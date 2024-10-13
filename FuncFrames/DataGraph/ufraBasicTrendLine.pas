{ -----------------------------------------------------------------------------
  Unit Name: ufraBasicTrendLine
  Author:    ��ΰ
  Date:      24-һ��-2018
  Purpose:   ��Frame��Ϊ�����߻�ͼģ��Ļ������ṩ��TreeChart�Ļ������ݡ�����
  �����Ӹ��߼��Ĺ����߻��ƹ��ܽ��ڴ˻����Ϸ�װ���ɡ�
  ��Ҫ���ܣ�
  1��Chart���ã�

  2��Series���ã�
  (1) ������ɫ�����͡���Ӱ����ϸ����㡢��ǩ�ȣ�
  (2) �ṩ������Series�༭���Ի�����
  (3) ������ʱ��ӡ�ɾ��һ��Series����
  (4) ����Series���ݵȻ������ݲ�����
  3��Chart���ݣ�
  (1) ���Ƶ������ݣ��������š��������š������϶��ȣ�
  (2) �ֹ����ñ��⡢����⡢ͼ�����֣�
  (3) ���ṩ������Chart���Ա༭����
  4�������
  (1) ���������Ϊ���ָ�ʽ��ͼ��ͼƬ��
  (2) �ɽ����úõ�ͼ�α���Ϊtee�ļ�����������Chart������ʾ��
  History:   2018-01-24
  2018-07-11 ˫���ᣬ�����Զ����š�����Զ�����ò�Ʋ��Ǻ����롣
  2018-09-21 ���Ӽ���ģʽ
  2022-05-11 �޸�AddData���������в���X������Double��ΪVariant��Ŀ��
  ���ڶԸ�Nullֵ
  2022-10-25
  ��1����������ק�����ߵ���һ�������ߵķ�������������Ϊ������Ctrl����
  ��קһ�������ߵ���һ���У��ͷż��ɡ�������Զ��ж����������⡢
  ���������ߵ���ɫ��Pointer�����⣻
  ��2��˫��Title�ᵯ��InputBox���޸ı��⣻
  ��3��˫��Axis Title�ᵯ��Inputbox���޸ı���

  2022-10-26
  ��1��˫��Pointer������ק���ݵ�
  ----------------------------------------------------------------------------- }
{ TChart�Դ����������϶����������ã�����ȱ�����������š��������Ź��ܡ�������Ȼ��Ҫ�Լ����ʵ�� }
{ todo:����˫��ĳ�����ᣬ��������Զ����� }
{ DONE:���ӿ�����ͼ����̡�Tee��ʽͼ�δ��� }
{ todo:��������ĳ���߹��� }
{ DONE:����chart���ù��� }
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
  // ����Pointer������
  TSimPointerMethod = (spm20, spmStep2, spmStep3, spmStep5);
  // ��ǰ�������ͣ���Ҫ�����ְ������������Ҽ���Ҫ����Ծ�����MouseUpʱ�Ƿ�Ҫ�����˵�
  TOpType = (otNone { ɶ�ض�������û�� } , otDragChart { ��ק��ͼ�� } , otDragSeries { ��ק���� } ,
    otAdjustAxis { ���������� } , otCanPopupMenu { ���Ե����˵� } );

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
    FBeMinimalism  : Boolean; // �Ƿ񼫼�
    FSetSimPointer : Boolean; // �Ƿ�������ģ��㣨ģ����������ԭLine��Pointer��
    FOpType        : TOpType;
    /// <summary>
    /// ȱʡ����£�������ÿ�����ݶ���ʾPointer�������ݽ϶��ʱ����Pointer�϶������ʾ�Ľ����
    /// �ѿ�������TeeChart�ֲ��������Լ�����Pointer�������Ҫ��������Pointer���͵�Series���Line
    /// ��Pointer���ʵ�����������
    /// </summary>
    procedure SetSimPointer(ASimMethod: TSimPointerMethod = spm20); // ����ģ���
    /// ������ֹ��ק���ݵ㣬��֮ǰ��ֹ����ú�������֮��Ȼ
    /// ͬʱҲ��鱻�û���Series�Ƿ��ж�Ӧ��DragPointTool����û���򴴽�һ��
    procedure AllowDragPoint(ASeries: TLineSeries);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // Draw a line
    procedure AddData(ASeries: TChartSeries; X: Double; Y: { Double } Variant; ALabel: String = '');
      overload; // 2022-05-11 �޸�
    procedure AddData(SeriesIndex: Integer; X: Double; Y: { Double } Variant; ALabel: string = '');
      overload; // 2022-05-11 �޸�
    procedure ShowSampleDatas;
    procedure ClearDatas(ASeries: TChartSeries);
    // ɾ��ȫ����������
    procedure ReleaseTrendLines;
    procedure SetChartTitle(ATitle: string);
    // ����һ�����ߣ���û����ʽ���������£��Զ�������ɫ�����ݵ���״
    function NewLine(ATitle: string; VAxisIsLeft: Boolean = True): Integer;
    // ���������߼���
    procedure SetMinimalism(V: Boolean);
    /// <summary>�Ƿ񼫼����壿��ȡ������֮</summary>
    /// <remarks>�����񣬽����ر��⡢�����ᡢͼ����ͬʱ�������ߵĵ�ߴ���С��1��
    /// ����ֻ����ͼ�α���</remarks>
    property Minimalism: Boolean read FBeMinimalism write SetMinimalism;
  end;

implementation

uses
  VclTee.TeePrevi, VclTee.EditChar, VclTee.TeePoEdi {, TeCanvas} , VclTee.TeePenDlg,
  VclTee.TeExport, VclTee.TeeStore, VclTee.TeePNG, VclTee.TeeJPEG, VclTee.TeeGIF,
  VclTee.TeeExport, uMyTeeAxisScrollTool,
  uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher, uHJX.Data.Types,
  uHJX.Template.ChartTemplateProc {���ô˵�Ԫ��Ϊ����TMeterLine���TLineSeries} ,
  uDragSeriesHelper {����Ԫ��������Ϊ����קLineSeries�ṩ����};
{$R *.dfm}

const
  { ����ʮ����Ԥ�������ɫ }
  SSColors: array [0 .. 11] of TColor = (clWebDarkBlue, clwebdarkgreen, clWebMidnightBlue,
    clWebDarkOliveGreen, clWebIndigo, clWebDarkViolet, clWebDarkMagenta, clWebPurple, clWebDeepPink,
    clWebDodgerBlue, clWebTeal, clWebSienna);

  { ���������������λ�ã�����������������CustomAxis��Chart����
    Ϊ������ȷ������Chart�д�������Ե���Position��Margin�Ķ���Ӧ��ѡ��������Ϊ���ڵ�λ������Axis��
    Panel�ȡ�
  }
procedure ReplaceAxes(AChart: TChart);
/// ÿ��Axis����һ��Shape�����Shape����+��ǩ�ķ�Χ����������Title������ͨ��Shape��ȷ����Ŀ�ȣ�
/// ���ǣ����Shape������Visible���У����Կ�������Axis��Shape.Visible := True; Shape.Transparent := True
/// ���������Shape�����Ρ�
/// Ϊ��ȷ��Title�Ĵ�С��������Title��Width��Height��ȷ�����������ᣬ�������ת90�㣬��Ӧ����Height
/// ��ȷ���߶ȡ�
var
  CAList               : TList;
  i                    : Integer;
  CA                   : TChartAxis;
  NextXLeft, NextXRight: Integer;
  MargLeft, MargRight  : Integer;
  preUnit              : TTeeUnits;
  L1st, R1st           : Boolean; // �Ƿ��ǵ�һ�����ᡢ��һ�����ᣬ����ȷ��Margin�Ƿ�����10��pixels
begin
  NextXLeft := 0;
  NextXRight := 0;
  MargLeft := 20;
  MargRight := 20;
  { todo:Ϊ����������������������һ��Chart�͸����������PositionUnit }
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

  { LeftAxis��RightAxis��ʾ���Panel���Զ�����Margin }
  CAList := TList.Create;
  try
    for i := 0 to AChart.SeriesList.count - 1 do
      if AChart[i].Active then
        case AChart[i].VertAxis of
          aLeftAxis:
            begin
              if CAList.IndexOf(AChart.LeftAxis) = -1 then
              begin
                { todo:�迼��LeftAxis���ص����������û��Seriesʹ��LeftAxisʱ�������� }
                if AChart.LeftAxis.Visible then
                begin
                  CAList.Add(AChart.LeftAxis);
                  // �����ѭ���У���������LeftAxis��Margin�������������޳������治���ж�
                  // MargLeft := MargLeft - extraMargin;
                  MargLeft := MargLeft - AChart.LeftAxis.Shape.Width - AChart.LeftAxis.Title.Height;
                  // .Width;
                end;
              end;
            end;
          aRightAxis: { Case��û��Series��ӦRightAxis������RightAxis��Ȼ��Visible����������û�д��� }
            begin
              if CAList.IndexOf(AChart.RightAxis) = -1 then
              begin
                { todo:�迼��RightAxis���ص���� }
                if AChart.RightAxis.Visible then
                begin
                  CAList.Add(AChart.RightAxis);
                  // MargRight := MargRight - extraMargin;
                  // ������û�����߶�Ӧʱ����Ҳ����ʾ�ģ���û�����أ�����ʱ��Shape.WidthС���㣬
                  // ����Title.Height��Ϊ�㣬������ֵ
                  MargRight := MargRight - Abs(AChart.RightAxis.Shape.Width) -
                    AChart.RightAxis.Title.Height;
                end;
              end;
            end;
          aCustomVertAxis:
            begin
              { todo:�迼��CustomAxis���ص���� }
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

        if R1st then { ע�⣬�Ҳ����Shape.Width��Ȼ�Ǹ��ģ��� }
          MargRight := MargRight + Abs(CA.Shape.Width) + CA.Title.Height + 10
        else
        begin
          if CA.Shape.Width < 0 then
            MargRight := MargRight + Abs(CA.Shape.Width) + CA.Title.Height
          else
            MargRight := MargRight + CA.Title.Height;
          // ����ǵ�һ���ᣬ���üӣ������ڽ���һ���������¶�Margin��10������
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

  { ����NewSS������Series��ɫ��ͬ }
  procedure _SetDiffColor;
  var
    iSS       : Integer;
    iClr      : Integer;
    bSameColor: Boolean;
  begin
    { ͨ�����ñ�����ʱ����ζ��NewSSû�в��������ɫ����ʱNewSS����ɫΪDrag��Series��ɫ }
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
{ ����NewSS������Series��Pointer��ͬ }
  procedure _SetDiffPointer;
  var
    iSS  : Integer;
    iPt  : Integer;
    bSame: Boolean;
  begin
    iPt := 0;
    // ����Pointer�ߴ����ִ��һֱ
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

  { ����֮ǰ��Ӧ�ȼ���Ƿ�����ͬ�������ߣ����пɲ�ȡ�������������ȴ�ʩ }
  { todo:������LineSeries֮ǰ��Ӧ�ȼ���Ƿ��������Ĺ����ߣ�������ȡ�������������������ǰ׺ }
  // NewSS := TLineSeries.Create(AChart);
  NewSS := TMeterLine.Create(AChart);
  // dragS := ADropSeries as TLineSeries;
  NewSS.Assign(ADropSeries { FDragSeries as TLineSeries } );
  if ADropSeries is TMeterLine then
  begin
    NewSS.Meter := (ADropSeries as TMeterLine).Meter;
    NewSS.DataIndex := (ADropSeries as TMeterLine).DataIndex;
    // ����NewSS��Title
    NewSS.Title := NewSS.Meter.DesignName + '-' + NewSS.Meter.DataSheetStru.PDs.Items
      [NewSS.DataIndex - 1].Name; // DataIndex��PDIndex����ʼ��Ϊ1
  end;

  // �޸�Chart������MeterLine�����ƣ��Ա�������ͬ������
  for i := 0 to AChart.SeriesCount - 1 do
  begin
    if AChart.Series[i] is TMeterLine then
      with AChart.Series[i] as TMeterLine do
      begin
        Title := Meter.DesignName + '-' + Meter.DataSheetStru.PDs.Items[DataIndex - 1].Name;
      end;
  end;

  { todo:��Ҫ�������������⣬��������������ᣬ����Ҫ������������� }
  // 2022-9-9 ����Ĵ������FDragSeries���������ж��Ƿ���Ҫ������������
  sAxisTitle := ADropSeries.GetVertAxis.Title.Text;
  // �ж������������Ƿ���ͬ�������ᣬ���У�������Ϊ���ᣬ���ޣ������ΪCustomVerAxis��
  { todo: ����ĳ��ȱʡ��û���ã�����RightAxis����Drop��Series������Ҫһ�����ᣬ��ʱ�Ͳ�Ӧ�ô���
    CustomAxis������ֱ��ʹ������ }
  b := False;
  for i := 0 to AChart.Axes.count - 1 do
    if AChart.Axes.Items[i].Title.Text = sAxisTitle then
    begin
      b := True;
      CA := AChart.Axes.Items[i];
      break;
    end;

  // ���û���ҵ�����ᣬ����Ҫ����
  if not b then
  begin
    // ���û���ҵ���ֻ�ܴ���CustomAxes
    CA := AChart.CustomAxes.Add;
    NewAxisTool := ThwTeeAxisScrollTool.Create(AChart.Parent);
    NewAxisTool.Axis := CA;
    NewAxisTool.Active := True;
    CA.Title.Text := sAxisTitle;
    CA.Horizontal := False;
    CA.PositionUnits := muPixels;
    CA.Grid.Visible := False;
    // ������ɫ
    j := 0;
    for i := 0 to AChart.Axes.count - 1 do // ����CustomAxis��ȱʡ����6������������ֻ����
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
    // ����������ᣬ�����CustomAxis����Series��ɫӦ������ɫ��ͬ������Ӧ���ǲ�ͬ������Series����ɫ
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
          NewSS.Color := AChart.CustomAxes[i].Axis.Color; // �����CustomAxis����Series��ɫ����ͬɫ
          break;
        end;
    end;
  end;
  NewSS.HorizAxis := aBottomAxis;
  // ShowMessage(sAxisTitle);

  { todo:��Ҫ�������ù�������ɫ��������͵�ָʾ��Ϣ }
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
  // �������YΪNullֵ�ĵ� 2022-05-11
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
  // 2022-05-11 �������YΪNullֵ�ĵ�
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
      { clkPart.AAxis.Automatic := True }; // ˫���Զ����Ž���uMyTeeAxisScrollTool����
    cpSeries:
      ;
    cpTitle:
      chtLine.Title.Text.Text := InputBox('�޸�ͼ�α���', '�����±���', chtLine.Title.Text.Text);
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
      clkPart.AAxis.Title.Text := InputBox('�޸����������', '�����������±���', clkPart.AAxis.Title.Text);
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
  FOpType := otNone; // ɶҲ����
  popTL.AutoPopup := False;

  if (Button = mbLeft) and (Shift = [ssCtrl, ssLeft]) then { ��ק }
  begin
    if Part.Part = cpSeries then
    begin
      FOpType := otDragSeries;
      uDragSeriesHelper.DragSeries := Part.ASeries as TLineSeries;
      chtLine.BeginDrag(True, -1);
    end;
  end
  else if (Button = mbRight) and (Shift = [ssCtrl, ssLeft]) then { LeftCtrl+MouseRight: ������ }
  begin { �����ᣬ��ֹ����ʽ�˵� }
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
          { �����ChartRect�е����˵������޷��϶����� }
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
      chtLine.Hint := format('%s��%8.2f',
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
    // Ŀǰ��ʱ��Zoom�ķ�����ʵ�������᷽������š�������ͬʱ�������к�����������ᣬ������
    // �������ĳһ����������š�
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
    chtLine.Hint := format('%s��%8.2f',
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
  // 2022-10-25 ��TMeterLine���TLineSeries��������Meter & DataIndex property

  ls.Name := 'NewLine' + IntToStr(Integer(ls));
  ls.Title := ATitle;
  chtLine.AddSeries(ls);
  // ��������
  if VAxisIsLeft then
    ls.VertAxis := aLeftAxis
  else
    ls.VertAxis := aRightAxis;
  // ����Ϊ���ڸ�ʽ
  ls.XValues.DateTime := True;
  // ��ɫ
  ls.Color := chtLine.GetFreeSeriesColor;
  // ���ݵ�
  ls.Pointer.Visible := True;

  { todo:����Ӧ������̫���������⣬����汾�����16�е��� }
  ls.Pointer.Style := TSeriesPointerStyle(chtLine.SeriesCount - 1);

  if chtLine.SeriesCount = 1 then // ��һ������PointerStyle�������Σ�Size=3�Ե�̫��so...
    ls.Pointer.Size := 2
  else
    ls.Pointer.Size := 3;

  // ���߷�ʽ���߶�
  // 2022-05-11 ���ʹ��dsCurve���ͣ�������Null���ʱ��Ϊ��ȷ��ǰ�����ߵ�������TeeChart�ᱣ������
  // �����ӣ����󵼶����ݵķ�����Ϊ���ж����ߣ�����ʹ��Segments���͡�
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
/// ��IFunctionDiapatcher�������RewriteDatas�������޸ĺ����������д�ص����ݱ�
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
      if ML.Tag = 100 then // =100���ǵ㱻��ק��
      begin
        if MessageDlg(S + '�����ݱ��޸Ĺ����Ƿ��д' + ML.Meter.DesignName + '�����ݣ�', mtConfirmation,
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
            ShowMessage(S + '���ݻ�д��ϡ�����Excel�򿪼�飬��Ҫʱ���±���һ�顣');
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
  { �����������ߵı�� }
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
  { ����������壬������һ�Ѷ�����ͬʱ�������ߵĵ��С }
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
  Description: ���������ٹ�������Pointer�����������õķ�ʽ�ǣ������µ�PointSeries��
  ����ԭLineSeries��Pointer�����������١�
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
  /// Ŀǰ�������л��ƹ����ߵĴ����Ѿ�ת�Ƶ�uHJX.Template.ChartTemplaceProc��Ԫ���ˣ�
  /// ����ɹ����߻��Ƶ�ʱ�򣬱�Frame��Ԥ���Series���ѱ�ɾ������Series�ɸõ�Ԫ�е�
  /// DrawMeterSeires/AddNewLine�����������´�����Lineû������Name��ֻ������TitleΪ
  /// ATLSeries.Title��
  /// ����Line.Pointer�ķ����Ǵ���Pointer�������ԭLineSeries��Pointer
  FSetSimPointer := True;
  for iPnt := 0 to chtLine.SeriesCount - 1 do
  begin
    if chtLine.Series[iPnt] is TLineSeries then
    begin
      Line := chtLine.Series[iPnt] as TLineSeries;
      // �����������ʾ20���㣬������20����ľͲ����ˡ�
      if (ASimMethod = spm20) and (Line.XValues.count < 20) then
        Continue;

      NewPnt := TPointSeries.Create(chtLine);
      NewPnt.Clear;
      NewPnt.Title := Line.Title; // + '_Pointer'; // ������ڳ�ͻ������
      // �µ������ص�Ͷ�Ӧ��Line Pointer��ȫһ��
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

      // ����Ĵ��밴����ŵȼ�������������ܱ�֤�������Ͼ���
      n := Line.XValues.count;
      case ASimMethod of
        spm20: { iStep := Line.XValues.Count div 20; } // ��ʱֻ���ǵ����м���������ǵ�ʱ���
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

      // NewPnt.Legend.Visible := False; // ����Legend����ʾ
      chtLine.AddSeries(NewPnt);
      NewPnt.Visible := Line.Pointer.Visible;
      Line.Pointer.Visible := False;
      // ����Pointer֮�����Դ�һ�Ż���ÿ�
      Line.Pen.Width := 2 { Line.Pen.Width + 1 };
      Line.Legend.Visible := False; // �õ��Legend�����ߵ�Legend��
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
      Tool.OnEndDrag := Self.ChartTool1EndDrag; // ����Tool����ģ�崦��Ԫ����ӵģ����δ�����¼���Ӧ���ڴ�����һ�¡�
      if Tool.Series = ASeries then
      begin
        b := True;
        Tool.Active := not Tool.Active;
        // ASeries.Pointer.
        if Tool.Active then
          lblHint.Caption := '������ק���ݵ�'
        else
          lblHint.Caption := '��ֹ��ק���ݵ�';
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
    lblHint.Caption := '������ת���ݵ�';
  end;
  lblHint.Visible := True;
  Timer1.Enabled := True;
end;

procedure TfraBasicTrendLine.ChartTool1EndDrag(Sender: TDragPointTool; Index: Integer);
begin
  // Tag = 100��ʾ���ݵ㱻ק����
  Sender.Series.Tag := 100;
end;

end.
