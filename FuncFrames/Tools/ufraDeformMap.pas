{ -----------------------------------------------------------------------------
 Unit Name: ufraDeformMap
 Author:    ��ΰ
 Date:      12-����-2019
 Purpose:   ����Ԫ���ڽ����б��μ��������ʵ��������ʾ��ͼ�У�ͬʱ��ʾ�����
            ��ͷ������ι켣����ʱû�е�ͼ��������������
 History:
----------------------------------------------------------------------------- }
{ todo: �Զ����������ᣬʹ֮���ȱ���Ϊ1:1 }
unit ufraDeformMap;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  VclTee.TeeProcs, VclTee.Chart, Vcl.ExtCtrls, VclTee.Series, VclTee.ArrowCha, Vcl.StdCtrls;

type
  { ���ε����꣬���ô������ϵ }
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
    FExaggeration: Integer; // ���ų̶ȣ����굥λΪ�ף����Ǳ������Ǻ��׼���������Ҫ��������ʾ����
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Clear;
    // ���һ������������������
    procedure AddDP(AName: string; ACoodinates: DPCoodinates);
    // ����ָ�������������������飬���������ݣ������������滻֮
    // ��ָ���������һ�����ꣻ
    // ɾ��ָ���������һ������
    // ɾ��һ�����
    // ��ͣˢ��
    // ˢ��
  end;

implementation

{$R *.dfm}


constructor TfraDeformMap.Create(AOwner: TComponent);
begin
  inherited;
  FExaggeration := 1000; // �����ηŴ�1000������˿��ţ�����֪���Ƿ��ܿ������
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
  NewAS.Name := 'DP' + IntToStr(Integer(NewAS)); // �ö���ĵ�ַ��Ϊ���������ɱ��������ظ�
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
    // ������ӵ�һ�����ʵ�����꣬�Ժ�ĵ��ڵ�һ����������ϼ��Ͽ��ź�Ĳ�ֵ��
    // ���ڲ���ʱ���Ȳ���ȫ���������������
    { NewAS.AddArrow(ACoodinates[i].East, ACoodinates[i].North, ACoodinates[i + 1].East,
      ACoodinates[i + 1].North); }
    // ���������ֵ��������һ��
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
  NewAS.LegendTitle := format('%s: ��:%3.2f; ��:%3.2f',
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
