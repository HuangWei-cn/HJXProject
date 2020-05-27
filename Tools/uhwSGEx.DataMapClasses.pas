{ -----------------------------------------------------------------------------
 Unit Name: uhwSGEx.DataMapClasses
 Author:    ��ΰ
 Date:      20-����-2017
 Purpose:   ����SimpleGraph������ͼԪ����
            ����Ԫ��̳���uhwSGEx��Ԫ���Ƕ�SimpleGraph����չ��������ʾ����
            �ֲ�ͼ
 History:
----------------------------------------------------------------------------- }

unit uhwSGEx.DataMapClasses;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.UITypes, System.Variants,
  Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  SimpleGraph, SynGdiPlus, uhwSGEx;

type
    { ��ͼ�� }
    { DONE:��������ȹ��� }
    { todo:ȡ����Linkable������ }
    { DONE:����ͼ�κ�ֻĬ����������������ԭͼ���š����û������Ƿ�1:1��ʾͼֽ }
  TdmcMap = class(TGPRectangularNode)
  private
    FRatio         : Double; // ԭʼͼƬ�����
    FLockRatio     : Boolean;
    FAngleFromNorth: Double;  // ��ͼ�������ļн�
    FOneMMLength   : Integer; // 1mm�൱�ڶ��ٻ�ͼ���ȵ�λ������ָʾ���ݴ�С
    procedure SetLockRatio(b: Boolean);
    procedure SetMovable(b: Boolean);
    procedure SetSelectable(b: Boolean);
    procedure SetResizable(b: Boolean);
  protected
    procedure BackgroundChanged(Sender: TObject); override;
  public
    constructor Create(AOwner: TSimpleGraph); override;
    procedure SetBounds(aLeft, aTop, aWidth, aHeight: Integer); override;
    procedure SetBoundRectOriginal;
  published
    property LockRatio : Boolean read FLockRatio write SetLockRatio;
    property Moveable  : Boolean write SetMovable;
    property Selectable: Boolean write SetSelectable;
    property Resizeable: Boolean write SetResizable;
    // ��ͼY������������ļнǣ����������Ҫ���ڻ��ƽ����εķ��򡣻�ͼƽ���Y
    // ���������¡�
    property AngleFromNorth: Double read FAngleFromNorth write FAngleFromNorth;
    property OneMMLength   : Integer read FOneMMLength write FOneMMLength;
  end;

    { �������� }
    { todo:���ʱ����ʾ���+������������ʱ����ʾ���ݣ�������+���ݣ�HintΪ���+������ }
    { todo:�ṩ���ֲ�ͬ����ʾ��ʽ���硰���ݡ����������������ݡ��������ڣ����ݡ��ȵ� }
    { todo:��������ʾ���ݺ���ʾ������֮���л� }
  TdmcDataItem = class(TGPTextNode)
  private
    FDesignName: string;
    FDataName  : string;
    FDataUnit  : string;
    FData      : Variant;
    FDTScale   : TDateTime;
    procedure SetData(v: Variant);
    procedure SetDTScale(dt: TDateTime);
    //function GetShowBorder: Boolean;
    //procedure SetShowBorder(b: Boolean);
  public
    procedure ShowData(AData: string; dt: TDateTime);
    procedure ClearData;
  published
    property DesignName: string read FDesignName write FDesignName;
    property DataName  : string read FDataName write FDataName;
    property DataUnit  : string read FDataUnit write FDataUnit;
    property Data      : Variant read FData write SetData;
    property DTScale   : TDateTime read FDTScale write SetDTScale;
    property ShowBorder;
    property DataAlignRight;
  end;

    { 2018-06-14 ����������ǩ���󡣱�����δ������չ�����У�1)��ʾ���ݲ�һ������ʹ��TdmcDataItem
      ���󣬱�������ShowData֮���Զ��������ݱ�ǩ�����ݼ�ͷ��2)�������ܻ�û��� }
  TdmcMeterLabel = class(TGPTextNode)
  private
    FDesignName: string;
    FMeterType : string;
  published
    property DesignName: string read FDesignName write FDesignName;
    property MeterType : string read FMeterType write FMeterType;
    property DataAlignRight;
    property ShowBorder;
  end;

    { 2019-06-19 ���ӱ�ʾ�������ݴ�С�ͷ���ļ�ͷ����ҪĿ����ʵ��ƽ��������ݵķ���ʹ�С }
  TdmcDataArrow = class(TGPGraphicLink)
  private
  published
  end;

  { 2019-08-06 ���η���ָʾ������ƽ����β�ֵ������������нǼ������ͷ�ķ���ʹ�С����ʾ������
    ���⣺1���Ƿ���Ҫ����Ϊ�̶����ȣ�����ʾ������ͱ�����ֵ��
          2�����䳤���ɷ��Ǳ����������������ꣿ
 }
  TdmcDeformationDirection = class(TGPGraphicLink)
  private
    FDesignName: string;
    FMeterType : string;
    FXName     : string;  // X������
    FYName     : string;  // Y������
    FXDirect   : Integer; // X����ϵ��������ͼ���Ƿ���Ҫ��ʵ��ֵ����-1�������ô������ʱ������Ҫ
    FYDirect   : Integer; // Y����ϵ��
    // FOneMilliMeterLength: Integer; // 1mm�൱�ڶ���ͼ��λ��
    FAngleFromNorth: Double; // Y����������������нǡ���������У�XΪ��������YΪ����������ͼ���У�Y
      // Ϊ��ֱ���£�XΪ�������ң���Ҫ������ת�任���ܵõ���ȷ����ֵ��
    FX             : Variant;
    FY             : Variant;
    FNorth         : Variant;
    FEast          : Variant;
    FDTScale       : TDateTime;
    FUseGlobalAngle: Boolean;
  public
    constructor Create(AOwner: TSimpleGraph); override;
    procedure SetData(ANorth, AEast: Variant);
    procedure ShowData(AData: string; dt: TDateTime);
    procedure ClearData;
  published
    property DesignName: string read FDesignName write FDesignName;
    property MeterType : string read FMeterType write FMeterType;
    property XDataName : string read FXName write FXName;
    property YDataName : string read FYName write FYName;
    // property OneMilliMeterLength: Integer read FOneMilliMeterLength write FOneMilliMeterLength;
    property AngleFromNorth: Double read FAngleFromNorth write FAngleFromNorth;
    property XDirect       : Integer read FXDirect write FXDirect;
    property YDirect       : Integer read FYDirect write FYDirect;
    property North         : Variant read FNorth write FNorth;
    property East          : Variant read FEast write FEast;
    // �Ƿ����ȫ�ֽǶȣ�ָ�Ƿ���õ�ͼ�������н���Ϊȫ�ֽǶ�ʹ�á������ò���ȫ��
    // �ֽǶȣ�����Ҫ����ÿһ�����ε���Ļ������������нǣ����ô�����꣩��������
    // ÿһ�����ε���ٿ����������нǣ����ñ������꣩
    property UseGlobalAngle: Boolean read FUseGlobalAngle write FUseGlobalAngle;
  end;

procedure SetBackgroundMap(AMap: TdmcMap);
procedure SetOneMMLength(ALength: Integer);

implementation

var
  GlobalAngleFromNorth: Double;
  GlobalOneMMLength   : Integer;
  SinValue            : Double;
  CosValue            : Double;
  BackMap             : TdmcMap;

{ ���ù������� }
procedure SetBackgroundMap(AMap: TdmcMap);
begin
  BackMap := AMap;
  GlobalAngleFromNorth := BackMap.AngleFromNorth;
  GlobalOneMMLength := BackMap.OneMMLength;
  SinValue := sin(GlobalAngleFromNorth / 180 * pi);
  CosValue := Cos(GlobalAngleFromNorth / 180 * pi);
end;

procedure SetOneMMLength(ALength: Integer);
begin
  GlobalOneMMLength := ALength;
end;

{ X������ת }
function GlobalTransX(X, Y: Double): Double;
begin
  Result := X * CosValue - Y * SinValue;
end;

{ Y������ת }
function GlobalTransY(X, Y: Double): Double;
begin
  Result := X * SinValue + Y * CosValue;
end;

constructor TdmcMap.Create(AOwner: TSimpleGraph);
begin
  inherited;
  Options := [goSelectable, goShowCaption];
  LockRatio := True;
  FRatio := 1.33;
  FAngleFromNorth := 0;
  FOneMMLength := 5; // ÿ����=5����ͼ���ȵ�λ
end;

procedure TdmcMap.BackgroundChanged(Sender: TObject);
var
  rc: TRect;
begin
  inherited;
    { ���ݵ�ͼʵ�ʳߴ����ñ������С���û�����֮�������µ��� }
  rc := GetBoundsRect;
  if (Background.Width <> 0) and (Background.Height <> 0) then
  begin
    FRatio := Background.Width / Background.Height;
    rc.Width := round(rc.Height * FRatio);
    SetBoundsRect(rc);
  end
  else
    FRatio := 0;
end;

procedure TdmcMap.SetLockRatio(b: Boolean);
var
  rc: TRect;
begin
  FLockRatio := b;
  if b then
  begin
    rc := GetBoundsRect;
    SetBounds(rc.Left, rc.Top, rc.Width, rc.Height);
  end;
end;

procedure TdmcMap.SetBounds(aLeft: Integer; aTop: Integer; aWidth: Integer; aHeight: Integer);
begin
  if FLockRatio then
  begin
    aWidth := round(aHeight * Self.FRatio);
  end;
  inherited;
end;

procedure TdmcMap.SetBoundRectOriginal;
var
  rc: TRect;
begin
  if (Background.Width <> 0) and (Background.Height <> 0) then
  begin
    rc := GetBoundsRect;
    rc.Width := Background.Width;
    rc.Height := Background.Height;
    SetBoundsRect(rc);
  end;
end;

procedure TdmcMap.SetMovable(b: Boolean);
begin
  if b then
  begin
    if not(gnoMovable in Self.NodeOptions) then
      NodeOptions := NodeOptions + [gnoMovable];
  end
  else if gnoMovable in NodeOptions then
    NodeOptions := NodeOptions - [gnoMovable];
end;

procedure TdmcMap.SetSelectable(b: Boolean);
begin
  if b then
  begin
    if not(goSelectable in Options) then
      Options := Options + [goSelectable];
  end
  else if goSelectable in Options then
    Options := Options - [goSelectable];
end;

procedure TdmcMap.SetResizable(b: Boolean);
begin
  if b then
  begin
    if not(gnoResizable in Self.NodeOptions) then
      NodeOptions := NodeOptions + [gnoResizable];
  end
  else if gnoMovable in NodeOptions then
    NodeOptions := NodeOptions - [gnoResizable];
end;

procedure TdmcDataItem.SetData(v: Variant);
begin
  FData := v;
    { todo:���Ӷ�v�����ͼ�顢ת����顢��ʽ���� }
    // Self.Text := v;
end;

procedure TdmcDataItem.ShowData(AData: string; dt: TDateTime);
begin
  Text := AData;
  Self.FDTScale := dt;
  Hint := DesignName + ' : ' + DataName + #13#10'�۲�����: ' + FormatDateTime('yyyy-mm-dd', dt);
end;

procedure TdmcDataItem.ClearData;
begin
  DTScale := 0;
  FData := Unassigned;
  Text := DesignName + ':' + DataName;
  Hint := Text;
end;

procedure TdmcDataItem.SetDTScale(dt: TDateTime);
begin
    { todo:���ʱ�����Ƿ�Ϊ�գ�����ʱ�����ʽ��ʱӦ���� }
  FDTScale := dt;
  Self.Hint := FormatDateTime('yyyy-mm-dd', dt);
end;

(*
function TdmcDataItem.GetShowBorder: Boolean;
begin
  if pen.Style = psClear then
    Result := False
  else
    Result := True;
end;

procedure TdmcDataItem.SetShowBorder(b: Boolean);
begin
  if b then
    pen.Style := psSolid
  else
    pen.Style := psClear;
end;
*)
constructor TdmcDeformationDirection.Create(AOwner: TSimpleGraph);
begin
  inherited;
  // FOneMilliMeterLength := 5; // 1mm�൱��5�����ȵ�λ
  FAngleFromNorth := 0;
  FXDirect := 1;
  FYDirect := 1;
end;

{ �����������������ֵ }
procedure TdmcDeformationDirection.SetData(ANorth: Variant; AEast: Variant);
var
  SinV, CosV: Double;
begin
  if not(VarIsClear(AEast) or VarIsNull(AEast) or VarIsClear(ANorth) or VarIsNull(ANorth)) then
  begin
    Self.Visible := True;
    FNorth := ANorth;
    FEast := AEast;
    // ������л���
    if Self.UseGlobalAngle then
    begin
      FY := GlobalTransX(FNorth, FEast);
      FX := GlobalTransY(FNorth, FEast) * -1;
    end
    else
    begin
      SinV := sin(AngleFromNorth / 180 * pi);
      CosV := Cos(AngleFromNorth / 180 * pi);
      FY := (FNorth * CosV - FEast * SinV);
      FX := (FNorth * SinV + FEast * CosV) * -1;
    end;
  end
  else
  begin
    // δ�⣬���
    VarClear(FNorth);
    VarClear(FEast);
    VarClear(FX);
    VarClear(FY);
    Self.Visible := False;
  end;

end;

procedure TdmcDeformationDirection.ShowData(AData: string; dt: TDateTime);
var
  pt0, pt1: TPoint;
begin
  if not Visible then
    Exit;

  FDTScale := dt;
  { ����AData����ûʲô�ã��������ʹ��SetData�������� }
  pt0 := Points[0];
  { ��ʱ�Ȳ�������ת��Ҳ�����Ǳ��� }
  if not(VarIsClear(FEast) or VarIsNull(FEast) or VarIsClear(FNorth) or VarIsNull(FNorth)) then
  begin
    if GlobalOneMMLength = 0 then
    begin
      pt1.X := pt0.X + FX * 20; // FOneMilliMeterLength;
      pt1.Y := pt0.Y + FY * 20; // FOneMilliMeterLength;
    end
    else
    begin
      pt1.X := pt0.X + FX * GlobalOneMMLength; // FOneMilliMeterLength;
      pt1.Y := pt0.Y + FY * GlobalOneMMLength; // FOneMilliMeterLength;
    end;
    Points[1] := pt1;

    Hint := Format('X:%s; Y:%s', [formatfloat('0.00', FY), formatfloat('0.00', FX)]);
    Text := Hint;
  end;
end;

procedure TdmcDeformationDirection.ClearData;
begin
  FX := Unassigned;
  FY := Unassigned;
  FNorth := Unassigned;
  FEast := Unassigned;
  FDTScale := 0;
  Self.Text := FDesignName;
  Hint := Text;
end;

initialization

TSimpleGraph.Register(TdmcMap);
TSimpleGraph.Register(TdmcDataItem);
TSimpleGraph.Register(TdmcDeformationDirection);
TSimpleGraph.Register(TdmcMeterLabel);

finalization

TSimpleGraph.Unregister(TdmcMap);
TSimpleGraph.Unregister(TdmcDataItem);
TSimpleGraph.Unregister(TdmcDeformationDirection);
TSimpleGraph.Unregister(TdmcMeterLabel);

end.
