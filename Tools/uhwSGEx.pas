{ -----------------------------------------------------------------------------
  Unit Name: uhwSGEx
  Author:    ��ΰ
  Date:      27-ʮ��-2015
  Purpose:   ����Ԫ�Ƕ�SimpleGraphͼԪ����չ����չ��ͼԪʹ��GDI+���л�ͼ��
      ʹ��GDI+���л�ͼ�������У�
      1���߿��ṩ�˰�͸��Ч���Ϳ����Ч����
      2����䡣�����͸��Ч����
      3�����֡��ṩ�˿������ʾ��
      4������ͼ�񡣶Թ�դ�ļ���Metafile�ļ��ṩ��ƽ������

      �ƻ�������ӵ�Ч���У�
      1���߿��Glow�����⣩Ч����
      2����ӰЧ����

      �ƻ����ӵ�ͼ���У�
      1��ֱ�ߡ���ֱ�߼������ߣ�
      2�����ߡ�

      ���ʹ��SimpleGraph��Ϊ��ȫ���ϵͳ����ͼ��ͼ����������ڱ�ͼԪ
      ����Ļ������ٽ�����չ�����Ӻͼ�������йص����ԡ�

  History:
      2017-04-19  ��֪Ϊ�Σ������Ȼ�Ѿ���д��TGraphNode����TGPPolygonalNode�������
      ����TGPGraphNode�̳У���������д��TPolygonalNode��

      2019-06-19  ������GraphLink����GDI�����߶�ԲȦ�Ĵ���
  ----------------------------------------------------------------------------- }
{ todo:���ӱ߿������ߵ����ͣ���������ߡ����ߵ� }
{ todo:���ӱ߿��ߵĿ�ȣ�ԭͼ��ò��û�����ñ߿��߿�� }
{ todo:������ӰЧ���ͷ���Ч�� }
{ todo:���ӽ���ɫ����� }
unit uhwSGEx;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.UITypes,
  Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  SimpleGraph, SynGdiPlus;

type
    { ʹ��GDI+ʵ��ͼԪ�Ļ��Ʒ����Ļ����� }
  TGPGraphNode = class(TGraphNode)
  private
    FTransparency: SmallInt; // ͼԪ͸����
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
            // ����͸����֮��Ҫˢ��һ�¡���
    property UseGdipDrawText: Boolean read FDrawTextGdip write FDrawTextGdip;
  end;

    { ��дPolygonalNode����ʹ��GDI+������ͼ��ʵ���ϱ�������Լ̳���TGPGraphNode������
      ԭ������дһ��Ϳ����ˣ���֪������Ϊ�δ�TPolygonalNode�̳У���֡� }

  TGPPolygonalNode = class(TPolygonalNode)
  private
        // fVertices    : TPoints;
    FTransparency: SmallInt;
    FSynPicture  : TSynPicture;
    FDrawTextGdip: Boolean; // ע�⣺ȱʡ�ǲ�ʹ��GDI+�����ı��ģ�����
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

    { ��Բ }
  TGPEllipticNode = class(TGPGraphNode)
  protected
    function CreateRegion: HRGN; override;
    procedure DrawBorder(Canvas: TCanvas); override;
    function LinkIntersect(const LinkPt: TPoint; const LinkAngle: Double): TPoints; override;
  end;

    { ������ }

  TGPTriangularNode = class(TGPPolygonalNode)
  protected
    procedure QueryMaxTextRect(out Rect: TRect); override;
    procedure DefineVertices(const ARect: TRect; var Points: TPoints); override;
  end;
    { ���� }

  TGPRectangularNode = class(TGPPolygonalNode)
  protected
    procedure DefineVertices(const ARect: TRect; var Points: TPoints); override;
  end;

    { ���� }

  TGPRhomboidalNode = class(TGPPolygonalNode)
  protected
    procedure QueryMaxTextRect(out Rect: TRect); override;
    procedure DefineVertices(const ARect: TRect; var Points: TPoints); override;
  end;
    { ����� }

  TGPPentagonalNode = class(TGPPolygonalNode)
  protected
    procedure QueryMaxTextRect(out Rect: TRect); override;
    procedure DefineVertices(const ARect: TRect; var Points: TPoints); override;
  end;

    { THexagonalNode }
    { ������ }

  TGPHexagonalNode = class(TGPPolygonalNode)
  protected
    procedure QueryMaxTextRect(out Rect: TRect); override;
    procedure DefineVertices(const ARect: TRect; var Points: TPoints); override;
  end;

    { �����߶����GDI+��չ }
  TGPGraphicLink = class(TGraphLink)
  protected
    procedure DrawControlPoints(Canvas: TCanvas); override;
    procedure DrawHighlight(Canvas: TCanvas); override;
    procedure DrawBody(Canvas: TCanvas); override;
    procedure DrawText(Canvas: TCanvas); override;
    function DrawPointStyle(Canvas: TCanvas; const Pt: TPoint; const Angle: Double;
      Style: TLinkBeginEndStyle; SIZE: Integer): TPoint; override;
  end;

    { �ı� }
    { todo:GDIP֧���ı�����ת������Ӧ��ʵ��~~ }
  TGPTextNode = class(TGPRectangularNode)
  private
    FAutoSize      : Boolean;
    FDataAlignRight: Boolean; // �����Ƿ��Ҷ��룬���Ҷ��룬�����ݱ仯ʱ�����Ͻ�λ�ò��䡣
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
    { Ϊ����TGDPPlusFull��protected�������������࣬�ڱ���Ԫinitialization�δ��� }
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
                { ȡ���ֻ��������С }
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
        // ����TSynPicture���Ʊ�������������֧�ְ�͸��Ч���Ϳ����Metafile��ʾ��
        // ��͸���Ϳ���ݵ�wmf��emf��emf+Ч����Ҫ��������ʵ�֡�
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
  gpGraphic, gpFont, gpBrush, gpFontFamily: THandle; // ����SynGDIPlus
  gpRect                                  : TGdipRectF;
  Wstr                                    : WideString; // �������ȡ��
begin
  if Owner.PZState = 1 then
    inherited
  else if FDrawTextGdip then
  begin
        { ������򵥵�ʹ��GDI+������֣�Ҫ����֮����ο�ԭDrawText�����ݡ�����û�п���
          �ı��Ķ��롢���������õ� }
    if TextToShow <> '' then
    begin
      try
        GdipF.CreateFromHDC(Canvas.Handle, gpGraphic);

                // �����ֲ�ʹ��͸����
                // GdipF.CreateSolidFill(Color2ARGB(FTransparency, Canvas.font.Color), gpBrush);
        GdipF.CreateSolidFill(Color2ARGB(255, Canvas.font.Color), gpBrush);

        GdipF.CreateFontFamilyFromName(PWideChar(Canvas.font.Name), nil, gpFontFamily);
        GdipF.CreateFont(gpFontFamily, Canvas.font.SIZE, 0, 3, gpFont);
        GdipF.SetTextRenderingHint(gpGraphic, { trhAntiAliasGridFit } trhAntiAlias);

                { ȡ���ֻ��������С��ע�⣺��GdipF.MeasureString�����ò�����ȷ�Ľ�������û��
                  ��ʾ����ʾ����ȷ���������������Ĵ���ʹ����BoundsRect��ΪgpRect��ֵ��������
                  ��ʾ���������ˣ��������ֵ�λ����Щ��̫���ʡ�
                  ��ԭ�ȵ�DrawText����������ȷ��ʾ��TextRect�е����֣���Gdip�Ļ����ᳬ�������Χ��
                  ������һ���ַ����ص�����֪��Ϊʲô���ѵ���Ӧ���ȶ�gpRect��ֵ��Ȼ���ٲ�����
                  ��ֱ�㲻����~~
 }
        Wstr := TextToShow; // ���Բ���Wstr����
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
        // �������ɫ��ARGB������TColor����
      GdipF.CreatePen(Color2ARGB(FTransparency, Canvas.Pen.Color), Canvas.Pen.Width, uWorld, Pen);
      GdipF.CreateSolidFill(Color2ARGB(FTransparency, Canvas.brush.Color), brush);
      GdipF.SetSmoothingMode(graphic, smAntiAlias { smHighQuality } );
        // �߿�
      GdipF.DrawEllipse(graphic, Pen, Left, Top, Width, Height);
        // ���
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
                        // GDI���Ʒ���
            GdipF.DrawEllipse(gpGraphic, gpPen, Pt.X - SIZE div 2, Pt.Y - SIZE div 2, SIZE, SIZE);
            result := NextPointOfLine(Angle, Pt, SIZE div 2);

                        // ԭ����Ʒ���
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
    { ԭ����������ѡ��ʱ�����ӣ� }
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
                { �����ճ�ԭ�����ݣ����ڻ�ͼ�������滻ΪGDI+ }
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

                    { ע��DrawLines�Ĳ���Points����ʵֻ�����������ĵ�һ��Ԫ�صĵ�ַ��Ȼ��ָ����������
                      ���ǽ���������ĵ�ַ���ݸ�DrawLines�� }
          GdipF.DrawLines(gpGraphic, gpPen, @Pts[0], PointCount);
        finally
          Canvas.brush.Style := OldBrushStyle;
        end;
                { DONE: ����ԭ����д������DrawBody���� }
      end;

    finally
      GdipF.DeleteGraphics(gpGraphic);
      GdipF.DeletePen(gpPen);
      GdipF.DeleteBrush(gpBrush);
    end;
  end;

begin
    { ���ʹ��ԭ���ģ���inherited }
    // inherited;
    { Ҫʹ��GDI+����������� }
  if Owner.PZState = 1 then
    inherited
  else
    GDIPDrawBody;
end;

procedure TGPGraphicLink.DrawText(Canvas: TCanvas);
var
  gpGraphic, gpFont, gpBrush, gpFontFamily: THandle; // ����SynGDIPlus
  gpRect                                  : TGdipRectF;
begin
    { ������򵥵�ʹ��GDI+������֣�Ҫ����֮����ο�ԭDrawText������ }
    // if TextToShow <> '' then
    // begin
    // try
    // GdipF.CreateFromHDC(Canvas.Handle, gpGraphic);
    // GdipF.CreateSolidFill(Color2ARGB(255, Canvas.font.Color), gpBrush);
    // GdipF.CreateFontFamilyFromName(PWideChar(Canvas.font.Name), nil, gpFontFamily);
    // GdipF.CreateFont(gpFontFamily, Canvas.font.Size, 0, 3, gpFont);
    // GdipF.SetTextRenderingHint(gpGraphic, { trhAntiAliasGridFit } trhAntiAlias);
    //
    // { ȡ���ֻ��������С }
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
    // Ĭ���ޱ߿�
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
        // ����Ĵ������Text���ݼ����ı��Ŀ�Ⱥ͸߶ȣ�������ͼԪ�Ĵ�С
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
      // �����ı��������Ҫ�Ŀ�͸�
      Winapi.Windows.DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect,
        Owner.DrawTextBiDiModeFlags(DrawTextFlags));

      Rect.Width := Rect.Width + Margin * 2 + Pen.Width * 2;
      Rect.Height := Rect.Height + Margin * 2 + Pen.Width * 2;
      rWidth := Rect.Width;
      // 2020-5-26 ����������Ҷ��룬��...
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
{ gdip��SynGDIPlus��ȫ�ֶ��󣬸õ�Ԫ��ͼҪ���� }
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
