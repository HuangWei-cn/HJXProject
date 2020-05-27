{ -----------------------------------------------------------------------------
 Unit Name: uhwSGEx.DataMapClasses
 Author:    黄伟
 Date:      20-四月-2017
 Purpose:   基于SimpleGraph的数据图元定义
            本单元类继承自uhwSGEx单元，是对SimpleGraph的扩展，用于显示数据
            分布图
 History:
----------------------------------------------------------------------------- }

unit uhwSGEx.DataMapClasses;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.UITypes, System.Variants,
  Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  SimpleGraph, SynGdiPlus, uhwSGEx;

type
    { 底图类 }
    { DONE:锁定长宽比功能 }
    { todo:取消“Linkable”属性 }
    { DONE:加载图形后，只默认锁定比例，不按原图缩放。由用户决定是否按1:1显示图纸 }
  TdmcMap = class(TGPRectangularNode)
  private
    FRatio         : Double; // 原始图片长宽比
    FLockRatio     : Boolean;
    FAngleFromNorth: Double;  // 底图与正北的夹角
    FOneMMLength   : Integer; // 1mm相当于多少绘图长度单位，用于指示数据大小
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
    // 底图Y正方向和正北的夹角，这个属性主要用于绘出平面变形的方向。绘图平面的Y
    // 正方向向下。
    property AngleFromNorth: Double read FAngleFromNorth write FAngleFromNorth;
    property OneMMLength   : Integer read FOneMMLength write FOneMMLength;
  end;

    { 数据项类 }
    { todo:设计时，显示编号+数据名；运行时，显示数据，或日期+数据，Hint为编号+数据名 }
    { todo:提供几种不同的显示方式，如“数据”、“数据名：数据”、“日期：数据”等等 }
    { todo:允许在显示数据和显示数据项之间切换 }
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

    { 2018-06-14 增加仪器标签对象。本对象未来的扩展功能有：1)显示数据不一定必须使用TdmcDataItem
      对象，本对象在ShowData之后自动创建数据标签、数据箭头；2)其他功能还没想好 }
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

    { 2019-06-19 增加表示仪器数据大小和方向的箭头，首要目标是实现平面变形数据的方向和大小 }
  TdmcDataArrow = class(TGPGraphicLink)
  private
  published
  end;

  { 2019-08-06 变形方向指示，根据平面变形测值、与正北方向夹角计算出箭头的方向和大小，显示出来。
    问题：1、是否需要设置为固定长度，仅标示出方向和变形数值？
          2、若变长，可否考虑变比例，比如对数坐标？
 }
  TdmcDeformationDirection = class(TGPGraphicLink)
  private
    FDesignName: string;
    FMeterType : string;
    FXName     : string;  // X数据名
    FYName     : string;  // Y数据名
    FXDirect   : Integer; // X方向系数，即在图中是否需要将实际值乘以-1。当采用大地坐标时，不需要
    FYDirect   : Integer; // Y方向系数
    // FOneMilliMeterLength: Integer; // 1mm相当于多少图像单位。
    FAngleFromNorth: Double; // Y正方向与正北方向夹角。大地坐标中，X为正北方向，Y为正东方向；在图像中，Y
      // 为竖直向下，X为横向向右，需要进行旋转变换才能得到正确的数值。
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
    // 是否采用全局角度，指是否采用底图和正北夹角作为全局角度使用。若不用采用全，
    // 局角度，则需要设置每一个变形点屏幕正方向和正北夹角（采用大地坐标），或设置
    // 每一个变形点的临空面与正北夹角（采用本地坐标）
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

{ 设置公共变量 }
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

{ X坐标旋转 }
function GlobalTransX(X, Y: Double): Double;
begin
  Result := X * CosValue - Y * SinValue;
end;

{ Y坐标旋转 }
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
  FOneMMLength := 5; // 每毫米=5个绘图长度单位
end;

procedure TdmcMap.BackgroundChanged(Sender: TObject);
var
  rc: TRect;
begin
  inherited;
    { 根据底图实际尺寸设置本对象大小，用户可以之后再重新调整 }
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
    { todo:增加对v的类型检查、转换检查、格式化等 }
    // Self.Text := v;
end;

procedure TdmcDataItem.ShowData(AData: string; dt: TDateTime);
begin
  Text := AData;
  Self.FDTScale := dt;
  Hint := DesignName + ' : ' + DataName + #13#10'观测日期: ' + FormatDateTime('yyyy-mm-dd', dt);
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
    { todo:检查时间项是否为空，若有时间项，格式化时应加上 }
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
  // FOneMilliMeterLength := 5; // 1mm相当于5个长度单位
  FAngleFromNorth := 0;
  FXDirect := 1;
  FYDirect := 1;
end;

{ 将大地坐标测量结果赋值 }
procedure TdmcDeformationDirection.SetData(ANorth: Variant; AEast: Variant);
var
  SinV, CosV: Double;
begin
  if not(VarIsClear(AEast) or VarIsNull(AEast) or VarIsClear(ANorth) or VarIsNull(ANorth)) then
  begin
    Self.Visible := True;
    FNorth := ANorth;
    FEast := AEast;
    // 下面进行换算
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
    // 未测，清空
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
  { 这里AData参数没什么用，这个对象使用SetData设置数据 }
  pt0 := Points[0];
  { 暂时既不考虑旋转，也不考虑比例 }
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
