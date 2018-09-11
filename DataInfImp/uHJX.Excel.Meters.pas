{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Excel.Meters
 Author:    ��ΰ
 Date:      29-����-2018
 Purpose:   ������������嵥Ԫ��Ŀǰ�����Ǵ�Excel���ݱ�����ȡ�������󣬹�
            ��Щ��������ΪExcelMeters����ʼ�����õ��������ݿ��У�������
            ��ʹ����Щ����Ӧ���ܹ����㵱ǰ����Ҫ���ˡ�
 History:   2018-05-29 ���������������
            2018-06-06
                ������Ԫ���ж����޸�Ϊ��uHJX.Classes.Meters��Ԫ�м̳ж�������
                ��Ԫ�еĶ���Ϊ���������������ԭuHJX.Excel.Meters�еĶ�������
                �޸�Ŀ�ģ��������Ԫ�����ɲ�����ã������ع������ʵ������
                ����Ԫ��ֻ�������������У��������ݷ��ʲ������
                δ���ýӿڵ�ԭ�򣺶����е�ĳЩ����Ҳ�Ƕ��������ýӿھͶ�����
                �ǽӿڣ�����ʱ��Ҫת������ʮ���鷳��
            2018-07-24
                �����ӵ����ݽṹԤ������ͼ��Ͻ����˼̳к�ʵ�֡�
----------------------------------------------------------------------------- }

unit uHJX.Excel.Meters;

interface

uses
    System.Classes, System.SysUtils, System.Variants, System.Generics.Collections,
    uHJX.Classes.Meters;

type
// TDataDefine = record
// Name: string;
// Alias: string;
// DataUnit: string;
// Column: Integer;
// HasEV: Boolean; // ������ֵ��
// end;
//
// PDataDefine = ^TDataDefine;
    // PDataDefines = array of PDataDefine;

    TDataDefineList = class(TDataDefines)
    protected
        FList: TList<PDataDefine>;
        function GetItem(Index: Integer): PDataDefine; override;
        // procedure SetItem(Index: Integer; DD: PDataDefine);
        function GetCount: Integer; override;
    public
        constructor Create;
        destructor Destroy; override;

        function AddNew: PDataDefine; override;
        function IndexOfDataName(AName: String): Integer; override;
        procedure Clear; override;
        procedure Assign(Source: TDataDefines); override;
        // property Items[Index: Integer]: PDataDefine read GetItem; // write SetItem;
        // property Count: Integer read GetCount;
    end;

// TDataSheetStructure = record
// DTStartRow: Integer;
// DTStartCol: Integer;
// AnnoCol: Integer;
// BaseLine: Integer;
// MDs: TDataDefines;
// PDs: TDataDefines;
// end;
//
// TMeterParams = record
// MeterType: string;
// Model: string;
// SerialNo: string;
// WorkMode: string;
// MinValue: double;
// MaxValue: double;
// SensorCount: Integer;
// SetupDate: TDateTime;
// BaseDate: TDateTime;
// MDCount: Integer;
// PDCount: Integer;
// Annotation: string;
// end;
//
// TMeterProjectParams = record
// SubProject: string;
// Position: string;
// Elevation: double;
// Stake: string;
// Profile: string;
// Deep: double;
// Annotation: string;
// GroupID: string; // ������ID��Ŀǰָ��������  2018-05-29
// end;

    TMeterItem = class(TMeterDefine)
    protected
        // function GetPDDefines: TDataDefines;
        function GetPDDefine(Index: Integer): TDataDefine; override;
    public
// DesignName   : string;
// DataSheet    : string;
// DataBook     : string;
// Params       : TMeterParams;
// PrjParams    : TMeterProjectParams;
// DataSheetStru: TDataSheetStructure;
        constructor Create;
        destructor Destroy; override;
        function ParamValue(AParamName: string): Variant; override;
        procedure SetParamValue(AParamName: string; Value: Variant); override;
        function PDName(Index: Integer): string; override;
        function PDColumn(Index: Integer): Integer; override;

        // property PDDefines: TDataDefines;// read DataSheetStru.PDs;
        // property PDDefine[Index: Integer]: TDataDefine read GetPDDefine;
    end;

    TMeterDefineList = class(TMeterDefines)
    protected
        FList: TList;
        function GetCount: Integer; override;
        function GetItem(Index: Integer): TMeterDefine; override;
        function GetMeter(ADesignName: string): TMeterDefine; override;
    public
        constructor Create;
        destructor Destroy; override;
        function AddNew: TMeterDefine; override;
        function Add(AMeter: TMeterDefine): Integer; override;
        // ע�⣺Clear��Deleteֻ�Ƴ����󣬲����ͷţ�����
        procedure Clear; override;
        procedure ReleaseAllMeters; override;
        procedure Delete(Index: Integer); overload; override;
        procedure Delete(AName: string); overload; override;
        procedure SortByDesignName; override;
        procedure SortByPosition; override;
        procedure SortByMeterType; override;
        procedure SortByDataFile; override;
        // property Count: Integer read GetCount;
        // property Items[index: Integer]: TMeterDefine read GetItem;
        // property Meter[ADesignName: string]: TMeterDefine read GetMeter;
    end;

    { 2018-05-29 ��������
      ��������Ҫ�����������������͡������������Լ�������������ԵĶ��壬�����ݱ��ʽ�������߸�ʽ
      �ȵȡ���򵥵��鶨�����ǰ������������������Ϳ��Ե�����д����Ԫ���ܿ����ӵĸ�ʽ���壬��
      ��������鷳�����Ҳ����� }
    TMeterGroupItemObj = class(TMeterGroupItem)
    private
        // FName  : string;
        // FType  : string;
        FMeters: TStrings;
        function GetMeterCount: Integer; override;
        function GetItem(Index: Integer): string; override;
    public
        constructor Create;
        destructor Destroy; override;
        // property Name: string read FName write FName;
        // property GroupType: string read FType write FType;
        // property Count: Integer read GetMeterCount;
        // property Items[Index: Integer]: string read GetItem;
        procedure AddMeter(AName: string); override;
        procedure AddMeters(AMeterList: string); override;
    end;

    { 2018-05-29 �����鼯�� }
    TMeterGroupList = class(TMeterGroup)
    private
        FList: TList<TMeterGroupItem>;
    protected
        function GetCount: Integer; override;
        function GetItem(Index: Integer): TMeterGroupItem; override;
        function GetItemByName(AGroupName: string): TMeterGroupItem; override;
    public
        constructor Create;
        destructor Destroy; override;
        function AddNew: TMeterGroupItem; override;
        procedure ReleaseAllItems; override;
        // property Item[Index: Integer]: TMeterGroupItem read GetItem;
        // property ItemByName[AGroupName: string]: TMeterGroupItem read GetItemByName;
    end;

    TPreDefineDSItem = class(TPreDefineDataStructure)
    public
        constructor Create;
        destructor Destroy; override;
    end;

    TPreDefineDSList = class(TPreDefineDataStruList)
    private
        FList: TList<TPreDefineDataStructure>;
    protected
        function GetCount: Integer; override;
        function GetItem(Index: Integer): TPreDefineDataStructure; override;
        function GetItemByName(ADefineName: string): TPreDefineDataStructure; override;
    public
        constructor Create;
        destructor Destroy; override;
        function AddNew: TPreDefineDataStructure; override;
        procedure Clear; override;
    end;

type
    { �����������ֶ�������Ӧ����ʾ����������DataSet��field���ƻ�Ϊ�������������񿴡�
      ����ṹ������SetFieldDisplayName�������÷����ǽӿ�ͬ��������ʵ�֡� }
// ThjxDSName = record
// FieldName: string;
// DisplayName: string;
// end;
//
// PhjxDSName = ^ThjxDSName;

    ThjxDSNameList = class(ThjxDSNames)
    private
        FList: TList<PhjxDSName>;
    public
        constructor Create;
        destructor Destroy; override;
        procedure AddName(AFldName, ADispName: string); override;
        function DispName(AFldName: string): String; override;
    end;

    { ����ͼ���� }
    TLayoutList = class(TLayouts)
    private
        FList: TList<PLayoutRec>;
    protected
        function GetCount: Integer; override;
        function GetItem(Index: Integer): PLayoutRec; override;
    public
        constructor Create;
        destructor Destroy; override;
        function AddNew: PLayoutRec; override;
        procedure Clear; override;
    end;

implementation

constructor TDataDefineList.Create;
begin
    inherited;
    FList := TList<PDataDefine>.Create;
end;

destructor TDataDefineList.Destroy;
begin
    while FList.Count > 0 do
    begin
        Dispose(FList.Items[0]);
        FList.Delete(0);
    end;
    FList.Clear;
    FList.Free;
    inherited;
end;

function TDataDefineList.GetCount: Integer;
begin
    Result := FList.Count;
end;

function TDataDefineList.GetItem(Index: Integer): PDataDefine;
begin
    Result := nil;
    if FList.Items[Index] <> nil then
        Result := PDataDefine(FList.Items[index]);
end;

function TDataDefineList.AddNew: PDataDefine;
begin
    New(Result);
    FList.Add(Result);
    Result.Name := '';
    Result.Alias := '';
    Result.DataUnit := '';
    Result.Column := 0;
    Result.HasEV := false;
end;

procedure TDataDefineList.Clear;
begin
    while FList.Count > 0 do
    begin
        Dispose(FList.Items[0]);
        FList.Delete(0);
    end;
    FList.Clear;
end;

function TDataDefineList.IndexOfDataName(AName: string): Integer;
var
    i: Integer;
begin
    Result := -1;
    for i := 0 to FList.Count - 1 do
        if CompareText(PDataDefine(FList.Items[i]).Name, AName) = 0 then
        begin
            Result := i;
            Break;
        end;
end;

procedure TDataDefineList.Assign(Source: TDataDefines);
var
    i     : Integer;
    pdf, p: PDataDefine;
begin
    for i := 0 to Source.Count - 1 do
    begin
        pdf := Self.AddNew;
        p := PDataDefine(Source.Items[i]);
        pdf^ := p^;
    end;
end;

constructor TMeterItem.Create;
begin
    inherited;
    DataSheetStru.MDs := TDataDefineList.Create;
    DataSheetStru.PDs := TDataDefineList.Create;
end;

destructor TMeterItem.Destroy;
begin
    Self.DataSheetStru.MDs.Free;
    Self.DataSheetStru.PDs.Free;
    inherited;
end;

function TMeterItem.ParamValue(AParamName: string): Variant;
var
    S: string;
begin
    // Result := Empty;
    S := UpperCase(AParamName);
    if S = 'METERTYPE' then
        Result := Self.Params.MeterType
    else if S = 'MODEL' then
        Result := Params.Model
    else if S = 'SERIALNO' then
        Result := Params.SerialNo
    else if S = 'WORKMODE' then
        Result := Params.WorkMode
    else if S = 'SETUPDATE' then
        Result := FormatDateTime('yyyy-mm-dd', Params.SetupDate)
    else if S = 'BASEDATE' then
        Result := FormatDateTime('yyyy-mm-dd', Params.BaseDate)
    else if S = 'POSITION' then
        Result := PrjParams.Position
    else if S = 'ELEVATION' then
        Result := FormatFloat('0.00', PrjParams.Elevation)
    else if S = 'DEEP' then
        Result := FormatFloat('0.00', PrjParams.Deep)
    else if S = 'STAKE' then
        Result := PrjParams.Stake
    else if S = 'PROFILE' then
        Result := PrjParams.Profile
    else if S='DESIGNNAME' then
        Result := Self.DesignName
    else
        Result := 'Unknow parameter';
end;

procedure TMeterItem.SetParamValue(AParamName: string; Value: Variant);
var
    S: String;
begin
    { todo:��SetParamValue�������������ͼ�� }
    S := UpperCase(AParamName);
    if S = 'METERTYPE' then
        Params.MeterType := VarToStr(Value)
    else if S = 'MODEL' then
        Params.Model := Value
    else if S = 'SERIALNO' then
        Params.SerialNo := Value
    else if S = 'WORKMODE' then
        Params.WorkMode := Value
    else if S = 'SETUPDATE' then
        Params.SetupDate := VarToDateTime(Value)
    else if S = 'BASEDATE' then
        Params.BaseDate := VarToDateTime(Value)
    else if S = 'POSISTION' then
        PrjParams.Position := Value
    else if S = 'SUBPROJECT' then
        PrjParams.SubProject := Value
    else if S = 'ELEVATION' then
        PrjParams.Elevation := Value
    else if S = 'DEEP' then
        PrjParams.Deep := Value
    else if S = 'STAKE' then
        PrjParams.Stake := Value
    else if S = 'PROFILE' then
        PrjParams.Profile := Value;
end;

function TMeterItem.PDName(Index: Integer): String;
begin
    Result := Self.DataSheetStru.PDs.Items[Index].Name;
end;

function TMeterItem.PDColumn(Index: Integer): Integer;
begin
    Result := Self.DataSheetStru.PDs.Items[Index].Column;
end;

function TMeterItem.GetPDDefine(Index: Integer): TDataDefine;
begin
    Result := PDataDefine(DataSheetStru.PDs.Items[Index])^;
end;

constructor TMeterDefineList.Create;
begin
    inherited;
    FList := TList.Create;
end;

destructor TMeterDefineList.Destroy;
begin
    while FList.Count > 0 do
    begin
        TMeterDefine(FList.Items[0]).Free;
        FList.Delete(0);
    end;

    FList.Free;
    inherited;
end;

function TMeterDefineList.GetCount: Integer;
begin
    Result := FList.Count;
end;

function TMeterDefineList.AddNew: TMeterDefine;
begin
    Result := TMeterItem.Create;
    FList.Add(Result);
end;

function TMeterDefineList.Add(AMeter: TMeterDefine): Integer;
begin
    Result := FList.Add(AMeter);
end;

function TMeterDefineList.GetItem(Index: Integer): TMeterDefine;
begin
    Result := FList.Items[index];
end;

function TMeterDefineList.GetMeter(ADesignName: string): TMeterDefine;
var
    i: Integer;
begin
    for i := 0 to FList.Count - 1 do
    begin
        Result := Items[i];
        if Result.DesignName = ADesignName then
            Exit;
    end;
    Result := nil;
end;

procedure TMeterDefineList.Clear;
begin
    FList.Clear;
end;

procedure TMeterDefineList.ReleaseAllMeters;
begin
    while FList.Count > 0 do
    begin
        TMeterDefine(FList.Items[0]).Free;
        FList.Delete(0);
    end;
    FList.Clear;
end;

procedure TMeterDefineList.Delete(Index: Integer);
begin
    FList.Delete(index);
end;

procedure TMeterDefineList.Delete(AName: string);
var
    i: Integer;
begin
    for i := 0 to FList.Count - 1 do
        if Items[i].DesignName = AName then
        begin
            FList.Delete(i);
            Break;
        end;
end;

function CompareDesignName(N1, N2: Pointer): Integer;
begin
    Result := CompareText(TMeterDefine(N1).DesignName, TMeterDefine(N2).DesignName);
end;

function ComparePosition(N1, N2: Pointer): Integer;
var
    M1, M2: TMeterDefine;
begin
    M1 := TMeterDefine(N1);
    M2 := TMeterDefine(N2);
    Result := CompareText(M1.PrjParams.Position, M2.PrjParams.Position);
    if Result = 0 then
    begin
        Result := CompareText(M1.Params.MeterType, M2.Params.MeterType);
        if Result = 0 then
            Result := CompareText(M1.DesignName, M2.DesignName);
    end;
end;

function CompareMeterType(N1, N2: Pointer): Integer;
var
    M1, M2: TMeterDefine;
begin
    M1 := TMeterDefine(N1);
    M2 := TMeterDefine(N2);
    Result := CompareText(M1.Params.MeterType, M2.Params.MeterType);
    if Result = 0 then
    begin
        Result := CompareText(M1.PrjParams.Position, M2.PrjParams.Position);
        if Result = 0 then
            Result := CompareText(M1.DesignName, M2.DesignName);
    end;
end;

function CompareDataBook(N1, N2: Pointer): Integer;
var
    M1, M2: TMeterDefine;
begin
    M1 := TMeterDefine(N1);
    M2 := TMeterDefine(N2);
    Result := CompareText(M1.DataBook, M2.DataBook);
    if Result = 0 then
        Result := CompareText(M1.DesignName, M2.DesignName);
end;

procedure TMeterDefineList.SortByDesignName;
begin
    FList.Sort(@CompareDesignName);
end;

procedure TMeterDefineList.SortByPosition;
begin
    FList.Sort(@ComparePosition);
end;

procedure TMeterDefineList.SortByMeterType;
begin
    FList.Sort(@CompareMeterType);
end;

procedure TMeterDefineList.SortByDataFile;
begin
    FList.Sort(@CompareDataBook);
end;

constructor ThjxDSNameList.Create;
begin
    inherited Create;
    FList := TList<PhjxDSName>.Create;
end;

destructor ThjxDSNameList.Destroy;
begin
    while FList.Count > 0 do
    begin
        Dispose(FList.Items[0]);
        FList.Delete(0);
    end;
    FList.Clear;
    FreeAndNil(FList);
    inherited;
end;

procedure ThjxDSNameList.AddName(AFldName: string; ADispName: string);
var
    NewDs: PhjxDSName;
begin
    New(NewDs);
    NewDs.FieldName := AFldName;
    NewDs.DisplayName := ADispName;
    FList.Add(NewDs);
end;

function ThjxDSNameList.DispName(AFldName: string): string;
var
    i: Integer;
begin
    Result := '';
    for i := 0 to FList.Count - 1 do
        if CompareText(AFldName, FList.Items[i].FieldName) = 0 then
        begin
            Result := FList.Items[i].DisplayName;
            Break;
        end;
end;

constructor TMeterGroupItemObj.Create;
begin
    inherited;
    FMeters := TStringList.Create;
end;

destructor TMeterGroupItemObj.Destroy;
begin
    FMeters.Free;
    inherited;
end;

function TMeterGroupItemObj.GetMeterCount: Integer;
begin
    Result := FMeters.Count;
end;

function TMeterGroupItemObj.GetItem(Index: Integer): string;
begin
    Result := FMeters.Strings[Index];
end;

procedure TMeterGroupItemObj.AddMeter(AName: string);
begin
    FMeters.Add(AName);
end;

procedure TMeterGroupItemObj.AddMeters(AMeterList: string);
begin
    FMeters.Text := AMeterList;
end;

{ -----------------------------------------------------------------------------
  Procedure  : Create
  Description: ���������鼯��
----------------------------------------------------------------------------- }
constructor TMeterGroupList.Create;
begin
    inherited;
    FList := TList<TMeterGroupItem>.Create;
end;

destructor TMeterGroupList.Destroy;
var
    i: Integer;
begin
    for i := 0 to FList.Count - 1 do
        FList.Items[i].Free;
    FList.Clear;
    FList.Free;
    inherited;
end;

function TMeterGroupList.GetCount: Integer;
begin
    Result := FList.Count;
end;

function TMeterGroupList.GetItem(Index: Integer): TMeterGroupItem;
begin
    Result := FList.Items[index];
end;

function TMeterGroupList.GetItemByName(AGroupName: string): TMeterGroupItem;
var
    i: Integer;
begin
    Result := nil;
    for i := 0 to FList.Count - 1 do
        if FList.Items[i].Name = AGroupName then
        begin
            Result := FList.Items[i];
            Break;
        end;
end;

function TMeterGroupList.AddNew: TMeterGroupItem;
begin
    Result := TMeterGroupItemObj.Create;
    FList.Add(Result);
end;

procedure TMeterGroupList.ReleaseAllItems;
var
    i: Integer;
begin
    for i := 0 to FList.Count - 1 do
        FList.Items[i].Free;
    FList.Clear;
end;

constructor TLayoutList.Create;
begin
    inherited;
    FList := TList<PLayoutRec>.Create;
end;

destructor TLayoutList.Destroy;
begin
    Clear;
    FreeAndNil(FList);
    inherited;
end;

function TLayoutList.GetCount: Integer;
begin
    Result := FList.Count;
end;

function TLayoutList.GetItem(Index: Integer): PLayoutRec;
begin
    Result := FList.Items[index];
end;

function TLayoutList.AddNew: PLayoutRec;
begin
    New(Result);
    FList.Add(Result);
end;

procedure TLayoutList.Clear;
var
    i: Integer;
begin
    for i := 0 to FList.Count - 1 do
        Dispose(FList.Items[i]);
    FList.Clear;
end;

constructor TPreDefineDSItem.Create;
begin
    inherited;
    DataDefine.MDs := TDataDefineList.Create;
    DataDefine.PDs := TDataDefineList.Create;
end;

destructor TPreDefineDSItem.Destroy;
begin
    DataDefine.PDs.Free;
    DataDefine.MDs.Free;
    inherited;
end;

constructor TPreDefineDSList.Create;
begin
    inherited;
    FList := TList<TPreDefineDataStructure>.Create;
end;

destructor TPreDefineDSList.Destroy;
begin
    Clear;
    FList.Free;
    inherited;
end;

function TPreDefineDSList.GetCount: Integer;
begin
    Result := FList.Count;
end;

function TPreDefineDSList.GetItem(Index: Integer): TPreDefineDataStructure;
begin
    Result := FList.Items[index];
end;

function TPreDefineDSList.GetItemByName(ADefineName: string): TPreDefineDataStructure;
var
    i: Integer;
begin
    Result := nil;
    for i := 0 to FList.Count - 1 do
        if SameText(ADefineName, FList[i].DefineName) then
        begin
            Result := FList[i];
            Break;
        end;
end;

function TPreDefineDSList.AddNew: TPreDefineDataStructure;
begin
    Result := TPreDefineDSItem.Create;
    FList.Add(Result);
end;

procedure TPreDefineDSList.Clear;
var
    i: Integer;
begin
    for i := 0 to FList.Count - 1 do
        FList.Items[i].Free;
    FList.Clear;
end;

initialization

{ todo:���弰����ExcelMeters��MeterGroup��Ӧ�ŵ�AppServices��Ԫ�У������������д��� }
ExcelMeters := TMeterDefineList.Create;
DSNames := ThjxDSNameList.Create;
MeterGroup := TMeterGroupList.Create;
Layouts := TLayoutList.Create;
DSDefines := TPreDefineDSList.Create;

finalization

try
    FreeAndNil(ExcelMeters);
    FreeAndNil(DSNames);
    FreeAndNil(MeterGroup);
    FreeAndNil(Layouts);
    FreeAndNil(DSDefines);
finally
end;

end.
