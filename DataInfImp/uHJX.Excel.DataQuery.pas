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
  2024-10-11
  修改了_GetBookAndSheet方法，增加了检查工作簿最后编辑时间的逻辑，如果SSWorkBook的
  最后编辑时间早于文件时间，表明工作簿在打开后被编辑，需要重新打开。
  在没有增加这一条逻辑之前，即便修改了文件，程序查询的时候也不会显示最新的数据。
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
  Datasnap.DBClient, System.DateUtils, {MidasLib,} vcl.dialogs, nexcel,
  XLSReadWriteII5, XLSSheetData5 {nExcel保存数据会有问题，因此用这个组件} , Xc12DataStyleSheet5,
  uHJX.Intf.Datas, uHJX.Excel.IO, uHJX.Data.Types, uHJX.Intf.AppServices;

type
  { 黄金峡数据查询对象： }
  ThjxDataQuery = class(TInterfacedObject, IClientFuncs)
  private
    FUseSession: Boolean;
    FErrorMsg: String;
    // FRW5       : TXLSReadWriteII5;
    function _GetBookAndSheet(ADsnName: String; var AWBK: IXLSWorkBook; var ASht: IXLSWorkSheet;
      UseSession: Boolean = True): Boolean;
    procedure _RewriteDatasWithExcel(Datas: PmtDatas);
    /// 用XLSReadWrite5组件将数据写回数据文件会造成灾难性后果，切勿使用！！！
    procedure _RewriteDatasWithXRW5(Datas: PmtDatas);
  public
    constructor Create;
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
    function GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime; var Values: TDoubleDynArray)
      : Boolean; overload;
    function GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime; var Values: TVariantDynArray)
      : Boolean; overload;
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
    function GetGroupPDDatasInPeriod(AGrpName: string; DT1, DT2: TDateTime; DS: TDataSet): Boolean;
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
    { 取回指定仪器在指定时段内的观测次数，其中V为数组，结构如下：
      V[0]: start date;
      V[1]: end date;
      V[2]: Count;
      V[3]: variant array
      V[3][0]: first year, such as 2017
      V[3][1]: 1月观测次数
      V[3][n]: n月观测次数
      V[3][12]: 12月观测次数
      V[4]: variant array
      V[4][1]: secend year, such as 2018
      .....
    }
    procedure GetDataCount2(ADsnName: String; DT1, DT2: TDateTime; var V: TVariantDynArray);
    { 设置DataSet字段别名，对于Excel数据驱动，这个对应表存储在Excel参数文件中，初始化参数时
      已加载到uHJX.Excel.Meters单元的DSNames集合中 }
    procedure SetFieldDisplayName(DS: TDataSet);
    { 返回仪器类型名称 }
    function GetMeterTypeName(ADsnName: string): string;
    { 返回仪器数据增量(不包括测斜孔数据)。返回两测次间增量及月增量。返回值Values的描述参见接口
      函数的注释 }
    function GetDataIncrement(ADsnName: string; DT: TDateTime;
      var Values: TVariantDynArray): Boolean;
    { 返回指定仪器在指定日期间隔期间的增量，返回值为：pdName, DTScale, 日期间隔、测值、增量。
      本函数与GetDataIncrement有差别，本函数没有30天增量，因此只有5列数据； }
    function GetDataIncrement2(ADsnName: String; DT: TDateTime; InteralDays: Integer;
      var Values: TVariantDynArray): Boolean;

    /// <summary>
    /// * 返回指定时间段内指定仪器的指定周期增量，如返回月增量、周增量、季度增量、半年增量、年增量等。
    /// 本函数每次执行仅查询一个传感器的某一物理量的周期增量，若需要查询一堆仪器或仪器的多个物理量，
    /// 则对每支仪器的每个物理量都需要调用本方法一次。
    /// * 若某仪器在观测数据序列中间缺少某时段数据，如缺少4月12日~8月25日期间数据的情况，暂时采用中间
    /// 缺少数据的月份增量为0的方式。最好能在备注中说明这种情况，或采用其他显示方式。
    /// * 各个周期的取值方法：月周期，本周起止时间段一般从上月StartDay到本月的StartDay，除非是采用自
    /// 然月；年周期，从上一年12月StartDay到本年度12月startday，除非是自然年；季度采用自然计时，即从
    /// 季度的1日~下一季度的1日；周周期，取上一周的StartDay~本周的StartDay，除非StartDay为1.
    /// </summary>
    /// <param name="ADsnName">监测仪器设计编号</param>
    /// <param name="APDIndex">待查询的物理量序号，对于多数应用情况，APDIndex=0即可满足要求。但是对于
    /// 某些仪器，如多点位移计，若需要列出各深度测点的周期间隔，则需要用APDIndex逐一指定传感器。或者
    /// 对于水平位移计测点需要查询其他方向、钢筋计查询温度增量等
    /// </param>
    /// <param name="StartDate">查询的起始日期</param>
    /// <param name="EndDate">查询的截止日期</param>
    /// <param name="Values">返回的查询结果，以Variant二维数组方式返回，采用Variant数组的原因在于某
    /// 些数据可能为Null值，若是用double，则无法表示Null。
    /// 每条记录的格式为：
    /// 日期间隔名称 起始日期 截止日期 起始值  截止值  增量  最大值  最小值  变幅  备注
    /// 数据项含义说明：
    /// 1、日期间隔名称：String类型，如“2018年8月”、“2020年第一季度”、“2017年”；
    /// 2、起始日期、截止日期：Double，本次间隔的起止日期。
    /// 3、起始值、截止值、增量：Double 分别对应该周期第一天测值、最后一天测值、两者差值；
    /// 4、最大值、最小值、变幅：Double，分别对应该周期内的最大最小值和两者差值；
    /// </param>
    /// <param name="StartDay">指该周期的起始日期，如月周期的20，指每月20日至次月19日。对于年和季度
    /// 周期的情况也是如此。但是对于周增量，则StartDay=1~7，对应周一~周日，超过7则认为是1。</param>
    /// <param name="Period">0~3，分别对应月、年、季、周</param>
    /// <returns>查询成功为True，否则为False</returns>
    function GetPeriodIncrement(ADsnName: String; APDIndex: Integer; StartDate, EndDate: TDateTime;
      var Values: TVariantDynArray; StartDay: Integer = 20; Period: Integer = 0): Boolean;
    { 取回全部数据，包括观测值 }
    function GetAllDatas(ADsnName: String; ADS: TDataSet): Boolean;
    /// <summary> 2023-06-23
    /// 本方法用于将一条物理量数据回填至数据表。回填数据的来源是过程线，因此数据数组仅有日期和数值
    /// 两项，而且数值可能为空值。返回的数据中包含PDIndex项，指名了是哪一个PD。
    /// 回填时，将数据与工作表数据进行比较，若两者不一致，用回填数据替代，否则不改
    /// </summary>
    procedure RewriteDatas(Datas: PmtDatas);
    /// <summary> 2023-06-27
    /// 从“监测事件.xlsx”中提取指定设计编号的事件
    /// </summary>
    function GetMeterEvents(ADesignName: String): PmtEvents;
    /// <summary> 2023-06-27
    /// 写一条记录
    /// </summary>
    procedure WriteMeterEvent(ADesignName: string; AEventDate, ALogDate: TDateTime; AEvent: string);

    function ErrorMsg: String;
    procedure ClearErrMsg;
    procedure AddErrMsg(Msg: String);
  end;

procedure RegistClientDatas;

implementation

uses
  uHJX.Intf.FunctionDispatcher {uHJX.Excel.Meters} , uHJX.Classes.Meters, uHJX.EnvironmentVariables;

type
  TDateLocateOption = (dloEqual, dloBefore, dloAfter, dloClosest); // 日期查询定位选项：等于，之前，之后，最接近

var
  /// 为了提高访问数据的速度，避免重复创建对象、重复打开上次已经打开的文件，可使用Session模式，调用
  ///  SessionBegin方法，保留上次打开的工作簿对象，当仪器工作簿相同时，不必再次加载数据.
  ///  只使用一个SSWorkbook，还是太保守了，为了提高效率，应该使用多个对象，用文件池的方式
  SSWorkBook: IXLSWorkBook; // 会话期间使用的Workbook
  /// SSWorkBook打开的工作簿的最后修改时间，这个变量用于当采用Session方式时，如果目标工作簿发生了
  /// 改变，则再次访问该工作簿时，需要重新打开，以获取新数据，这个变量在_GetBookAndSheet方法中使用
  ///  这个变量已经整合到Tmyworkbook对象的field中了，不再需要
  /// WBFileAge: LongInt;

  { -----------------------------------------------------------------------------
    Procedure  : _GetFloatOrNull
    Description: 返回浮点数，或NULL
    ----------------------------------------------------------------------------- }
function _GetFloatOrNull(ASht: IXLSWorkSheet; ARow, ACol: Integer): Variant;
begin
  Result := Null;
  if VarIsNumeric(ASht.Cells[ARow, ACol].Value) then
    Result := ASht.Cells[ARow, ACol].Value;
end;

{ 返回仪器的工作簿及工作表对象 }
function ThjxDataQuery._GetBookAndSheet(ADsnName: string; var AWBK: IXLSWorkBook;
  var ASht: IXLSWorkSheet; UseSession: Boolean = True): Boolean;
var
  Meter: TMeterDefine;
begin
  Result := False;
  // AWBK := nil;
  // ASHT := nil;
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
  begin
    AddErrMsg('未找到' + ADsnName);
    Exit;
  end;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
  begin
    AddErrMsg('未找到' + ADsnName + '的数据表');
    Exit;
  end;
  { todo:这里增加判断，如果AWBK就是仪器的工作簿，则无需再经过打开的步骤了 }
  if UseSession then
  begin
    if SSWorkBook = nil then
      SSWorkBook := TMyWorkbook.Create;
    AWBK := SSWorkBook;
  end
  else if not Assigned(AWBK) then
    AWBK := TMyWorkbook.Create;

  /// 如果不是同一个工作簿，或者是同一个工作簿但是编辑时间不同，需要重新打开。
  /// 否则，直接使用原有的工作簿。采用比较File Age的方式，可以一直使用Session模式，事实上，在本单元所有调用本方法的
  /// 地方，都已经默认采用了Session·模式，因此，这里不需要再判断是否是Session模式了。
  /// 下一步的优化，就是采用文件池的方式，将所有打开过的工作簿都保留下来，下次直接使用即可。
  if (TMyWorkbook(AWBK).FullName <> Meter.DataBook) 
    or (TmyWorkBook(AWBK).FileAge <> FileAge(Meter.DataBook)) then
  begin
    if not ExcelIO.OpenWorkbook(AWBK, Meter.DataBook) then
    begin
      AddErrMsg('未能打开' + ADsnName + '的数据工作簿' + Meter.DataBook);
      Exit;
    end
  end;

  /// 到这里，已经打开了WorkBook，更新WBFileAge：
  ///  现在TmyWorkbook自带FileAge field，可以自己更新了，这个变量取消
  /// wbfileage := Fileage(meter.DataBook);

  ASht := ExcelIO.GetSheet(AWBK, Meter.DataSheet);
  if ASht = nil then
  begin
    AddErrMsg('打开' + ADsnName + '的数据表' + Meter.DataSheet + '出错');
    Exit;
  end;

  { 走到这里，可以返回True了 }
  Result := True;
end;

{ 快速定位指定日期所在的行，或最接近的日期所在行，返回值为行数。
  参数：
  StartRow:       仪器数据起始行，也是查找的起始行；
  LacateOption:   0:必须等于该日期；1:该日期的前一个；2:最接近该日期，无论前后。
}
function _LocateDTRow(Sheet: IXLSWorkSheet; DT: TDateTime; DTStartRow: Integer;
  LocateOption: TDateLocateOption = dloEqual): Integer;
var
  DT1, DT2: TDateTime;
  d1, d2: Integer;
  iRow: Integer;
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
  S := Trim(ExcelIO.GetStrValue(Sheet, iStart, 1));
  if S = '' then
    Exit;

  DT1 := ExcelIO.GetDateTimeValue(Sheet, iStart, 1); // StrToDateTime(S);
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
    S := Trim(ExcelIO.GetStrValue(Sheet, iRow, 1));
    if S = '' then
      Continue
    else
      Break;
  end;
  DT2 := ExcelIO.GetDateTimeValue(Sheet, iRow, 1); // StrToDateTime(S);
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
  i: Integer;
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

// 根据仪器数据定义，创建观测量和物理量字段表
procedure _CreateFieldsFromDataDefines(DS: TDataSet; AMDDefines, APDDefines: TDataDefines);
var
  i: Integer;
  DF: TFieldDef;
begin
  TClientDataSet(DS).FieldDefs.Clear;
  TClientDataSet(DS).IndexDefs.Clear;
  DF := DS.FieldDefs.AddFieldDef;
  DF.Name := 'DTScale';
  DF.DataType := ftDateTime;
  DF.DisplayName := '观测日期';
  // 观测量
  for i := 0 to AMDDefines.Count - 1 do
  begin
    DF := DS.FieldDefs.AddFieldDef;
    DF.Name := 'MD' + IntToStr(i + 1);
    DF.DisplayName := AMDDefines.Items[i].Name;
    DF.DataType := ftFloat;
  end;
  // 物理量
  for i := 0 to APDDefines.Count - 1 do
  begin
    DF := DS.FieldDefs.AddFieldDef;
    DF.Name := 'PD' + IntToStr(i + 1);
    DF.DisplayName := APDDefines.Items[i].Name;
    DF.DataType := ftFloat;
  end;
  DF := DS.FieldDefs.AddFieldDef;
  DF.Name := 'Annotation';
  DF.DisplayName := '备注';
  DF.DataType := ftWideString;
  TClientDataSet(DS).IndexDefs.Add('IndexDT', 'DTScale', []);
end;

// 设置字段displaylabel
procedure _SetPDFieldsDisplayName(DS: TDataSet; APDDefines: TDataDefines);
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

procedure _SetFieldsDisplayName(DS: TDataSet; AMDDefines, APDDefines: TDataDefines;
  ANoCol: Integer);
var
  i, n: Integer;
  S: String;
begin
  with DS as TClientDataSet do
    Fields[0].DisplayLabel := '观测日期';

  for i := 1 to DS.FieldCount - 1 do
  begin
    DS.Fields[i].DisplayLabel := DS.FieldDefs[i].DisplayName;
    S := DS.FieldDefs[i].Name; // 字段名，MD + Index，或PD+Index
    if S <> 'Annotation' then
      n := StrToInt(Copy(S, 3, length(S) - 2)); // 序号
    S := Copy(S, 1, 2);
    // 为提高读取数据的速度，直接在这里将每个数据项的列号写到Field.Tag中，省的读
    // 的时候再去访问DataDefine.Column属性
    if S = 'MD' then
    begin
      DS.Fields[i].Tag := AMDDefines.Items[n - 1].Column;
      DS.Fields[i].DisplayLabel := AMDDefines.Items[n - 1].Name;
    end
    else if S = 'PD' then
    begin
      DS.Fields[i].Tag := APDDefines.Items[n - 1].Column;
      DS.Fields[i].DisplayLabel := APDDefines.Items[n - 1].Name;
    end
    else
    begin
      DS.Fields[i].Tag := ANoCol;
      DS.Fields[i].DisplayLabel := '备注';
    end;

    if DS.Fields[i].DataType = ftFloat then
      (DS.Fields[i] as TNumericField).DisplayFormat := '0.00'
    else if DS.Fields[i].DataType = ftDateTime then
      (DS.Fields[i] as TDateTimeField).DisplayFormat := 'yyyy-mm-dd hh:mm';

  end;
  // 如果最后一个字段名为Annotation，则为备注字段
  with DS.Fields[DS.FieldCount - 1] do
    if Name = 'Annotation' then
    begin
      DisplayLabel := '备注';
      Tag := ANoCol;
    end;

end;

// 根据仪器组定义创建数据集字段
procedure _CreateFieldsFromGroup(DS: TDataSet; AGroup: TMeterGroupItem);
var
  i, j: Integer;
  DF: TFieldDef;
  MT: TMeterDefine;
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

constructor ThjxDataQuery.Create;
begin
  inherited Create;
  (IAppServices.FuncDispatcher as IFunctionDispatcher).RegistFuncRewriteData(RewriteDatas);
  // FRW5 := TXLSReadWriteII5.Create(nil);
  // FRW5.DirectRead := False;
  // FRW5.DirectWrite := False;
  //WBFileAge := -1;
end;

destructor ThjxDataQuery.Destroy;
begin
  // FRW5.Free;
  inherited;
end;

procedure ThjxDataQuery.SessionBegin;
begin
  FUseSession := True;
  SSWorkBook := TMyWorkbook.Create;
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
  Meter: TMeterDefine;
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  iCount, i: Integer;
  iRow: Integer;
  S: String;
begin
  Result := False;
  SetLength(Values, 0);

  Meter := ExcelMeters.Meter[ADsnName];
  (*
    if Meter = nil then Exit;

    if (Meter.DataBook = '') or (Meter.DataSheet = '') then Exit;

    if FUseSession then wbk := SSWorkBook
    else wbk := TMyWorkbook.Create;

    if TMyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then Exit;

    sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
    if sht = nil then Exit;
  *)
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
    Exit;

  iCount := Meter.PDDefines.Count + 1; // 物理量+观测日期
  SetLength(Values, iCount);
  Values[0] := 0; // 观测日期设置为0，若没有数据，则不填入，调用者通过观测日期是否为0判断是否有观测数据。

  // 下面开始倒序查找数据
  for iRow := Sht.UsedRange.LastRow + 5 downto Meter.DataSheetStru.BaseLine { .DTStartRow } do
  begin
    IAppServices.ProcessMessages;
    S := Trim(VarToStr(Sht.Cells[iRow, 1].Value));
    if S = '' then
      Continue;
    // 观测日期
    Values[0] := ExcelIO.GetDateTimeValue(Sht, iRow, 1);

    // 备注 由于Values是Double类型数组，无法填入备注
    { with Meter.DataSheetStru do
      if AnnoCol > 0 then
      Values[iCount - 1] := ExcelIO.GetStrValue(sht, iRow, Meter.DataSheetStru.AnnoCol); }

    // 各个物理量
    for i := 0 to Meter.PDDefines.Count - 1 do
      Values[i + 1] := ExcelIO.GetFloatValue(Sht, iRow, Meter.PDColumn(i));
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
  Meter: TMeterDefine;
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  iCount, i: Integer;
  iRow: Integer;
  S: String;
begin
  Result := False;
  for i := Low(Values) to High(Values) do
    VarClear(Values[i]);
  SetLength(Values, 0);

  Meter := ExcelMeters.Meter[ADsnName];
  (*
    if Meter = nil then Exit;

    if (Meter.DataBook = '') or (Meter.DataSheet = '') then Exit;

    if FUseSession then wbk := SSWorkBook
    else wbk := TMyWorkbook.Create;

    if TMyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then Exit;

    sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
    if sht = nil then Exit;
  *)
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
    Exit;

  iCount := Meter.PDDefines.Count + 1; // 物理量+观测日期
  SetLength(Values, iCount);
  Values[0] := 0; // 观测日期设置为0，若没有数据，则不填入，调用者通过观测日期是否为0判断是否有观测数据。

  // 下面开始倒序查找数据
  for iRow := Sht.UsedRange.LastRow + 5 downto Meter.DataSheetStru.BaseLine { .DTStartRow } do
  begin
    IAppServices.ProcessMessages;
    S := Trim(VarToStr(Sht.Cells[iRow, 1].Value));
    if S = '' then
      Continue;
    // 观测日期
    Values[0] := ExcelIO.GetDateTimeValue(Sht, iRow, 1);

    // 备注 由于Values是Double类型数组，无法填入备注
    { with Meter.DataSheetStru do
      if AnnoCol > 0 then
      Values[iCount - 1] := ExcelIO.GetStrValue(sht, iRow, Meter.DataSheetStru.AnnoCol); }

    // 各个物理量
    for i := 0 to Meter.PDDefines.Count - 1 do
      Values[i + 1] := _GetFloatOrNull(Sht, iRow, Meter.PDColumn(i));
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
  Meter: TMeterDefine;
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  iCount, i: Integer;
  iRow: Integer;
  // S        : String;
  // DT1      : TDateTime;
begin
  Result := False;
  SetLength(Values, 0);

  Meter := ExcelMeters.Meter[ADsnName];
  (*
    if Meter = nil then
    Exit;

    if (Meter.DataBook = '') or (Meter.DataSheet = '') then
    Exit;

    if FUseSession then
    wbk := SSWorkBook
    else
    wbk := TMyWorkbook.Create;

    if TMyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
    Exit;

    sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
    if sht = nil then
    Exit;
  *)
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
    Exit;

  iCount := Meter.PDDefines.Count + 1; // 物理量+观测日期+备注
  SetLength(Values, iCount);
  Values[0] := 0; // 观测日期设置为0，若没有数据，则不填入，调用者通过观测日期是否为0判断是否有观测数据。
  iRow := _LocateDTRow(Sht, DT, Meter.DataSheetStru.BaseLine { .DTStartRow } , dloBefore);
  if (iRow <> -1) and (iRow > Meter.DataSheetStru.BaseLine { .DTStartRow } ) then
  begin
    Dec(iRow); // 早一行
    Values[0] := ExcelIO.GetDateTimeValue(Sht, iRow, 1);
    for i := 0 to Meter.PDDefines.Count - 1 do
      Values[i + 1] := ExcelIO.GetFloatValue(Sht, iRow, Meter.PDColumn(i));
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
  Meter: TMeterDefine;
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  iCount, i: Integer;
  iRow: Integer;
  // S        : String;
  // DT1      : TDateTime;
begin
  Result := False;
  for i := Low(Values) to High(Values) do
    VarClear(Values[i]);
  SetLength(Values, 0);

  Meter := ExcelMeters.Meter[ADsnName];
  (*
    if Meter = nil then
    Exit;

    if (Meter.DataBook = '') or (Meter.DataSheet = '') then
    Exit;

    if FUseSession then
    wbk := SSWorkBook
    else
    wbk := TMyWorkbook.Create;

    if TMyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
    Exit;

    sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
    if sht = nil then
    Exit;
  *)
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
    Exit;

  iCount := Meter.PDDefines.Count + 1; // 物理量+观测日期+备注
  SetLength(Values, iCount);
  Values[0] := 0; // 观测日期设置为0，若没有数据，则不填入，调用者通过观测日期是否为0判断是否有观测数据。
  iRow := _LocateDTRow(Sht, DT, Meter.DataSheetStru.BaseLine { .DTStartRow } , dloBefore);
  if (iRow <> -1) and (iRow > Meter.DataSheetStru.BaseLine { .DTStartRow } ) then
  begin
    Dec(iRow); // 早一行
    Values[0] := ExcelIO.GetDateTimeValue(Sht, iRow, 1);
    for i := 0 to Meter.PDDefines.Count - 1 do
      Values[i + 1] := _GetFloatOrNull(Sht, iRow, Meter.PDColumn(i));
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
  var Values: TDoubleDynArray; DTDelta: Integer = 0): Boolean;
var
  Meter: TMeterDefine;
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  iCount: Integer;
  iRow, iLRow: Integer;
  // S           : String;
  DT1: TDateTime;
  dLast, dThis: double;

  procedure SetData(ARow: Integer);
  var
    ii: Integer;
  begin
    Values[0] := ExcelIO.GetDateTimeValue(Sht, ARow, 1);
    { with Meter.DataSheetStru do
      if AnnoCol > 0 then
      Values[iCount - 1] := ExcelIO.GetStrValue(sht, ARow, AnnoCol); }

    for ii := 0 to Meter.PDDefines.Count - 1 do
      Values[ii + 1] := ExcelIO.GetFloatValue(Sht, ARow, Meter.PDColumn(ii));
  end;

begin
  Result := False;
  SetLength(Values, 0);

  Meter := ExcelMeters.Meter[ADsnName];
  (*
    if Meter = nil then
    Exit;

    if (Meter.DataBook = '') or (Meter.DataSheet = '') then
    Exit;

    if FUseSession then
    wbk := SSWorkBook
    else
    wbk := TMyWorkbook.Create;

    if TMyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
    Exit;

    sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
    if sht = nil then
    Exit;
  *)
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
    Exit;

  iCount := Meter.PDDefines.Count + 1; // 物理量+观测日期+备注
  SetLength(Values, iCount);
  Values[0] := 0; // 观测日期设置为0，若没有数据，则不填入，调用者通过观测日期是否为0判断是否有观测数据。
  // 倒序查找
  dLast := -10000;
  dThis := 10000;
  iLRow := 0;

  iRow := _LocateDTRow(Sht, DT, Meter.DataSheetStru.BaseLine { .DTStartRow } , dloClosest);
  if iRow = -1 then
    Exit;

  DT1 := ExcelIO.GetDateTimeValue(Sht, iRow, 1);
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
  Meter: TMeterDefine;
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  iCount, i: Integer;
  iRow, iLRow: Integer;
  // S           : String;
  DT1: TDateTime;
  dLast, dThis: double;

  procedure SetData(ARow: Integer);
  var
    ii: Integer;
  begin
    Values[0] := ExcelIO.GetDateTimeValue(Sht, ARow, 1);
    { with Meter.DataSheetStru do
      if AnnoCol > 0 then
      Values[iCount - 1] := ExcelIO.GetStrValue(sht, ARow, AnnoCol); }

    for ii := 0 to Meter.PDDefines.Count - 1 do
      Values[ii + 1] := { ExcelIO.GetFloatValue } _GetFloatOrNull(Sht, ARow, Meter.PDColumn(ii));
  end;

begin
  Result := False;
  for i := low(Values) to high(Values) do
    VarClear(Values[i]);
  SetLength(Values, 0);

  Meter := ExcelMeters.Meter[ADsnName];
  (*
    if Meter = nil then
    Exit;

    if (Meter.DataBook = '') or (Meter.DataSheet = '') then
    Exit;

    if FUseSession then
    wbk := SSWorkBook
    else
    wbk := TMyWorkbook.Create;

    if TMyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
    Exit;

    sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
    if sht = nil then
    Exit;
  *)
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
    Exit;

  iCount := Meter.PDDefines.Count + 1; // 物理量+观测日期+备注
  SetLength(Values, iCount);
  Values[0] := 0; // 观测日期设置为0，若没有数据，则不填入，调用者通过观测日期是否为0判断是否有观测数据。
  // 倒序查找
  dLast := -10000;
  dThis := 10000;
  iLRow := 0;

  iRow := _LocateDTRow(Sht, DT, Meter.DataSheetStru.BaseLine { .DTStartRow } , dloClosest);
  if iRow = -1 then
    Exit;

  DT1 := ExcelIO.GetDateTimeValue(Sht, iRow, 1);
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
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  Meter: TMeterDefine;
  S: string;
  iRow, i: Integer;
  DT: TDateTime;
  AnnoCol: Integer;
begin
  Result := False;
  Meter := ExcelMeters.Meter[ADsnName];
  (*
    if Meter = nil then
    Exit;
    if (Meter.DataBook = '') or (Meter.DataSheet = '') then
    Exit;

    if FUseSession then
    wbk := SSWorkBook
    else
    wbk := TMyWorkbook.Create;

    if ExcelIO.OpenWorkbook(wbk, Meter.DataBook) = False then
    Exit;
    sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
    if sht = nil then
    Exit;
  *)
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
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
  _SetPDFieldsDisplayName(DS, Meter.PDDefines);

  if Meter.DataSheetStru.AnnoCol > 0 then
    AnnoCol := Meter.DataSheetStru.AnnoCol
  else
    AnnoCol := 0;

  for iRow := Meter.DataSheetStru.BaseLine { .DTStartRow } to Sht.UsedRange.LastRow + 1 do
  begin
    IAppServices.ProcessMessages;
    S := Trim(VarToStr(Sht.Cells[iRow, 1].Value));
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
        DS.Fields[DS.Fields.Count - 1].Value := ExcelIO.GetStrValue(Sht, iRow, AnnoCol);
      // 物理量
      for i := 0 to Meter.PDDefines.Count - 1 do
        DS.Fields[i + 1].Value := _GetFloatOrNull(Sht, iRow, Meter.PDColumn(i));
      // DS.Fields[i + 1].Value := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
      DS.Post;
    end;
  end;
  Result := True;
end;

function ThjxDataQuery.GetAllPDDatas(ADsnName: string; DS: TDataSet): Boolean;
var
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  Meter: TMeterDefine;
  S: string;
  iRow, i: Integer;
  AnnoCol: Integer;
  function __GetFloatValue(iRow, iCol: Integer): Variant;
  var
    sVar: String;
    d: double;
  begin
    Result := Null;
    // sht.Cells[irow,icol].Value
    if VarIsNumeric(Sht.Cells[iRow, iCol].Value) then
      Result := Sht.Cells[iRow, iCol].Value;
  end;

begin
  Result := False;
  Meter := ExcelMeters.Meter[ADsnName];
  (*
    if Meter = nil then
    Exit;
    if (Meter.DataBook = '') or (Meter.DataSheet = '') then
    Exit;

    if FUseSession then
    wbk := SSWorkBook
    else
    wbk := TMyWorkbook.Create;

    if ExcelIO.OpenWorkbook(wbk, Meter.DataBook) = False then
    Exit;
    sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
    if sht = nil then
    Exit;
  *)
  /// 2024-10-11 添加FUseSession参数，这样修改了Excel文件后，再次调用时可以获取新数据
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
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
  _SetPDFieldsDisplayName(DS, Meter.PDDefines);

  if Meter.DataSheetStru.AnnoCol > 0 then
    AnnoCol := Meter.DataSheetStru.AnnoCol
  else
    AnnoCol := 0;

  // 查询、添加数据
  // for iRow := Meter.DataSheetStru.DTStartRow to sht.UsedRange.LastRow + 2 do
  // 首行从初值行开始2022-05-01
  for iRow := Meter.DataSheetStru.BaseLine to Sht.UsedRange.LastRow + 2 do
  begin
    IAppServices.ProcessMessages;
    S := Trim(VarToStr(Sht.Cells[iRow, 1].Value));
    if S = '' then
      Continue;
    // ---------------------
    DS.Append;
    DS.Fields[0].Value := ExcelIO.GetDateTimeValue(Sht, iRow, 1); // StrToDateTime(S);
    if AnnoCol > 0 then
      DS.Fields[DS.Fields.Count - 1].Value := ExcelIO.GetStrValue(Sht, iRow, AnnoCol);

    for i := 0 to Meter.PDDefines.Count - 1 do
      DS.Fields[i + 1].Value := __GetFloatValue(iRow, Meter.PDColumn(i));
    // { todo:BUG!!当单元格没有值或不是数值时，此函数将返回0，而不是空值 }
    // DS.Fields[i + 1].value := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
    DS.Post;
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetAllDatas
  Description: 取回全部数据，包括观测数据
  ----------------------------------------------------------------------------- }
function ThjxDataQuery.GetAllDatas(ADsnName: string; ADS: TDataSet): Boolean;
var
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  Meter: TMeterDefine;
  S: string;
  iRow, i: Integer;
  AnnoCol: Integer;
  function __GetNummericFieldValue(iCol: Integer): Variant;
  var
    SS: String;
  begin
    Result := Null;
    try
      Result := VarAsType(Sht.Cells[iRow, iCol].Value, varDouble);
    except
      Result := Null;
    end;
  end;

begin
  Result := False;
  Meter := ExcelMeters.Meter[ADsnName];

  /// 增加fusesession
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
    Exit;

  // 运行到这里，可以尝试创建DataSet、读取数据了
  // 如果DS为空，则创建之
  if ADS = nil then
    ADS := TClientDataSet.Create(nil)
  else
  begin
    if ADS.Active then
      ADS.Close;
    ADS.FieldDefs.Clear;
  end;
  // 给DS中添加字段
  _CreateFieldsFromDataDefines(ADS, Meter.DataSheetStru.MDs, Meter.PDDefines);
  { 这里要注意，尽量使用TClientDataset！！！ }
  TClientDataSet(ADS).CreateDataSet;
  _SetFieldsDisplayName(ADS, Meter.DataSheetStru.MDs, Meter.PDDefines, Meter.DataSheetStru.AnnoCol);

  if Meter.DataSheetStru.AnnoCol > 0 then
    AnnoCol := Meter.DataSheetStru.AnnoCol
  else
    AnnoCol := 0;

  for iRow := Meter.DataSheetStru.BaseLine to Sht.UsedRange.LastRow + 2 do
  begin
    IAppServices.ProcessMessages;
    S := Trim(VarToStr(Sht.Cells[iRow, 1].Value)); // 取日期
    if S = '' then // 如果为空，则下一行
      Continue;
    // ---------------------
    ADS.Append;
    ADS.Fields[0].Value := ExcelIO.GetDateTimeValue(Sht, iRow, 1); // StrToDateTime(S);
    if AnnoCol > 0 then
      ADS.Fields[ADS.Fields.Count - 1].Value := ExcelIO.GetStrValue(Sht, iRow, AnnoCol);

    for i := 1 to ADS.FieldCount - 1 do
    begin
      // Cell.Value的值，可能是Null，可能是''，可能是数字
      if (ADS.Fields[i].DataType = ftFloat) then
        ADS.Fields[i].Value := __GetNummericFieldValue(ADS.Fields[i].Tag)
      else
        ADS.Fields[i].Value := Sht.Cells[iRow, ADS.Fields[i].Tag].Value; // Field.Tag是列号
    end;

    (*
      for i := 0 to Meter.DataSheetStru.MDs.Count - 1 do
      ADS.Fields[i + 1].Value := sht.Cells[iRow, Meter.DataSheetStru.MDs.Items[i].Column].Value;

      for i := 0 to Meter.PDDefines.Count - 1 do
      ADS.Fields[i + 1].Value := sht.Cells[iRow, Meter.PDColumn(i)].Value;

    *)
    // { todo:BUG!!当单元格没有值或不是数值时，此函数将返回0，而不是空值 }
    // DS.Fields[i + 1].value := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
    ADS.Post;
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
  Meter: TMeterDefine;
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  chkDate: TevCheckDate;
  iRow: Integer;
  S: String;
  PD1: double;
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
  (*
    if Meter = nil then
    Exit;
    if (Meter.DataBook = '') or (Meter.DataSheet = '') then
    Exit;
    if FUseSession then
    wbk := SSWorkBook
    else
    wbk := TMyWorkbook.Create;

    if TMyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
    Exit;
    sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
    if sht = nil then
    Exit;
  *)
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
    Exit;

  { set date for check }
  EVData.ID := Meter.DesignName;
  for iRow := Sht.UsedRange.LastRow + 2 downto Meter.DataSheetStru.BaseLine { .DTStartRow } do
  begin
    IAppServices.ProcessMessages;
    S := Trim(VarToStr(Sht.Cells[iRow, 1].Value));
    if S = '' then
      Continue;
    if TryStrToDateTime(S, dtScale) = False then
      Continue;

    PD1 := ExcelIO.GetFloatValue(Sht, iRow, Meter.PDColumn(0));

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
  Meter: TMeterDefine;
  i, n: Integer;
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  chkDate: TevCheckDate;
  iRow: Integer;
  S: String;
  dtScale: TDateTime;
  // 释放调用者提供的evdatas占用的内存，不同的仪器特征值数量不同
  procedure ReleaseEVDatas;
  var
    ii: Integer;
  begin
    if length(EVDatas) > 0 then
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
    d: double;
    iCol: Integer;
  begin
    iCol := Meter.PDColumn(EVDatas[iev].PDIndex);
    d := ExcelIO.GetFloatValue(Sht, iRow, iCol);

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
  (*
    if Meter = nil then
    Exit;

    if (Meter.DataBook = '') or (Meter.DataSheet = '') then
    Exit;
    if FUseSession then
    wbk := SSWorkBook
    else
    wbk := TMyWorkbook.Create;

    if TMyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
    Exit;
    sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
    if sht = nil then
    Exit;
  *)
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
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

  for iRow := Sht.UsedRange.LastRow + 1 downto Meter.DataSheetStru.BaseLine { .DTStartRow } do
  begin
    IAppServices.ProcessMessages;
    S := Trim(VarToStr(Sht.Cells[iRow, 1].Value));
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
        EVDatas[i].CurValue := ExcelIO.GetFloatValue(Sht, iRow, Meter.PDColumn(EVDatas[i].PDIndex));
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
  Meter: TMeterDefine;
  i, n: Integer;
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  chkDate: TevCheckDate;
  iRow: Integer;
  Row1, Row2: Integer; // 指定日期起止行
  S: String;
  dtScale: TDateTime;
  // 释放调用者提供的evdatas占用的内存，不同的仪器特征值数量不同
  procedure ReleaseEVDatas;
  var
    ii: Integer;
  begin
    if length(EVDatas) > 0 then
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
    d: double;
    iCol: Integer;
  begin
    iCol := Meter.PDColumn(EVDatas[iev].PDIndex);
    d := ExcelIO.GetFloatValue(Sht, iRow, iCol);
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
  (*
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
    wbk := TMyWorkbook.Create;

    if TMyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
    Exit;
    sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
    if sht = nil then
    Exit;
  *)
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
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
  Row1 := _LocateDTRow(Sht, DT1, Meter.DataSheetStru.BaseLine { .DTStartRow } , dloClosest);
  Row2 := _LocateDTRow(Sht, DT2, Meter.DataSheetStru.BaseLine { .DTStartRow } , dloBefore);
  // 如果没有查找到合适的行，则退出
  if (Row1 = -1) then
  begin
    Showmessage(ADsnName + '：未找到适合的起始日期，可能起始行设置不正确，或日期不正确，或没有数据');
    Exit;
  end;

  if (Row2 = -1) then
  begin
    Showmessage(ADsnName + '：未找到适合的截止日期，可能起始行设置不正确，或日期不正确，或没有数据');
    Exit;
  end;

  // for iRow := sht.UsedRange.LastRow + 1 downto Meter.DataSheetStru.DTStartRow do
  for iRow := Row2 downto Row1 do
  begin
    IAppServices.ProcessMessages;
    S := Trim(VarToStr(Sht.Cells[iRow, 1].Value));
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
        EVDatas[i].CurValue := ExcelIO.GetFloatValue(Sht, iRow, Meter.PDColumn(EVDatas[i].PDIndex));
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
  Meter: TMeterDefine;
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  iRow: Integer;
  S: String;
  dtScale: TDateTime;
begin
  Result := 0;
  Meter := ExcelMeters.Meter[ADsnName];
  // 前期准备工作-----------------------------
  (*
    if Meter = nil then
    Exit;
    if (Meter.DataBook = '') or (Meter.DataSheet = '') then
    Exit;
    if FUseSession then
    wbk := SSWorkBook
    else
    wbk := TMyWorkbook.Create;

    if TMyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
    Exit;
    sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
    if sht = nil then
    Exit;
  *)
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
    Exit;

  // -------------------------------------------
  for iRow := Meter.DataSheetStru.BaseLine { .DTStartRow } to Sht.UsedRange.LastRow + 1 do
  begin
    IAppServices.ProcessMessages;
    S := Trim(VarToStr(Sht.Cells[iRow, Meter.DataSheetStru.DTStartCol].Value));
    if S = '' then
      Continue;
    if TryStrToDate(S, dtScale) then
      if (dtScale >= DT1) and (dtScale <= DT2) then
        inc(Result);
  end;
end;

{ 取回指定仪器在指定时段内的观测次数 }
procedure ThjxDataQuery.GetDataCount2(ADsnName: string; DT1: TDateTime; DT2: TDateTime;
  var V: TVariantDynArray);
var
  i, iCol: Integer;
  Meter: TMeterDefine;
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  iRow: Integer;
  S: string;
  dtScale: TDateTime;

  dMin, dMax: TDateTime;

  iYear, iMonth: Integer;
  nYear, nMonth: Integer; // dtscale的年，月
  iCount: Integer;
begin
  { 先清理V }
  if length(V) > 3 then
  begin
    V[0] := '';
    V[1] := '';
    V[2] := 0;
    for i := 3 to High(V) do
      VarClear(V[i]);
  end;
  SetLength(V, 3);
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
  begin
    SetLength(V, 0);
    Exit;
  end;
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
    Exit;

  dMin := DT1;
  if DT2 = 0 then
    dMax := Now
  else
    dMax := DT2;

  iCol := Meter.DataSheetStru.DTStartCol;
  iYear := 0;
  iMonth := 1;
  V[2] := 0; // 总次数为0;
  for iRow := Meter.DataSheetStru.DTStartRow to Sht.UsedRange.LastRow + 1 do
  begin
    IAppServices.ProcessMessages;
    S := Trim(VarToStr(Sht.Cells[iRow, iCol].Value));
    if S = '' then
      Continue;
    if TryStrToDateTime(S, dtScale) then
    begin
      // 判断是否在时间范围内
      if (dtScale >= DT1) and (dtScale <= DT2) then
      begin
        nYear := YearOf(dtScale);
        nMonth := MonthOf(dtScale);
        if iYear = 0 then
          V[0] := dtScale; // start date
        // 是否新一年？
        if iYear <> nYear then
        begin
          iMonth := 0; // 月份为0
          SetLength(V, length(V) + 1);
          V[High(V)] := VarArrayCreate([0, 13], varInteger);
          V[high(V)][0] := nYear; // 年份
          V[High(V)][1] := 0; // 年统计为0
          iYear := nYear;
        end;
        // 是否新月
        if iMonth <> nMonth then
          iMonth := nMonth;
        V[High(V)][1] := V[high(V)][1] + 1; // 年统计+1
        V[high(V)][iMonth + 1] := V[high(V)][iMonth + 1] + 1; // 月统计+1
        V[2] := V[2] + 1; // 总次数+1
        V[1] := dtScale; // 更新截止日期
      end;
    end;
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
    Sheet: IXLSWorkSheet;
  end;

  PGroupMeterSheet = ^TGroupMeterSheet;
  PGroupSheets = array of PGroupMeterSheet;

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
  bwbk: Boolean;
  i, j: Integer;
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
      AGrpSheets[0].WbkBook := TMyWorkbook.Create;
      ExcelIO.OpenWorkbook(AGrpSheets[0].WbkBook, Meter.DataBook);
      AGrpSheets[0].Sheet := ExcelIO.GetSheet(AGrpSheets[0].WbkBook, Meter.DataSheet);
    end
    else // 对于其他仪器，检查同组仪器的工作簿是否相同、工作表是否相同，如果相同则引用否则打开
    begin
      for j := 0 to i do
      begin
        IAppServices.ProcessMessages;
        if TMyWorkbook(AGrpSheets[j].WbkBook).FullName = Meter.DataBook then
        begin
          AGrpSheets[i].WbkBook := AGrpSheets[j].WbkBook;
          bwbk := True; // 已有工作簿
          Break;
        end;
      end;
      if not bwbk then
      begin
        AGrpSheets[i].WbkBook := TMyWorkbook.Create;
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
  Group: TMeterGroupItem;
  i, j, iRow: Integer;
  k, n: Integer;
  S, Msg: String;
  DT: TDateTime;
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
  { for iRow := GroupSheets[0].Meter.DataSheetStru.DTStartRow to GroupSheets[0]
    .Sheet.UsedRange.LastRow + 2 do }
  for iRow := GroupSheets[0].Meter.DataSheetStru.BaseLine to GroupSheets[0]
    .Sheet.UsedRange.LastRow + 2 do
  begin
    IAppServices.ProcessMessages;
    S := Trim(VarToStr(GroupSheets[0].Sheet.Cells[iRow, 1].Value));
    if S = '' then
      Continue;
    // 判断S是否是合法的日期字符串，若不是合法的日期格式，则提示用户后继续，但放弃本行的处理
    if TryStrToDateTime(S, DT) = False then
    begin
      Msg := GroupSheets[0].Sheet.Name;
      Msg := Format('工作表%s的第%d行第%d列的内容“%s”不是合法的日期格式，请检查。', [Msg, iRow, 1, S]);
      Showmessage(Msg);
      Continue;
    end;

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
  Group: TMeterGroupItem;
  i, n, iMT: Integer;
  iRow: Integer;
  S: string;
  DT: TDateTime;
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
  for iRow := GroupSheets[0].Meter.DataSheetStru.BaseLine { .DTStartRow } to GroupSheets[0]
    .Sheet.UsedRange.LastRow + 2 do
  begin
    IAppServices.ProcessMessages;
    S := Trim(VarToStr(GroupSheets[0].Sheet.Cells[iRow, 1].Value));
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
  每行数组各个元素：0-物理量名；1-当前值观测日期；2-两次观测间隔天数；3-当前值；
  4-与上次观测的差值；5-30天差值
  ----------------------------------------------------------------------------- }
function ThjxDataQuery.GetDataIncrement(ADsnName: string; DT: TDateTime;
  var Values: TVariantDynArray): Boolean;
var
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  Meter: TMeterDefine;
  i, iDTStart: Integer;
  iRow, iDays: Integer; // 行号，间隔日期
  iMonRow: Integer; // 上个月数据所在行
  k: Integer; // 用于平面变形测点物理量序号
  // S, pdName  : String;
  sType: string; // 仪器类型
  d, d2, d30: double; // 当前值，增量，月增量
  kIdx: set of byte; // 特征值列的序号集合，假设监测仪器的特征值数量不会多于127
  procedure ClearValues; // 清理并初始化传入的Values参数
  var
    ii: Integer;
  begin
    if length(Values) > 0 then
      for ii := Low(Values) to High(Values) do
        VarClear(Values[ii]);
    SetLength(Values, 0);
  end;

begin
  Result := False;
  ClearValues; // 清理Values
  sType := GetMeterTypeName(ADsnName); // 获取仪器类型
  Meter := ExcelMeters.Meter[ADsnName];
  iDTStart := Meter.DataSheetStru.BaseLine { .DTStartRow };

  if _GetBookAndSheet(ADsnName, Wbk, Sht) = False then // 返回仪器的数据表
    Exit;

  iRow := _LocateDTRow(Sht, DT, iDTStart, dloClosest); // 找到指定日期，或最接近的日期所在的行
  if iRow = -1 then
    Exit;

  iMonRow := _LocateDTRow(Sht, IncDay(DT, -30), iDTStart, dloClosest); // 一个月前数据所在行

  // 下面开始取数据了
  { todo:修改这个愚蠢方法，将这一堆写到配置文件中去 }
  (*
    if (sType = '锚索测力计') or (sType = '锚杆应力计') or (sType = '渗压计') or (sType = '基岩变形计')
    or (sType = '测缝计') or (sType = '裂缝计') or (sType = '位错计') or (sType = '钢筋计')
    or (sType = '钢板计') or (sType = '水位计') or (sType = '水位') or (sType = '量水堰')
    or (sType = '应变计') or (sType = '无应力计') then
    begin
    { 这些仪器数据是单行，且取第一个物理量 }
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
    { 多点位移计设置4行，取4个数据 }
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
    end
    else if (sType = '平面位移测点') then
    begin
    { 平面位移测点暂时只计算本地坐标差值，取SdX',SdY',SdH }
    SetLength(Values, 3);
    for i := 0 to 2 do
    begin
    Values[i] := VarArrayCreate([0, 5], varVariant);
    // Values[i][0] := Meter.pdName(i);
    Values[i][1] := ExcelIO.GetDateTimeValue(sht, iRow, 1);
    { todo:此处及以下应当判断数据合法性 }
    case i of
    0: k := 11; // SdX'=PD12, k=12-1=11
    1: k := 12; // SdY'=PD13
    2: k := 8;  // SdH =PD9
    end;
    Values[i][0] := Meter.pdName(k);
    Values[i][3] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(k)); // 当前值
    if iRow > iDTStart then
    begin
    iDays := DaysBetween(ExcelIO.GetDateTimeValue(sht, iRow, 1),
    ExcelIO.GetDateTimeValue(sht, iRow - 1, 1));
    d := ExcelIO.GetFloatValue(sht, iRow - 1, Meter.PDColumn(k));
    d2 := Values[i][3] - d;
    d30 := Values[i][3] - ExcelIO.GetFloatValue(sht, iMonRow, Meter.PDColumn(k));
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
  *)
  { 下面根据仪器数据结构中定义的特征值量查询观测数据变化值，即凡有特征值定义的物理量均进行查询，
    多数仪器仅有一个特征值，但是多点、水平位移等则有多个特征值。 }
  kIdx := [];
  k := 0;
  { 统计有多少特征值项 }
  for i := 0 to Meter.PDDefines.Count - 1 do
    if Meter.PDDefine[i].HasEV then
    begin
      include(kIdx, i);
      inc(k);
    end;
  if k > 0 then
  begin
    SetLength(Values, k);
    i := 0;
    { 下面对每一个特征值进行处理，每个特征值占一行 }
    for k in kIdx do
    begin
      Values[i] := VarArrayCreate([0, 5], varVariant);
      Values[i][0] := Meter.pdName(k);
      Values[i][1] := ExcelIO.GetDateTimeValue(Sht, iRow, 1); // 观测日期
      Values[i][3] := ExcelIO.GetFloatValue(Sht, iRow, Meter.PDColumn(k));
      if iRow > iDTStart then
      begin
        iDays := DaysBetween(ExcelIO.GetDateTimeValue(Sht, iRow, 1),
          ExcelIO.GetDateTimeValue(Sht, iRow - 1, 1));
        d := ExcelIO.GetFloatValue(Sht, iRow - 1, Meter.PDColumn(k));
        d2 := Values[i][3] - d;
        d30 := Values[i][3] - ExcelIO.GetFloatValue(Sht, iMonRow, Meter.PDColumn(k));
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

      inc(i);
    end;
  end;

  Result := True;
end;

function ThjxDataQuery.GetDataIncrement2(ADsnName: string; DT: TDateTime; InteralDays: Integer;
  var Values: TVariantDynArray): Boolean;
var
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  Meter: TMeterDefine;
  i, iDTStart: Integer;
  iRow, iDays: Integer; // 行号，间隔日期
  iEarlierRow: Integer; // 上个月数据所在行
  k: Integer; // 用于平面变形测点物理量序号
  // S, pdName  : String;
  sType: string; // 仪器类型
  d, d2, d30: double; // 当前值，增量，月增量
  kIdx: set of byte; // 特征值列的序号集合，假设监测仪器的特征值数量不会多于127
  procedure ClearValues; // 清理并初始化传入的Values参数
  var
    ii: Integer;
  begin
    if length(Values) > 0 then
      for ii := Low(Values) to High(Values) do
        VarClear(Values[ii]);
    SetLength(Values, 0);
  end;

begin
  Result := False;
  ClearValues;

  sType := GetMeterTypeName(ADsnName); // 获取仪器类型
  Meter := ExcelMeters.Meter[ADsnName];
  iDTStart := Meter.DataSheetStru.BaseLine { .DTStartRow };

  (* if _GetBookAndSheet(ADsnName, wbk, sht) = False then // 返回仪器的数据表
    Exit;
  *)
  if not _GetBookAndSheet(ADsnName, Wbk, Sht) then
    Exit;

  iRow := _LocateDTRow(Sht, DT, iDTStart, dloClosest); // 找到指定日期，或最接近的日期所在的行
  if iRow = -1 then
    Exit;

  iEarlierRow := _LocateDTRow(Sht, IncDay(DT, -InteralDays), iDTStart, dloClosest); // 一个月前数据所在行
  if iEarlierRow < iDTStart then
    iEarlierRow := iDTStart;
  { another case, iEarlierRow = iRow, then what? }

  kIdx := [];
  k := 0;
  { 统计有多少特征值项 }
  for i := 0 to Meter.PDDefines.Count - 1 do
    if Meter.PDDefine[i].HasEV then
    begin
      include(kIdx, i);
      inc(k);
    end;

  if k > 0 then
  begin
    SetLength(Values, k);
    i := 0;
    { 下面对每一个特征值进行处理，每个特征值占一行 }
    for k in kIdx do
    begin
      Values[i] := VarArrayCreate([0, 4], varVariant);
      Values[i][0] := Meter.pdName(k);
      Values[i][1] := ExcelIO.GetDateTimeValue(Sht, iRow, 1); // 观测日期
      Values[i][3] := ExcelIO.GetFloatValue(Sht, iRow, Meter.PDColumn(k));
      if iRow > iDTStart then
      begin
        iDays := DaysBetween(ExcelIO.GetDateTimeValue(Sht, iRow, 1),
          ExcelIO.GetDateTimeValue(Sht, iEarlierRow, 1));
        d := ExcelIO.GetFloatValue(Sht, iEarlierRow, Meter.PDColumn(k));
        d2 := Values[i][3] - d;
        // d30 := Values[i][3] - ExcelIO.GetFloatValue(sht, iMonRow, Meter.PDColumn(k));
        Values[i][2] := iDays;
        Values[i][4] := d2;
        // Values[i][5] := d30;
      end
      else
      begin
        Values[i][2] := 0;
        Values[i][4] := Null;
        // Values[i][5] := Null;
      end;

      inc(i);
    end;
  end;

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : _GetPeriodDay
  Description: 计算查询周期的截止日期或起始日期。本方法供GetPeriodIncrement方法
  调用。
  若NextPeriod为True，即求下一个周期的起始日期，也是本周期的截止日期，若为
  False，则求本周期的起始日期。
  ----------------------------------------------------------------------------- }
function _GetPeriodDay(ADate: TDateTime; Period, StartDay: Integer; NextPeriod: Boolean = True)
  : TDateTime;
var
  iPeriod, iiYear, iiMonth, iiDay: Integer;
begin
  Result := 0;
  iiYear := YearOf(ADate);
  iiMonth := MonthOf(ADate);
  iiDay := DayOf(ADate);
  case Period of
    0:
      begin
        // 月周期，如果StartDay=1，则本月周期为1日~下月1日，否则从上月StartDay到本月StartDay
        if StartDay = 1 then
        begin
          Result := IncMonth(EncodeDate(iiYear, iiMonth, 1));
        end
        else
        begin
          if NextPeriod then
            Result := IncMonth(EncodeDate(iiYear, iiMonth, StartDay))
          else
            Result := EncodeDate(iiYear, iiMonth, StartDay)
        end;
      end;
    1:
      begin
        /// 对年的周期，如果StartDay=1，则从本年度1月1日~来年1月1日，否则
        /// 暂定为从前一年12月某日到本年度12月某日。如2018年的年度测值取时范围为2017年
        /// 12月20日~2018年12月20日。
        if StartDay = 1 then
        begin
          Result := EncodeDate(iiYear + 1, 1, 1);
        end
        else
        begin
          if NextPeriod then
            Result := EncodeDate(iiYear + 1, 12, StartDay)
          else
            Result := EncodeDate(iiYear, 12, StartDay);
        end;
      end;
    2:
      // 季度周期暂时不考虑
      begin
      end;
    3:
      // 周周期暂不考虑，观测频次往往间隔都超过一周了……
      begin
        iPeriod := WeeksInYear(ADate);
        Result := IncDay(ADate, 7); // 简单粗暴的增加7天好了
      end;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetPeriodIncrement
  Description: 查询指定仪器的指定物理量在指定时间范围内指定周期类型的增量
  本方法可用于显示仪器的观测数据统计结果、绘制增量直方图、烛光图等高级图形
  ----------------------------------------------------------------------------- }
function ThjxDataQuery.GetPeriodIncrement(ADsnName: String; APDIndex: Integer;
  StartDate, EndDate: TDateTime; var Values: TVariantDynArray; StartDay: Integer = 20;
  Period: Integer = 0): Boolean;
var
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  Meter: TMeterDefine;
  sType: String;

  iStartRow, iEndRow { 给定起止日期对应的行号 } , iFirstRow, iLastRow { 周期起止时间对应的行号 } , iDay, n, i, iDataCol,
    iRow: Integer;
  sPeriodName: string; // 每条记录的间隔时段名称，如“2018年9月”
  dtStart, dtEnd: TDateTime; // 间隔时段的起止时间
  dtPeriodDate: TDateTime; // 当前周期的理论截止时间，主要应对起始日在周期中间的情况，具体来说
  // 用于月周期的情况，一般只有月周期的起始日不是每月1日，基本都在中间。
  dStart, dEnd, dInc: double; // 间隔时段的起止测值和增量值
  // dMax, dMin, dA :double; //间隔时段的最大最小值及测值在期间内的变幅
  // ----清理待输出的结果Values--------------------
  procedure __ClearValues;
  var
    ii: Integer;
  begin
    if length(Values) > 0 then
      for ii := Low(Values) to High(Values) do
        VarClear(Values[ii]);
    SetLength(Values, 0);
  end;

// ----计算增量-------
  function __GetInc(V1, V2: Variant): Variant;
  begin
    Result := Null;
    if VarIsNumeric(V1) and VarIsNumeric(V2) then
      Result := V2 - V1;
  end;

begin
  Result := False;
  __ClearValues;
  sType := GetMeterTypeName(ADsnName);
  Meter := ExcelMeters.Meter[ADsnName];
  iStartRow := Meter.DataSheetStru.BaseLine { .DTStartRow }; // 数据表中的第一行，即数据起始行
  if iStartRow = -1 then
    Exit;

  iDataCol := Meter.PDColumn(APDIndex);
  if _GetBookAndSheet(ADsnName, Wbk, Sht) = False then
    Exit;

  { 为降低代码复杂度，目前只考虑取回月增量，其他间隔以后再说。很久不写代码了，都快忘记编程了 }
  n := 0; // 数组长度
  iStartRow := _LocateDTRow(Sht, StartDate, iStartRow, dloClosest); // 取回指定时段的首行
  iFirstRow := iStartRow;
  iEndRow := _LocateDTRow(Sht, EndDate, iStartRow, dloClosest); // 截止日期对应的行
  dtStart := ExcelIO.GetDateTimeValue(Sht, iStartRow, 1); // 首行日期
  dStart := ExcelIO.GetFloatValue(Sht, iStartRow, iDataCol); // 第一个周期的起始数据
  dtPeriodDate := dtStart;
  /// 对于起始日期所在的第一个周期的判断，遵循如下逻辑：
  /// 1、若DayOf(dtStart)<StartDay，则本周期起始日期=dtStart，截止日期=周期的StartDay，如周期为月，
  /// StartDay=20，dtStart=2018-7-12，则本周为2018-7-12 ~ 2018-7-20。
  /// 2、若DayOf(dtStart)>=StartDay，则本周期起始日期=dtStart，截止日期=下一周期的StartDay。如周期
  /// 为月，StartDay=20，dtStart=2018-7-25，则本周期为2018-7-25 ~ 2018-8-20。
  /// 首个周期之后的各个周期判断就简单了。
  iDay := DayOf(dtStart);
  if iDay < StartDay then
  begin
    // 当iDay<StartDay时，需要判断本周期的结束日期是否等于iDay。如给定StartDate为8月17日，每月从上个
    // 月的20日开始计，则8月17日应属于8月的测值。此时需要查询最接近8月20日的观测日期，若最接近8月20日
    // 的观测日期是8月17日，甚至是8月16日，应查询8月17日~9月20日的期间测值。
    iLastRow := _LocateDTRow(Sht, _GetPeriodDay(dtStart, Period, StartDay, False), iStartRow,
      dloClosest);
    // 若iLastRow <= iStartRow，表明本周期没有数据，应查询下一周期，否则取本周期值。因此，只有当
    // iLastRow > iStartRow时，本周期才有数据，才需要在这里进行查询，否则就进入正常的查询循环。
    // 同时，这里也没有考虑到中间缺失几个周期数据的情况下，应该怎样表示。
    if iLastRow > iStartRow then
    begin
      inc(n);
      iFirstRow := iStartRow;
      SetLength(Values, n);
      Values[n - 1] := VarArrayCreate([0, 9], varVariant);
      Values[n - 1][0] := FormatDateTime('yyyy-mm', dtStart); // 暂时只处理月增量问题
      Values[n - 1][1] := dtStart;
      Values[n - 1][2] := ExcelIO.GetDateTimeValue(Sht, iLastRow, 1);
      Values[n - 1][3] := ExcelIO.GetValue(Sht, iFirstRow, iDataCol);
      Values[n - 1][4] := ExcelIO.GetValue(Sht, iLastRow, iDataCol);
      // 求增量：
      Values[n - 1][5] := __GetInc(Values[n - 1][3], Values[n - 1][4]);
      // 暂时不查询周期特征值和备注
      for i := 6 to 9 do
        Values[n - 1][i] := Null;
      iFirstRow := iLastRow;
      dtStart := Values[n - 1][2];
    end;
  end;

  // 重复查询，直到iEndRow的日期超出EndDate
  repeat
    // dtPeriodDate := _GetPeriodDay(dtStart, Period, StartDay);
    dtPeriodDate := _GetPeriodDay(dtPeriodDate, Period, StartDay);
    /// 取周期截止日期所在的行号
    iLastRow := _LocateDTRow(Sht, dtPeriodDate, iStartRow, dloClosest);
    if iLastRow = -1 then
      Break;
    if iLastRow > iEndRow then
      iLastRow := iEndRow;
    dtEnd := ExcelIO.GetDateTimeValue(Sht, iLastRow, 1);
    /// get datas
    inc(n);
    SetLength(Values, n);
    Values[n - 1] := VarArrayCreate([0, 9], varVariant);
    // 如果StartDay=1，则周期以StartDay为准，否则以dtPeriodDate为准
    case Period of
      0: // 月增量
        if StartDay = 1 then
          // Values[n - 1][0] := FormatDateTime('yyyy-mm', dtStart)
          Values[n - 1][0] := FormatDateTime('yyyy-mm', dtPeriodDate - 1)
        else
          Values[n - 1][0] := FormatDateTime('yyyy-mm', dtPeriodDate); // 以结束日期的月份作为本周期增量的时段名
      1: // 年增量
        if StartDay = 1 then
          Values[n - 1][0] := FormatDateTime('yyyy', dtPeriodDate - 1) + '年'
        else
          Values[n - 1][0] := FormatDateTime('yyyy', dtPeriodDate) + '年'; // 以结束日期的月份作为本周期增量的时段名
      2: // 季度增量，这个麻烦一点，干脆显示日期的了，回头有时间再处理
        { doto: 周期增量处理如何显示季度 }
        Values[n - 1][0] := FormatDateTime('yyyy-mm-dd', dtPeriodDate);
      3: // 周增量
        Values[n - 1][0] := FormatDateTime('yyyy-mm-dd', dtPeriodDate);
    end;

    Values[n - 1][1] := dtStart;
    Values[n - 1][2] := dtEnd;
    Values[n - 1][3] := ExcelIO.GetValue(Sht, iFirstRow, iDataCol);
    Values[n - 1][4] := ExcelIO.GetValue(Sht, iLastRow, iDataCol);
    Values[n - 1][5] := __GetInc(Values[n - 1][3], Values[n - 1][4]);

    /// 准备查询下一个周期
    /// 2022-02-14 这里有问题了：假设查询月增量，如果StartDay=1，假设8月1日最近的数据
    /// 是7月29日，则程序会用7月29日作为8月1日的数据，但是在查找下一个数据的时候，
    /// _GetPeriodDay在增加1个月，下一个数据日期还是8月1日，查找对应8月1日的数据的时候
    /// 又查到了7月29日……就变成了不停的循环。所以，问题在于最接近的数据日期月份和查询
    /// 日期的月份不一致造成的。
    iFirstRow := iLastRow;
    dtStart := dtEnd;

    /// 判断结束条件。若下一周期起始日期≥时段截止日期时，结束循环。
    if iFirstRow >= iEndRow then
      Break;
  until False;
  Result := True;
end;

{ ------------------------------------------------------------------------------------------------
  本方法仅回写物理量的计算结果，相当于直接用数值替代了公式。
  本方法测试了nExcel和ReadWriteII5写入Excel文件，结果感人，都可能会破坏Excel工作簿。奇怪的是，部分
  工作簿可以正常多次写入，不会遇到问题，比如应变计。但是锚索应力计工作簿会出现冻结33行的情况，而
  钢板计工作簿直接损坏到连Excel都无能为力的地步。目前尚不知造成问题的原因。
  相对来说，ReadWriteII5要比nExcel更好一点。nExcel读数据没有问题。
  最终，还是得需要Excel来操作它自己的文件。
  ------------------------------------------------------------------------------------------------- }
procedure ThjxDataQuery.RewriteDatas(Datas: PmtDatas);
begin
  // 用Excel填写数据
  _RewriteDatasWithExcel(Datas);

  //用XLSReadWriteII5填写数据
  //这个组件会破坏现有Excel文件，使之变得不可读，因此只能继续用Excel
  //_rewriteDataswithxrw5(datas);
end;

procedure ThjxDataQuery._RewriteDatasWithExcel(Datas: PmtDatas);
var
  Meter: TMeterDefine;
  // wbk            : XLSReadWriteII5.;
  // Sheet          : XLSSheetData5.TXLSWorksheet;
  iRow, iRowCount: Integer;
  iPDCol, iDTCol: Integer;
  iData: Integer;
  d1, d2: double;
  DT: TDateTime;
  bWrited: Boolean;
  { --- 用Excel吧 --- }
  XLSApp: OleVariant;
  XLSWbk, XLSSht: OleVariant;
  OpenExcelOK: Boolean;
begin
  Meter := ExcelMeters.Meter[Datas.DesignName];
  if Meter = nil then
    Exit;
  // 打开对应的工作表
  // FRW5.Clear;
  // FRW5.LoadFromFile(Meter.DataBook);
  // Sheet := FRW5.SheetByName(Meter.DataSheet);
  XLSApp := ExcelIO.GetExcelApp(True); // 不主动创建Application
  // XLSApp.Visible := True;
  XLSApp.ScreenUpdating := False;
  try
    XLSWbk := XLSApp.WorkBooks.Open(Meter.DataBook);
    if not(VarIsNull(XLSWbk) or VarIsEmpty(XLSWbk)) then
    begin
      XLSSht := XLSWbk.worksheets[Meter.DataSheet];
      if not(VarIsNull(XLSSht) or VarIsEmpty(XLSSht)) then
      begin
        XLSSht.activate;
        OpenExcelOK := True;
      end
      else
      begin
        Showmessage('打开工作表错误，无法回写');
      end;
    end
    else
      Showmessage('Excel打开工作簿出错，无法回写');

    if OpenExcelOK then
    begin
      iRowCount := XLSSht.UsedRange.Rows.Count;
      iPDCol := Meter.DataSheetStru.PDs.Items[Datas.PDIndex - 1].Column;
      iDTCol := Meter.DataSheetStru.DTStartCol;
      iData := 0;
      bWrited := False;
      for iRow := Meter.DataSheetStru.DTStartRow { RWII5规则 } to iRowCount do
      begin
        DT := XLSSht.Cells[iRow, iDTCol].Value;
        if DT = 0 then
          Break; // 如果日期=0，其实要么是非法日期，要么是日期是空
        // 日期是双精度数，从Excel取得的日期值与Delphi中的日期值会存在极端微小的差异，导致两者不想等
        // 因此，若不想用字符串格式化的日期，就用这种差值足够小来判断是否相等。
        if Abs(DT - Datas.Datas[iData].DT) < 0.00001 then
        begin
          d1 := XLSSht.Cells[iRow, iPDCol].Value;
          d2 := Datas.Datas[iData].Data;
          // 浮点数存在一定差值，因此两者差若小于一定值，则认为相等
          if Abs(d1 - d2) > 0.0001 then
          begin
            try
              XLSSht.Cells[iRow, iPDCol].Value := d2;
              XLSSht.Range[XLSSht.Cells[iRow, iPDCol], XLSSht.Cells[iRow, iPDCol]].font.color
                := -6737152;
              XLSSht.Range[XLSSht.Cells[iRow, iPDCol], XLSSht.Cells[iRow, iPDCol]]
                .font.Italic := True;

              bWrited := True;
            finally
            end;
          end;
        end;
        inc(iData);
      end;

    end;

    if bWrited then
      XLSWbk.save;

    XLSWbk.Close;
  finally
    XLSApp.ScreenUpdating := True;
    XLSApp.Quit; // 如果不是CreateObject方式获取XLSAPP，则不关闭
  end;
end;

/// 使用XLSReadWriteII5组件将数据写回Excel工作簿，会带来灾难性后果！切勿使用！
procedure ThjxDataQuery._RewriteDatasWithXRW5(Datas: PmtDatas);
var
  Meter: TMeterDefine;
  Wbk: TXLSReadWriteII5;
  Sheet: XLSSheetData5.TXLSWorksheet;
  iRow, iRowCount: Integer;
  iPDCol, iDTCol: Integer;
  iData: Integer;
  d1, d2: double;
  DT: TDateTime;
  bWrited: Boolean;
begin
  Meter := ExcelMeters.Meter[Datas.DesignName];
  if Meter = nil then
    Exit;
  // 打开对应的工作表
  // FRW5.Clear;
  // FRW5.LoadFromFile(Meter.DataBook);
  try
    Wbk := TXLSReadWriteII5.Create(nil);
    wbk.LoadFromFile(meter.DataBook);
    Sheet := wbk.SheetByName(Meter.DataSheet);

    iRowCount := Sheet.LastRow + 1; // ReadWriteII5的序号遵循Delphi序号规则，即从0开始，Excel从1开始
    Showmessage(Meter.DataSheetStru.PDs.Items[Datas.PDIndex - 1].Name);
    iPDCol := Meter.DataSheetStru.PDs.Items[Datas.PDIndex - 1].Column;
    iDTCol := Meter.DataSheetStru.DTStartCol;
    iData := 0;
    bWrited := False;
    wbk.CompileFormulas;
    { 下面这一段循环的逻辑有问题，存在出错的可能。由于Datas数组只包含待保存的数据，因此应当用Datas
      进行循环，确保每一个数据都能保存。用Datas循环，可用快速逼近法查找数据的时间 }
    for iRow := Meter.DataSheetStru.DTStartRow - 1 { RWII5规则 } to iRowCount do
    begin
      DT := Sheet.AsDateTime[iDTCol-1, iRow]; //RWII5的Excel对象起始序号为0
      if DT = 0 then
        Break; // 如果日期=0，其实要么是非法日期，要么是日期是空
      if Abs(DT - Datas.Datas[iData].DT) < 0.00001 then
      begin
        d1 := Sheet.AsFloat[iPDCol-1, iRow]; // ExcelIO.GetFloatValue(Sheet, iRow, iPDCol);
        d2 := Datas.Datas[iData].Data;
        // 浮点数存在一定差值，因此两者差若小于一定值，则认为相等
        if Abs(d1 - d2) > 0.0001 then
        begin
          try
            Sheet.AsFloat[iPDCol-1, iRow] := d2;
            Sheet.Cell[iPDCol-1, iRow].FontColor := 6737152;
            Sheet.Cell[iPDCol-1, iRow].FontStyle := [xfsItalic];

            bWrited := True;
          finally
          end;
        end;
        inc(iData)
      end;
    end;
    //
    if bWrited then
    begin
      try
        wbk.Write;
      except
        on e:exception do
          showmessage('保存数据出错' + #13#10 + e.Message);
      end;
    end;
  finally
    Wbk.Free;
  end;

end;

/// <Summary>提取指定仪器的系列事件记录
/// </Summary>
function ThjxDataQuery.GetMeterEvents(ADesignName: String): PmtEvents;
var
  Wbk: IXLSWorkBook;
  Sht: IXLSWorkSheet;
  S: string;
  iRow: Integer;
  d1, d2: TDateTime;
  e: string;
begin
  Result := nil;
  if ENV_EventsFile = '' then
    Exit;
  if ExcelIO.OpenWorkbook(Wbk, ENV_EventsFile) then
  begin
    New(Result);
    Result.DesignName := ADesignName;
    Sht := ExcelIO.GetSheet(Wbk, '监测事件');
    for iRow := 3 to Sht.UsedRange.Rows.Count do
    begin
      S := ExcelIO.GetStrValue(Sht, iRow, 1);
      if S = ADesignName then
      begin
        d1 := ExcelIO.GetDateTimeValue(Sht, iRow, 2);
        d2 := ExcelIO.GetDateTimeValue(Sht, iRow, 3);
        e := ExcelIO.GetStrValue(Sht, iRow, 4);
        Result.AddEvent(d1, d2, e);
      end;
    end;
  end;

end;

/// 写入一条事件记录
procedure ThjxDataQuery.WriteMeterEvent(ADesignName: string; AEventDate: TDateTime;
  ALogDate: TDateTime; AEvent: string);
var
  Wbk: nexcel.IXLSWorkBook;
  Sht: nexcel.IXLSWorkSheet;
  iRow, i: Integer;
  S: string;
begin
  if ENV_EventsFile = '' then
    Exit;
  Wbk := nexcel.txlsworkbook.Create;
  if ExcelIO.OpenWorkbook(Wbk, ENV_EventsFile) then
  begin
    Sht := ExcelIO.GetSheet(Wbk, '监测事件');
    iRow := ExcelIO.GetBlankRow(Sht, 3, 1); // 参数3为该表数据记录的首行行号
    if iRow = 0 then // irow=0表明首行亦为空
      iRow := 3;
    // 写入
    Sht.Cells[iRow, 1].Value := ADesignName;
    Sht.Cells[iRow, 2].Value := AEventDate;
    Sht.Cells[iRow, 3].Value := ALogDate;
    Sht.Cells[iRow, 4].Value := AEvent;
    Wbk.save;
    Wbk.Close;
  end;
end;

function ThjxDataQuery.ErrorMsg: String;
begin
  Result := FErrorMsg;
end;

procedure ThjxDataQuery.ClearErrMsg;
begin
  FErrorMsg := '';
end;

procedure ThjxDataQuery.AddErrMsg(Msg: string);
begin
  FErrorMsg := FErrorMsg + #13#10 + Msg;
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
