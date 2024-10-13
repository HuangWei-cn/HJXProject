{ -----------------------------------------------------------------------------
  Unit Name: uInitParams
  Author:    ��ΰ
  Date:      31-����-2017
  Purpose:   ����Ԫ���ڳ�ʼ������������
  ����������Դ�ڡ�����������.xls��������Ӳ������м�������ĸ��������
  ����������ϣ������϶���ExcelMeters�������ˡ�
  History:
  2018-06-21
  ���������ļ������������ݸ�Ŀ¼����ʱĿ¼����������ļ������·����
  ������������������Щ����·�����ڼ��������ļ�ʱ������Щ·��Ϊ����
  ·����
  ��Ҫ��һ��������·�����ֲ�ͼ·�������ý�������ý��в�����
  2018-07-24
  �����˶����ݽṹԤ�����Ķ�ȡ����д���������ݽṹ�������ݵļ���
  ����ʹ��Ԥ����ṹ�����ظ��ǡ�
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
  { ����Excel�����仯���� }
  TMeterExcelParamChanged = (mepcBase, mepcProject, mepcDataStru, mepcDataFile, mepcDataView,
    mepcChartStyle, mepcGroup);
  { �����仯���� }
  TMeterExcelParamchangedSet = set of TMeterExcelParamChanged;

  { ������������ }
  THJXExcelParam = class
  public
    { ����һ������ֵ }
    class function UpdateParam(DsnName: String; ParamName: String; ParamValue: Variant): Boolean;
    { ���������Ƿ���ڣ���ParamName�Ƿ��ǺϷ����� }
    class function IsMeterParam(ParamName: String): Boolean;
    { �г����������� }
    class function ListMeterParamNames: String;
  end;

  { �򿪼��ع����ļ��Ի������û�ѡ���˹����ļ��������֮����������ע�ᵽAppServices����Ϊ
    AppServices.OpenDatabaseManager����ʵ��ִ���ߡ�������ִ����Ϻ󣬸��ݼ����������ϵ���¼� }
procedure OpenProject(LoadNew: Boolean = False);

{ ���ع��������ļ������ļ�ָ���˲����ļ��������б��ļ����ڣ����������Щ��һ���� }
function LoadProjectConfig(prjBookName: string): Boolean;
{ ���ز����ļ������������������������̲��������ݽṹ����� }
function LoadParams(ParamBook: IXLSWorkBook): Boolean;
{ �������������ļ��б���ÿ����������Ӧ�Ĺ������͹�����ֵ��Meter�Ķ�Ӧ���� }
function LoadDataFileList(DFBook: IXLSWorkBook): Boolean;
{ ���ز���ͼ����� 2018-06-07 }
function LoadLayoutList(DFBook: IXLSWorkBook): Boolean;
{ �����ֶ����б��ñ�������������-��Ӧ�����������磺MeterType - �������͵ȡ�����ֶ�������Ҫ����
  �����༭��������ʾ������������� }
function LoadFieldDispNames(ParamBook: IXLSWorkBook): Boolean;
{ ����Ԥ������������ͱ� }
function LoadMeterTypes(ParamBook: IXLSWorkBook): Boolean;
{ ����Ԥ����Ĺ��̲�λ�б� }
function LoadProjectLocations(ParamBook: IXLSWorkBook): Boolean;
{ ���������鶨�� }
function LoadMeterGroup(ParamBook: IXLSWorkBook): Boolean;
{ ���ع�����Ԥ����  2018-09-03��������LoadTemplates������� }
function LoadTrendLinePreDefines(ParamBook: IXLSWorkBook): Boolean;
{ ����ģ�壺ChartTemplates��WebGridTemplates��XLSGridTemplates�� }
function LoadTemplates(ParamBook: IXLSWorkBook): Boolean;
{ ������������Ѵ��ڵ��������ı�����Ʊ�ţ��������µ��������� }
function SaveParams(AMeter: TMeterDefine; NewMeter: Boolean = False): Boolean; overload;
{ ����������������������Ʊ�� }
function SaveParams(AMeter: TMeterDefine; OldName: string): Boolean; overload;
{ ���µ������� }
// function UpdateParam(ADsnName: string; ParamName: string; Param:Variant):Boolean;

{ ���һ�����������ݹ��������������ļ��б������� }
function AppendDataSheet(ADsnName, ASheetName, ABookName, AMeterType, APosition: string): Integer;

var
  { ��������ȫ�ֱ������ڱ༭�����ļ�ʱ�����ٷ�����Щ�������ļ���ʡ�Ĵ򿪹����ļ���ȥ�� }
  xlsPrjFile   : string;   // ���������ļ�
  xlsParamFile : string;   // �����ļ�
  xlsDFListFile: string;   // ���ݹ������б��ļ�
  xlsEventsFile: string;   // ����¼��������ļ�
  IssueList    : TStrings; // �������ع��������б�

implementation

uses
  uHJX.EnvironmentVariables, uHJX.Excel.Meters, System.RegularExpressions, System.IOUtils,
  System.IniFiles,
  // uTLDefineProc {2018-07-26 ������ģ������嵥Ԫ��ͬʱ�������ģ����룬��ʱ������Ԫֱ������};
  uHJX.Classes.Templates, uHJX.Template.ChartTemplate, uHJX.Template.WebGrid,
  uHJX.Template.XLGrid;

type
  { �������ж���ṹ }
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

  { TParamCols���ڷ���Excel�����ļ�ʱ��ָ����������������Ӧ�Ĺ������кš���������Ѿ��ڲ�����
    �еġ�ParamSheetStructure����������Ԥ�ȶ�����ˣ����ز���֮ǰ���ȶ�ȡ������еĶ��壬����
    �������Ժ��ȡ����ʱ��ͨ��������ɻ�ȡ������Ӧ�������ڵ��� }
  /// <summary>������ṹ���壬����-�к� </summary>
  TParamCols = class
  public
    PRJ: TParamColsList;
    PRM: TParamColsList;
    DAT: TParamColsList;
    GRP: TParamColsList; // 2018-05-29 ���������鶨��ṹ
    DPD: TParamColsList; // 2018-07-24 �������ݱ�ṹԤ����ṹ
    TLD: TParamColsList; // 2018-07-24 ���ӹ�����Ԥ����ṹ
    WGT: TParamColsList; // WebGrid Template sheet structure define
    XLT: TParamColsList; // XLGrid template sheet structure define
    constructor Create;
    destructor Destroy; override;
  end;

const
  MAXMETERNUMBER = 5000;
  PathPattern    = '^[a-zA-Z]:(((\\(?! )[^/:*?<>\""|\\]+)+\\?)|(\\)?)\s*$'; // �ļ�·��������ʽ

  // 2018-09-19���������������
  /// <summary>���������ļ���������ṹ����</summary>
  SHTSTRUDEFINE = 'ParamSheetStructure';
  /// <summary>������������������������Ϊ��</summary>
  SHTSENSORPARAMS = '�����������Ա�';
  /// <summary>��������������Ա��粿λ��׮�š��̡߳���װ���ڵ�</summary>
  SHTPRJPARAMS = '�����������Ա�';
  /// <summary>����������ݼ�����ʽ�����</summary>
  SHTMETERDATAS = '�������ݸ�ʽ����';
  /// <summary>�ֶ�������Ҫ�������������ֶ����Ͷ�Ӧ������������ʾ�����֣�</summary>
  SHTDSNAME = '�ֶ�����';
  /// <summary>Ԥ��������ݣ����������͡����̲�λ</summary>
  SHTPREDEFINE = 'Ԥ������';
  /// <summary>�����鶨�壬����-������������</summary>
  SHTGROUPDEFINE = '�����鶨���';
  /// <summary>������������Ԥ��������ݱ��ʽ��һ��������������ݽṹָ�������ĸ�Ԥ�����
  /// ���������ض������ã����ز���ʱ��Ԥ����ĸ�ʽ�滻֮��
  /// </summary>
  SHTDATASTRUC = '���ݸ�ʽԤ����';
  /// <summary>����Chartģ��</summary>
  SHTCHARTTEMPLS = '������ģ��';
  /// <summary>�����۲����ݵ�WebGrid��ʽ��ģ�壬EhGridҲ��ʹ�����ģ��</summary>
  SHTWGTEMPLS = 'WebGrid������ģ��';
  /// <summary>����Excel��ʽ���ݱ���ʹ�õ�ģ��Ŀ¼��ģ�屾��������һ��Excel�ļ���</summary>
  SHTXLTEMPLS = 'Excel������ģ��';

var
  // PARAMCOLS: TParamStruColDefine;
  // ��������������������ṹ���壬���ڿ��ٷ��ʲ�����
  theCols     : TParamCols;
  DataFilePath: string; // �����ļ���·�������ļ��б������C1��Ԫ��

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
    ShowMessage('��������û�С�ParamSheetStructure������������ܴ���'#13#10 + '�ٵĲ��������ټ��һ�¡�');
    Exit;
  end;

  // �������Ա�ṹ����
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

  // �������Ա�ṹ����
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

  // ���ݸ�ʽ����
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

  // 2018-05-29 �������ʽ����
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

  // 2018-07-24���ݱ��ʽԤ����
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

  // 2018-07-24 ������Ԥ����
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

  // 2018-09-13 WebGridģ�嶨���ṹ
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

  // 2018-09-13 XLGridģ�嶨��ṹ
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
  Description: �����������̲���
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
  Sht := ExcelIO.GetSheet(ParamBook, '�����������Ա�');
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
  Description: ��������������ʵ��Ӧ�����Ǵ�����������
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
  Sht := ExcelIO.GetSheet(ParamBook, { '�����������Ա�' } SHTSENSORPARAMS);
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
  Description: �����ݽṹ������ж�ȡһ�У����������������д��DSS�С�
  ����������Ҫ�õ���������Ԥ����ṹ�� �� �������ݽṹ��������߷ֱ���Ԥ����
  ���ع��̺��������ݶ�����ع��̴���
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
    { TODO:��Ҫ��������������ͬ��������Լ���MDCount��PDCount��һ�µ���� }
    if (Length(SS1) > 0) { and (Length(SS2) > 0) } then
      for i := low(SS1) to high(SS1) do
      begin
        pdd := DDs.AddNew;
        pdd.Name := SS1[i];
        // �п���û���ṩ�кţ���ʱSS2�������顣
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
  DSS.ChartDefineName := StrValue('ChartTemplate'); // 2018-07-26 ��ȡͼ������
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
  Description: ��������LoadDatasheetStru���ƣ��ɴ�˵����������LoadDataSheetStru
  �����Ļ������޸Ķ�����Ϊʡ�£�û�н������������ƴ�������Ż����������������ˡ�
  ----------------------------------------------------------------------------- }
function LoadPreDefineDataStru(ParamBook: IXLSWorkBook): Boolean;
var
  iRow    : Integer;
  Sht     : IXLSWorksheet;
  S       : string;
  PreDItem: TPreDefineDataStructure;
begin
  Result := False;
  Sht := ExcelIO.GetSheet(ParamBook, { '���ݸ�ʽԤ����' } SHTDATASTRUC);
  if Sht = nil then
  begin
    ShowMessage('������������û�а���"���ݸ�ʽԤ����"�����������Ǿɰ�����ļ���'#13#10'����²����ļ��������档');
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
  Description: �����������ݱ�ṹ�����¼
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

{ �ñ��������滻Ԥ���� }
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

    // ����Templates name��֮�����ö���
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
    // ���渲��MDs��LocalDefine��MDs�����������(PDs��ͬ):
    // 1. ���������У�������ȣ�ֱ�Ӹ���ȫ����
    // 2. ���������У�������ȣ���������
    // 3. ���������У�������ͬ�����ظ���Ԥ���壬ʹ֮�뱾����ͬ��
    if LocalDefine.MDs.Count > 0 then
      ReplaceDataDefines(LocalDefine.MDs, AMeter.DataSheetStru.MDs);
    if LocalDefine.PDs.Count > 0 then
      ReplaceDataDefines(LocalDefine.PDs, AMeter.DataSheetStru.PDs);
  end;

begin
  Result := False;
  Sht := ExcelIO.GetSheet(ParamBook, { '�������ݸ�ʽ����' } SHTMETERDATAS);
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

      // ��ȡԤ��������
      S1 := Trim(VarToStr(Sht.Cells[iRow, 4].Value));
      if S1 <> '' then
      begin
        // ���S1��Ϊ�գ����Ԥ��������ȡ�����ã�����д��������DataSheetStru������
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

      // ���������������ã��������������в�Ϊ�յ�ֵ���򸲸�Ԥ����ֵ��
      ClearLocalDefine;
      LoadDataStruRecord(Sht, iRow, LocalDefine, theCols.DAT);
      { �������ø���Ԥ�������ã���һЩ�����������:
        1. ��Ҫ�����������ƣ����Բ������кţ�
        2. ��Ҫ���������кţ��ͱ����ṩ�������ƣ�
        3. ������ʼ�С���ʼ�С���ֵ�С���ע�еȿ��Ե������ã���Ӱ������
        4. �������ơ�������Ҫ���ǣ��ͱ����ṩ�����ģ��޷�ֻ�������е�ĳһ�
      }
      RecoverByLocal;

      // �ɷ��������������������õ�������DataSheetStru�����С�
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
  Description: ����������������
  ----------------------------------------------------------------------------- }
function LoadParams(ParamBook: IXLSWorkBook): Boolean;
begin
  Result := False;
  // �ȼ��ز����ļ��ṹ�����
  if not GetParamSheetStructure(ParamBook) then
  begin
    ShowMessage('δ�ܼ��ز����ļ��ṹ���壬�޷���ɳ�ʼ���������ع��̡�');
    Exit;
  end;

  // ���ع��̲�λ������������Ҫ����PosIndexֵ
  LoadProjectLocations(ParamBook);

  // ���ع��̲����������ﴴ����������Ҳ����˵��ֻ����������ж���������Żᱻ����������������
  // �е���������ڹ��̱���û�У��򲻻ᱻ������
  LoadProjectParams(ParamBook);
  // �������ݽṹԤ�����
  LoadPreDefineDataStru(ParamBook);
  // ���ع�����Ԥ�����
  LoadTrendLinePreDefines(ParamBook);
  // ����ģ�嶨��
  LoadTemplates(ParamBook);
  // ���ػ���������
  LoadMeterParams(ParamBook);
  // �������ݽṹ�����
  LoadDataSheetStru(ParamBook);
  // ���������鶨���
  LoadMeterGroup(ParamBook);
  // �����ֶ����б�
  LoadFieldDispNames(ParamBook);
  // �������������б�
  LoadMeterTypes(ParamBook);

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadDataFileList
  Description: �������������ļ��б����
  ----------------------------------------------------------------------------- }
function LoadDataFileList(DFBook: IXLSWorkBook): Boolean;
var
  Sht           : IXLSWorksheet;
  iRow          : Integer;
  S, sSht, sBook: string;
  AMeter        : TMeterDefine;
begin
  Result := False;
  Sht := ExcelIO.GetSheet(DFBook, '���������ļ��б�');
  if Sht = nil then
    Exit;
  // ȡ�����ļ��У��������ļ��ľ���·����������Կ��ǣ������C1��Ԫ��δָ������·�������ļ��б���
  // ���·�����򵯴����û�ѡ�������ļ������ļ��У�����������ʹ�õ�����ԡ�
  DataFilePath := Trim(ExcelIO.GetStrValue(Sht, 1, 3)); // C1��Ԫ��

  // ��֤Datafilepath�Ƿ���ڡ��Ƿ���ȷ
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
    { todo:��������ж�һ��sBook�Ƿ���һ������·����֮�����ж�һ���ļ��Ƿ���� }
    { 2018-06-06
      �����Ĵ����жϹ���Ӧ�ǣ�1- �ж�sBook�Ƿ�Ϊ�Ϸ�·�����������ж��ļ��Ƿ���ڣ�����������֪ͨ
      �û���������ѡ��ȷ���ļ�����ɴ���������������� 2- �ж�DataFilePath�Ƿ�Ϊ�ա��Ƿ���Ч����
      Ϊ�ջ���Ч��֪ͨ�û�ѡ��һ����Ч��·����֮�� 3- ��DataFilePath��sBook�ϳ�Ϊ�����ļ�·����
      ͨ��������ʽ�жϺϳɽ���Ƿ���Ч������Ч���ж��Ƿ���ڣ�����Ч�򲻴�����֪ͨ�û���ѡ�ļ�
      �������
      Ϊ���Ч�ʣ�����жϵ�sBook�ʹ������������棬��������ͬ��sBookֱ�Ӳ��ô�������

      Ŀǰ�Ĵ������sBookȫ��Ϊ���·��������ǰ��"\"���ţ�C1��Ԫ���DataFilePath�ַ���Ϊ����·����
      ��ĩβ���ַ�"\"�� }
    if FileExists(sBook) then
      sBook := TPath.GetFullPath(sBook)
    else
      // ʹ�û��������е�����·��
      if ENV_DataRoot <> '' then
        if FileExists(ENV_DataRoot + sBook) then
          sBook := ENV_DataRoot + sBook
        else
          sBook := ''
      else
        sBook := '';

    // 2018-06-21 ��ʱ�����ļ��б��б����ĸ�·��
    // if DataFilePath <> '' then
    // begin
    // { �ж�ԭsBook�Ƿ��ǺϷ�·�������������������ʽ�涨ֻ�������ľ���·���ŷ������� }
    // if TRegEx.IsMatch(sBook, PathPattern) then
    // begin
    // if not FileExists(sBook) then
    // sBook := '';
    // end
    // else
    // { todo:���ϳɵ��ļ��Ƿ�Ϸ����Ƿ���� }
    // if FileExists(DataFilePath + '\' + sBook) then
    // sBook := DataFilePath + '\' + sBook
    // else
    // { todo: ���ϳ��ļ������ڣ������û�ָ���ļ������û�ȡ��ָ�������Ժ�ͬ���ļ�������ָ�� }
    // sBook := '';
    // end
    // else
    // { todo: ����ļ��Ƿ���ڣ��������ڣ������û�Ϊ������ѡ��һ���ļ���ָ���ļ� }
    // if not FileExists(sBook) then
    // sBook := '';

    AMeter.DataSheet := sSht;
    AMeter.DataBook := sBook;
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadLayoutList
  Description: ���ز���ͼ�б�
  ----------------------------------------------------------------------------- }
function LoadLayoutList(DFBook: IXLSWorkBook): Boolean;
var
  Sht                       : IXLSWorksheet;
  iRow                      : Integer;
  sName, sFile, sPath, sAnno: string;
  ARec                      : PLayoutRec;
begin
  Result := False;
  Sht := ExcelIO.GetSheet(DFBook, '�ֲ�ͼ�ļ��б�');
  if Sht = nil then
    Exit;

  // ȡ���·��
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
      ShowMessage(Format('·��%s��Ч���޷����ز���ͼ�ļ��б�', [sPath]));
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
      ShowMessage(Format('����ͼ%sû��ָ��ͼ���ļ�', [sName]));
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
        ShowMessage(Format('����ͼ%s���ļ�·��%s��Ч��', [sName, sPath + sFile]));
    end;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadMeterGroup
  Description: ���������鶨�� 2018-05-29
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
  Sht := ExcelIO.GetSheet(ParamBook, { '�����鶨���' } SHTGROUPDEFINE);
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
  Description: ���ع��������ļ�������ļ��ж����������������ļ������������ļ�
  �б��ļ��������̸��ݴ˱���һ����֮��
  ----------------------------------------------------------------------------- }
function LoadProjectConfig(prjBookName: string): Boolean;
var
  Wbk, Wbk1, Wbk2: IXLSWorkBook;
  Sht            : IXLSWorksheet;
  S, sPF, sDLF   : string;
  iRow           : Integer;

  sDataRt    : string; // �����ļ���Ŀ¼
  sScheme    : string; // �ֲ�ͼĿ¼
  sCX        : string; // ��б������Ŀ¼
  sTemp      : string; // ��ʱ
  sTemplBook : string; // Excel DataGrid template workbook
  sEventsFile: string; // ����¼�������

  function _GetFullPath(APath: string): string;
  begin
    try
      Result := TPath.GetFullPath(APath);
    except
      // IssueList.Add(APath + '������Ч���ļ�����·��');
      Result := '';
    end;
  end;

begin
  Result := False;
  IssueList.Clear;

  xlsPrjFile := prjBookName;

  // �����������ļ�����·�����Ժ�Ҫ�õ�
  ENV_ConfigPath := ExtractFilePath(prjBookName);
  // ���ȫ���Ѵ�����������Ҫ���¼�����~~
  ExcelMeters.ReleaseAllMeters;
  MeterGroup.ReleaseAllItems;

  // ��ջ�����
  ENV_DataRoot := '';
  ENV_SchemePath := '';
  ENV_CXDataPath := '';
  ENV_TempPath := '';
  ENV_XLTemplBook := '';
  ENV_EventsFile := '';

  Wbk := TXLSWorkbook.Create;

  { todo:��д����Ĵ��룬��OpenWorkbook���������ļ��򿪵���� }

  try
    // wbk.Open(prjBookName);
    if ExcelIO.OpenWorkbook(Wbk, prjBookName) = False then
    begin
      ShowMessage('δ�ܴ򿪹��������ļ����޷�����...');
    end;

    Sht := ExcelIO.GetSheet(Wbk, '���������ļ�');
    if Sht = nil then
    begin
      ShowMessage('������Ч�ġ����������ļ���');
      Exit;
    end;
    { todo:��Ӹ�ʽ��� }
    sPF := '';
    sDLF := '';
    for iRow := 3 to Sht.UsedRange.LastRow + 1 do
    begin
      S := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
      if S = '' then
        Break;

      if S = '��������������' then
        sPF := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = '���������ļ��б�����' then
        sDLF := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = '�۲����ݸ�Ŀ¼' then
        sDataRt := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = '�ֲ�ͼĿ¼' then
        sScheme := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = '��б������Ŀ¼' then
        sCX := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = '��ʱĿ¼' then
        sTemp := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = 'Excel����ģ��' then
        sTemplBook := Trim(VarToStr(Sht.Cells[iRow, 3].Value))
      else if S = '����¼�������' then
        sEventsFile := Trim(VarToStr(Sht.Cells[iRow, 3].Value));
    end;

    // �����ļ�·��
    S := GetCurrentDir;
    SetCurrentDir(ENV_ConfigPath);

    // �����Ŀ¼�滻Ϊ����Ŀ¼
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
      IssueList.Add(Format('���������ļ���%s����Ч', [sPF]));
      xlsParamFile := '';
    end;

    if (xlsDFListFile = '') or (not FileExists(sDLF)) then
    begin
      IssueList.Add(Format('���������ļ��б�������%s��������Ч�ļ�', [sDLF]));
    end;

    // ShowMessage(sDataRt + #13 + sScheme + #13 + sCX + #13 + sTemp);
    // ������ЩĿ¼�Ƿ���ڣ��������������
    if DirectoryExists(sDataRt) then
      ENV_DataRoot := sDataRt
    else
      IssueList.Add('�����ļ���Ŀ¼��Ч�򲻴���');

    if DirectoryExists(sScheme) then
      ENV_SchemePath := sScheme
    else
      IssueList.Add('�����������ͼ�ļ�����Ч�򲻴���');

    if DirectoryExists(sCX) then
      ENV_CXDataPath := sCX
    else
      IssueList.Add('��б�������ļ�����Ч�򲻴���');

    if DirectoryExists(sTemp) then
      ENV_TempPath := sTemp
    else
      IssueList.Add('��ʱ�ļ�����Ч�򲻴���');

    if FileExists(sTemplBook) then
      ENV_XLTemplBook := sTemplBook
    else
      IssueList.Add(Format('��%s��������Ч���ļ����޷�����Excelģ�幤������', [sTemplBook]));

    if FileExists(sEventsFile) then
      ENV_EventsFile := sEventsFile
    else
      IssueList.Add(Format('��%s��������Ч���ļ����޷�����Excelģ�幤������', [sEventsFile]));

    // ������������������
    if sPF <> '' then
      try
        Wbk1 := TXLSWorkbook.Create;
        Wbk1.Open(sPF);
        LoadParams(Wbk1);
        // LoadTrendlinePredefines(Wbk1);
      except
        on e: Exception do
          ShowMessage('����������������' + e.Message);
      end;

    if sDLF <> '' then
      try
        Wbk2 := TXLSWorkbook.Create;
        Wbk2.Open(sDLF);
        LoadDataFileList(Wbk2);
        LoadLayoutList(Wbk2); // 2018-06-07 ���ز���ͼ���
      except
        on e: Exception do
          ShowMessage('�������������ļ��б����' + e.Message);
      end;

    Result := True;
    // �������ݿ��Ѵ���Ϣ
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
  Description: �����ֶ���ʾ�������
  ----------------------------------------------------------------------------- }
function LoadFieldDispNames(ParamBook: IXLSWorkBook): Boolean;
var
  Sht   : IXLSWorksheet;
  iRow  : Integer;
  S1, S2: string;
begin
  Result := False;
  Sht := ExcelIO.GetSheet(ParamBook, { '�ֶ�����' } SHTDSNAME);
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
  Description: ����������������
  ----------------------------------------------------------------------------- }
function LoadMeterTypes(ParamBook: IXLSWorkBook): Boolean;
var
  Sht : IXLSWorksheet;
  iRow: Integer;
  S   : string;
begin
  Result := False;
  PG_MeterTypes.Clear;
  Sht := ExcelIO.GetSheet(ParamBook, { 'Ԥ������' } SHTPREDEFINE);
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
  Description: ���ع��̲�λ�����
  ----------------------------------------------------------------------------- }
function LoadProjectLocations(ParamBook: IXLSWorkBook): Boolean;
var
  Sht : IXLSWorksheet;
  iRow: Integer;
  S   : string;
begin
  Result := False;
  PG_Locations.Clear;
  Sht := ExcelIO.GetSheet(ParamBook, { 'Ԥ������' } SHTPREDEFINE);
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
  Description: ���ع�����Ԥ���������
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
    // ����ռ���
    for NewDF in TLPreDefines.Values do NewDF.Free;
    TLPreDefines.Clear;

    Sht := ExcelIO.GetSheet(ParamBook, '������Ԥ����');
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
    NewDF.Name := sName; // decodedefine��ʱ��ҪClearһ�Σ����ɾ����Name
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
  // ��ռ���
  ts := IAppServices.Templates as TTemplates;
  // ���û�м���Templates��صĵ�Ԫ��ts�͵���nil�����ڼ��ù��ܵĳ�����˵������������û�а���
  // templates��ص�ϵ�е�Ԫ
  if ts = nil then
    Exit;

  ts.ClearAll;
  // ����ChartTemplates
  Sht := ExcelIO.GetSheet(ParamBook, { '������ģ��' } SHTCHARTTEMPLS);
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
      if S = '������' then
        ct.ChartType := cttTrendLine
      else if S = 'ʸ��ͼ' then // ��������ƽ��λ��ʸ��ͼ���������
        ct.ChartType := cttVector
      else if S = 'ɢ��ͼ' then // ��������ʾɢ����б����б����
        ct.ChartType := cttPoints
      else if S = '��ͼ' then
        ct.ChartType := cttBar
      else if S = '����ͼ' then // ��������ʾ��б����б����
        ct.ChartType := cttHoriLine
      else if S = 'λ��ͼ' then // ��������ʾ�ֲ�ͼ�����������
        ct.ChartType := cttDisplacement;

      // template str
      S := Trim(VarToStr(Sht.Cells[iRow, 4].Value));
      ct.TemplateStr := S;
      // annotation
      S := Trim(VarToStr(Sht.Cells[iRow, 5].Value));
      ct.Annotation := S;
    end;

  Sht := ExcelIO.GetSheet(ParamBook, { 'WebGrid������ģ��' } SHTWGTEMPLS);
  if Sht <> nil then
    for iRow := 2 to 1000 do
    begin
      sName := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
      if sName = '' then
        Break;

      wg := ts.AddWGTemplate(TWebGridTemplate) as TWebGridTemplate;
      wg.TemplateName := sName;

      // �������������Ѿ�д����ģ����룬������ģ�����ʱ�����ã�����Ͳ��ӱ��ж�ȡ�ˡ�

      // template string
      S := Trim(VarToStr(Sht.Cells[iRow, 4].Value));
      wg.TemplateStr := S;
      // annotation
      S := Trim(VarToStr(Sht.Cells[iRow, 5].Value));
      wg.Annotation := S;
    end;

  Sht := ExcelIO.GetSheet(ParamBook, { 'Excel������ģ��' } SHTXLTEMPLS);
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
      if S = '��' then
        xl.ApplyGroup := False
      else
        xl.ApplyGroup := True;
      // sheet name
      S := Trim(VarToStr(Sht.Cells[iRow, 5].Value));
      xl.TemplateSheet := S;
      // xlgrid type
      S := Trim(VarToStr(Sht.Cells[iRow, 6].Value));
      if S = '��̬��' then
        xl.GridType := xlgdynrow
      else if S = '��̬��' then
        xl.GridType := xlgdyncol
      else if S = '��̬��' then
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
  Description:  �ڲ�ʹ�á��ڻ����������������Ա����ݸ�ʽ���в���ָ�����
  ��ŵļ������
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
    { todo: ��������кŸ�Ϊ�ɶ����ȡ�кţ�����ǿ����δ������Ӧ�� }
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
    // ȥ��ĩβ�Ŀո�
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
  Description: ����������򴴽��������Ĳ��������������ı���������Ʊ��
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
  Sht := ExcelIO.GetSheet(Wbk, '�����������Ա�');
  _SaveMeterBaseParams(Sht, AMeter, NewMeter);

  { todo:���Ʊ��湤�̲��������ݸ�ʽ������ѡ�� }
end;

{ -----------------------------------------------------------------------------
  Procedure  : SaveParams
  Description: �������������������ı���������Ʊ��
  ----------------------------------------------------------------------------- }
function SaveParams(AMeter: TMeterDefine; OldName: string): Boolean;
// var
// Wbk: IXLSWorkBook;
// Sht: IXLSWorksheet;
begin
  Result := False;
  // �ȸ������ٵ���SaveParams

  // ����SaveParams
  Result := SaveParams(AMeter);
end;

{ -----------------------------------------------------------------------------
  Procedure  : AppendDataSheet
  Description: ����һ���������������������ļ��б�������
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
    ShowMessage('�������ļ��б�����ʧ�ܣ��ֹ�������ˡ�');
    Exit;
  end;
  Sht := ExcelIO.GetSheet(Wbk, '���������ļ��б�');
  if Sht = nil then
  begin
    ShowMessage('No found datalist sheet, do it by youself.');
    Exit;
  end;

  // ����������һ��
  for i := Sht.UsedRange.Rows.Count + 3 downto 3 do
  begin
    // ����ǿ����������ֱ���ҵ����һ�У������ݵģ�
    if VarToStr(Sht.Cells[i, 2].Value) = '' then
      Continue
    else
    begin
      // �ҵ��󣬵�i+1��Ϊ���һ��֮��Ŀ���
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
  { ���ParamName=DesignName�����˳�����������UpdateParam���޸���Ʊ�� }
  if SameText(ParamName, 'DesignName') then
    Exit;

  Wbk := TXLSWorkbook.Create;
  if ExcelIO.OpenWorkbook(Wbk, xlsParamFile) = False then
    Exit;
  { �鿴�����Ƿ���PRM�� }
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
  { ����ɹ���Ӧ��������������� }
end;

class function THJXExcelParam.IsMeterParam(ParamName: string): Boolean;
begin
  // ��theCols��prj,prm,dat���Ҳ���
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
  Description: ���LoadNew������µ������ļ�������ʹ�SummaryReport.ini��
  �ҵ������ļ�����
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
      // ������¼�¼������ݿ������¼�
      IAppServices.OnLogin(nil);
      IAppServices.OnRemoteConnect(nil);
    end;
  end;
  procedure __OpenLoad;
  begin
    dlg.Title := '�򿪹��������ļ�';
    dlg.Filter := 'Excel�ļ�|*.xls;*.xlsx';
    if S <> '' then
      dlg.InitialDir := ExtractFileDir(S)
    else
      dlg.InitialDir := ExtractFileDir(Application.ExeName);
    dlg.Options := [ofOverwritePrompt, ofPathMustExist, ofFileMustExist];
    if dlg.Execute then
    begin
      __LoadPrj(dlg.FileName);
      Init.WriteString('�����ļ�', '�����ļ�', dlg.FileName);
    end;
  end;

begin

  S := ExtractFilePath(Application.ExeName);
  FN := ExtractFileName(Application.ExeName);
  FN := copy(FN, 1, Pos('.', FN) - 1) + '.ini'; // ȥ����չ�������ͬ��ini

  // ExtractFileExt(fn);
  // �ȿ�����û�������ļ�
  dlg := TOpenDialog.Create(nil);
  Init := TIniFile.Create(S + FN);
  ENV_InitFile := S + FN;

  try
    if FileExists(S + FN) then
    begin
      S := Trim(Init.ReadString('�����ļ�', '�����ļ�', ''));
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
  // ���޸���LoadProject������������ʱ����ע���������
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
