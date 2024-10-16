unit ufrmEVGraph;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, Vcl.Menus, VclTee.TeEngine,
  VclTee.Series, Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, Data.DB;

type
  TfrmEVGraph = class(TForm)
    Chart: TChart;
    TeeGDIPlus1: TTeeGDIPlus;
    srsMax: TLineSeries;
    srsLast: TLineSeries;
    srsMin: TLineSeries;
    PopupMenu1: TPopupMenu;
    piCopyAsBitmap: TMenuItem;
    piCopyAsMetafile: TMenuItem;
    N3: TMenuItem;
    piSetupChart: TMenuItem;
    procedure piCopyAsBitmapClick(Sender: TObject);
    procedure piCopyAsMetafileClick(Sender: TObject);
    procedure piSetupChartClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ChartDblClick(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    /// <summary>
    /// 从给定的DataSet中查找给定部位、给定仪器类型的特征值，并绘制特征曲线
    /// </summary>
    procedure DrawEVGraph(APos, AType, APDName: String; ADS: TDataSet; GroupByPos: Boolean);
  end;

procedure PopupEVGraph(APos, AType, APDName: String; ADS: TDataSet; GroupByPosition:Boolean);

implementation

uses
  VclTee.TeePrevi, VclTee.EditChar, VclTee.TeePoEdi {, TeCanvas} , VclTee.TeePenDlg,
  VclTee.TeExport, VclTee.TeeStore, VclTee.TeePNG, VclTee.TeeJPEG, VclTee.TeeGIF;

{$R *.dfm}

var
  FrmHeight, FrmWidth: Integer;

procedure TfrmEVGraph.ChartDblClick(Sender: TObject);
var
  mp     : TPoint;
  clkPart: TChartClickedPart;
  S:String;
begin
  mp := chart.GetCursorPos;
  Chart.CalcClickedPart(mp, clkPart);
  if clkPart.Part = cpTitle then
  begin
    s := chart.Title.Caption;
    s := InputBox('设置分布图标题', '输入新的分布图标题', s);
    if s<>'' then
      chart.Title.Caption := s;
  end;
end;

procedure TfrmEVGraph.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := 0;
end;

procedure TfrmEVGraph.DrawEVGraph(APos: string; AType: string; APDName: String; ADS: TDataSet;
  GroupByPos: Boolean);
var
  i       : Integer;
  s       : String;
  PosCondi: Boolean;
begin
  Chart.Title.Text.Text := APos + AType + '特征曲线';
  if ADS.RecordCount = 0 then
    Exit;
  ADS.First;
  Chart.LeftAxis.Title.Text := APDName;
  Chart.BottomAxis.Title.Text := AType;
  repeat
    if GroupByPos then
      if ADS.FieldByName('Position').AsString = APos then
        PosCondi := true
      else
        PosCondi := False
    else
      PosCondi := true;

    if PosCondi and (ADS.FieldByName('MeterType').AsString = AType) and
      (ADS.FieldByName('PDName').AsString = APDName) then
    begin
      s := ADS.FieldByName('DesignName').AsString;
      if ADS.FieldByName('MaxInLife').IsNull then
        srsMax.AddNull
      else
        srsMax.AddY(ADS.FieldByName('MaxInLife').AsFloat, s);

      if ADS.FieldByName('MinInLife').IsNull then
        srsMin.AddNull
      else
        srsMin.AddY(ADS.FieldByName('MinInLife').AsFloat, s);

      if ADS.FieldByName('Value').IsNull then
        srsLast.AddNull
      else
        srsLast.AddY(ADS.FieldByName('Value').AsFloat, s);
    end;
    ADS.Next;
  until ADS.Eof;
end;

procedure TfrmEVGraph.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmEVGraph.FormResize(Sender: TObject);
begin
  FrmHeight := Self.Height;
  FrmWidth := Self.Width;
end;

procedure TfrmEVGraph.piCopyAsBitmapClick(Sender: TObject);
begin
  Chart.Legend.CheckBoxes := False;
  Chart.CopyToClipboardBitmap;
  Chart.Legend.CheckBoxes := true;
end;

procedure TfrmEVGraph.piCopyAsMetafileClick(Sender: TObject);
begin
  Chart.Legend.CheckBoxes := False;
  Chart.CopyToClipboardMetafile(true);
  Chart.Legend.CheckBoxes := true;
end;

procedure TfrmEVGraph.piSetupChartClick(Sender: TObject);
begin
  EditChart(Self, Chart);
end;

procedure PopupEVGraph(APos, AType, APDName: String; ADS: TDataSet; GroupByPosition: Boolean);
var
  frm: TfrmEVGraph;
begin
  frm := TfrmEVGraph.Create(Application.MainForm);
  if (FrmWidth > 0) and (FrmHeight > 0) then
    frm.SetBounds(frm.Left, frm.Top, FrmWidth, FrmHeight);
  frm.DrawEVGraph(APos, AType, APDName, ADS, GroupByPosition);
  frm.Show;
end;

end.
