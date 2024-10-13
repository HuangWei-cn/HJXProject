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
  2022-05-11 修改AddData方法，其中参数X类型由Double改为Variant，目的
  在于对付Null值
  2022-10-25
  （1）增加了拖拽过程线到另一个过程线的方法，操作方法为按下左Ctrl键，
  拖拽一个过程线到另一个中，释放即可。程序会自动判断坐标轴问题、
  新增过程线的颜色及Pointer的问题；
  （2）双击Title会弹出InputBox，修改标题；
  （3）双击Axis Title会弹出Inputbox，修改标题

  2022-10-26
  （1）双击Pointer可以拖拽数据点
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
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Generics.Collections,
  VclTee.TeeGDIPlus, VclTee.TeEngine,
  Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, VclTee.TeeTools, VclTee.Series, Vcl.Menus,
  VclTee.TeeChineseSimp, VclTee.TeeDragPoint, Vcl.StdCtrls, VclTee.TeeFunci, VclTee.CurvFitt,
  VclTee.TeeSpline;

type
  // 减少Pointer的类型
  TSimPointerMethod = (spm20, spmStep2, spmStep3, spmStep5);
  // 当前操作类型，主要是区分按下鼠标左键或右键后要干嘛，以决定当MouseUp时是否要弹出菜单
  TOpType = (otNone { 啥特定操作都没有 } , otDragChart { 拖拽绘图区 } , otDragSeries { 拖拽曲线 } ,
    otAdjustAxis { 调整坐标轴 } , otCanPopupMenu { 可以弹出菜单 } );

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
    Series3: TPointSeries;
    N3: TMenuItem;
    piShow20Pointers: TMenuItem;
    piShowPointersStep2: TMenuItem;
    piShowPointersStep3: TMenuItem;
    piShowPointersStep5: TMenuItem;
    N4: TMenuItem;
    piRestoreLinePointer: TMenuItem;
    ChartTool1: TDragPointTool;
    lblHint: TLabel;
    Timer1: TTimer;
    N5: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    piCurve: TMenuItem;
    Series4: TFastLineSeries;
    TeeFunction1: TTrendFunction;
    Series5: TFastLineSeries;
    TeeFunction2: TSmoothingFunction;
    Series6: TFastLineSeries;
    TeeFunction3: TCurveFittingFunction;
    Series7: TFastLineSeries;
    TeeFunction4: TAverageTeeFunction;
    N9: TMenuItem;
    piRewriteData: TMenuItem;
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
    procedure piShow20PointersClick(Sender: TObject);
    procedure piShowPointersStep2Click(Sender: TObject);
    procedure piShowPointersStep3Click(Sender: TObject);
    procedure piShowPointersStep5Click(Sender: TObject);
    procedure piRestoreLinePointerClick(Sender: TObject);
    procedure chtLineDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean);
    procedure chtLineDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure chtLineMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
    procedure chtLineAfterDraw(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure piCurveClick(Sender: TObject);
    procedure chtLineMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
    procedure ChartTool1EndDrag(Sender: TDragPointTool; Index: Integer);
    procedure piRewriteDataClick(Sender: TObject);
  private
    { Private declarations }
    FSelectedSeries: TChartSeries;
    FBeMinimalism  : Boolean; // 是否极简
    FSetSimPointer : Boolean; // 是否设置了模拟点（模拟点用于替代原Line的Pointer）
    FOpType        : TOpType;
    /// <summary>
    /// 缺省情况下，过程线每个数据都显示Pointer，当数据较多的时候，因Pointer较多造成显示的结果很
    /// 难看。但是TeeChart又不能酌情自己减少Pointer，因此需要在这里用Pointer类型的Series替代Line
    /// 的Pointer，适当减少数量。
    /// </summary>
    procedure SetSimPointer(ASimMethod: TSimPointerMethod = spm20); // 设置模拟点
    /// 允许或禁止拖拽数据点，若之前禁止则调用后允许，反之亦然
    /// 同时也检查被敲击的Series是否有对应的DragPointTool，若没有则创建一个
    procedure AllowDragPoint(ASeries: TLineSeries);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // Draw a line
    procedure AddData(ASeries: TChartSeries; X: Double; Y: { Double } Variant; ALabel: String = '');
      overload; // 2022-05-11 修改
    procedure AddData(SeriesIndex: Integer; X: Double; Y: { Double } Variant; ALabel: string = '');
      overload; // 2022-05-11 修改
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
  VclTee.TeExport, VclTee.TeeStore, VclTee.TeePNG, VclTee.TeeJPEG, VclTee.TeeGIF,
  VclTee.TeeExport, uMyTeeAxisScrollTool,
  uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher, uHJX.Data.Types,
  uHJX.Template.ChartTemplateProc {引用此单元仅为了用TMeterLine替代TLineSeries} ,
  uDragSeriesHelper {本单元单纯就是为了拖拽LineSeries提供帮助};
{$R *.dfm}

const
  { 增加十二种预定义的颜色 }
  SSColors: array [0 .. 11] of TColor = (clWebDarkBlue, clwebdarkgreen, clWebMidnightBlue,
    clWebDarkOliveGreen, clWebIndigo, clWebDarkViolet, clWebDarkMagenta, clWebPurple, clWebDeepPink,
    clWebDodgerBlue, clWebTeal, clWebSienna);

  { 重新设置坐标轴的位置，本方法用于设置了CustomAxis的Chart布局
    为了能正确工作，Chart中大多数可以调节Position或Margin的对象都应该选用像素作为调节单位，包括Axis、
    Panel等。
  }
procedure ReplaceAxes(AChart: TChart);
/// 每个Axis都有一个Shape，这个Shape是轴+标签的范围，但不包括Title，可以通过Shape来确定轴的宽度，
/// 但是，这个Shape必须是Visible才行，所以可以设置Axis的Shape.Visible := True; Shape.Transparent := True
/// 来隐藏这个Shape的外形。
/// 为了确定Title的大小，可以用Title的Width和Height来确定。对于竖轴，如果文字转90°，则应该用Height
/// 来确定高度。
var
  CAList               : TList;
  i                    : Integer;
  CA                   : TChartAxis;
  NextXLeft, NextXRight: Integer;
  MargLeft, MargRight  : Integer;
  preUnit              : TTeeUnits;
  L1st, R1st           : Boolean; // 是否是第一个左轴、第一个右轴，用于确定Margin是否增加10个pixels
begin
  NextXLeft := 0;
  NextXRight := 0;
  MargLeft := 20;
  MargRight := 20;
  { todo:为保险起见，这里最好再设置一遍Chart和各个坐标轴的PositionUnit }
  preUnit := AChart.MarginUnits;
  AChart.MarginUnits := muPixels;
  AChart.LeftAxis.PositionUnits := muPixels;
  AChart.RightAxis.PositionUnits := muPixels;
  AChart.LeftAxis.Shape.Transparent := True;
  AChart.LeftAxis.Shape.Visible := True;
  AChart.RightAxis.Shape.Transparent := True;
  AChart.RightAxis.Shape.Visible := True;
  for i := 0 to AChart.CustomAxes.count - 1 do
    if not AChart.CustomAxes[i].Horizontal then
    begin
      AChart.CustomAxes[i].PositionUnits := muPixels;
      AChart.CustomAxes[i].Shape.Transparent := True;
      AChart.CustomAxes[i].Shape.Visible := True;
    end;

  { LeftAxis和RightAxis显示与否，Panel将自动设置Margin }
  CAList := TList.Create;
  try
    for i := 0 to AChart.SeriesList.count - 1 do
      if AChart[i].Active then
        case AChart[i].VertAxis of
          aLeftAxis:
            begin
              if CAList.IndexOf(AChart.LeftAxis) = -1 then
              begin
                { todo:需考虑LeftAxis隐藏的情况，即当没有Series使用LeftAxis时它会隐藏 }
                if AChart.LeftAxis.Visible then
                begin
                  CAList.Add(AChart.LeftAxis);
                  // 下面的循环中，计入了主LeftAxis的Margin，故这里先行剔除，后面不再判断
                  // MargLeft := MargLeft - extraMargin;
                  MargLeft := MargLeft - AChart.LeftAxis.Shape.Width - AChart.LeftAxis.Title.Height;
                  // .Width;
                end;
              end;
            end;
          aRightAxis: { Case：没有Series对应RightAxis，但是RightAxis仍然是Visible，但在这里没有处理 }
            begin
              if CAList.IndexOf(AChart.RightAxis) = -1 then
              begin
                { todo:需考虑RightAxis隐藏的情况 }
                if AChart.RightAxis.Visible then
                begin
                  CAList.Add(AChart.RightAxis);
                  // MargRight := MargRight - extraMargin;
                  // 当右轴没有曲线对应时，它也是显示的，并没有隐藏，但此时的Shape.Width小于零，
                  // 但是Title.Height不为零，是正常值
                  MargRight := MargRight - Abs(AChart.RightAxis.Shape.Width) -
                    AChart.RightAxis.Title.Height;
                end;
              end;
            end;
          aCustomVertAxis:
            begin
              { todo:需考虑CustomAxis隐藏的情况 }
              if AChart[i].CustomVertAxis <> nil then
                if AChart[i].CustomVertAxis.Visible then
                  if CAList.IndexOf(AChart[i].CustomVertAxis) = -1 then
                    CAList.Add(AChart[i].CustomVertAxis);
            end;
        end;

    L1st := False;
    R1st := False;
    for i := 0 to CAList.count - 1 do
    begin
      CA := TChartAxis(CAList[i]);
      if CA.OtherSide then
      begin
        CA.PositionPercent := NextXRight;
        NextXRight := NextXRight - Abs(CA.Shape.Width) - CA.Title.Height;
        if (CA.Shape.Width <> 0) or (CA.Title.Height <> 0) then
          NextXRight := NextXRight - 10;

        if R1st then { 注意，右侧轴的Shape.Width居然是负的！！ }
          MargRight := MargRight + Abs(CA.Shape.Width) + CA.Title.Height + 10
        else
        begin
          if CA.Shape.Width < 0 then
            MargRight := MargRight + Abs(CA.Shape.Width) + CA.Title.Height
          else
            MargRight := MargRight + CA.Title.Height;
          // 如果是第一个轴，不用加，避免在仅有一个轴的情况下多Margin了10个像素
          R1st := True;
        end;
      end
      else
      begin
        CA.PositionPercent := NextXLeft;
        NextXLeft := NextXLeft - CA.Shape.Width - CA.Title.Height - 10;
        // - CA.MaxLabelsWidth - CA.TickLength - extraPos;
        if not L1st then
        begin
          MargLeft := MargLeft + CA.Shape.Width + CA.Title.Height;
          L1st := True;
        end
        else
          MargLeft := MargLeft + CA.Shape.Width + CA.Title.Height + 10;
      end;
    end;

    AChart.MarginLeft := MargLeft;
    AChart.MarginRight := MargRight;
  finally
    CAList.Free;
  end;
end;

procedure DropNewSeries(AChart: TChart; ADropSeries: TLineSeries);
var
  NewSS     : TMeterLine; // TLineSeries;
  sAxisTitle: string;
  i, j      : Integer;
  b         : Boolean;
  CA        : TChartAxis;

  NewAxisTool: ThwTeeAxisScrollTool;

  { 设置NewSS与其他Series颜色不同 }
  procedure _SetDiffColor;
  var
    iSS       : Integer;
    iClr      : Integer;
    bSameColor: Boolean;
  begin
    { 通常调用本方法时，意味着NewSS没有采用轴的颜色，此时NewSS的颜色为Drag的Series颜色 }
    iClr := 0;
    repeat
      bSameColor := False;
      for iSS := 0 to AChart.SeriesCount - 1 do
        if NewSS.Color = AChart.Series[iSS].Color then
        begin
          bSameColor := True;
          break;
        end;

      if bSameColor then
      begin
        NewSS.Color := SSColors[iClr];
        NewSS.Brush.Color := SSColors[iClr];
        NewSS.Pen.Color := SSColors[iClr];
        inc(iClr);
      end;
    until bSameColor = False;
  end;
{ 设置NewSS与其他Series的Pointer不同 }
  procedure _SetDiffPointer;
  var
    iSS  : Integer;
    iPt  : Integer;
    bSame: Boolean;
  begin
    iPt := 0;
    // 设置Pointer尺寸与现存的一直
    NewSS.Pointer.Size := (AChart.Series[AChart.SeriesCount - 1] as TLineSeries).Pointer.Size;
    NewSS.Pointer.Pen.Color := NewSS.Color;
    NewSS.Pointer.Brush.Color := NewSS.Color;
    NewSS.Pointer.Brush.Style := bsClear;
    NewSS.Pointer.Color := NewSS.Color;
    NewSS.Pointer.Transparency := 25;
    // newss.LinePen.Fill.

    repeat
      bSame := False;
      for iSS := 0 to AChart.SeriesCount - 1 do
        if NewSS.Pointer.Style = (AChart.Series[iSS] as TLineSeries).Pointer.Style then
        begin
          bSame := True;
          break;
        end;
      if bSame then
      begin
        NewSS.Pointer.Style := TSeriesPointerStyle(iPt);
        inc(iPt);
      end;
    until bSame = False;
  end;

begin
  if ADropSeries = nil then
    Exit;

  { 创建之前，应先检查是否已有同名过程线，若有可采取放弃、重命名等措施 }
  { todo:创建新LineSeries之前，应先检查是否有重名的过程线，若有则取消或重命名或加仪器名前缀 }
  // NewSS := TLineSeries.Create(AChart);
  NewSS := TMeterLine.Create(AChart);
  // dragS := ADropSeries as TLineSeries;
  NewSS.Assign(ADropSeries { FDragSeries as TLineSeries } );
  if ADropSeries is TMeterLine then
  begin
    NewSS.Meter := (ADropSeries as TMeterLine).Meter;
    NewSS.DataIndex := (ADropSeries as TMeterLine).DataIndex;
    // 设置NewSS的Title
    NewSS.Title := NewSS.Meter.DesignName + '-' + NewSS.Meter.DataSheetStru.PDs.Items
      [NewSS.DataIndex - 1].Name; // DataIndex是PDIndex，起始数为1
  end;

  // 修改Chart内其他MeterLine的名称，以便于区别不同的仪器
  for i := 0 to AChart.SeriesCount - 1 do
  begin
    if AChart.Series[i] is TMeterLine then
      with AChart.Series[i] as TMeterLine do
      begin
        Title := Meter.DesignName + '-' + Meter.DataSheetStru.PDs.Items[DataIndex - 1].Name;
      end;
  end;

  { todo:需要考虑坐标轴问题，如产生了新坐标轴，则需要设置坐标轴标题 }
  // 2022-9-9 下面的代码根据FDragSeries的坐标轴判断是否需要创建新坐标轴
  sAxisTitle := ADropSeries.GetVertAxis.Title.Text;
  // 判断所有竖轴中是否有同名坐标轴，若有，则设置为该轴，若无，则添加为CustomVerAxis。
  { todo: 假如某个缺省轴没人用，比如RightAxis，而Drop的Series正好需要一个右轴，此时就不应该创建
    CustomAxis，而是直接使用右轴 }
  b := False;
  for i := 0 to AChart.Axes.count - 1 do
    if AChart.Axes.Items[i].Title.Text = sAxisTitle then
    begin
      b := True;
      CA := AChart.Axes.Items[i];
      break;
    end;

  // 如果没有找到这个轴，则需要创建
  if not b then
  begin
    // 如果没有找到，只能创建CustomAxes
    CA := AChart.CustomAxes.Add;
    NewAxisTool := ThwTeeAxisScrollTool.Create(AChart.Parent);
    NewAxisTool.Axis := CA;
    NewAxisTool.Active := True;
    CA.Title.Text := sAxisTitle;
    CA.Horizontal := False;
    CA.PositionUnits := muPixels;
    CA.Grid.Visible := False;
    // 设置颜色
    j := 0;
    for i := 0 to AChart.Axes.count - 1 do // 不算CustomAxis，缺省就有6个，其中竖轴只有俩
    begin
      if AChart.Axes[i].Horizontal then
        Continue;
      AChart.Axes[i].Axis.Color := SSColors[j];
      AChart.Axes[i].LabelsFont.Color := SSColors[j];
      AChart.Axes[i].Ticks.Color := SSColors[j];
      AChart.Axes[i].Title.Font.Color := SSColors[j];
      inc(j);
    end;

    if ADropSeries.VertAxis = aRightAxis then
      CA.OtherSide := True
    else if ADropSeries.VertAxis = aCustomVertAxis then
      CA.OtherSide := ADropSeries.CustomVertAxis.OtherSide;
    NewSS.VertAxis := aCustomVertAxis;
    NewSS.CustomVertAxis := CA;
    NewSS.Color := CA.Axis.Color;
  end
  else
  begin
    // 如果是左右轴，如果有CustomAxis，则Series颜色应与轴颜色相同，否则应该是不同于其他Series的颜色
    if AChart.LeftAxis.Title.Text = sAxisTitle then
    begin
      NewSS.VertAxis := aLeftAxis;
      if AChart.CustomAxes.count > 0 then
        NewSS.Color := AChart.LeftAxis.Axis.Color
      else
        _SetDiffColor;
    end
    else if AChart.RightAxis.Title.Text = sAxisTitle then
    begin
      NewSS.VertAxis := aRightAxis;
      if AChart.CustomAxes.count > 0 then
        NewSS.Color := AChart.RightAxis.Axis.Color
      else
        _SetDiffColor;
    end
    else
    begin
      NewSS.VertAxis := aCustomVertAxis;
      for i := 0 to AChart.CustomAxes.count - 1 do
        if AChart.CustomAxes[i].Title.Text = sAxisTitle then
        begin
          NewSS.CustomVertAxis := AChart.CustomAxes[i];
          NewSS.Color := AChart.CustomAxes[i].Axis.Color; // 如果是CustomAxis，则Series颜色与轴同色
          break;
        end;
    end;
  end;
  NewSS.HorizAxis := aBottomAxis;
  // ShowMessage(sAxisTitle);

  { todo:需要考虑重置过程线颜色、标点类型等指示信息 }
  _SetDiffPointer;
  NewSS.ParentChart := AChart;
  NewSS.Visible := True;
  ReplaceAxes(AChart);
end;

constructor TfraBasicTrendLine.Create(AOwner: TComponent);
begin
  inherited;
  TeeSetChineseSimp;
  FSetSimPointer := False;
end;

destructor TfraBasicTrendLine.Destroy;
begin
  inherited;
end;

procedure TfraBasicTrendLine.AddData(ASeries: TChartSeries; X: Double; Y: { Double } Variant;
  ALabel: string = '');
var
  i: Integer;
begin
  // 允许添加Y为Null值的点 2022-05-11
  if VarIsNull(Y) then
  begin
    i := ASeries.AddXY(X, -100, ALabel);
    ASeries.SetNull(i);
  end
  else
    ASeries.AddXY(X, Y, ALabel);
end;

procedure TfraBasicTrendLine.AddData(SeriesIndex: Integer; X: Double; Y: { Double } Variant;
  ALabel: string = '');
var
  i: Integer;
begin
  // 2022-05-11 允许添加Y为Null值的点
  if VarIsNull(Y) then
  begin
    i := chtLine.Series[SeriesIndex].AddXY(X, -100, ALabel);
    chtLine.Series[SeriesIndex].SetNull(i);
  end
  else
    chtLine.Series[SeriesIndex].AddXY(X, Y, ALabel)
end;

procedure TfraBasicTrendLine.ShowSampleDatas;
begin
  Series1.FillSampleValues(50);
  Series2.FillSampleValues(50);
end;

procedure TfraBasicTrendLine.Timer1Timer(Sender: TObject);
begin
  lblHint.Visible := False;
  Timer1.Enabled := False;
end;

procedure TfraBasicTrendLine.chtLineAfterDraw(Sender: TObject);
begin
  ReplaceAxes(chtLine);
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
  if Series is TLineSeries then
    uDragSeriesHelper.DragSeries := Series as TLineSeries;
end;

procedure TfraBasicTrendLine.chtLineDblClick(Sender: TObject);
var
  mp     : TPoint;
  clkPart: TChartClickedPart;
begin
  mp := chtLine.GetCursorPos;
  chtLine.CalcClickedPart(mp, clkPart);
  case clkPart.Part of
    cpNone:
      ;
    cpLegend:
      ;
    cpAxis:
      { clkPart.AAxis.Automatic := True }; // 双击自动缩放交给uMyTeeAxisScrollTool处理
    cpSeries:
      ;
    cpTitle:
      chtLine.Title.Text.Text := InputBox('修改图形标题', '输入新标题', chtLine.Title.Text.Text);
    cpFoot:
      ;
    cpChartRect:
      ;
    cpSeriesMarks:
      ;
    cpSeriesPointer:
      AllowDragPoint(clkPart.ASeries as TLineSeries);
    cpSubTitle:
      ;
    cpSubFoot:
      ;
    cpAxisTitle:
      clkPart.AAxis.Title.Text := InputBox('修改坐标轴标题', '输入坐标轴新标题', clkPart.AAxis.Title.Text);
  end;
end;

procedure TfraBasicTrendLine.chtLineDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if Sender = Source then
    Exit;
  if not(Source is TChart) then
    Exit;
  if uDragSeriesHelper.DragSeries = nil then
    Exit;
  DropNewSeries(chtLine, uDragSeriesHelper.DragSeries);
  uDragSeriesHelper.DragSeries := nil;
end;

procedure TfraBasicTrendLine.chtLineDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if (Source is TChart) and (Sender <> Source) then
    Accept := True
  else
    Accept := False;
end;

procedure TfraBasicTrendLine.chtLineMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  pt  : TPoint;
  Part: TChartClickedPart;
begin
  chtLine.CalcClickedPart(Point(X, Y), Part);
  pt := chtLine.ClientToScreen(Point(X, Y));
  FOpType := otNone; // 啥也不干
  popTL.AutoPopup := False;

  if (Button = mbLeft) and (Shift = [ssCtrl, ssLeft]) then { 拖拽 }
  begin
    if Part.Part = cpSeries then
    begin
      FOpType := otDragSeries;
      uDragSeriesHelper.DragSeries := Part.ASeries as TLineSeries;
      chtLine.BeginDrag(True, -1);
    end;
  end
  else if (Button = mbRight) and (Shift = [ssCtrl, ssLeft]) then { LeftCtrl+MouseRight: 缩放轴 }
  begin { 缩放轴，禁止弹出式菜单 }
    // if Part.Part = cpAxis then popTL.AutoPopup := False;
    FOpType := otAdjustAxis;
  end
  else
  begin
    case Part.Part of
      cpNone, cpSeries, cpSeriesMarks:
        begin
          FOpType := otCanPopupMenu;
          popTL.AutoPopup := True;
          { if Button = mbRight then
            popTL.Popup(pt.X, pt.Y); }
        end;
      cpLegend:
        ;
      cpAxis:
        ;
      // cpSeries:;
      cpTitle:
        ;
      cpFoot:
        ;
      cpChartRect:
        begin
          FOpType := otCanPopupMenu;
          popTL.AutoPopup := True;
          { 如果在ChartRect中弹出菜单，将无法拖动曲线 }
        end;
      // cpSeriesMarks:;
      cpSeriesPointer:
        ;
      cpSubTitle:
        ;
      cpSubFoot:
        ;
      cpAxisTitle:
        ;
    end;

  end;

end;

procedure TfraBasicTrendLine.chtLineMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  mp     : TPoint;
  clkPart: TChartClickedPart;
begin
  mp := chtLine.GetCursorPos;
  chtLine.CalcClickedPart(mp, clkPart);

  if clkPart.Part = cpSeriesPointer then
    with clkPart do
      chtLine.Hint := format('%s：%8.2f',
        [formatdatetime('yyyy-mm-dd', TLineSeries(ASeries).XValue[PointIndex]),
        TLineSeries(ASeries).YValue[PointIndex]])
  else if clkPart.Part = cpChartRect then
  begin
    if Shift = [ssRight] then
      FOpType := otDragChart;
    popTL.AutoPopup := False;
  end
  else
    chtLine.Hint := '';
  (*
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
  *)
end;

procedure TfraBasicTrendLine.chtLineMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  pt: TPoint;
begin
  pt := chtLine.ClientToScreen(Point(X, Y));
end;

procedure TfraBasicTrendLine.ClearDatas(ASeries: TChartSeries);
begin
  ASeries.Clear;
end;

procedure TfraBasicTrendLine.ReleaseTrendLines;
var
  i: Integer;
begin
  for i := chtLine.SeriesCount - 1 downto 0 do
    chtLine.Series[i].Free;
  chtLine.RemoveAllSeries;
end;

procedure TfraBasicTrendLine.SetChartTitle(ATitle: string);
begin
  chtLine.Title.Caption := ATitle;
end;

procedure TfraBasicTrendLine.N7Click(Sender: TObject);
begin
  chtLine.Legend.Alignment := latop;
  N7.Checked := True;
end;

procedure TfraBasicTrendLine.N8Click(Sender: TObject);
begin
  chtLine.Legend.Alignment := laRight;
  N8.Checked := True;
end;

function TfraBasicTrendLine.NewLine(ATitle: string; VAxisIsLeft: Boolean = True): Integer;
var
  ls: TLineSeries;
begin
  Result := -1;

  // ls := TLineSeries.Create(chtLine);
  ls := TMeterLine.Create(chtLine);
  // 2022-10-25 用TMeterLine替代TLineSeries，增加了Meter & DataIndex property

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
  ls.Pointer.Style := TSeriesPointerStyle(chtLine.SeriesCount - 1);

  if chtLine.SeriesCount = 1 then // 第一个曲线PointerStyle是正方形，Size=3显得太大，so...
    ls.Pointer.Size := 2
  else
    ls.Pointer.Size := 3;

  // 画线方式：线段
  // 2022-05-11 如果使用dsCurve类型，则遇到Null点的时候，为了确保前后曲线的连续，TeeChart会保持曲线
  // 的连接，将误导对数据的分析。为了中断连线，必须使用Segments类型。
  ls.DrawStyle := dsSegments;

  Result := chtLine.SeriesList.IndexOf(ls);
end;

procedure TfraBasicTrendLine.piCopyAsEMFClick(Sender: TObject);
begin
  chtLine.Legend.CheckBoxes := False;
  chtLine.CopyToClipboardMetafile(True);
  chtLine.Legend.CheckBoxes := True;
  // chtLine.CopyToClipboardBitmap;
end;

procedure TfraBasicTrendLine.piCurveClick(Sender: TObject);
var
  i : Integer;
  DS: TCustomSeriesDrawStyle;
begin
  piCurve.Checked := not piCurve.Checked;
  if piCurve.Checked then
    DS := dsCurve
  else
    DS := dsSegments;

  for i := 0 to chtLine.SeriesCount - 1 do
    with chtLine.Series[i] as TLineSeries do
      DrawStyle := DS;
end;

procedure TfraBasicTrendLine.piMinimalismClick(Sender: TObject);
begin
  piMinimalism.Checked := not piMinimalism.Checked;
  Minimalism := piMinimalism.Checked;
end;

procedure TfraBasicTrendLine.piRestoreLinePointerClick(Sender: TObject);
var
  i   : Integer;
  Line: TLineSeries;
  ss  : TChartSeries;
begin
  for i := chtLine.SeriesCount - 1 downto 0 do
  begin
    ss := chtLine.Series[i];
    if chtLine.Series[i] is TPointSeries then
    begin
      chtLine.RemoveSeries(ss);
      ss.Free;
    end
    else
    begin
      Line := ss as TLineSeries;
      Line.Pen.Width := 1;
      Line.Pointer.Visible := True;
      Line.Legend.Visible := True;
    end;
  end;
end;

/// <summary>
/// 从IFunctionDiapatcher那里调用RewriteDatas方法将修改后的曲线数据写回到数据表
/// </summary>
procedure TfraBasicTrendLine.piRewriteDataClick(Sender: TObject);
var
  i, ii: Integer;
  ML   : TMeterLine;
  S    : String;
  Datas: PmtDatas;
begin
  for i := 0 to chtLine.SeriesCount - 1 do
  begin
    if chtLine.Series[i] is TMeterLine then
    begin
      ML := (chtLine.Series[i]) as TMeterLine;
      S := ML.Meter.DesignName;
      if ML.Tag = 100 then // =100就是点被拖拽过
      begin
        if MessageDlg(S + '的数据被修改过，是否回写' + ML.Meter.DesignName + '的数据？', mtConfirmation,
          [mbYes, mbNo], 0) = mrYes then
        begin
          New(Datas);
          Screen.Cursor := crHourGlass;
          try
            Datas.DesignName := S;
            Datas.PDIndex := ML.DataIndex;
            for ii := 0 to ml.XValues.Count -1 do
              datas.AddData(ml.XValue[ii], ml.YValue[ii]);
            (IAppServices.FuncDispatcher as IFunctionDispatcher).RewriteData(Datas);
            ShowMessage(S + '数据回写完毕。请用Excel打开检查，必要时重新保存一遍。');
          finally
            Datas.ReleaseData;
            Dispose(Datas);
            Screen.Cursor := crDefault;
          end;
          // (IAppServices.FuncDispatcher as IFunctionDispatcher).RewriteData()
        end;
      end;
    end;
  end;
end;

procedure TfraBasicTrendLine.piCopyAsBitmapClick(Sender: TObject);
var
  JPG: TJPEGExportFormat;
begin
  JPG := TJPEGExportFormat.Create;
  try
    chtLine.Legend.CheckBoxes := False;
    JPG.Panel := chtLine;
    JPG.CopyToClipboard;
  finally
    JPG.Free;
    chtLine.Legend.CheckBoxes := True;
  end;
  // chtLine.CopyToClipboardBitmap;
  // chtLine.CopyToClipboardMetafile(True);
end;

procedure TfraBasicTrendLine.piSaveAsEMFClick(Sender: TObject);
begin
  chtLine.Legend.CheckBoxes := False;
  TeeExport(nil, chtLine);
  chtLine.Legend.CheckBoxes := True;
end;

procedure TfraBasicTrendLine.piSaveAsBitmapClick(Sender: TObject);
begin
  chtLine.Legend.CheckBoxes := False;
  TeeExport(nil, chtLine);
  chtLine.Legend.CheckBoxes := True;
end;

procedure TfraBasicTrendLine.piSaveAsTeeChartClick(Sender: TObject);
begin
  chtLine.Legend.CheckBoxes := False;
  TeeExport(nil, chtLine);
  // VclTee.TeeExport.SaveTeeToFile(chtLine, AName);
  chtLine.Legend.CheckBoxes := True;
end;

procedure TfraBasicTrendLine.piSetupChartClick(Sender: TObject);
begin
  EditChart(nil, chtLine);
end;

procedure TfraBasicTrendLine.piSetupSeriesClick(Sender: TObject);
begin
  if FSelectedSeries <> nil then
    EditSeries(nil, FSelectedSeries);
  { 减少所有曲线的标点 }
  SetSimPointer;
end;

procedure TfraBasicTrendLine.piShow20PointersClick(Sender: TObject);
begin
  SetSimPointer(spm20);
end;

procedure TfraBasicTrendLine.piShowPointersStep2Click(Sender: TObject);
begin
  SetSimPointer(spmStep2);
end;

procedure TfraBasicTrendLine.piShowPointersStep3Click(Sender: TObject);
begin
  SetSimPointer(spmStep3);
end;

procedure TfraBasicTrendLine.piShowPointersStep5Click(Sender: TObject);
begin
  SetSimPointer(spmStep5);
end;

procedure TfraBasicTrendLine.SetMinimalism(V: Boolean);
var
  i: Integer;
begin
  { 如果极简主义，则隐藏一堆东西，同时将过程线的点变小 }
  chtLine.Title.Visible := not V;
  chtLine.Legend.Visible := not V;
  // chtLine.LeftAxis.Visible := not V;
  with chtLine.LeftAxis do
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

  for i := 0 to chtLine.SeriesCount - 1 do
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

{ -----------------------------------------------------------------------------
  Procedure  : SetSimPointer
  Description: 本方法减少过程线中Pointer的数量。采用的方式是：创建新的PointSeries，
  代替原LineSeries的Pointer，但数量减少。
  ----------------------------------------------------------------------------- }
procedure TfraBasicTrendLine.SetSimPointer(ASimMethod: TSimPointerMethod = spm20);
var
  i, iPnt, iStep, j, n: Integer;
  d, dStep            : Double;
  NewPnt              : TPointSeries;
  Line                : TLineSeries;
begin
  // if FSetSimPointer then Exit;
  piRestoreLinePointerClick(Self);
  /// 2022-02-22
  /// 目前本功能中绘制过程线的代码已经转移到uHJX.Template.ChartTemplaceProc单元中了，
  /// 当完成过程线绘制的时候，本Frame中预设的Series均已被删除。新Series由该单元中的
  /// DrawMeterSeires/AddNewLine方法创建，新创建的Line没有设置Name，只设置了Title为
  /// ATLSeries.Title。
  /// 减少Line.Pointer的方法是创建Pointer类型替代原LineSeries的Pointer
  FSetSimPointer := True;
  for iPnt := 0 to chtLine.SeriesCount - 1 do
  begin
    if chtLine.Series[iPnt] is TLineSeries then
    begin
      Line := chtLine.Series[iPnt] as TLineSeries;
      // 如果方法是显示20个点，则少于20个点的就不管了。
      if (ASimMethod = spm20) and (Line.XValues.count < 20) then
        Continue;

      NewPnt := TPointSeries.Create(chtLine);
      NewPnt.Clear;
      NewPnt.Title := Line.Title; // + '_Pointer'; // 这里存在冲突的隐患
      // 新点的外观特点和对应的Line Pointer完全一样
      NewPnt.SeriesColor := Line.SeriesColor;
      NewPnt.HorizAxis := Line.HorizAxis;
      NewPnt.VertAxis := Line.VertAxis;
      if Line.VertAxis = aCustomVertAxis then
        NewPnt.CustomVertAxis := Line.CustomVertAxis;

      // NewPnt.Pointer.Assign(Line.Pointer);
      NewPnt.Pointer.Assign(Line.Pointer);
      // NewPnt.Pointer.Brush.Color := Line.Brush.Color;
      // NewPnt.Pointer.Brush.Style := Line.Pointer.Brush.Style;
      // NewPnt.Pointer.Style := Line.Pointer.Style;

      // 下面的代码按照序号等间隔跳过，但不能保证在日期上均等
      n := Line.XValues.count;
      case ASimMethod of
        spm20: { iStep := Line.XValues.Count div 20; } // 暂时只考虑等序列间隔，不考虑等时间隔
          dStep := (Line.XValues[n - 1] - Line.XValues[0]) / 20;
        spmStep2:
          iStep := 2;
        spmStep3:
          iStep := 3;
        spmStep5:
          iStep := 5;
      end;

      j := 0;

      if ASimMethod = spm20 then
      begin
        d := Line.XValues[0] + dStep;
        NewPnt.AddXY(Line.XValues[0], Line.YValues[0]);
        for i := 0 to n - 1 do
        begin
          if Line.XValues[i] >= d then
          begin
            if Line.XValues[i] > 0 then
              NewPnt.AddXY(Line.XValues[i], Line.YValues[i]);
            d := d + dStep;
          end;
        end;
      end
      else
        for i := 0 to n - 1 do
        begin
          if j > n - 1 then
          begin
            NewPnt.AddXY(Line.XValues[n - 1], Line.YValues[n - 1]);
            break;
          end
          else if Line.XValues[j] <> 0 then
            NewPnt.AddXY(Line.XValues[j], Line.YValues[j]);
          j := j + iStep;
        end;

      // NewPnt.Legend.Visible := False; // 不在Legend上显示
      chtLine.AddSeries(NewPnt);
      NewPnt.Visible := Line.Pointer.Visible;
      Line.Pointer.Visible := False;
      // 减少Pointer之后，线稍粗一号会更好看
      Line.Pen.Width := 2 { Line.Pen.Width + 1 };
      Line.Legend.Visible := False; // 用点的Legend代替线的Legend。
    end;
  end;
end;

procedure TfraBasicTrendLine.AllowDragPoint(ASeries: TLineSeries);
var
  i   : Integer;
  Tool: TDragPointTool;
  b   : Boolean;
begin
  b := False;
  lblHint.Top := (chtLine.Height - lblHint.Height) div 2;
  lblHint.Left := (chtLine.Width - lblHint.Width) div 2;
  for i := 0 to chtLine.Tools.count - 1 do
    if chtLine.Tools.Items[i] is TDragPointTool then
    begin
      Tool := chtLine.Tools.Items[i] as TDragPointTool;
      Tool.OnEndDrag := Self.ChartTool1EndDrag; // 由于Tool是在模板处理单元中添加的，因此未设置事件相应，在此设置一下。
      if Tool.Series = ASeries then
      begin
        b := True;
        Tool.Active := not Tool.Active;
        // ASeries.Pointer.
        if Tool.Active then
          lblHint.Caption := '允许拖拽数据点'
        else
          lblHint.Caption := '禁止拖拽数据点';
      end;
    end;

  if not b then
  begin
    Tool := TDragPointTool.Create(chtLine);
    Tool.Series := ASeries;
    Tool.DragStyle := dsY;
    Tool.Active := True;
    chtLine.Tools.Add(Tool);
    Tool.OnEndDrag := ChartTool1EndDrag;
    lblHint.Caption := '允许拓转数据点';
  end;
  lblHint.Visible := True;
  Timer1.Enabled := True;
end;

procedure TfraBasicTrendLine.ChartTool1EndDrag(Sender: TDragPointTool; Index: Integer);
begin
  // Tag = 100表示数据点被拽过。
  Sender.Series.Tag := 100;
end;

end.
