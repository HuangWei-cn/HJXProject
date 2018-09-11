unit uHJX.Func.ChartTemplateClasses;

interface

uses
    System.Classes, System.SysUtils, System.Generics.Collections, System.Variants;

type
    { 坐标轴类型 }
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
        OtherSide: Boolean; // 对于竖轴，OtherSide是右轴；对于横轴，Otherside是顶轴
        Index: Integer;     // 在模板坐标轴集合中的Index
        Format: string;     // 坐标轴数字的格式
        SubAxis1: TSubAxis;
        SubAxis2: TSubAxis;
        ChartAxis: TObject; { 向TeeChart的TAxis对象，这个属性只有在用模板应用到Chart时才会赋值，因为
        之后要添加Series，需要为Series指明CustomAxis，为简化查找CustomAxis的过程，直接赋值比较有效 }
    end;

    TCDSource = (cdsMeter, cdsEnv); // Chart数据来源:监测仪器或设置，或来源于环境量

    { 数据序列定义 }
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

    { 数据图表模板对象 }
    TDataChartTemplate = class
    protected
        FChartType   : Integer; // 尚未明确Type枚举类型
        FTemplateType: Integer; // 同上
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

    { 模板集合 }
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
        Exception.Create(Format('名为“%s”的模板已存在，无法添加同名模板。', [AName]));
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
