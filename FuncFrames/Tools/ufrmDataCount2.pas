{ -----------------------------------------------------------------------------
 Unit Name: ufrmDataCount2
 Author:    ��ΰ
 Date:      14-ʮ��-2022
 Purpose:   ��ϸ��Ĺ۲����ͳ�ƣ����ڼ��㾭�ѣ�Ҳ������������ȱ�������
 History:
----------------------------------------------------------------------------- }

unit ufrmDataCount2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, HTMLUn2, HtmlView, Vcl.StdCtrls, Vcl.ExtCtrls, DateUtils,
  uHJX.Intf.Datas, {uHJX.Excel.Meters} uHJX.Classes.Meters, uHJX.Data.Types, Vcl.ComCtrls,
  Vcl.Menus;

type
  TfrmDataCount2 = class(TForm)
    Panel1: TPanel;
    btnCountNow: TButton;
    HtmlViewer1: THtmlViewer;
    ProgressBar1: TProgressBar;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    HtmlViewer2: THtmlViewer;
    PopupMenu1: TPopupMenu;
    piCopyToClipboard: TMenuItem;
    dtpStart: TDateTimePicker;
    dtpEnd: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    procedure btnCountNowClick(Sender: TObject);
    procedure piCopyToClipboardClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FMeterSelected: TStrings;
  public
    { Public declarations }
  end;

var
  frmDataCount2: TfrmDataCount2;

implementation

uses
  uWebGridCross, ufrmMeterSelector;
{$R *.dfm}


{ -----------------------------------------------------------------------------
  Procedure  : btnCountNowClick
  Description: ͳ����������ȹ۲�������ɷֽ⵽�¡�
  ��������Իƽ�Ͽ�������ʼ��ݴ�2016�꿪ʼ��
----------------------------------------------------------------------------- }
procedure TfrmDataCount2.btnCountNowClick(Sender: TObject);
var
  i, n  : Integer;
  iMeter: Integer;
  iMon  : Integer;
  V     : TVariantDynArray;
  S     : string;
  WCV1  : TWebCrossView;
  WCV2  : TWebCrossView;
  Meter : TMeterDefine;
  frm   : TfrmMeterSelector;
begin
  ProgressBar1.Position := 0;
  if ExcelMeters.Count = 0 then
  begin
    ShowMessage('û�м���������޷�ͳ��');
    Exit;
  end;

  frm := TfrmMeterSelector.Create(Self);
  frm.SetSelected(FMeterSelected);
  frm.ShowModal;
  frm.GetSelected(FMeterSelected);
  frm.Release;
  if FMeterSelected.Count = 0 then
  begin
    Exit;
  end;

  WCV1 := TWebCrossView.Create;
  WCV1.ColCount := 17;
  WCV1.AddRow;
  WCV1.Cells[0, 0].Value := '��װ��λ';
  WCV1.Cells[1, 0].Value := '��������';
  WCV1.Cells[2, 0].Value := '��Ʊ��';
  WCV1.Cells[3, 0].Value := '���';
  WCV1.Cells[4, 0].Value := '����';

  for i := 5 to 16 do
      WCV1.Cells[i, 0].Value := IntToStr(i - 4) + '��';

  WCV2 := TWebCrossView.Create;
  WCV2.ColCount := 6 + (YearOf(Now) - 2016 + 1);
  WCV2.AddRow;
  WCV2.Cells[0, 0].Value := '��װ��λ';
  WCV2.Cells[1, 0].Value := '��������';
  WCV2.Cells[2, 0].Value := '��Ʊ��';
  WCV2.Cells[3, 0].Value := '�ܲ��';
  WCV2.Cells[4, 0].Value := '��ʼ����';
  WCV2.Cells[5, 0].Value := '��ֹ����';
  for i := 6 to WCV2.ColCount - 1 do
      WCV2.Cells[i, 0].Value := 2016 + i - 6; // 2016,2017,2018....now

  try
    ProgressBar1.Max := FMeterSelected.Count;
    ProgressBar1.Visible := True;
    ExcelMeters.SortByMeterType; // �������������򣬿������̲�ѯʱ��
    for iMeter := 0 to FMeterSelected.Count - 1 do
    begin
      ProgressBar1.Position := iMeter + 1;
      Meter := ExcelMeters.Meter[FMeterSelected[iMeter]];
      IHJXClientFuncs.GetDataCount2(Meter.DesignName, dtpStart.Date, dtpEnd.Date, V);
      // ���wcv2
      WCV2.AddRow;
      n := WCV2.RowCount - 1;
      WCV2.Cells[0, n].Value := Meter.PrjParams.Position;
      WCV2.Cells[1, n].Value := Meter.Params.MeterType;
      WCV2.Cells[2, n].Value := Meter.DesignName;
      WCV2.Cells[3, n].Value := V[2]; // ��Ȳ��
      WCV2.Cells[4, n].Value := V[0]; // ��ʼ����
      WCV2.Cells[5, n].Value := V[1]; // ��ֹ����

      { ���Meter�����ݣ���Length��v��>4 }
      if Length(V) > 3 then
        for i := 3 to High(V) do { ÿһ���������飬����һ������� }
        begin
          WCV1.AddRow;
          n := WCV1.RowCount - 1;
          // ��д������Ϣ������
          WCV1.Cells[0, n].Value := Meter.PrjParams.Position;
          WCV1.Cells[1, n].Value := Meter.Params.MeterType;
          WCV1.Cells[2, n].Value := Meter.DesignName;
          WCV1.Cells[3, n].Value := V[i][0]; // ���
          WCV1.Cells[4, n].Value := V[i][1]; // ����
          if V[i][0] >= 2016 then
              WCV2.Cells[V[i][0] - 2016 + 6, WCV2.RowCount - 1].Value := V[i][1];

          // ��д�²��
          for iMon := 1 to 12 do
          begin
            WCV1.Cells[4 + iMon, n].Value := V[i][1 + iMon];
            if V[i][1 + iMon] = 0 then // ������²��Ϊ0����ɫΪǳ��ɫ
                WCV1.Cells[4 + iMon, n].FormatStyle.FontColor := clSilver;
          end;
        end;

      // S := S + ExcelMeters.Items[i].DesignName + #9 + vartostr(V[0]) + #13#10;
      Application.ProcessMessages;
    end;
    HtmlViewer1.LoadFromString(WCV2.CrossPage);
    HtmlViewer2.LoadFromString(WCV1.CrossPage);
  finally
    ProgressBar1.Visible := False;
    for i := Low(V) to High(V) do
        VarClear(V[i]);
    SetLength(V, 0);
    WCV1.Free;
    WCV2.Free;
    ShowMessage('��ѯ���');
  end;
end;

procedure TfrmDataCount2.FormCreate(Sender: TObject);
begin
  FMeterSelected := TStringList.Create;
  dtpEnd.Date := Now;
end;

procedure TfrmDataCount2.FormDestroy(Sender: TObject);
begin
  FMeterSelected.Free;
end;

procedure TfrmDataCount2.piCopyToClipboardClick(Sender: TObject);
begin
  with (PopupMenu1.PopupComponent as THtmlViewer) do
  begin
    SelectAll;
    CopyToClipboard;
    sellength := 0;
  end;
end;

end.
