{ 本单元的XLGrid模板处理方法
    采用类似WebGridProc的方法，提供一个函数完成这件事。
}
unit uHJX.Template.XLGridProc;

interface

uses
    System.Classes, System.Types, System.SysUtils, System.Variants, System.Generics.Collections,
    nExcel,
    uHJX.Intf.AppServices, uHJX.Classes.Meters, uHJX.Template.XLGrid;

{ 需要提供起止日期参数 }
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
        // Offset偏移数据单元格，如果是单行或单列，则偏移1行或1列，若是n行则偏移n行，这样可以实现
        // 多行或多列的动态。
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

// 返回可用的名称，如果AName存在，则自动添加序号，再查，直到没有为止
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

{ 用nExcel自己复制工作表，方式是拷贝原表UsedRange }
function __DupWorksheet(SrcSheet: IXLSWorkSheet; DesBook: IXLSWorkBook; NewSheetName: string)
    : IXLSWorkSheet;
begin
    Result := nil;
    if (SrcSheet = nil) or (DesBook = nil) then Exit;

    Result := DesBook.WorkSheets.Add;

    // 检查是否存在重名工作表，若存在，则自动增加序号
    Result.Name := __GetAltName(DesBook, NewSheetName);

    // 从原表拷贝usedrange到新表
    with SrcSheet.UsedRange do
    begin
        Copy(Result.RCRange[FirstRow, FirstCol, LastRow + 1, LastCol + 1], xlPasteAll);
        Result.RCRange[FirstRow, FirstCol, LastRow + 1, LastCol + 1].Formula := Formula;
    end;

    //nExcel无法设置冻结区，因此产生的结果将是没有冻结区的工作表。
end;

{ Use Excel or ET duplacation a worksheet to an other workbook. }
function __CopyWorkSheet(SrcSheet: IXLSWorkSheet; DesBook: IXLSWorkBook; NewSheetName: string)
    : IXLSWorkSheet;
var
    Obj: OleVariant;
begin
    Result := nil;
end;

{ 这个方法需要考虑到多行或多列偏移的问题 }
procedure TXLDataCell.Offset;
begin
    case GridType of
        xlgDynRow: inc(Row, OffsetStep);
        xlgStatic:;
        xlgDynCol: inc(Col, OffsetStep);
    end;
end;

{ 从字段中取回数据，填入单元格中，单元格的格式保持与模板的一致 }
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
{ 解析Head和title单元格占位符，找到对应的Meter参数，返回该值 }
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

{ 解析数据区单元格占位符，填写到DataCell结构中对应的项：若有对应数据字段设置字段对象，若无则源内容
  为字符串，可以不用管，在填写数据方法中会将源区域拷贝到新位置 }
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

{ 完成标题和表头区域的占位符替换 }
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

{ 处理数据区，本方法并不填写数据。本方法完成的工作是解析数据区各个单元格的占位符，将单元格和字段联系
  起来，需要填写数据时将字段数据填入即可。填写数据的方法是另外一个 }
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
     // 填入数据，直到完成任务
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

    { 在这里复制工作表的问题在于已经用nExcel打开了工作簿，如果用Excel或ET完成复制，则需要重新打开着
     两个文件。一个解决办法是提供另一个方法，在那个方法中处理仪器集合，它一次性地为每只仪器复制好
     工作表，再调用本方法进行逐一处理 }
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
