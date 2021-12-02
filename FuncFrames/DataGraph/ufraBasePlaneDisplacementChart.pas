{ -----------------------------------------------------------------------------
 Unit Name: ufraBasePlaneDisplacementChart
 Author:    黄伟
 Date:      05-七月-2018
 Purpose:   基本平面位移图
        提供一个TeeChart绘制平面位移矢量图，只处理绘图部分、导出等专项功能。
        提供数据或其他高级演示功能由一个壳Frame提供，类似ufraTrendlineShell
        单元。
 History:
----------------------------------------------------------------------------- }

unit ufraBasePlaneDisplacementChart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  VclTee.Series, VclTee.ArrowCha, Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, Vcl.Menus,
  VclTee.TeeChineseSimp, Vcl.ComCtrls, uMyTeeAxisScrollTool;

type
  TfraBasePlaneDisplacementChart = class(TFrame)
    chtDisplacement: TChart;
    ssDisplacement: TArrowSeries;
    popChart: TPopupMenu;
    piCopyAsBitmap: TMenuItem;
    piCopyAsMetafile: TMenuItem;
    N1: TMenuItem;
    piSaveAs: TMenuItem;
    chtCumulativeDeform: TChart;
    ssCumulative: TArrowSeries;
    N2: TMenuItem;
    piChartSetup: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    chtTrendLine: TChart;
    srsX: TLineSeries;
    srsY: TLineSeries;
    chtXY: TChart;
    srsXY: TLineSeries;
    TeeGDIPlus1: TTeeGDIPlus;
    procedure piCopyAsBitmapClick(Sender: TObject);
    procedure piCopyAsMetafileClick(Sender: TObject);
    procedure piSaveAsClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure piChartSetupClick(Sender: TObject);
    procedure TabSheet1Resize(Sender: TObject);
  private
    { Private declarations }
    FAxisToolY : ThwTeeAxisScrollTool;
    FAxisToolX : ThwTeeAxisScrollTool;
    FAxisToolY1: ThwTeeAxisScrollTool;
    FAxistoolX1: ThwTeeAxisScrollTool;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;
    procedure ClearDatas;
    procedure ShowSampleDatas;
    // show diaplacement trace
    procedure AddData(X0, Y0, X1, Y1: Double; ALabel: string = ''); overload;
    procedure AddData(DTScale: TDateTime; X, Y: Double); overload;
    procedure SetChartTitle(ATitle: string);
  end;

implementation

uses
  VclTee.TeExport, VclTee.TeePrevi, VclTee.EditChar, VclTee.TeePoEdi {, TeCanvas} ,
  VclTee.TeePenDlg, VclTee.TeeStore, VclTee.TeePNG, VclTee.TeeJPEG, VclTee.TeeGIF;
{$R *.dfm}


constructor TfraBasePlaneDisplacementChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TeeSetChineseSimp;
  FAxisToolY := ThwTeeAxisScrollTool.Create(Self);
  FAxisToolY.Axis := chtTrendLine.LeftAxis;
  FAxisToolY.Active := True;
  FAxisToolX := ThwTeeAxisScrollTool.Create(Self);
  FAxisToolX.Axis := chtTrendLine.BottomAxis;
  FAxisToolX.Active := True;

  FAxisToolY1 := ThwTeeAxisScrollTool.Create(Self);
  FAxisToolY1.Axis := chtXY.LeftAxis;
  FAxisToolY1.Active := True;
  FAxisToolX1 := ThwTeeAxisScrollTool.Create(Self);
  FAxisToolX1.Axis := chtXY.BottomAxis;
  FAxisToolX1.Active := True;

end;

destructor TfraBasePlaneDisplacementChart.Destroy;
begin
  //TTeeCustomToolAxis is a component, it will be free by Frame.
  //FAxisToolY.Free;
  //FAxisToolX.Free;
  //FAxisToolY1.Free;
  //FAxistoolX1.Free;
  inherited;
end;

procedure TfraBasePlaneDisplacementChart.ClearDatas;
begin
  ssDisplacement.Clear;
  ssCumulative.Clear;
end;

procedure TfraBasePlaneDisplacementChart.FrameResize(Sender: TObject);
begin
  // chtDisplacement.Width := chtDisplacement.Height;
  // chtCumulativeDeform.Width := chtCumulativeDeform.Height;
end;

procedure TfraBasePlaneDisplacementChart.piChartSetupClick(Sender: TObject);
begin
  EditChart(nil, TChart(popChart.PopupComponent));
end;

procedure TfraBasePlaneDisplacementChart.piCopyAsBitmapClick(Sender: TObject);
begin
  // chtDisplacement.CopyToClipboardBitmap;
  with (popChart.PopupComponent as TChart) do
  begin
    Legend.CheckBoxes := False;
    CopyToClipboardBitmap;
    Legend.CheckBoxes := True;
  end;
end;

procedure TfraBasePlaneDisplacementChart.piCopyAsMetafileClick(Sender: TObject);
begin
  // chtDisplacement.CopyToClipboardMetafile(True);
  with (popChart.PopupComponent as TChart) do
  begin
    Legend.CheckBoxes := False;
    CopyToClipboardBitmap;
    legend.CheckBoxes := True;
  end;
end;

procedure TfraBasePlaneDisplacementChart.piSaveAsClick(Sender: TObject);
begin
  TeeExport(nil, chtDisplacement);
end;

{ -----------------------------------------------------------------------------
  Procedure  : ShowSampleDatas
  Description: 示例数据，显示一条阿基米德螺旋线
----------------------------------------------------------------------------- }
procedure TfraBasePlaneDisplacementChart.ShowSampleDatas;
var
  R     : Double;
  X0, Y0: Double;
  X1, Y1: Double;
begin
  ssDisplacement.StartXValues.DateTime := False;
  ssDisplacement.EndXValues.DateTime := False;
  ClearDatas;
  X0 := 0;
  Y0 := 0;
    // X1 := 0;
    // Y1 := 0;
  R := 0;
    // 下面添加一下示例数据
  repeat
    X1 := R * sin(R);
    Y1 := R * cos(R);
    if (X1 <> X0) and (Y1 <> Y0) then
        ssDisplacement.AddArrow(X0, Y0, X1, Y1);
    X0 := X1;
    Y0 := Y1;
    R := R + 0.2;
  until R > 10;
end;

procedure TfraBasePlaneDisplacementChart.TabSheet1Resize(Sender: TObject);
begin
  chtDisplacement.Width := chtDisplacement.Height;
  chtCumulativeDeform.Width := chtCumulativeDeform.Height;
end;

function MaxValue(D: array of Double): Double;
var
  i: integer;
begin
  Result := Abs(D[Low(D)]);
  for i := Low(D) to High(D) do
    if Abs(D[i]) > Result then
        Result := Abs(D[i]);
end;

{ -----------------------------------------------------------------------------
  Procedure  : AddData
  Description: 添加一条箭头
----------------------------------------------------------------------------- }
procedure TfraBasePlaneDisplacementChart.AddData(X0, Y0, X1, Y1: Double;
  ALabel: string = '');
var
  MaxX, MaxY: Double;
  MinX, MinY: Double;
begin
  MaxX := MaxValue([X0, Y0, X1, Y1]);
  chtDisplacement.LeftAxis.Automatic := False;
  chtDisplacement.BottomAxis.Automatic := False;

  ssDisplacement.AddArrow(X0, Y0, X1, Y1, ALabel, clBlue);

    // 下面的工作为了将(0,0)置于Chart的中央
  with ssDisplacement do
      MaxX := MaxValue([MaxX, XValues.MaxValue, XValues.MinValue, YValues.MaxValue,
      YValues.MinValue]);
// MaxX := Abs(ssDisplacement.XValues.MaxValue);
// MaxY := Abs(ssDisplacement.YValues.MaxValue);
// MinX := Abs(ssDisplacement.XValues.MinValue);
// MinY := Abs(ssDisplacement.YValues.MinValue);
// if MinX > MaxX then
// MaxX := MinX;
// if MinY > MaxY then
// MaxY := MinY;
// if MaxY > MaxX then
// MaxX := MaxY;

  chtDisplacement.LeftAxis.Minimum := -MaxX;
  chtDisplacement.LeftAxis.Maximum := MaxX;
  chtDisplacement.BottomAxis.Minimum := -MaxX;
  chtDisplacement.BottomAxis.Maximum := MaxX;

  // 下面显示累积位移，为了减少修改其他代码，这里将就一下
  ssCumulative.Clear;
  ssCumulative.AddArrow(0, 0, X1, Y1);

  MaxX := Abs(X1);
  MaxY := Abs(Y1);
  if MaxX < MaxY then MaxX := MaxY;
  with chtCumulativeDeform do
  begin
    LeftAxis.Maximum := MaxX;
    LeftAxis.Minimum := -MaxX;
    BottomAxis.Maximum := MaxX;
    BottomAxis.Minimum := -MaxX;
  end;

end;

procedure TfraBasePlaneDisplacementChart.AddData(DTScale: TDateTime; X: Double; Y: Double);
var
  D: Double;
begin
  srsX.AddXY(DTScale, X);
  srsY.AddXY(DTScale, Y);
  D := Sqrt(X * X + Y * Y);
  srsXY.AddXY(DTScale, D);
end;

procedure TfraBasePlaneDisplacementChart.SetChartTitle(ATitle: string);
begin
  chtDisplacement.Title.Caption := ATitle + '位移轨迹图';
  chtCumulativeDeform.Title.Caption := ATitle + '(累积位移)';
  chtTrendLine.Title.Caption := ATitle + '测值过程线';
  chtXY.Title.Caption := ATitle + '水平合位移过程线';
end;

end.
