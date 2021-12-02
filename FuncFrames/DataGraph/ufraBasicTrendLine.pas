{ -----------------------------------------------------------------------------
 Unit Name: ufraBasicTrendLine
 Author:    黄伟
 Date:      24-一月-2018
 Purpose:   本Frame作为过程线绘图模块的基础，提供对TreeChart的基本操纵。其他
            更复杂更高级的过程线绘制功能皆在此基础上封装而成。
            主要功能：
            1、Chart设置：

            2、Series设置；
                (1) 设置颜色、线型、阴影、粗细、标点、标签等；
                (2) 提供完整的Series编辑器对话窗；
                (3) 可运行时添加、删除一个Series对象；
                (4) 设置Series数据等基本数据操作；
            3、Chart操纵：
                (1) 完善的鼠标操纵，滚轮缩放、单轴缩放、单轴拖动等；
                (2) 手工设置标题、轴标题、图例文字；
                (3) 可提供完整的Chart属性编辑器；
            4、输出：
                (1) 拷贝、另存为多种格式的图形图片；
                (2) 可将设置好的图形保存为tee文件，允许其他Chart加载显示；
 History:   2018-01-24
            2018-07-11 双击轴，该轴自动缩放。这个自动缩放貌似不是很理想。
            2018-09-21 增加极简模式
----------------------------------------------------------------------------- }
{ TChart自带的坐标轴拖动方法可以用，但是缺少坐标轴缩放、滚轮缩放功能。可能仍然需要自己编程实现 }
{ todo:增加双击某坐标轴，则该轴变成自动比例 }
{ DONE:增加拷贝、图像存盘、Tee格式图形存盘 }
{ todo:增加隐藏某条线功能 }
{ DONE:增加chart设置功能 }
unit ufraBasicTrendLine;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, VclTee.TeeTools, VclTee.Series, Vcl.Menus,
  VclTee.TeeChineseSimp;

type
  TfraBasicTrendLine = class(TFrame)
    chtLine: TChart;
    ctScrollBottom: TAxisScrollTool;
    ctScrollLeft: TAxisScrollTool;
    ctScrollRight: TAxisScrollTool;
    N2: TMenuItem;
    N6: TMenuItem;
    piCopyAsBitmap: TMenuItem;
    piCopyAsEMF: TMenuItem;
    piSaveAsBitmap: TMenuItem;
    piSaveAsEMF: TMenuItem;
    piSaveAsTeeChart: TMenuItem;
    piSetupChart: TMenuItem;
    piSetupSeries: TMenuItem;
    popTL: TPopupMenu;
    Series1: TLineSeries;
    Series2: TLineSeries;
    TeeGDIPlus1: TTeeGDIPlus;
    N1: TMenuItem;
    piMinimalism: TMenuItem;
    procedure chtLineClickSeries(Sender: TCustomChart; Series: TChartSeries; ValueIndex: Integer;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure piSetupSeriesClick(Sender: TObject);
    procedure piSetupChartClick(Sender: TObject);
    procedure piCopyAsBitmapClick(Sender: TObject);
    procedure piCopyAsEMFClick(Sender: TObject);
    procedure piSaveAsBitmapClick(Sender: TObject);
    procedure piSaveAsEMFClick(Sender: TObject);
    procedure piSaveAsTeeChartClick(Sender: TObject);
    procedure chtLineClick(Sender: TObject);
    procedure chtLineMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure chtLineDblClick(Sender: TObject);
    procedure piMinimalismClick(Sender: TObject);
  private
        { Private declarations }
    FSelectedSeries: TChartSeries;
    FBeMinimalism  : Boolean; // 是否极简
  public
        { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
        // Draw a line
    procedure AddData(ASeries: TChartSeries; X: Double; Y: Double;
      ALabel: String = ''); overload;
    procedure AddData(SeriesIndex: Integer; X: Double; Y: Double;
      ALabel: string = ''); overload;
    procedure ShowSampleDatas;
    procedure ClearDatas(ASeries: TChartSeries);
        // 删除全部创建的线
    procedure ReleaseTrendLines;
    procedure SetChartTitle(ATitle: string);
        // 创建一条新线，在没有样式定义的情况下，自动分配颜色和数据点形状
    function NewLine(ATitle: string; VAxisIsLeft: Boolean = True): Integer;
        // 正常，或者极简
    procedure SetMinimalism(V: Boolean);
        /// <summary>是否极简主义？读取或设置之</summary>
        /// <remarks>极简风格，将隐藏标题、坐标轴、图例，同时将过程线的点尺寸缩小到1，
        /// 基本只保留图形本身</remarks>
    property Minimalism: Boolean read FBeMinimalism write SetMinimalism;
  end;

implementation

uses
  VclTee.TeePrevi, VclTee.EditChar, VclTee.TeePoEdi {, TeCanvas} , VclTee.TeePenDlg,
  VclTee.TeExport, VclTee.TeeStore, VclTee.TeePNG, VclTee.TeeJPEG, VclTee.TeeGIF;

{$R *.dfm}


constructor TfraBasicTrendLine.Create(AOwner: TComponent);
begin
  inherited;
  TeeSetChineseSimp;
end;

destructor TfraBasicTrendLine.Destroy;
begin
  inherited;
end;

procedure TfraBasicTrendLine.AddData(ASeries: TChartSeries; X: Double; Y: Double;
  ALabel: string = '');
begin
  ASeries.AddXY(X, Y, ALabel);
end;

procedure TfraBasicTrendLine.AddData(SeriesIndex: Integer; X: Double; Y: Double;
  ALabel: string = '');
begin
  chtLine.Series[SeriesIndex].AddXY(X, Y, ALabel)
end;

procedure TfraBasicTrendLine.ShowSampleDatas;
begin
  Series1.FillSampleValues(50);
  Series2.FillSampleValues(50);
end;

procedure TfraBasicTrendLine.chtLineClick(Sender: TObject);
begin
  chtLine.SetFocus;
  if not chtLine.Focused then
      Winapi.Windows.SetFocus(chtLine.Handle);
end;

procedure TfraBasicTrendLine.chtLineClickSeries(Sender: TCustomChart; Series: TChartSeries;
  ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FSelectedSeries := Series;
end;

procedure TfraBasicTrendLine.chtLineDblClick(Sender: TObject);
var
  mp     : TPoint;
  clkPart: TChartClickedPart;
begin
  mp := chtLine.GetCursorPos;
  chtLine.CalcClickedPart(mp, clkPart);
  if (clkPart.Part = cpAxis) or (clkPart.Part = cpAxisTitle) then
  begin
    clkPart.AAxis.Automatic := True;
  end;
end;

procedure TfraBasicTrendLine.chtLineMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  mp     : TPoint;
  clkPart: TChartClickedPart;
begin
  mp := chtLine.GetCursorPos;
  chtLine.CalcClickedPart(mp, clkPart);
  if (clkPart.Part = cpAxis) or (clkPart.Part = cpAxisTitle) then
  begin
        // 目前暂时用Zoom的方向来实现坐标轴方向的缩放。问题是同时缩放所有横轴或所有纵轴，而不能
        // 做到针对某一个轴进行缩放。
    if clkPart.AAxis.Horizontal then
        chtLine.Zoom.Direction := tzdHorizontal
    else
        chtLine.Zoom.Direction := tzdVertical
  end
  else
  begin
    chtLine.Zoom.Direction := tzdBoth;
    if clkPart.Part = cpSeriesPointer then
      with clkPart do
          chtLine.Hint := format('%s：%8.2f',
          [formatdatetime('yyyy-mm-dd', TLineSeries(ASeries).XValue[PointIndex]),
          TLineSeries(ASeries).YValue[PointIndex]])
    else
        chtLine.Hint := '';
  end;
end;

procedure TfraBasicTrendLine.ClearDatas(ASeries: TChartSeries);
begin
  ASeries.Clear;
end;

procedure TfraBasicTrendLine.ReleaseTrendLines;
var
  i: Integer;
begin
  for i := 0 to chtLine.Seriescount - 1 do
      chtLine.Series[i].Free;
  chtLine.RemoveAllSeries;
end;

procedure TfraBasicTrendLine.SetChartTitle(ATitle: string);
begin
  chtLine.Title.Caption := ATitle;
end;

function TfraBasicTrendLine.NewLine(ATitle: string; VAxisIsLeft: Boolean = True)
  : Integer;
var
  ls: TLineSeries;
begin
  Result := -1;
  ls := TLineSeries.Create(chtLine);
  ls.Name := 'NewLine' + IntToStr(Integer(ls));
  ls.Title := ATitle;
  chtLine.AddSeries(ls);
    // 设置竖轴
  if VAxisIsLeft then
      ls.VertAxis := aLeftAxis
  else
      ls.VertAxis := aRightAxis;
    // 横轴为日期格式
  ls.XValues.DateTime := True;
    // 颜色
  ls.Color := chtLine.GetFreeSeriesColor;
    // 数据点
  ls.Pointer.Visible := True;

    { todo:这里应考虑线太多出错的问题，这个版本最多有16中点型 }
  ls.Pointer.Style := TSeriesPointerStyle(chtLine.Seriescount - 1);

  if chtLine.Seriescount = 1 then // 第一个曲线PointerStyle是正方形，Size=3显得太大，so...
      ls.Pointer.Size := 2
  else
      ls.Pointer.Size := 3;

    // 画线方式：曲线
  ls.DrawStyle := dsCurve;

  Result := chtLine.SeriesList.IndexOf(ls);
end;

procedure TfraBasicTrendLine.piCopyAsEMFClick(Sender: TObject);
begin
  chtLine.Legend.CheckBoxes := False;
  chtLine.CopyToClipboardMetafile(True);
  chtline.Legend.CheckBoxes := True;
    // chtLine.CopyToClipboardBitmap;
end;

procedure TfraBasicTrendLine.piMinimalismClick(Sender: TObject);
begin
  piMinimalism.Checked := not piMinimalism.Checked;
  Minimalism := piMinimalism.Checked;
end;

procedure TfraBasicTrendLine.piCopyAsBitmapClick(Sender: TObject);
var
  JPG: TJPEGExportFormat;
begin
  JPG := TJPEGExportFormat.Create;
  try
    chtline.Legend.CheckBoxes := false;
    JPG.Panel := chtLine;
    JPG.CopyToClipboard;
  finally
    JPG.Free;
    chtline.Legend.CheckBoxes := true;
  end;
    // chtLine.CopyToClipboardBitmap;
    // chtLine.CopyToClipboardMetafile(True);
end;

procedure TfraBasicTrendLine.piSaveAsEMFClick(Sender: TObject);
begin
  chtline.Legend.CheckBoxes := false;
  TeeExport(nil, chtLine);
  chtline.Legend.CheckBoxes := true;
end;

procedure TfraBasicTrendLine.piSaveAsBitmapClick(Sender: TObject);
begin
  chtline.Legend.CheckBoxes := false;
  TeeExport(nil, chtLine);
  chtline.Legend.CheckBoxes := true;
end;

procedure TfraBasicTrendLine.piSaveAsTeeChartClick(Sender: TObject);
begin
  chtline.Legend.CheckBoxes := false;
  TeeExport(nil, chtLine);
  chtline.Legend.CheckBoxes := true;
end;

procedure TfraBasicTrendLine.piSetupChartClick(Sender: TObject);
begin
  EditChart(nil, chtLine);
end;

procedure TfraBasicTrendLine.piSetupSeriesClick(Sender: TObject);
begin
  if FSelectedSeries <> nil then
      EditSeries(nil, FSelectedSeries);
end;

procedure TfraBasicTrendLine.SetMinimalism(V: Boolean);
var
  i: Integer;
begin
    { 如果极简主义，则隐藏一堆东西，同时将过程线的点变小 }
  chtLine.Title.Visible := not V;
  chtLine.Legend.Visible := not V;
    // chtLine.LeftAxis.Visible := not V;
  with chtLine.leftaxis do
  begin
    Title.Visible := not V;
    if V then
        LabelsFont.Size := 6
    else
        LabelsFont.Size := 8;
  end;
  chtLine.RightAxis.Visible := not V;
    // chtLine.BottomAxis.Visible := not V;
  with chtLine.BottomAxis do
  begin
    Title.Visible := not V;
    if V then
        LabelsFont.Size := 6
    else
        LabelsFont.Size := 8;
  end;

  if V then
  begin
    chtLine.MarginLeft := 0;
    chtLine.MarginBottom := 0;
  end
  else
  begin
    chtLine.MarginLeft := 20;
    chtLine.MarginBottom := 4;
  end;

  for i := 0 to chtLine.Seriescount - 1 do
    if chtLine.Series[i] is TLineSeries then
      with (chtLine.Series[i] as TLineSeries) do
      begin
        if V then
            Pointer.Size := 1
        else
        begin
          if i = 0 then
              Pointer.Size := 2
          else
              Pointer.Size := 3;
        end;
      end;
end;

end.
