{ -----------------------------------------------------------------------------
  Unit Name: ufraInclineCharts
  Author:    黄伟
  Date:      17-二月-2017
  Purpose:   测斜仪曲线frame单元。本单元一次性提供完整的测斜仪观测数据图形表现
  方式，包括：2D偏移图（带时间滚动），3D偏移图，2D历史曲线等。
  History:
        2017-09-02  增加了多日期同图绘制偏移曲线的功能，这个功能用于对比曲线的
        变化。
  ----------------------------------------------------------------------------- }
{ 编程说明；
	一、3D Chart坐标轴标题问题
		在TeeChart中，如果使用3D Chart，就面临坐标轴标题在显示方面的各种问题。TeeChart的3D render有三种方式：GDI，
		GDI+，OpenGL。很不幸，每种渲染方式都存在问题。

		GDI：
		首要问题就是没有抗锯齿。其次，所有文字都如同2D一样平平地显示在窗口中，没有进行三维旋转。这样，坐标轴标题
		看起来就很奇怪——实际上，所有文本的显示都看起来有点奇怪，与三维空间的直觉不符。其中DepthAxis标题是水平或垂
		直显示，无论图形怎样旋转，结果都一样。
		GDI+：
		相比GDI，唯一的改进是有了抗锯齿，其他都一样。
		OpenGL：
		OpenGL渲染速度很快，在我的笔记本中十分流畅，比GDI+快的多。但是——它无法正常渲染中文字体。要显示中文，必须将
		字体作为2D Bitmap处理。这样一来，使用OpenGL显示的中文非常难看，惨不忍睹。
		坐标轴显示问题：可以将坐标轴标题在空间进行旋转，比如横轴和竖轴标题，这样看起来就舒服多了。但是——永远有但是
		——使用OpenGL显示深度轴标题时存在问题，一是文字与横轴坐标是平行的，即垂直于深度坐标轴，二是标题的z位置很奇
		怪，比横轴更靠近用户窗口（在面前），这样旋转图形的时候，这个坐标文本就跑的很远。

		一个解决办法：
		采用TeeChart提供的名为Text3D的tool实现水平面两坐标轴标题的正确显示，即用Text3D模拟坐标轴标题，而坐标轴自身不
		显示标题。使用Text3D的问题是其空间坐标难以确定，在IDE中调节的位置，在程序运行中一旦Chart的尺寸发生变化，其
		位置不会随坐标轴位置大小的变化而变化。这时需要在Resize事件中调整Text3D的位置，其Position.X,Y,Z设置方式参见
		_ReDraw3DText方法。Text3D存在的另一个问题是文字的显示不够好看。
}
{ todo: 增加限定图形大小的设置功能，可设置值，或用标尺滑动调节 }
{ todo: 增加允许用户修改标题、轴标题、图例文字的功能 }
{ todo: 尝试使用HTML标题、小标题等更高级的显示方式 }
{ todo: 给2D、3D图形添加Annotation，显示特征值 }
{ todo: 允许用户拥有更多的图形设置能力，直接将TeeChartPro的设置界面提供给用户 }
unit ufraInclineCharts;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
    {---------------} uhwDataType.DSM.Inclinometer {--------------------------------} ,
    VclTee.TeeGDIPlus, VclTee.TeeText3D,
    VclTee.TeeTools, VclTee.TeeSurfa, VclTee.TeePoin3, VclTee.TeEngine, VclTee.Series, Vcl.ExtCtrls,
    VclTee.TeeProcs, VclTee.Chart, Vcl.ComCtrls, VclTee.TeeAnimations, Vcl.Menus,
    Vcl.StdCtrls, Vcl.WinXCtrls, Vcl.Buttons, VclTee.TeeOpenGL;

type
    TfraInclineCharts = class(TFrame)
        axscrltlChartTool1: TAxisScrollTool;
        axscrltlChartTool2: TAxisScrollTool;
        cht2DA: TChart;
        cht3D: TChart;
        chtHistoryLinesA: TChart;
        LineA: THorizLineSeries;
        hrzlnsrsSeries2: THorizLineSeries;
        hrzlnsrsSeries3: THorizLineSeries;
        hrzlnsrsSeries4: THorizLineSeries;
        pgcInclineCharts: TPageControl;
        Line3D: TPoint3DSeries;
        rtlChartTool1: TRotateTool;
        rtlChartTool2: TRotateTool;
        tab2D: TTabSheet;
        tab3D: TTabSheet;
        tabHistory: TTabSheet;
        TeeGDIPlus1: TTeeGDIPlus;
        cht2DB: TChart;
        LineB: THorizLineSeries;
        AxisScrollTool1: TAxisScrollTool;
        AxisScrollTool2: TAxisScrollTool;
        pmChartOp: TPopupMenu;
        piCopyChart: TMenuItem;
        piCopyAsWMF: TMenuItem;
        piCopyAsBitmap: TMenuItem;
        N1: TMenuItem;
        piFeatureFunction: TMenuItem;
        tabEigenValue: TTabSheet;
        mmoEigenValue: TMemo;
        pnlHoleInfo: TPanel;
        lblHoleInfo: TLabel;
        TeeGDIPlus2: TTeeGDIPlus;
        piAutoRotate: TMenuItem;
        Ani3DChart: TTeeAnimationTool;
        piExportGIF: TMenuItem;
        Panel1: TPanel;
        btnHisD: TSpeedButton;
        btnHisA: TSpeedButton;
        btnHisB: TSpeedButton;
        BalloonHint1: TBalloonHint;
        TeeOpenGL1: TTeeOpenGL;
        TeeOpenGL2: TTeeOpenGL;
        ctl3d_A: TText3DTool;
        ctl3d_B: TText3DTool;
        ctl3d_D: TText3DTool;
        TeeGDIPlus3: TTeeGDIPlus;
        N2: TMenuItem;
        piEditChart: TMenuItem;
        procedure tab2DResize(Sender: TObject);
        procedure piCopyAsWMFClick(Sender: TObject);
        procedure piCopyAsBitmapClick(Sender: TObject);
        procedure pmChartOpPopup(Sender: TObject);
        procedure piAutoRotateClick(Sender: TObject);
        procedure piExportGIFClick(Sender: TObject);
        procedure btnHisDClick(Sender: TObject);
        procedure piEditChartClick(Sender: TObject);
    private
        { Private declarations }
        FHoleInfo: TdtInclineHoleInfo;
        FHisDatas: PdtInHistoryDatas;
        procedure ShowActivity(bActive: Boolean; AInfo: string = '');
        { 绘制历次观测过程线，参数Dir表明是绘制合成方向、A向、B向，值为0，1，2 }
        procedure _DrawHistoryLine(HisDatas: PdtInHistoryDatas; Dir: Integer = 0);
        procedure _ReDrawText3D;
    public
        { Public declarations }
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        // 设置测斜孔基本信息
        procedure SetHoleInfo(AInfo: TdtInclineHoleInfo);
        { 绘制2D偏移曲线 }
        procedure Draw2DLine(Datas: PdtInclinometerDatas);
        { 绘制多个日期的2D偏移曲线 }
        procedure DrawMultDate2DLines(MultDatas: PdtInHistoryDatas);
        // 绘制3D偏移曲线
        procedure Draw3DLine(Datas: PdtInclinometerDatas);
        // 绘制时间过程线，Dir为方向，值为0-合成、1-A、2-B
        procedure Draw2DHistoryLines(HisDatas: PdtInHistoryDatas); overload;
        procedure Draw2DHistoryLines; overload; // 绘制合成方向D的历次曲线
        // 显示特征值内容
        procedure ShowEigenValue(Datas: PdtInclinometerDatas);

        property HistoryDatas: PdtInHistoryDatas read FHisDatas write FHisDatas;
    end;

implementation

uses VclTee.TeeGIF, Vcl.Imaging.GIFImg, VclTee.TeExport, VclTee.TeeEditPro, VclTee.EditChar;
{$R *.dfm}


function GetMax(d1, d2: Double): Double;
begin
    if d1 > d2 then
        result := d1
    else
        result := d2
end;

function GetMax2(d1, d2, d3: Double): Double;
begin
    result := GetMax(d1, d2);
    result := GetMax(result, d3);
end;

procedure TfraInclineCharts.btnHisDClick(Sender: TObject);
var
    i: Integer;
begin
    if Sender = btnHisD then
        i := 0
    else if Sender = btnHisA then
        i := 1
    else if Sender = btnHisB then
        i := 2;
    chtHistoryLinesA.RemoveAllSeries;
    // 检查是否有数据可绘制
    if FHisDatas.HoleID = '' then
        exit;
    if Length(FHisDatas.HisDatas) = 0 then
        exit;
    _DrawHistoryLine(FHisDatas, i);
end;

constructor TfraInclineCharts.Create(AOwner: TComponent);
begin
    inherited;
    pgcInclineCharts.ActivePage := tabEigenValue;
    New(FHisDatas);
end;

destructor TfraInclineCharts.Destroy;
begin
    if FHisDatas <> nil then
    begin
        FHisDatas.ReleaseDatas;
        Dispose(FHisDatas);
    end;
    inherited;
end;

procedure TfraInclineCharts.ShowActivity(bActive: Boolean; AInfo: string = '');
begin
    // lblIndicatorInfo.Caption := AInfo;
    // if bActive = True then
    // begin
    // ActIndicator.StartAnimation;
    // pnlShowActivity.Visible := True;
    // end
    // else
    // begin
    // ActIndicator.StopAnimation;
    // pnlShowActivity.Visible := False;
    // end;
end;

{ 传递并绘制单次观测数据的2D曲线 }
procedure TfraInclineCharts.Draw2DLine(Datas: PdtInclinometerDatas);
var
    i                 : Integer;
    d1, d2, dMax, dMin: Double;
begin
    // Clear all values
    cht2DA.Legend.Visible := false;
    cht2DB.Legend.Visible := false;
    // 移除多余的线，这些线可能是在绘制多日曲线时留下的。
    if cht2DA.SeriesCount > 0 then
        for i := cht2DA.SeriesCount - 1 downto 1 do
            cht2DA.Series[i].Free;
    if cht2DB.SeriesCount > 0 then
        for i := cht2DB.SeriesCount - 1 downto 1 do
            cht2DB.Series[i].Free;

    cht2DA.Series[0].Clear;
    cht2DB.Series[0].Clear;
    // 设置标题
    cht2DA.Title.Caption := '测斜孔' + FHoleInfo.DesignID + #13#10'A向位移变化量曲线(' +
        DateTimeToStr(Datas.DTScale) + ')';
    cht2DB.Title.Caption := '测斜孔' + FHoleInfo.DesignID + #13#10'B向位移变化量曲线(' +
        DateTimeToStr(Datas.DTScale) + ')';
    cht2DA.BottomAxis.Automatic := True;
    cht2DB.BottomAxis.Automatic := True;
    // 填入数据
    if Length(Datas.Datas) > 0 then
    begin
        for i := Low(Datas.Datas) to High(Datas.Datas) do
        begin
            LineA.AddXY(Datas.Datas[i].sgmDA, Datas.Datas[i].Level);
            LineB.AddXY(Datas.Datas[i].sgmDB, Datas.Datas[i].Level);
        end;
        d1 := Abs(LineA.MaxXValue);
        d2 := Abs(LineA.MinXValue);
        dMax := GetMax(d1, d2);
        d1 := Abs(LineB.MaxXValue);
        d2 := Abs(LineB.MinXValue);
        dMax := GetMax2(dMax, d1, d2);
        if dMax < 2 then
            dMax := 2;
        dMin := dMax * -1;
        cht2DA.BottomAxis.Automatic := false;
        cht2DA.BottomAxis.Maximum := dMax;
        cht2DA.BottomAxis.Minimum := dMin;
        cht2DB.BottomAxis.Automatic := false;
        cht2DB.BottomAxis.Maximum := dMax;
        cht2DB.BottomAxis.Minimum := dMin;
    end;
end;

procedure TfraInclineCharts.Draw3DLine(Datas: PdtInclinometerDatas);
var
    i                 : Integer;
    d1, d2, dMax, dMin: Double;
begin
    cht3D.Series[0].Clear;
    cht3D.Title.Caption := '测斜孔' + FHoleInfo.DesignID + #13#10'三维位移变化量曲线(' +
        DateTimeToStr(Datas.DTScale) + ')';
    cht3D.DepthAxis.Title.Angle := 0;
    // cht3D.DepthAxis.Title.
    cht3D.BottomAxis.Automatic := True;
    cht3D.DepthAxis.Automatic := True;
    if Length(Datas.Datas) > 0 then
        for i := Low(Datas.Datas) to High(Datas.Datas) do
            { NOTICE: axis Y data is level, not sgmDB or sgmDA，以X轴为B方向，深度轴为A方向 }
            Line3D.AddXYZ(Datas.Datas[i].sgmDB, Datas.Datas[i].Level, Datas.Datas[i].sgmDA);

    { 下面的代码重置X轴和深度轴的最大最小值，以使Y轴置于图形中央的0位置 }
    d1 := Abs(Line3D.MaxXValue);
    d2 := Abs(Line3D.MinXValue);
    dMax := GetMax(d1, d2);
    d1 := Abs(Line3D.MaxZValue);
    d2 := Abs(Line3D.MinZValue);
    dMax := GetMax2(dMax, d1, d2);
    if dMax < 2 then
        dMax := 2;
    dMin := dMax * -1;

    cht3D.BottomAxis.Automatic := false;
    cht3D.BottomAxis.Maximum := dMax;
    cht3D.BottomAxis.Minimum := dMin;
    cht3D.DepthAxis.Automatic := false;
    cht3D.DepthAxis.Maximum := dMax;
    cht3D.DepthAxis.Minimum := dMin;

end;

procedure TfraInclineCharts.piAutoRotateClick(Sender: TObject);
begin
    if piAutoRotate.Checked then
    begin
        // Ani3DChart.AutoPlay := True;
        Ani3DChart.Loop := True;
        Ani3DChart.Animate.Speed := 60;
        Ani3DChart.Animate.SpeedFactor := 0.1;
        Ani3DChart.Play;
    end
    else
        Ani3DChart.Stop;
end;

procedure TfraInclineCharts.piCopyAsBitmapClick(Sender: TObject);
begin
    (pmChartOp.PopupComponent as TChart).CopyToClipboardBitmap;
end;

procedure TfraInclineCharts.piCopyAsWMFClick(Sender: TObject);
begin
    (pmChartOp.PopupComponent as TChart).CopyToClipboardMetafile(True);
end;

procedure TfraInclineCharts.piEditChartClick(Sender: TObject);
begin
    if pmChartOp.PopupComponent is TChart then
        EditChart(Self, pmChartOp.PopupComponent as TChart);
end;

procedure TfraInclineCharts.piExportGIFClick(Sender: TObject);
// var tmp: TGIFExportFormat;
// aGIF: TGIFImage;
begin
    // tmp := TGIFExportFormat.Create;
    try
        GIFImageDefaultAnimationLoop := glEnabled;
        TeeExport(Self, cht3D);
        // TeeSavePanel(TGIFExportFormat,cht3D);
        // tmp.Panel := cht3D;
        // tmp.Animate := Ani3DChart.Animate;
        // tmp.Animate.Loop := True;
        // ShowActivity(True,'即将开始导出GIF动图，可能需要等待数分钟之久……');
        // Application.ProcessMessages;
        // aGIF := tmp.GIF;
        // agif.Animate := True;
        // aGIF.AnimateLoop := glEnabled;
        // tmp.CreateAnimatedGIF(agif);
        // agif.AnimateLoop := glEnabled;
        // agif.SaveToFile('e:\test.gif');
        // tmp.GIF.AnimateLoop := glContinously;
        // tmp.SaveToFile('e:\test.gif');
        // ShowActivity(False);
        // ShowMessage('导出完成 :)');
    finally
        // tmp.Free;
        // agif.Free;
    end;
end;

procedure TfraInclineCharts.pmChartOpPopup(Sender: TObject);
begin
    if pmChartOp.PopupComponent = cht3D then
    begin
        piAutoRotate.Visible := True;
        piExportGIF.Visible := True;
    end
    else
    begin
        piExportGIF.Visible := false;
        piAutoRotate.Checked := false;
        piAutoRotate.Visible := false;
        // Ani3DChart.AutoPlay := False;
        // Ani3DChart.Loop := False;
        Ani3DChart.Stop;
    end;
end;

procedure TfraInclineCharts.tab2DResize(Sender: TObject);
begin
    cht2DA.Width := tab2D.Width div 2;
    _ReDrawText3D;
end;

procedure TfraInclineCharts._DrawHistoryLine(HisDatas: PdtInHistoryDatas; Dir: Integer = 0);
var
    iDT, i : Integer;
    newLine: THorizLineSeries;
    S      : string;
    d      : Double;
begin
    while chtHistoryLinesA.SeriesCount > 0 do
        chtHistoryLinesA.Series[0].Free;
    chtHistoryLinesA.RemoveAllSeries;
    chtHistoryLinesA.DepthAxis.Items.Clear;
    // chtHistoryLinesA.Canvas.
    // chtHistoryLinesA.RemoveAllSeries;
    chtHistoryLinesA.BottomAxis.AutomaticMinimum := True;
    S := '测斜孔' + HisDatas.HoleID + #13#10;
    case Dir of
        0:
            begin
                S := S + '历次位移曲线';
                chtHistoryLinesA.BottomAxis.AutomaticMinimum := false;
                chtHistoryLinesA.BottomAxis.Minimum := -2;
            end;
        1:
            S := S + 'A向历次位移曲线';
        2:
            S := S + 'B向历次位移曲线';
    end;
    chtHistoryLinesA.Title.Caption := S;

    if Length(HisDatas.HisDatas) > 0 then
        for iDT := Low(HisDatas.HisDatas) to High(HisDatas.HisDatas) do
        begin
            // Create a line
            newLine := THorizLineSeries.Create(chtHistoryLinesA);
            chtHistoryLinesA.AddSeries(newLine);
            // newLine.Depth := -1;
            newLine.Depth := 2;
            newLine.LinePen.Width := 2;
            newLine.Transparency := 50;
            newLine.Title :=FormatDateTime('yyyy-mm-dd',HisDatas.HisDatas[iDT].DTScale);
            newLine.LinePen.Color := newLine.SeriesColor;
            newLine.LinePen.Fill.Color := newLine.SeriesColor;
            // set line properties
            // fill in datas
            newLine.BeginUpdate;
            for i := Low(HisDatas.HisDatas[iDT].Datas) to High(HisDatas.HisDatas[iDT].Datas) do
            begin
                case Dir of
                    0:
                        begin
                            d := HisDatas.HisDatas[iDT].Datas[i].sgmDA * HisDatas.HisDatas[iDT]
                                .Datas[i].sgmDA + HisDatas.HisDatas[iDT].Datas[i].sgmDB *
                                HisDatas.HisDatas[iDT].Datas[i].sgmDB;
                            d := Sqrt(d);
                        end;
                    1:
                        d := HisDatas.HisDatas[iDT].Datas[i].sgmDA;
                    2:
                        d := HisDatas.HisDatas[iDT].Datas[i].sgmDB;
                end;
                newLine.AddXY(d, HisDatas.HisDatas[iDT].Datas[i].Level);
            end;
            newLine.EndUpdate;
        end;
end;

procedure TfraInclineCharts.Draw2DHistoryLines(HisDatas: PdtInHistoryDatas);
var
    i      : Integer;
    newLine: THorizLineSeries;
begin
    if btnHisD.Down then
        i := 0
    else if btnHisA.Down then
        i := 1
    else
        i := 2;

    _DrawHistoryLine(HisDatas, i);
    pgcInclineCharts.ActivePage := tabHistory;
end;

procedure TfraInclineCharts.Draw2DHistoryLines;
var
    i: Integer;
begin
    if btnHisD.Down then
        i := 0
    else if btnHisA.Down then
        i := 1
    else
        i := 2;
    _DrawHistoryLine(FHisDatas, i);
    pgcInclineCharts.ActivePage := tabHistory;
end;

{ -----------------------------------------------------------------------------
  Procedure  : DrawMultDate2DLines
  Description: 绘制多个日期的2D偏移曲线
----------------------------------------------------------------------------- }
var
    { 变量pts是曲线Pointer的Style数组，保存了可在多日期同图中使用的点style，这里
      定义了9个，基本够用了，再多就循环使用。多日期同图中，曲线的颜色由Chart自动
      设置，Pointer.style由程序设置。 }
    pts: array [1 .. 9] of TSeriesPointerStyle = (
        psRectangle,
        psTriangle,
        psDownTriangle,
        psDiagCross,
        psStar,
        psCross,
        psDiamond,
        psLeftTriangle,
        psRightTriangle
    );

procedure TfraInclineCharts.DrawMultDate2DLines(MultDatas: PdtInHistoryDatas);
var
    i, iDT            : Integer;
    d1, d2, dMax, dMin: Double;
    ADatas            : PdtInclinometerDatas;
    ALineA, ALineB    : THorizLineSeries;
    // 设置偏移曲线的样式，主要是设置Pointer.style，颜色由chart自动设置。
    procedure _SetLine(L: THorizLineSeries);
    begin
        L.Pointer.Visible := True;
        L.Pointer.Size := 3;
        if L.ParentChart.SeriesCount <= 9 then
            L.Pointer.Style := pts[L.ParentChart.SeriesCount]
        else
        begin
            L.Pointer.Style := pts[L.ParentChart.SeriesCount mod 9];
        end;
    end;

begin
    if cht2DA.SeriesCount > 1 then
        for i := cht2DA.SeriesCount - 1 downto 1 do
            cht2DA.Series[i].Free;
    if cht2DB.SeriesCount > 1 then
        for i := cht2DB.SeriesCount - 1 downto 1 do
            cht2DB.Series[i].Free;
    cht2DA.Series[0].Clear;
    cht2DB.Series[0].Clear;
    cht2DA.Title.Caption := '测斜孔' + FHoleInfo.DesignID + #13#10'A向位移变化量曲线';
    cht2DB.Title.Caption := '测斜孔' + FHoleInfo.DesignID + #13#10'B向位移变化量曲线';
    cht2DA.BottomAxis.Automatic := True;
    cht2DB.BottomAxis.Automatic := True;
    d1 := 0;
    d2 := 0;
    dMax := 0;
    dMin := 0;
    for iDT := Low(MultDatas.HisDatas) to High(MultDatas.HisDatas) do
    begin
        if iDT = Low(MultDatas.HisDatas) then
        begin
            ALineA := LineA;
            ALineB := LineB;
        end
        else
        begin
            ALineA := THorizLineSeries.Create(cht2DA);
            ALineA.ParentChart := cht2DA;
            cht2DA.AddSeries(ALineA);
            ALineB := THorizLineSeries.Create(cht2DB);
            ALineB.ParentChart := cht2DB;
            cht2DB.AddSeries(ALineB);
            _SetLine(ALineA);
            _SetLine(ALineB);
        end;

        ADatas := MultDatas.HisDatas[iDT];
        ALineA.Title := DateToStr(ADatas.DTScale);
        ALineA.LegendTitle := ALineA.Title;
        ALineB.Title := DateToStr(ADatas.DTScale);
        ALineB.LegendTitle := ALineB.Title;
        if Length(ADatas.Datas) > 0 then
            for i := Low(ADatas.Datas) to High(ADatas.Datas) do
            begin
                ALineA.AddXY(ADatas.Datas[i].sgmDA, ADatas.Datas[i].Level);
                ALineB.AddXY(ADatas.Datas[i].sgmDB, ADatas.Datas[i].Level);
            end;
        d1 := GetMax(Abs(ALineA.MaxXValue), Abs(ALineA.MinXValue));
        d2 := GetMax(Abs(ALineB.MaxXValue), Abs(ALineB.MinXValue));
        dMax := GetMax2(d1, d2, dMax);
    end;
    dMin := dMax * -1;
    cht2DA.BottomAxis.Automatic := false;
    cht2DB.BottomAxis.Automatic := false;
    cht2DA.BottomAxis.Maximum := dMax;
    cht2DA.BottomAxis.Minimum := dMin;
    cht2DB.BottomAxis.Maximum := dMax;
    cht2DB.BottomAxis.Minimum := dMin;
    cht2DA.Legend.Visible := True;
    cht2DB.Legend.Visible := True;
end;

procedure TfraInclineCharts.SetHoleInfo(AInfo: TdtInclineHoleInfo);
var
    S: string;
begin
    FHoleInfo := AInfo;
    S := '设计编号：' + AInfo.DesignID + #13#10;
    S := S + '工程部位：' + AInfo.Position + #13#10;
    S := S + '桩    号：' + AInfo.StakeNo + #13#10;
    S := S + '初值日期：' + DateToStr(AInfo.BaseDate) + #13#10;

    lblHoleInfo.Caption := S;
    // s       := s + '观测次数：' + IntToStr( { dtList.Count } lstDTScale.Count);
end;

procedure TfraInclineCharts.ShowEigenValue(Datas: PdtInclinometerDatas);
var
    MaxA, MaxALevel: Double;
    MaxB, MaxBLevel: Double;
    MaxD, MaxDLevel: Double;
    d              : Double;
    i              : Integer;

    procedure AddS(S: string);
    begin
        mmoEigenValue.Lines.Add(S);
    end;
    procedure AddL;
    begin
        mmoEigenValue.Lines.Add('------------------------');
    end;

begin
    mmoEigenValue.Text := '';
    AddS('观测日期：' + DateToStr(Datas.DTScale));
    AddS('观测点数：' + IntToStr(Length(Datas.Datas)));
    AddL;
    // 开始比较，先设初值
    MaxA := Datas.Datas[0].sgmDA;
    MaxALevel := Datas.Datas[0].Level;
    MaxB := Datas.Datas[0].sgmDB;
    MaxBLevel := MaxALevel;
    MaxD := MaxA * MaxA + MaxB * MaxB;
    MaxDLevel := MaxALevel;

    for i := 0 to High(Datas.Datas) do
    begin
        if Abs(MaxA) < Abs(Datas.Datas[i].sgmDA) then
        begin
            MaxA := Datas.Datas[i].sgmDA;
            MaxALevel := Datas.Datas[i].Level;
        end;

        if Abs(MaxB) < Abs(Datas.Datas[i].sgmDB) then
        begin
            MaxB := Datas.Datas[i].sgmDB;
            MaxBLevel := Datas.Datas[i].Level;
        end;

        d := Datas.Datas[i].sgmDA * Datas.Datas[i].sgmDA + Datas.Datas[i].sgmDB *
            Datas.Datas[i].sgmDB;
        if MaxD < d then
        begin
            MaxD := d;
            MaxDLevel := Datas.Datas[i].Level;
        end;
    end;

    AddS('A向最大位移：' + FormatFloat('0.00', MaxA) + 'mm; 高度：' + FormatFloat('0.00', MaxALevel) + 'm');
    AddS('B向最大位移：' + FormatFloat('0.00', MaxB) + 'mm; 高度：' + FormatFloat('0.00', MaxBLevel) + 'm');
    AddS('最大位移   ：' + FormatFloat('0.00', Sqrt(MaxD)) + 'mm; 高度：' + FormatFloat('0.00',
        MaxDLevel) + 'm');
end;

procedure TfraInclineCharts._ReDrawText3D;
begin
    { --------------------------------------- }
    { Chart tool Text3D有个很奇怪的行为，就是除非改变它的Text，否则无论改它的其他任何属性，它都
      不重新绘制。因此，在这里根据Chart的尺寸修改它的位置之后，必须重新设置Text，而且要发生一点
      变化才行，所以先在尾部加一个空格，再删掉那个空格，这样就正常了。 }
    ctl3d_A.Position.X := cht3D.Width / 2 - 50;
    ctl3d_A.Position.Y := cht3D.Height - 10;
    ctl3d_A.Text := 'A向位移(mm) ';
    ctl3d_A.Text := Trim(ctl3d_A.Text);
    // cht3d.Canvas.
    { --------------------------------------- }
    ctl3d_B.Position.X := cht3D.Width / 2 - 50;
    ctl3d_B.Position.Y := cht3D.Height - 10;
    ctl3d_B.Text := 'B向位移(mm) ';
    ctl3d_B.Text := Trim(ctl3d_B.Text);
    { --------------------------------------- }
    ctl3d_D.Position.Z := cht3D.DepthAxis.IAxisSize / 2;
    ctl3d_D.Position.X := cht3D.BottomAxis.IAxisSize / 2;
    ctl3d_D.Text := '深度(m) ';
    ctl3d_D.Text := Trim(ctl3d_D.Text);
    // ctl3d_A.Visible := false; ctl3d_A.Visible :=True;
    // ctl3d_A.Active := false; ctl3d_A.Active := true;
end;

end.
