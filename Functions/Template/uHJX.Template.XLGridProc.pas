{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Template.XLGridProc
 Author:    ��ΰ
 Date:      13-ʮ��-2018
 Purpose:   Excelģ�崦��Ԫ
            ��֪���⣺�������nExcel����������д���ҹ���������Chart����nExcel
            ���ɵĹ������򲻿���Excel�򿪳���˵�ڴ治����
            ���ԣ�������Ҫ��дʹ��Excel��д���ݵĴ��롣��Ҫ�ڱ���Ԫ��ʹ��Excel
            �������ݣ���Ӧ���ڱ���Ԫ��һ���Եش���������Ҫ�������ݵ�������������
            ��ֻ����
 History:   2018-10-13 ������ʹ��Excel����Ԥ����ģ�幤�����ƣ��Ĺ���
----------------------------------------------------------------------------- }
{ todo:��Excel��ET���Excel�������͹�������� }
unit uHJX.Template.XLGridProc;

interface

uses
  System.Classes, System.Types, System.SysUtils, System.Variants, System.Generics.Collections,
  nExcel,
  uHJX.Intf.AppServices, uHJX.Classes.Meters, uHJX.Classes.Templates, uHJX.Template.XLGrid,
  uHJX.EnvironmentVariables;

{ ��Ҫ�ṩ��ֹ���ڲ��� }
function GenXLGrid(grdTmp: TXLGridTemplate; ADsnName: string; TmpBookName, ResBookName: string)
  : string; overload;
function GenXLGrid(grdTmp: TXLGridTemplate; ADsnName: string; TmpBook, ResBook: IXLSWorkBook;
  CopySheet: Boolean = True): string; overload;
{ ʹ��Excel Application�������ݵķ��������ñ�����֮ǰ��Ӧ�Ѿ���������Ӧ�Ŀ����ݱ� }
function GenXLGrid(grdTmp: TXLGridTemplate; Meter: TMeterDefine; TagBook: OleVariant)
  : string; overload;

implementation

uses
  uHJX.Template.ProcSpecifiers, Data.DB, DataSnap.DBClient, System.Win.ComObj, MidasLib;

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
    procedure SetCellValue(Sht: IXLSWorkSheet); overload;
    procedure SetCellValue(Sht: OleVariant); overload;
  end;

  // ����Excel�ĸ�������
  TXLHelp = class
  public
    /// <summary>ȡ��Excel Application������CreateNew = True���򴴽��µ�ʵ��</summary>
    class function GetExcelApp(CreateNew: Boolean = True): OleVariant;
    /// <summary>ΪMeterList����ÿֻ��������������ģ�壬������ΪBkName��</summary>
    class function CreateEmptyWorkbook(var XLApp: OleVariant; BkName: string;
      MeterList: TStrings): Boolean;
    /// <summary>Excel���_ProcTitleHeadRange����</summary>
    class procedure ProcTitleHeadRange(Tmpl: TXLGridTemplate; Sht: OleVariant; AMeter: TMeterDefine;
      AsGroup: Boolean = False);
    class procedure ProcDataRange(Tmpl: TXLGridTemplate; Sht: OleVariant; AMeter: TMeterDefine;
      AsGroup: Boolean = False);
  end;

var
  DataRangeCells: TArray<TXLDataCell>;

{ -----------------------------------------------------------------------------
  Procedure  : __GetExcelApp
  Description: ����Excel��AutoApplication������û���������е�Excelʵ������
  ����һ��ʵ�������������ˣ������ˡ�
----------------------------------------------------------------------------- }
function __GetExcelApp: OleVariant;
begin
  Result := Unassigned;
  try
    Result := GetActiveOleObject('Excel.Application');
  except
    on EOleSysError do
      try
        Result := CreateOleObject('Excel.Application');
      except
      end;
  end;
end;

function __GetSheet(ABook: IXLSWorkBook; SheetName: string): IXLSWorkSheet;
var
  i: Integer;
begin
  Result := nil;
  i := ABook.WorkSheets.Index[SheetName];
  if i > 0 then
      Result := ABook.WorkSheets.Entries[i];
end;

function __HasSheet(ABook: IXLSWorkBook; AName: string): Boolean;
begin
  Result := False;
  if ABook.WorkSheets.Index[AName] > 0 then
      Result := True;
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
    else
        Break;
  until False;
end;

{ ��nExcel�Լ����ƹ�������ʽ�ǿ���ԭ��UsedRange }
function __DupWorksheet(SrcSheet: IXLSWorkSheet; DesBook: IXLSWorkBook; NewSheetName: string)
  : IXLSWorkSheet;
begin
  Result := nil;
  if (SrcSheet = nil) or (DesBook = nil) then
      Exit;

  Result := DesBook.WorkSheets.Add;

    // ����Ƿ�������������������ڣ����Զ��������
  Result.Name := __GetAltName(DesBook, NewSheetName);

    // ��ԭ����usedrange���±�
  with SrcSheet.UsedRange do
  begin
    Copy(Result.RCRange[FirstRow, FirstCol, LastRow + 1, LastCol + 1], xlPasteAll);
    Result.RCRange[FirstRow, FirstCol, LastRow + 1, LastCol + 1].Formula := Formula;
  end;

    // nExcel�޷����ö���������˲����Ľ������û�ж������Ĺ�����
end;

{ ���������Ҫ���ǵ����л����ƫ�Ƶ����� }
procedure TXLDataCell.Offset;
begin
  case GridType of
    xlgDynRow:
      inc(Row, OffsetStep);
    xlgStatic:
      ;
    xlgDynCol:
      inc(Col, OffsetStep);
  end;
end;

{ ���ֶ���ȡ�����ݣ����뵥Ԫ���У���Ԫ��ĸ�ʽ������ģ���һ�� }
function TXLDataCell.GetValue: Variant;
begin
    // Result := Null;
  if Field = nil then
      Result := Null
  else
      Result := Field.Value;
end;

procedure TXLDataCell.SetCellValue(Sht: IXLSWorkSheet);
begin
  Sht.Cells[Self.Row, Self.Col].Value := GetValue;
end;

procedure TXLDataCell.SetCellValue(Sht: OleVariant);
var
  Data: Variant;
begin
  Data := GetValue;
  case VarType(Data) of
    varString: Sht.Cells[Self.Row, Self.Col].Value := VarToStr(Data);
  else
    Sht.Cells[Self.Row, Self.Col].Value := Data;
  end;
end;

{ ================================================================================================ }
{ ����Head��title��Ԫ��ռλ�����ҵ���Ӧ��Meter���������ظ�ֵ }
function __ProcHeadCell(AValue: Variant; AMeter: TMeterDefine; AsGroup: Boolean = False): Variant;
var
  S: string;
// i: Integer;
begin
  Result := AValue;
  S := VarToStr(AValue);
  if S = '' then
      Exit;
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

  if S = '' then
      Exit;
  ACell.Specifier := ProcDataSpecifiers(S, AMeter, AsGroup);
  ACell.Field := DS.FindField(ACell.Specifier);
end;

{ ��ɱ���ͱ�ͷ�����ռλ���滻 }
procedure _ProcTitleHeadRange(Tmpl: TXLGridTemplate; Sht: IXLSWorkSheet; AMeter: TMeterDefine;
  AsGroup: Boolean = False);
var
  iRow, iCol: Integer;
// S, Str    : string;
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
  i             : Integer;
  OffRow, OffCol: Integer;
  newRect       : TRect;
  SrcRange      : IXLSRange;
  DS            : TClientDataSet;
  GetData       : Boolean;
  procedure CopyNewRange;
  begin
    newRect.Offset(OffCol, OffRow);
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
          xlgStatic:
            DataRangeCells[i].OffsetStep := 0;
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
  OffRow := 0;
  OffCol := 0;
  newRect := Tmpl.DataRect;
  case Tmpl.GridType of
    xlgDynRow:
      OffRow := Tmpl.DataRect.Bottom - Tmpl.DataRect.Top + 1;
    xlgDynCol:
      OffCol := Tmpl.DataRect.Right - Tmpl.DataRect.Left + 1;
  end;

  DS := TClientDataSet.Create(nil);

  try
    if AsGroup then
        GetData := IAppServices.ClientDatas.GetGroupAllPDDatas(AMeter.PrjParams.GroupID, DS)
    else
        GetData := IAppServices.ClientDatas.GetAllPDDatas(AMeter.DesignName, DS);

    if GetData then
    begin
      if DS.RecordCount > 0 then
      begin
        // ����ģ����������Ԫ�����ݣ���ռλ���滻Ϊ�����ֶλ���������
        SetDataCells;
        // ׼�����ݼ������Ͼ�Ҫ��д���ݡ���
        DS.First;
        repeat
          // ����ģ�����������ʽ����ʽ����λ��
          SrcRange.Copy(Sht.RCRange[newRect.Top, newRect.Left, newRect.Bottom,
            newRect.Right]);
          // ������
          for i := 0 to high(DataRangeCells) do
          begin
            DataRangeCells[i].SetCellValue(Sht);
            DataRangeCells[i].Offset;
          end;
          // ������λ�ã���һѭ���и�ʽ����ʽ������������
          newRect.Offset(OffCol, OffRow);

          DS.Next;
        until DS.Eof;
        DS.Close;
      end
      else
          ClearDataRange;
    end
    else
        ClearDataRange;
  finally
    DS.Free;
  end;

end;

class function TXLHelp.GetExcelApp(CreateNew: Boolean = True): OleVariant;
begin
  Result := Unassigned;
  try
    if CreateNew then
        Result := CreateOleObject('Excel.Application')
    else
        Result := GetActiveOleObject('Excel.Application');
  except
    on EOleSysError do
      try
        // Result := CreateOleObject('Excel.Application');
      except
      end;
  end;
end;

class function TXLHelp.CreateEmptyWorkbook(var XLApp: OleVariant; BkName: string;
  MeterList: TStrings): Boolean;
var
  ShtLsts: String;
  i, j   : Integer;
  Meter  : TMeterDefine;
  grpMts : TStrings;
  grpItem: TMeterGroupItem;
  tpl    : TXLGridTemplate;
  Tpls   : TTemplates;
  tplName: string;
  tagName: string;
  // -----------------
  SrcBk, SrcSht: OleVariant;
  TagBk, TagSht: OleVariant;
begin
  Result := False;
  if ENV_XLTemplBook = '' then Exit; // ���û��ģ�幤�������øɻ���

  if VarIsNull(XLApp) or VarIsEmpty(XLApp) then
  begin
    XLApp := Self.GetExcelApp(False);
    if VarIsNull(XLApp) or VarIsEmpty(XLApp) then Exit;
  end;

  SrcBk := XLApp.WorkBooks.Open(ENV_XLTemplBook);
  if VarIsNull(SrcBk) then Exit;
  TagBk := XLApp.WorkBooks.Add;

  ShtLsts := '';
  grpMts := TStringList.Create;

  try
    Tpls := IAppServices.Templates as TTemplates;
    for i := 0 to MeterList.Count - 1 do
    begin
      if grpMts.IndexOf(MeterList.Strings[i]) <> -1 then
          Continue;
      Meter := ExcelMeters.Meter[MeterList.Strings[i]];
      if Meter = nil then Continue;
      if (Meter.DataBook = '') or (Meter.datasheet = '') then
          Continue;

      if Meter.PrjParams.GroupID <> '' then
      begin
        tagName := Meter.PrjParams.GroupID;
        grpItem := MeterGroup.ItemByName[Meter.PrjParams.GroupID];
        for j := 0 to grpItem.Count - 1 do grpMts.Add(grpItem.Items[j]);
      end
      else
          tagName := Meter.DesignName;

      tpl := Tpls.ItemByName[Meter.DataSheetStru.XLTemplate] as TXLGridTemplate;
      tplName := tpl.TemplateSheet;
      SrcSht := SrcBk.WorkSheets.Item[tplName];
      { todo:�ж�һ�� SrcSht�Ƿ�Ϊ�� }
      if VarIsNull(SrcSht) then Continue;
      SrcSht.Copy(Null, TagBk.WorkSheets.Item[TagBk.WorkSheets.Count]);
      TagSht := TagBk.WorkSheets.Item[TagBk.WorkSheets.Count];
      { todo:�жϱ����Ƿ����ظ������ظ��������� }
      TagSht.Name := tagName;

      // ShtLsts := ShtLsts + tplName + ':' + tagName + #13#10;
    end;
    // ִ�е��������Ӧ���Ѿ�������
    try
      TagBk.SaveAs(BkName, 56);
      Result := True;
    finally
      SrcBk.Close;
      TagBk.Close;
    end;
  finally
    grpMts.Free;
  end;
end;

class procedure TXLHelp.ProcTitleHeadRange(Tmpl: TXLGridTemplate; Sht: OleVariant;
  AMeter: TMeterDefine; AsGroup: Boolean = False);
var
  iRow, iCol: Integer;
begin
  for iCol := Tmpl.TitleRect.Left to Tmpl.TitleRect.Right do
    for iRow := Tmpl.TitleRect.Top to Tmpl.TitleRect.Bottom do
        Sht.Cells[iRow, iCol].Value := VarToStr(__ProcHeadCell(Sht.Cells[iRow, iCol].Value, AMeter,
        AsGroup));

  for iCol := Tmpl.HeadRect.Left to Tmpl.HeadRect.Right do
    for iRow := Tmpl.HeadRect.Top to Tmpl.HeadRect.Bottom do
        Sht.Cells[iRow, iCol].Value := VarToStr(__ProcHeadCell(Sht.Cells[iRow, iCol].Value, AMeter,
        AsGroup));
end;

class procedure TXLHelp.ProcDataRange(Tmpl: TXLGridTemplate; Sht: OleVariant; AMeter: TMeterDefine;
  AsGroup: Boolean = False);
var
  i             : Integer;
  OffRow, OffCol: Integer;
  newRect       : TRect;
  SrcRange      : OleVariant;
  DS            : TClientDataSet;
  GetData       : Boolean;
  procedure _CopyNewRange;
  begin
    newRect.Offset(OffCol, OffRow);
    SrcRange.Copy(Sht.Range[Sht.Cells[newRect.Top, newRect.Left], Sht.Cells[newRect.Bottom,
      newRect.Right]]);
  end;
  procedure _SetDataCells;
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
          xlgDynRow: DataRangeCells[i].OffsetStep := Tmpl.DataRect.Bottom - Tmpl.DataRect.Top + 1;
          xlgStatic: DataRangeCells[i].OffsetStep := 0;
          xlgDynCol: DataRangeCells[i].OffsetStep := Tmpl.DataRect.Right - Tmpl.DataRect.Left + 1;
        end;
        __ProcDataCell(Sht.Cells[iRow, iCol].Value, DataRangeCells[i], AMeter, DS, AsGroup);
        inc(i);
      end;
  end;
  procedure _ClearDataRange;
  begin
    SrcRange := Sht.Range[Sht.Cells[Tmpl.DataRect.Top, Tmpl.DataRect.Left],
      Sht.Cells[Tmpl.DataRect.Bottom, Tmpl.DataRect.Right]];
    SrcRange.Clear;
  end;

begin
  SetLength(DataRangeCells, 0);
  SetLength(DataRangeCells, (Tmpl.DataRect.Width + 1) * (Tmpl.DataRect.Height + 1));
  with Tmpl.DataRect do
      SrcRange := Sht.Range[Sht.Cells[Top, Left], Sht.Cells[Bottom, Right]];
  OffRow := 0;
  OffCol := 0;
  newRect := Tmpl.DataRect;
  case Tmpl.GridType of
    xlgDynRow: OffRow := Tmpl.DataRect.Bottom - Tmpl.DataRect.Top + 1;
    xlgStatic:;
    xlgDynCol: OffCol := Tmpl.DataRect.Right - Tmpl.DataRect.Left + 1;
  end;

  DS := TClientDataSet.Create(nil);
  try
    if AsGroup then
        GetData := IAppServices.ClientDatas.GetGroupAllPDDatas(AMeter.PrjParams.GroupID, DS)
    else
        GetData := IAppServices.ClientDatas.GetAllPDDatas(AMeter.DesignName, DS);
    if GetData then
    begin
      if DS.RecordCount > 0 then
      begin
        _SetDataCells;
        DS.First;
        repeat
          SrcRange.Copy(Sht.Range[Sht.Cells[newRect.Top, newRect.Left],
            Sht.Cells[newRect.Bottom, newRect.Right]]);
          for i := 0 to High(DataRangeCells) do
          begin
            DataRangeCells[i].SetCellValue(Sht);
            DataRangeCells[i].Offset;
          end;
          newRect.Offset(OffCol, OffRow);
          DS.Next;
        until DS.Eof;
      end;
    end
    else
        _ClearDataRange;
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
  if FileExists(ResBookName) then
      RBook.Open(ResBookName)
  else
      RBook.SaveAs(ResBookName);

  Result := GenXLGrid(grdTmp, ADsnName, TBook, RBook);
  RBook.Save;
end;

function GenXLGrid(grdTmp: TXLGridTemplate; ADsnName: string; TmpBook, ResBook: IXLSWorkBook;
  CopySheet: Boolean = True): string; overload;
var
  Meter         : TMeterDefine;
  bGroup        : Boolean;
  tmpSht, desSht: IXLSWorkSheet;
begin
  Result := '';
  Meter := TMeterDefines(IAppServices.Meters).Meter[ADsnName];
  if Meter = nil then
      Exit;

  if (Meter.PrjParams.GroupID <> '') and grdTmp.ApplyGroup then
      bGroup := True
  else
      bGroup := False;

  tmpSht := __GetSheet(TmpBook, grdTmp.TemplateSheet);
  if tmpSht = nil then
      Exit;

    { �����︴�ƹ���������������Ѿ���nExcel���˹������������Excel��ET��ɸ��ƣ�����Ҫ���´���
     �����ļ���һ������취���ṩ��һ�����������Ǹ������д����������ϣ���һ���Ե�Ϊÿֻ�������ƺ�
     �������ٵ��ñ�����������һ���� }
  if CopySheet then
  begin
    if Meter.PrjParams.GroupID <> '' then
        desSht := __DupWorksheet(tmpSht, ResBook, Meter.PrjParams.GroupID)
    else
        desSht := __DupWorksheet(tmpSht, ResBook, ADsnName);
  end
  else // ���������������˵���������Ѿ��ڵ���֮ǰ�������ˣ�����ֻ��Ҫ���ü���
  begin
    if Meter.PrjParams.GroupID <> '' then
        desSht := __GetSheet(ResBook, Meter.PrjParams.GroupID)
    else
        desSht := __GetSheet(ResBook, ADsnName);
  end;

  if desSht = nil then
      Exit;

  _ProcTitleHeadRange(grdTmp, desSht, Meter, bGroup);
  _ProcDataRange(grdTmp, desSht, Meter, bGroup);

  ResBook.Save;
end;

function GenXLGrid(grdTmp: TXLGridTemplate; Meter: TMeterDefine; TagBook: OleVariant): string;
var
  bGroup  : Boolean;
  TagSheet: OleVariant;
begin
  Result := '';
  if (Meter.PrjParams.GroupID <> '') and grdTmp.ApplyGroup then bGroup := True
  else bGroup := False;

  TagSheet := Unassigned;
  if bGroup then
      TagSheet := TagBook.WorkSheets.Item[Meter.PrjParams.GroupID]
  else
      TagSheet := TagBook.WorkSheets.Item[Meter.DesignName];

  if VarIsNull(TagSheet) or VarIsEmpty(TagSheet) then Exit;

  TXLHelp.ProcTitleHeadRange(grdTmp, TagSheet, Meter, bGroup);
  TXLHelp.ProcDataRange(grdTmp, TagSheet, Meter, bGroup);
  TagBook.Save;
end;

initialization

finalization

SetLength(DataRangeCells, 0);

end.
