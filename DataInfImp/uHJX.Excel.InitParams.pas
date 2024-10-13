{ -----------------------------------------------------------------------------
  Unit Name: uInitParams
  Author:    黄伟
  Date:      31-三月-2017
  Purpose:   本单元用于初始化仪器参数。
  仪器参数来源于“仪器参数表.xls”，程序从参数表中加载所需的各项参数。
  参数加载完毕，基本上都在ExcelMeters对象中了。
  History:
  2018-06-21
  工程配置文件中增加了数据根目录、临时目录等相对配置文件的相对路径，
  环境变量中增加了这些常用路径，在加载配置文件时设置这些路径为绝对
  路径。
  需要进一步将仪器路径、分布图路径等利用今天的设置进行操作。
  2018-07-24
  增加了对数据结构预定义表的读取，重写了仪器数据结构定义内容的加载
  处理，使用预定义结构及本地覆盖。
  ----------------------------------------------------------------------------- }

unit uHJX.Excel.InitParams;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils, System.Variants, System.StrUtils,
  System.Types, Vcl.Dialogs, Vcl.Forms,
  nExcel,
  uHJX.Intf.AppServices,
  {uHJX.Excel.Meters} uHJX.Classes.Meters, uHJX.Excel.IO, uHJX.ProjectGlobal;

type
  { 仪器Excel参数变化类型 }
  TMeterExcelParamChanged = (mepcBase, mepcProject, mepcDataStru, mepcDataFile, mepcDataView,
    mepcChartStyle, mepcGroup);
  { 参数变化集合 }
  TMeterExcelParamchangedSet = set of TMeterExcelParamChanged;

  { 参数操作对象 }
  THJXExcelParam = class
  public
    { 更新一个参数值 }
    class function UpdateParam(DsnName: String; ParamName: String; ParamValue: Variant): Boolean;
    { 给定参数是否存在，即ParamName是否是合法参数 }
    class function IsMeterParam(ParamName: String): Boolean;
    { 列出仪器参数名 }
    class function ListMeterParamNames: String;
  end;

  { 打开加载工程文件对话框，若用户选择了工程文件，则加载之。本方法将注册到AppServices，作为
    AppServices.OpenDatabaseManager方法实际执行者。本方法执行完毕后，根据加载情况产生系列事件 }
procedure OpenProject(LoadNew: Boolean = False);

{ 加载工程配置文件，该文件指明了参数文件和数据列表文件所在，程序根据这些逐一处理 }
function LoadProjectConfig(prjBookName: string): Boolean;
{ 加载参数文件，包括仪器基本参数、工程参数、数据结构定义等 }
function LoadParams(ParamBook: IXLSWorkBook): Boolean;
{ 加载仪器数据文件列表，将每个仪器所对应的工作簿和工作表赋值给Meter的对应属性 }
function LoadDataFileList(DFBook: IXLSWorkBook): Boolean;
{ 加载布置图定义表 2018-06-07 }
function LoadLayoutList(DFBook: IXLSWorkBook): Boolean;
{ 加载字段名列表，该表是仪器属性名-对应的中文名，如：MeterType - 仪器类型等。这个字段名表主要用于
  参数编辑、参数显示、报表数据项等 }
function LoadFieldDispNames(ParamBook: IXLSWorkBook): Boolean;
{ 加载预定义的仪器类型表 }
function LoadMeterTypes(ParamBook: IXLSWorkBook): Boolean;
{ 加载预定义的工程部位列表 }
function LoadProjectLocations(ParamBook: IXLSWorkBook): Boolean;
{ 加载仪器组定义 }
function LoadMeterGroup(ParamBook: IXLSWorkBook): Boolean;
{ 加载过程线预定义  2018-09-03本方法被LoadTemplates方法替代 }
function LoadTrendLinePreDefines(ParamBook: IXLSWorkBook): Boolean;
{ 加载模板：ChartTemplates、WebGridTemplates、XLSGridTemplates等 }
function LoadTemplates(ParamBook: IXLSWorkBook): Boolean;
{ 保存参数，对已存在的仪器不改变其设计编号，允许创建新的仪器参数 }
function SaveParams(AMeter: TMeterDefine; NewMeter: Boolean = False): Boolean; overload;
{ 保存参数，允许更改仪器设计编号 }
function SaveParams(AMeter: TMeterDefine; OldName: string): Boolean; overload;
{ 更新单个参数 }
// function UpdateParam(ADsnName: string; ParamName: string; Param:Variant):Boolean;

{ 添加一个仪器的数据工作表到仪器数据文件列表工作簿中 }
function AppendDataSheet(ADsnName, ASheetName, ABookName, AMeterType, APosition: string): Integer;

var
  { 以下三个全局变量用于编辑参数文件时，快速访问这些工作簿文件，省的打开工程文件再去找 }
  xlsPrjFile   : string;   // 工程设置文件
  xlsParamFile : string;   // 参数文件
  xlsDFListFile: string;   // 数据工作簿列表文件
  xlsEventsFile: string;   // 监测事件工作簿文件
  IssueList    : TStrings; // 参数加载过程问题列表

implementation

uses
  uHJX.EnvironmentVariables, uHJX.Excel.Meters, System.RegularExpressions, System.IOUtils,
  System.IniFiles,
  // uTLDefineProc {2018-07-26 过程线模板对象定义单元，同时负责解析模板代码，暂时被本单元直接引用};
  uHJX.Classes.Templates, uHJX.Template.ChartTemplate, uHJX.Template.WebGrid,
  uHJX.Template.XLGrid;

type
  { 参数表列定义结构 }
  TParamColDefine = record
    ParamName: string;
    Col: Integer;
  end;

  PColDefine = ^TParamColDefine;

  TParamColsList = class
  private
    FList: TList<PColDefine>;
    function GetCount: Integer;
    function GetItem(Index: Integer): PColDefine;
    function GetCol(AName: string): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function AddNew: PColDefine;
    property Count: Integer read GetCount;
    property Item[index: Integer]: PColDefine read GetItem;
    property Col[AName: string]: Integer read GetCol;
  end;

  { TParamCols用于访问Excel参数文件时，指明各个参数项所对应的工作表列号。这个定义已经在参数表
    中的“ParamSheetStructure”工作表中预先定义好了，加载参数之前首先读取这个表中的定义，设置
    本对象，以后读取参数时，通过本对象可获取各个对应参数所在的列 }
  /// <summary>参数表结构定义，参数-列号 </summary>
  TParamCols = class
  public
    PRJ: TParamColsList;
    PRM: TParamColsList;
    DAT: TParamColsList;
    GRP: TParamColsList; // 2018-05-29 增加仪器组定义结构
    DPD: TParamColsList; // 2018-07-24 增加数据表结构预定义结构
    TLD: TParamColsList; // 2018-07-24 增加过程线预定义结构
    WGT: TParamColsList; // WebGrid Template sheet structure define
    XLT: TParamColsList; // XLGrid template sheet structure define
    constructor Create;
    destructor Destroy; override;
  end;

const
  MAXMETERNUMBER = 5000;
  PathPattern    = '^[a-zA-Z]:(((\\(?! )[^/:*?<>\""|\\]+)+\\?)|(\\)?)\s*$'; // 文件路径正则表达式

  // 2018-09-19参数表各工作表名
  /// <summary>参数定义文件各工作表结构定义</summary>
  SHTSTRUDEFINE = 'ParamSheetStructure';
  /// <summary>传感器基本参数，出厂参数为主</summary>
  SHTSENSORPARAMS = '仪器基本属性表';
  /// <summary>监测仪器工程属性表，如部位、桩号、高程、安装日期等</summary>
  SHTPRJPARAMS = '仪器工程属性表';
  /// <summary>监测仪器数据计算表格式定义表</summary>
  SHTMETERDATAS = '仪器数据格式定义';
  /// <summary>字段名表，主要是仪器参数的字段名和对应的中文名（显示的名字）</summary>
  SHTDSNAME = '字段名表';
  /// <summary>预定义的内容，如仪器类型、工程部位</summary>
  SHTPREDEFINE = '预定义项';
  /// <summary>仪器组定义，组名-组内仪器名单</summary>
  SHTGROUPDEFINE = '仪器组定义表';
  /// <summary>根据仪器类型预定义的数据表格式，一般情况下仪器数据结构指明采用哪个预定义项，
  /// 若仪器有特定的设置，加载参数时用预定义的格式替换之。
  /// </summary>
  SHTDATASTRUC = '数据格式预定义';
  /// <summary>仪器Chart模板</summary>
  SHTCHARTTEMPLS = '过程线模板';
  /// <summary>仪器观测数据的WebGrid形式的模板，EhGrid也将使用这个模板</summary>
  SHTWGTEMPLS = 'WebGrid基本表模板';
  /// <summary>导出Excel形式数据表所使用的模板目录，模板本身保存在另一个Excel文件。</summary>
  SHTXLTEMPLS = 'Excel基本表模板';

var
  // PARAMCOLS: TParamStruColDefine;
  // 参数工作簿各个参数表结构定义，用于快速访问参数表
  theCols     : TParamCols;
  DataFilePath: string; // 数据文件夹路径，在文件列表工作表的C1单元格

constructor TParamColsList.Create;
begin
  inherited;
  FList := TList<PColDefine>.Create;
end;

destructor TParamColsList.Destroy;
begin
  while FList.Count > 0 do
  begin
    Dispose(FList.Items[0]);
    FList.Delete(0);
  end;
  FList.Free;
  inherited;
end;

function TParamColsList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TParamColsList.GetItem(Index: Integer): PColDefine;
begin
  Result := FList.Items[index];
end;

function TParamColsList.AddNew: PColDefine;
begin
  New(Result);
  FList.Add(Result);
end;

function TParamColsList.GetCol(AName: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FList.Count - 1 do
    if SameText(FList.Items[i].ParamName, AName) then
    begin
      Result := FList.Items[i].Col;
      Break;
    end;
end;

constructor TParamCols.Create;
begin
  inherited;
  PRJ := TParamColsList.Create;
  PRM := TParamColsList.Create;
  DAT := TParamColsList.Create;
  GRP := TParamColsList.Create; // 2018-05-29
  DPD := TParamColsList.Create; // 2018-07-24
  TLD := TParamColsList.Create; // 2018-07-24
  WGT := TParamColsList.Create; // 2018-09-13
  XLT := TParamColsList.Create; // 2018-09-13
end;

destructor TParamCols.Destroy;
begin
  PRJ.Free;
  PRM.Free;
  DAT.Free;
  GRP.Free; // 2018-05-29
  DPD.Free; // 2018-07-24
  TLD.Free; // 2018-07-24
  WGT.Free; // 2018-09-13
  XLT.Free; // 2018-09-13
  inherited;
end;

function GetParamSheetStructure(ParamBook: IXLSWorkBook): Boolean;
var
  Sht         : IXLSWorksheet;
  S, sNum     : string;
  iRow, ColNum: Integer;
  ColDef      : PColDefine;
begin
  Result := False;
  // Sht := ExcelIO.GetSheet(ParamBook, 'ParamSheetStructure');
  Sht := ExcelIO.GetSheet(ParamBook, SHTSTRUDEFINE);
  if Sht = nil then
  begin
    ShowMessage('参数表中没有“ParamSheetStructure”工作表，你可能打开了'#13#10 + '假的参数表，请再检查一下。');
    Exit;
  end;

  // 基本属性表结构定义
  for iRow := 3 to 50 do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
    if S = '' then
      Break;
    sNum := VarToStr(Sht.Cells[iRow, 3].Value);
    ColNum := StrToInt(sNum);

    ColDef := theCols.PRM.AddNew;
    ColDef.ParamName := S;
    ColDef.Col := ColNum;
  end;

  // 工程属性表结构定义
  for iRow := 3 to 100 do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 6].Value));
    if S = '' then
      Break;
    sNum := VarToStr(Sht.Cells[iRow, 7].Value);
    ColNum := StrToInt(sNum);
    ColDef := theCols.PRJ.AddNew;
    ColDef.ParamName := S;
    ColDef.Col := ColNum;
  end;

  // 数据格式定义
  for iRow := 3 to 100 do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 10].Value));
    if S = '' then
      Break;
    sNum := VarToStr(Sht.Cells[iRow, 11].Value);
    ColNum := StrToInt(sNum);
    ColDef := theCols.DAT.AddNew;
    ColDef.ParamName := S;
    ColDef.Col := ColNum;
  end;

  // 2018-05-29 仪器组格式定义
  for iRow := 3 to 100 do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 14].Value));
    if S = '' then
      Break;
    sNum := VarToStr(Sht.Cells[iRow, 15].Value);
    ColNum := StrToInt(sNum);
    ColDef := theCols.GRP.AddNew;
    ColDef.ParamName := S;
    ColDef.Col := ColNum;
  end;

  // 2018-07-24数据表格式预定义
  for iRow := 3 to 100 do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 18].Value));
    if S = '' then
      Break;
    sNum := VarToStr(Sht.Cells[iRow, 19].Value);
    ColNum := StrToInt(sNum);
    ColDef := theCols.DPD.AddNew;
    ColDef.ParamName := S;
    ColDef.Col := ColNum;
  end;

  // 2018-07-24 过程线预定义
  for iRow := 3 to 100 do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 22].Value));
    if S = '' then
      Break;
    sNum := VarToStr(Sht.Cells[iRow, 23].Value);
    ColNum := StrToInt(sNum);
    ColDef := theCols.TLD.AddNew;
    ColDef.ParamName := S;
    ColDef.Col := ColNum;
  end;

  // 2018-09-13 WebGrid模板定义表结构
  for iRow := 3 to 100 do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 26].Value));
    if S = '' then
      Break;
    sNum := VarToStr(Sht.Cells[iRow, 27].Value);
    ColNum := StrToInt(sNum);
    ColDef := theCols.WGT.AddNew;
    ColDef.ParamName := S;
    ColDef.Col := ColNum;
  end;

  // 2018-09-13 XLGrid模板定义结构
  for iRow := 3 to 100 do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 30].Value));
    if S = '' then
      Break;
    sNum := VarToStr(Sht.Cells[iRow, 31].Value);
    ColNum := StrToInt(sNum);
    ColDef := theCols.XLT.AddNew;
    ColDef.ParamName := S;
    ColDef.Col := ColNum;
  end;

  Result := True;
end;

function _GetStrValue(ASht: IXLSWorksheet; ARow: Integer; ColList: TParamColsList;
  AName: string): string;
var
  iCol: Integer;
begin
  Result := '';
  iCol := ColList.Col[AName];
  if iCol = 0 then
    Exit;
  Result := Trim(VarToStr(ASht.Cells[ARow, iCol].Value));
end;

function _GetFloatValue(ASht: IXLSWorksheet; ARow: Integer; ColList: TParamColsList;
  AName: string): double;
var
  sValue: string;
begin
  Result := 0;
  sValue := _GetStrValue(ASht, ARow, ColList, AName);
  if sValue = '' then
    Exit;
  try
    Result := StrToFloat(sValue);
  finally
  end;
end;

function _GetDateTimeValue(ASht: IXLSWorksheet; ARow: Integer; ColList: TParamColsList;
  AName: string): TDateTime;
var
  sValue: string;
begin
  Result := 0;
  sValue := _GetStrValue(ASht, ARow, ColList, AName);
  TryStrToDateTime(sValue, Result);
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadProjectParams
  Description: 加载仪器工程参数
  ----------------------------------------------------------------------------- }
function LoadProjectParams(ParamBook: IXLSWorkBook): Boolean;
var
  iRow  : Integer;
  AMeter: TMeterDefine;
  Sht   : IXLSWorksheet;
  S     : string;
  function StrValue(ARow: Integer; AName: string): string;
  begin
    Result := _GetStrValue(Sht, ARow, theCols.PRJ, AName);
  end;
  function FloatValue(ARow: Integer; AName: string): double;
  begin
    Result := _GetFloatValue(Sht, ARow, theCols.PRJ, AName);
  end;

begin
  Result := False;
  Sht := ExcelIO.GetSheet(ParamBook, '仪器工程属性表');
  if Sht = nil then
    Exit;
  for iRow := 4 to MAXMETERNUMBER do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
    if S = '' then
      Break;
    AMeter := ExcelMeters.AddNew;
    AMeter.DesignName := S;
    AMeter.PrjParams.SubProject := StrValue(iRow, 'SubProject');
    AMeter.PrjParams.Position := StrValue(iRow, 'Position');
    AMeter.PrjParams.PosIndex := PG_Locations.IndexOf(AMeter.PrjParams.Position); // 2022-11-3
    AMeter.PrjParams.Elevation := FloatValue(iRow, 'Elevation');
    AMeter.PrjParams.Stake := StrValue(iRow, 'Stake');
    AMeter.PrjParams.Profile := StrValue(iRow, 'Profile');
    AMeter.PrjParams.Deep := FloatValue(iRow, 'Deep');
    AMeter.PrjParams.Annotation := StrValue(iRow, 'Annotation');
    AMeter.PrjParams.GroupID := StrValue(iRow, 'GroupID');
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadMeterParams
  Description: 加载仪器参数表，实际应该算是传感器参数表
  ----------------------------------------------------------------------------- }
function LoadMeterParams(ParamBook: IXLSWorkBook): Boolean;
var
  iRow  : Integer;
  AMeter: TMeterDefine;
  Sht   : IXLSWorksheet;
  S     : string;
  function StrValue(AName: string): string;
  begin
    Result := _GetStrValue(Sht, iRow, theCols.PRM, AName);
  end;
  function FloatValue(AName: string): double;
  begin
    Result := _GetFloatValue(Sht, iRow, theCols.PRM, AName);
  end;
  function DateTimeValue(AName: string): TDateTime;
  begin
    Result := _GetDateTimeValue(Sht, iRow, theCols.PRM, AName);
  end;

begin
  Result := False;
  Sht := ExcelIO.GetSheet(ParamBook, { '仪器基本属性表' } SHTSENSORPARAMS);
  if Sht = nil then
    Exit;
  for iRow := 4 to MAXMETERNUMBER do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
    if S = '' then
      Break;
    AMeter := ExcelMeters.Meter[S];
    if AMeter = nil then
      Continue;
    AMeter.Params.MeterType := StrValue('MeterType');
    AMeter.Params.Model := StrValue('Model');
    AMeter.Params.SerialNo := StrValue('SerialNo');
    AMeter.Params.WorkMode := StrValue('WorkMode');
    AMeter.Params.MinValue := FloatValue('MinValue');
    AMeter.Params.MaxValue := FloatValue('MaxValue');
    AMeter.Params.SensorCount := Trunc(FloatValue('SensorCount'));
    AMeter.Params.SetupDate := DateTimeValue('SetupDate');
    AMeter.Params.BaseDate := DateTimeValue('BaseDate');
    AMeter.Params.MDCount := Trunc(FloatValue('MDCount'));
    AMeter.Params.PDCount := Trunc(FloatValue('PDCount'));
    AMeter.Params.Annotation := StrValue('Annotation');
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadDataStruRecord
  Description: 从数据结构定义表中读取一行，并解析，将结果填写到DSS中。
  有两个表需要用到本函数：预定义结构表 和 仪器数据结构定义表，两者分别由预定义
  加载过程和仪器数据定义加载过程处理。
  ----------------------------------------------------------------------------- }
function LoadDataStruRecord(Sheet: IXLSWorksheet; ARow: Integer; var DSS: TDataSheetStructure;
  PCL: TParamColsList): Boolean;
var
  S1, S2  : string;
  SS1, SS2: TArray<string>;
  function StrValue(AName: string): string;
  begin
    Result := _GetStrValue(Sheet, ARow, PCL, AName);
  end;
  function FloatValue(AName: string): double;
  begin
    Result := _GetFloatValue(Sheet, ARow, PCL, AName);
  end;
  procedure ExtractDataDefine(datNames, datCols: string; DDs: TDataDefines);
  var
    i  : Integer;
    pdd: PDataDefine;
  begin
    SetLength(SS1, 0);
    SetLength(SS2, 0);
    SS1 := datNames.Split(['|']);
    SS2 := datCols.Split(['|']);
    // SS1.DelimitedText := datNames;
    // SS2.DelimitedText := datCols;
    { TODO:需要考虑两者数量不同的情况，以及和MDCount、PDCount不一致的情况 }
    if (Length(SS1) > 0) { and (Length(SS2) > 0) } then
      for i := low(SS1) to high(SS1) do
      begin
        pdd := DDs.AddNew;
        pdd.Name := SS1[i];
        // 有可能没有提供列号，这时SS2不是数组。
        if Length(SS2) > 0 then
          if i <= high(SS2) then
            pdd.Column := StrToInt(SS2[i]);
      end;
  end;
  procedure ProcEVItems(EVDefine: string);
  var
    i, k: Integer;
  begin
    SetLength(SS1, 0);
    SS1 := EVDefine.Split(['|']);
    // SS1.Clear;
    // SS1.DelimitedText := EVDefine;
    if Length(SS1) > 0 then
      for i := low(SS1) to high(SS1) do
      begin
        k := StrToInt(SS1[i]) - 1;
        DSS.PDs.Items[k].HasEV := True;
      end;
  end;

begin
  DSS.DTStartRow := Trunc(FloatValue('DTStartRow'));
  DSS.DTStartCol := Trunc(FloatValue('DTStartCol'));
  DSS.AnnoCol := Trunc(FloatValue('Annotation'));
  DSS.BaseLine := Trunc(FloatValue('BaseLine'));
  DSS.ChartDefineName := StrValue('ChartTemplate'); // 2018-07-26 提取图表定义名
  DSS.ChartTemplate := StrValue('ChartTemplate');
  DSS.WGTemplate := StrValue('WebGridTemplate');
  DSS.XLTemplate := StrValue('XLSGridTemplate');
  DSS.MeterType := StrValue('MeterType');

  S1 := StrValue('MDDefine');
  S2 := StrValue('MDCols');
  ExtractDataDefine(S1, S2, DSS.MDs);

  S1 := StrValue('PDDefine');
  S2 := StrValue('PDCols');
  ExtractDataDefine(S1, S2, DSS.PDs);

  S1 := StrValue('EVItems');
  ProcEVItems(S1);

  SetLength(SS1, 0);
  SetLength(SS2, 0);

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadPreDefineDataStru
  Description: 本函数与LoadDatasheetStru类似，干脆说，本函数在LoadDataSheetStru
  函数的基础上修改而来。为省事，没有将两个函数相似代码进行优化，就这样能用算了。
  ----------------------------------------------------------------------------- }
function LoadPreDefineDataStru(ParamBook: IXLSWorkBook): Boolean;
var
  iRow    : Integer;
  Sht     : IXLSWorksheet;
  S       : string;
  PreDItem: TPreDefineDataStructure;
begin
  Result := False;
  Sht := ExcelIO.GetSheet(ParamBook, { '数据格式预定义' } SHTDATASTRUC);
  if Sht = nil then
  begin
    ShowMessage('参数工作簿中没有包含"数据格式预定义"工作表，可能是旧版参数文件。'#13#10'请更新参数文件后再来玩。');
    Exit;
  end;

  try
    for iRow := 5 to MAXMETERNUMBER do
    begin
      S := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
      if S = '' then
        Break;
      PreDItem := DSDefines.AddNew;
      PreDItem.DefineName := S;
      LoadDataStruRecord(Sht, iRow, PreDItem.DataDefine, theCols.DPD);
    end;

  finally
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadDataSheetStru
  Description: 加载仪器数据表结构定义记录
  ----------------------------------------------------------------------------- }
function LoadDataSheetStru(ParamBook: IXLSWorkBook): Boolean;
var
  iRow       : Integer;
  AMeter     : TMeterDefine;
  Sht        : IXLSWorksheet;
  S, S1      : string;
  LocalDefine: TDataSheetStructure;
  PDDS       : TPreDefineDataStructure;
  Obj        : TObject;

  procedure ClearLocalDefine;
  begin
    LocalDefine.MDs.Clear;
    LocalDefine.PDs.Clear;
    LocalDefine.DTStartRow := 0;
    LocalDefine.DTStartCol := 0;
    LocalDefine.AnnoCol := 0;
    LocalDefine.BaseLine := 0;
    LocalDefine.ChartDefineName := '';
    LocalDefine.ChartTemplate := '';
    LocalDefine.WGTemplate := '';
    LocalDefine.XLTemplate := '';
  end;

{ 用本地设置替换预定义 }
  procedure RecoverByLocal;
    procedure ReplaceIntValue(LV: Integer; var V: Integer);
    begin
      if LV <> 0 then
        V := LV;
    end;

    procedure ReplaceDataDefines(Local, MTDefine: TDataDefines);
    var
      ii: Integer;
    begin
      if local.Count = MTDefine.Count then
        for ii := 0 to local.Count - 1 do
        begin
          MTDefine.Items[ii].Name := local.Items[ii].Name;
          MTDefine.Items[ii].Alias := local.Items[ii].Alias;
          MTDefine.Items[ii].DataUnit := local.Items[ii].DataUnit;
          if local.Items[ii].Column <> 0 then
          begin
            MTDefine.Items[ii].Column := local.Items[ii].Column;
            MTDefine.Items[ii].HasEV := local.Items[ii].HasEV;
          end;
        end
      else
      begin
        MTDefine.Clear;
        MTDefine.Assign(local);
      end;
    end;

  begin
    ReplaceIntValue(LocalDefine.DTStartRow, AMeter.DataSheetStru.DTStartRow);
    ReplaceIntValue(LocalDefine.DTStartCol, AMeter.DataSheetStru.DTStartCol);
    ReplaceIntValue(LocalDefine.AnnoCol, AMeter.DataSheetStru.AnnoCol);
    ReplaceIntValue(LocalDefine.BaseLine, AMeter.DataSheetStru.BaseLine);

    // 设置Templates name，之后设置对象
    with AMeter.DataSheetStru do
    begin
      if LocalDefine.ChartDefineName <> '' then
        ChartDefineName := LocalDefine.ChartDefineName;
      if LocalDefine.ChartTemplate <> '' then
        ChartTemplate := LocalDefine.ChartTemplate;
      if LocalDefine.WGTemplate <> '' then
        WGTemplate := LocalDefine.WGTemplate;
      if LocalDefine.XLTemplate <> '' then
        XLTemplate := LocalDefine.XLTemplate;
    end;

    if AMeter.DataSheetStru.ChartDefineName <> '' then
    begin
      Obj := (IAppServices.Templates as TTemplates).ItemByName
        [AMeter.DataSheetStru.ChartDefineName];
      if Obj <> nil then
        AMeter.ChartPreDef := Obj;
    end;
    // 下面覆盖MDs。LocalDefine的MDs存在如下情况(PDs相同):
    // 1. 有名，有列，数量相等，直接覆盖全部；
    // 2. 有名，无列，数量相等，覆盖名称
    // 3. 有名，有列，数量不同，本地覆盖预定义，使之与本地相同。
    if LocalDefine.MDs.Count > 0 then
      ReplaceDataDefines(LocalDefine.MDs, AMeter.DataSheetStru.MDs);
    if LocalDefine.PDs.Count > 0 then
      ReplaceDataDefines(LocalDefine.PDs, AMeter.DataSheetStru.PDs);
  end;

begin
  Result := False;
  Sht := ExcelIO.GetSheet(ParamBook, { '仪器数据格式定义' } SHTMETERDATAS);
  if Sht = nil then
    Exit;
  LocalDefine.MDs := TDataDefineList.Create;
  LocalDefine.PDs := TDataDefineList.Create;
  try
    for iRow := 5 to MAXMETERNUMBER do
    begin
      S := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
      if S = '' then
        Break;
      AMeter := ExcelMeters.Meter[S];
      if AMeter = nil then
        Continue;

      // 读取预定义名称
      S1 := Trim(VarToStr(Sht.Cells[iRow, 4].Value));
      if S1 <> '' then
      begin
        // 如果S1不为空，则从预定义那里取回设置，并填写到仪器的DataSheetStru属性中
        PDDS := DSDefines.ItemByName[S1];
        if PDDS <> nil then
          with AMeter.DataSheetStru do
          begin
            DTStartRow := PDDS.DataDefine.DTStartRow;
            DTStartCol := PDDS.DataDefine.DTStartCol;
            AnnoCol := PDDS.DataDefine.AnnoCol;
            BaseLine := PDDS.DataDefine.BaseLine;
            MDs.Assign(PDDS.DataDefine.MDs);
            PDs.Assign(PDDS.DataDefine.PDs);
            ChartDefineName := PDDS.DataDefine.ChartDefineName;
            ChartTemplate := PDDS.DataDefine.ChartTemplate;
            WGTemplate := PDDS.DataDefine.WGTemplate;
            XLTemplate := PDDS.DataDefine.XLTemplate;
          end;
      end;

      // 加载仪器本地设置，若本地设置中有不为空的值，则覆盖预定义值。
      ClearLocalDefine;
      LoadDataStruRecord(Sht, iRow, LocalDefine, theCols.DAT);
      { 本地设置覆盖预定义设置，有一些规则必须遵守:
        1. 若要覆盖数据名称，可以不设置列号；
        2. 若要覆盖数据列号，就必须提供数据名称；
        3. 日期起始行、起始列、初值行、备注列等可以单独设置，不影响其他
        4. 数据名称、数据列要覆盖，就必须提供完整的，无法只覆盖其中的某一项。
      }
      RecoverByLocal;

      // 旧方法：加载仪器本地设置到仪器的DataSheetStru属性中。
      // LoadDataStruRecord(Sht, iRow, AMeter.DataSheetStru, theCols.DAT);

    end;
  finally
    LocalDefine.PDs.Free;
    LocalDefine.MDs.Free;
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadParams
  Description: 加载仪器参数过程
  ----------------------------------------------------------------------------- }
function LoadParams(ParamBook: IXLSWorkBook): Boolean;
begin
  Result := False;
  // 先加载参数文件结构定义表
  if not GetParamSheetStructure(ParamBook) then
  begin
    ShowMessage('未能加载参数文件结构定义，无法完成初始化参数加载过程。');
    Exit;
  end;

  // 加载工程部位表，加载仪器后要设置PosIndex值
  LoadProjectLocations(ParamBook);

  // 加载工程参数表，在这里创建仪器对象。也就是说，只有在这个表中定义的仪器才会被创建。基本参数表
  // 中的仪器如果在工程表中没有，则不会被创建。
  LoadProjectParams(ParamBook);
  // 加载数据结构预定义表
  LoadPreDefineDataStru(ParamBook);
  // 加载过程线预定义表
  LoadTrendLinePreDefines(ParamBook);
  // 加载模板定义
  LoadTemplates(ParamBook);
  // 加载基本参数表
  LoadMeterParams(ParamBook);
  // 加载数据结构定义表
  LoadDataSheetStru(ParamBook);
  // 加载仪器组定义表
  LoadMeterGroup(ParamBook);
  // 加载字段名列表
  LoadFieldDispNames(ParamBook);
  // 加载仪器类型列表
  LoadMeterTypes(ParamBook);

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadDataFileList
  Description: 加载仪器数据文件列表过程
  ----------------------------------------------------------------------------- }
function LoadDataFileList(DFBook: IXLSWorkBook): Boolean;
var
  Sht           : IXLSWorksheet;
  iRow          : Integer;
  S, sSht, sBook: string;
  AMeter        : TMeterDefine;
begin
  Result := False;
  Sht := ExcelIO.GetSheet(DFBook, '仪器数据文件列表');
  if Sht = nil then
    Exit;
  // 取数据文件夹，即数据文件的绝对路径。这里可以考虑，如果在C1单元格未指定绝对路径，而文件列表是
  // 相对路径，则弹窗让用户选择数据文件所在文件夹，这样可增加使用的灵活性。
  DataFilePath := Trim(ExcelIO.GetStrValue(Sht, 1, 3)); // C1单元格

  // 验证Datafilepath是否存在、是否正确
  if (ENV_DataRoot = '') or not DirectoryExists(ENV_DataRoot) then
    if (DataFilePath = '') or (not DirExists(DataFilePath)) then;

  for iRow := 3 to 10000 do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
    if S = '' then
      Break;
    AMeter := ExcelMeters.Meter[S];
    if AMeter = nil then
      Continue;
    sSht := VarToStr(Sht.Cells[iRow, 3].Value);
    sBook := VarToStr(Sht.Cells[iRow, 4].Value);
    { todo:这里最好判断一下sBook是否是一个完整路径，之后再判断一下文件是否存在 }
    { 2018-06-06
      完整的处理判断过程应是：1- 判断sBook是否为合法路径，若是则判断文件是否存在，若不存在则通知
      用户到盘上挑选正确的文件（或干脆放弃）；若不是则 2- 判断DataFilePath是否为空、是否有效，若
      为空或无效则通知用户选择一个有效的路径。之后 3- 将DataFilePath和sBook合成为完整文件路径，
      通过正则表达式判断合成结果是否有效，若有效则判断是否存在，若无效或不存在则通知用户挑选文件
      或放弃。
      为提高效率，完成判断的sBook和处理结果将被保存，再遇到相同的sBook直接采用处理结果。

      目前的代码假设sBook全部为相对路径，且无前导"\"符号，C1单元格的DataFilePath字符串为绝对路径，
      且末尾无字符"\"。 }
    if FileExists(sBook) then
      sBook := TPath.GetFullPath(sBook)
    else
      // 使用环境变量中的数据路径
      if ENV_DataRoot <> '' then
        if FileExists(ENV_DataRoot + sBook) then
          sBook := ENV_DataRoot + sBook
        else
          sBook := ''
      else
        sBook := '';

    // 2018-06-21 暂时弃用文件列表中标明的根路径
    // if DataFilePath <> '' then
    // begin
    // { 判断原sBook是否是合法路径名，在这里的正则表达式规定只有完整的绝对路径才符合条件 }
    // if TRegEx.IsMatch(sBook, PathPattern) then
    // begin
    // if not FileExists(sBook) then
    // sBook := '';
    // end
    // else
    // { todo:检查合成的文件是否合法、是否存在 }
    // if FileExists(DataFilePath + '\' + sBook) then
    // sBook := DataFilePath + '\' + sBook
    // else
    // { todo: 若合成文件不存在，则让用户指定文件，若用户取消指定，则以后同名文件都不再指定 }
    // sBook := '';
    // end
    // else
    // { todo: 检查文件是否存在，若不存在，则让用户为该仪器选择一个文件或不指定文件 }
    // if not FileExists(sBook) then
    // sBook := '';

    AMeter.DataSheet := sSht;
    AMeter.DataBook := sBook;
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadLayoutList
  Description: 加载布置图列表
  ----------------------------------------------------------------------------- }
function LoadLayoutList(DFBook: IXLSWorkBook): Boolean;
var
  Sht                       : IXLSWorksheet;
  iRow                      : Integer;
  sName, sFile, sPath, sAnno: string;
  ARec                      : PLayoutRec;
begin
  Result := False;
  Sht := ExcelIO.GetSheet(DFBook, '分布图文件列表');
  if Sht = nil then
    Exit;

  // 取相对路径
  sPath := Trim(ExcelIO.GetStrValue(Sht, 1, 2));
  if ENV_SchemePath <> '' then
    sPath := ENV_SchemePath
  else
  begin
    if DirectoryExists(sPath) then
    begin
      if RightStr(sPath, 1) <> '\' then
        sPath := sPath + '\';
    end
    else
    begin
      ShowMessage(Format('路径%s无效，无法加载布置图文件列表', [sPath]));
      Exit;
    end;
  end;

  for iRow := 3 to Sht.UsedRange.LastRow do
  begin
    sName := Trim(ExcelIO.GetStrValue(Sht, iRow, 2));
    if sName = '' then
      Continue;
    sFile := Trim(ExcelIO.GetStrValue(Sht, iRow, 3));
    sAnno := Trim(ExcelIO.GetStrValue(Sht, iRow, 5));
    if sFile = '' then
    begin
      ShowMessage(Format('布置图%s没有指定图形文件', [sName]));
      Continue;
    end
    else
    begin
      if FileExists(sPath + sFile) then
      begin
        ARec := Layouts.AddNew;
        ARec.Name := sName;
        ARec.FileName := sPath + sFile;
        ARec.Annotation := sAnno;
      end
      else
        ShowMessage(Format('布置图%s的文件路径%s无效。', [sName, sPath + sFile]));
    end;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadMeterGroup
  Description: 加载仪器组定义 2018-05-29
  ----------------------------------------------------------------------------- }
function LoadMeterGroup(ParamBook: IXLSWorkBook): Boolean;
var
  iRow : Integer;
  AItem: TMeterGroupItem;
  Sht  : IXLSWorksheet;
  S, S1: string;
  SS   : TStringDynArray;
  i    : Integer;
  function StrValue(ARow: Integer; AName: string): string;
  begin
    Result := _GetStrValue(Sht, ARow, theCols.GRP, AName);
  end;
  function FloatValue(ARow: Integer; AName: string): double;
  begin
    Result := _GetFloatValue(Sht, ARow, theCols.GRP, AName);
  end;

begin
  Result := False;
  Sht := ExcelIO.GetSheet(ParamBook, { '仪器组定义表' } SHTGROUPDEFINE);
  if Sht = nil then
    Exit;
  for iRow := 4 to MAXMETERNUMBER do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
    if S = '' then
      Break;
    AItem := MeterGroup.AddNew;
    AItem.Name := StrValue(iRow, 'GroupName');
    AItem.GroupType := StrValue(iRow, 'GroupType');
    S1 := StrValue(iRow, 'GroupMeters');
    SS := SplitString(S1, '|');
    if Length(SS) > 0 then
      for i := low(SS) to high(SS) do
        AItem.AddMeter(SS[i]);
  end;
  Result := True;
  SetLength(SS, 0);
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadProjectConfig
  Description: 加载工程配置文件，这个文件中定义了仪器参数表文件和仪器数据文件
  列表文件，本过程根据此表逐一加载之。
  ----------------------------------------------------------------------------- }
function LoadProjectConfig(prjBookName: string): Boolean;
var
  Wbk, Wbk1, Wbk2: IXLSWorkBook;
  Sht            : IXLSWorksheet;
  S, sPF, sDLF   : string;
  iRow           : Integer;

  sDataRt    : string; // 数据文件根目录
  sScheme    : string; // 分布图目录
  sCX        : string; // 测斜、测量目录
  sTemp      : string; // 临时
  sTemplBook : string; // Excel DataGrid template workbook
  sEventsFile: string; // 监测事件工作簿

  function _GetFullPath(APath: string): string;
  begin
    try
      Result := TPath.GetFullPath(APath);
    except
      // IssueList.Add(APath + '不是有效的文件名或路径');
      Result := '';
    end;
  end;

begin
  Result := False;
  IssueList.Clear;

  xlsPrjFile := prjBookName;

  // 解析出配置文件所在路径，以后要用到
  ENV_ConfigPath := ExtractFilePath(prjBookName);
  // 清空全部已创建的仪器，要重新加载了~~
  ExcelMeters.ReleaseAllMeters;
  MeterGroup.ReleaseAllItems;

  // 清空环境量
  ENV_DataRoot := '';
  ENV_SchemePath := '';
  ENV_CXDataPath := '';
  ENV_TempPath := '';
  ENV_XLTemplBook := '';
  ENV_EventsFile := '';

  Wbk := TXLSWorkbook.Create;

  { todo:重写下面的代码，用OpenWorkbook函数处理文件打开的情况 }

  try
    // wbk.Open(prjBookName);
    if ExcelIO.OpenWorkbook(Wbk, prjBookName) = False then
    begin
      ShowMessage('未能打开工程配置文件，无法继续...');
    end;

    Sht := ExcelIO.GetSheet(Wbk, '工程配置文件');
    if Sht = nil then
    begin
      ShowMessage('不是有效的“工程配置文件”');
      Exit;
    end;
    { todo:添加格式检查 }
    sPF := '';
    sDLF := '';
    for iRow := 3 to Sht.UsedRange.LastRow + 1 do
    begin
      S := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
      if S = '' then
        Break;

      if S = '仪器参数表工作簿' then
        sPF := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = '仪器数据文件列表工作簿' then
        sDLF := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = '观测数据根目录' then
        sDataRt := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = '分布图目录' then
        sScheme := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = '测斜孔数据目录' then
        sCX := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = '临时目录' then
        sTemp := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = 'Excel报表模板' then
        sTemplBook := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = '监测事件工作簿' then
        sEventsFile := Trim(VarToStr(Sht.Cells[iRow, 3].Value));
    end;

    // 设置文件路径
    S := GetCurrentDir;
    SetCurrentDir(ENV_ConfigPath);

    // 将相对目录替换为绝对目录
    xlsParamFile := _GetFullPath(sPF);
    xlsDFListFile := _GetFullPath(sDLF);
    sDataRt := _GetFullPath(sDataRt);
    sScheme := _GetFullPath(sScheme);
    sCX := _GetFullPath(sCX);
    sTemp := _GetFullPath(sTemp);
    sTemplBook := _GetFullPath(sTemplBook);
    sEventsFile := _GetFullPath(sEventsFile);

    if (xlsParamFile = '') or (not FileExists(sPF)) then
    begin
      IssueList.Add(Format('仪器参数文件“%s”无效', [sPF]));
      xlsParamFile := '';
    end;

    if (xlsDFListFile = '') or (not FileExists(sDLF)) then
    begin
      IssueList.Add(Format('仪器数据文件列表工作簿“%s”不是有效文件', [sDLF]));
    end;

    // ShowMessage(sDataRt + #13 + sScheme + #13 + sCX + #13 + sTemp);
    // 测试这些目录是否存在，若不存在则清空
    if DirectoryExists(sDataRt) then
      ENV_DataRoot := sDataRt
    else
      IssueList.Add('数据文件根目录无效或不存在');

    if DirectoryExists(sScheme) then
      ENV_SchemePath := sScheme
    else
      IssueList.Add('监测仪器布置图文件夹无效或不存在');

    if DirectoryExists(sCX) then
      ENV_CXDataPath := sCX
    else
      IssueList.Add('测斜孔数据文件夹无效或不存在');

    if DirectoryExists(sTemp) then
      ENV_TempPath := sTemp
    else
      IssueList.Add('临时文件夹无效或不存在');

    if FileExists(sTemplBook) then
      ENV_XLTemplBook := sTemplBook
    else
      IssueList.Add(Format('“%s”不是有效的文件，无法加载Excel模板工作簿。', [sTemplBook]));

    if FileExists(sEventsFile) then
      ENV_EventsFile := sEventsFile
    else
      IssueList.Add(Format('“%s”不是有效的文件，无法加载Excel模板工作簿。', [sEventsFile]));

    // 加载仪器参数表工作簿
    if sPF <> '' then
      try
        Wbk1 := TXLSWorkbook.Create;
        Wbk1.Open(sPF);
        LoadParams(Wbk1);
        // LoadTrendlinePredefines(Wbk1);
      except
        on e: Exception do
          ShowMessage('加载仪器参数出错：' + e.Message);
      end;

    if sDLF <> '' then
      try
        Wbk2 := TXLSWorkbook.Create;
        Wbk2.Open(sDLF);
        LoadDataFileList(Wbk2);
        LoadLayoutList(Wbk2); // 2018-06-07 加载布置图李彪
      except
        on e: Exception do
          ShowMessage('加载仪器数据文件列表出错：' + e.Message);
      end;

    Result := True;
    // 发出数据库已打开消息
    IAppServices.OnLogin(nil);
  except
    on e: Exception do
      ShowMessage(e.Message);
  end;
  SetCurrentDir(S);

  if IssueList.Count > 0 then
    ShowMessage(IssueList.Text);
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadFieldDispNames
  Description: 加载字段显示名定义表
  ----------------------------------------------------------------------------- }
function LoadFieldDispNames(ParamBook: IXLSWorkBook): Boolean;
var
  Sht   : IXLSWorksheet;
  iRow  : Integer;
  S1, S2: string;
begin
  Result := False;
  Sht := ExcelIO.GetSheet(ParamBook, { '字段名表' } SHTDSNAME);
  if Sht = nil then
    Exit;

  for iRow := 2 to Sht.UsedRange.LastRow + 1 do
  begin
    S1 := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
    if S1 = '' then
      Continue;
    S2 := Trim(VarToStr(Sht.Cells[iRow, 3].Value));
    if S2 <> '' then
      dsnames.AddName(S1, S2);
  end;

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadMeterTypes
  Description: 加载仪器类型名表
  ----------------------------------------------------------------------------- }
function LoadMeterTypes(ParamBook: IXLSWorkBook): Boolean;
var
  Sht : IXLSWorksheet;
  iRow: Integer;
  S   : string;
begin
  Result := False;
  PG_MeterTypes.Clear;
  Sht := ExcelIO.GetSheet(ParamBook, { '预定义项' } SHTPREDEFINE);
  if Sht = nil then
    Exit;
  for iRow := 2 to Sht.UsedRange.LastRow + 1 do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 1].Value));
    if S = '' then
      Continue;
    PG_MeterTypes.Add(S);
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadProjectLocations
  Description: 加载工程部位定义表
  ----------------------------------------------------------------------------- }
function LoadProjectLocations(ParamBook: IXLSWorkBook): Boolean;
var
  Sht : IXLSWorksheet;
  iRow: Integer;
  S   : string;
begin
  Result := False;
  PG_Locations.Clear;
  Sht := ExcelIO.GetSheet(ParamBook, { '预定义项' } SHTPREDEFINE);
  if Sht = nil then
    Exit;
  for iRow := 2 to Sht.UsedRange.LastRow + 1 do
  begin
    S := Trim(VarToStr(Sht.Cells[iRow, 3].Value));
    if S <> '' then
      PG_Locations.Add(S);
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadTrendLinePreDefines
  Description: 加载过程线预定义表内容
  ----------------------------------------------------------------------------- }
function LoadTrendLinePreDefines(ParamBook: IXLSWorkBook): Boolean;
(*
  var
  Sht     : IXLSWorksheet;
  S, sName: string;
  iRow    : Integer;
  NewDF   : TTrendlinePreDefine;
*)
begin
  (*
    Result := False;
    // 先清空集合
    for NewDF in TLPreDefines.Values do NewDF.Free;
    TLPreDefines.Clear;

    Sht := ExcelIO.GetSheet(ParamBook, '过程线预定义');
    if Sht = nil then Exit;
    for iRow := 2 to 1000 do
    begin
    // define name
    sName := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
    if sName = '' then Break;

    NewDF := TTrendlinePreDefine.Create;
    // type string
    S := Trim(VarToStr(Sht.Cells[iRow, 3].Value));
    // define string
    S := Trim(VarToStr(Sht.Cells[iRow, 4].Value));
    NewDF.DecodeDefine(S);
    NewDF.Name := sName; // decodedefine的时候，要Clear一次，结果删除了Name
    // annotation string
    S := Trim(VarToStr(Sht.Cells[iRow, 5].Value));
    TLPreDefines.Add(NewDF.Name, NewDF);
    end;
  *)
end;

function LoadTemplates(ParamBook: IXLSWorkBook): Boolean;
var
  Sht     : IXLSWorksheet;
  S, sName: string;
  iRow    : Integer;
  ct      : TChartTemplate;
  wg      : TWebGridTemplate;
  xl      : TXLGridTemplate;
  ts      : TTemplates;
begin
  // 清空集合
  ts := IAppServices.Templates as TTemplates;
  // 如果没有加载Templates相关的单元，ts就等于nil。对于剪裁功能的程序来说，往往工程中没有包含
  // templates相关的系列单元
  if ts = nil then
    Exit;

  ts.ClearAll;
  // 加载ChartTemplates
  Sht := ExcelIO.GetSheet(ParamBook, { '过程线模板' } SHTCHARTTEMPLS);
  if Sht <> nil then
    for iRow := 2 to 1000 do
    begin
      sName := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
      if sName = '' then
        Break;

      ct := ts.AddChartTemplate(TChartTemplate) as TChartTemplate;
      ct.TemplateName := sName;
      // type
      S := Trim(VarToStr(Sht.Cells[iRow, 3].Value));
      if S = '过程线' then
        ct.ChartType := cttTrendLine
      else if S = '矢量图' then // 用来绘制平面位移矢量图，单个测点
        ct.ChartType := cttVector
      else if S = '散点图' then // 可用来显示散点或测斜孔倾斜曲线
        ct.ChartType := cttPoints
      else if S = '棒图' then
        ct.ChartType := cttBar
      else if S = '竖线图' then // 可用来显示测斜孔倾斜曲线
        ct.ChartType := cttHoriLine
      else if S = '位移图' then // 可用来显示分布图，横轴非日期
        ct.ChartType := cttDisplacement;

      // template str
      S := Trim(VarToStr(Sht.Cells[iRow, 4].Value));
      ct.TemplateStr := S;
      // annotation
      S := Trim(VarToStr(Sht.Cells[iRow, 5].Value));
      ct.Annotation := S;
    end;

  Sht := ExcelIO.GetSheet(ParamBook, { 'WebGrid基本表模板' } SHTWGTEMPLS);
  if Sht <> nil then
    for iRow := 2 to 1000 do
    begin
      sName := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
      if sName = '' then
        Break;

      wg := ts.AddWGTemplate(TWebGridTemplate) as TWebGridTemplate;
      wg.TemplateName := sName;

      // 仪器类型属性已经写入了模板代码，在设置模板代码时会设置，这里就不从表中读取了。

      // template string
      S := Trim(VarToStr(Sht.Cells[iRow, 4].Value));
      wg.TemplateStr := S;
      // annotation
      S := Trim(VarToStr(Sht.Cells[iRow, 5].Value));
      wg.Annotation := S;
    end;

  Sht := ExcelIO.GetSheet(ParamBook, { 'Excel基本表模板' } SHTXLTEMPLS);
  if Sht <> nil then
    for iRow := 2 to 1000 do
    begin
      sName := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
      if sName = '' then
        Break;

      xl := ts.AddXLTemplate(TXLGridTemplate) as TXLGridTemplate;
      xl.TemplateName := sName;
      // meter type
      S := Trim(VarToStr(Sht.Cells[iRow, 3].Value));
      xl.MeterType := S;
      // group
      S := Trim(VarToStr(Sht.Cells[iRow, 4].Value));
      if S = '否' then
        xl.ApplyGroup := False
      else
        xl.ApplyGroup := True;
      // sheet name
      S := Trim(VarToStr(Sht.Cells[iRow, 5].Value));
      xl.TemplateSheet := S;
      // xlgrid type
      S := Trim(VarToStr(Sht.Cells[iRow, 6].Value));
      if S = '动态行' then
        xl.GridType := xlgdynrow
      else if S = '动态列' then
        xl.GridType := xlgdyncol
      else if S = '静态表' then
        xl.GridType := xlgstatic;
      // title range
      S := Trim(VarToStr(Sht.Cells[iRow, 7].Value));
      xl.TitleRangeRef := S;
      // head range
      S := Trim(VarToStr(Sht.Cells[iRow, 8].Value));
      xl.HeadRangeRef := S;
      // data range
      S := Trim(VarToStr(Sht.Cells[iRow, 9].Value));
      xl.DataRangeRef := S;
      // annotation
      S := Trim(VarToStr(Sht.Cells[iRow, 10].Value));
      xl.Annotation := S;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : _FindMeter
  Description:  内部使用。在基本参数表、工程属性表、数据格式表中查找指定设计
  编号的监测仪器
  ----------------------------------------------------------------------------- }
function _FindMeter(Sht: IXLSWorksheet; AName: string; StartRow: Integer = 1): Integer;
var
  iRow : Integer;
  S, S1: string;
begin
  Result := 0;
  S1 := UpperCase(AName);
  for iRow := StartRow to Sht.UsedRange.LastRow + 1 do
  begin
    { todo: 将这里的列号改为由定义表取列号，以增强程序未来的适应力 }
    S := UpperCase(Trim(VarToStr(Sht.Cells[iRow, 2].Value)));
    if S = S1 then
    begin
      Result := iRow;
      Break;
    end;
  end;
end;

function _FindBlankRow(Sht: IXLSWorksheet; StartRow: Integer = 1): Integer;
begin
  for Result := StartRow to Sht.UsedRange.LastRow + 1000 do
    if Trim(VarToStr(Sht.Cells[Result, 2].Value)) = '' then
      Exit;
  Result := 0;
end;

function _ChangeDesignName(Sht: IXLSWorksheet; ACol: Integer; OldName, NewName: string): Boolean;
var
  iRow: Integer;
begin
  Result := False;
  iRow := _FindMeter(Sht, OldName, 1);
  if iRow <> 0 then
  begin
    Sht.Cells[iRow, ACol].Value := NewName;
    Result := True;
  end;
end;

function _SaveMeterBaseParams(Sht: IXLSWorksheet; AMeter: TMeterDefine; NewMeter: Boolean): Boolean;
var
  iRow: Integer;
begin
  Result := False;
  if NewMeter then
    iRow := _FindBlankRow(Sht, 4)
  else
    iRow := _FindMeter(Sht, AMeter.DesignName, 4);
  if iRow = 0 then
    Exit;

  with theCols do
  begin
    if NewMeter then
    begin
      Sht.Cells[iRow, 1].Value := iRow - 3;
      Sht.Cells[iRow, PRM.Col['DesignName']].Value := AMeter.DesignName;
    end;
    Sht.Cells[iRow, PRM.Col['MeterType']].Value := AMeter.Params.MeterType;
    Sht.Cells[iRow, PRM.Col['Model']].Value := AMeter.Params.Model;
    Sht.Cells[iRow, PRM.Col['SerialNo']].Value := AMeter.Params.SerialNo;
    Sht.Cells[iRow, PRM.Col['WorkMode']].Value := AMeter.Params.WorkMode;
    Sht.Cells[iRow, PRM.Col['MinValue']].Value := AMeter.Params.MinValue;
    Sht.Cells[iRow, PRM.Col['MaxValue']].Value := AMeter.Params.MaxValue;
    Sht.Cells[iRow, PRM.Col['SensorsCount']].Value := AMeter.Params.SensorCount;
    Sht.Cells[iRow, PRM.Col['MDCount']].Value := AMeter.Params.MDCount;
    Sht.Cells[iRow, PRM.Col['PDCount']].Value := AMeter.Params.PDCount;
    Sht.Cells[iRow, PRM.Col['Annotation']].Value := AMeter.Params.Annotation;
    Sht.Cells[iRow, PRM.Col['SetupDate']].Value := AMeter.Params.SetupDate;
    Sht.Cells[iRow, PRM.Col['BaseDate']].Value := AMeter.Params.BaseDate;
  end;

  Result := True;
end;

function _SaveMeterDataStructure(Sht: IXLSWorksheet; AMeter: TMeterDefine;
  NewMeter: Boolean): Boolean;
var
  iRow                   : Integer;
  sDFStr, sColStr, sEVDef: string;
  procedure GetDataDefineStr(DFList: TDataDefines);
  var
    i: Integer;
  begin
    sDFStr := '';
    sColStr := '';
    sEVDef := '';
    if DFList.Count = 0 then
      Exit;
    for i := 0 to DFList.Count - 1 do
    begin
      sDFStr := sDFStr + DFList.Items[i].Name + '|';
      sColStr := sColStr + IntToStr(DFList.Items[i].Column) + '|';
      if DFList.Items[i].HasEV then
        sEVDef := sEVDef + IntToStr(i + 1) + '|';
    end;
    // 去掉末尾的空格
    if sDFStr <> '' then
      sDFStr := copy(sDFStr, 1, Length(sDFStr) - 1);
    if not sColStr.IsEmpty then
      sColStr := copy(sColStr, 1, sColStr.Length - 1);
    if not sEVDef.IsEmpty then
      sEVDef := copy(sEVDef, 1, sEVDef.Length - 1);
  end;

begin
  Result := False;
  if NewMeter then
    iRow := _FindBlankRow(Sht, 5)
  else
    iRow := _FindMeter(Sht, AMeter.DesignName, 5);
  if iRow = 0 then
    Exit;

  with theCols do
  begin
    if NewMeter then
    begin
      Sht.Cells[iRow, 1].Value := iRow - 4;
      Sht.Cells[iRow, theCols.DAT.Col['DesignName']].Value := AMeter.DesignName;
    end;
    Sht.Cells[iRow, DAT.Col['MeterType']].Value := AMeter.Params.MeterType;
    Sht.Cells[iRow, DAT.Col['DTStartRow']].Value := AMeter.DataSheetStru.DTStartRow;
    Sht.Cells[iRow, DAT.Col['DTStartCol']].Value := AMeter.DataSheetStru.DTStartCol;
    Sht.Cells[iRow, DAT.Col['Annotation']].Value := AMeter.DataSheetStru.AnnoCol;
    Sht.Cells[iRow, DAT.Col['BaseLine']].Value := AMeter.DataSheetStru.BaseLine;
    GetDataDefineStr(AMeter.DataSheetStru.MDs);
    Sht.Cells[iRow, DAT.Col['MDDefine']].Value := sDFStr;
    Sht.Cells[iRow, DAT.Col['MDCols']].Value := sColStr;
    GetDataDefineStr(AMeter.DataSheetStru.PDs);
    Sht.Cells[iRow, DAT.Col['PDDefine']].Value := sDFStr;
    Sht.Cells[iRow, DAT.Col['PDCols']].Value := sColStr;
    Sht.Cells[iRow, DAT.Col['EVItems']].Value := sEVDef;
  end;

  Result := True;
end;

function _SaveMeterProjectParams(Sht: IXLSWorksheet; AMeter: TMeterDefine;
  NewMeter: Boolean): Boolean;
var
  iRow: Integer;
begin
  Result := False;
  if NewMeter then
    iRow := _FindBlankRow(Sht, 4)
  else
    iRow := _FindMeter(Sht, AMeter.DesignName, 4);
  if iRow = 0 then
    Exit;
  with theCols do
  begin
    if NewMeter then
    begin
      Sht.Cells[iRow, 1].Value := iRow - 3;
      Sht.Cells[iRow, PRJ.Col['DesignName']].Value := AMeter.DesignName;
    end;
    Sht.Cells[iRow, PRJ.Col['MeterType']].Value := AMeter.Params.MeterType;
    Sht.Cells[iRow, PRJ.Col['SubProject']].Value := AMeter.PrjParams.SubProject;
    Sht.Cells[iRow, PRJ.Col['Position']].Value := AMeter.PrjParams.Position;
    Sht.Cells[iRow, PRJ.Col['Elevation']].Value := AMeter.PrjParams.Elevation;
    Sht.Cells[iRow, PRJ.Col['Stake']].Value := AMeter.PrjParams.Stake;
    Sht.Cells[iRow, PRJ.Col['Profile']].Value := AMeter.PrjParams.Profile;
    Sht.Cells[iRow, PRJ.Col['Deep']].Value := AMeter.PrjParams.Deep;
    Sht.Cells[iRow, PRJ.Col['Annotation']].Value := AMeter.PrjParams.Annotation;
  end;
  Result := True;
end;

function _SaveMeterDataSource(Sht: IXLSWorksheet; AMeter: TMeterDefine; NewMeter: Boolean): Boolean;
var
  iRow: Integer;
begin
  Result := False;
  if NewMeter then
    iRow := _FindBlankRow(Sht, 3)
  else
    iRow := _FindMeter(Sht, AMeter.DesignName, 3);
  if iRow = 0 then
    Exit;
  Sht.Cells[iRow, 1].Value := iRow - 2;
  Sht.Cells[iRow, 2].Value := AMeter.DesignName;
  Sht.Cells[iRow, 3].Value := AMeter.DataSheet;
  Sht.Cells[iRow, 4].Value := AMeter.DataBook;
end;

{ -----------------------------------------------------------------------------
  Procedure  : SaveParams
  Description: 保存参数，或创建新仪器的参数。本函数不改变仪器的设计编号
  ----------------------------------------------------------------------------- }
function SaveParams(AMeter: TMeterDefine; NewMeter: Boolean = False): Boolean;
var
  Wbk : IXLSWorkBook;
  Sht : IXLSWorksheet;
  iRow: Integer;
begin
  Result := False;
  // Open parameter workbook
  Wbk := TXLSWorkbook.Create;
  if ExcelIO.OpenWorkbook(Wbk, xlsParamFile) = False then
    Exit;
  if Wbk = nil then
    Exit;

  // Open meter's parameter worksheet
  Sht := ExcelIO.GetSheet(Wbk, '仪器基本属性表');
  _SaveMeterBaseParams(Sht, AMeter, NewMeter);

  { todo:完善保存工程参数和数据格式参数的选项 }
end;

{ -----------------------------------------------------------------------------
  Procedure  : SaveParams
  Description: 保存参数，本函数允许改变仪器的设计编号
  ----------------------------------------------------------------------------- }
function SaveParams(AMeter: TMeterDefine; OldName: string): Boolean;
// var
// Wbk: IXLSWorkBook;
// Sht: IXLSWorksheet;
begin
  Result := False;
  // 先改名，再调用SaveParams

  // 调用SaveParams
  Result := SaveParams(AMeter);
end;

{ -----------------------------------------------------------------------------
  Procedure  : AppendDataSheet
  Description: 保存一个仪器工作表到仪器数据文件列表工作簿中
  ----------------------------------------------------------------------------- }
function AppendDataSheet(ADsnName, ASheetName, ABookName, AMeterType, APosition: string): Integer;
var
  Wbk : IXLSWorkBook;
  Sht : IXLSWorksheet;
  i, j: Integer;
  S   : string;
begin
  Result := 0;
  if ExcelIO.OpenWorkbook(Wbk, xlsDFListFile) = False then
  begin
    ShowMessage('打开数据文件列表工作簿失败，手工添加算了。');
    Exit;
  end;
  Sht := ExcelIO.GetSheet(Wbk, '仪器数据文件列表');
  if Sht = nil then
  begin
    ShowMessage('No found datalist sheet, do it by youself.');
    Exit;
  end;

  // 倒序查找最后一行
  for i := Sht.UsedRange.Rows.Count + 3 downto 3 do
  begin
    // 如果是空行则继续，直到找到最后一行（有内容的）
    if VarToStr(Sht.Cells[i, 2].Value) = '' then
      Continue
    else
    begin
      // 找到后，第i+1行为最后一行之后的空行
      Sht.Cells[i + 1, 1].Value := i + 1;
      Sht.Cells[i + 1, 2].Value := ADsnName;
      Sht.Cells[i + 1, 3].Value := ASheetName;
      Sht.Cells[i + 1, 4].Value := ExtractFileName(ABookName);
      Sht.Cells[i + 1, 5].Value := AMeterType;
      Sht.Cells[i + 1, 6].Value := APosition;
      for j := 1 to 6 do
      begin
        with Sht.Cells[i + 1, j].Font do
        begin
          name := 'Consolas';
          size := 9;
          Italic := True;
        end;
      end;
      Break;
    end;
  end;
  Result := Wbk.Save;
end;

class function THJXExcelParam.UpdateParam(DsnName: string; ParamName: string;
  ParamValue: Variant): Boolean;
var
  iRow, iCol: Integer;
  Wbk       : IXLSWorkBook;
  Sht       : IXLSWorksheet;
begin
  Result := False;
  if not IsMeterParam(ParamName) then
    Exit;
  { 如果ParamName=DesignName，则退出，不允许在UpdateParam中修改设计编号 }
  if SameText(ParamName, 'DesignName') then
    Exit;

  Wbk := TXLSWorkbook.Create;
  if ExcelIO.OpenWorkbook(Wbk, xlsParamFile) = False then
    Exit;
  { 查看参数是否在PRM中 }
  iCol := theCols.PRM.Col[ParamName];
  if iCol <> 0 then
  begin
    Sht := ExcelIO.GetSheet(Wbk, SHTSENSORPARAMS);
    if Sht = nil then
      Exit;
    iRow := _FindMeter(Sht, DsnName);
    if iRow = 0 then
      Exit;

    Sht.Cells[iRow, iCol].Value := ParamValue;
  end;

  iCol := theCols.PRJ.Col[ParamName];
  if iCol <> 0 then
  begin
    Sht := ExcelIO.GetSheet(Wbk, SHTPRJPARAMS);
    if Sht = nil then
      Exit;
    iRow := _FindMeter(Sht, DsnName);
    if iRow = 0 then
      Exit;
    Sht.Cells[iRow, iCol].Value := ParamValue;
  end;
  Wbk.Save;
  Result := True;
  { 保存成功后，应更新仪器对象参数 }
end;

class function THJXExcelParam.IsMeterParam(ParamName: string): Boolean;
begin
  // 在theCols的prj,prm,dat中找参数
  Result := theCols.PRJ.Col[ParamName] <> 0;
  if not Result then
    Result := theCols.PRM.Col[ParamName] <> 0;
  if not Result then
    Result := theCols.DAT.Col[ParamName] <> 0;
end;

class function THJXExcelParam.ListMeterParamNames: String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to theCols.PRM.Count - 1 do
    Result := Result + theCols.PRM.Item[i].ParamName + #13#10;
  for i := 0 to theCols.PRJ.Count - 1 do
    Result := Result + theCols.PRJ.Item[i].ParamName + #13#10;
end;

{ -----------------------------------------------------------------------------
  Procedure  : OpenProject
  Description: 如果LoadNew，则打开新的配置文件。否则就从SummaryReport.ini中
  找到配置文件，打开
  ----------------------------------------------------------------------------- }
procedure OpenProject(LoadNew: Boolean = False);
var
  Init: TIniFile;
  dlg : TOpenDialog;
  S   : String;
  FN  : STRING; // Exefile name

  procedure __LoadPrj(PrjFile: String);
  begin
    if LoadProjectConfig(PrjFile) then
    begin
      // 产生登录事件、数据库连接事件
      IAppServices.OnLogin(nil);
      IAppServices.OnRemoteConnect(nil);
    end;
  end;
  procedure __OpenLoad;
  begin
    dlg.Title := '打开工程配置文件';
    dlg.Filter := 'Excel文件|*.xls;*.xlsx';
    if S <> '' then
      dlg.InitialDir := ExtractFileDir(S)
    else
      dlg.InitialDir := ExtractFileDir(Application.ExeName);
    dlg.Options := [ofOverwritePrompt, ofPathMustExist, ofFileMustExist];
    if dlg.Execute then
    begin
      __LoadPrj(dlg.FileName);
      Init.WriteString('工程文件', '配置文件', dlg.FileName);
    end;
  end;

begin

  S := ExtractFilePath(Application.ExeName);
  FN := ExtractFileName(Application.ExeName);
  FN := copy(FN, 1, Pos('.', FN) - 1) + '.ini'; // 去掉扩展名，变成同名ini

  // ExtractFileExt(fn);
  // 先看看有没有配置文件
  dlg := TOpenDialog.Create(nil);
  Init := TIniFile.Create(S + FN);
  ENV_InitFile := S + FN;

  try
    if FileExists(S + FN) then
    begin
      S := Trim(Init.ReadString('工程文件', '配置文件', ''));
      if Not FileExists(S) then
        S := '';
    end
    else
      S := '';

    if LoadNew then
      __OpenLoad
    else if S <> '' then
      __LoadPrj(S)
    else
      __OpenLoad;
  finally
    dlg.FreeOnRelease;
    Init.Free;
  end;
end;

procedure RegManager;
begin
  // 因修改了LoadProject参数，导致暂时不能注册这个方法
  // IAppServices.RegisterOpenDBManProc(OpenProject);
end;

initialization

theCols := TParamCols.Create;
IssueList := TStringList.Create;
RegManager;

finalization

theCols.Free;
IssueList.Free;

end.
