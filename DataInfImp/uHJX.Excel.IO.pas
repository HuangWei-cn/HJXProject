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
    end;

var
    ExcelIO: TExcelIO;

implementation

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

initialization

ExcelIO := TExcelIO.Create;

finalization

ExcelIO.Free;

end.
