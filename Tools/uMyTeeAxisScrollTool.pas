{ -----------------------------------------------------------------------------
 Unit Name: uMyTeeAxisScrollTool
 Author:    Administrator
 Date:      04-十一月-2015
 Purpose:   可使用鼠标拖动TeeChart坐标轴，按下Ctrl键后拖动鼠标将缩放坐标轴。

            本工具没有使用鼠标滚轮实施坐标轴缩放的原因在于对于横轴，不产生鼠标
            滚轮事件。

            在实施缩放时，如果按鼠标左键进行缩放横轴的时候，松开左键后缩放效果
            会发生变化，估计是因为按左键激活了Chart自身的Zoom设置。要获得理想
            的缩放效果，应当按Ctrl + 右键进行缩放。

            双击坐标轴，坐标轴将自动设置MaxMin，图形恢复原状。

            如果启用了Zoom的动画效果，在对坐标轴进行缩放时，会导致反应迟缓（本
            工具使用了ZoomRect方法进行缩放，而非改变坐标轴的Max、Min值）。

 History:

 Usage:     本单元在加载时已自动注册了本工具类，用户只需要创建实例、加入到Chart、
            为本工具指定一个坐标轴即可。注意需要人工进行释放。
----------------------------------------------------------------------------- }

unit uMyTeeAxisScrollTool;

interface

uses
  Windows, SysUtils, Classes, Controls,
  VCLTee.TeEngine, VCLTee.Chart
    ;
{ todo: 增加双击坐标轴后坐标轴的MaxMin设为自动的功能 }

type
  ThwTeeAxisScrollTool = class(TTeeCustomToolAxis)
  private
    FScrollInverted : Boolean;
    OldX, OldY      : Integer;
    InAxis, LastAxis: TChartAxis;
    FFactor         : Double;
        // 是否自动剪裁超出本坐标轴区域的图形
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
        // 剪裁超出本坐标轴区域的图形，只剪裁使用本坐标轴的图形，其他的不管。
    property ClipSeries: Boolean read FAutoClipSeries write FAutoClipSeries default False;
  end;

    { 以Axis Bound为边界剪裁Series的工具，可以剪裁所有图形，使它们不超出它们的坐标轴范围 }
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
  Date:      04-十一月-2015
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

    { 如果采用ZoomRect方法，会对所有曲线实施缩放。一般来说，应只针对X轴实现ZoomRect，改变所有曲线的
      日期范围。 }
  procedure DoAxisZoom(AAxis: TChartAxis);
  var
    zRect : TRect;
    ADelta: Double;
  begin
    if AAxis.IAxisSize <> 0 then
    begin
      if AAxis.Horizontal then
      begin
                { 对横轴缩放也采用设置坐标轴MAX,MIN方式。采用ZoomRect方法在多Y轴的时候，以LeftAxis和
                  RightAxis为坐标轴的图形缩放时出现了问题，采用SetMinMax方法后解决，尚未明了该问题是
                  何原因引起。 }
                // zRect := Rect(gRect.Left - Delta, gRect.Top, gRect.Right + Delta, gRect.Bottom);
                // TChart(ParentChart).ZoomRect(zRect);
        ADelta := Delta * (AAxis.Maximum - AAxis.Minimum) / AAxis.IAxisSize;
        AAxis.SetMinMax(AAxis.Minimum - ADelta, AAxis.Maximum + ADelta);
      end
      else
      begin
                { 对Y轴采用ZoomRect方法会影响所有曲线，因此仍采用设置Max、Min方法 }
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
// { 判断用户鼠标所在的坐标轴，并返回它 }
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
// //是水平轴：
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
  result := '坐标轴卷动及缩放工具';
end;

{ -----------------------------------------------------------------------------
  Procedure:    ThwTeeAxisScrollTool.LongDescription
  Description:
----------------------------------------------------------------------------- }
class function ThwTeeAxisScrollTool.LongDescription: string;
begin
  result := 'hw编写的类似AxisScrollTool的坐标轴卷动及缩放工具，'#13#10 + '对坐标轴的缩放可使用Ctrl+鼠标右键完成。';
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
  result := '按坐标轴边界剪裁图形';
end;

class function ThwClipSeriesTool.LongDescription: string;
begin
  result := '将图形的显示范围限值在坐标轴边界内，使之不超出该边界。';
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
 Date:      04-十一月-2015
 Purpose:   可使用鼠标拖动TeeChart坐标轴，按下Ctrl键后拖动鼠标将缩放坐标轴。

            本工具没有使用鼠标滚轮实施坐标轴缩放的原因在于对于横轴，不产生鼠标
            滚轮事件。

            在实施缩放时，如果按鼠标左键进行缩放横轴的时候，松开左键后缩放效果
            会发生变化，估计是因为按左键激活了Chart自身的Zoom设置。要获得理想
            的缩放效果，应当按Ctrl + 右键进行缩放。

            双击坐标轴，坐标轴将自动设置MaxMin，图形恢复原状。

            如果启用了Zoom的动画效果，在对坐标轴进行缩放时，会导致反应迟缓（本
            工具使用了ZoomRect方法进行缩放，而非改变坐标轴的Max、Min值）。

 History:

 Usage:     本单元在加载时已自动注册了本工具类，用户只需要创建实例、加入到Chart、
            为本工具指定一个坐标轴即可。注意需要人工进行释放。
----------------------------------------------------------------------------- }

unit uMyTeeAxisScrollTool;

interface

uses
  Windows, SysUtils, Classes, Controls,
  VCLTee.TeEngine, VCLTee.Chart
    ;
{ todo: 增加双击坐标轴后坐标轴的MaxMin设为自动的功能 }

type
  ThwTeeAxisScrollTool = class(TTeeCustomToolAxis)
  private
    FScrollInverted : Boolean;
    OldX, OldY      : Integer;
    InAxis, LastAxis: TChartAxis;
    FFactor         : Double;
        // 是否自动剪裁超出本坐标轴区域的图形
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
        // 剪裁超出本坐标轴区域的图形，只剪裁使用本坐标轴的图形，其他的不管。
    property ClipSeries: Boolean read FAutoClipSeries write FAutoClipSeries default False;
  end;

    { 以Axis Bound为边界剪裁Series的工具，可以剪裁所有图形，使它们不超出它们的坐标轴范围 }
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
  Date:      04-十一月-2015
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

    { 如果采用ZoomRect方法，会对所有曲线实施缩放。一般来说，应只针对X轴实现ZoomRect，改变所有曲线的
      日期范围。 }
  procedure DoAxisZoom(AAxis: TChartAxis);
  var
    zRect : TRect;
    ADelta: Double;
  begin
    if AAxis.IAxisSize <> 0 then
    begin
      if AAxis.Horizontal then
      begin
                { 对横轴缩放也采用设置坐标轴MAX,MIN方式。采用ZoomRect方法在多Y轴的时候，以LeftAxis和
                  RightAxis为坐标轴的图形缩放时出现了问题，采用SetMinMax方法后解决，尚未明了该问题是
                  何原因引起。 }
                // zRect := Rect(gRect.Left - Delta, gRect.Top, gRect.Right + Delta, gRect.Bottom);
                // TChart(ParentChart).ZoomRect(zRect);
        ADelta := Delta * (AAxis.Maximum - AAxis.Minimum) / AAxis.IAxisSize;
        AAxis.SetMinMax(AAxis.Minimum - ADelta, AAxis.Maximum + ADelta);
      end
      else
      begin
                { 对Y轴采用ZoomRect方法会影响所有曲线，因此仍采用设置Max、Min方法 }
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
// { 判断用户鼠标所在的坐标轴，并返回它 }
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
// //是水平轴：
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
  result := '坐标轴卷动及缩放工具';
end;

{ -----------------------------------------------------------------------------
  Procedure:    ThwTeeAxisScrollTool.LongDescription
  Description:
----------------------------------------------------------------------------- }
class function ThwTeeAxisScrollTool.LongDescription: string;
begin
  result := 'hw编写的类似AxisScrollTool的坐标轴卷动及缩放工具，'#13#10 + '对坐标轴的缩放可使用Ctrl+鼠标右键完成。';
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
  result := '按坐标轴边界剪裁图形';
end;

class function ThwClipSeriesTool.LongDescription: string;
begin
  result := '将图形的显示范围限值在坐标轴边界内，使之不超出该边界。';
end;

initialization

RegisterTeeTools([ThwTeeAxisScrollTool, ThwClipSeriesTool]);

finalization

UnregisterTeeTools([ThwTeeAxisScrollTool, ThwClipSeriesTool]);

end.
>>>>>>> 19a9cc2e7281586b7fab8882907ff6f8bf46f4eb
