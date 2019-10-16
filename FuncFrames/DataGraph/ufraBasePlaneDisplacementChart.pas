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
  VclTee.Series, VclTee.ArrowCha, Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, Vcl.Menus;

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
    procedure piCopyAsBitmapClick(Sender: TObject);
    procedure piCopyAsMetafileClick(Sender: TObject);
    procedure piSaveAsClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  private
        { Private declarations }
  public
        { Public declarations }
    procedure ClearDatas;
    procedure ShowSampleDatas;
    // show diaplacement trace
    procedure AddData(X0, Y0, X1, Y1: Double; ALabel: string = '');
    procedure SetChartTitle(ATitle: string);
  end;

implementation

uses
  VclTee.TeExport;
{$R *.dfm}


procedure TfraBasePlaneDisplacementChart.ClearDatas;
begin
  ssDisplacement.Clear;
  ssCumulative.Clear;
end;

procedure TfraBasePlaneDisplacementChart.FrameResize(Sender: TObject);
begin
  chtDisplacement.Width := chtDisplacement.Height;
  chtCumulativeDeform.Width := chtCumulativeDeform.Height;
end;

procedure TfraBasePlaneDisplacementChart.piCopyAsBitmapClick(Sender: TObject);
begin
  // chtDisplacement.CopyToClipboardBitmap;
  (popChart.PopupComponent as TChart).CopyToClipboardBitmap;
end;

procedure TfraBasePlaneDisplacementChart.piCopyAsMetafileClick(Sender: TObject);
begin
  // chtDisplacement.CopyToClipboardMetafile(True);
  (popChart.PopupComponent as TChart).CopyToClipboardBitmap;
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

procedure TfraBasePlaneDisplacementChart.SetChartTitle(ATitle: string);
begin
  chtDisplacement.Title.Caption := ATitle;
  chtCumulativeDeform.Title.Caption := ATitle + '(累积位移)';
end;

end.
