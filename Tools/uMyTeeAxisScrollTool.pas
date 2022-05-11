{ -----------------------------------------------------------------------------
 Unit Name: uMyTeeAxisScrollTool
 Author:    Administrator
 Date:      04-ʮһ��-2015
 Purpose:   ��ʹ������϶�TeeChart�����ᣬ����Ctrl�����϶���꽫���������ᡣ

            ������û��ʹ��������ʵʩ���������ŵ�ԭ�����ڶ��ں��ᣬ���������
            �����¼���

            ��ʵʩ����ʱ��������������������ź����ʱ���ɿ����������Ч��
            �ᷢ���仯����������Ϊ�����������Chart�����Zoom���á�Ҫ�������
            ������Ч����Ӧ����Ctrl + �Ҽ��������š�

            ˫�������ᣬ�����Ὣ�Զ�����MaxMin��ͼ�λָ�ԭ״��

            ���������Zoom�Ķ���Ч�����ڶ��������������ʱ���ᵼ�·�Ӧ�ٻ�����
            ����ʹ����ZoomRect�����������ţ����Ǹı��������Max��Minֵ����

 History:

 Usage:     ����Ԫ�ڼ���ʱ���Զ�ע���˱������࣬�û�ֻ��Ҫ����ʵ�������뵽Chart��
            Ϊ������ָ��һ�������ἴ�ɡ�ע����Ҫ�˹������ͷš�
----------------------------------------------------------------------------- }

unit uMyTeeAxisScrollTool;

interface

uses
  Windows, SysUtils, Classes, Controls,
  VCLTee.TeEngine, VCLTee.Chart
    ;
{ todo: ����˫����������������MaxMin��Ϊ�Զ��Ĺ��� }

type
  ThwTeeAxisScrollTool = class(TTeeCustomToolAxis)
  private
    FScrollInverted : Boolean;
    OldX, OldY      : Integer;
    InAxis, LastAxis: TChartAxis;
    FFactor         : Double;
        // �Ƿ��Զ����ó����������������ͼ��
    FAutoClipSeries: Boolean;
    procedure SetFactor(AData: Double);
  protected
    procedure ChartMouseEvent(AEvent: TChartMouseEvent; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure SeriesEvent(AEvent: TChartToolEvent; ASeries: TChartSeries); override;
        // procedure WheelMouseEvent(AEvent: TWheelMouseEvent; WheelDelta: Integer;
        // X, Y: Integer); override;
    class function GetEditorClass: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function Description: string; override;
    class function LongDescription: string; override;
    property Factor: Double read FFactor write SetFactor;
  published
    property Active;
    property Axis;
    property ScrollInverted: Boolean read FScrollInverted write FScrollInverted default False;
        // ���ó����������������ͼ�Σ�ֻ����ʹ�ñ��������ͼ�Σ������Ĳ��ܡ�
    property ClipSeries: Boolean read FAutoClipSeries write FAutoClipSeries default False;
  end;

    { ��Axis BoundΪ�߽����Series�Ĺ��ߣ����Լ�������ͼ�Σ�ʹ���ǲ��������ǵ������᷶Χ }
  ThwClipSeriesTool = class(TTeeCustomToolSeries)
  private
    FClipAll: Boolean;
  protected
    procedure SeriesEvent(AEvent: TChartToolEvent; ASeries: TChartSeries); override;
  public
    class function Description: string; override;
    class function LongDescription: string; override;
  published
    property Active;
    property Series;
    property ClipAll: Boolean read FClipAll write FClipAll;
  end;

implementation

constructor ThwTeeAxisScrollTool.Create(AOwner: TComponent);
begin
  inherited;
  FFactor := 0.05;
end;

destructor ThwTeeAxisScrollTool.Destroy;
begin
  inherited;
end;

{ -----------------------------------------------------------------------------
  Procedure: ChartMouseEvent
  Author:    Administrator
  Date:      04-ʮһ��-2015
  Arguments: AEvent: TChartMouseEvent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer
  Result:    None
----------------------------------------------------------------------------- }
procedure ThwTeeAxisScrollTool.ChartMouseEvent(AEvent: TChartMouseEvent; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

  function AxisClicked: TChartAxis;
  var
    t: Integer;
  begin
    result := nil;

    if Assigned(Axis) then
    begin
      if Axis.Visible and Axis.Clicked(X, Y) then
          result := Axis;
    end
    else
      with ParentChart do
        for t := 0 to Axes.Count - 1 do
          if Axes[t].Visible and Axes[t].Clicked(X, Y) then
          begin
            result := Axes[t];
            break;
          end;
  end;

var
  Delta  : Integer;
  gRect  : TRect;
  tmpAxis: TChartAxis;

  procedure DoAxisScroll(AAxis: TChartAxis);
  begin
    if AAxis.IAxisSize <> 0 then
        AAxis.Scroll(Delta * (AAxis.Maximum - AAxis.Minimum) / AAxis.IAxisSize, False);
  end;

    { �������ZoomRect�����������������ʵʩ���š�һ����˵��Ӧֻ���X��ʵ��ZoomRect���ı��������ߵ�
      ���ڷ�Χ�� }
  procedure DoAxisZoom(AAxis: TChartAxis);
  var
    zRect : TRect;
    ADelta: Double;
  begin
    if AAxis.IAxisSize <> 0 then
    begin
      if AAxis.Horizontal then
      begin
                { �Ժ�������Ҳ��������������MAX,MIN��ʽ������ZoomRect�����ڶ�Y���ʱ����LeftAxis��
                  RightAxisΪ�������ͼ������ʱ���������⣬����SetMinMax������������δ���˸�������
                  ��ԭ������ }
                // zRect := Rect(gRect.Left - Delta, gRect.Top, gRect.Right + Delta, gRect.Bottom);
                // TChart(ParentChart).ZoomRect(zRect);
        ADelta := Delta * (AAxis.Maximum - AAxis.Minimum) / AAxis.IAxisSize;
        AAxis.SetMinMax(AAxis.Minimum - ADelta, AAxis.Maximum + ADelta);
      end
      else
      begin
                { ��Y�����ZoomRect������Ӱ���������ߣ�����Բ�������Max��Min���� }
                // zRect := Rect(gRect.Left, gRect.Top - Delta, gRect.Right, gRect.Bottom + Delta);
                // AAxis.AdjustMaxMinRect(zRect);
        ADelta := Delta * (AAxis.Maximum - AAxis.Minimum) / AAxis.IAxisSize;
        AAxis.SetMinMax(AAxis.Minimum - ADelta, AAxis.Maximum + ADelta);
      end;
    end;
  end;

  procedure CheckOtherAxes;
  var
    t : Integer;
    tt: Integer;
  begin
    with ParentChart do
      for t := 0 to Axes.Count - 1 do
        if (Axes[t] <> InAxis) and (Axes[t].Horizontal = InAxis.Horizontal) then
          for tt := 0 to SeriesCount - 1 do
            if Series[tt].AssociatedToAxis(InAxis) and
              Series[tt].AssociatedToAxis(Axes[t]) then
            begin
              if not(ssCtrl in Shift) then
                  DoAxisScroll(Axes[t])
              else
                  DoAxisZoom(Axes[t]);
              break;
            end;
  end;

begin
  inherited;

  if Active then
    case AEvent of
      cmeDown:
        begin
          InAxis := AxisClicked;
          LastAxis := InAxis;
          OldX := X;
          OldY := Y;
          if LastAxis <> nil then
            if ssDouble in Shift then
            begin
              LastAxis.Automatic := True;
            end;
        end;
      cmeMove:
        begin
          if Assigned(InAxis) then
          begin
            gRect := Self.ParentChart.ChartRect;

            if InAxis.Horizontal then
                Delta := OldX - X
            else
                Delta := OldY - Y;

            if InAxis.Inverted then
                Delta := -Delta;

            if InAxis.Horizontal then
            begin
              if ScrollInverted then
                  Delta := -Delta;
            end
            else if not ScrollInverted then
                Delta := -Delta;

            if (ssCtrl in Shift) and (ssRight in Shift) then
                DoAxisZoom(InAxis)
            else
                DoAxisScroll(InAxis);

            CheckOtherAxes;

            OldX := X;
            OldY := Y;
            ParentChart.CancelMouse := True;
          end
          else
          begin
            tmpAxis := AxisClicked;
            if tmpAxis <> nil then
            begin
              if (ssCtrl in Shift) then
              begin
                if tmpAxis.Horizontal then
                    ParentChart.Cursor := crSizeWE
                else
                    ParentChart.Cursor := crSizeNS;
              end
              else
                  ParentChart.Cursor := crHandPoint;
              ParentChart.CancelMouse := True;
            end;
          end;
        end;

      cmeUp:
        InAxis := nil;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure:    ThwTeeAxisScrollTool.WheelMouseEvent
  Description:
----------------------------------------------------------------------------- }
// procedure ThwTeeAxisScrollTool.WheelMouseEvent(AEvent: TWheelMouseEvent;
// WheelDelta: Integer;    X, Y: Integer);
// { �ж��û�������ڵ������ᣬ�������� }
// function AxisClicked: TChartAxis;
// var
// t : Integer;
// begin
// result := nil;
//
// if Assigned(Axis) then
// begin
// if Axis.Visible and Axis.Clicked(X, Y) then
// result := Axis;
// end
// else
// with ParentChart do
// for t := 0 to Axes.Count - 1 do
// if Axes[t].Visible and Axes[t].Clicked(X, Y) then
// begin
// result := Axes[t];
// break;
// end;
// end;
//
// var
// gRect: TRect;
// d1,d2: Double;
// Delta: Integer;
// begin
// inherited;
// InAxis := AxisClicked;
// if Assigned(InAxis) then
// begin
// //��ˮƽ�᣺
// if InAxis.Horizontal then
// begin
// gRect := ParentChart.ChartRect;
// if WheelDelta > 0 then
// Delta := 5
// else
// Delta := -5;
// gRect := Rect(gRect.Left + Delta, gRect.Top, gRect.Right - Delta, gRect.Bottom);
// TChart(Parentchart).ZoomRect(gRect);
// end
// else
// begin
// d1 := Inaxis.Maximum - InAxis.Minimum;
// d2:= d1 * FFactor;
// if WheelDelta < 0 then d2:= -d2;
// InAxis.Maximum := Inaxis.Maximum + d2;
// InAxis.Minimum := inaxis.Minimum -d2;
// end;
// end;
// end;
{ -----------------------------------------------------------------------------
  Procedure:    ThwTeeAxisScrollTool.GetEditorClass
  Description:
----------------------------------------------------------------------------- }
class function ThwTeeAxisScrollTool.GetEditorClass: string;
begin
  result := '';
end;

{ -----------------------------------------------------------------------------
  Procedure:    ThwTeeAxisScrollTool.Description
  Description:
----------------------------------------------------------------------------- }
class function ThwTeeAxisScrollTool.Description: string;
begin
  result := '������������Ź���';
end;

{ -----------------------------------------------------------------------------
  Procedure:    ThwTeeAxisScrollTool.LongDescription
  Description:
----------------------------------------------------------------------------- }
class function ThwTeeAxisScrollTool.LongDescription: string;
begin
  result := 'hw��д������AxisScrollTool��������������Ź��ߣ�'#13#10 + '������������ſ�ʹ��Ctrl+����Ҽ���ɡ�';
end;

procedure ThwTeeAxisScrollTool.SetFactor(AData: Double);
begin
  if AData <= 0 then
      AData := 0
  else if AData >= 1 then
      AData := 1;
end;

procedure ThwTeeAxisScrollTool.SeriesEvent(AEvent: TChartToolEvent; ASeries: TChartSeries);
var
  tmpR: TRect;
begin
  if not FAutoClipSeries then
      Exit;

  if Assigned(ParentChart) and ParentChart.CanClip then
    if AEvent = cteBeforeDrawSeries then
    begin
      if (ASeries.GetVertAxis = Self.Axis) or (ASeries.GetHorizAxis = Self.Axis) then
      begin
        tmpR.Left := ASeries.GetHorizAxis.IStartPos;
        tmpR.Right := ASeries.GetHorizAxis.IEndPos;
        tmpR.Top := ASeries.GetVertAxis.IStartPos;
        tmpR.Bottom := ASeries.GetVertAxis.IEndPos;

        ParentChart.Canvas.ClipRectangle(tmpR);
      end;
    end
    else if AEvent = cteAfterDrawSeries then
        ParentChart.Canvas.UnClipRectangle;
end;

procedure ThwClipSeriesTool.SeriesEvent(AEvent: TChartToolEvent; ASeries: TChartSeries);
var
  tmpR: TRect;
  srs : TChartSeries;
begin

  if Assigned(ParentChart) and ParentChart.CanClip then
    if AEvent = cteBeforeDrawSeries then
    begin
      if FClipAll then
          srs := ASeries
      else
          srs := Series;

      tmpR.Left := srs.GetHorizAxis.IStartPos;
      tmpR.Right := srs.GetHorizAxis.IEndPos;
      tmpR.Top := srs.GetVertAxis.IStartPos;
      tmpR.Bottom := srs.GetVertAxis.IEndPos;

      ParentChart.Canvas.ClipRectangle(tmpR);
    end
    else if AEvent = cteAfterDrawSeries then
        ParentChart.Canvas.UnClipRectangle;
end;

class function ThwClipSeriesTool.Description: string;
begin
  result := '��������߽����ͼ��';
end;

class function ThwClipSeriesTool.LongDescription: string;
begin
  result := '��ͼ�ε���ʾ��Χ��ֵ��������߽��ڣ�ʹ֮�������ñ߽硣';
end;

initialization

RegisterTeeTools([ThwTeeAxisScrollTool, ThwClipSeriesTool]);

finalization

UnregisterTeeTools([ThwTeeAxisScrollTool, ThwClipSeriesTool]);

end.
=======
{ -----------------------------------------------------------------------------
 Unit Name: uMyTeeAxisScrollTool
 Author:    Administrator
 Date:      04-ʮһ��-2015
 Purpose:   ��ʹ������϶�TeeChart�����ᣬ����Ctrl�����϶���꽫���������ᡣ

            ������û��ʹ��������ʵʩ���������ŵ�ԭ�����ڶ��ں��ᣬ���������
            �����¼���

            ��ʵʩ����ʱ��������������������ź����ʱ���ɿ����������Ч��
            �ᷢ���仯����������Ϊ�����������Chart�����Zoom���á�Ҫ�������
            ������Ч����Ӧ����Ctrl + �Ҽ��������š�

            ˫�������ᣬ�����Ὣ�Զ�����MaxMin��ͼ�λָ�ԭ״��

            ���������Zoom�Ķ���Ч�����ڶ��������������ʱ���ᵼ�·�Ӧ�ٻ�����
            ����ʹ����ZoomRect�����������ţ����Ǹı��������Max��Minֵ����

 History:

 Usage:     ����Ԫ�ڼ���ʱ���Զ�ע���˱������࣬�û�ֻ��Ҫ����ʵ�������뵽Chart��
            Ϊ������ָ��һ�������ἴ�ɡ�ע����Ҫ�˹������ͷš�
----------------------------------------------------------------------------- }

unit uMyTeeAxisScrollTool;

interface

uses
  Windows, SysUtils, Classes, Controls,
  VCLTee.TeEngine, VCLTee.Chart
    ;
{ todo: ����˫����������������MaxMin��Ϊ�Զ��Ĺ��� }

type
  ThwTeeAxisScrollTool = class(TTeeCustomToolAxis)
  private
    FScrollInverted : Boolean;
    OldX, OldY      : Integer;
    InAxis, LastAxis: TChartAxis;
    FFactor         : Double;
        // �Ƿ��Զ����ó����������������ͼ��
    FAutoClipSeries: Boolean;
    procedure SetFactor(AData: Double);
  protected
    procedure ChartMouseEvent(AEvent: TChartMouseEvent; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure SeriesEvent(AEvent: TChartToolEvent; ASeries: TChartSeries); override;
        // procedure WheelMouseEvent(AEvent: TWheelMouseEvent; WheelDelta: Integer;
        // X, Y: Integer); override;
    class function GetEditorClass: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function Description: string; override;
    class function LongDescription: string; override;
    property Factor: Double read FFactor write SetFactor;
  published
    property Active;
    property Axis;
    property ScrollInverted: Boolean read FScrollInverted write FScrollInverted default False;
        // ���ó����������������ͼ�Σ�ֻ����ʹ�ñ��������ͼ�Σ������Ĳ��ܡ�
    property ClipSeries: Boolean read FAutoClipSeries write FAutoClipSeries default False;
  end;

    { ��Axis BoundΪ�߽����Series�Ĺ��ߣ����Լ�������ͼ�Σ�ʹ���ǲ��������ǵ������᷶Χ }
  ThwClipSeriesTool = class(TTeeCustomToolSeries)
  private
    FClipAll: Boolean;
  protected
    procedure SeriesEvent(AEvent: TChartToolEvent; ASeries: TChartSeries); override;
  public
    class function Description: string; override;
    class function LongDescription: string; override;
  published
    property Active;
    property Series;
    property ClipAll: Boolean read FClipAll write FClipAll;
  end;

implementation

constructor ThwTeeAxisScrollTool.Create(AOwner: TComponent);
begin
  inherited;
  FFactor := 0.05;
end;

destructor ThwTeeAxisScrollTool.Destroy;
begin
  inherited;
end;

{ -----------------------------------------------------------------------------
  Procedure: ChartMouseEvent
  Author:    Administrator
  Date:      04-ʮһ��-2015
  Arguments: AEvent: TChartMouseEvent; Button: TMouseButton; Shift: TShiftState; X, Y: Integer
  Result:    None
----------------------------------------------------------------------------- }
procedure ThwTeeAxisScrollTool.ChartMouseEvent(AEvent: TChartMouseEvent; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

  function AxisClicked: TChartAxis;
  var
    t: Integer;
  begin
    result := nil;

    if Assigned(Axis) then
    begin
      if Axis.Visible and Axis.Clicked(X, Y) then
          result := Axis;
    end
    else
      with ParentChart do
        for t := 0 to Axes.Count - 1 do
          if Axes[t].Visible and Axes[t].Clicked(X, Y) then
          begin
            result := Axes[t];
            break;
          end;
  end;

var
  Delta  : Integer;
  gRect  : TRect;
  tmpAxis: TChartAxis;

  procedure DoAxisScroll(AAxis: TChartAxis);
  begin
    if AAxis.IAxisSize <> 0 then
        AAxis.Scroll(Delta * (AAxis.Maximum - AAxis.Minimum) / AAxis.IAxisSize, False);
  end;

    { �������ZoomRect�����������������ʵʩ���š�һ����˵��Ӧֻ���X��ʵ��ZoomRect���ı��������ߵ�
      ���ڷ�Χ�� }
  procedure DoAxisZoom(AAxis: TChartAxis);
  var
    zRect : TRect;
    ADelta: Double;
  begin
    if AAxis.IAxisSize <> 0 then
    begin
      if AAxis.Horizontal then
      begin
                { �Ժ�������Ҳ��������������MAX,MIN��ʽ������ZoomRect�����ڶ�Y���ʱ����LeftAxis��
                  RightAxisΪ�������ͼ������ʱ���������⣬����SetMinMax������������δ���˸�������
                  ��ԭ������ }
                // zRect := Rect(gRect.Left - Delta, gRect.Top, gRect.Right + Delta, gRect.Bottom);
                // TChart(ParentChart).ZoomRect(zRect);
        ADelta := Delta * (AAxis.Maximum - AAxis.Minimum) / AAxis.IAxisSize;
        AAxis.SetMinMax(AAxis.Minimum - ADelta, AAxis.Maximum + ADelta);
      end
      else
      begin
                { ��Y�����ZoomRect������Ӱ���������ߣ�����Բ�������Max��Min���� }
                // zRect := Rect(gRect.Left, gRect.Top - Delta, gRect.Right, gRect.Bottom + Delta);
                // AAxis.AdjustMaxMinRect(zRect);
        ADelta := Delta * (AAxis.Maximum - AAxis.Minimum) / AAxis.IAxisSize;
        AAxis.SetMinMax(AAxis.Minimum - ADelta, AAxis.Maximum + ADelta);
      end;
    end;
  end;

  procedure CheckOtherAxes;
  var
    t : Integer;
    tt: Integer;
  begin
    with ParentChart do
      for t := 0 to Axes.Count - 1 do
        if (Axes[t] <> InAxis) and (Axes[t].Horizontal = InAxis.Horizontal) then
          for tt := 0 to SeriesCount - 1 do
            if Series[tt].AssociatedToAxis(InAxis) and
              Series[tt].AssociatedToAxis(Axes[t]) then
            begin
              if not(ssCtrl in Shift) then
                  DoAxisScroll(Axes[t])
              else
                  DoAxisZoom(Axes[t]);
              break;
            end;
  end;

begin
  inherited;

  if Active then
    case AEvent of
      cmeDown:
        begin
          InAxis := AxisClicked;
          LastAxis := InAxis;
          OldX := X;
          OldY := Y;
          if LastAxis <> nil then
            if ssDouble in Shift then
            begin
              LastAxis.Automatic := True;
            end;
        end;
      cmeMove:
        begin
          if Assigned(InAxis) then
          begin
            gRect := Self.ParentChart.ChartRect;

            if InAxis.Horizontal then
                Delta := OldX - X
            else
                Delta := OldY - Y;

            if InAxis.Inverted then
                Delta := -Delta;

            if InAxis.Horizontal then
            begin
              if ScrollInverted then
                  Delta := -Delta;
            end
            else if not ScrollInverted then
                Delta := -Delta;

            if (ssCtrl in Shift) and (ssRight in Shift) then
                DoAxisZoom(InAxis)
            else
                DoAxisScroll(InAxis);

            CheckOtherAxes;

            OldX := X;
            OldY := Y;
            ParentChart.CancelMouse := True;
          end
          else
          begin
            tmpAxis := AxisClicked;
            if tmpAxis <> nil then
            begin
              if (ssCtrl in Shift) then
              begin
                if tmpAxis.Horizontal then
                    ParentChart.Cursor := crSizeWE
                else
                    ParentChart.Cursor := crSizeNS;
              end
              else
                  ParentChart.Cursor := crHandPoint;
              ParentChart.CancelMouse := True;
            end;
          end;
        end;

      cmeUp:
        InAxis := nil;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure:    ThwTeeAxisScrollTool.WheelMouseEvent
  Description:
----------------------------------------------------------------------------- }
// procedure ThwTeeAxisScrollTool.WheelMouseEvent(AEvent: TWheelMouseEvent;
// WheelDelta: Integer;    X, Y: Integer);
// { �ж��û�������ڵ������ᣬ�������� }
// function AxisClicked: TChartAxis;
// var
// t : Integer;
// begin
// result := nil;
//
// if Assigned(Axis) then
// begin
// if Axis.Visible and Axis.Clicked(X, Y) then
// result := Axis;
// end
// else
// with ParentChart do
// for t := 0 to Axes.Count - 1 do
// if Axes[t].Visible and Axes[t].Clicked(X, Y) then
// begin
// result := Axes[t];
// break;
// end;
// end;
//
// var
// gRect: TRect;
// d1,d2: Double;
// Delta: Integer;
// begin
// inherited;
// InAxis := AxisClicked;
// if Assigned(InAxis) then
// begin
// //��ˮƽ�᣺
// if InAxis.Horizontal then
// begin
// gRect := ParentChart.ChartRect;
// if WheelDelta > 0 then
// Delta := 5
// else
// Delta := -5;
// gRect := Rect(gRect.Left + Delta, gRect.Top, gRect.Right - Delta, gRect.Bottom);
// TChart(Parentchart).ZoomRect(gRect);
// end
// else
// begin
// d1 := Inaxis.Maximum - InAxis.Minimum;
// d2:= d1 * FFactor;
// if WheelDelta < 0 then d2:= -d2;
// InAxis.Maximum := Inaxis.Maximum + d2;
// InAxis.Minimum := inaxis.Minimum -d2;
// end;
// end;
// end;
{ -----------------------------------------------------------------------------
  Procedure:    ThwTeeAxisScrollTool.GetEditorClass
  Description:
----------------------------------------------------------------------------- }
class function ThwTeeAxisScrollTool.GetEditorClass: string;
begin
  result := '';
end;

{ -----------------------------------------------------------------------------
  Procedure:    ThwTeeAxisScrollTool.Description
  Description:
----------------------------------------------------------------------------- }
class function ThwTeeAxisScrollTool.Description: string;
begin
  result := '������������Ź���';
end;

{ -----------------------------------------------------------------------------
  Procedure:    ThwTeeAxisScrollTool.LongDescription
  Description:
----------------------------------------------------------------------------- }
class function ThwTeeAxisScrollTool.LongDescription: string;
begin
  result := 'hw��д������AxisScrollTool��������������Ź��ߣ�'#13#10 + '������������ſ�ʹ��Ctrl+����Ҽ���ɡ�';
end;

procedure ThwTeeAxisScrollTool.SetFactor(AData: Double);
begin
  if AData <= 0 then
      AData := 0
  else if AData >= 1 then
      AData := 1;
end;

procedure ThwTeeAxisScrollTool.SeriesEvent(AEvent: TChartToolEvent; ASeries: TChartSeries);
var
  tmpR: TRect;
begin
  if not FAutoClipSeries then
      Exit;

  if Assigned(ParentChart) and ParentChart.CanClip then
    if AEvent = cteBeforeDrawSeries then
    begin
      if (ASeries.GetVertAxis = Self.Axis) or (ASeries.GetHorizAxis = Self.Axis) then
      begin
        tmpR.Left := ASeries.GetHorizAxis.IStartPos;
        tmpR.Right := ASeries.GetHorizAxis.IEndPos;
        tmpR.Top := ASeries.GetVertAxis.IStartPos;
        tmpR.Bottom := ASeries.GetVertAxis.IEndPos;

        ParentChart.Canvas.ClipRectangle(tmpR);
      end;
    end
    else if AEvent = cteAfterDrawSeries then
        ParentChart.Canvas.UnClipRectangle;
end;

procedure ThwClipSeriesTool.SeriesEvent(AEvent: TChartToolEvent; ASeries: TChartSeries);
var
  tmpR: TRect;
  srs : TChartSeries;
begin

  if Assigned(ParentChart) and ParentChart.CanClip then
    if AEvent = cteBeforeDrawSeries then
    begin
      if FClipAll then
          srs := ASeries
      else
          srs := Series;

      tmpR.Left := srs.GetHorizAxis.IStartPos;
      tmpR.Right := srs.GetHorizAxis.IEndPos;
      tmpR.Top := srs.GetVertAxis.IStartPos;
      tmpR.Bottom := srs.GetVertAxis.IEndPos;

      ParentChart.Canvas.ClipRectangle(tmpR);
    end
    else if AEvent = cteAfterDrawSeries then
        ParentChart.Canvas.UnClipRectangle;
end;

class function ThwClipSeriesTool.Description: string;
begin
  result := '��������߽����ͼ��';
end;

class function ThwClipSeriesTool.LongDescription: string;
begin
  result := '��ͼ�ε���ʾ��Χ��ֵ��������߽��ڣ�ʹ֮�������ñ߽硣';
end;

initialization

RegisterTeeTools([ThwTeeAxisScrollTool, ThwClipSeriesTool]);

finalization

UnregisterTeeTools([ThwTeeAxisScrollTool, ThwClipSeriesTool]);

end.
>>>>>>> 19a9cc2e7281586b7fab8882907ff6f8bf46f4eb
