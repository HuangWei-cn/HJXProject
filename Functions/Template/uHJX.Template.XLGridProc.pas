{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Template.XLGridProc
 Author:    黄伟
 Date:      13-十月-2018
 Purpose:   Excel模板处理单元
            已知问题：如果采用nExcel处理数据填写，且工作表中有Chart，则nExcel
            生成的工作簿打不开，Excel打开出错，说内存不够。
            所以，可能需要编写使用Excel填写数据的代码。若要在本单元中使用Excel
            处理数据，则应当在本单元中一次性地处理所有需要导出数据的仪器，而不是
            逐只处理。
 History:   2018-10-13 增加了使用Excel进行预处理（模板工作表复制）的功能
----------------------------------------------------------------------------- }
{ todo:用Excel或ET完成Excel工作簿和工作表操作 }
unit uHJX.Template.XLGridProc;

interface

uses
  System.Classes, System.Types, System.SysUtils, System.Variants, System.Generics.Collections,
  nExcel,
  uHJX.Intf.AppServices, uHJX.Classes.Meters, uHJX.Classes.Templates, uHJX.Template.XLGrid,
  uHJX.EnvironmentVariables;

{ 需要提供起止日期参数 }
function GenXLGrid(grdTmp: TXLGridTemplate; ADsnName: string; TmpBookName, ResBookName: string)
  : string; overload;
function GenXLGrid(grdTmp: TXLGridTemplate; ADsnName: string; TmpBook, ResBook: IXLSWorkBook;
  CopySheet: Boolean = True): string; overload;
{ 使用Excel Application生成数据的方法，调用本方法之前，应已经创建了相应的空数据表 }
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
    // Offset偏移数据单元格，如果是单行或单列，则偏移1行或1列，若是n行则偏移n行，这样可以实现
    // 多行或多列的动态。
    procedure Offset;
    function GetValue: Variant;
    procedure SetCellValue(Sht: IXLSWorkSheet); overload;
    procedure SetCellValue(Sht: OleVariant); overload;
  end;

  // 操作Excel的辅助工具
  TXLHelp = class
  public
    /// <summary>取得Excel Application对象，若CreateNew = True，则创建新的实例</summary>
    class function GetExcelApp(CreateNew: Boolean = True): OleVariant;
    /// <summary>为MeterList表中每只仪器创建空数据模板，并保存为BkName。</summary>
    class function CreateEmptyWorkbook(var XLApp: OleVariant; BkName: string;
      MeterList: TStrings): Boolean;
    /// <summary>Excel版的_ProcTitleHeadRange函数</summary>
    class procedure ProcTitleHeadRange(Tmpl: TXLGridTemplate; Sht: OleVariant; AMeter: TMeterDefine;
      AsGroup: Boolean = False);
    class procedure ProcDataRange(Tmpl: TXLGridTemplate; Sht: OleVariant; AMeter: TMeterDefine;
      AsGroup: Boolean = False);
  end;

var
  DataRangeCells: TArray<TXLDataCell>;

{ -----------------------------------------------------------------------------
  Procedure  : __GetExcelApp
  Description: 返回Excel的AutoApplication对象，若没有正在运行的Excel实例，则
  启动一个实例，若启动不了，就算了。
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
    else
        Break;
  until False;
end;

{ 用nExcel自己复制工作表，方式是拷贝原表UsedRange }
function __DupWorksheet(SrcSheet: IXLSWorkSheet; DesBook: IXLSWorkBook; NewSheetName: string)
  : IXLSWorkSheet;
begin
  Result := nil;
  if (SrcSheet = nil) or (DesBook = nil) then
      Exit;

  Result := DesBook.WorkSheets.Add;

    // 检查是否存在重名工作表，若存在，则自动增加序号
  Result.Name := __GetAltName(DesBook, NewSheetName);

    // 从原表拷贝usedrange到新表
  with SrcSheet.UsedRange do
  begin
    Copy(Result.RCRange[FirstRow, FirstCol, LastRow + 1, LastCol + 1], xlPasteAll);
    Result.RCRange[FirstRow, FirstCol, LastRow + 1, LastCol + 1].Formula := Formula;
  end;

    // nExcel无法设置冻结区，因此产生的结果将是没有冻结区的工作表。
end;

{ 这个方法需要考虑到多行或多列偏移的问题 }
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

{ 从字段中取回数据，填入单元格中，单元格的格式保持与模板的一致 }
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
{ 解析Head和title单元格占位符，找到对应的Meter参数，返回该值 }
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

  if S = '' then
      Exit;
  ACell.Specifier := ProcDataSpecifiers(S, AMeter, AsGroup);
  ACell.Field := DS.FindField(ACell.Specifier);
end;

{ 完成标题和表头区域的占位符替换 }
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

{ 处理数据区，本方法并不填写数据。本方法完成的工作是解析数据区各个单元格的占位符，将单元格和字段联系
  起来，需要填写数据时将字段数据填入即可。填写数据的方法是另外一个 }
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
     // 填入数据，直到完成任务
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
        // 解析模板数据区单元格内容，将占位符替换为数据字段或仪器属性
        SetDataCells;
        // 准备数据集，马上就要填写数据……
        DS.First;
        repeat
          // 复制模板数据区域格式及公式到新位置
          SrcRange.Copy(Sht.RCRange[newRect.Top, newRect.Left, newRect.Bottom,
            newRect.Right]);
          // 填数据
          for i := 0 to high(DataRangeCells) do
          begin
            DataRangeCells[i].SetCellValue(Sht);
            DataRangeCells[i].Offset;
          end;
          // 设置新位置，下一循环中格式及公式将拷贝到这里
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
  if ENV_XLTemplBook = '' then Exit; // 如果没有模板工作簿则不用干活了

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
      { todo:判断一下 SrcSht是否为空 }
      if VarIsNull(SrcSht) then Continue;
      SrcSht.Copy(Null, TagBk.WorkSheets.Item[TagBk.WorkSheets.Count]);
      TagSht := TagBk.WorkSheets.Item[TagBk.WorkSheets.Count];
      { todo:判断表名是否有重复，若重复则重命名 }
      TagSht.Name := tagName;

      // ShtLsts := ShtLsts + tplName + ':' + tagName + #13#10;
    end;
    // 执行到这里，拷贝应该已经结束了
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

    { 在这里复制工作表的问题在于已经用nExcel打开了工作簿，如果用Excel或ET完成复制，则需要重新打开着
     两个文件。一个解决办法是提供另一个方法，在那个方法中处理仪器集合，它一次性地为每只仪器复制好
     工作表，再调用本方法进行逐一处理 }
  if CopySheet then
  begin
    if Meter.PrjParams.GroupID <> '' then
        desSht := __DupWorksheet(tmpSht, ResBook, Meter.PrjParams.GroupID)
    else
        desSht := __DupWorksheet(tmpSht, ResBook, ADsnName);
  end
  else // 如果不拷贝工作表，说明工作表已经在调用之前拷贝好了，这里只需要引用即可
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
