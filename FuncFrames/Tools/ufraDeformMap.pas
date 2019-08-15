{ -----------------------------------------------------------------------------
 Unit Name: ufraDeformMap
 Author:    黄伟
 Date:      12-八月-2019
 Purpose:   本单元用于将所有变形监测点根据其实测坐标显示在图中，同时显示其变形
            箭头，或变形轨迹。暂时没有底图，仅各个测点而已
 History:
----------------------------------------------------------------------------- }
{ todo: 自动调整横竖轴，使之长度比例为1:1 }
unit ufraDeformMap;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  VclTee.TeeProcs, VclTee.Chart, Vcl.ExtCtrls, VclTee.Series, VclTee.ArrowCha, Vcl.StdCtrls;

type
  { 变形点坐标，采用大地坐标系 }
  TDPCoodinate = record
    DTScale: TDateTime;
    North: Double;
    East: Double;
  end;

  // PDPCoodinate = ^TDPCoodinate;
  DPCoodinates  = array of TDPCoodinate;
  PDPCoodinates = ^DPCoodinates;

  TDPArrowSeries = class(TArrowSeries)
  private
    FDesignName: string;
    FCoodintes : PDPCoodinates;
  public

  published
    property DesignName: string read FDesignName write FDesignName;
  end;

  TfraDeformMap = class(TFrame)
    Panel1: TPanel;
    chtDeformMap: TChart;
    TeeGDIPlus1: TTeeGDIPlus;
    Series1: TArrowSeries;
    Label1: TLabel;
    edtExaggeration: TEdit;
    Label2: TLabel;
  private
    { Private declarations }
    FExaggeration: Integer; // 夸张程度，坐标单位为米，但是变形则是毫米级，所以需要夸张来显示变形
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Clear;
    // 添加一个仪器，及坐标数组
    procedure AddDP(AName: string; ACoodinates: DPCoodinates);
    // 设置指定仪器的坐标数据数组，若已有数据，则用新数据替换之
    // 向指定仪器添加一个坐标；
    // 删除指定仪器最后一个坐标
    // 删除一个测点
    // 暂停刷新
    // 刷新
  end;

implementation

{$R *.dfm}


constructor TfraDeformMap.Create(AOwner: TComponent);
begin
  inherited;
  FExaggeration := 1000; // 将变形放大1000倍，如此夸张，还不知道是否能看的清楚
  chtDeformMap.RemoveAllSeries;
  FreeAndNil(Series1);
end;

procedure TfraDeformMap.Clear;
begin
  // chtDeformMap.ClearChart;
  chtDeformMap.FreeAllSeries;
end;

procedure TfraDeformMap.AddDP(AName: string; ACoodinates: DPCoodinates);
var
  NewAS : TArrowSeries;
  i     : Integer;
  X1, Y1: Double;
  X2, Y2: Double;
  dX, dY: Double;
begin
  NewAS := TArrowSeries.Create(chtDeformMap);
  NewAS.Name := 'DP' + IntToStr(Integer(NewAS)); // 用对象的地址作为对象名，可避免名称重复
  NewAS.Title := AName;
  NewAS.XValues.DateTime := False;
  NewAS.Marks.Visible := True;
  NewAS.Marks.Style := smsLabel; // smsLabel;
  NewAS.Marks.Clip := True;
  NewAS.Marks.ClipText := True;
  X1 := ACoodinates[0].East;
  Y1 := ACoodinates[0].North;
  for i := Low(ACoodinates) to High(ACoodinates) - 1 do
  begin
    // 首先添加第一个点的实际坐标，以后的点在第一个点的坐标上加上夸张后的差值。
    // 现在测试时，先测试全部添加坐标的情况。
    { NewAS.AddArrow(ACoodinates[i].East, ACoodinates[i].North, ACoodinates[i + 1].East,
      ACoodinates[i + 1].North); }
    // 计算坐标差值，并夸张一下
    dX := (ACoodinates[i + 1].East - ACoodinates[i].East) * FExaggeration;
    dY := (ACoodinates[i + 1].North - ACoodinates[i].North) * FExaggeration;
    X2 := X1 + dX;
    Y2 := Y1 + dY;
    if i = low(ACoodinates) then
        NewAS.AddArrow(X1, Y1, X2, Y2, AName)
    else
        NewAS.AddArrow(X1, Y1, X2, Y2);
    X1 := X2;
    Y1 := Y2;
  end;
  i := High(ACoodinates);
  NewAS.LegendTitle := format('%s: 北:%3.2f; 东:%3.2f',
    [AName, (ACoodinates[i].North - ACoodinates[0].North) * 1000,
    (ACoodinates[i].East - ACoodinates[0].East) * 1000]);
  // NewAs.Legend.
  NewAS.ParentChart := chtDeformMap;

  (*
  with chtDeformMap do
      Label2.Caption := format('w: %f; h: %f', [MaxXValue(BottomAxis) - MinXValue(BottomAxis),
      maxyvalue(LeftAxis) - minyvalue(LeftAxis)]);
  chtDeformMap.SetChartRect(rect(0, 0, 400 + chtDeformMap.Legend.Width, 400));
 *)
end;

end.
