unit ufrmIncBarGraph;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher, uHJX.Intf.Datas, uHJX.Classes.Meters,
  uHJX.Data.Types,
  ufraBaseIncrementGraph;

type
  TfrmIncbar = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    FFrame: TfraIncGraph;
    // һЩȱʡ����ֵ
    FPDIndex            : Integer;
    FMeter              : TMeterDefine;
    FMeterName          : String;
    FMeterType          : String;
    FStartDay           : Integer;
    FPeriod             : Integer; // 0- mongth; 1-Year; 2-Senson; 3-Week
    FStartDate, FEndDate: TDateTime;
    procedure SetChart(ADsnName: String; APDIndex: Integer);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    /// <summary>
    /// ��ʾָ�������������������ͼ������ʼ��Ϊÿ��1�գ���ʼ����Ϊ2016��3��1�գ���ֹ����Ϊ��ǰ���ڡ�
    /// ���������Լ�����ClientDatasȥ��ѯ���ݡ�
    /// </summary>
    procedure ShowGraph(ADsnName: string); overload;

    /// <summary>
    /// ��ʾָ�����������������ͼ����ͬʱָ��������ʱ��ʽ����ʼ�ա���ʼ�ͽ�ֹ���ڡ�
    /// �������Լ�ȥ�����ݲ���ʾ����APDIndex=-1�����ѯ���о�������ֵ���Ե���������
    /// </summary>
    procedure ShowGraph(ADsnName: String; APDIndex, Period, StartDay: Integer;
      StartDate, EndDate: TDateTime); Overload;

    /// <summary>
    /// ��ʾָ�����������������ͼ�������Ѿ���ѯ���ˣ�ֻ��Ҫ��ʾһ�¾Ϳ����ˡ�
    /// AValue��ʽ�μ�uHJX.Intf.Datas��Ԫ��GetPeriodIncrement�����е�˵����
    /// </summary>
    procedure ShowGraph(ADsnName: string; APDIndex: Integer; AValue: TVariantDynArray); overload;

    /// <summary>
    /// ����һ����������������ͼ
    /// </summary>
    procedure AddGraph(APDIndex: Integer);
  end;

procedure PopupIncBar(ADesignName: String; APDIndex, Period, StartDay: Integer;
  StartDate, EndDate: TDateTime);

implementation

{$R *.dfm}


var
  FrmHeight, FrmWidth: Integer;

procedure TfrmIncbar.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := 0;
end;

procedure TfrmIncbar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmIncbar.FormCreate(Sender: TObject);
begin
  FFrame := TfraIncGraph.Create(Self);
  FFrame.Parent := Self;
  FFrame.Align := alClient;
  FStartDay := 1;
  FPeriod := 0;
  FStartDate := StrToDate('2016-3-1');
  FEndDate := Now;
end;

procedure TfrmIncbar.SetChart(ADsnName: string; APDIndex: Integer);
begin
  FMeter := ExcelMeters.Meter[ADsnName];
  if FMeter = Nil then Exit;
  FMeterType := FMeter.Params.MeterType;
  FFrame.chtBar.Title.Caption := FMeterType + ADsnName + '����ͼ';
  FFrame.chtBar.Series[0].Title := FMeter.PDName(APDIndex);
  FFrame.chtBar.Series[0].Clear;
  // ����������⣬����û�е�λ��Ϣ��û�����á���
end;

{ -----------------------------------------------------------------------------
  Procedure  : FormDestroy
  Description:
----------------------------------------------------------------------------- }
procedure TfrmIncbar.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FFrame);
end;

procedure TfrmIncbar.FormResize(Sender: TObject);
begin
  FrmHeight := Self.Height;
  FrmWidth := Self.Width;
end;

{ -----------------------------------------------------------------------------
  Procedure  : ShowGraph
  Description:
----------------------------------------------------------------------------- }
procedure TfrmIncbar.ShowGraph(ADsnName: string);
begin
  ShowGraph(ADsnName, -1, 0, 1, 0, Now);
end;

procedure _ClearValues(var V: TVariantDynArray);
var
  i: Integer;
begin
  if length(V) > 0 then
    for i := Low(V) to High(V) do VarClear(V[i]);
  SetLength(V, 0);
end;

{ -----------------------------------------------------------------------------
  Procedure  : ShowGraph
  Description: ��������ѯָ��������ָ����������ָ��ʱ����ڵ������������ư�ͼ��
  ��APDIndex=-1ʱ����ѯ���о�������ֵ���Ե���������
----------------------------------------------------------------------------- }
procedure TfrmIncbar.ShowGraph(ADsnName: string; APDIndex, Period: Integer; StartDay: Integer;
  StartDate: TDateTime; EndDate: TDateTime);
var
  i, idx: Integer;
  S     : string;
  Values: TVariantDynArray;
begin
  Self.Caption := ADsnName + '������ͼ';
  if APDIndex = -1 then
  begin
    // �ȴ���PDIndex=0���������ʱ�����һ���Լ�
    SetChart(ADsnName, 0);
    FPDIndex := 0;
    FStartDay := StartDay;
    FStartDate := StartDate;
    FEndDate := EndDate;
    FPeriod := Period;
    ShowGraph(ADsnName, 0, Period, StartDay, StartDate, EndDate);
    // ��������
    for idx := 1 to FMeter.PDDefines.Count - 1 do
      if FMeter.PDDefine[idx].HasEV then AddGraph(idx);
  end
  else
  begin
    SetChart(ADsnName, APDIndex);
    FPDIndex := APDIndex;
    FStartDay := StartDay;
    FStartDate := StartDate;
    FEndDate := EndDate;
    FPeriod := Period;
    if IAppServices.ClientDatas.GetPeriodIncrement(ADsnName, APDIndex, StartDate, EndDate, Values,
      StartDay, Period) then
      for i := Low(Values) to High(Values) do FFrame.AddData(Values[i][5], Values[i][0]);
  end;

  _ClearValues(Values);
end;

{ -----------------------------------------------------------------------------
  Procedure  : ShowGraph
  Description:
----------------------------------------------------------------------------- }
procedure TfrmIncbar.ShowGraph(ADsnName: string; APDIndex: Integer; AValue: TVariantDynArray);
var
  i: Integer;
begin
  Self.Caption := ADsnName + '������ͼ';
  SetChart(ADsnName, APDIndex);
  for i := Low(AValue) to High(AValue) do
  begin
    FFrame.AddData(AValue[i][5], AValue[i][0]);
  end;
end;

procedure TfrmIncbar.AddGraph(APDIndex: Integer);
var
  i, iBar: Integer;
  Values : TVariantDynArray;
begin
  // �Ȳ�һ��
  if IAppServices.ClientDatas.GetPeriodIncrement(FMeter.DesignName, APDIndex, FStartDate, FEndDate,
    Values, FStartDay, FPeriod) then
  begin
    iBar := FFrame.NewBar(FMeter.PDName(APDIndex));
    for i := Low(Values) to high(Values) do
        FFrame.AddData(iBar, Values[i][5], Values[i][0]);
  end;
  _ClearValues(Values);
end;

procedure PopupIncBar(ADesignName: String; APDIndex, Period, StartDay: Integer;
  StartDate, EndDate: TDateTime);
var
  frm: TfrmIncbar;
begin
  frm := TfrmIncbar.Create(Application.MainForm);
  if (FrmWidth > 0) and (FrmHeight>0) then
      frm.SetBounds(frm.Left,frm.Top,FrmWidth,FrmHeight);
//  if FrmHeight > 0 then
//      frm.Height := FrmHeight;

  frm.ShowGraph(ADesignName, APDIndex, Period, StartDay, StartDate, EndDate);
  frm.Show;
end;

end.
