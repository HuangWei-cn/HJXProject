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
    System.Types, Vcl.Dialogs,
    nExcel,
    uHJX.Intf.AppServices,
    {uHJX.Excel.Meters} uHJX.Classes.Meters, uHJX.Excel.IO, uHJX.ProjectGlobal;

type
    { ����Excel�����仯���� }
    TMeterExcelParamChanged = (mepcBase, mepcProject, mepcDataStru, mepcDataFile, mepcDataView,
        mepcChartStyle, mepcGroup);
    { �����仯���� }
    TMeterExcelParamchangedSet = set of TMeterExcelParamChanged;

{ ���ع��������ļ������ļ�ָ���˲����ļ��������б��ļ����ڣ����������Щ��һ���� }
function LoadProjectConfig(prjBookName: String): Boolean;
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
{ ���ع�����Ԥ���� }
function LoadTrendLinePreDefines(ParamBook: IXLSWorkBook): Boolean;
{ ������������Ѵ��ڵ��������ı�����Ʊ�ţ��������µ��������� }
function SaveParams(AMeter: TMeterDefine; NewMeter: Boolean = False): Boolean; overload;
{ ����������������������Ʊ�� }
function SaveParams(AMeter: TMeterDefine; OldName: string): Boolean; overload;

var
    { ��������ȫ�ֱ������ڱ༭�����ļ�ʱ�����ٷ�����Щ�������ļ���ʡ�Ĵ򿪹����ļ���ȥ�� }
    xlsPrjFile   : string; // ���������ļ�
    xlsParamFile : string; // �����ļ�
    xlsDFListFile: string; // ���ݹ������б��ļ�

implementation

uses
    uHJX.EnvironmentVariables, uHJX.Excel.Meters, System.RegularExpressions, System.IOUtils,
    uTLDefineProc {2018-07-26 ������ģ������嵥Ԫ��ͬʱ�������ģ����룬��ʱ������Ԫֱ������};

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
        property Item[Index: Integer]: PColDefine read GetItem;
        property Col[AName: string]: Integer read GetCol;
    end;

{ TParamCols���ڷ���Excel�����ļ�ʱ��ָ����������������Ӧ�Ĺ������кš���������Ѿ��ڲ�����
      �еġ�ParamSheetStructure����������Ԥ�ȶ�����ˣ����ز���֮ǰ���ȶ�ȡ������еĶ��壬����
      �������Ժ��ȡ����ʱ��ͨ��������ɻ�ȡ������Ӧ�������ڵ��� }
    TParamCols = class
    public
        PRJ: TParamColsList;
        PRM: TParamColsList;
        DAT: TParamColsList;
        GRP: TParamColsList; // 2018-05-29 ���������鶨��ṹ
        DPD: TParamColsList; // 2018-07-24 �������ݱ�ṹԤ����ṹ
        TLD: TParamColsList; // 2018-07-24 ���ӹ�����Ԥ����ṹ
        constructor Create;
        destructor Destroy; override;
    end;

const
    MAXMETERNUMBER = 5000;
    PathPattern    = '^[a-zA-Z]:(((\\(?! )[^/:*?<>\""|\\]+)+\\?)|(\\)?)\s*$'; // �ļ�·��������ʽ

var
    // PARAMCOLS: TParamStruColDefine;
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
    Result := FList.Items[Index];
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
        if FList.Items[i].ParamName = AName then
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
end;

destructor TParamCols.Destroy;
begin
    PRJ.Free;
    PRM.Free;
    DAT.Free;
    GRP.Free; // 2018-05-29
    DPD.Free; // 2018-07-24
    TLD.Free; // 2018-07-24
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
    Sht := ExcelIO.GetSheet(ParamBook, 'ParamSheetStructure');
    if Sht = nil then
    begin
        ShowMessage('��������û�С�ParamSheetStructure������������ܴ���'#13#10
            + '�ٵĲ��������ټ��һ�¡�');
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
    sValue: String;
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
    function DateTimeValue(AName: String): TDateTime;
    begin
        Result := _GetDateTimeValue(Sht, iRow, theCols.PRM, AName);
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
            for i := Low(SS1) to High(SS1) do
            begin
                pdd := DDs.AddNew;
                pdd.Name := SS1[i];
                // �п���û���ṩ�кţ���ʱSS2�������顣
                if Length(SS2) > 0 then
                    if i <= High(SS2) then
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
            for i := low(SS1) to High(SS1) do
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
    DSS.ChartDefineName := StrValue('ChartPreDefine'); // 2018-07-26 ��ȡͼ������

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
    S       : String;
    PreDItem: TPreDefineDataStructure;
begin
    Result := False;
    Sht := ExcelIO.GetSheet(ParamBook, '���ݸ�ʽԤ����');
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

    procedure ClearLocalDefine;
    begin
        LocalDefine.MDs.Clear;
        LocalDefine.PDs.Clear;
        LocalDefine.DTStartRow := 0;
        LocalDefine.DTStartCol := 0;
        LocalDefine.AnnoCol := 0;
        LocalDefine.BaseLine := 0;
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
            if Local.Count = MTDefine.Count then
                for ii := 0 to Local.Count - 1 do
                begin
                    MTDefine.Items[ii].Name := local.Items[ii].Name;
                    MTDefine.Items[ii].Alias := local.Items[ii].Alias;
                    MTDefine.Items[ii].DataUnit := local.Items[ii].DataUnit;
                    if Local.Items[ii].Column <> 0 then
                    begin
                        MTDefine.Items[ii].Column := Local.Items[ii].Column;
                        MTDefine.Items[ii].HasEV := local.Items[ii].HasEV;
                    end;
                end
            else
            begin
                MTDefine.Clear;
                MTDefine.Assign(Local);
            end;
        end;

    begin
        ReplaceIntValue(LocalDefine.DTStartRow, AMeter.DataSheetStru.DTStartRow);
        ReplaceIntValue(LocalDefine.DTStartCol, AMeter.DataSheetStru.DTStartCol);
        ReplaceIntValue(LocalDefine.AnnoCol, AMeter.DataSheetStru.AnnoCol);
        ReplaceIntValue(LocalDefine.BaseLine, AMeter.DataSheetStru.BaseLine);

        // ����Chart��������֮�����ö���
        if LocalDefine.ChartDefineName <> '' then
            AMeter.DataSheetStru.ChartDefineName := LocalDefine.ChartDefineName;
        if AMeter.DataSheetStru.ChartDefineName <> '' then
        begin
            if TLPreDefines.ContainsKey(AMeter.DataSheetStru.ChartDefineName) then
                AMeter.ChartPreDef := TLPreDefines.Items[AMeter.DataSheetStru.ChartDefineName];
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
    Sht := ExcelIO.GetSheet(ParamBook, '�������ݸ�ʽ����');
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
    // ���ع��̲����������ﴴ����������Ҳ����˵��ֻ����������ж���������Żᱻ����������������
    // �е���������ڹ��̱���û�У��򲻻ᱻ������
    LoadProjectParams(ParamBook);
    // �������ݽṹԤ�����
    LoadPreDefineDataStru(ParamBook);
    // ���ع�����Ԥ�����
    LoadTrendLinePreDefines(ParamBook);
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
    // ���ع��̲�λ��
    LoadProjectLocations(ParamBook);

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
        if (DataFilePath = '') or (not DirExists(DataFilePath)) then
                ;

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
    Sht : IXLSWorksheet;
    iRow: Integer;
    sName,
        sFile,
        sPath,
        sMeters,
        sAnno: string;
    ARec     : PLayoutRec;
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
    Sht := ExcelIO.GetSheet(ParamBook, '�����鶨���');
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
            for i := Low(SS) to High(SS) do
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

    sDataRt: string; // �����ļ���Ŀ¼
    sScheme: string; // �ֲ�ͼĿ¼
    sCX    : string; // ��б������Ŀ¼
    sTemp  : string; // ��ʱ
begin
    Result := False;
    xlsPrjFile := prjBookName;

    // �����������ļ�����·�����Ժ�Ҫ�õ�
    ENV_ConfigPath := ExtractFilePath(prjBookName);
    // ���ȫ���Ѵ�����������Ҫ���¼�����~~
    ExcelMeters.ReleaseAllMeters;
    MeterGroup.ReleaseAllItems;

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
                sTemp := Trim(VarToStr(Sht.Cells[iRow, 3].Value));
        end;

        xlsParamFile := sPF;
        xlsDFListFile := sDLF;

        // �����ļ�·��
        S := GetCurrentDir;
        SetCurrentDir(ENV_ConfigPath);
        // �����Ŀ¼�滻Ϊ����Ŀ¼
        sDataRt := TPath.GetFullPath(sDataRt);
        sScheme := TPath.GetFullPath(sScheme);
        sCX := TPath.GetFullPath(sCX);
        sTemp := TPath.GetFullPath(sTemp);
        // ShowMessage(sDataRt + #13 + sScheme + #13 + sCX + #13 + sTemp);
        // ������ЩĿ¼�Ƿ���ڣ��������������
        if DirectoryExists(sDataRt) then
            ENV_DataRoot := sDataRt;
        if DirectoryExists(sScheme) then
            ENV_SchemePath := sScheme;
        if DirectoryExists(sCX) then
            ENV_CXDataPath := sCX;
        if DirectoryExists(sTemp) then
            ENV_TempPath := sTemp;

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
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadFieldDispNames
  Description: �����ֶ���ʾ�������
----------------------------------------------------------------------------- }
function LoadFieldDispNames(ParamBook: IXLSWorkBook): Boolean;
var
    Sht   : IXLSWorksheet;
    iRow  : Integer;
    S1, S2: String;
begin
    Result := False;
    Sht := ExcelIO.GetSheet(ParamBook, '�ֶ�����');
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
    S   : String;
begin
    Result := False;
    PG_MeterTypes.Clear;
    Sht := ExcelIO.GetSheet(ParamBook, 'Ԥ������');
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
    Sht := ExcelIO.GetSheet(ParamBook, 'Ԥ������');
    if Sht = nil then
        Exit;
    for iRow := 2 to Sht.UsedRange.LastRow + 1 do
    begin
        S := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
        if S <> '' then
            PG_Locations.Add(S);
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadTrendLinePreDefines
  Description: ���ع�����Ԥ���������
----------------------------------------------------------------------------- }
function LoadTrendLinePreDefines(ParamBook: IXLSWorkBook): Boolean;
var
    Sht     : IXLSWorksheet;
    S, sName: string;
    iRow    : Integer;
    NewDF   : TTrendlinePreDefine;
begin
    Result := False;
    //����ռ���
    for NewDF in TLPreDefines.Values do
        NewDF.Free;
    TLPreDefines.Clear;

    Sht := ExcelIO.GetSheet(ParamBook, '������Ԥ����');
    if Sht = nil then
        Exit;
    for iRow := 2 to 1000 do
    begin
        // define name
        sName := Trim(VarToStr(Sht.Cells[iRow, 2].Value));
        if sName = '' then
            Break;

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
end;

{ -----------------------------------------------------------------------------
  Procedure  : _FindMeter
  Description:  �ڲ�ʹ�á��ڻ����������������Ա����ݸ�ʽ���в���ָ�����
                ��ŵļ������
----------------------------------------------------------------------------- }
function _FindMeter(Sht: IXLSWorksheet; AName: String; StartRow: Integer = 1): Integer;
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
end;

{ -----------------------------------------------------------------------------
  Procedure  : SaveParams
  Description: �������������������ı���������Ʊ��
----------------------------------------------------------------------------- }
function SaveParams(AMeter: TMeterDefine; OldName: String): Boolean;
var
    Wbk: IXLSWorkBook;
    Sht: IXLSWorksheet;
begin
    Result := False;
    // �ȸ������ٵ���SaveParams

// ����SaveParams
    Result := SaveParams(AMeter);
end;

initialization

theCols := TParamCols.Create;

finalization

theCols.Free;

end.
