{ -----------------------------------------------------------------------------
  Unit Name: uhwSGEx
  Author:    黄伟
  Date:      27-十月-2015
  Purpose:   本单元是对SimpleGraph图元的扩展，扩展的图元使用GDI+进行绘图。
      使用GDI+进行绘图的内容有：
      1、边框。提供了半透明效果和抗锯齿效果；
      2、填充。允许半透明效果；
      3、文字。提供了抗锯齿显示；
      4、背景图像。对光栅文件和Metafile文件提供了平滑处理。

      计划继续添加的效果有；
      1、边框的Glow（发光）效果；
      2、阴影效果；

      计划增加的图形有：
      1、直线。单直线及多义线；
      2、曲线。

      如果使用SimpleGraph作为安全监测系统布置图的图形组件，可在本图元
      对象的基础上再进行扩展，增加和监测仪器有关的属性。

  History:
      2017-04-19  不知为何，当年既然已经重写了TGraphNode，而TGPPolygonalNode不从这个
      对象TGPGraphNode继承，反而又重写了TPolygonalNode？

      2019-06-19  修正了GraphLink中用GDI绘制线端圆圈的错误。
  ----------------------------------------------------------------------------- }
{ todo:增加边框、连接线的线型，允许断续线、点线等 }
{ todo:增加边框线的宽度，原图形貌似没有设置边框线宽的 }
{ todo:增加阴影效果和发光效果 }
{ todo:增加渐变色彩填充 }
unit uhwSGEx;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.UITypes,
  Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  SimpleGraph, SynGdiPlus;

type
    { 使用GDI+实现图元的绘制方法的基础类 }
  TGPGraphNode = class(TGraphNode)
  private
    FTransparency: SmallInt; // 图元透明度
    FSynPicture  : TSynPicture;
    FDrawTextGdip: Boolean;
  protected
    procedure BackgroundChanged(Sender: TObject); virtual;
    procedure DrawText(Canvas: TCanvas); override;
    procedure DrawBackground(Canvas: TCanvas); override;
        // procedure DrawBorder(Canvas: TCanvas); override;
    procedure DrawBody(Canvas: TCanvas); override;
    procedure SetTransparency(Value: SmallInt);
  public
    constructor Create(AOwner: TSimpleGraph); override;
    destructor Destroy; override;
  published
    property Left;
    property Top;
    property Width;
    property Height;
    property Alignment;
    property Layout;
    property Margin;
    property Background;
    property NodeOptions;
    property Transparency: SmallInt read FTransparency write SetTransparency;
            // 设置透明度之后要刷新一下～～
    property UseGdipDrawText: Boolean read FDrawTextGdip write FDrawTextGdip;
  end;

    { 重写PolygonalNode对象，使用GDI+方法绘图。实际上本对象可以继承自TGPGraphNode，照着
      原对象重写一遍就可以了，不知道当年为何从TPolygonalNode继承，奇怪。 }

  TGPPolygonalNode = class(TPolygonalNode)
  private
        // fVertices    : TPoints;
    FTransparency: SmallInt;
    FSynPicture  : TSynPicture;
    FDrawTextGdip: Boolean; // 注意：缺省是不使用GDI+绘制文本的！！！
  protected
    procedure BackgroundChanged(Sender: TObject); virtual;
    procedure DrawText(Canvas: TCanvas); override;
    procedure DrawBackground(Canvas: TCanvas); override;
    procedure DrawBorder(Canvas: TCanvas); override;
    procedure SetTransparency(Value: SmallInt);
  public
    constructor Create(AOwner: TSimpleGraph); override;
    destructor Destroy; override;
    property Vertices;
  published
    property Transparency   : SmallInt read FTransparency write SetTransparency;
    property UseGdipDrawText: Boolean read FDrawTextGdip write FDrawTextGdip;
  end;

    { 椭圆 }
  TGPEllipticNode = class(TGPGraphNode)
  protected
    function CreateRegion: HRGN; override;
    procedure DrawBorder(Canvas: TCanvas); override;
    function LinkIntersect(const LinkPt: TPoint; const LinkAngle: Double): TPoints; override;
  end;

    { 三角形 }

  TGPTriangularNode = class(TGPPolygonalNode)
  protected
    procedure QueryMaxTextRect(out Rect: TRect); override;
    procedure DefineVertices(const ARect: TRect; var Points: TPoints); override;
  end;
    { 矩形 }

  TGPRectangularNode = class(TGPPolygonalNode)
  protected
    procedure DefineVertices(const ARect: TRect; var Points: TPoints); override;
  end;

    { 菱形 }

  TGPRhomboidalNode = class(TGPPolygonalNode)
  protected
    procedure QueryMaxTextRect(out Rect: TRect); override;
    procedure DefineVertices(const ARect: TRect; var Points: TPoints); override;
  end;
    { 五角形 }

  TGPPentagonalNode = class(TGPPolygonalNode)
  protected
    procedure QueryMaxTextRect(out Rect: TRect); override;
    procedure DefineVertices(const ARect: TRect; var Points: TPoints); override;
  end;

    { THexagonalNode }
    { 六角形 }

  TGPHexagonalNode = class(TGPPolygonalNode)
  protected
    procedure QueryMaxTextRect(out Rect: TRect); override;
    procedure DefineVertices(const ARect: TRect; var Points: TPoints); override;
  end;

    { 连接线对象的GDI+扩展 }
  TGPGraphicLink = class(TGraphLink)
  protected
    procedure DrawControlPoints(Canvas: TCanvas); override;
    procedure DrawHighlight(Canvas: TCanvas); override;
    procedure DrawBody(Canvas: TCanvas); override;
    procedure DrawText(Canvas: TCanvas); override;
    function DrawPointStyle(Canvas: TCanvas; const Pt: TPoint; const Angle: Double;
      Style: TLinkBeginEndStyle; SIZE: Integer): TPoint; override;
  end;

    { 文本 }
    { todo:GDIP支持文本的旋转，将来应当实现~~ }
  TGPTextNode = class(TGPRectangularNode)
  private
    FAutoSize      : Boolean;
    FDataAlignRight: Boolean; // 数据是否右对齐，若右对齐，则当内容变化时，右上角位置不变。
  protected
    procedure Changed(Flags: TGraphChangeFlags); override;
    procedure SetAutoSize(V: Boolean);
    procedure AdjustTextRect;
    function GetShowBorder: Boolean; virtual;
    procedure SetShowBorder(b: Boolean); virtual;
  public
    constructor Create(AOwner: TSimpleGraph); override;
  published
    property AutoSize      : Boolean read FAutoSize write SetAutoSize;
    property DataAlignRight: Boolean read FDataAlignRight write FDataAlignRight;
    property ShowBorder    : Boolean read GetShowBorder write SetShowBorder;
  end;

implementation

// uses
// GDIPAPINew, GDIPObjNew;
type
    { 为调用TGDPPlusFull的protected方法而声明的类，在本单元initialization段创建 }
  TGDIPlusFullEx = class(TGDIPlusFull);

  PPoints = ^TPoints;

  ARGB = DWORD;

    // const
    // ALPHA_SHIFT = 24;
    // {$EXTERNALSYM ALPHA_SHIFT}
    // RED_SHIFT   = 16;
    // {$EXTERNALSYM RED_SHIFT}
    // GREEN_SHIFT = 8;
    // {$EXTERNALSYM GREEN_SHIFT}
    // BLUE_SHIFT  = 0;
    // {$EXTERNALSYM BLUE_SHIFT}
    // ALPHA_MASK  = (ARGB($ff) shl ALPHA_SHIFT);
var
  GdipF: TGDIPlusFullEx;

function MakeColor(a, r, g, b: Byte): ARGB;
begin
  result := ((DWORD(b) shl 0) or (DWORD(g) shl 8) or (DWORD(r) shl 16) or (DWORD(a) shl 24));
end;

function ColorRefToARGB(rgb: COLORREF): ARGB; overload;
begin
  result := MakeColor(255, GetRValue(rgb), GetGValue(rgb), GetBValue(rgb));
end;

function ColorRefToARGB(Alpha: Integer; rgb: COLORREF): ARGB; overload;
begin
  result := MakeColor(Alpha, GetRValue(rgb), GetGValue(rgb), GetBValue(rgb));
end;

function Color2ARGB(AColor: TColor): ARGB; overload;
begin
  result := ColorRefToARGB(ColorToRGB(AColor));
end;

function Color2ARGB(Alpha: Integer; AColor: TColor): ARGB; overload;
begin
  result := ColorRefToARGB(Alpha, ColorToRGB(AColor));
end;

constructor TGPGraphNode.Create(AOwner: TSimpleGraph);
begin
  inherited Create(AOwner);
  FSynPicture := TSynPicture.Create;
  Background.OnChange := BackgroundChanged;
  Transparency := 255;
end;

destructor TGPGraphNode.Destroy;
begin
  FSynPicture.Free;
  inherited;
end;

procedure TGPGraphNode.BackgroundChanged(Sender: TObject);
begin
  Changed([gcView, gcData]);
  FSynPicture.Assign(Background);
end;

procedure TGPGraphNode.DrawText(Canvas: TCanvas);
var
    // DC: HDC;
    // Rect             : TRect;
  gpRect: TGdipRectF;
    // DrawTextFlags: Integer;
    // BkMode, TextAlign: Integer;
    { ------------ }
  graphic, font, brush, fontfml: THandle;
begin
  if FDrawTextGdip then
  begin
        // inherited;
    if TextToShow <> '' then
    begin
            // Rect := TextRect;
            // gpRect.X := Rect.Location.X;
            // gpRect.Y := Rect.Location.Y;
            // gpRect.Width := Rect.Width;
            // gpRect.Height := Rect.Height;

            // DrawTextFlags := DT_NOPREFIX or DT_EDITCONTROL or DT_NOCLIP or TextAlignFlags[Alignment] or TextLayoutFlags[Layout];
            // DC := Canvas.Handle;
            // BkMode := SetBkMode(DC, TRANSPARENT);
            // TextAlign := SetTextAlign(DC, TA_LEFT or TA_TOP);
            // //Canvas.Font.Quality := fqClearTypeNatural;
            // Winapi.Windows.DrawText(DC, PChar(TextToShow), Length(TextToShow), Rect,
            // Owner.DrawTextBiDiModeFlags(DrawTextFlags));
            // SetTextAlign(DC, TextAlign);
            // SetBkMode(DC, BkMode);

            { GDI+ }
      try
        GdipF.CreateFromHDC(Canvas.Handle, graphic);
        GdipF.CreateSolidFill(Color2ARGB(FTransparency, Canvas.font.Color), brush);
        GdipF.CreateFontFamilyFromName(PWideChar(Canvas.font.Name), nil, fontfml);
        GdipF.CreateFont(fontfml, Canvas.font.SIZE, 0, 3, font);
                // GdipF.CreateFontFrom(Canvas.Font.Handle, font);
                // rst := GdipF.CreateFontFrom(Canvas.Handle, font);
        GdipF.SetTextRenderingHint(graphic, trhAntiAliasGridFit { trhAntiAlias } );
                    // GdipF.DrawString(graphic, PWideChar(Self.Text), Length(Text), font, @gpRect { dest } ,
                // 0, brush);
                { 取文字绘制区域大小 }
        GdipF.MeasureString(graphic, PWideChar(TextToShow), StrLen(PWideChar(TextToShow)), font,
          @gpRect, 0, @gpRect, nil, nil);
        gpRect.X := TextRect.Location.X;
        gpRect.Y := TextRect.Location.Y;

        GdipF.DrawString(graphic, PWideChar(TextToShow), Length(TextToShow), font, @gpRect
                    { dest } , 0, brush);
      finally
        GdipF.DeleteGraphics(graphic);
        GdipF.DeleteBrush(brush);
        GdipF.DeleteFont(font);
        GdipF.DeleteFontFamily(fontfml);
      end;
    end;
  end
  else
    inherited;
end;

procedure TGPGraphNode.DrawBackground(Canvas: TCanvas);
var
    // ClipRgn: HRGN;
    // Bitmap: TBitmap;
    // graphic: TGraphic;
  ImageRect: TRect;
begin
  if Background.graphic <> nil then
  begin
    ImageRect.Left := Left + MulDiv(Width, BackgroundMargins.Left, 100);
    ImageRect.Top := Top + MulDiv(Height, BackgroundMargins.Top, 100);
    ImageRect.Right := Left + Width - MulDiv(Width, BackgroundMargins.Right, 100);
    ImageRect.Bottom := Top + Height - MulDiv(Height, BackgroundMargins.Bottom, 100);
        // ClipRgn := CreateClipRgn(Canvas);
        // 采用TSynPicture绘制背景。本方法不支持半透明效果和抗锯齿Metafile显示，
        // 半透明和抗锯齿的wmf、emf、emf+效果需要其他过程实现。
    FSynPicture.Draw(Canvas, ImageRect);
        // ---------------- Origin code -------------------------------------------------
        // ClipRgn := CreateClipRgn(Canvas);
        // try
        // SelectClipRgn(Canvas.Handle, ClipRgn);
        // try
        // Graphic := Background.Graphic;
        // Background.OnChange := nil;
        // try

            // if (Graphic is TMetafile) and (Canvas is TMetafileCanvas) and ((ImageRect.Left >= Screen.Width) or (ImageRect.Top >= Screen.Height)) then
        // begin // Workaround Windows bug!
        // Bitmap := TBitmap.Create;
        // try
        // Bitmap.Transparent := True;
        // Bitmap.TransparentColor := Canvas.Brush.Color;
        // Bitmap.Canvas.Brush.Color := Canvas.Brush.Color;
        // Bitmap.Width := ImageRect.Right - ImageRect.Left;
        // Bitmap.Height := ImageRect.Bottom - ImageRect.Top;
        // Bitmap.PixelFormat := pf32bit;
        // Bitmap.Canvas.StretchDraw(Rect(0, 0, Bitmap.Width, Bitmap**.Height), Graphic);
        // Canvas.Draw(ImageRect.Left, ImageRect.Top, Bitmap);
        // finally
        // Bitmap.Free;
        // end;
        // end
        // else
        // Canvas.StretchDraw(ImageRect, Graphic);
        // finally
        // Background.OnChange := BackgroundChanged;
        // end;
        // finally
        // SelectClipRgn(Canvas.Handle, 0);
        // end;
        // finally
        // DeleteObject(ClipRgn);
        // end;
    Canvas.brush.Style := bsClear;
    DrawBorder(Canvas);
  end;
end;

procedure TGPGraphNode.DrawBody(Canvas: TCanvas);
begin
  inherited;
end;

procedure TGPGraphNode.SetTransparency(Value: SmallInt);
begin
  if Value < 0 then
    FTransparency := 0
  else if Value > 255 then
    FTransparency := 255
  else
    FTransparency := Value;
end;

constructor TGPPolygonalNode.Create(AOwner: TSimpleGraph);
begin
  inherited;
  FTransparency := 255;
  FSynPicture := TSynPicture.Create;
  Background.OnChange := BackgroundChanged;
end;

destructor TGPPolygonalNode.Destroy;
begin
  FSynPicture.Free;
  inherited Destroy;
end;

procedure TGPPolygonalNode.BackgroundChanged(Sender: TObject);
begin
  Changed([gcView, gcData]);
  FSynPicture.Assign(Background);
end;

procedure TGPPolygonalNode.SetTransparency(Value: SmallInt);
begin
  if Value < 0 then
    FTransparency := 0
  else if Value > 255 then
    FTransparency := 255
  else
    FTransparency := Value;
end;

procedure TGPPolygonalNode.DrawBackground(Canvas: TCanvas);
var
    // ClipRgn: HRGN;
  ImageRect: TRect;
begin
  if { (Self.Owner.CommandMode = cmPan) or } (Owner.PZState = 1) then // 2019-11-19
    inherited
  else if Background.graphic <> nil then
  begin
    ImageRect.Left := Left + MulDiv(Width, BackgroundMargins.Left, 100);
    ImageRect.Top := Top + MulDiv(Height, BackgroundMargins.Top, 100);
    ImageRect.Right := Left + Width - MulDiv(Width, BackgroundMargins.Right, 100);
    ImageRect.Bottom := Top + Height - MulDiv(Height, BackgroundMargins.Bottom, 100);
    FSynPicture.Draw(Canvas, ImageRect);
  end;
end;

procedure TGPPolygonalNode.DrawBorder(Canvas: TCanvas);
var
  graphic, Pen, brush: THandle;
begin
    // inherited;
  if Owner.PZState = 1 then
    inherited
  else
    try
      GdipF.CreateFromHDC(Canvas.Handle, graphic);
      GdipF.SetSmoothingMode(graphic, smAntiAlias);
      GdipF.CreatePen(Color2ARGB(FTransparency, Canvas.Pen.Color), Canvas.Pen.Width, uWorld, Pen);
      GdipF.CreateSolidFill(Color2ARGB(FTransparency, Canvas.brush.Color), brush);

      if Canvas.Pen.Style <> psClear then
        GdipF.DrawPolygon(graphic, Pen, PPoints(@Vertices)^, high(Vertices) + 1);

      if Canvas.brush.Style <> bsClear then
        GdipF.FillPolygon(graphic, brush, PPoints(@Vertices)^, high(Vertices) + 1, fmAlternate);

      if Assigned(Canvas.OnChange) then
        Canvas.OnChange(Canvas);
    finally
      GdipF.DeleteGraphics(graphic);
      GdipF.DeletePen(Pen);
      GdipF.DeleteBrush(brush);
    end;
end;

procedure TGPPolygonalNode.DrawText(Canvas: TCanvas);
var
  gpGraphic, gpFont, gpBrush, gpFontFamily: THandle; // 用于SynGDIPlus
  gpRect                                  : TGdipRectF;
  Wstr                                    : WideString; // 这个可以取消
begin
  if Owner.PZState = 1 then
    inherited
  else if FDrawTextGdip then
  begin
        { 这里仅简单地使用GDI+绘出文字，要完善之，须参考原DrawText的内容。这里没有考虑
          文本的对齐、字体风格设置等 }
    if TextToShow <> '' then
    begin
      try
        GdipF.CreateFromHDC(Canvas.Handle, gpGraphic);

                // 对文字不使用透明度
                // GdipF.CreateSolidFill(Color2ARGB(FTransparency, Canvas.font.Color), gpBrush);
        GdipF.CreateSolidFill(Color2ARGB(255, Canvas.font.Color), gpBrush);

        GdipF.CreateFontFamilyFromName(PWideChar(Canvas.font.Name), nil, gpFontFamily);
        GdipF.CreateFont(gpFontFamily, Canvas.font.SIZE, 0, 3, gpFont);
        GdipF.SetTextRenderingHint(gpGraphic, { trhAntiAliasGridFit } trhAntiAlias);

                { 取文字绘制区域大小。注意：用GdipF.MeasureString经常得不到正确的结果，造成没有
                  显示或显示不正确的情况，所以下面的代码使用了BoundsRect作为gpRect的值，终于能
                  显示出文字来了，但是文字的位置有些不太合适。
                  用原先的DrawText方法可以正确显示在TextRect中的文字，用Gdip的话，会超出这个范围，
                  造成最后一个字符被截掉，不知道为什么？难道是应该先对gpRect赋值，然后再测量吗？
                  简直搞不懂啊~~
 }
        Wstr := TextToShow; // 可以不用Wstr变量
// GdipF.MeasureString(gpGraphic, PWideChar(wstr), StrLen(PWideChar(wstr)),
// gpFont, @gpRect, 0, @gpRect, nil, nil);
        gpRect.X := TextRect.Location.X;
        gpRect.Y := TextRect.Location.Y;

                // try
        gpRect.Width := BoundsRect.Width;   // TextRect.Width;
        gpRect.Height := BoundsRect.Height; // TextRect.Height;

        GdipF.DrawString(gpGraphic, PWideChar(Wstr), StrLen(PWideChar(Wstr)), gpFont, @gpRect,
          0, gpBrush);
      finally
        GdipF.DeleteFont(gpFont);
        GdipF.DeleteFontFamily(gpFontFamily);
        GdipF.DeleteBrush(gpBrush);
        GdipF.DeleteGraphics(gpGraphic);
      end;
    end;
  end
  else
    inherited;
end;

// procedure TGPPolygonalNode.DrawBody(Canvas: TCanvas);
// begin
// inherited;
// end;

function TGPEllipticNode.CreateRegion: HRGN;
begin
  result := CreateEllipticRgn(Left, Top, Left + Width + 1, Top + Height + 1);
end;

function TGPEllipticNode.LinkIntersect(const LinkPt: TPoint; const LinkAngle: Double): TPoints;
begin
  result := IntersectLineEllipse(LinkPt, LinkAngle, BoundsRect);
end;

procedure TGPEllipticNode.DrawBorder(Canvas: TCanvas);
var
  graphic, Pen, brush: THandle;
begin
    // inherited;
    // GdipF.DrawEllipse(Canvas.Handle, Canvas.Pen.Handle, Left, Top, Left + Width, Top + Height);
  if Owner.PZState = 1 then
    inherited
  else
    try
      GdipF.CreateFromHDC(Canvas.Handle, graphic);
        // 这里的颜色是ARGB，不是TColor类型
      GdipF.CreatePen(Color2ARGB(FTransparency, Canvas.Pen.Color), Canvas.Pen.Width, uWorld, Pen);
      GdipF.CreateSolidFill(Color2ARGB(FTransparency, Canvas.brush.Color), brush);
      GdipF.SetSmoothingMode(graphic, smAntiAlias { smHighQuality } );
        // 边框
      GdipF.DrawEllipse(graphic, Pen, Left, Top, Width, Height);
        // 填充
      GdipF.FillEllipse(graphic, brush, Left, Top, Width, Height);

      if Assigned(Canvas.OnChange) then
        Canvas.OnChange(Canvas);
    finally
      GdipF.DeleteGraphics(graphic);
      GdipF.DeletePen(Pen);
      GdipF.DeleteBrush(brush);
    end;
end;

procedure TGPTriangularNode.QueryMaxTextRect(out Rect: TRect);
var
  r: TRect;
begin
  with Rect do
  begin
    Left := (Vertices[0].X + Vertices[2].X) div 2;
    Top := (Vertices[0].Y + Vertices[2].Y) div 2;
    Right := (Vertices[0].X + Vertices[1].X) div 2;
    Bottom := Vertices[1].Y;
  end;
  inherited QueryMaxTextRect(r);
  IntersectRect(Rect, r);
end;

procedure TGPTriangularNode.DefineVertices(const ARect: TRect; var Points: TPoints);
begin
  SetLength(Points, 3);
  with ARect do
  begin
    with Points[0] do
    begin
      X := (Left + Right) div 2;
      Y := Top;
    end;
    with Points[1] do
    begin
      X := Right;
      Y := Bottom;
    end;
    with Points[2] do
    begin
      X := Left;
      Y := Bottom;
    end;
  end;
end;

procedure TGPPentagonalNode.QueryMaxTextRect(out Rect: TRect);
var
  r: TRect;
begin
  with Rect do
  begin
    Left := Vertices[3].X;
    Top := (Vertices[0].Y + Vertices[4].Y) div 2;
    Right := Vertices[2].X;
    Bottom := Vertices[2].Y;
  end;
  inherited QueryMaxTextRect(r);
  IntersectRect(Rect, r);
end;

procedure TGPPentagonalNode.DefineVertices(const ARect: TRect; var Points: TPoints);
begin
  SetLength(Points, 5);
  with ARect do
  begin
    with Points[0] do
    begin
      X := (Left + Right) div 2;
      Y := Top;
    end;
    with Points[1] do
    begin
      X := Right;
      Y := (Top + Bottom) div 2;
    end;
    with Points[2] do
    begin
      X := Right - (Right - Left) div 4;
      Y := Bottom;
    end;
    with Points[3] do
    begin
      X := Left + (Right - Left) div 4;
      Y := Bottom;
    end;
    with Points[4] do
    begin
      X := Left;
      Y := (Top + Bottom) div 2;
    end;
  end;
end;

procedure TGPHexagonalNode.QueryMaxTextRect(out Rect: TRect);
var
  r: TRect;
begin
  with Rect do
  begin
    Left := Vertices[0].X;
    Top := Vertices[0].Y;
    Right := Vertices[3].X;
    Bottom := Vertices[3].Y;
  end;
  inherited QueryMaxTextRect(r);
  IntersectRect(Rect, r);
end;

procedure TGPHexagonalNode.DefineVertices(const ARect: TRect; var Points: TPoints);
begin
  SetLength(Points, 6);
  with ARect do
  begin
    with Points[0] do
    begin
      X := Left + (Right - Left) div 4;
      Y := Top;
    end;
    with Points[1] do
    begin
      X := Right - (Right - Left) div 4;
      Y := Top;
    end;
    with Points[2] do
    begin
      X := Right;
      Y := (Top + Bottom) div 2;
    end;
    with Points[3] do
    begin
      X := Right - (Right - Left) div 4;
      Y := Bottom;
    end;
    with Points[4] do
    begin
      X := Left + (Right - Left) div 4;
      Y := Bottom;
    end;
    with Points[5] do
    begin
      X := Left;
      Y := (Top + Bottom) div 2;
    end;
  end;
end;

procedure TGPRhomboidalNode.QueryMaxTextRect(out Rect: TRect);
var
  r: TRect;
begin
  with Rect do
  begin
    Left := (Vertices[0].X + Vertices[3].X) div 2;
    Top := (Vertices[0].Y + Vertices[3].Y) div 2;
    Right := (Vertices[1].X + Vertices[2].X) div 2;
    Bottom := (Vertices[1].Y + Vertices[2].Y) div 2;
  end;
  inherited QueryMaxTextRect(r);
  IntersectRect(Rect, r);
end;

procedure TGPRhomboidalNode.DefineVertices(const ARect: TRect; var Points: TPoints);
begin
  SetLength(Points, 4);
  with ARect do
  begin
    with Points[0] do
    begin
      X := (Left + Right) div 2;
      Y := Top;
    end;
    with Points[1] do
    begin
      X := Right;
      Y := (Top + Bottom) div 2;
    end;
    with Points[2] do
    begin
      X := (Left + Right) div 2;
      Y := Bottom;
    end;
    with Points[3] do
    begin
      X := Left;
      Y := (Top + Bottom) div 2;
    end;
  end;
end;

procedure TGPGraphicLink.DrawControlPoints(Canvas: TCanvas);
begin
  inherited;
end;

function TGPGraphicLink.DrawPointStyle(Canvas: TCanvas; const Pt: TPoint; const Angle: Double;
  Style: TLinkBeginEndStyle; SIZE: Integer): TPoint;
var
  Pts: array [1 .. 4] of TPoint;

  function GDIPDrawPointStyle: TPoint;
  var
    gpGraphic, gpPen: THandle;
  begin
    try
      GdipF.CreateFromHDC(Canvas.Handle, gpGraphic);
      GdipF.SetSmoothingMode(gpGraphic, smAntiAlias);
      GdipF.CreatePen(Color2ARGB(255, Canvas.Pen.Color), Canvas.Pen.Width, uWorld, gpPen);

      SIZE := PointStyleOffset(Style, SIZE);
      case Style of
        lsArrow:
          begin
            Pts[1] := Pt;
            Pts[2] := NextPointOfLine(Angle + Pi / 9, Pt, SIZE);
            Pts[3] := NextPointOfLine(Angle, Pt, MulDiv(SIZE, 6, 10));
            Pts[4] := NextPointOfLine(Angle - Pi / 9, Pt, SIZE);
                        // Canvas.Polygon(Pts);
            GdipF.DrawPolygon(gpGraphic, gpPen, @Pts, 4);
            result := Pts[3];
          end;
        lsArrowSimple:
          begin
            Pts[1] := NextPointOfLine(Angle + Pi / 6, Pt, SIZE);
            Pts[2] := Pt;
            Pts[3] := NextPointOfLine(Angle - Pi / 6, Pt, SIZE);
                        // Canvas.Polyline(Slice(Pts, 3));
            GdipF.DrawLines(gpGraphic, gpPen, @Pts[1], 3);
            result := Pt;
          end;
        lsCircle:
          begin
                        // GDI绘制方法
            GdipF.DrawEllipse(gpGraphic, gpPen, Pt.X - SIZE div 2, Pt.Y - SIZE div 2, SIZE, SIZE);
            result := NextPointOfLine(Angle, Pt, SIZE div 2);

                        // 原版绘制方法
                        // Canvas.Ellipse(Pt.X - Size, Pt.Y - Size, Pt.X + Size, Pt.Y + Size);
                        // result := NextPointOfLine(Angle, Pt, SIZE);
          end;
        lsDiamond:
          begin
            Pts[1] := NextPointOfLine(Angle, Pt, SIZE);
            Pts[2] := NextPointOfLine(Angle + Pi / 2, Pt, SIZE);
            Pts[3] := NextPointOfLine(Angle, Pt, -SIZE);
            Pts[4] := NextPointOfLine(Angle - Pi / 2, Pt, SIZE);
                        // Canvas.Polygon(Pts);
            GdipF.DrawPolygon(gpGraphic, gpPen, @Pts, 4);
            result := Pts[1];
          end;
      else
        result := Pt;
      end;
    finally
      GdipF.DeletePen(gpPen);
      GdipF.DeleteGraphics(gpGraphic);
    end;
  end;

begin

    // inherited;
  if Owner.PZState = 1 then
    result := inherited
  else
    result := GDIPDrawPointStyle;
end;

procedure TGPGraphicLink.DrawHighlight(Canvas: TCanvas);
var
  PtRect     : TRect;
  First, Last: Integer;
  Pts        : TPoints;

  procedure GDIPDrawHighlight;
  var
    gpGraphic, gpBrush, gpPen: THandle;
  begin
    try
      GdipF.CreateFromHDC(Canvas.Handle, gpGraphic);
      GdipF.SetSmoothingMode(gpGraphic, smAntiAlias);
      GdipF.CreatePen(Color2ARGB(255, Canvas.Pen.Color), Canvas.Pen.Width, uWorld, gpPen);
            // GdipF

      if PointCount > 1 then
      begin
        if (MovingPoint >= 0) and (MovingPoint < PointCount) then
        begin
          if MovingPoint > 0 then
            First := MovingPoint - 1
          else
            First := MovingPoint;
          if MovingPoint < PointCount - 1 then
            Last := MovingPoint + 1
          else
            Last := MovingPoint;
          Pts := Copy(Polyline, First, Last - First + 1);

                    // Canvas.Polyline(Copy(Polyline, First, Last - First + 1));
        end
        else
          Pts := Polyline;
                // Canvas.Polyline(Polyline)
        GdipF.DrawLines(gpGraphic, gpPen, @Pts[0], PointCount);
      end
      else if PointCount = 1 then
      begin
        PtRect := MakeSquare(Points[0], Canvas.Pen.Width);
                // Canvas.Ellipse(PtRect.Left, PtRect.Top, PtRect.Right, PtRect.Bottom);
        GdipF.DrawEllipse(gpGraphic, gpPen, PtRect.Left, PtRect.Top, PtRect.Width, PtRect.Height);
      end;
    finally
      GdipF.DeletePen(gpPen);
      GdipF.DeleteGraphics(gpGraphic);
    end;

  end;

begin
    { 原版绘高亮（被选中时的样子） }
    // inherited;
    { GDI+ }
  if Owner.PZState = 1 then
    inherited
  else
    GDIPDrawHighlight;
end;

procedure TGPGraphicLink.DrawBody(Canvas: TCanvas);
var
  ModifiedPolyLine: TPoints;
  PtRect          : TRect;
  OldPenStyle     : TPenStyle;
  OldBrushStyle   : TBrushStyle;
  Angle           : Double;

  procedure GDIPDrawBody;
  var
    gpGraphic, gpPen, gpBrush: THandle;
    Pts                      : TPoints;
  begin
    try
      GdipF.CreateFromHDC(Canvas.Handle, gpGraphic);
      GdipF.SetSmoothingMode(gpGraphic, smAntiAlias);
      GdipF.CreatePen(Color2ARGB(255, Canvas.Pen.Color), Canvas.Pen.Width, uWorld, gpPen);
      GdipF.CreateSolidFill(Color2ARGB(255, Canvas.brush.Color), gpBrush);

      ModifiedPolyLine := nil;
      if PointCount = 1 then
      begin
                { 下面照抄原版内容，仅在绘图命令上替换为GDI+ }
        PtRect := MakeSquare(Points[0], Pen.Width div 2);
        while not IsRectEmpty(PtRect) do
        begin
          GdipF.DrawEllipse(gpGraphic, gpPen, PtRect.Left, PtRect.Top, PtRect.Width, PtRect.Height);
          InflateRect(PtRect, -1, -1);
        end;
      end
      else if PointCount >= 2 then
      begin
        if (BeginStyle <> lsNone) or (EndStyle <> lsNone) then
        begin
          OldPenStyle := Canvas.Pen.Style;
          Canvas.Pen.Style := psSolid;
          try
            if BeginStyle <> lsNone then
            begin
              if ModifiedPolyLine = nil then
                ModifiedPolyLine := Copy(Polyline, 0, PointCount);
              Angle := LineSlopeAngle(Points[1], Points[0]);
              ModifiedPolyLine[0] := DrawPointStyle(Canvas, Points[0], Angle, BeginStyle,
                BeginSize);
            end;
            if EndStyle <> lsNone then
            begin
              if ModifiedPolyLine = nil then
                ModifiedPolyLine := Copy(Polyline, 0, PointCount);
              Angle := LineSlopeAngle(Points[PointCount - 2], Points[PointCount - 1]);
              ModifiedPolyLine[PointCount - 1] := DrawPointStyle(Canvas, Points[PointCount - 1],
                Angle, EndStyle, EndSize);;
            end;
          finally
            Canvas.Pen.Style := OldPenStyle;
          end;
        end;
        OldBrushStyle := Canvas.brush.Style;

        try
          Canvas.brush.Style := bsClear;
          if ModifiedPolyLine <> nil then
            Pts := ModifiedPolyLine
          else
            Pts := Polyline;

                    { 注：DrawLines的参数Points，其实只是输入点数组的第一个元素的地址，然后指明点数，而
                      不是将整个数组的地址传递给DrawLines。 }
          GdipF.DrawLines(gpGraphic, gpPen, @Pts[0], PointCount);
        finally
          Canvas.brush.Style := OldBrushStyle;
        end;
                { DONE: 参照原代码写出完整DrawBody代码 }
      end;

    finally
      GdipF.DeleteGraphics(gpGraphic);
      GdipF.DeletePen(gpPen);
      GdipF.DeleteBrush(gpBrush);
    end;
  end;

begin
    { 如果使用原来的，就inherited }
    // inherited;
    { 要使用GDI+，就用下面的 }
  if Owner.PZState = 1 then
    inherited
  else
    GDIPDrawBody;
end;

procedure TGPGraphicLink.DrawText(Canvas: TCanvas);
var
  gpGraphic, gpFont, gpBrush, gpFontFamily: THandle; // 用于SynGDIPlus
  gpRect                                  : TGdipRectF;
begin
    { 这里仅简单地使用GDI+绘出文字，要完善之，须参考原DrawText的内容 }
    // if TextToShow <> '' then
    // begin
    // try
    // GdipF.CreateFromHDC(Canvas.Handle, gpGraphic);
    // GdipF.CreateSolidFill(Color2ARGB(255, Canvas.font.Color), gpBrush);
    // GdipF.CreateFontFamilyFromName(PWideChar(Canvas.font.Name), nil, gpFontFamily);
    // GdipF.CreateFont(gpFontFamily, Canvas.font.Size, 0, 3, gpFont);
    // GdipF.SetTextRenderingHint(gpGraphic, { trhAntiAliasGridFit } trhAntiAlias);
    //
    // { 取文字绘制区域大小 }
    // GdipF.MeasureString(gpGraphic,PWideChar(TextToShow), strlen(PWideChar(TextToShow)),
    // gpFont, @gpRect, 0, @gpRect, nil,nil);
    // gpRect.X := TextCenter.X-gpRect.Width /2; //TextRect.Location.X;
    // gpRect.Y := TextCenter.Y-gprect.Height /2; //TextRect.Location.Y;
    //

    // GdipF.DrawString(gpGraphic, PWideChar(TextToShow), strlen(PWideChar(TextToShow)), gpFont, @gpRect, 0, gpBrush);
    // finally
    // GdipF.DeleteFont(gpFont);
    // GdipF.DeleteFontFamily(gpFontFamily);
    // GdipF.DeleteBrush(gpBrush);
    // GdipF.DeleteGraphics(gpGraphic);
    // end;
    //
    // end;
  inherited;
end;

procedure TGPRectangularNode.DefineVertices(const ARect: TRect; var Points: TPoints);
begin
  SetLength(Points, 4);
  Points[0].X := ARect.Left;
  Points[0].Y := ARect.Top;
  Points[1].X := ARect.Right;
  Points[1].Y := ARect.Top;
  Points[2].X := ARect.Right;
  Points[2].Y := ARect.Bottom;
  Points[3].X := ARect.Left;
  Points[3].Y := ARect.Bottom;
end;

constructor TGPTextNode.Create(AOwner: TSimpleGraph);
begin
  inherited;
    // 默认无边框
  Self.Pen.Style := psClear;
  Self.Margin := 3;
  Self.Transparency := 200;
  Self.brush.Color := clWhite;
  FAutoSize := True;
end;

procedure TGPTextNode.Changed(Flags: TGraphChangeFlags);
var
  Rect    : TRect;
  txtSize : TSize;
  txtSize2: TSize;
  cCanvas : TControlCanvas;
  i, iRow : Integer;
  S1, S2  : string;
begin
  if not FAutoSize then
    inherited
  else
  begin
        // 下面的代码根据Text内容计算文本的宽度和高度，并调整图元的大小
    if (gcText in Flags) or ((gcView in Flags) and ((Flags * VisualRectFlags) <> [])) then
    begin
      AdjustTextRect;
    end;
    inherited;
  end;
end;

procedure TGPTextNode.SetAutoSize(V: Boolean);
begin
  FAutoSize := V;
    // do something;
  AdjustTextRect;
end;

procedure TGPTextNode.AdjustTextRect;
const
  DrawTextFlags = DT_NOPREFIX or DT_EDITCONTROL or DT_CALCRECT or DT_NOCLIP;
var
  Canvas: TCanvas;
  Rect  : TRect;
  rWidth: Integer;
begin
  if not FAutoSize then
    Exit;

  if Text <> '' then
  begin
    Canvas := TCompatibleCanvas.Create;
    try
      Canvas.font := font;
      Rect := BoundsRect;
      Rect.Width := Rect.Width + 1000;
      Rect.Height := Rect.Height + 1000;
      // 计算文本输出所需要的宽和高
      Winapi.Windows.DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect,
        Owner.DrawTextBiDiModeFlags(DrawTextFlags));

      Rect.Width := Rect.Width + Margin * 2 + Pen.Width * 2;
      Rect.Height := Rect.Height + Margin * 2 + Pen.Width * 2;
      rWidth := Rect.Width;
      // 2020-5-26 如果是数据右对齐，则...
      if Self.FDataAlignRight then
      begin
        Rect.Right := BoundsRect.Right;
        Rect.Left := Rect.Right - rWidth;
      end;

      if Rect <> BoundsRect then
        SetBoundsRect(Rect);
    finally
      Canvas.Free;
    end;
  end;
end;

function TGPTextNode.GetShowBorder:Boolean;
begin
  if pen.Style = psClear then
    Result := False
  else
    Result := True;
end;

procedure TGPTextNode.SetShowBorder(b: Boolean);
begin
  if b then
    pen.Style := psSolid
  else
    pen.Style := psClear;
end;



initialization

GdipF := TGDIPlusFullEx.Create;
{ gdip是SynGDIPlus的全局对象，该单元绘图要调用 }
if Gdip = nil then
  Gdip := TGDIPlusFull.Create('gdiplus.dll');
TSimpleGraph.Register(TGPGraphicLink);
TSimpleGraph.Register(TGPEllipticNode);
TSimpleGraph.Register(TGPTriangularNode);
TSimpleGraph.Register(TGPRhomboidalNode);
TSimpleGraph.Register(TGPPentagonalNode);
TSimpleGraph.Register(TGPHexagonalNode);
TSimpleGraph.Register(TGPRectangularNode);
TSimpleGraph.Register(TGPTextNode);

finalization

if GdipF <> nil then
  FreeAndNil(GdipF);
GdipF := nil;

TSimpleGraph.Unregister(TGPEllipticNode);
TSimpleGraph.Unregister(TGPTriangularNode);
TSimpleGraph.Unregister(TGPRhomboidalNode);
TSimpleGraph.Unregister(TGPPentagonalNode);
TSimpleGraph.Unregister(TGPHexagonalNode);
TSimpleGraph.Unregister(TGPRectangularNode);
TSimpleGraph.Unregister(TGPGraphicLink);
TSimpleGraph.Unregister(TGPTextNode);

end.
