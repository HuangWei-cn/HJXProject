{ -----------------------------------------------------------------------------
  Unit Name: ufraInclineCharts
  Author:    ��ΰ
  Date:      17-����-2017
  Purpose:   ��б������frame��Ԫ������Ԫһ�����ṩ�����Ĳ�б�ǹ۲�����ͼ�α���
  ��ʽ��������2Dƫ��ͼ����ʱ���������3Dƫ��ͼ��2D��ʷ���ߵȡ�
  History:
        2017-09-02  �����˶�����ͬͼ����ƫ�����ߵĹ��ܣ�����������ڶԱ����ߵ�
        �仯��
  ----------------------------------------------------------------------------- }
{ ���˵����
	һ��3D Chart�������������
		��TeeChart�У����ʹ��3D Chart���������������������ʾ����ĸ������⡣TeeChart��3D render�����ַ�ʽ��GDI��
		GDI+��OpenGL���ܲ��ң�ÿ����Ⱦ��ʽ���������⡣

		GDI��
		��Ҫ�������û�п���ݡ���Σ��������ֶ���ͬ2Dһ��ƽƽ����ʾ�ڴ����У�û�н�����ά��ת�����������������
		�������ͺ���֡���ʵ���ϣ������ı�����ʾ���������е���֣�����ά�ռ��ֱ������������DepthAxis������ˮƽ��
		ֱ��ʾ������ͼ��������ת�������һ����
		GDI+��
		���GDI��Ψһ�ĸĽ������˿���ݣ�������һ����
		OpenGL��
		OpenGL��Ⱦ�ٶȺܿ죬���ҵıʼǱ���ʮ����������GDI+��Ķࡣ���ǡ������޷�������Ⱦ�������塣Ҫ��ʾ���ģ����뽫
		������Ϊ2D Bitmap��������һ����ʹ��OpenGL��ʾ�����ķǳ��ѿ����Ҳ��̶á�
		��������ʾ���⣺���Խ�����������ڿռ������ת����������������⣬������������������ˡ����ǡ�����Զ�е���
		����ʹ��OpenGL��ʾ��������ʱ�������⣬һ�����������������ƽ�еģ�����ֱ����������ᣬ���Ǳ����zλ�ú���
		�֣��Ⱥ���������û����ڣ�����ǰ����������תͼ�ε�ʱ����������ı����ܵĺ�Զ��

		һ������취��
		����TeeChart�ṩ����ΪText3D��toolʵ��ˮƽ����������������ȷ��ʾ������Text3Dģ����������⣬������������
		��ʾ���⡣ʹ��Text3D����������ռ���������ȷ������IDE�е��ڵ�λ�ã��ڳ���������һ��Chart�ĳߴ緢���仯����
		λ�ò�����������λ�ô�С�ı仯���仯����ʱ��Ҫ��Resize�¼��е���Text3D��λ�ã���Position.X,Y,Z���÷�ʽ�μ�
		_ReDraw3DText������Text3D���ڵ���һ�����������ֵ���ʾ�����ÿ���
}
{ todo: �����޶�ͼ�δ�С�����ù��ܣ�������ֵ�����ñ�߻������� }
{ todo: ���������û��޸ı��⡢����⡢ͼ�����ֵĹ��� }
{ todo: ����ʹ��HTML���⡢С����ȸ��߼�����ʾ��ʽ }
{ todo: ��2D��3Dͼ�����Annotation����ʾ����ֵ }
{ todo: �����û�ӵ�и����ͼ������������ֱ�ӽ�TeeChartPro�����ý����ṩ���û� }
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
        { �������ι۲�����ߣ�����Dir�����ǻ��ƺϳɷ���A��B��ֵΪ0��1��2 }
        procedure _DrawHistoryLine(HisDatas: PdtInHistoryDatas; Dir: Integer = 0);
        procedure _ReDrawText3D;
    public
        { Public declarations }
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        // ���ò�б�׻�����Ϣ
        procedure SetHoleInfo(AInfo: TdtInclineHoleInfo);
        { ����2Dƫ������ }
        procedure Draw2DLine(Datas: PdtInclinometerDatas);
        { ���ƶ�����ڵ�2Dƫ������ }
        procedure DrawMultDate2DLines(MultDatas: PdtInHistoryDatas);
        // ����3Dƫ������
        procedure Draw3DLine(Datas: PdtInclinometerDatas);
        // ����ʱ������ߣ�DirΪ����ֵΪ0-�ϳɡ�1-A��2-B
        procedure Draw2DHistoryLines(HisDatas: PdtInHistoryDatas); overload;
        procedure Draw2DHistoryLines; overload; // ���ƺϳɷ���D����������
        // ��ʾ����ֵ����
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
    // ����Ƿ������ݿɻ���
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

{ ���ݲ����Ƶ��ι۲����ݵ�2D���� }
procedure TfraInclineCharts.Draw2DLine(Datas: PdtInclinometerDatas);
var
    i                 : Integer;
    d1, d2, dMax, dMin: Double;
begin
    // Clear all values
    cht2DA.Legend.Visible := false;
    cht2DB.Legend.Visible := false;
    // �Ƴ�������ߣ���Щ�߿������ڻ��ƶ�������ʱ���µġ�
    if cht2DA.SeriesCount > 0 then
        for i := cht2DA.SeriesCount - 1 downto 1 do
            cht2DA.Series[i].Free;
    if cht2DB.SeriesCount > 0 then
        for i := cht2DB.SeriesCount - 1 downto 1 do
            cht2DB.Series[i].Free;

    cht2DA.Series[0].Clear;
    cht2DB.Series[0].Clear;
    // ���ñ���
    cht2DA.Title.Caption := '��б��' + FHoleInfo.DesignID + #13#10'A��λ�Ʊ仯������(' +
        DateTimeToStr(Datas.DTScale) + ')';
    cht2DB.Title.Caption := '��б��' + FHoleInfo.DesignID + #13#10'B��λ�Ʊ仯������(' +
        DateTimeToStr(Datas.DTScale) + ')';
    cht2DA.BottomAxis.Automatic := True;
    cht2DB.BottomAxis.Automatic := True;
    // ��������
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
    cht3D.Title.Caption := '��б��' + FHoleInfo.DesignID + #13#10'��άλ�Ʊ仯������(' +
        DateTimeToStr(Datas.DTScale) + ')';
    cht3D.DepthAxis.Title.Angle := 0;
    // cht3D.DepthAxis.Title.
    cht3D.BottomAxis.Automatic := True;
    cht3D.DepthAxis.Automatic := True;
    if Length(Datas.Datas) > 0 then
        for i := Low(Datas.Datas) to High(Datas.Datas) do
            { NOTICE: axis Y data is level, not sgmDB or sgmDA����X��ΪB���������ΪA���� }
            Line3D.AddXYZ(Datas.Datas[i].sgmDB, Datas.Datas[i].Level, Datas.Datas[i].sgmDA);

    { ����Ĵ�������X��������������Сֵ����ʹY������ͼ�������0λ�� }
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
        // ShowActivity(True,'������ʼ����GIF��ͼ��������Ҫ�ȴ�������֮�á���');
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
        // ShowMessage('������� :)');
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
    S := '��б��' + HisDatas.HoleID + #13#10;
    case Dir of
        0:
            begin
                S := S + '����λ������';
                chtHistoryLinesA.BottomAxis.AutomaticMinimum := false;
                chtHistoryLinesA.BottomAxis.Minimum := -2;
            end;
        1:
            S := S + 'A������λ������';
        2:
            S := S + 'B������λ������';
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
  Description: ���ƶ�����ڵ�2Dƫ������
----------------------------------------------------------------------------- }
var
    { ����pts������Pointer��Style���飬�����˿��ڶ�����ͬͼ��ʹ�õĵ�style������
      ������9�������������ˣ��ٶ��ѭ��ʹ�á�������ͬͼ�У����ߵ���ɫ��Chart�Զ�
      ���ã�Pointer.style�ɳ������á� }
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
    // ����ƫ�����ߵ���ʽ����Ҫ������Pointer.style����ɫ��chart�Զ����á�
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
    cht2DA.Title.Caption := '��б��' + FHoleInfo.DesignID + #13#10'A��λ�Ʊ仯������';
    cht2DB.Title.Caption := '��б��' + FHoleInfo.DesignID + #13#10'B��λ�Ʊ仯������';
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
    S := '��Ʊ�ţ�' + AInfo.DesignID + #13#10;
    S := S + '���̲�λ��' + AInfo.Position + #13#10;
    S := S + '׮    �ţ�' + AInfo.StakeNo + #13#10;
    S := S + '��ֵ���ڣ�' + DateToStr(AInfo.BaseDate) + #13#10;

    lblHoleInfo.Caption := S;
    // s       := s + '�۲������' + IntToStr( { dtList.Count } lstDTScale.Count);
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
    AddS('�۲����ڣ�' + DateToStr(Datas.DTScale));
    AddS('�۲������' + IntToStr(Length(Datas.Datas)));
    AddL;
    // ��ʼ�Ƚϣ������ֵ
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

    AddS('A�����λ�ƣ�' + FormatFloat('0.00', MaxA) + 'mm; �߶ȣ�' + FormatFloat('0.00', MaxALevel) + 'm');
    AddS('B�����λ�ƣ�' + FormatFloat('0.00', MaxB) + 'mm; �߶ȣ�' + FormatFloat('0.00', MaxBLevel) + 'm');
    AddS('���λ��   ��' + FormatFloat('0.00', Sqrt(MaxD)) + 'mm; �߶ȣ�' + FormatFloat('0.00',
        MaxDLevel) + 'm');
end;

procedure TfraInclineCharts._ReDrawText3D;
begin
    { --------------------------------------- }
    { Chart tool Text3D�и�����ֵ���Ϊ�����ǳ��Ǹı�����Text���������۸����������κ����ԣ�����
      �����»��ơ���ˣ����������Chart�ĳߴ��޸�����λ��֮�󣬱�����������Text������Ҫ����һ��
      �仯���У���������β����һ���ո���ɾ���Ǹ��ո������������ˡ� }
    ctl3d_A.Position.X := cht3D.Width / 2 - 50;
    ctl3d_A.Position.Y := cht3D.Height - 10;
    ctl3d_A.Text := 'A��λ��(mm) ';
    ctl3d_A.Text := Trim(ctl3d_A.Text);
    // cht3d.Canvas.
    { --------------------------------------- }
    ctl3d_B.Position.X := cht3D.Width / 2 - 50;
    ctl3d_B.Position.Y := cht3D.Height - 10;
    ctl3d_B.Text := 'B��λ��(mm) ';
    ctl3d_B.Text := Trim(ctl3d_B.Text);
    { --------------------------------------- }
    ctl3d_D.Position.Z := cht3D.DepthAxis.IAxisSize / 2;
    ctl3d_D.Position.X := cht3D.BottomAxis.IAxisSize / 2;
    ctl3d_D.Text := '���(m) ';
    ctl3d_D.Text := Trim(ctl3d_D.Text);
    // ctl3d_A.Visible := false; ctl3d_A.Visible :=True;
    // ctl3d_A.Active := false; ctl3d_A.Active := true;
end;

end.
