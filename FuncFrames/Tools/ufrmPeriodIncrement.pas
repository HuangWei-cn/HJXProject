{ -----------------------------------------------------------------------------
 Unit Name: ufrmPeriodIncrement
 Author:    黄伟
 Date:      29-九月-2020
 Purpose:   查询指定时间段内的周期增量，如月增量、年增量、季度增量等
 History:
----------------------------------------------------------------------------- }

unit ufrmPeriodIncrement;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.OleCtrls,
  SHDocVw,
  uHJX.Intf.AppServices, uHJX.IntfImp.AppServices, uHJX.Intf.Datas, uHJX.Excel.DataQuery,
  uHJX.Classes.Meters, uHJX.Data.Types, uHJX.Excel.IO,
  uWebGridCross, uWBLoadHTML;

type
  TfrmPeriodIncrement = class(TForm)
    pnlFunc: TPanel;
    WB: TWebBrowser;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    edtStartDay: TEdit;
    updStartDay: TUpDown;
    radMonth: TRadioButton;
    radYear: TRadioButton;
    dtpStartDate: TDateTimePicker;
    dtpEndDate: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    btnQuery: TButton;
    Label3: TLabel;
    GroupBox3: TGroupBox;
    radHGrid: TRadioButton;
    radVGrid: TRadioButton;
    radWeak: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WBBeforeNavigate2(ASender: TObject; const pDisp: IDispatch; const URL, Flags,
      TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
  private
    { Private declarations }
    WCV: TWebCrossView;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
  end;

var
  frmPeriodIncrement: TfrmPeriodIncrement;

implementation

uses
  ufrmMeterSelector, ufrmIncBarGraph;
{$R *.dfm}


const
    { 注：这里的CSS设置使得表格呈现细线边框 }
    { 针对表格的表头、单元格使用了CSS定义 }
  htmPageCode2 = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10
    + '<html>'#13#10
    + '<head>'#13#10
    + '<meta http-equiv="Content-Type" content="text/html; charset=GB2312" />'#13#10
    + '<style type="text/css">'#13#10
    + '.DataGrid {border:1px solid #1F4E79;border-width:1px 1px 1px 1px;margin:0px 0px 0px 0px;border-collapse:collapse}'#13#10
    + '.thStyle {font-size: 8pt; font-family: Consolas; color: #000000; padding:2px;border:1px solid #1F4E79}'#13#10
    + '.tdStyle {font-size: 8pt; font-family: Consolas; color: #000000; background-color:#FFFFFF;empty-cells:show;'
    // #F7F7F7
    + '          border:1px solid #1F4E79; padding:2px}'#13#10
    + '.CaptionStyle {font-family:黑体;font-size: 9pt;color: #000000; padding:2px;border:1px solid #1F4E79; background-color:#FFFF99}'#13#10
    + '</style>'#13#10
    + '</head>'#13#10
    + '<body>'#13#10
    + '@PageContent@'#13#10
    + '</body>'#13#10
    + '</html>';

procedure TfrmPeriodIncrement.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := 0;
end;

procedure TfrmPeriodIncrement.btnQueryClick(Sender: TObject);
var
  frm          : TfrmMeterSelector;
  MeterList    : TStrings;
  i, iCol, k   : Integer;
  iMeter       : Integer;
  V            : TVariantDynArray;
  iStartDay    : Integer;
  iPeriod      : Integer;
  Body, Page   : String;
  sType, sMeter: string; // sType为仪器类型，sMeter为生成的仪器数据HTML代码
  Meter        : TMeterDefine;
  procedure __ClearValues;
  var
    ii: Integer;
  begin
    if Length(V) > 0 then
      for ii := Low(V) to High(V) do
          VarClear(V[ii]);
    SetLength(V, 0);
  end;

  procedure __SetWebGrid;
  var
    ii: Integer;
  begin
    WCV.Reset;
    WCV.ColCount := 10;
    WCV.TitleRows := 1;
    WCV.AddRow;
    WCV.Cells[0, 0].Value := '时间段';
    WCV.Cells[1, 0].Value := '起始日期';
    WCV.Cells[2, 0].Value := '截止日期';
    WCV.Cells[3, 0].Value := '起始测值';
    WCV.Cells[4, 0].Value := '截止测值';
    WCV.Cells[5, 0].Value := '增量';
    WCV.Cells[6, 0].Value := '时段最大值';
    WCV.Cells[7, 0].Value := '时段最小值';
    WCV.Cells[8, 0].Value := '时段变幅';
    WCV.Cells[9, 0].Value := '备注';
    for ii := 3 to 8 do WCV.ColHeader[ii].Align := taRightJustify;
  end;
  /// 设置横向表格的表头
  procedure __SetVertGridHead;
  var
    ii: Integer;
  begin
    WCV.ColCount := Length(V) + 4; // 2021-11-22 原本是增加1列，现在增加了起始截至测值和总增量3列;
    WCV.TitleRows := 2;
    WCV.AddRow;
    // 横向表格表头的第一单元格为观测量，第一列
    WCV.Cells[0, 0].Value := '观测量';
    WCV.Cells[1, 0].Value := '观测值';
    WCV.Cells[2, 0].Value := '观测值';
    for ii := Low(V) to High(V) do
        WCV.Cells[ii + 3, 0].Value := '增量';
    WCV.Cells[High(V) + 4, 0].Value := '期间总增量';

    // 横向表格表头第二行
    WCV.AddRow;
    // 2021-11-22 新加
    WCV.Cells[0, 1].Value := '观测量';
    WCV.Cells[1, 1].Value := FormatDateTime('yyyy-mm-dd', VarToDateTime(V[Low(V)][1])); // '起始日期';
    WCV.Cells[2, 1].Value := FormatDateTime('yyyy-mm-dd', VarToDateTime(V[high(V)][2])); // '截止截止';
    WCV.Cells[High(V) + 4, 1].Value := '期间总增量';

    WCV.ColHeader[1].Align := taRightJustify;
    WCV.ColHeader[2].Align := taRightJustify;
    WCV.ColHeader[High(V) + 4].Align := taRightJustify;
    WCV.ColHeader[0].ColumnFormat.BGColor := clGreen;
    WCV.ColHeader[1].ColumnFormat.BGColor := clWebKhaki;
    WCV.ColHeader[2].ColumnFormat.BGColor := clWebKhaki;
    wcv.ColHeader[High(v)+4].ColumnFormat.BGColor :=clWebForestGreen;

    // 横向表格的表头其余表格为时间段
    for ii := Low(V) to High(V) do
    begin
      WCV.Cells[ii + 3, 1].Value := V[ii][0];
      WCV.ColHeader[ii + 3].Align := taRightJustify;
      WCV.ColHeader[ii + 1].ColumnFormat.BGColor := clWebLightGreen;
    end;
  end;

  function __GetInc(V1, V2: Variant): Variant;
  begin
    Result := '';
    if VarIsNumeric(V1) and VarIsNumeric(V2) then Result := V2 - V1;
  end;

begin
  WB.Navigate('about:blank');
  MeterList := TStringList.Create;
  frm := TfrmMeterSelector.Create(Self);
  frm.ShowModal;
  frm.GetSelected(MeterList);
  frm.Release;
  if MeterList.Count = 0 then exit;
  Page := htmPageCode2;
  iStartDay := updStartDay.Position;
  if radMonth.Checked then iPeriod := 0
  else if radYear.Checked then iPeriod := 1
  else if radWeak.Checked then iPeriod := 3;

  IAppServices.ClientDatas.SessionBegin;
  for iMeter := 0 to MeterList.Count - 1 do
  begin
    Meter := excelmeters.Meter[MeterList[iMeter]];
    sType := Meter.Params.MeterType;
    sMeter := '<H3>' + sType + '<a href="popgraph:' + Meter.DesignName + '">' + Meter.DesignName +
      '</a>月增量表</H3>'#13#10;
    WCV.Reset;
    // 对每一个特征值进行查询
    for k := 0 to Meter.PDDefines.Count - 1 do
    begin
      if Meter.PDDefines.Items[k].HasEV then
      begin
        { if IAppServices.ClientDatas.GetPeriodIncrement(MeterList[iMeter], k, dtpStartDate.Date,
          dtpEndDate.Date, V) then }
        if IAppServices.ClientDatas.GetPeriodIncrement(MeterList[iMeter], k, dtpStartDate.Date,
          dtpEndDate.Date, V, iStartDay, iPeriod) then
        begin
          /// 对于竖向显示的数据表格，每一个物理量将用单独的表格进行呈现
          if radVGrid.Checked then
          begin
            sMeter := sMeter + Meter.PDName(k) + #13#10;
            __SetWebGrid;

            for i := Low(V) to High(V) do
            begin
              WCV.AddRow;
              if VarIsArray(V[i]) then
                for iCol := 0 to 9 do
                    WCV.Cells[iCol, i + 1].Value := V[i][iCol];
            end;
            sMeter := sMeter + WCV.CrossGrid + #13#10'<HR>';
          end
          else // 横向显示的表格，所有可作为特征值的量均在相同的表格中
          begin
            if WCV.ColCount = 0 then __SetVertGridHead;
            WCV.AddRow;
            i := WCV.RowCount - 1;                    // 新行号
            WCV.Cells[0, i].Value := Meter.PDName(k); // 数据项名称
            WCV.Cells[1, i].Value := V[low(V)][3];    // 起始测值
            WCV.Cells[2, i].Value := V[high(V)][4];   // 截止测值
            WCV.Cells[WCV.ColCount - 1, i].Value := __GetInc(V[Low(V)][3], V[high(V)][4]);
            for iCol := low(V) to high(V) do
                WCV.Cells[iCol + 3, i].Value := V[iCol][5];
          end;
        end;
      end;
    end;
    if radHGrid.Checked then
        sMeter := sMeter + WCV.CrossGrid + '<hr>';
    __ClearValues;
    Body := Body + sMeter;
  end;
  Page := StringReplace(Page, '@PageContent@', Body, []);
  WB_LoadHTML(WB, Page);
  IAppServices.ClientDatas.SessionEnd;
end;

procedure TfrmPeriodIncrement.FormCreate(Sender: TObject);
begin
  dtpEndDate.Date := Now;
  WCV := TWebCrossView.Create;
end;

procedure TfrmPeriodIncrement.FormDestroy(Sender: TObject);
begin
  WCV.Free;
end;

procedure TfrmPeriodIncrement.WBBeforeNavigate2(ASender: TObject; const pDisp: IDispatch; const URL,
  Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
var
  S, cmd, sName: String;
  i            : Integer;
  iPeriod      : Integer;
begin
  S := VarToStr(URL);

  if radWeak.Checked then
      iPeriod := 3
  else if radMonth.Checked then
      iPeriod := 0
  else if radYear.Checked then
      iPeriod := 1;

  if pos('about', S) > 0 then // 加载空页面
      Cancel := False
  else if pos('popgraph', S) > 0 then
  begin
    i := pos(':', S);
    cmd := Copy(S, 1, i - 1);
    sName := Copy(S, i + 1, Length(S) - 1);
    // ShowMessage('Hot link: ' + s);
    if cmd = 'popgraph' then
        ufrmIncBarGraph.PopupIncBar(sName, -1, iPeriod, updStartDay.Position, dtpStartDate.Date,
        dtpEndDate.Date);
    Cancel := True;
  end;
end;

end.
