{ -----------------------------------------------------------------------------
  Unit Name: uHJX.Excel.IO
  Author:    ��ΰ
  Date:      09-����-2017
  Purpose:   ����Ԫ����nExcel��ɶ�Excel �ķ��ʡ�
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

    { �������򿪹���������������������ռ�õ����������ʾ�û��ر�Excel��Ȼ�����ԣ������û����ٳ��� }
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
        // �жϹ������Ƿ�򿪣�WBK�������ɱ��ഴ����
    function BookOpened(WBK: IXLSWorkBook; AName: string): Boolean;

        { ------ ������һ�����Excel����ķ��� ------- }
    class function GetExcelApp(CreateNew: Boolean = False): OleVariant;
    /// <summary>����Excel��ET���򿪹�����������ָ����sheetΪActiveSheet</summary>
    class procedure Excel_ShowSheet(ABKName, AShtName: string);
    /// <summary>����Excel��ET����SrcBook�п���������DesBook�У����DesBook=�����򲻴��ڣ��򴴽���
    /// ��������SrcSheetsΪ��Ҫ������Դ�������б���ʽ��"Դ����:Ŀ�ı���#13#10"�����
    /// ֻ��Դ��������Ŀ�ı���=Դ������������Ŀ�ı���������������Ĺ�����</summary>
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
  Description: ��������Excel������������ù�������Excelռ�ã�����ʾ�û��ر�
  Excel���ٴ򿪣������ظ���Σ�ֱ���ɹ��򿪻��û�������
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
          if MessageBox(0, PWideChar('�Ƿ�Ҫ�ر�Excel�����ԣ�'), '��Excel������',
            MB_ICONWARNING or MB_RETRYCANCEL) = IDCANCEL then
              bExit := True;
        end;
    else
      begin
        bExit := True;
        showmessage('��֧�ֵ��ļ����͡�');
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
      showmessage('ֻ����ExcelIO�򿪵Ĺ����������жϹ�����FullName�����޸Ĵ���');
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
  Description: ��SrcBook����������ָ��������Ŀ�깤����DesBook
  ָ���Ĺ�������ScrSheets�����У��ò�����ʽΪ"SourcesheetName:targetsheetName#13#10"��
  �������¹�������Դ������ΪTargetSheetName����TargetSheetName=''��û��
  ��һ�������ԭ������
  ����XLApp��ExcelApplication����ΪNull�����ڱ������л�ȡ�򴴽�һ������XLapp��
  �ڱ������л�ȡ�򴴽��ģ��򱾷��������˳�������ʹ��Quit������
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
    bDoQuit := False; // ���˳�application
    // ������ݽ�����XLAppΪ�գ�����Ҫ�ڱ������л�ȡ�򴴽�ExcelApplication������������ʱ��Ҫ���
    // �˳��������ݽ���XLApp�����������˳���ֻ�ǹر��ڱ������д򿪵Ĺ�������
    if VarIsNull(XLApp) or VarIsEmpty(XLApp) then
    begin
      bDoQuit := True;
      // �������������XLApp��Ҫ����Quit��������Ϊ�п��ܰ��Ѿ��򿪵����ڱ༭��������ʵ���رյ���
      // �Ȳ����������ǻ�ȡ�Ѿ��򿪵�ExcelApplicationʵ��
      XLApp := GetExcelApp;
      // û�У��򴴽�һ��
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
        { TODO -ohw -cExcel.IO : ���ж�SheetName�Ƿ��Ѵ��ڣ�����������Ҫ������ }
        try
          TagSheet.Name := S2;
        except
        end;
      end;
    end;
    // ִ�е�������ǿ��������
    try
      //ɾ����һ����
      tagbk.WorkSheets[1].Delete;
      { todo:������չ���ж��Ǳ���ΪxlExcel9795����xlExcel12 }
      TagBk.SaveAs(TagBook, 56); // xlExcel8 = 56: Excel 97~2003
      //TagBk.SaveAs(TagBook);
      Sleep(1000);
      Result := True;
    finally
      SrcBk.Close(False);
      TagBk.Close(False);
      // ���XLApp���ڱ������л�ȡ�ģ�����Ҫ����˳�
      if bDoQuit then
        // ���û�д򿪵Ĺ������ˣ�˵���ǸղŴ����ģ����˳���
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

    //��Excel Applicationû��Ready���ȴ�
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
