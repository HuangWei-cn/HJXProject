{ ����Ԫ��XLGridģ�崦����
    ��������WebGridProc�ķ������ṩһ�������������¡�
}
unit uHJX.Template.XLGridProc;

interface

uses
    System.Classes, System.Types, System.SysUtils, System.Variants, System.Generics.Collections,
    nExcel,
    uHJX.Intf.AppServices, uHJX.Classes.Meters, uHJX.Template.XLGrid;

{ ��Ҫ�ṩ��ֹ���ڲ��� }
function GenXLGrid(grdTmp: TXLGridTemplate; ADsnName: string; TmpBookName, ResBookName: string)
    : string; overload;
function GenXLGrid(grdTmp: TXLGridTemplate; ADsnName: string; TmpBook, ResBook: IXLSWorkBook)
    : string; overload;

implementation

uses
    uHJX.Template.ProcSpecifiers, Data.DB, DataSnap.DBClient, System.Win.ComObj;

type
    TXLDataCell = record
        Row, Col: Integer;
        OffsetStep: Integer;
        TempStr: string;
        Specifier: string;
        Field: TField;
        GridType: TXLGridType;
        // Offsetƫ�����ݵ�Ԫ������ǵ��л��У���ƫ��1�л�1�У�����n����ƫ��n�У���������ʵ��
        // ���л���еĶ�̬��
        procedure Offset;
        function GetValue: Variant;
        procedure SetCellValue(Sht: IXLSWorkSheet);
    end;

var
    DataRangeCells: TArray<TXLDataCell>;

function __GetSheet(ABook: IXLSWorkBook; SheetName: string): IXLSWorkSheet;
var
    i: Integer;
begin
    Result := nil;
    i := ABook.WorkSheets.Index[SheetName];
    if i > 0 then Result := ABook.WorkSheets.Entries[i];
end;

function __HasSheet(ABook: IXLSWorkBook; AName: string): Boolean;
begin
    Result := False;
    if ABook.WorkSheets.Index[AName] > 0 then Result := True;
end;

// ���ؿ��õ����ƣ����AName���ڣ����Զ������ţ��ٲ飬ֱ��û��Ϊֹ
function __GetAltName(ABook: IXLSWorkBook; AName: string): string;
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

{ ��nExcel�Լ����ƹ�������ʽ�ǿ���ԭ��UsedRange }
function __DupWorksheet(SrcSheet: IXLSWorkSheet; DesBook: IXLSWorkBook; NewSheetName: string)
    : IXLSWorkSheet;
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

    //nExcel�޷����ö���������˲����Ľ������û�ж������Ĺ�����
end;

{ Use Excel or ET duplacation a worksheet to an other workbook. }
function __CopyWorkSheet(SrcSheet: IXLSWorkSheet; DesBook: IXLSWorkBook; NewSheetName: string)
    : IXLSWorkSheet;
var
    Obj: OleVariant;
begin
    Result := nil;
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
    if Field = nil then Result := null
    else Result := Field.Value;
end;

procedure TXLDataCell.SetCellValue(Sht: IXLSWorkSheet);
begin
    Sht.Cells[Self.Row, Self.Col].Value := GetValue;
end;

{ ================================================================================================ }
{ ����Head��title��Ԫ��ռλ�����ҵ���Ӧ��Meter���������ظ�ֵ }
function __ProcHeadCell(AValue: Variant; AMeter: TMeterDefine; AsGroup: Boolean = False): Variant;
var
    S: string;
    i: Integer;
begin
    Result := AValue;
    S := VarToStr(AValue);
    if S = '' then Exit;
    Result := ProcParamSpecifiers(S, AMeter, AsGroup);
end;

{ ������������Ԫ��ռλ������д��DataCell�ṹ�ж�Ӧ������ж�Ӧ�����ֶ������ֶζ���������Դ����
  Ϊ�ַ��������Բ��ùܣ�����д���ݷ����лὫԴ���򿽱�����λ�� }
procedure __ProcDataCell(AValue: Variant; var ACell: TXLDataCell; AMeter: TMeterDefine;
    DS: TDataSet; AsGroup: Boolean = False);
var
    S: string;
begin
    S := VarToStr(AValue);
    ACell.TempStr := S;
    ACell.Field := nil;

    if S = '' then Exit;
    ACell.Specifier := ProcDataSpecifiers(S, AMeter, AsGroup);
    ACell.Field := DS.FindField(ACell.Specifier);
end;

{ ��ɱ���ͱ�ͷ�����ռλ���滻 }
procedure _ProcTitleHeadRange(Tmpl: TXLGridTemplate; Sht: IXLSWorkSheet; AMeter: TMeterDefine;
    AsGroup: Boolean = False);
var
    iRow, iCol: Integer;
    S, Str    : string;
begin
    for iCol := Tmpl.TitleRect.Left to Tmpl.TitleRect.Right do
        for iRow := Tmpl.TitleRect.Top to Tmpl.TitleRect.Bottom do
                Sht.Cells[iRow, iCol].Value := __ProcHeadCell(Sht.Cells[iRow, iCol].Value,
                AMeter, AsGroup);

    for iCol := Tmpl.HeadRect.Left to Tmpl.HeadRect.Right do
        for iRow := Tmpl.HeadRect.Top to Tmpl.HeadRect.Bottom do
                Sht.Cells[iRow, iCol].Value := __ProcHeadCell(Sht.Cells[iRow, iCol].Value,
                AMeter, AsGroup);
end;

{ ������������������������д���ݡ���������ɵĹ����ǽ���������������Ԫ���ռλ��������Ԫ����ֶ���ϵ
  ��������Ҫ��д����ʱ���ֶ��������뼴�ɡ���д���ݵķ���������һ�� }
procedure _ProcDataRange(Tmpl: TXLGridTemplate; Sht: IXLSWorkSheet; AMeter: TMeterDefine;
    AsGroup: Boolean = False);
var
    // iRow, iCol: Integer;
    i, n          : Integer;
    Offrow, Offcol: Integer;
    newRect       : TRect;
    SrcRange      : IXLSRange;
    DS            : TClientDataSet;
    S             : string;
    GetData       : Boolean;
    procedure CopyNewRange;
    begin
        newRect.Offset(Offcol, Offrow);
        {
            newRect.Top := newRect.Top + Offrow;
            newRect.Left := newRect.Left + Offcol;
            newRect.Right := newRect.Right + Offcol;
            newRect.Bottom := newRect.Bottom + Offrow;
 }
        SrcRange.Copy(Sht.RCRange[newRect.Top, newRect.Left, newRect.Bottom, newRect.Right]);
    end;

    procedure SetDataCells;
    var
        iRow, iCol: Integer;
    begin
        i := 0;
        for iCol := Tmpl.DataRect.Left to Tmpl.DataRect.Right do
            for iRow := Tmpl.DataRect.Top to Tmpl.DataRect.Bottom do
            begin
                DataRangeCells[i].Row := iRow;
                DataRangeCells[i].Col := iCol;
                DataRangeCells[i].TempStr := trim(VarToStr(Sht.Cells[iRow, iCol].Value));
                DataRangeCells[i].Field := nil;
                DataRangeCells[i].GridType := Tmpl.GridType;

                case Tmpl.GridType of
                    xlgDynRow:
                        DataRangeCells[i].OffsetStep := Tmpl.DataRect.Bottom -
                            Tmpl.DataRect.Top + 1;
                    xlgStatic: DataRangeCells[i].OffsetStep := 0;
                    xlgDynCol:
                        DataRangeCells[i].OffsetStep := Tmpl.DataRect.Right -
                            Tmpl.DataRect.Left + 1;
                end;
                __ProcDataCell(Sht.Cells[iRow, iCol].Value, DataRangeCells[i], AMeter, DS, AsGroup);
                inc(i);
            end;
    end;

    procedure ClearDataRange;
    begin
        SrcRange := Sht.RCRange[Tmpl.DataRect.Top, Tmpl.DataRect.Left, Tmpl.DataRect.Bottom,
            Tmpl.DataRect.Right];
        SrcRange.Clear;
    end;

begin
    SetLength(DataRangeCells, 0);
    SetLength(DataRangeCells, (Tmpl.DataRect.Width + 1) * (Tmpl.DataRect.Height + 1));
     // �������ݣ�ֱ���������
    SrcRange := Sht.RCRange[Tmpl.DataRect.Top, Tmpl.DataRect.Left, Tmpl.DataRect.Bottom,
        Tmpl.DataRect.Right];
    Offrow := 0;
    Offcol := 0;
    newRect := Tmpl.DataRect;
    case Tmpl.GridType of
        xlgDynRow: Offrow := Tmpl.DataRect.Bottom - Tmpl.DataRect.Top + 1;
        xlgDynCol: Offcol := Tmpl.DataRect.Right - Tmpl.DataRect.Left + 1;
    end;

    DS := TClientDataSet.Create(nil);

    try
        if AsGroup then
                GetData := IAppServices.ClientDatas.GetGroupAllPDDatas(AMeter.PrjParams.GroupID, DS)
        else GetData := IAppServices.ClientDatas.GetAllPDDatas(AMeter.DesignName, DS);

        if GetData then
        begin
            if DS.RecordCount > 0 then
            begin
                SetDataCells;
                DS.First;
                repeat
                    SrcRange.Copy(Sht.RCRange[newRect.Top, newRect.Left, newRect.Bottom,
                            newRect.Right]);

                    for i := 0 to high(DataRangeCells) do
                    begin
                        DataRangeCells[i].SetCellValue(Sht);
                        DataRangeCells[i].Offset;
                    end;

                    newRect.Offset(Offcol, Offrow);

                    DS.Next;
                until DS.Eof;
                DS.Close;
            end
            else ClearDataRange;
        end
        else ClearDataRange;
    finally
        DS.Free;
    end;

end;

function GenXLGrid(grdTmp: TXLGridTemplate; ADsnName: string; TmpBookName, ResBookName: string)
    : string; overload;
var
    TBook, RBook: IXLSWorkBook;
begin
    Result := '';
    TBook := TXLSWorkbook.Create;
    RBook := TXLSWorkbook.Create;
    { todo:check open error }
    TBook.Open(TmpBookName);
    if FileExists(ResBookName) then RBook.Open(ResBookName)
    else RBook.SaveAs(ResBookName);

    Result := GenXLGrid(grdTmp, ADsnName, TBook, RBook);
    RBook.Save;
end;

function GenXLGrid(grdTmp: TXLGridTemplate; ADsnName: string; TmpBook, ResBook: IXLSWorkBook)
    : string; overload;
var
    Meter         : TMeterDefine;
    bGroup        : Boolean;
    tmpSht, desSht: IXLSWorkSheet;
begin
    Result := '';
    Meter := TMeterDefines(IAppServices.Meters).Meter[ADsnName];
    if Meter = nil then Exit;

    if (Meter.PrjParams.GroupID <> '') and grdTmp.ApplyToGroup then bGroup := True
    else bGroup := False;

    tmpSht := __GetSheet(TmpBook, grdTmp.TemplateSheet);
    if tmpSht = nil then Exit;

    { �����︴�ƹ���������������Ѿ���nExcel���˹������������Excel��ET��ɸ��ƣ�����Ҫ���´���
     �����ļ���һ������취���ṩ��һ�����������Ǹ������д����������ϣ���һ���Ե�Ϊÿֻ�������ƺ�
     �������ٵ��ñ�����������һ���� }
    desSht := __DupWorksheet(tmpSht, ResBook, ADsnName);
    if desSht = nil then Exit;

    _ProcTitleHeadRange(grdTmp, desSht, Meter, bGroup);
    _ProcDataRange(grdTmp, desSht, Meter, bGroup);

    ResBook.Save;
end;

initialization

finalization

SetLength(DataRangeCells, 0);

end.
