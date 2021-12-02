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
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, VclTee.TeeTools, VclTee.Series, Vcl.Menus,
  VclTee.TeeChineseSimp;

type
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
  private
        { Private declarations }
    FSelectedSeries: TChartSeries;
    FBeMinimalism  : Boolean; // �Ƿ񼫼�
  public
        { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
        // Draw a line
    procedure AddData(ASeries: TChartSeries; X: Double; Y: Double;
      ALabel: String = ''); overload;
    procedure AddData(SeriesIndex: Integer; X: Double; Y: Double;
      ALabel: string = ''); overload;
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
  VclTee.TeExport, VclTee.TeeStore, VclTee.TeePNG, VclTee.TeeJPEG, VclTee.TeeGIF;

{$R *.dfm}


constructor TfraBasicTrendLine.Create(AOwner: TComponent);
begin
  inherited;
  TeeSetChineseSimp;
end;

destructor TfraBasicTrendLine.Destroy;
begin
  inherited;
end;

procedure TfraBasicTrendLine.AddData(ASeries: TChartSeries; X: Double; Y: Double;
  ALabel: string = '');
begin
  ASeries.AddXY(X, Y, ALabel);
end;

procedure TfraBasicTrendLine.AddData(SeriesIndex: Integer; X: Double; Y: Double;
  ALabel: string = '');
begin
  chtLine.Series[SeriesIndex].AddXY(X, Y, ALabel)
end;

procedure TfraBasicTrendLine.ShowSampleDatas;
begin
  Series1.FillSampleValues(50);
  Series2.FillSampleValues(50);
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
end;

procedure TfraBasicTrendLine.chtLineDblClick(Sender: TObject);
var
  mp     : TPoint;
  clkPart: TChartClickedPart;
begin
  mp := chtLine.GetCursorPos;
  chtLine.CalcClickedPart(mp, clkPart);
  if (clkPart.Part = cpAxis) or (clkPart.Part = cpAxisTitle) then
  begin
    clkPart.AAxis.Automatic := True;
  end;
end;

procedure TfraBasicTrendLine.chtLineMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  mp     : TPoint;
  clkPart: TChartClickedPart;
begin
  mp := chtLine.GetCursorPos;
  chtLine.CalcClickedPart(mp, clkPart);
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
end;

procedure TfraBasicTrendLine.ClearDatas(ASeries: TChartSeries);
begin
  ASeries.Clear;
end;

procedure TfraBasicTrendLine.ReleaseTrendLines;
var
  i: Integer;
begin
  for i := 0 to chtLine.Seriescount - 1 do
      chtLine.Series[i].Free;
  chtLine.RemoveAllSeries;
end;

procedure TfraBasicTrendLine.SetChartTitle(ATitle: string);
begin
  chtLine.Title.Caption := ATitle;
end;

function TfraBasicTrendLine.NewLine(ATitle: string; VAxisIsLeft: Boolean = True)
  : Integer;
var
  ls: TLineSeries;
begin
  Result := -1;
  ls := TLineSeries.Create(chtLine);
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
  ls.Pointer.Style := TSeriesPointerStyle(chtLine.Seriescount - 1);

  if chtLine.Seriescount = 1 then // ��һ������PointerStyle�������Σ�Size=3�Ե�̫��so...
      ls.Pointer.Size := 2
  else
      ls.Pointer.Size := 3;

    // ���߷�ʽ������
  ls.DrawStyle := dsCurve;

  Result := chtLine.SeriesList.IndexOf(ls);
end;

procedure TfraBasicTrendLine.piCopyAsEMFClick(Sender: TObject);
begin
  chtLine.Legend.CheckBoxes := False;
  chtLine.CopyToClipboardMetafile(True);
  chtline.Legend.CheckBoxes := True;
    // chtLine.CopyToClipboardBitmap;
end;

procedure TfraBasicTrendLine.piMinimalismClick(Sender: TObject);
begin
  piMinimalism.Checked := not piMinimalism.Checked;
  Minimalism := piMinimalism.Checked;
end;

procedure TfraBasicTrendLine.piCopyAsBitmapClick(Sender: TObject);
var
  JPG: TJPEGExportFormat;
begin
  JPG := TJPEGExportFormat.Create;
  try
    chtline.Legend.CheckBoxes := false;
    JPG.Panel := chtLine;
    JPG.CopyToClipboard;
  finally
    JPG.Free;
    chtline.Legend.CheckBoxes := true;
  end;
    // chtLine.CopyToClipboardBitmap;
    // chtLine.CopyToClipboardMetafile(True);
end;

procedure TfraBasicTrendLine.piSaveAsEMFClick(Sender: TObject);
begin
  chtline.Legend.CheckBoxes := false;
  TeeExport(nil, chtLine);
  chtline.Legend.CheckBoxes := true;
end;

procedure TfraBasicTrendLine.piSaveAsBitmapClick(Sender: TObject);
begin
  chtline.Legend.CheckBoxes := false;
  TeeExport(nil, chtLine);
  chtline.Legend.CheckBoxes := true;
end;

procedure TfraBasicTrendLine.piSaveAsTeeChartClick(Sender: TObject);
begin
  chtline.Legend.CheckBoxes := false;
  TeeExport(nil, chtLine);
  chtline.Legend.CheckBoxes := true;
end;

procedure TfraBasicTrendLine.piSetupChartClick(Sender: TObject);
begin
  EditChart(nil, chtLine);
end;

procedure TfraBasicTrendLine.piSetupSeriesClick(Sender: TObject);
begin
  if FSelectedSeries <> nil then
      EditSeries(nil, FSelectedSeries);
end;

procedure TfraBasicTrendLine.SetMinimalism(V: Boolean);
var
  i: Integer;
begin
    { ����������壬������һ�Ѷ�����ͬʱ�������ߵĵ��С }
  chtLine.Title.Visible := not V;
  chtLine.Legend.Visible := not V;
    // chtLine.LeftAxis.Visible := not V;
  with chtLine.leftaxis do
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

  for i := 0 to chtLine.Seriescount - 1 do
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

end.
