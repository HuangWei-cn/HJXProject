{ -----------------------------------------------------------------------------
 Unit Name: ufraBaseIncrementGraph
 Author:    黄伟
 Date:      08-十月-2020
 Purpose:   本功能用于显示监测数据的时段增量图，如月增量等。
            通常这类图形用于变形、压力、应变等增量显示。
            对于仅有一个传感器的监测仪器，只需要显示一个物理量的增量棒图；对于
            有多个传感器的监测仪器（如多点位移计等），则可能需要在一个Chart中
            显示多个棒图。
            本功能的使用，可以用一个Form套在外面做成弹出式的窗体；或者像“观测
            数据报表”功能那样，默默绘制完拷贝为位图插入到Web页面中。

 History:
----------------------------------------------------------------------------- }

unit ufraBaseIncrementGraph;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  VclTee.Series, Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, Vcl.Menus, VclTee.TeeChineseSimp,
  VclTee.TeeTools;

type
  TfraIncGraph = class(TFrame)
    chtBar: TChart;
    srsBar1: TBarSeries;
    TeeGDIPlus1: TTeeGDIPlus;
    popIncBar: TPopupMenu;
    piCopyAsBitmap: TMenuItem;
    N1: TMenuItem;
    piSetup: TMenuItem;
    ChartTool1: TAxisScrollTool;
    procedure piSetupClick(Sender: TObject);
    procedure piCopyAsBitmapClick(Sender: TObject);
    procedure chtBarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    /// <summary>
    /// 重置图形，删除多余的Bar，并重置srsBar1，使之回归到没有数据的状态
    /// </summary>
    procedure ResetChart;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure AddData(Value: Variant; ALabel: String); overload;
    procedure AddData(SeriesIndex: Integer; Value: Variant; ALabel: String); overload;
    function NewBar(ATitle: string): Integer;
  end;

implementation

{$R *.dfm}


uses
  VclTee.TeePrevi, VclTee.EditChar, VclTee.TeePoEdi {, TeCanvas} , VclTee.TeePenDlg,
  VclTee.TeExport, VclTee.TeeStore, VclTee.TeePNG, VclTee.TeeJPEG, VclTee.TeeGIF;

constructor TfraIncGraph.Create(AOwner: TComponent);
begin
  inherited;
  TeeSetChineseSimp;
end;

procedure TfraIncGraph.ResetChart;
var
  i  : Integer;
  srs: TChartSeries;
begin
  if chtBar.SeriesCount > 1 then
    for i := chtBar.SeriesCount - 1 downto 1 do
    begin
      srs := chtBar.Series[i];
      chtBar.Serieslist.Remove(srs);
      srs.Free;
    end;
  srsBar1.Clear;
end;

procedure TfraIncGraph.AddData(SeriesIndex: Integer; Value: Variant; ALabel: string);
begin
  if (VarIsNull(Value)) or (VarIsEmpty(Value)) then
    (chtBar.Series[SeriesIndex] as TBarSeries).Add(0, ALabel)
  else
    (chtBar.Series[SeriesIndex] as TBarSeries).Add(Value, ALabel);
end;

procedure TfraIncGraph.AddData(Value: Variant; ALabel: string);
begin
  // srsBar1.Add(Value, ALabel);
  AddData(0, Value, ALabel);
end;

procedure TfraIncGraph.chtBarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  mp     : TPoint;
  clkPart: TChartClickedPart;
begin
  mp := chtBar.GetCursorPos;
  chtBar.CalcClickedPart(mp, clkPart);
  if (clkPart.Part = cpAxis) or (clkPart.Part = cpAxisTitle) then
  begin
        // 目前暂时用Zoom的方向来实现坐标轴方向的缩放。问题是同时缩放所有横轴或所有纵轴，而不能
        // 做到针对某一个轴进行缩放。
    if clkPart.AAxis.Horizontal then
        chtBar.Zoom.Direction := tzdHorizontal
    else
        chtBar.Zoom.Direction := tzdVertical
  end
  else
  begin
    chtBar.Zoom.Direction := tzdBoth;
    if clkPart.Part = cpSeriesPointer then
      with clkPart do
          chtBar.Hint := format('%8.2f',
          [TBarSeries(ASeries).YValue[PointIndex]])
    else
        chtBar.Hint := '';
  end;

end;

function TfraIncGraph.NewBar(ATitle: string): Integer;
var
  srs: TBarSeries;
begin
  Result := -1;
  srs := TBarSeries.Create(chtBar);
  // 指定一个唯一的名称
  srs.Name := 'BarSeries' + IntToStr(Integer(srs));
  srs.Title := ATitle;
  srs.Marks.Visible := False;
  chtBar.AddSeries(srs);
  Result := chtBar.Serieslist.IndexOf(srs);
end;

procedure TfraIncGraph.piCopyAsBitmapClick(Sender: TObject);
var
  JPG: TJPEGExportFormat;
begin
  JPG := TJPEGExportFormat.Create;
  try
    JPG.Panel := chtBar;
    JPG.CopyToClipboard;
  finally
    JPG.Free;
  end;
end;

procedure TfraIncGraph.piSetupClick(Sender: TObject);
begin
  EditChart(nil, chtBar);
end;

end.
