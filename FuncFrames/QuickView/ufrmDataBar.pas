{-----------------------------------------------------------------------------
 Unit Name: ufrmDataBar
 Author:    黄伟
 Date:      29-十月-2022
 Purpose:   本单元绘制选定的一组监测仪器和指定的观测量当前数据及变化量，棒图
            型式。
            本单元配合速览功能(ufraQuickViewer)，也从该界面调用。
 History:   2022-10-27 首发
-----------------------------------------------------------------------------}
{ todo:考虑将这个DataBar图功能弄成自定义组的型式，可以保存、调用 }
unit ufrmDataBar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine, VclTee.Series,
  Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, Vcl.Menus, Data.Db;

type
  TfrmDataBar = class(TForm)
    chtBar: TChart;
    ssMeterData: TBarSeries;
    ssDelta: TBarSeries;
    PopupMenu1: TPopupMenu;
    piCopyToClipboard: TMenuItem;
    N1: TMenuItem;
    piSetupChart: TMenuItem;
    TeeGDIPlus1: TTeeGDIPlus;
    piLabel90: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure chtBarDblClick(Sender: TObject);
    procedure piCopyToClipboardClick(Sender: TObject);
    procedure piSetupChartClick(Sender: TObject);
    procedure piLabel90Click(Sender: TObject);
  private
    { Private declarations }
    FMeters: String; // 用来显示Form标题的，没别的用途
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    procedure ClearSeries;
    procedure AddData(ADsnName: string; AData, ADelta: Double);
    procedure DrawBar(AType: String; APDName: String; ADS: TDataSet; DrawDelta: Boolean = False);
  end;

procedure PopupDataBar(AType: String; APDName: String; ADS: TDataSet; DrawDelta: Boolean = False);

implementation

uses
  VclTee.TeePrevi, VclTee.EditChar, VclTee.TeePoEdi {, TeCanvas} , VclTee.TeePenDlg,
  VclTee.TeExport, VclTee.TeeStore, VclTee.TeePNG, VclTee.TeeJPEG, VclTee.TeeGIF;
{$R *.dfm}


var
  defHeight: integer;
  defWidth : integer;

procedure TfrmDataBar.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := 0;
end;

procedure TfrmDataBar.chtBarDblClick(Sender: TObject);
var
  mp     : TPoint;
  clkPart: TChartClickedPart;
begin
 //
  mp := chtBar.GetCursorPos;
  chtBar.CalcClickedPart(mp, clkPart);
  case clkPart.Part of
    cpNone:;
    cpLegend:;
    cpAxis:
      clkPart.AAxis.Automatic := True;
    cpSeries:;
    cpTitle:
      chtBar.Title.Text.Text := InputBox('修改图形标题', '输入新标题', chtBar.Title.Text.Text);
    cpFoot:;
    cpChartRect:;
    cpSeriesMarks:;
    cpSeriesPointer:;
    cpSubTitle:;
    cpSubFoot:;
    cpAxisTitle:
      clkPart.AAxis.Title.Text := InputBox('修改坐标轴标题', '输入坐标轴新标题', clkPart.AAxis.Title.Text);

  end;

end;

procedure TfrmDataBar.ClearSeries;
begin
  chtBar.Series[0].Clear;
  chtBar.Series[1].Clear;
end;

procedure TfrmDataBar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmDataBar.FormResize(Sender: TObject);
begin
  defHeight := Self.Height;
  defWidth := Self.Width;
end;

procedure TfrmDataBar.piCopyToClipboardClick(Sender: TObject);
begin
  chtBar.Legend.CheckBoxes := False;
  chtBar.CopyToClipboardBitmap;
  chtBar.Legend.CheckBoxes := True;
end;

procedure TfrmDataBar.piLabel90Click(Sender: TObject);
begin
  if chtBar.BottomAxis.LabelsAngle = 0 then
      chtBar.BottomAxis.LabelsAngle := 90
  else chtBar.BottomAxis.LabelsAngle := 0;
  piLabel90.Checked := chtBar.BottomAxis.LabelsAngle = 90;
end;

procedure TfrmDataBar.piSetupChartClick(Sender: TObject);
begin
  EditChart(Self, chtBar);
end;

procedure TfrmDataBar.AddData(ADsnName: string; AData: Double; ADelta: Double);
begin
  (chtBar.Series[0] as TBarSeries).Add(AData, ADsnName);
  (chtBar.Series[1] as TBarSeries).Add(ADelta, ADsnName);
end;

procedure TfrmDataBar.DrawBar(AType: string; APDName: string; ADS: TDataSet;
  DrawDelta: Boolean = False);
var
  i: integer;
  s: string;
begin
  chtBar.Title.Text.Text := AType + APDName + '测值及增量';
  if ADS.RecordCount = 0 then exit;

  ADS.First;
  FMeters := ADS.FieldByName('DesignName').AsString;

  if ADS.FindField('Data') <> nil then s := 'Data'
  else if ADS.FindField('Data2') <> nil then s := 'Data2'
  else s := '';
  i := 0;
  if s <> '' then
    repeat
      if ADS.FieldByName('PDName').AsString = APDName then
      begin
        FMeters := ADS.FieldByName('DesignName').AsString;
        // 设置窗体标题，这是第一支仪器
        if i = 0 then
        begin
          Self.Caption := AType + '组观测数据(' + ADS.FieldByName('PDName').AsString + '): ' + FMeters;
          i := 1;
        end;

        AddData(ADS.FieldByName('DesignName').AsString, ADS.FieldByName(s).AsFloat,
          ADS.FieldByName('Increment').AsFloat);
      end;
      ADS.next;
    until ADS.Eof;
  ADS.Last;
  Self.Caption := Self.Caption + ' ~ ' + FMeters;
  chtBar.Title.Text.Text := self.Caption;
end;

procedure PopupDataBar(AType: String; APDName: String; ADS: TDataSet; DrawDelta: Boolean = False);
var
  frm: TfrmDataBar;
begin
  frm := TfrmDataBar.Create(application.MainForm);
  if (defWidth > 0) and (defHeight > 0) then
      frm.SetBounds(frm.Left, frm.Top, defWidth, defHeight);
  frm.chtBar.Title.Text.Text := AType + '棒棒图';
  frm.chtBar.LeftAxis.Title.Text := APDName;
  frm.DrawBar(AType, APDName, ADS, DrawDelta);
  frm.Show;
end;

end.
