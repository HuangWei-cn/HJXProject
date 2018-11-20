{ -----------------------------------------------------------------------------
  Unit Name: uHJX.Excel.IO
  Author:    黄伟
  Date:      09-四月-2017
  Purpose:   本单元借助nExcel完成对Excel 的访问。
  History:
  ----------------------------------------------------------------------------- }

unit uHJX.Excel.IO;

interface

uses
  System.Classes, System.SysUtils, System.Variants, System.Generics.Collections, System.Types,
  System.StrUtils, Winapi.Windows, Vcl.Dialogs,
  nExcel;

type
  TmyWorkbook = class(TXLSWorkbook)
    Opened: Boolean;
    FullName: string;
    function Open(FileName: WideString): Integer;
    function SheetByName(AName: WideString): IXLSWorkSheet;
  public
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

function TmyWorkbook.Open(FileName: WideString): Integer;
begin
  FullName := FileName;
  Result := inherited Open(FileName);
  Opened := Result = 1;
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
          if MessageBox(0, PWideChar('是否要关闭Excel后重试？'), '打开Excel工作簿',
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
begin
  Result := VarToDateTime(ASheet.Cells[ARow, ACol].value);
end;

function TExcelIO.GetIntValue(ASheet: IXLSWorkSheet; ARow: Integer; ACol: Integer): Integer;
var
  S: string;
begin
  Result := 0;
  S := GetStrValue(ASheet, ARow, ACol);
  TryStrToInt(S, Result);
end;

function TExcelIO.BookOpened(WBK: IXLSWorkBook; AName: string): Boolean;
begin
  Result := False;
  if WBK is TmyWorkbook then
      Result := SameText(TmyWorkbook(WBK).FullName, AName)
  else
      showmessage('只有用ExcelIO打开的工作簿才能判断工作簿FullName，请修改代码');
end;

class procedure TExcelIO.Excel_ShowSheet(ABKName: string; AShtName: string);
var
  XLApp, BK, Sht: Variant;
begin
  if not FileExists(ABKName) then Exit;
  try
    xlapp := null;
    XLApp := GetExcelApp; // CreateOleObject('Excel.Application');
    if VarIsNull(xlapp) or VarIsEmpty(XLApp) then xlapp := GetExcelApp(True);

    if VarIsNull(XLApp) or VarIsEmpty(XLApp) then
    begin
      ShellExecute(0, PChar('open'), PChar(ABKName), nil, nil, SW_SHOWNORMAL);
      Exit;
    end;

    XLApp.Visible := False;

    BK := XLApp.WorkBooks.Open(ABKName);
    if VarIsNull(BK) then Exit;
    Sht := BK.WorkSheets.Item[AShtName];
    if Not VarIsNull(Sht) then Sht.Activate;

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
  SrcBk, TagBk,
    SrcSheet, TagSheet: Variant;
  ShtList             : TStrings;
  i, j                : Integer;
  S, S1, S2           : String; // s1:source sheet name;s2:taget sheet name
  bDoQuit             : Boolean;
begin
  Result := False;
  if Trim(SrcSheets) = '' then Exit;

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
      if VarIsNull(XLApp) or VarIsEmpty(XLApp) then XLApp := GetExcelApp(True);
    end;
  except
    Exit;
  end;

  SrcBk := XLApp.WorkBooks.Open(SrcBook);
  if VarIsNull(SrcBk) then Exit;
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

      if VarIsNull(SrcSheet) then Continue;

      SrcSheet.Copy(Null, TagBk.WorkSheets.Item[TagBk.WorkSheets.Count]);
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
      //删除第一个表
      tagbk.WorkSheets[1].Delete;
      { todo:根据扩展名判断是保存为xlExcel9795还是xlExcel12 }
      TagBk.SaveAs(TagBook, 56); // xlExcel8 = 56: Excel 97~2003
      //TagBk.SaveAs(TagBook);
      Sleep(1000);
      Result := True;
    finally
      SrcBk.Close(False);
      TagBk.Close(False);
      // 如果XLApp是在本方法中获取的，则需要择机退出
      if bDoQuit then
        // 如果没有打开的工作簿了，说明是刚才创建的，就退出。
        if XLApp.WordBooks.Count = 0 then XLApp.Quit
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

    //若Excel Application没有Ready，等待
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
