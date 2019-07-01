{ -----------------------------------------------------------------------------
  Unit Name: uHJX.Excel.DataQuery
  Author:    黄伟
  Date:      06-四月-2017
  Purpose:   数据查询单元-针对Excel数据源
  History:  2018-05-29~29
            增加处理仪器组的数据提取功能，目前能满足锚杆组。要能适应任意仪器数据
            提取，需要进一步完善

            2018-05-31
            1.增加“备注”字段的提取；
            2.为平面位移测点增加了观测数据表表头设置(DBGridEh表头)；
            3.改进查找单条记录的方法，用_LocateDTRow方法快速查找指定日期所在的行；
            4.给布置图添加了显示指定日期观测数据的按钮和方法。

            2018-06-14
            增加了查询仪器数据增量及月增量的功能
            2018-09-18
            特征值查询：完成了时间段内特征值查询功能，特征值中增加了“增量”和“振幅”
            两项。
  ----------------------------------------------------------------------------- }

unit uHJX.Excel.DataQuery;

{ todo:GetLastPDDatas方法等没有返回备注字段的内容，有时备注内容十分重要 }
{ todo:应考虑在SessionBegin时设置WorkBook Pool，凡打开过的保留下来，下一次使用时直接调用，不再创建 }
{ todo:注册打开数据库方法、数据连接及注销事件 }
{ todo:注册仪器列表加载更新事件 }
{ todo:注册仪器参数更新加载事件 }
interface

uses
  System.Classes, System.Types, System.SysUtils, System.Variants, System.StrUtils, Data.DB,
  Datasnap.DBClient, System.DateUtils, {MidasLib,}
  uHJX.Intf.Datas, uHJX.Excel.IO, uHJX.Data.Types, uHJX.Intf.AppServices;

type
    { 黄金峡数据查询对象： }
  ThjxDataQuery = class(TInterfacedObject, IClientFuncs)
  private
    FUseSession: Boolean;
  public
    destructor Destroy; override;
        { 启动会话 }
        { todo:实现启动会话后创建打开的工作簿池，当需要打开工作簿时先检查是否已经打开，若池中
          没有，才创建并打开新工作簿。工作簿池对于静态表类型较为有用，可以大幅度缩减提取数据的时间。 }
    procedure SessionBegin;
    procedure SessionEnd;
        { 取回指定监测仪器的最后一次监测数据 }
    function GetLastPDDatas(ADsnName: string; var Values: TDoubleDynArray): Boolean; overload;
    function GetLastPDDatas(ADsnName: string; var Values: TVariantDynArray): Boolean; overload;
        { 取回指定时段内监测仪器的最后一次数据 }
    function GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
      var Values: TDoubleDynArray): Boolean; overload;
    function GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
      var Values: TVariantDynArray): Boolean; overload;
        { 取回最接近指定日期的观测数据 }
    function GetNearestPDDatas(ADsnName: String; DT: TDateTime; var Values: TDoubleDynArray;
      DTDelta: Integer = 0): Boolean; overload;
    function GetNearestPDDatas(ADsnName: String; DT: TDateTime; var Values: TVariantDynArray;
      DTDelta: Integer = 0): Boolean; overload;
        { 取回指定时段内监测仪器所有观测数据 }
    function GetPDDatasInPeriod(ADsnName: string; DT1, DT2: TDateTime; DS: TDataSet): Boolean;
        { 取回全部观测数据 }
    function GetAllPDDatas(ADsnName: string; DS: TDataSet): Boolean;
        { 取回仪器组全部观测数据，注意仪器组数据集中字段名格式: 设计编号.物理量名 }
    function GetGroupAllPDDatas(AGrpName: string; DS: TDataSet): Boolean;
        { 取回仪器在指定时段内的观测数据 }
    function GetGroupPDDatasInPeriod(AGrpName: string; DT1, DT2: TDateTime;
      DS: TDataSet): Boolean;
        { 取回当前特征值，这两个已弃用 }
    function GetEVData(ADsnName: String; EVData: PEVDataStru): Boolean; overload;
    function GetEVData(ADsnName: string; var EVDatas: TDoubleDynArray): Boolean; overload;
        { 取回仪器所有物理量的特征值 }
    function GetEVDatas(ADsnName: String; var EVDatas: PEVDataArray): Boolean;
        { 取回指定时段内的特征值 }
    function GetEVDataInPeriod(ADsnName: string; DT1, DT2: TDateTime;
      var EVDatas: PEVDataArray): Boolean;
        { 取回指定时段内的观测点次 }
    function GetDataCount(ADsnName: string; DT1, DT2: TDateTime): Integer;
        { 设置DataSet字段别名，对于Excel数据驱动，这个对应表存储在Excel参数文件中，初始化参数时
          已加载到uHJX.Excel.Meters单元的DSNames集合中 }
    procedure SetFieldDisplayName(DS: TDataSet);
        { 返回仪器类型名称 }
    function GetMeterTypeName(ADsnName: string): string;
        { 返回仪器数据增量(不包括测斜孔数据)。返回两测次间增量及月增量。返回值Values的描述参见接口
          函数的注释 }
    function GetDataIncrement(ADsnName: string; DT: TDateTime;
      var Values: TVariantDynArray): Boolean;
  end;

procedure RegistClientDatas;

implementation

uses
    {uHJX.Excel.Meters} uHJX.Classes.Meters, nExcel;

type
  TDateLocateOption = (dloEqual, dloBefore, dloAfter, dloClosest); // 日期查询定位选项：等于，之前，之后，最接近

var
  SSWorkBook: IXLSWorkBook; // 会话期间使用的Workbook

{ -----------------------------------------------------------------------------
  Procedure  : _GetFloatOrNull
  Description: 返回浮点数，或NULL
----------------------------------------------------------------------------- }
function _GetFloatOrNull(ASht: IXLSWorksheet; ARow, ACol: Integer): Variant;
begin
  Result := Null;
  if VarIsFloat(ASht.Cells[ARow, ACol].Value) then
      Result := ASht.Cells[ARow, ACol].Value;
end;

{ 返回仪器的工作簿及工作表对象 }
function _GetMeterSheet(ADsnName: string; var AWBK: IXLSWorkBook; var ASht: IXLSWorksheet;
  UseSession: Boolean = True): Boolean;
var
  Meter: TMeterDefine;
begin
  Result := False;
    // AWBK := nil;
    // ASHT := nil;
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;
  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;
    { todo:这里增加判断，如果AWBK就是仪器的工作簿，则无需再经过打开的步骤了 }
  if UseSession then
      AWBK := SSWorkBook
  else if not Assigned(AWBK) then
      AWBK := TmyWorkbook.Create;

  if TmyWorkbook(AWBK).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(AWBK, Meter.DataBook) then
        Exit;

  ASht := ExcelIO.GetSheet(AWBK, Meter.DataSheet);
  if ASht = nil then
      Exit;

    { 走到这里，可以返回True了 }
  Result := True;
end;

{ 快速定位指定日期所在的行，或最接近的日期所在行，返回值为行数。
    参数：
    StartRow:       仪器数据起始行，也是查找的起始行；
    LacateOption:   0:必须等于该日期；1:该日期的前一个；2:最接近该日期，无论前后。
}
function _LocateDTRow(Sheet: IXLSWorksheet; DT: TDateTime; DTStartRow: Integer;
  LocateOption: TDateLocateOption = dloEqual): Integer;
var
  DT1, DT2    : TDateTime;
  d1, d2      : Integer;
  iRow        : Integer;
  iStart, iEnd: Integer;
// Delta       : Integer;
  S: string;
    { 递归查询 }
  function _Locate(StartRow, EndRow: Integer): Integer;
  begin
    IAppServices.ProcessMessages;
    Result := -1;
        // 考虑StartRow=EndRow, EndRow-StartRow=1的情况
        // 起止两行相邻，若仍没找到则挑选最接近的
    if EndRow - StartRow <= 1 then
    begin
      DT1 := ExcelIO.GetDateTimeValue(Sheet, StartRow, 1);
      DT2 := ExcelIO.GetDateTimeValue(Sheet, EndRow, 1);
            // 根据Option选择操作
            // 必须精确相等，则没有找到
      case LocateOption of
        dloEqual:
          Exit;
        dloBefore:
          begin
            Result := StartRow;
            Exit;
          end;
        dloAfter:
          begin
            Result := EndRow;
            Exit;
          end;
        dloClosest:
          begin
                        // 最接近指定日期的数据
                        // 求差值
            d1 := DaysBetween(DT1, DT);
            d2 := DaysBetween(DT, DT2);
            if d1 < d2 then
                Result := StartRow
            else
                Result := EndRow;
          end;
      end;
      Exit;
    end;

        // 在StartRow和EndRow选中间行
    iRow := (StartRow + EndRow) div 2;
    DT1 := ExcelIO.GetDateTimeValue(Sheet, iRow, 1);
    if DT1 = DT then
    begin
      Result := iRow;
      Exit;
    end;

        // 比较DT1和DT，重新设置StartRow和EndRow,再找
    if DT1 < DT then
        StartRow := iRow
    else
        EndRow := iRow;
        // 递归，再找
    Result := _Locate(StartRow, EndRow);
  end;

begin
  Result := -1;
  if Sheet = nil then
      Exit;
  iStart := DTStartRow;
  iEnd := Sheet.UsedRange.LastRow + 2;

    // 判断5种特殊情况:没数据，起始行为结果，截止行为结果, 早于起始行，晚于截止行
    // 1. 没数据
  if iEnd < iStart then
      Exit;

    // 2. 起始行等于给日期，若起始行日期为空则退出，即同样没数据
  S := trim(ExcelIO.GetStrValue(Sheet, iStart, 1));
  if S = '' then
      Exit;

  DT1 := StrToDateTime(S);
  if DT1 = DT then
  begin
    Result := iStart;
    Exit;
  end;

    // 3. 早于起始行，若允许之后或允许接近返回起始行，否则退出
  if DT1 > DT then
    if LocateOption in [dloAfter, dloClosest] then
    begin
      Result := iStart;
      Exit;
    end
    else
        Exit;

    // 4. 截止行等于给定日期
    // 先跳过空行，找到最后一行数据，取得最后日期
  for iRow := iEnd downto iStart do
  begin
    IAppServices.ProcessMessages;
    S := trim(ExcelIO.GetStrValue(Sheet, iRow, 1));
    if S = '' then
        Continue
    else
        Break;
  end;
  DT2 := StrToDateTime(S);
  if DT2 = DT then
  begin
    Result := iRow;
    Exit;
  end;

    // 5. 晚于截止行
  if DT > DT2 then
    if LocateOption in [dloBefore, dloClosest] then // 允许前后接近
    begin
      Result := iRow;
      Exit;
    end
    else
        Exit;
    // 以上5种情况不存在，则老老实实地查找吧：
  if iEnd <> iRow then
      iEnd := iRow;
  Result := _Locate(iStart, iEnd);
end;

// 根据物理量定义创建字段表
procedure _CreateFieldsFromPDDefines(DS: TDataSet; APDDefines: TDataDefines);
var
  i : Integer;
  DF: TFieldDef;
begin
  TClientDataSet(DS).FieldDefs.Clear;
  TClientDataSet(DS).IndexDefs.Clear;

    // 观测日期字段
  DF := DS.FieldDefs.AddFieldDef;
  DF.Name := 'DTScale';
  DF.DataType := ftDateTime;
  DF.DisplayName := '观测日期';
    // 物理量字段
  for i := 0 to APDDefines.Count - 1 do
  begin
    DF := DS.FieldDefs.AddFieldDef;
    DF.Name := 'PD' + IntToStr(i + 1);
    DF.DisplayName := APDDefines.Items[i].Name;
    DF.DataType := ftFloat;
  end;
    // 备注字段
  DF := DS.FieldDefs.AddFieldDef;
  DF.Name := 'Annotation';
  DF.DisplayName := '备注';
  DF.DataType := ftWideString;

  TClientDataSet(DS).IndexDefs.Add('IndexDT', 'DTScale', []);
end;

// 设置字段displaylabel
procedure _SetFieldsDisplayName(DS: TDataSet; APDDefines: TDataDefines);
var
  i: Integer;
begin
  with DS as TClientDataSet do
  begin
    Fields[0].DisplayLabel := '观测日期';
    for i := 0 to APDDefines.Count - 1 do
    begin
      Fields[i + 1].DisplayLabel := APDDefines.Items[i].Name;
      if Fields[i + 1].DataType = ftFloat then
        (Fields[i + 1] as TNumericField).DisplayFormat := '0.00';
    end;
        // 如果最后一个字段名为Annotation，则为备注字段
    with Fields[Fields.Count - 1] do
      if Name = 'Annotation' then
          DisplayLabel := '备注';
  end;
end;

// 根据仪器组定义创建数据集字段
procedure _CreateFieldsFromGroup(DS: TDataSet; AGroup: TMeterGroupItem);
var
  i, j: Integer;
  DF  : TFieldDef;
  MT  : TMeterDefine;
begin
  TClientDataSet(DS).FieldDefs.Clear;
  TClientDataSet(DS).IndexDefs.Clear;

  DF := DS.FieldDefs.AddFieldDef;
  DF.Name := 'DTScale';
  DF.DataType := ftDateTime;
  DF.DisplayName := '观测日期';
  for i := 0 to AGroup.Count - 1 do
  begin
    MT := ExcelMeters.Meter[AGroup.Items[i]];
    for j := 0 to MT.DataSheetStru.PDs.Count - 1 do
    begin
      DF := DS.FieldDefs.AddFieldDef;
      DF.Name := Format('%s.PD%d', [MT.DesignName, j + 1]);
      DF.DataType := ftFloat;
    end;
  end;
    { DONE:增加备注字段 }
  DF := DS.FieldDefs.AddFieldDef;
  DF.Name := 'Annotation';
  DF.DataType := ftString;
  DF.DisplayName := '备注';
    // 增加索引字段
  TClientDataSet(DS).IndexDefs.Add('IndexDT', 'DTScale', []);
end;

procedure _SetGroupFieldsDisplayName(DS: TDataSet; AGroup: TMeterGroupItem);
var
  i, j, n: Integer;
// fld    : TField;
  MT: TMeterDefine;
begin
  with DS as TClientDataSet do
  begin
    Fields[0].DisplayLabel := '观测日期';
    Fields[Fields.Count - 1].DisplayLabel := '备注';
    n := 1;
    for i := 0 to AGroup.Count - 1 do
    begin
      MT := ExcelMeters.Meter[AGroup.Items[i]];
      for j := 0 to MT.DataSheetStru.PDs.Count - 1 do
      begin
        Fields[n].DisplayLabel :=
          Format('%s|%s', [MT.DesignName, MT.DataSheetStru.PDs.Items[j].Name]);
        if Fields[n].DataType = ftFloat then
          (Fields[n] as TNumericField).DisplayFormat := '0.00';
        inc(n);
      end;
    end;
  end;
end;

destructor ThjxDataQuery.Destroy;
begin
  inherited;
end;

procedure ThjxDataQuery.SessionBegin;
begin
  FUseSession := True;
  SSWorkBook := TmyWorkbook.Create;
end;

procedure ThjxDataQuery.SessionEnd;
begin
  SSWorkBook := nil;
  FUseSession := False;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetLastPDDatas
  Description: 取回最后一次观测数据（物理量），返回结果数组为：日期、物理量
  数组，其中日期以双精度表示
  ----------------------------------------------------------------------------- }
function ThjxDataQuery.GetLastPDDatas(ADsnName: string; var Values: TDoubleDynArray): Boolean;
var
  Meter    : TMeterDefine;
  wbk      : IXLSWorkBook;
  sht      : IXLSWorksheet;
  iCount, i: Integer;
  iRow     : Integer;
  S        : String;
begin
  Result := False;
  SetLength(Values, 0);
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then Exit;

  if FUseSession then wbk := SSWorkBook
  else wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then Exit;

  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then Exit;

  iCount := Meter.PDDefines.Count + 1; // 物理量+观测日期
  SetLength(Values, iCount);
  Values[0] := 0; // 观测日期设置为0，若没有数据，则不填入，调用者通过观测日期是否为0判断是否有观测数据。

    // 下面开始倒序查找数据
  for iRow := sht.UsedRange.LastRow + 5 downto Meter.DataSheetStru.DTStartRow do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then Continue;
        // 观测日期
    Values[0] := ExcelIO.GetDateTimeValue(sht, iRow, 1);

        // 备注 由于Values是Double类型数组，无法填入备注
        { with Meter.DataSheetStru do
            if AnnoCol > 0 then
                Values[iCount - 1] := ExcelIO.GetStrValue(sht, iRow, Meter.DataSheetStru.AnnoCol); }

        // 各个物理量
    for i := 0 to Meter.PDDefines.Count - 1 do
        Values[i + 1] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
    Break;
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetLastPDDatas
  Description: 返回最后一次观测数据，格式为“日期+物理量数组”，返回数据为Variant，
  若数据合法则为双精度数值，否则为NULL。
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetLastPDDatas(ADsnName: string; var Values: TVariantDynArray): Boolean;
var
  Meter    : TMeterDefine;
  wbk      : IXLSWorkBook;
  sht      : IXLSWorksheet;
  iCount, i: Integer;
  iRow     : Integer;
  S        : String;
begin
  Result := False;
  for i := Low(Values) to High(Values) do VarClear(Values[i]);
  SetLength(Values, 0);

  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then Exit;

  if FUseSession then wbk := SSWorkBook
  else wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then Exit;

  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then Exit;

  iCount := Meter.PDDefines.Count + 1; // 物理量+观测日期
  SetLength(Values, iCount);
  Values[0] := 0; // 观测日期设置为0，若没有数据，则不填入，调用者通过观测日期是否为0判断是否有观测数据。

    // 下面开始倒序查找数据
  for iRow := sht.UsedRange.LastRow + 5 downto Meter.DataSheetStru.DTStartRow do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then Continue;
        // 观测日期
    Values[0] := ExcelIO.GetDateTimeValue(sht, iRow, 1);

        // 备注 由于Values是Double类型数组，无法填入备注
        { with Meter.DataSheetStru do
            if AnnoCol > 0 then
                Values[iCount - 1] := ExcelIO.GetStrValue(sht, iRow, Meter.DataSheetStru.AnnoCol); }

        // 各个物理量
    for i := 0 to Meter.PDDefines.Count - 1 do
        Values[i + 1] := _GetFloatOrNull(sht, iRow, Meter.PDColumn(i));
        // Values[i + 1] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
    Break;
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetLastPDDatasInPeriod
  Description: 取回指定时段内最后一次观测数据
  ----------------------------------------------------------------------------- }
function ThjxDataQuery.GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
  var Values: TDoubleDynArray): Boolean;
var
  Meter    : TMeterDefine;
  wbk      : IXLSWorkBook;
  sht      : IXLSWorksheet;
  iCount, i: Integer;
  iRow     : Integer;
// S        : String;
// DT1      : TDateTime;
begin
  Result := False;
  SetLength(Values, 0);
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;

  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;

  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

  iCount := Meter.PDDefines.Count + 1; // 物理量+观测日期+备注
  SetLength(Values, iCount);
  Values[0] := 0; // 观测日期设置为0，若没有数据，则不填入，调用者通过观测日期是否为0判断是否有观测数据。
  iRow := _LocateDTRow(sht, DT, Meter.DataSheetStru.DTStartRow, dloBefore);
  if (iRow <> -1) and (iRow > Meter.DataSheetStru.DTStartRow) then
  begin
    Dec(iRow); // 早一行
    Values[0] := ExcelIO.GetDateTimeValue(sht, iRow, 1);
    for i := 0 to Meter.PDDefines.Count - 1 do
        Values[i + 1] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
  end
  else
      Exit;

// for iRow := sht.UsedRange.LastRow + 1 downto Meter.DataSheetStru.DTStartRow do
// begin
// S := Trim(VarToStr(sht.Cells[iRow, 1].value));
// if S = '' then
// Continue;
//
// if TryStrToDateTime(S, DT1) = False then
// Continue; // 如果时间字符串无效，跳过本条记录
//
// if DT1 > DT then
// Continue;
//
// Values[0] := ExcelIO.GetDateTimeValue(sht, iRow, 1); // 观测日期
// { with Meter.DataSheetStru do
// if AnnoCol > 0 then
// Values[iCount - 1] := ExcelIO.GetStrValue(sht, iRow, Meter.DataSheetStru.AnnoCol); }
//
// for i := 0 to Meter.PDDefines.Count - 1 do
// Values[i + 1] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
// Break;
//
// end;

  Result := True;
end;

function ThjxDataQuery.GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
  var Values: TVariantDynArray): Boolean;
var
  Meter    : TMeterDefine;
  wbk      : IXLSWorkBook;
  sht      : IXLSWorksheet;
  iCount, i: Integer;
  iRow     : Integer;
// S        : String;
// DT1      : TDateTime;
begin
  Result := False;
  for i := Low(Values) to High(Values) do VarClear(Values[i]);
  SetLength(Values, 0);
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;

  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;

  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

  iCount := Meter.PDDefines.Count + 1; // 物理量+观测日期+备注
  SetLength(Values, iCount);
  Values[0] := 0; // 观测日期设置为0，若没有数据，则不填入，调用者通过观测日期是否为0判断是否有观测数据。
  iRow := _LocateDTRow(sht, DT, Meter.DataSheetStru.DTStartRow, dloBefore);
  if (iRow <> -1) and (iRow > Meter.DataSheetStru.DTStartRow) then
  begin
    Dec(iRow); // 早一行
    Values[0] := ExcelIO.GetDateTimeValue(sht, iRow, 1);
    for i := 0 to Meter.PDDefines.Count - 1 do
        Values[i + 1] := _GetFloatOrNull(sht, iRow, Meter.PDColumn(i));
        // Values[i + 1] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
  end
  else
      Exit;

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetNearestPDDatas
  Description: 取回最接近指定日期的观测数据，时间可前可后
  ----------------------------------------------------------------------------- }
{ DONE:应采用更快的数据查找方式，而非从第一条一直找到最后 }
function ThjxDataQuery.GetNearestPDDatas(ADsnName: string; DT: TDateTime;
  var Values: TDoubleDynArray;
  DTDelta: Integer = 0): Boolean;
var
  Meter      : TMeterDefine;
  wbk        : IXLSWorkBook;
  sht        : IXLSWorksheet;
  iCount     : Integer;
  iRow, iLRow: Integer;
// S           : String;
  DT1         : TDateTime;
  dLast, dThis: double;

  procedure SetData(ARow: Integer);
  var
    ii: Integer;
  begin
    Values[0] := ExcelIO.GetDateTimeValue(sht, ARow, 1);
        { with Meter.DataSheetStru do
            if AnnoCol > 0 then
                Values[iCount - 1] := ExcelIO.GetStrValue(sht, ARow, AnnoCol); }

    for ii := 0 to Meter.PDDefines.Count - 1 do
        Values[ii + 1] := ExcelIO.GetFloatValue(sht, ARow, Meter.PDColumn(ii));
  end;

begin
  Result := False;
  SetLength(Values, 0);
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;

  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;

  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

  iCount := Meter.PDDefines.Count + 1; // 物理量+观测日期+备注
  SetLength(Values, iCount);
  Values[0] := 0; // 观测日期设置为0，若没有数据，则不填入，调用者通过观测日期是否为0判断是否有观测数据。
    // 倒序查找
  dLast := -10000;
  dThis := 10000;
  iLRow := 0;

  iRow := _LocateDTRow(sht, DT, Meter.DataSheetStru.DTStartRow, dloClosest);
  if iRow = -1 then
      Exit;

  DT1 := ExcelIO.GetDateTimeValue(sht, iRow, 1);
  if DTDelta <> 0 then // 如果有限差，且超限，则退出
  begin
    dLast := Abs(DaysBetween(DT1, DT));
    if dLast > DTDelta then
        Exit;
  end;

  SetData(iRow);

  Result := True;
end;

function ThjxDataQuery.GetNearestPDDatas(ADsnName: string; DT: TDateTime;
  var Values: TVariantDynArray; DTDelta: Integer = 0): Boolean;
var
  Meter      : TMeterDefine;
  wbk        : IXLSWorkBook;
  sht        : IXLSWorksheet;
  iCount, i  : Integer;
  iRow, iLRow: Integer;
// S           : String;
  DT1         : TDateTime;
  dLast, dThis: double;

  procedure SetData(ARow: Integer);
  var
    ii: Integer;
  begin
    Values[0] := ExcelIO.GetDateTimeValue(sht, ARow, 1);
        { with Meter.DataSheetStru do
            if AnnoCol > 0 then
                Values[iCount - 1] := ExcelIO.GetStrValue(sht, ARow, AnnoCol); }

    for ii := 0 to Meter.PDDefines.Count - 1 do
        Values[ii + 1] := { ExcelIO.GetFloatValue } _GetFloatOrNull(sht, ARow, Meter.PDColumn(ii));
  end;

begin
  Result := False;
  for i := low(Values) to high(Values) do VarClear(Values[i]);
  SetLength(Values, 0);
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;

  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;

  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

  iCount := Meter.PDDefines.Count + 1; // 物理量+观测日期+备注
  SetLength(Values, iCount);
  Values[0] := 0; // 观测日期设置为0，若没有数据，则不填入，调用者通过观测日期是否为0判断是否有观测数据。
    // 倒序查找
  dLast := -10000;
  dThis := 10000;
  iLRow := 0;

  iRow := _LocateDTRow(sht, DT, Meter.DataSheetStru.DTStartRow, dloClosest);
  if iRow = -1 then
      Exit;

  DT1 := ExcelIO.GetDateTimeValue(sht, iRow, 1);
  if DTDelta <> 0 then // 如果有限差，且超限，则退出
  begin
    dLast := Abs(DaysBetween(DT1, DT));
    if dLast > DTDelta then
        Exit;
  end;

  SetData(iRow);

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetPDDatasInPeriod
  Description: 取回指定时段内的观测数据
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetPDDatasInPeriod(ADsnName: string; DT1: TDateTime; DT2: TDateTime;
  DS: TDataSet): Boolean;
var
  wbk    : IXLSWorkBook;
  sht    : IXLSWorksheet;
  Meter  : TMeterDefine;
  S      : string;
  iRow, i: Integer;
  DT     : TDateTime;
  AnnoCol: Integer;
begin
  Result := False;
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;
  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;

  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if ExcelIO.OpenWorkbook(wbk, Meter.DataBook) = False then
      Exit;
  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;
    // 运行到这里，可以尝试创建DataSet、读取数据了
    // 如果DS为空，则创建之
  if DS = nil then
      DS := TClientDataSet.Create(nil)
  else
  begin
    if DS.Active then
        DS.Close;
    DS.FieldDefs.Clear;
  end;
    // 给DS中添加字段
  _CreateFieldsFromPDDefines(DS, Meter.PDDefines);
    { 这里要注意，尽量使用TClientDataset！！！ }
  TClientDataSet(DS).CreateDataSet;
  _SetFieldsDisplayName(DS, Meter.PDDefines);

  if Meter.DataSheetStru.AnnoCol > 0 then
      AnnoCol := Meter.DataSheetStru.AnnoCol
  else AnnoCol := 0;

  for iRow := Meter.DataSheetStru.DTStartRow to sht.UsedRange.LastRow + 1 do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
    if TryStrToDateTime(S, DT) = False then
        Continue;

    if DT > DT2 then
        Break;

    if DT >= DT1 then
    begin
            // ---------------------
      DS.Append;
            // 观测日期
      DS.Fields[0].Value := StrToDateTime(S);
            // 备注
      if AnnoCol > 0 then
          DS.Fields[DS.Fields.Count - 1].Value := ExcelIO.GetStrValue(sht, iRow, AnnoCol);
            // 物理量
      for i := 0 to Meter.PDDefines.Count - 1 do
          DS.Fields[i + 1].Value := _GetFloatOrNull(sht, iRow, Meter.PDColumn(i));
          // DS.Fields[i + 1].Value := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
      DS.Post;
    end;
  end;
  Result := True;
end;

function ThjxDataQuery.GetAllPDDatas(ADsnName: string; DS: TDataSet): Boolean;
var
  wbk    : IXLSWorkBook;
  sht    : IXLSWorksheet;
  Meter  : TMeterDefine;
  S      : string;
  iRow, i: Integer;
  AnnoCol: Integer;
  function __GetFloatValue(iRow, iCol: Integer): Variant;
  var
    sVar: String;
    d   : double;
  begin
    Result := Null;
      // sht.Cells[irow,icol].Value
    if VarIsFloat(sht.Cells[iRow, iCol].Value) then Result := sht.Cells[iRow, iCol].Value;
  end;

begin
  Result := False;
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;
  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;

  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if ExcelIO.OpenWorkbook(wbk, Meter.DataBook) = False then
      Exit;
  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;
    // 运行到这里，可以尝试创建DataSet、读取数据了
    // 如果DS为空，则创建之
  if DS = nil then
      DS := TClientDataSet.Create(nil)
  else
  begin
    if DS.Active then
        DS.Close;
    DS.FieldDefs.Clear;
  end;
    // 给DS中添加字段
  _CreateFieldsFromPDDefines(DS, Meter.PDDefines);
    { 这里要注意，尽量使用TClientDataset！！！ }
  TClientDataSet(DS).CreateDataSet;
  _SetFieldsDisplayName(DS, Meter.PDDefines);

  if Meter.DataSheetStru.AnnoCol > 0 then
      AnnoCol := Meter.DataSheetStru.AnnoCol
  else AnnoCol := 0;

    // 查询、添加数据
  for iRow := Meter.DataSheetStru.DTStartRow to sht.UsedRange.LastRow + 2 do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
        // ---------------------
    DS.Append;
    DS.Fields[0].Value := StrToDateTime(S);
    if AnnoCol > 0 then
        DS.Fields[DS.Fields.Count - 1].Value := ExcelIO.GetStrValue(sht, iRow, AnnoCol);

    for i := 0 to Meter.PDDefines.Count - 1 do
        DS.Fields[i + 1].Value := __GetFloatValue(iRow, Meter.PDColumn(i));
          // { todo:BUG!!当单元格没有值或不是数值时，此函数将返回0，而不是空值 }
          // DS.Fields[i + 1].value := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
    DS.Post;
  end;
  Result := True;
end;

type
  TevCheckDate = record
    theYear, theMon: Integer;
    dtYear1, dtYear2: TDateTime;
    dtMon1, dtMon2: TDateTime;
  end;

    { -----------------------------------------------------------------------------
      Procedure  : GetEVData   （废弃不用，因为只返回第一个物理量的特征值）
      Description: 查找当前特征值，时间为最后一次观测时间，目前只能查询PD1的特征值
      对于多点位移计也是如此。
      ----------------------------------------------------------------------------- }
function ThjxDataQuery.GetEVData(ADsnName: string; EVData: PEVDataStru): Boolean;
var
  Meter  : TMeterDefine;
  wbk    : IXLSWorkBook;
  sht    : IXLSWorksheet;
  chkDate: TevCheckDate;
  iRow   : Integer;
  S      : String;
  PD1    : double;
  dtScale: TDateTime;

  procedure SetDate(DT: TDateTime);
  begin
    chkDate.theYear := YearOf(DT);
    chkDate.theMon := MonthOf(DT);
    chkDate.dtYear1 := EncodeDate(chkDate.theYear, 1, 1);
    chkDate.dtYear2 := EndOfAYear(chkDate.theYear);
    chkDate.dtMon1 := EncodeDate(chkDate.theYear, chkDate.theMon, 1);
    chkDate.dtMon2 := EndOfAMonth(chkDate.theYear, chkDate.theMon);
  end;

begin
  Result := False;
  EVData.Init;
  chkDate.dtYear1 := 0;
  chkDate.dtMon1 := 0;
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;
  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;
  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;
  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

    { set date for check }
  EVData.ID := Meter.DesignName;
  for iRow := sht.UsedRange.LastRow + 2 downto Meter.DataSheetStru.DTStartRow do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
    if TryStrToDateTime(S, dtScale) = False then
        Continue;

    PD1 := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(0));

        { 判断是否设置了CheckDate，若无则设置之：此时遇到最后一条记录 }
    if chkDate.dtMon1 = 0 then
    begin
      SetDate(dtScale);
            { 当前值 }
      EVData.CurValue := PD1;
      EVData.CurDate := dtScale;
    end;

        { LeftEV }
    EVData.LifeEV.CompareData(dtScale, PD1);

        { YearEV }
    if YearOf(dtScale) = chkDate.theYear then
    begin
      EVData.YearEV.CompareData(dtScale, PD1);
            { MonthEV }
      if MonthOf(dtScale) = chkDate.theMon then
          EVData.MonthEV.CompareData(dtScale, PD1);
    end;
  end;

  Result := True;
end;

{ 废弃不用了 }
function ThjxDataQuery.GetEVData(ADsnName: string; var EVDatas: TDoubleDynArray): Boolean;
var
  EVData: PEVDataStru;
begin
  Result := False;
  SetLength(EVDatas, 0);
  New(EVData);
  try
    Result := GetEVData(ADsnName, EVData);
    if Result then
    begin
      SetLength(EVDatas, 14);
      with EVData.LifeEV do
      begin
        EVDatas[0] := MaxValue;
        EVDatas[1] := MaxDate;
        EVDatas[2] := MinValue;
        EVDatas[3] := MinDate;
      end;
      with EVData.YearEV do
      begin
        EVDatas[4] := MaxValue;
        EVDatas[5] := MaxDate;
        EVDatas[6] := MinValue;
        EVDatas[7] := MinDate;
      end;
      with EVData.MonthEV do
      begin
        EVDatas[8] := MaxValue;
        EVDatas[9] := MaxDate;
        EVDatas[10] := MinValue;
        EVDatas[11] := MinDate;
      end;
      EVDatas[12] := EVData.CurValue;
      EVDatas[13] := EVData.CurDate;
    end;
  finally
    Dispose(EVData);
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetEVDatas
  Description: 本方法返回仪器所有具有特征值的物理量的特征值
  与GetEVData不同，GetEVData仅返回第一个物理量的特征值，本函数返回有特征值的
  物理量的特征值。有些仪器有多个物理量，比如多点位移计，每个测点都需要返回特
  征值，本方法一次性将这些测点的特征值全部取回。
  ----------------------------------------------------------------------------- }
function ThjxDataQuery.GetEVDatas(ADsnName: string; var EVDatas: PEVDataArray): Boolean;
var
  Meter  : TMeterDefine;
  i, n   : Integer;
  wbk    : IXLSWorkBook;
  sht    : IXLSWorksheet;
  chkDate: TevCheckDate;
  iRow   : Integer;
  S      : String;
  dtScale: TDateTime;
    // 释放调用者提供的evdatas占用的内存，不同的仪器特征值数量不同
  procedure ReleaseEVDatas;
  var
    ii: Integer;
  begin
    if Length(EVDatas) > 0 then
      for ii := Low(EVDatas) to High(EVDatas) do
        try
          Dispose(EVDatas[ii]);
        except
        end;
    SetLength(EVDatas, 0);
  end;
  procedure SetDate(DT: TDateTime);
  begin
    chkDate.theYear := YearOf(DT);
    chkDate.theMon := MonthOf(DT);
    chkDate.dtYear1 := EncodeDate(chkDate.theYear, 1, 1);
    chkDate.dtYear2 := EndOfAYear(chkDate.theYear);
    chkDate.dtMon1 := EncodeDate(chkDate.theYear, chkDate.theMon, 1);
    chkDate.dtMon2 := EndOfAMonth(chkDate.theYear, chkDate.theMon);
  end;
  procedure FindEVData(iev: Integer);
  var
    d   : double;
    iCol: Integer;
  begin
    iCol := Meter.PDColumn(EVDatas[iev].PDIndex);
    d := ExcelIO.GetFloatValue(sht, iRow, iCol);

    EVDatas[iev].LifeEV.CompareData(dtScale, d);
    EVDatas[iev].LifeEV.Increment := EVDatas[iev].CurValue - d; // 2018-09-18 生命期增量

    if YearOf(dtScale) = chkDate.theYear then
    begin
      EVDatas[iev].YearEV.CompareData(dtScale, d);
      EVDatas[iev].YearEV.Increment := EVDatas[iev].CurValue - d; // 2018-09-18 年增量
      if MonthOf(dtScale) = chkDate.theMon then
      begin
        EVDatas[iev].MonthEV.CompareData(dtScale, d);
        EVDatas[iev].MonthEV.Increment := EVDatas[iev].CurValue - d; // 月增量
      end;
    end;
  end;

begin
  Result := False;
  chkDate.theYear := 0;
  chkDate.theMon := 0;
    // 必要的检查和初始化
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;
  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;
  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

    // 对EVDatas数组初始化，释放多余的内存
  ReleaseEVDatas;
    // 根据Meter具有特征值的物理量数量初始化EVDatas数组
  n := 0;
  for i := 0 to Meter.PDDefines.Count - 1 do
    if Meter.PDDefine[i].HasEV then
    begin
      inc(n);
      SetLength(EVDatas, n);
      New(EVDatas[n - 1]);
      EVDatas[n - 1].Init;
      EVDatas[n - 1].PDIndex := i;
      EVDatas[n - 1].ID := ADsnName;
    end;

  for iRow := sht.UsedRange.LastRow + 1 downto Meter.DataSheetStru.DTStartRow do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
    if TryStrToDateTime(S, dtScale) = False then
        Continue;
        // 如果没有设置时间，则现在设置：即以最后一条记录的时间作为该仪器的特征值统计时间
    if chkDate.theYear = 0 then
    begin
      SetDate(dtScale); // 初始化时间设置
            // 设置当前值
      for i := 0 to High(EVDatas) do
      begin
        EVDatas[i].CurDate := dtScale;
        { todo:数值合法性判断 }
        EVDatas[i].CurValue := ExcelIO.GetFloatValue(sht, iRow,
          Meter.PDColumn(EVDatas[i].PDIndex));
      end;
    end;
        //
    for i := 0 to High(EVDatas) do
        FindEVData(i);
  end;

    // 2018-09-18振幅
  for i := 0 to High(EVDatas) do
    with EVDatas[i]^ do
    begin
      LifeEV.Amplitude := LifeEV.MaxValue - LifeEV.MinValue;
      YearEV.Amplitude := YearEV.MaxValue - YearEV.MinValue;
      MonthEV.Amplitude := MonthEV.MaxValue - MonthEV.MinValue;
    end;

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetEVDataInPeriod
  Description: 返回指定时段内的特征值
  2018-09-17 基本照抄GetEVDatas函数，只是改变了查询范围，从查询全部改为只查询
  时段内。下一步将两个函数合并为一个，GetEVDatas调用本函数完成全部数据查询
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetEVDataInPeriod(ADsnName: string; DT1: TDateTime; DT2: TDateTime;
  var EVDatas: PEVDataArray): Boolean;
var
  Meter     : TMeterDefine;
  i, n      : Integer;
  wbk       : IXLSWorkBook;
  sht       : IXLSWorksheet;
  chkDate   : TevCheckDate;
  iRow      : Integer;
  Row1, Row2: Integer; // 指定日期起止行
  S         : String;
  dtScale   : TDateTime;
    // 释放调用者提供的evdatas占用的内存，不同的仪器特征值数量不同
  procedure ReleaseEVDatas;
  var
    ii: Integer;
  begin
    if Length(EVDatas) > 0 then
      for ii := Low(EVDatas) to High(EVDatas) do
        try
          Dispose(EVDatas[ii]);
        except
        end;
    SetLength(EVDatas, 0);
  end;
  procedure SetDate(DT: TDateTime);
  begin
    chkDate.theYear := YearOf(DT);
    chkDate.theMon := MonthOf(DT);
    chkDate.dtYear1 := EncodeDate(chkDate.theYear, 1, 1);
    chkDate.dtYear2 := EndOfAYear(chkDate.theYear);
    chkDate.dtMon1 := EncodeDate(chkDate.theYear, chkDate.theMon, 1);
    chkDate.dtMon2 := EndOfAMonth(chkDate.theYear, chkDate.theMon);
  end;
  procedure FindEVData(iev: Integer);
  var
    d   : double;
    iCol: Integer;
  begin
    iCol := Meter.PDColumn(EVDatas[iev].PDIndex);
    d := ExcelIO.GetFloatValue(sht, iRow, iCol);
    with EVDatas[iev]^ do
    begin
      LifeEV.CompareData(dtScale, d);
      LifeEV.Increment := CurValue - d;
      if YearOf(dtScale) = chkDate.theYear then
      begin
        YearEV.CompareData(dtScale, d);
        YearEV.Increment := CurValue - d;
        if MonthOf(dtScale) = chkDate.theMon then
        begin
          MonthEV.CompareData(dtScale, d);
          MonthEV.Increment := CurValue - d;
        end;
      end;
    end;
  end;

begin
  Result := False;
  chkDate.theYear := 0;
  chkDate.theMon := 0;
    // 必要的检查和初始化
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;

    { 这里需要处理：如果仪器初值日期比DT2还晚，就不查了 }
  if Meter.Params.BaseDate > DT2 then
      Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;
  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;
  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

    // 对EVDatas数组初始化，释放多余的内存
  ReleaseEVDatas;
    // 根据Meter具有特征值的物理量数量初始化EVDatas数组
  n := 0;
  for i := 0 to Meter.PDDefines.Count - 1 do
    if Meter.PDDefine[i].HasEV then
    begin
      inc(n);
      SetLength(EVDatas, n);
      New(EVDatas[n - 1]);
      EVDatas[n - 1].Init;
      EVDatas[n - 1].PDIndex := i;
      EVDatas[n - 1].ID := ADsnName;
    end;

    { 与GetEVDatas不同的地方在这里： }
  Row1 := _LocateDTRow(sht, DT1, Meter.DataSheetStru.DTStartRow, dloClosest);
  Row2 := _LocateDTRow(sht, DT2, Meter.DataSheetStru.DTStartRow, dloBefore);
    // for iRow := sht.UsedRange.LastRow + 1 downto Meter.DataSheetStru.DTStartRow do
  for iRow := Row2 downto Row1 do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
    if TryStrToDateTime(S, dtScale) = False then
        Continue;
        // 如果没有设置时间，则现在设置：即以最后一条记录的时间作为该仪器的特征值统计时间
    if chkDate.theYear = 0 then
    begin
      SetDate(dtScale); // 初始化时间设置
            // 设置当前值
      for i := 0 to High(EVDatas) do
      begin
        EVDatas[i].CurDate := dtScale;
        { todo:此处应当判断数据合法性 }
        EVDatas[i].CurValue := ExcelIO.GetFloatValue(sht, iRow,
          Meter.PDColumn(EVDatas[i].PDIndex));
      end;
    end;
        //
    for i := 0 to High(EVDatas) do
        FindEVData(i);
  end;

    // 计算振幅
  for i := 0 to high(EVDatas) do
    with EVDatas[i]^ do
    begin
      LifeEV.Amplitude := LifeEV.MaxValue - LifeEV.MinValue;
      YearEV.Amplitude := YearEV.MaxValue - YearEV.MinValue;
      MonthEV.Amplitude := MonthEV.MaxValue - MonthEV.MinValue;
    end;

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : SetFieldDisplayName
  Description: 本方法根据在Excel参数表中预定义的字段名与别名对应表更换DataSet
  中的字段DisplayLabel。在本单元中，这个对应表取自Excel的属性定义工作簿中的字段
  名表，该表在加载参数时被加载，并存储到uhjx.excel.meters单元中的DSNames对象中，
  该对象有一个DispName方法，可根据字段名返回对应的DisplayLabel。
  2018-05-31 感觉这个方法没用，一般生成的时候字段名都是PD1,PD2..等等，要替换为
  能理解的字段名，需要用仪器定义中的字段名去替换
----------------------------------------------------------------------------- }
procedure ThjxDataQuery.SetFieldDisplayName(DS: TDataSet);
var
  i: Integer;
  S: string;
begin
  for i := 0 to DS.Fields.Count - 1 do
  begin
    S := DSNames.DispName(DS.Fields[i].FieldName);
    if S <> '' then
        DS.Fields[i].DisplayLabel := S;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetDataCount
  Description: 取回指定仪器在指定时间段内的观测数据点次
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetDataCount(ADsnName: string; DT1: TDateTime; DT2: TDateTime): Integer;
var
  Meter  : TMeterDefine;
  wbk    : IXLSWorkBook;
  sht    : IXLSWorksheet;
  iRow   : Integer;
  S      : String;
  dtScale: TDateTime;
begin
  Result := 0;
  Meter := ExcelMeters.Meter[ADsnName];
    // 前期准备工作-----------------------------
  if Meter = nil then
      Exit;
  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;
  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;
  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;
    // -------------------------------------------
  for iRow := Meter.DataSheetStru.DTStartRow to sht.UsedRange.LastRow + 1 do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, Meter.DataSheetStru.DTStartCol].Value));
    if S = '' then
        Continue;
    if TryStrToDate(S, dtScale) then
      if (dtScale >= DT1) and (dtScale <= DT2) then
          inc(Result);
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetMeterTypeName
  Description: 返回监测仪器类型名称，如“多点位移计”、“锚索测力计”, etc.
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetMeterTypeName(ADsnName: string): string;
var
  Meter: TMeterDefine;
begin
  Result := '';
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;
  Result := Meter.Params.MeterType;
end;

type
    // 本结构用于指向仪器组内各仪器的工作簿和工作表
  TGroupMeterSheet = record
    DsnName: string;
    Meter: TMeterDefine;
    WbkBook: IXLSWorkBook;
    Sheet: IXLSWorksheet;
  end;

  PGroupMeterSheet = ^TGroupMeterSheet;
  PGroupSheets     = array of PGroupMeterSheet;

{ -----------------------------------------------------------------------------
  Procedure  : _PrepareGroupDataSet
  Description: 预备工作，为提取组数据准备
  预备内容：1、创建一个结构数组保存组内仪器、对应的工作簿和工作表；2、打开
  仪器数据对应的工作簿，返回工作簿和工作表对象；3、创建组数据集，设置字段等；
----------------------------------------------------------------------------- }
procedure _PrepareGroupDataSet(AGroup: TMeterGroupItem; var AGrpSheets: PGroupSheets;
  ADataSet: TDataSet);
var
  Meter: TMeterDefine;
  bwbk : Boolean;
  i, j : Integer;
begin
    // 打开每个仪器的工作簿和工作表
  SetLength(AGrpSheets, AGroup.Count);
  for i := 0 to AGroup.Count - 1 do
  begin
    New(AGrpSheets[i]);
    AGrpSheets[i].DsnName := AGroup.Items[i];
    Meter := ExcelMeters.Meter[AGroup.Items[i]];
    AGrpSheets[i].Meter := Meter;
    if Meter = nil then
        Continue;
    bwbk := False;
        // 对于第一支仪器，打开工作簿和工作表
    if i = 0 then
    begin
      AGrpSheets[0].WbkBook := TmyWorkbook.Create;
      ExcelIO.OpenWorkbook(AGrpSheets[0].WbkBook, Meter.DataBook);
      AGrpSheets[0].Sheet := ExcelIO.GetSheet(AGrpSheets[0].WbkBook, Meter.DataSheet);
    end
    else // 对于其他仪器，检查同组仪器的工作簿是否相同、工作表是否相同，如果相同则引用否则打开
    begin
      for j := 0 to i do
      begin
        IAppServices.ProcessMessages;
        if TmyWorkbook(AGrpSheets[j].WbkBook).FullName = Meter.DataBook then
        begin
          AGrpSheets[i].WbkBook := AGrpSheets[j].WbkBook;
          bwbk := True; // 已有工作簿
          Break;
        end;
      end;
      if not bwbk then
      begin
        AGrpSheets[i].WbkBook := TmyWorkbook.Create;
        ExcelIO.OpenWorkbook(AGrpSheets[i].WbkBook, Meter.DataBook);
      end;
      AGrpSheets[i].Sheet := ExcelIO.GetSheet(AGrpSheets[i].WbkBook, Meter.DataSheet);
    end;
  end;

    // 工作表已经打开完毕，创建数据集
  if ADataSet = nil then
      ADataSet := TClientDataSet.Create(nil)
  else
  begin
    if ADataSet.Active then
        ADataSet.Close;
    ADataSet.FieldDefs.Clear;
  end;

    // 创建数据集字段定义
  _CreateFieldsFromGroup(ADataSet, AGroup);
  TClientDataSet(ADataSet).CreateDataSet;
  _SetGroupFieldsDisplayName(ADataSet, AGroup);
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetGroupAllPDDatas
  Description: 返回仪器组全部观测数据
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetGroupAllPDDatas(AGrpName: string; DS: TDataSet): Boolean;
var
  GroupSheets: PGroupSheets;
  Group      : TMeterGroupItem;
  i, j, iRow : Integer;
  k, n       : Integer;
  S          : String;
begin
  Result := False;
  Group := MeterGroup.ItemByName[AGrpName];
  if Group = nil then
      Exit;
    // 准备工作簿、工作表、创建数据集、设置数据集字段等等准备工作
  _PrepareGroupDataSet(Group, GroupSheets, DS);

    // 添加数据记录
    { todo:考虑仪器不同工作表、不同工作簿、观测日期可能有差异的情况 }
    // 2018-05-29 为加快导出观测数据表的功能，目前假设仪器组的仪器全部处于相同的工作表中，
    // 并共有相同的观测日期。这个处理方式目前针对锚杆应力计组有效
  for iRow := GroupSheets[0].Meter.DataSheetStru.DTStartRow to GroupSheets[0]
    .Sheet.UsedRange.LastRow + 2 do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(GroupSheets[0].Sheet.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
    DS.Append;
    DS.Fields[0].Value := StrToDateTime(S); // DTScale，这里没有判断S类型转换错误

        // 添加第一支仪器的备注
        { todo:在填写仪器组备注字段时，这里仅处理了第一支仪器的备注，没有考虑其他仪器的备注字段 }
    DS.Fields[DS.Fields.Count - 1].Value := ExcelIO.GetStrValue(GroupSheets[0].Sheet, iRow,
      GroupSheets[0].Meter.DataSheetStru.AnnoCol);

        // 添加第一支仪器观测数据
    for i := 0 to GroupSheets[0].Meter.PDDefines.Count - 1 do
        DS.Fields[i + 1].Value := _GetFloatOrNull(GroupSheets[0].Sheet, iRow,
        GroupSheets[0].Meter.PDColumn(i));
        // DS.Fields[i + 1].Value := ExcelIO.GetFloatValue(GroupSheets[0].Sheet, iRow,
        // GroupSheets[0].Meter.PDColumn(i));
    n := GroupSheets[0].Meter.PDDefines.Count + 1;
        // 添加其他仪器观测数据，这里假设观测记录都在同一行，即使不在同一张工作表
    for j := 1 to High(GroupSheets) do
      for k := 0 to GroupSheets[j].Meter.PDDefines.Count - 1 do
      begin
        IAppServices.ProcessMessages;
        DS.Fields[n].Value := _GetFloatOrNull(GroupSheets[j].Sheet, iRow,
          GroupSheets[j].Meter.PDColumn(k));
        // DS.Fields[n].Value := ExcelIO.GetFloatValue(GroupSheets[j].Sheet, iRow,
        // GroupSheets[j].Meter.PDColumn(k));
        inc(n);
      end;
        // 确定
    DS.Post;
  end;

    // 收尾工作
  for i := 0 to High(GroupSheets) do
      Dispose(GroupSheets[i]);
  SetLength(GroupSheets, 0);
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetGroupPDDatasInPeriod
  Description: 返回仪器组在指定时段内的观测数据
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetGroupPDDatasInPeriod(AGrpName: string; DT1: TDateTime; DT2: TDateTime;
  DS: TDataSet): Boolean;
var
  GroupSheets: PGroupSheets;
  Group      : TMeterGroupItem;
  i, n, iMT  : Integer;
  iRow       : Integer;
  S          : string;
  DT         : TDateTime;
begin
  Result := False;
  Group := MeterGroup.ItemByName[AGrpName];
  if Group = nil then
      Exit;

    // 大量的准备工作
  _PrepareGroupDataSet(Group, GroupSheets, DS);

    // 添加数据
    // 2018-05-29 为加快导出观测数据表的功能，目前假设仪器组的仪器全部处于相同的工作表中，
    // 并共有相同的观测日期
    { todo:需考虑不同工作簿、不同工作表的情况 }
  for iRow := GroupSheets[0].Meter.DataSheetStru.DTStartRow to GroupSheets[0]
    .Sheet.UsedRange.LastRow + 2 do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(GroupSheets[0].Sheet.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
    if TryStrToDateTime(S, DT) = False then
        Continue;
    if DT >= DT2 then
        Break;
    if DT >= DT1 then
    begin
      DS.Append;
      DS.Fields[0].Value := StrToDateTime(S);

            // 添加第一支仪器的备注
            { todo:在填写仪器组备注字段时，这里仅处理了第一支仪器的备注，没有考虑其他仪器的备注字段 }
      DS.Fields[DS.Fields.Count - 1].Value := ExcelIO.GetStrValue(GroupSheets[0].Sheet, iRow,
        GroupSheets[0].Meter.DataSheetStru.AnnoCol);

            // 添加各个仪器数据
      n := 1;
      for iMT := 0 to High(GroupSheets) do // 仪器循环
      begin
        IAppServices.ProcessMessages;
        for i := 0 to GroupSheets[iMT].Meter.PDDefines.Count - 1 do // 字段循环
        begin
          DS.Fields[n].Value := _GetFloatOrNull(GroupSheets[iMT].Sheet, iRow,
            GroupSheets[iMT].Meter.PDColumn(i));
          // DS.Fields[n].Value := ExcelIO.GetFloatValue(GroupSheets[iMT].Sheet, iRow,
          // GroupSheets[iMT].Meter.PDColumn(i));
          inc(n);
        end;
      end;
            // 确认
      DS.Post;
    end;
  end;
    // 收尾工作
  for i := 0 to High(GroupSheets) do
      Dispose(GroupSheets[i]);
  SetLength(GroupSheets, 0);
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetDataIncrement
  Description: 查询指定仪器在指定时间的数据增量
  数据增量包括指定时间测值及上一次测值的增量，月增量两项内容，返回数据格式为
        物理量名|观测日期|间隔天数|DT时间当前值|两测次增量值|月增量值
  参数Values是Variant类型动态数组，当仪器为锚索等单物理量仪器时，Values为1个
  元素，当仪器为多点或平面位移点时，Values是4或更多个元素。每个元素是一个
  VariantArray类型，6元素，格式为上述定义的数据格式。
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetDataIncrement(ADsnName: string; DT: TDateTime;
  var Values: TVariantDynArray): Boolean;
var
  wbk        : IXLSWorkBook;
  sht        : IXLSWorksheet;
  Meter      : TMeterDefine;
  i, iDTStart: Integer;
  iRow, iDays: Integer; // 行号，间隔日期
  iMonRow    : Integer; // 上个月数据所在行
// S, pdName  : String;
  sType     : string;    // 仪器类型
  d, d2, d30: double;    // 当前值，增量，月增量
  procedure ClearValues; // 清理并初始化传入的Values参数
  var
    ii: Integer;
  begin
    if Length(Values) > 0 then
      for ii := Low(Values) to High(Values) do
          VarClear(Values[ii]);
    SetLength(Values, 0);
  end;

begin
  Result := False;
  ClearValues;                         // 清理Values
  sType := GetMeterTypeName(ADsnName); // 获取仪器类型
  Meter := ExcelMeters.Meter[ADsnName];
  iDTStart := Meter.DataSheetStru.DTStartRow;

  if _GetMeterSheet(ADsnName, wbk, sht) = False then // 返回仪器的数据表
      Exit;

  iRow := _LocateDTRow(sht, DT, iDTStart, dloClosest); // 找到指定日期，或最接近的日期所在的行
  if iRow = -1 then
      Exit;

  iMonRow := _LocateDTRow(sht, IncDay(DT, -30), iDTStart, dloClosest); // 一个月前数据所在行

    // 下面开始取数据了
  if (sType = '锚索测力计') or (sType = '锚杆应力计') or (stype='渗压计') or (stype='基岩变形计') then
  begin
    SetLength(Values, 1);
    Values[0] := VarArrayCreate([0, 5], varVariant);
    Values[0][0] := Meter.pdName(0); // 物理量名
    Values[0][1] := ExcelIO.GetDateTimeValue(sht, iRow, 1); // 观测日期
    { TODO -oCharmer -c数据查询 : 此处应当判断数据合法性 }
    Values[0][3] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(0)); // 当前值
    if iRow > iDTStart then // 若当前行不是首行，则可以求上次及月值
    begin
      iDays := DaysBetween(ExcelIO.GetDateTimeValue(sht, iRow, 1),
        ExcelIO.GetDateTimeValue(sht, iRow - 1, 1));
      { todo:此处应当判断数据合法性 }
      d := ExcelIO.GetFloatValue(sht, iRow - 1, Meter.PDColumn(0));
      d2 := Values[0][3] - d;
      d30 := Values[0][3] - ExcelIO.GetFloatValue(sht, iMonRow, Meter.PDColumn(0));
      Values[0][2] := iDays;
      Values[0][4] := d2;
      Values[0][5] := d30;
    end
    else
    begin
      Values[0][2] := 0;
      Values[0][4] := Null;
      Values[0][5] := Null;
    end;
  end
  else if (sType = '多点位移计') then // 目前只考虑4点式多点位移计
  begin
    SetLength(Values, 4);
    for i := 0 to 3 do
    begin
      Values[i] := VarArrayCreate([0, 5], varVariant);
      Values[i][0] := Meter.pdName(i);
      Values[i][1] := ExcelIO.GetDateTimeValue(sht, iRow, 1);
      { todo:此处及以下应当判断数据合法性 }
      Values[i][3] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i)); // 当前值
      if iRow > iDTStart then
      begin
        iDays := DaysBetween(ExcelIO.GetDateTimeValue(sht, iRow, 1),
          ExcelIO.GetDateTimeValue(sht, iRow - 1, 1));
        d := ExcelIO.GetFloatValue(sht, iRow - 1, Meter.PDColumn(i));
        d2 := Values[i][3] - d;
        d30 := Values[i][3] - ExcelIO.GetFloatValue(sht, iMonRow, Meter.PDColumn(i));
        Values[i][2] := iDays;
        Values[i][4] := d2;
        Values[i][5] := d30;
      end
      else
      begin
        Values[i][2] := 0;
        Values[i][4] := Null;
        Values[i][5] := Null;
      end;
    end;
  end;

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : RegistClientDatas
  Description: 注册本数据访问对象
----------------------------------------------------------------------------- }
procedure RegistClientDatas;
begin
  IAppServices.RegisterClientDatas(ThjxDataQuery.Create);
  IHJXClientFuncs := IAppServices.ClientDatas;
end;

initialization

RegistClientDatas;

end.
