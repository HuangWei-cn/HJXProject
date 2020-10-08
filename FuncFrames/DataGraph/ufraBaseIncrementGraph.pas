{ -----------------------------------------------------------------------------
 Unit Name: ufraBaseIncrementGraph
 Author:    ��ΰ
 Date:      08-ʮ��-2020
 Purpose:   ������������ʾ������ݵ�ʱ������ͼ�����������ȡ�
            ͨ������ͼ�����ڱ��Ρ�ѹ����Ӧ���������ʾ��
            ���ڽ���һ���������ļ��������ֻ��Ҫ��ʾһ����������������ͼ������
            �ж���������ļ������������λ�ƼƵȣ����������Ҫ��һ��Chart��
            ��ʾ�����ͼ��
            �����ܵ�ʹ�ã�������һ��Form�����������ɵ���ʽ�Ĵ��壻�����񡰹۲�
            ���ݱ�������������ĬĬ�����꿽��Ϊλͼ���뵽Webҳ���С�

 History:
----------------------------------------------------------------------------- }

unit ufraBaseIncrementGraph;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  VclTee.Series, Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, Vcl.Menus, VclTee.TeeChineseSimp,
  VclTee.TeeTools;

type
  TfraIncGraph = class(TFrame)
    chtBar: TChart;
    srsBar1: TBarSeries;
    TeeGDIPlus1: TTeeGDIPlus;
    popIncBar: TPopupMenu;
    piCopyAsBitmap: TMenuItem;
    N1: TMenuItem;
    piSetup: TMenuItem;
    ChartTool1: TAxisScrollTool;
    procedure piSetupClick(Sender: TObject);
    procedure piCopyAsBitmapClick(Sender: TObject);
    procedure chtBarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    /// <summary>
    /// ����ͼ�Σ�ɾ�������Bar��������srsBar1��ʹ֮�ع鵽û�����ݵ�״̬
    /// </summary>
    procedure ResetChart;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure AddData(Value: Variant; ALabel: String); overload;
    procedure AddData(SeriesIndex: Integer; Value: Variant; ALabel: String); overload;
    function NewBar(ATitle: string): Integer;
  end;

implementation

{$R *.dfm}


uses
  VclTee.TeePrevi, VclTee.EditChar, VclTee.TeePoEdi {, TeCanvas} , VclTee.TeePenDlg,
  VclTee.TeExport, VclTee.TeeStore, VclTee.TeePNG, VclTee.TeeJPEG, VclTee.TeeGIF;

constructor TfraIncGraph.Create(AOwner: TComponent);
begin
  inherited;
  TeeSetChineseSimp;
end;

procedure TfraIncGraph.ResetChart;
var
  i  : Integer;
  srs: TChartSeries;
begin
  if chtBar.SeriesCount > 1 then
    for i := chtBar.SeriesCount - 1 downto 1 do
    begin
      srs := chtBar.Series[i];
      chtBar.Serieslist.Remove(srs);
      srs.Free;
    end;
  srsBar1.Clear;
end;

procedure TfraIncGraph.AddData(SeriesIndex: Integer; Value: Variant; ALabel: string);
begin
  if (VarIsNull(Value)) or (VarIsEmpty(Value)) then
    (chtBar.Series[SeriesIndex] as TBarSeries).Add(0, ALabel)
  else
    (chtBar.Series[SeriesIndex] as TBarSeries).Add(Value, ALabel);
end;

procedure TfraIncGraph.AddData(Value: Variant; ALabel: string);
begin
  // srsBar1.Add(Value, ALabel);
  AddData(0, Value, ALabel);
end;

procedure TfraIncGraph.chtBarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  mp     : TPoint;
  clkPart: TChartClickedPart;
begin
  mp := chtBar.GetCursorPos;
  chtBar.CalcClickedPart(mp, clkPart);
  if (clkPart.Part = cpAxis) or (clkPart.Part = cpAxisTitle) then
  begin
        // Ŀǰ��ʱ��Zoom�ķ�����ʵ�������᷽������š�������ͬʱ�������к�����������ᣬ������
        // �������ĳһ����������š�
    if clkPart.AAxis.Horizontal then
        chtBar.Zoom.Direction := tzdHorizontal
    else
        chtBar.Zoom.Direction := tzdVertical
  end
  else
  begin
    chtBar.Zoom.Direction := tzdBoth;
    if clkPart.Part = cpSeriesPointer then
      with clkPart do
          chtBar.Hint := format('%8.2f',
          [TBarSeries(ASeries).YValue[PointIndex]])
    else
        chtBar.Hint := '';
  end;

end;

function TfraIncGraph.NewBar(ATitle: string): Integer;
var
  srs: TBarSeries;
begin
  Result := -1;
  srs := TBarSeries.Create(chtBar);
  // ָ��һ��Ψһ������
  srs.Name := 'BarSeries' + IntToStr(Integer(srs));
  srs.Title := ATitle;
  srs.Marks.Visible := False;
  chtBar.AddSeries(srs);
  Result := chtBar.Serieslist.IndexOf(srs);
end;

procedure TfraIncGraph.piCopyAsBitmapClick(Sender: TObject);
var
  JPG: TJPEGExportFormat;
begin
  JPG := TJPEGExportFormat.Create;
  try
    JPG.Panel := chtBar;
    JPG.CopyToClipboard;
  finally
    JPG.Free;
  end;
end;

procedure TfraIncGraph.piSetupClick(Sender: TObject);
begin
  EditChart(nil, chtBar);
end;

end.
