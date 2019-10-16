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
  private
    { Private declarations }
  public
    { Public declarations }
    /// <summary>
    /// 从给定的DataSet中查找给定部位、给定仪器类型的特征值，并绘制特征曲线
    /// </summary>
    procedure DrawEVGraph(APos, AType, APDName: String; ADS: TDataSet);
  end;

implementation

uses
  VclTee.TeePrevi, VclTee.EditChar, VclTee.TeePoEdi {, TeCanvas} , VclTee.TeePenDlg,
  VclTee.TeExport, VclTee.TeeStore, VclTee.TeePNG, VclTee.TeeJPEG, VclTee.TeeGIF;

{$R *.dfm}


procedure TfrmEVGraph.DrawEVGraph(APos: string; AType: string; APDName: String; ADS: TDataSet);
var
  i: Integer;
  s: String;
begin
  Chart.Title.Text.Text := APos + AType + '特征曲线';
  if ADS.RecordCount = 0 then Exit;
  ADS.First;
  Chart.LeftAxis.Title.Text := APDName;
  Chart.BottomAxis.Title.Text := AType;
  repeat
    if (ADS.FieldByName('Position').AsString = APos) and
      (ADS.FieldByName('MeterType').AsString = AType) and
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

procedure TfrmEVGraph.piCopyAsBitmapClick(Sender: TObject);
begin
  Chart.CopyToClipboardBitmap;
end;

procedure TfrmEVGraph.piCopyAsMetafileClick(Sender: TObject);
begin
  Chart.CopyToClipboardMetafile(True);
end;

procedure TfrmEVGraph.piSetupChartClick(Sender: TObject);
begin
  EditChart(Self, Chart);
end;

end.
