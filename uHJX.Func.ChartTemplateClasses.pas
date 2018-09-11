unit uHJX.Func.ChartTemplateClasses;

interface

uses
    System.Classes, System.SysUtils, System.Generics.Collections, System.Variants;

type
    { ���������� }
    TAXType = (axLeft, axRight, axBottom, axCustom);

    { SubAxis record }
    TSubAxis = record
        Title: String;
        Visible: Boolean;
        Format: String;
    end;

    { TCTAxis class: Chart Template Axis class }
    TCTAxis = class
        Title: string;
        AxisType: TAXType;
        IsVerAxis: Boolean;
        OtherSide: Boolean; // �������ᣬOtherSide�����᣻���ں��ᣬOtherside�Ƕ���
        Index: Integer;     // ��ģ�������Ἧ���е�Index
        Format: string;     // ���������ֵĸ�ʽ
        SubAxis1: TSubAxis;
        SubAxis2: TSubAxis;
        ChartAxis: TObject; { ��TeeChart��TAxis�����������ֻ������ģ��Ӧ�õ�Chartʱ�Żḳֵ����Ϊ
        ֮��Ҫ���Series����ҪΪSeriesָ��CustomAxis��Ϊ�򻯲���CustomAxis�Ĺ��̣�ֱ�Ӹ�ֵ�Ƚ���Ч }
    end;

    TCDSource = (cdsMeter, cdsEnv); // Chart������Դ:������������ã�����Դ�ڻ�����

    { �������ж��� }
    TDataSeries = class
    protected
        FSeriesType: Integer;
        FSourceType: TCDSource;
        SourceName : string;
        MeterIndex : Integer;
        PDIndex    : Integer;
        Title      : string;
        VertAxis   : TCTAxis;
        ShowAnno   : Boolean;
    public
    end;

    { ����ͼ��ģ����� }
    TDataChartTemplate = class
    protected
        FChartType   : Integer; // ��δ��ȷTypeö������
        FTemplateType: Integer; // ͬ��
        FMeterType   : Integer;
        FEnvType     : Integer;
        FTempStr     : string;
    public
        Name        : string;
        ChartTitle  : string;
        HoriAxis    : TCTAxis;
        VertAxis    : TDictionary<string, TCTAxis>;
        Serieses    : TList<TDataSeries>;
        ApplyToGroup: Boolean;
        procedure DecodeDefine(DefStr: string); virtual; abstract;
    published
        property ChartType   : Integer read FChartType write FChartType;
        property TemplateType: Integer read FTemplateType write FTemplateType;
        property MeterType   : Integer read FMeterType write FMeterType;
        property TempDefine  : string read FTempStr;
    end;

    { ģ�弯�� }
    TChartTemplates = class
    private
        FTemplates: TDictionary<string, TDataChartTemplate>;
    protected
        function GetCount: Integer; virtual;
        function GetItem(Index: Integer): TDataChartTemplate;
        function GetItemByName(AName: string): TDataChartTemplate;
    public
        constructor Create;
        destructor Destroy; override;
        function Add(AName, ATempDefine: string): TDataChartTemplate; virtual;
        procedure Clear; virtual;
        property Count: Integer read GetCount;
        property Items[Index: Integer]: TDataChartTemplate read GetItem;
        property ItemsByName[AName: String]: TDataChartTemplate read GetItemByName;
    end;

implementation

constructor TChartTemplates.Create;
begin
    inherited;
    FTemplates := TDictionary<string, TDataChartTemplate>.Create;
end;

destructor TChartTemplates.Destroy;
begin
    Clear;
    FTemplates.Free;
    inherited;
end;

procedure TChartTemplates.Clear;
var
    ct: TDataChartTemplate;
begin
    for ct in FTemplates.Values do
        ct.Free;
    FTemplates.Clear;
end;

function TChartTemplates.GetCount: Integer;
begin
    Result := FTemplates.Count;
end;

function TChartTemplates.GetItem(Index: Integer): TDataChartTemplate;
begin
    Result := nil;
end;

function TChartTemplates.GetItemByName(AName: string): TDataChartTemplate;
begin
    Result := FTemplates.Items[AName];
end;

function TChartTemplates.Add(AName: string; ATempDefine: string): TDataChartTemplate;
var
    dct: TDataChartTemplate;
begin
    if FTemplates.ContainsKey(AName) then
    begin
        Exception.Create(Format('��Ϊ��%s����ģ���Ѵ��ڣ��޷����ͬ��ģ�塣', [AName]));
        Exit;
    end;

    dct := TDataChartTemplate.Create;
    try
        dct.DecodeDefine(ATempDefine);
        FTemplates.Add(AName, dct);
        Result := dct;
    except
        on e: Exception do
        begin
            dct.Free;
            Result := nil;
        end;
    end;
end;

end.
