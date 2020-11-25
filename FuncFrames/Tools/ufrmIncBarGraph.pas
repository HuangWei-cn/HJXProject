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
    // 一些缺省设置值
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
    /// 显示指定监测仪器的月增量棒图，月起始日为每月1日，起始日期为2016年3月1日，截止日期为当前日期。
    /// 本方法将自己调用ClientDatas去查询数据。
    /// </summary>
    procedure ShowGraph(ADsnName: string); overload;

    /// <summary>
    /// 显示指定监测仪器的增量棒图，需同时指定增量计时方式、起始日、起始和截止日期。
    /// 本方法自己去查数据并显示。若APDIndex=-1，则查询所有具有特征值属性的物理量。
    /// </summary>
    procedure ShowGraph(ADsnName: String; APDIndex, Period, StartDay: Integer;
      StartDate, EndDate: TDateTime); Overload;

    /// <summary>
    /// 显示指定监测仪器的增量棒图，数据已经查询过了，只需要显示一下就可以了。
    /// AValue格式参见uHJX.Intf.Datas单元的GetPeriodIncrement方法中的说明。
    /// </summary>
    procedure ShowGraph(ADsnName: string; APDIndex: Integer; AValue: TVariantDynArray); overload;

    /// <summary>
    /// 增加一个物理量的增量棒图
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
  FFrame.chtBar.Title.Caption := FMeterType + ADsnName + '增量图';
  FFrame.chtBar.Series[0].Title := FMeter.PDName(APDIndex);
  FFrame.chtBar.Series[0].Clear;
  // 设置竖轴标题，由于没有单位信息，没法设置……
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
  Description: 本方法查询指定仪器、指定物理量在指定时间段内的增量，并绘制棒图。
  当APDIndex=-1时，查询所有具有特征值属性的物理量。
----------------------------------------------------------------------------- }
procedure TfrmIncbar.ShowGraph(ADsnName: string; APDIndex, Period: Integer; StartDay: Integer;
  StartDate: TDateTime; EndDate: TDateTime);
var
  i, idx: Integer;
  S     : string;
  Values: TVariantDynArray;
begin
  Self.Caption := ADsnName + '增量棒图';
  if APDIndex = -1 then
  begin
    // 先处理PDIndex=0的情况，这时候调用一次自己
    SetChart(ADsnName, 0);
    FPDIndex := 0;
    FStartDay := StartDay;
    FStartDate := StartDate;
    FEndDate := EndDate;
    FPeriod := Period;
    ShowGraph(ADsnName, 0, Period, StartDay, StartDate, EndDate);
    // 处理其他
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
  Self.Caption := ADsnName + '增量棒图';
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
  // 先查一下
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
