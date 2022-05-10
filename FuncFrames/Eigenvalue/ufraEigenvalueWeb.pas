{ -----------------------------------------------------------------------------
  Unit Name: ufraEigenvalueWeb
  Author:    黄伟
  Date:      14-四月-2017
  Purpose:   本单元从数据库/表中提取监测仪器特征值数据，以HTML表格形式显示在
  嵌入的IE浏览器中，用户可拷贝粘贴到其他软件中。
  History:
    2018-06-14  修改了表格格式，按工程部位拆分了表格
    2018-09-18  增加了查询时间段内特征值的功能，增加了“增量”和“振幅”两项。
  ----------------------------------------------------------------------------- }
{ todo:允许采用分表形式显示特征值数据，可按安装部位进行分组分表 }
{ todo:允许用户选择表格内容，如可选是否有年特征、月特征、当前值、增量、振幅等等。
虽然查询结果是返回全部内容，但是表示的时候允许挑选，以免生成一个巨大表格，还需再编辑 }
{ todo:提供EhGrid显示的特征值，这个组件允许按列排序，这样在分组后再排序是非常有用的 }
unit ufraEigenvalueWeb;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.StrUtils, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.OleCtrls,
  SHDocVw, Vcl.ComCtrls,
  uHJX.Data.Types, uHJX.Intf.Datas, {uHJX.Excel.Meters} uHJX.Classes.Meters,
  uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher, uWebGridCross;

type
  TfraEigenvalueWeb = class(TFrame)
    Panel1: TPanel;
    btnGetEVData: TButton;
    wbEVPage: TWebBrowser;
    GroupBox1: TGroupBox;
    optLast: TRadioButton;
    optSpecialDate: TRadioButton;
    dtpStart: TDateTimePicker;
    rdgMeterOption: TRadioGroup;
    dtpEnd: TDateTimePicker;
    ProgressBar1: TProgressBar;
    grpEVItemSelect: TGroupBox;
    chkHistoryEV: TCheckBox;
    chkYearEV: TCheckBox;
    chkMonthEV: TCheckBox;
    chkLastData: TCheckBox;
    procedure btnGetEVDataClick(Sender: TObject);
    procedure wbEVPageBeforeNavigate2(ASender: TObject; const pDisp: IDispatch; const URL, Flags,
      TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
  private
        { Private declarations }
    FIDList  : TStrings; // 仪器列表
    FLoadding: Boolean;
    procedure _GetTitleRowStr(ARow: Integer; var V: array of Variant);
    procedure _SetGrid(AW: TWebCrossView);
  public
        { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
        // 取回第一个物理量的特征值
    procedure GetFirstEVDatas(IDList: string);
        // 取回仪器数据定义中具备特征值的数据的特征值
    procedure GetEVDatas(IDList: string);
  end;

implementation

uses
  uWBLoadHTML, uWeb_DataSet2HTML;
{$R *.dfm}


const
    { 注：这里的CSS设置使得表格呈现细线边框 }
    { 针对表格的表头、单元格使用了CSS定义 }
  htmPageCode2 = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10
    + '<html>'#13#10
    + '<head>'#13#10
    + '<meta http-equiv="Content-Type" content="text/html; charset=GB2312" />'#13#10
    + '<style type="text/css">'#13#10
    + '.DataGrid {border:1px solid #1F4E79;border-width:1px 1px 1px 1px;margin:1px 1px 1px 1px;border-collapse:collapse}'#13#10
    + '.thStyle {font-size: 8pt; font-family: Consolas; color: #000000; padding:3px;border:1px solid #1F4E79}'#13#10
    + '.tdStyle {font-size: 8pt; font-family: Consolas; color: #000000; background-color:#FFFFFF;empty-cells:show;'
    // #F7F7F7
    + '          border:1px solid #1F4E79; padding:3px}'#13#10
    + '.CaptionStyle {font-family:黑体;font-size: 9pt;color: #000000; padding:3px;border:1px solid #1F4E79; background-color:#FFFF99}'#13#10
    + '</style>'#13#10
    + '</head>'#13#10
    + '<body>'#13#10
    + '@PageContent@'#13#10
    + '</body>'#13#10
    + '</html>';

procedure TfraEigenvalueWeb.btnGetEVDataClick(Sender: TObject);
var
  S  : String;
  IFD: IFunctionDispatcher;

  procedure SelAll;
  var
    i: Integer;
  begin
    S := '';
    ExcelMeters.SortByPosition;
    for i := 0 to ExcelMeters.Count - 1 do
    begin
      if S = '' then
          S := ExcelMeters.Items[i].DesignName
      else
          S := S + #13#10 + ExcelMeters.Items[i].DesignName;
    end;
  end;

begin
  if (chkHistoryEV.Checked or chkYearEV.Checked or chkMonthEV.Checked) = False then
  begin
    ShowMessage('你总得选择一个特征值时段，比如历史、年、月等，不选就不查！');
    Exit;
  end;

  if rdgMeterOption.ItemIndex = 0 then
      SelAll
  else if IAppServices.FuncDispatcher <> nil then
  begin
    IFD := IAppServices.FuncDispatcher as IFunctionDispatcher;
    if IFD.HasProc('PopupMeterSelector') then
    begin
      IFD.CallFunction('PopupMeterSelector', FIDList);
      S := FIDList.Text;
    end
    else
        SelAll;
  end
  else
      SelAll;

  Screen.Cursor := crHourGlass;
  try
    GetEVDatas(S);
  finally
    Screen.Cursor := crDefault;
    ProgressBar1.Visible := False;
  end;
end;

constructor TfraEigenvalueWeb.Create(AOwner: TComponent);
begin
  inherited;
  FIDList := tstringlist.Create;
  dtpEnd.Date := Now;
end;

destructor TfraEigenvalueWeb.Destroy;
begin
  FIDList.Free;
  inherited;
end;

procedure TfraEigenvalueWeb._GetTitleRowStr(ARow: Integer; var V: array of Variant);
var
  i, iCol: Integer;
begin
    // SetLength(V, 15);
  // 首行标题
  if ARow = 1 then
  begin
        // V[0] := '安装部位';
        // V[1] := '仪器类型';
    V[0] := '设计编号';
    V[1] := '物理量';
    i := 2;
    if chkHistoryEV.Checked then
    begin
      for iCol := i to i + 5 do V[iCol] := '历史特征值';
      Inc(i, 6);
    end;

    if chkYearEV.Checked then
    begin
      for iCol := i to i + 5 do V[iCol] := '年特征值';
      Inc(i, 6);
    end;

    if chkMonthEV.Checked then
    begin
      for iCol := i to i + 5 do V[iCol] := '月特征值';
      Inc(i, 6);
    end;

    if chkLastData.Checked then
    begin
      for iCol := i to i + 1 do V[iCol] := '当前值';
      Inc(i, 2);
    end;
  end
  else // 第二行标题
  begin
    V[0] := '设计编号';
    V[1] := '物理量';
    i := 2;
    if chkHistoryEV.Checked then
    begin
      V[i] := '最大值';
      V[i + 1] := '最大值日期';
      V[i + 2] := '最小值';
      V[i + 3] := '最小值日期';
      V[i + 4] := '增量';
      V[i + 5] := '变幅';
      Inc(i, 6);
    end;

    if chkYearEV.Checked then
    begin
      V[i] := '年最大值';
      V[i + 1] := '最大值日期';
      V[i + 2] := '年最小值';
      V[i + 3] := '最小值日期';
      V[i + 4] := '年增量';
      V[i + 5] := '年变幅';
      Inc(i, 6);
    end;

    if chkMonthEV.Checked then
    begin
      V[i] := '月最大值';
      V[i + 1] := '最大值日期';
      V[i + 2] := '月最小值';
      V[i + 3] := '最小值日期';
      V[i + 4] := '月增量';
      V[i + 5] := '月变幅';
      Inc(i, 6);
    end;

    if chkLastData.Checked then
    begin
      V[i] := '当前值';
      V[i + 1] := '观测日期';
      Inc(i, 2);
    end;
  end;
end;

procedure TfraEigenvalueWeb._SetGrid(AW: TWebCrossView);
var
  V : array of Variant;
  i : Integer;
  CC: Integer; // ColCount
  S : String;
begin
  AW.TitleRows := 2;
  CC := 2; // 最起码有头两列设计编号和物理量名称2020-10-10
  // 2020-10-10 以下代码根据用户选择的查询项设置列数
  if chkHistoryEV.Checked then Inc(CC, 6);
  if chkYearEV.Checked then Inc(CC, 6);
  if chkMonthEV.Checked then Inc(CC, 6);
  if chkLastData.Checked then Inc(CC, 2);

  // AW.ColCount := { 16 } 22; // 2018-09-18 增加了增量和振幅
  AW.ColCount := CC;
  AW.ColHeader[0].AllowColSpan := True;
  SetLength(V, CC);
  // 设置表头首行
  _GetTitleRowStr(1, V);
  AW.AddRow(V);
  // 设置表头第二行
  _GetTitleRowStr(2, V);
  AW.AddRow(V);

  for i := 2 to CC - 1 do
  begin
    S := AW.Cells[i, 1].StrValue; // 取得标题第二行内容；
    if ((Pos('值', S) > 0) and (Pos('日期', S) = 0)) or (Pos('增量', S) > 0) or (Pos('变幅', S) > 0) then
        AW.ColHeader[i].Align := taRightJustify
    else
        AW.ColHeader[i].Align := tacenter;
    (*
    case i of
      2, 4, 6, 7, 8, 10, 12, 13, 14, 16, 18, 19, 20:
        AW.ColHeader[i].Align := taRightJustify;
    else
      AW.ColHeader[i].Align := taCenter;
    end;
 *)
  end;

    // WCV.AddCaptionRow(V);
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetFirstEVDatas
  Description: 本方法仅返回第一个物理量的特征值(已废弃！！！！！）
  ----------------------------------------------------------------------------- }
procedure TfraEigenvalueWeb.GetFirstEVDatas(IDList: string);
var
  i, j: Integer;
    // EVData: PEVDataStru;
  Meter: TMeterDefine;
  WCV  : TWebCrossView;
  V    : array of Variant;
  D    : TDoubleDynArray;
begin
  FIDList.Text := IDList;
  if FIDList.Count = 0 then
      Exit;

  WCV := TWebCrossView.Create;
  _SetGrid(WCV);
  SetLength(V, 16);
  try
    for i := 0 to FIDList.Count - 1 do
      if IHJXClientFuncs.GetEVData(FIDList.Strings[i], D) then
      begin
        Meter := ExcelMeters.Meter[FIDList.Strings[i]];
                // V[0] := Meter.PrjParams.Position;
                // V[1] := Meter.Params.MeterType;
        V[0] := FIDList.Strings[i];
        V[1] := Meter.PDDefine[0].Name;
        for j := 0 to 13 do
        begin
          if j mod 2 = 1 then
              V[j + 2] := FormatDateTime('yyyy-mm-dd', FloatToDateTime(D[j]))
          else
              V[j + 2] := D[j];
        end;
        WCV.AddRow(V);
      end;
    WB_LoadHTML(wbEVPage, WCV.CrossPage);
  finally
    WCV.Free;
    SetLength(V, 0);
  end;
end;

procedure TfraEigenvalueWeb.wbEVPageBeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  const URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
begin
    // 加载特征值页面时，不处理跳转链接事件
  if FLoadding then
      Exit;

    { TODO -ohw -c特征值 : 在这里处理用户点击仪器编号链接事件 }
    // showmessage(vartostr(URL));
  Cancel := True;
end;

procedure TfraEigenvalueWeb.GetEVDatas(IDList: string);
var
  i, j   : Integer; // 循环量
  iCol   : Integer;
  EVDatas: PEVDataArray;
  Meter  : TMeterDefine;
  WCV    : TWebCrossView;
  V      : array of Variant;
  page   : string;
  Body   : string;
  sPos   : string;
  sType  : string;
  bGet   : Boolean;
  S      : string;
  ErrMsg:string;
begin
  FIDList.Text := IDList;
  if FIDList.Count = 0 then
      Exit;

  ProgressBar1.Min := 1;
  ProgressBar1.Max := FIDList.Count;
  ProgressBar1.Position := 1;
  ProgressBar1.Visible := True;

  IHJXClientFuncs.SessionBegin;
  IHJXClientFuncs.ClearErrMsg;
  errmsg:='';

  WCV := TWebCrossView.Create;

  _SetGrid(WCV);
    // SetLength(V, 16);
  SetLength(V, wcv.ColCount); // 2018-09-18 增加“增量”，“振幅”两项

  Body := '<H2>观测数据特征值表</H2>';
  try
    for i := 0 to FIDList.Count - 1 do
    begin
      ProgressBar1.Position := i + 1;

      if optLast.Checked then
          bGet := IHJXClientFuncs.GetEVDatas(FIDList.Strings[i], EVDatas)
      else
          bGet := IHJXClientFuncs.GetEVDataInPeriod(FIDList.Strings[i], dtpStart.Date,
          dtpEnd.Date, EVDatas);

      if bGet then
      begin
        Meter := ExcelMeters.Meter[FIDList.Strings[i]];
        if i = 0 then
        begin
          sPos := Meter.PrjParams.Position;
          sType := Meter.Params.MeterType;
          Body := Body + '<h3>' + sPos + '监测仪器</h3>';
          WCV.AddCaptionRow([sType]);
        end
        else
        begin
          if Meter.PrjParams.Position <> sPos then
          begin
            sPos := Meter.PrjParams.Position;
            sType := Meter.Params.MeterType;
            Body := Body + WCV.CrossGrid;
            Body := Body + '<h3>' + sPos + '监测仪器</h3>';
            WCV.Reset;
            _SetGrid(WCV);
            WCV.AddCaptionRow([sType]);
          end;
        end;

        if Meter.Params.MeterType <> sType then
        begin
          sType := Meter.Params.MeterType;
          WCV.AddCaptionRow([sType]);
        end;

        if Length(EVDatas) > 0 then
        begin
          for j := Low(EVDatas) to High(EVDatas) do
          begin
          // V[0] := Meter.PrjParams.Position;
          // V[1] := Meter.Params.MeterType;
          { TODO -ohw -c特征值 : 仪器链接应该可选 }
            S := FIDList.Strings[i];
                        // V[0] := Format('<a href="Meter:%s">%s</a>', [S, S]);
            V[0] := FIDList.Strings[i];
            V[1] := Meter.PDDefine[EVDatas[j].PDIndex].Name;
                        // 添加各项
            with EVDatas[j]^ do
            begin
              iCol := 2;
              if chkHistoryEV.Checked then
              begin
                V[iCol] := Lifeev.MaxValue;
                V[iCol + 1] := FormatDateTime('yyyy-mm-dd', Lifeev.MaxDate);
                V[iCol + 2] := Lifeev.MinValue;
                V[iCol + 3] := FormatDateTime('yyyy-mm-dd', Lifeev.MinDate);
                V[iCol + 4] := Lifeev.Increment;
                V[iCol + 5] := Lifeev.Amplitude;
                Inc(iCol, 6);
              end;

              if chkYearEV.Checked then
              begin
                V[iCol] := YearEV.MaxValue;
                V[iCol + 1] := FormatDateTime('yyyy-mm-dd', YearEV.MaxDate);
                V[iCol + 2] := YearEV.MinValue;
                V[iCol + 3] := FormatDateTime('yyyy-mm-dd', YearEV.MinDate);
                V[iCol + 4] := YearEV.Increment;
                V[iCol + 5] := YearEV.Amplitude;
                Inc(iCol, 6);
              end;

              if chkMonthEV.Checked then
              begin
                V[iCol] := MonthEV.MaxValue;
                V[iCol + 1] := FormatDateTime('yyyy-mm-dd', MonthEV.MaxDate);
                V[iCol + 2] := MonthEV.MinValue;
                V[iCol + 3] := FormatDateTime('yyyy-mm-dd', MonthEV.MinDate);
                V[iCol + 4] := MonthEV.Increment;
                V[iCol + 5] := MonthEV.Amplitude;
                Inc(iCol, 6)
              end;

              if chkLastData.Checked then
              begin
                V[iCol] := CurValue;
                V[iCol + 1] := FormatDateTime('yyyy-mm-dd', CurDate);
              end;
            end;
            WCV.AddRow(V);
          end;
        end;
                // V[0]  := Meter.PrjParams.Position;
                // V[1]  := Meter.Params.MeterType;
                // V[2]  := FIDList.Strings[i];
                // v[3] := meter.PDDefine[0].Name;
                // for j := 0 to 13 do
                // begin
                // if j mod 2 = 1 then
                // V[j + 4] := FormatDateTime('yyyy-mm-dd', FloatToDateTime(D[j]))
                // else
                // V[j + 4] := D[j];
                // end;
      end;
      IAppServices.ProcessMessages;
    end;
    Body := Body + WCV.CrossGrid;
    page := StringReplace(htmPageCode2, '@PageTitle@', '观测数据特征值表', []);
    page := StringReplace(page, '@PageContent@', Body, []);
        // WB_LoadHTML(wbEVPage, WCV.CrossPage);
    FLoadding := True;
    WB_LoadHTML(wbEVPage, page);
    FLoadding := False;
  finally
    WCV.Free;
    SetLength(V, 0);
    if Length(EVDatas) > 0 then
    begin
      for i := Low(EVDatas) to High(EVDatas) do
        try
          Dispose(EVDatas[i]);
        except
        end;
      SetLength(EVDatas, 0);
    end;
    ProgressBar1.Visible := False;

    ErrMsg := IHJXClientFuncs.ErrorMsg;
    if ErrMsg <> '' then showmessage('查询过程中发现以下错误：'#13#10 + ErrMsg);
    IHJXClientFuncs.ClearErrMsg;
  end;

end;

end.
