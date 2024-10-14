{ -----------------------------------------------------------------------------
  Unit Name: uHJX.Excel.IO
  Author:    黄伟
  Date:      09-四月-2017
  Purpose:   本单元借助nExcel完成对Excel 的访问。
  History:
  2024-10-11
    给TmyWorkbook增加一个FileAge属性，用于记录文件最后编辑时间，这个属性在检查工作簿
    是否在打开后被修改过时有用。
  2024-10-14
    修改了TmyWorkbook的Open方法，现在采用先用TFileStream打开文件，再用inherited Open(FileStream)的方式打开。
    这样就可以解决文件被独占的问题。
  ----------------------------------------------------------------------------- }

unit uHJX.Excel.IO;
{ TODO:采用文件池的方式提供更佳的性能。若要避免打开的文件被破坏，可以考虑用TXLSWorkbook.OpenWorkbook
方法中打开流的方式 }
interface

uses
  System.Classes, System.SysUtils, System.Variants, System.Generics.Collections, System.Types,
  System.StrUtils, Winapi.Windows, Vcl.Dialogs,
  nExcel;

type
  TmyWorkbook = class(TXLSWorkbook)
    Opened: Boolean;
    FullName: string;
    /// <summary>文件最后编辑时间
    /// 单位：毫秒，从1970年1月1日午夜（格林威治标准时间）开始的毫秒数
    /// 添加这一项的目的在于，可以方便地判断文件是否被修改过，以便在读取时进行提示。本类打开的工作簿，
    /// 有可能在打开后被Excel编辑过，因此当程序需要再次访问该工作簿时，需要检查文件的最后编辑时间，若
    /// 是新文件，则需要重新打开
    ///</summary>
    FileAge: LongInt; //增加一个最后编辑时间的Field
    /// 修改了Open方法。之前是用inherited Open(FileName)，当Excel已经打开了文件，会因文件被独占而无法打开。
    /// 现在采用先用TFileStream打开文件，再用inherited Open(FileStream)的方式打开。这样就可以解决文件被独占的问题。
    function Open(FileName: WideString): Integer;
    function SheetByName(AName: WideString): IXLSWorkSheet;
  public
    constructor Create; override;
    function Close: Integer; override;
  end;

  { 本方法打开工作簿，若遇到工作簿被占用的情况，会提示用户关闭Excel，然后再试，除非用户不再尝试 }
type
  TExcelIO = class
  public
    function OpenWorkbook(var WBK: IXLSWorkBook; AName: String): Boolean;

    function HasSheet(ABook: IXLSWorkBook; AName: string): Boolean;

    function GetSheet(ABook: IXLSWorkBook; AName: string): IXLSWorkSheet;

    function GetStrValue(ASheet: IXLSWorkSheet; ARow, ACol: Integer): String;
    function GetFloatValue(ASheet: IXLSWorkSheet; ARow, ACol: Integer): Double;
    function GetDateTimeValue(ASheet: IXLSWorkSheet; ARow, ACol: Integer): TDateTime;
    function GetIntValue(ASheet: IXLSWorkSheet; ARow, ACol: Integer): Integer;
    function GetBlankRow(ASheet: IXLSWorkSheet; StartRow, ACol: Integer): Integer;
    // 返回Variant类型的值
    function GetValue(ASheet: IXLSWorkSheet; ARow, ACol: Integer): Variant;
    // 判断工作簿是否打开，WBK必须是由本类创建的
    function BookOpened(WBK: IXLSWorkBook; AName: string): Boolean;

    { ------ 下面是一组调用Excel程序的方法 ------- }
    class function GetExcelApp(CreateNew: Boolean = False): OleVariant;
    /// <summary>启动Excel或ET，打开工作簿，并设指定的sheet为ActiveSheet</summary>
    class procedure Excel_ShowSheet(ABKName, AShtName: string);
    /// <summary>启动Excel或ET，从SrcBook中拷贝工作表到DesBook中，如果DesBook=‘’或不存在，则创建新
    /// 工作簿。SrcSheets为需要拷贝的源工作表列表，格式是"源表名:目的表名#13#10"。如果
    /// 只有源表名，则目的表名=源表名，否则用目的表名重命名拷贝后的工作表</summary>
    class function Excel_CopySheet(XLApp: OleVariant; SrcBook, TagBook: String;
      SrcSheets: String): Boolean;
  end;

var
  ExcelIO: TExcelIO;

implementation

uses
  ComObj, ShellAPI;

constructor TmyWorkbook.Create;
begin
  inherited;
  FileAge := -1;
end;


{
  Function: TmyWorkbook.Open
  Purpose: Opens the specified Excel workbook file.

  Parameters:
    FileName: WideString - The name of the Excel workbook file to be opened.

  Return Value:
    Integer - The result of the workbook opening operation. A value of 1 indicates
              successful opening, while a value of -1 indicates failure.
}
function TmyWorkbook.Open(FileName: WideString): Integer;
var
  FStream: TFileStream;
begin
  FullName := FileName;
  FileAge := System.SysUtils.FileAge(FileName);
  FStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := inherited Open(FStream);
    Opened := Result = 1;
  finally
    FStream.Free;
  end;
  //Result := inherited Open(FileName);
end;


function TmyWorkbook.SheetByName(AName: WideString): IXLSWorkSheet;
var
  i: Integer;
begin
  Result := nil;
  i := Self.Sheets.Index[AName];
  if i <> -1 then
    Result := Self.Sheets.Entries[Self.Sheets.Index[AName]];
end;

function TmyWorkbook.Close: Integer;
begin
  FullName := '';
  Result := inherited Close;
  Opened := False;
end;

{ -----------------------------------------------------------------------------
  Procedure  : OpenWorkbook
  Description: 本函数打开Excel工作簿，如果该工作簿被Excel占用，则提示用户关闭
  Excel后再打开，可以重复多次，直到成功打开或用户放弃。
  ----------------------------------------------------------------------------- }
function TExcelIO.OpenWorkbook(var WBK: IXLSWorkBook; AName: string): Boolean;
var
  bExit     : Boolean;
  OpenResult: Integer;
begin
  Result := False;
  if WBK = nil then
    WBK := TmyWorkbook.Create;
  bExit := False;
  repeat
    if WBK is TmyWorkbook then
      OpenResult := TmyWorkbook(WBK).Open(AName)
    else
      OpenResult := WBK.Open(AName);

    case OpenResult of
      1:
        begin
          bExit := True;
          Result := True;
        end;
      -1:
        begin
          if MessageBox(0, PWideChar(AName + '无法打开，是否要关闭Excel后重试？'#13#10 +
            '若Excel或WPS没有占用该文件，则该文件可能是由WPS编辑过的、存在问题' +
            '的Excel 2007或更高版本的文件(xlsx格式), 请用真正的Excel保存一遍再' + '试试。若还不行，那就干点别的吧，别用了。'), '打开Excel工作簿',
            MB_ICONWARNING or MB_RETRYCANCEL) = IDCANCEL then
            bExit := True;
        end;
    else
      begin
        bExit := True;
        showmessage('不支持的文件类型。');
      end;
    end;
  until bExit;
end;

function TExcelIO.HasSheet(ABook: IXLSWorkBook; AName: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to ABook.Sheets.Count do
    if ABook.Sheets[i].Name = AName then
    begin
      Result := True;
      Break;
    end;
end;

function TExcelIO.GetSheet(ABook: IXLSWorkBook; AName: string): IXLSWorkSheet;
var
  i: Integer;
begin
  Result := nil;
  for i := 1 to ABook.Sheets.Count do
    if ABook.Sheets[i].Name = AName then
    begin
      Result := ABook.Sheets[i];
      Break;
    end;
end;

function TExcelIO.GetStrValue(ASheet: IXLSWorkSheet; ARow: Integer; ACol: Integer): string;
begin
  Result := '';
  Result := VarToStr(ASheet.Cells[ARow, ACol].value);
end;

function TExcelIO.GetFloatValue(ASheet: IXLSWorkSheet; ARow: Integer; ACol: Integer): Double;
var
  S: String;
begin
  Result := 0;
  S := Trim(VarToStr(ASheet.Cells[ARow, ACol].value));
  TryStrToFloat(S, Result);
end;

function TExcelIO.GetDateTimeValue(ASheet: IXLSWorkSheet; ARow: Integer; ACol: Integer): TDateTime;
var
  S, S1: string;
begin
  Result := 0;
  try
    Result := VarToDateTime(ASheet.Cells[ARow, ACol].value);
  except
    on e: Exception do
    begin
      Result := 0;
      S1 := VarToStr(ASheet.Cells[ARow, ACol].value);
      if ASheet.Workbook is TmyWorkbook then
        S := (ASheet.Workbook as TmyWorkbook).FullName + '中的工作簿' + ASheet.Name
      else
        S := '工作簿' + ASheet.Name;
      S := S + format('第%d行第%d列内容“%s”不是合法的日期格式，请检查。', [ARow, ACol, S1]);
      showmessage(S);
    end;
  end;
end;

function TExcelIO.GetIntValue(ASheet: IXLSWorkSheet; ARow: Integer; ACol: Integer): Integer;
var
  S: string;
begin
  Result := 0;
  S := GetStrValue(ASheet, ARow, ACol);
  TryStrToInt(S, Result);
end;

function TExcelIO.GetValue(ASheet: IXLSWorkSheet; ARow: Integer; ACol: Integer): Variant;
begin
  varClear(Result);
  Result := ASheet.Cells[ARow, ACol].value;
end;

function TExcelIO.BookOpened(WBK: IXLSWorkBook; AName: string): Boolean;
begin
  Result := False;
  if WBK is TmyWorkbook then
    Result := SameText(TmyWorkbook(WBK).FullName, AName)
  else
    showmessage('只有用ExcelIO打开的工作簿才能判断工作簿FullName，请修改代码');
end;

function TExcelIO.GetBlankRow(ASheet: IXLSWorkSheet; StartRow: Integer; ACol: Integer): Integer;
var
  i: Integer;
  S: string;
begin
  Result := 0;
  S := GetStrValue(ASheet, ASheet.UsedRange.Rows.Count, ACol);
  if S <> '' then
    Result := ASheet.UsedRange.Rows.Count + 1
  else
    for i := ASheet.UsedRange.Rows.Count downto StartRow do
    begin
      S := GetStrValue(ASheet, i, ACol);
      if S <> '' then
      begin
        Result := i + 1;
        Break;
      end;
    end;
end;

class procedure TExcelIO.Excel_ShowSheet(ABKName: string; AShtName: string);
var
  XLApp, BK, Sht: Variant;
begin
  if not FileExists(ABKName) then
    Exit;
  try
    XLApp := null;
    XLApp := GetExcelApp; // CreateOleObject('Excel.Application');
    if VarIsNull(XLApp) or VarIsEmpty(XLApp) then
      XLApp := GetExcelApp(True);

    if VarIsNull(XLApp) or VarIsEmpty(XLApp) then
    begin
      ShellExecute(0, PChar('open'), PChar(ABKName), nil, nil, SW_SHOWNORMAL);
      Exit;
    end;

    XLApp.Visible := False;

    BK := XLApp.WorkBooks.Open(ABKName);
    if VarIsNull(BK) then
      Exit;
    Sht := BK.WorkSheets.Item[AShtName];
    if Not VarIsNull(Sht) then
      Sht.Activate;

    XLApp.Visible := True;
    XLApp.WindowState := -4143; // xlNormal
  except
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : Excel_CopySheet
  Description: 从SrcBook工作簿拷贝指定工作表到目标工作簿DesBook
  指定的工作表在ScrSheets参数中，该参数形式为"SourcesheetName:targetsheetName#13#10"，
  拷贝到新工作簿后，源表将命名为TargetSheetName。若TargetSheetName=''或没有
  这一项，将沿用原表名。
  参数XLApp是ExcelApplication，若为Null，则在本方法中获取或创建一个。若XLapp是
  在本方法中获取或创建的，则本方法负责退出，否则不使用Quit方法。
  ----------------------------------------------------------------------------- }
class function TExcelIO.Excel_CopySheet(XLApp: OleVariant; SrcBook: string; TagBook: string;
  SrcSheets: string): Boolean;
var
  SrcBk, TagBk, SrcSheet, TagSheet: Variant;
  ShtList                         : TStrings;
  i, j                            : Integer;
  S, S1, S2                       : String; // s1:source sheet name;s2:taget sheet name
  bDoQuit                         : Boolean;
begin
  Result := False;
  if Trim(SrcSheets) = '' then
    Exit;

  try
    bDoQuit := False; // 不退出application
    // 如果传递进来的XLApp为空，则需要在本方法中获取或创建ExcelApplication，当方法结束时就要择机
    // 退出；若传递进来XLApp参数，则不能退出，只是关闭在本方法中打开的工作簿。
    if VarIsNull(XLApp) or VarIsEmpty(XLApp) then
    begin
      bDoQuit := True;
      // 用这个方法，当XLApp就要慎用Quit方法，因为有可能把已经打开的正在编辑工作簿的实例关闭掉。
      // 先不创建，而是获取已经打开的ExcelApplication实例
      XLApp := GetExcelApp;
      // 没有，则创建一个
      if VarIsNull(XLApp) or VarIsEmpty(XLApp) then
        XLApp := GetExcelApp(True);
    end;
  except
    Exit;
  end;

  SrcBk := XLApp.WorkBooks.Open(SrcBook);
  if VarIsNull(SrcBk) then
    Exit;
  TagBk := XLApp.WorkBooks.Add;

  ShtList := TStringList.Create;
  ShtList.Text := SrcSheets;
  try
    XLApp.ScreenUpdating := False;
    for i := 0 to ShtList.Count - 1 do
    begin
      S := ShtList.Strings[i];
      j := Pos(':', S);
      if j = 0 then
      begin
        S1 := S;
        S2 := '';
      end
      else
      begin
        S1 := Copy(S, 1, j - 1);
        S2 := Trim(Copy(S, j + 1, length(S) - j));
      end;
      SrcSheet := SrcBk.WorkSheets.Item[S1];

      if VarIsNull(SrcSheet) then
        Continue;

      SrcSheet.Copy(null, TagBk.WorkSheets.Item[TagBk.WorkSheets.Count]);
      TagSheet := TagBk.WorkSheets.Item[TagBk.WorkSheets.Count];
      if S2 <> '' then
      begin
        { TODO -ohw -cExcel.IO : 先判断SheetName是否已存在，若存在则需要重命名 }
        try
          TagSheet.Name := S2;
        except
        end;
      end;
    end;
    // 执行到这里，算是拷贝完毕了
    try
      // 删除第一个表
      TagBk.WorkSheets[1].Delete;
      { todo:根据扩展名判断是保存为xlExcel9795还是xlExcel12 }
      TagBk.SaveAs(TagBook, 56); // xlExcel8 = 56: Excel 97~2003
      // TagBk.SaveAs(TagBook);
      Sleep(1000);
      Result := True;
    finally
      SrcBk.Close(False);
      TagBk.Close(False);
      // 如果XLApp是在本方法中获取的，则需要择机退出
      if bDoQuit then
        // 如果没有打开的工作簿了，说明是刚才创建的，就退出。
        if XLApp.WordBooks.Count = 0 then
          XLApp.Quit
    end;
    Result := True;
  finally
    ShtList.Free;
    XLApp.ScreenUpdating := True;
  end;
end;

class function TExcelIO.GetExcelApp(CreateNew: Boolean = False): OleVariant;
begin
  Result := Unassigned;
  try
    if CreateNew then
      Result := CreateOleObject('Excel.Application')
    else
      Result := GetActiveOleObject('Excel.Application');

    // 若Excel Application没有Ready，等待
    if not(VarIsNull(Result) or VarIsEmpty(Result)) then
      while Result.Ready = False do;

  except
    { on EOleSysError do
      try
      Result := CreateOleObject('Excel.Application');
      except
      end; }
  end;
end;

initialization

ExcelIO := TExcelIO.Create;

finalization

ExcelIO.Free;

end.
