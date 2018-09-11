{   ����Ԫ��XLGridģ�崦����������class helper��ʽ���ṩ��GenGrid�������÷�������ģ�崴��XLS���
    Ҫʹ�ñ���Ԫ����Ҫ���������á�
}
unit uHJX.Template.XLGridHelper;

interface

uses
    System.Classes, System.Types, System.SysUtils, System.Variants, System.Generics.Collections,
    nExcel,
    uHJX.Template.XLGrid;

type
    { Gengrid������ɸ���ģ�崴�����ݱ�Ĺ����������������ӻ�ȡģ�幤������������������д����
      ��ϵ�����񡣶��ڵ�������˵��ֻ��Ҫ��T.GenGrid(BookName, DesignName)���ɣ�����ֵ�Ǵ����Ĺ���
      ������BookName�ǳɹ����������ƣ���������򿪷����½���
 }
    TXLGridTemplateHelper = class helper for TXLGridTemplate
    private
        // �������ͱ�ͷ��Ԫ������ʵ��Ϣ�滻ռλ��
        function ProcHeadCell(AValue: Variant): Variant;
        // �������ݵ�Ԫ����Ҫ����ռλ��
        function ProcDataCell(AValue: Variant): string;
        // ���������
        procedure ProcTitleRange(Sht: IXLSWorksheet; AMeter: string);
        // �����ͷ��
        procedure ProcHeadRange(Sht: IXLSWorksheet; AMeter: string);
        // ������������Ԫ��ռλ����ʹ֮���ֶ���ϵ����
        procedure ProcDataRange(Sht: IXLSWorksheet; AMeter: string);
    public
        function GenGrid(NewBookName, ADsnName: string): string; overload;
        function GenGrid(NewBook: IXLSWorkbook; ADsnName: string): string; overload;
    end;

    { Test }
var
    TmpBookName: string; // this variable for test.
    TmpBook: IXLSWorkbook;

implementation

uses
    System.RegularExpressions;

const
    { ����ͱ�ͷռλ��������ʽ����ϸ���ݲο�uHJX.Template.WGProc�е�������ʽע�� }
    RegExStr =
        '%([a-zA-Z]*|((Meter)([1-9][0-9]*)\.)?(DesignName|(PD|MD)([1-9][0-9]*)\.(Name|Alias|DataUnit)))%';

    { ���ݵ�Ԫռλ��������ʽ���μ�uhjx.template.wggrid��DataRowExStr��ע�� }
    DataRegEStr = '%(DTScale|Annotation|((Meter)(n|[1-9][0-9]*)\.)?(PD|MD)([1-9][0-9]*))%';

type
    TXLDataCell = record
        Row, Col: Integer;
        OffsetStep: Integer;
        TempStr: string;
        Specifier: string;
        Field: TObject;
        GridType: TXLGridType;
        // Offsetƫ�����ݵ�Ԫ������ǵ��л��У���ƫ��1�л�1�У�����n����ƫ��n�У���������ʵ��
        // ���л���еĶ�̬��
        procedure Offset;
        function GetValue: Variant;
        procedure SetCellValue(Sht: IXLSWorksheet);
    end;

var
    RegEx: TRegEx;
    RegExData: TRegEx;
    MyColl: TMatchCollection;
    MyGrps: TGroupCollection;
    DataRange: TArray<TXLDataCell>;

function __GetSheet(ABook: IXLSWorkbook; SheetName: string): IXLSWorksheet;
var
    i: Integer;
begin
    Result := nil;
    i := ABook.WorkSheets.Index[SheetName];
    if i > 0 then Result := ABook.WorkSheets.Entries[i];
end;

function __HasSheet(ABook: IXLSWorkbook; AName: string): Boolean;
begin
    Result := False;
    if ABook.WorkSheets.Index[AName] > 0 then Result := True;
end;

// ���ؿ��õ����ƣ����AName���ڣ����Զ������ţ��ٲ飬ֱ��û��Ϊֹ
function __GetAltName(ABook: IXLSWorkbook; AName: string): string;
var
    i: Integer;
begin
    Result := AName;
    i := 0;
    repeat
        if __HasSheet(ABook, Result) then
        begin
            inc(i);
            Result := AName + IntToStr(i);
        end
        else Break;
    until False;
end;

function __DupWorksheet(SrcSheet: IXLSWorksheet; DesBook: IXLSWorkbook; NewSheetName: string)
    : IXLSWorksheet;
begin
    Result := nil;
    if (SrcSheet = nil) or (DesBook = nil) then Exit;

    Result := DesBook.WorkSheets.Add;

    // ����Ƿ�������������������ڣ����Զ��������
    Result.Name := __GetAltName(DesBook, NewSheetName);

    // ��ԭ����usedrange���±�
    with SrcSheet.UsedRange do
    begin
        Copy(Result.RCRange[FirstRow, FirstCol, LastRow + 1, LastCol + 1], xlPasteAll);
        Result.RCRange[FirstRow, FirstCol, LastRow + 1, LastCol + 1].Formula := Formula;
    end;
end;

{ ���������Ҫ���ǵ����л����ƫ�Ƶ����� }
procedure TXLDataCell.Offset;
begin
    case GridType of
        xlgDynRow: inc(Row, OffsetStep);
        xlgStatic:;
        xlgDynCol: inc(Col, OffsetStep);
    end;
end;

{ ���ֶ���ȡ�����ݣ����뵥Ԫ���У���Ԫ��ĸ�ʽ������ģ���һ�� }
function TXLDataCell.GetValue: Variant;
begin
    // Result := Null;
    Result := 'Test';
end;

procedure TXLDataCell.SetCellValue(Sht: IXLSWorksheet);
begin
    Sht.Cells[Self.Row, Self.Col].Value := GetValue;
end;

{ ================================================================================================ }
{ ����Head��title��Ԫ��ռλ�����ҵ���Ӧ��Meter���������ظ�ֵ }
function __ProcHeadCell(AValue: Variant; AMeter: string): Variant;
var
    S: string;
    i: Integer;
begin
    Result := AValue;
    S := VarToStr(AValue);
    if S = '' then Exit;
    MyColl := RegEx.Matches(S);
    for i := 0 to MyColl.Count - 1 do
    begin
        MyGrps := MyColl.Item[i].Groups;
        case MyGrps.Count of
            2:
                begin
                    // ��ʱ����
                    if SameText(MyGrps.Item[1].Value, 'GroupName') then
                            Result := StringReplace(S, MyColl.Item[i].Value, 'GroupName',
                            [rfReplaceall])
                    else
                    begin
                        Result := StringReplace(S, MyColl.Item[i].Value, MyGrps.Item[1].Value,
                            [rfReplaceall]);
                    end;
                end;

            6: // ��Ӧ��ʽΪ%Meter1.DesignName%���ض�Ӧ��������
                begin
                    // ��ʱ����
                    Result := StringReplace(S, MyColl.Item[i].Value, MyGrps.Item[1].Value,
                        [rfReplaceall]);
                end;

            9:
                begin
                    // ��ʱ����
                    if MyGrps.Item[2].Value = '' then
                            Result := StringReplace(S, MyColl.Item[i].Value, MyGrps.Item[5].Value,
                            [rfReplaceall])
                    else Result := StringReplace(S, MyColl.Item[i].Value, MyGrps.Item[1].Value,
                            [rfReplaceall]);
                end;

        end;
    end;
end;

{ ������������Ԫ��ռλ������д��DataCell�ṹ�ж�Ӧ������ж�Ӧ�����ֶ������ֶζ���������Դ����
  Ϊ�ַ��������Բ��ùܣ�����д���ݷ����лὫԴ���򿽱�����λ�� }
procedure __ProcDataCell(AValue: Variant; ACell: TXLDataCell);
var
    S: string;
begin
    S := VarToStr(AValue);
    ACell.TempStr := S;

    if S = '' then Exit;
    MyColl := RegEx.Matches(S);
    if MyColl.Count > 0 then
    begin
        ACell.Specifier := MyColl.Item[0].Value;
        // ����ٶ�ÿ����Ԫ����ֻ����һ��ռλ������ֻ����һ���ֶΡ�����ʵ����������ʽ�ɽ��������
        // ռλ��������Ϊ�����������涨ֻ�ܰ���һ���ֶΣ���������Ԫ�����ݾ�������ֶε����ݡ�
        // �����ӵĴ����Ժ���˵�����ָ������ж����ô���
        MyGrps := MyColl.Item[0].Groups;
        case MyGrps.Count of
            2:
                begin
                    ACell.Specifier := MyGrps.Item[1].Value;
                end;
            7:
                begin
                    ACell.Specifier := MyGrps.Item[1].Value;
                end;
        end;
    end;
end;

function TXLGridTemplateHelper.ProcHeadCell(AValue: Variant): Variant;
begin

end;

function TXLGridTemplateHelper.ProcDataCell(AValue: Variant): string;
begin

end;

procedure TXLGridTemplateHelper.ProcTitleRange(Sht: IXLSWorksheet; AMeter: string);
var
    iRow, iCol: Integer;
    S, Str: string;
begin
    for iCol := TitleRect.Left to TitleRect.Right do
        for iRow := TitleRect.top to TitleRect.Bottom do
            // Sht.Cells[iRow, iCol].Value := ProcHeadCell(Sht.Cells[iRow, iCol].Value);
                Sht.Cells[iRow, iCol].Value := __ProcHeadCell(Sht.Cells[iRow, iCol].Value, AMeter);
end;

procedure TXLGridTemplateHelper.ProcHeadRange(Sht: IXLSWorksheet; AMeter: string);
var
    iRow, iCol: Integer;
begin
    for iCol := HeadRect.Left to HeadRect.Right do
        for iRow := HeadRect.top to HeadRect.Bottom do
            // Sht.Cells[iRow, iCol].Value := ProcHeadCell(Sht.Cells[iRow, iCol].Value);
                Sht.Cells[iRow, iCol].Value := __ProcHeadCell(Sht.Cells[iRow, iCol].Value, AMeter);
end;

{ ������������������������д���ݡ���������ɵĹ����ǽ���������������Ԫ���ռλ��������Ԫ����ֶ���ϵ
  ��������Ҫ��д����ʱ���ֶ��������뼴�ɡ���д���ݵķ���������һ�� }
procedure TXLGridTemplateHelper.ProcDataRange(Sht: IXLSWorksheet; AMeter: string);
var
    iRow, iCol: Integer;
    i, n: Integer;
    Offrow, Offcol: Integer;
    newRect: trect;
    SrcRange: IXLSRange;
    S: string;
    procedure CopyNewRange;
    begin
        newRect.top := newRect.top + Offrow;
        newRect.Left := newRect.Left + Offcol;
        newRect.Right := newRect.Right + Offcol;
        newRect.Bottom := newRect.Bottom + Offrow;
        SrcRange.Copy(Sht.RCRange[newRect.top, newRect.Left, newRect.Bottom, newRect.Right]);
    end;

begin
    SetLength(DataRange, 0);
    SetLength(DataRange, (DataRect.Width + 1) * (DataRect.Height + 1));
    // ����ռλ��
    i := 0;
    for iCol := DataRect.Left to DataRect.Right do
        for iRow := DataRect.top to DataRect.Bottom do
        begin
            DataRange[i].Row := iRow;
            DataRange[i].Col := iCol;
            DataRange[i].TempStr := trim(VarToStr(Sht.Cells[iRow, iCol].Value));
            DataRange[i].Field := nil;
            DataRange[i].GridType := Self.GridType;

            case Self.GridType of
                xlgDynRow: DataRange[i].OffsetStep := DataRect.Bottom - DataRect.top + 1;
                xlgStatic: DataRange[i].OffsetStep := 0;
                xlgDynCol: DataRange[i].OffsetStep := DataRect.Right - DataRect.Left + 1;
            end;
            // �����ֶ���
            // S := ProcDataCell(Sht.Cells[iRow, iCol].Value);
            __ProcDataCell(Sht.Cells[iRow, iCol].Value, DataRange[i]);
            if S <> '' then
            begin
                // datarange[i].Field := DS.FindField(s);
                DataRange[i].Specifier := 'Field: ' + S;
            end;
            inc(i);
        end;

    // �������ݣ�ֱ���������
    SrcRange := Sht.RCRange[DataRect.top, DataRect.Left, DataRect.Bottom, DataRect.Right];
    Offrow := 0;
    Offcol := 0;
    newRect := DataRect;
    { newRect.Left := DataRect.Left;
      newRect.top := DataRect.top;
      newRect.Right := DataRect.Right;
      newRect.Bottom := DataRect.Bottom; }
    case GridType of
        xlgDynRow: Offrow := DataRect.Bottom - DataRect.top + 1;
        xlgDynCol: Offcol := DataRect.Right - DataRect.Left + 1;
    end;
    { srcrange := sht.rcrange[DataRect.Left, DataRect.Top, DataRect.Right, DataRect.Bottom];
      offrow := 0; offcol := 0;
      newrect.left := datarect.left;newrect.top:=datarect.top;newrect.right := datarect.right;
      newrect.bottom := datarect.bottom;
      case gridtype of
      xlgdynrow: offrow := datarect.bottom - datarect.top + 1;
      xlgdyncol: offcol := datarect.right -datarect.left + 1;
      end;
      if ds.recordcount > 0 then
      begin
      ds.first;
      repeat
      for i := 0 to High(DataRange) do
      begin
      Datarange[i].SetCellValue(sht);
      DataRange[i].Offset;
      end;
      ds.Next;

      if not ds.next then
      begin
      newrect.left := newrect + offcol;
      newrect.top ::= newrect.top + offrow;
      newrect.right := newrect.right + Offcol;
      newrect.bottom := newrect.bottom + offrow
      srcrange.copy(sht.rcrange[newrect.left,newrect.top,newrect.right,newrect.bottom]);
      end;
      until ds.eof;
      end;
 }
    for n := 0 to 5 do
    begin
        // copy source range to new position

        // fill datas
        for i := 0 to high(DataRange) do
        begin
            DataRange[i].SetCellValue(Sht);
            DataRange[i].Offset;
        end;
        // ��ԭ�������򿽱���ʽ�����ݵ���λ��
        SrcRange.Copy(Sht.RCRange[newRect.top, newRect.Left, newRect.Bottom, newRect.Right]);
        newRect.Offset(Offcol, Offrow);
    end;
end;

// ����ģ�崴�����ݱ� ����ֵΪ�����Ĺ��������ƣ������ؽ����
function TXLGridTemplateHelper.GenGrid(NewBookName, ADsnName: string): string;
var
    Book: IXLSWorkbook;
begin
    Result := '';
    Book := TXLSWorkbook.Create;

    if FileExists(NewBookName) then Book.Open(NewBookName)
    else Book.SaveAs(NewBookName);

    Result := GenGrid(Book, ADsnName);

    Book.Close;
    Book := nil;
end;

function TXLGridTemplateHelper.GenGrid(NewBook: IXLSWorkbook; ADsnName: string): string;
var
    tmpSheet, resSheet: IXLSWorksheet; // ģ�幤�����ɹ�������
begin
    Result := '';
    tmpSheet := __GetSheet(TmpBook, Self.TemplateSheet);
    if tmpSheet = nil then Exit;

    // ��ģ�幤�����Ƶ��¹������У�ͬʱ�ж��Ƿ����ͬ��������
    resSheet := __DupWorksheet(tmpSheet, NewBook, ADsnName);
    if resSheet = nil then Exit;
    Result := resSheet.Name;

    // ������⡢��ͷ�Ⱦ�̬���֣��ø��ֲ����滻ռλ��
    ProcTitleRange(resSheet, ADsnName);
    ProcHeadRange(resSheet, ADsnName);

    // ����������
    // ��ȡ���ݣ�������
    ProcDataRange(resSheet, ADsnName);

    NewBook.Save;
    NewBook.Close;

end;

initialization

RegEx := TRegEx.Create(RegExStr);
RegExData := TRegEx.Create(DataRegEStr);

finalization

SetLength(DataRange, 0);

end.

