{ -----------------------------------------------------------------------------
 Unit Name: ufraQuickViewer
 Author:    黄伟
 Date:      07-六月-2018
 Purpose:   观测数据速览显示单元
    本单元通过检查每只仪器最近两次观测数据变化、月变化，将超过限值的仪器及其
    数据显示出来，同时统计数据增大和减小的数量，了解当前趋势。
 History:
    2018-06-14 增加了显示数据增量的功能，目前尚不能指定日期，但可以过滤掉微小
    变化。
    2020-06-10 增加了使用DBGridEh表格显示增量的功能。不久前还增加了显示最后一条
    记录的功能
----------------------------------------------------------------------------- }

unit ufraQuickViewer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, HTMLUn2, HtmlView, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.WinXCtrls, Vcl.Menus, Vcl.OleCtrls, SHDocVw, MemTableDataEh,
  Data.DB, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, DataDriverEh,
  Datasnap.DBClient, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, MemTableEh, System.Actions,
  Vcl.ActnList;

type
  TfraQuickViewer = class(TFrame)
    Panel1: TPanel;
    HtmlViewer: THtmlViewer;
    btnCreateQuickView: TButton;
    pnlProgress: TPanel;
    ProgressBar: TProgressBar;
    Label1: TLabel;
    lblDesignName: TLabel;
    lblProgress: TLabel;
    btnShowIncrement: TButton;
    chkUseFilter: TCheckBox;
    PopupMenu1: TPopupMenu;
    miCopy: TMenuItem;
    dlgPrint: TPrintDialog;
    miPrint: TMenuItem;
    dlgSave: TSaveDialog;
    miSave: TMenuItem;
    N1: TMenuItem;
    GroupBox1: TGroupBox;
    chkTableByType: TCheckBox;
    chkUseIE: TCheckBox;
    chkAllMeters: TCheckBox;
    wbViewer: TWebBrowser;
    btnSpecificDates: TButton;
    pnlDateSelector: TPanel;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    dtp1: TDateTimePicker;
    dtp2: TDateTimePicker;
    cmbDate1Opt: TComboBox;
    cmbDate2Opt: TComboBox;
    btnDateSelected: TButton;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    chkSimpleSDGrid: TCheckBox;
    rdgQueryType: TRadioGroup;
    MemTableEh1: TMemTableEh;
    dsDatas: TDataSource;
    cdsDatas: TClientDataSet;
    DataSetDriverEh1: TDataSetDriverEh;
    DBGridEh1: TDBGridEh;
    rdgPresentType: TRadioGroup;
    popGrid: TPopupMenu;
    piShowTrendLine: TMenuItem;
    piShowDataGrid: TMenuItem;
    N3: TMenuItem;
    piSetFont: TMenuItem;
    ActionList1: TActionList;
    actShowTrendLine: TAction;
    actShowDatas: TAction;
    actSetGridFont: TAction;
    N2: TMenuItem;
    piIncFontSize: TMenuItem;
    piDecFontSize: TMenuItem;
    dlgFont: TFontDialog;
    actIncFontSize: TAction;
    actDecFontSize: TAction;
    actOpenDataSheet: TAction;
    piOpenDataSheet: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    actCopytoClipboard: TAction;
    N6: TMenuItem;
    piCollapse: TMenuItem;
    piCollapseThisLevel: TMenuItem;
    piCollapseSubLevels: TMenuItem;
    piCollapseAllLevel: TMenuItem;
    procedure btnCreateQuickViewClick(Sender: TObject);
    procedure btnShowIncrementClick(Sender: TObject);
    procedure HtmlViewerHotSpotClick(Sender: TObject; const SRC: string; var Handled: Boolean);
    procedure miCopyClick(Sender: TObject);
    procedure miPrintClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure wbViewerBeforeNavigate2(ASender: TObject; const pDisp: IDispatch; const URL, Flags,
      TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
    procedure btnSpecificDatesClick(Sender: TObject);
    procedure btnDateSelectedClick(Sender: TObject);
    procedure popGridPopup(Sender: TObject);
    procedure actShowTrendLineExecute(Sender: TObject);
    procedure actShowDatasExecute(Sender: TObject);
    procedure actSetGridFontExecute(Sender: TObject);
    procedure actIncFontSizeExecute(Sender: TObject);
    procedure actDecFontSizeExecute(Sender: TObject);
    procedure actOpenDataSheetExecute(Sender: TObject);
    procedure actCopytoClipboardExecute(Sender: TObject);
    procedure piCollapseThisLevelClick(Sender: TObject);
    procedure piCollapseSubLevelsClick(Sender: TObject);
    procedure piCollapseAllLevelClick(Sender: TObject);
  private
    { Private declarations }
    FMeterList: TStrings;
    // 创建最新增量数据集
    procedure _CreateIncrementDataSet;
    // 创建指定间隔增量数据集
    procedure _Create2DayIncDataSet;
    // 设置DBGridEh的颜色等
    procedure _SetGridPresent;
    { 显示两个指定日期的数据，及其增量 }
    procedure ShowSpecificDatesData;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { 显示观测情况速览 }
    procedure ShowQuickView;
    { 显示观测数据增量，若UseFilter = False则显示全部仪器的数据增量，否则只显示超限的 }
    procedure ShowDataIncrement(UseFilter: Boolean = False);
    { 显示最新的观测数据，每支仪器一条记录，按类型分表 }
    procedure ShowLastDatas;
  end;

implementation

uses
  uHJX.Data.Types, uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher, uHJX.Intf.Datas,
  uHJX.Classes.Meters, uHJX.Excel.IO,
  uWebGridCross, uWBLoadHTML, DBGridEhImpExp;
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

  FN_INCDATA: array [0 .. 8] of string = ('安装部位', '仪器类型', '设计编号', '物理量', '观测日期', '间隔天数', '当前测值',
    '最新增量', '30天增量');
  FN_2DDATA: array [0 .. 10] of string = ('安装部位', '仪器类型', '设计编号', '物理量', '起始日期', '起始测值', '截止日期',
    '截止测值', '间隔天数', '增量', '日均增量');

var
  MaxDeltaDDWY: Double = 0.1;
  MaxDeltaMS  : Double = 5;
  MaxDeltaMG  : Double = 5;
  MaxDeltaSY  : Double = 1;

procedure TfraQuickViewer._CreateIncrementDataSet;
var
  i : Integer;
  DF: TFieldDef;
begin
  if MemTableEh1.Active then MemTableEh1.Close;

  if cdsDatas.Active then cdsDatas.Close;
  // for i := 0 to cdsdatas.FieldDefs.Count -1 do cdsDatas.FieldDefs[i].Free;
  cdsDatas.FieldDefs.Clear;
  // for i := 0 to cdsdatas.IndexDefs.Count -1 do cdsdatas.IndexDefs[i].Free;
  cdsDatas.IndexDefs.Clear;

  // 安装部位
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Position';
  DF.DataType := ftstring;
  DF.DisplayName := '安装部位';
  // 仪器类型
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'MeterType';
  DF.DataType := ftstring;
  DF.DisplayName := '仪器类型';
  // 设计编号
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'DesignName';
  DF.DataType := ftstring;
  DF.DisplayName := '设计编号';
  // 物理量
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'PDName';
  DF.DataType := ftstring;
  DF.DisplayName := '物理量';
  // 观测日期
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'DTScale';
  DF.DataType := ftDateTime;
  DF.DisplayName := '观测日期';
  // 间隔天数
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'InteralDays';
  DF.DataType := ftFloat;
  DF.DisplayName := '间隔天数';
  // 当前测值
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Data';
  DF.DataType := ftFloat;
  DF.DisplayName := '当前测值';
  // 最新增量
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Increment';
  DF.DataType := ftFloat;
  DF.DisplayName := '最新增量';
  // 最近30天增量
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Inc30Days';
  DF.DataType := ftFloat;
  DF.DisplayName := '最近30天增量';

  // 添加索引
  cdsDatas.IndexDefs.Add('IdxPos', 'Position', []);
  cdsDatas.IndexDefs.Add('IdxTyp', 'MeterType', []);
  cdsDatas.IndexDefs.Add('IdxDgn', 'DesignName', []);
  // cdsDatas.IndexDefs.Add('IdxPos','Position',[]);
  cdsDatas.CreateDataSet;
  for i := 0 to cdsDatas.Fields.Count - 1 do
  begin
    cdsDatas.Fields[i].DisplayLabel := FN_INCDATA[i]; // cdsDatas.Fields[i].DisplayName;
    if cdsDatas.Fields[i].DataType = ftFloat then
      (cdsDatas.Fields[i] as TNumericField).DisplayFormat := '0.00';
  end;
end;

procedure TfraQuickViewer._Create2DayIncDataSet;
var
  i : Integer;
  DF: TFieldDef;
begin
  if MemTableEh1.Active then MemTableEh1.Close;
  if cdsDatas.Active then cdsDatas.Close;
  cdsDatas.FieldDefs.Clear;
  cdsDatas.IndexDefs.Clear;
  // 1安装部位
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Position';
  DF.DataType := ftstring;
  // 2仪器类型
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'MeterType';
  DF.DataType := ftstring;
  // 3设计编号
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'DesignName';
  DF.DataType := ftstring;
  // 4物理量
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'PDName';
  DF.DataType := ftstring;
  // 5起始日期
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'StartDate';
  DF.DataType := ftDateTime;
  // 6测值
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Data1';
  DF.DataType := ftFloat;
  // 7截止日期
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'EndDate';
  DF.DataType := ftDateTime;
  // 8测值
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Data2';
  DF.DataType := ftFloat;
  // 9间隔天数
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'IntralDays';
  DF.DataType := ftFloat;
  // 10增量
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Increment';
  DF.DataType := ftFloat;
  // 11变化率
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Rate';
  DF.DataType := ftFloat;
  for i := 0 to cdsDatas.FieldDefs.Count - 1 do
      cdsDatas.FieldDefs[i].DisplayName := FN_2DDATA[i];

  cdsDatas.CreateDataSet;
  for i := 0 to cdsDatas.Fields.Count - 1 do
  begin
    cdsDatas.Fields[i].DisplayLabel := FN_2DDATA[i];
    if cdsDatas.Fields[i].DataType = ftFloat then
      (cdsDatas.Fields[i] as TNumericField).DisplayFormat := '0.00';
  end;
end;

procedure TfraQuickViewer._SetGridPresent;
var
  i: Integer;
  S: String;
  procedure __SetColumnColor(Clmn: TColumnEh; BgColor, FtColor: TColor);
  begin
    Clmn.Color := BgColor;
    Clmn.Font.Color := FtColor;
  end;

begin
  // 先设置共有的类型
  if DBGridEh1.FieldColumns['Position'] <> nil then
      __SetColumnColor(DBGridEh1.FieldColumns['Position'], clWebWheat, clBlack);
  if DBGridEh1.FieldColumns['MeterType'] <> nil then
      __SetColumnColor(DBGridEh1.FieldColumns['MeterType'], clWebLemonChiffon, clBlack);
  if DBGridEh1.FieldColumns['DesignName'] <> nil then
      __SetColumnColor(DBGridEh1.FieldColumns['DesignName'], clWhite, clBlack);
  if DBGridEh1.FieldColumns['PDName'] <> nil then
      __SetColumnColor(DBGridEh1.FieldColumns['PDName'], clWhite, clWebGreen);
  if DBGridEh1.FieldColumns['DesignName'] <> nil then
      __SetColumnColor(DBGridEh1.FieldColumns['DesignName'], clWhite, clBlack);

  for i := 0 to DBGridEh1.Columns.Count - 1 do
  begin
    S := DBGridEh1.Columns[i].FieldName;
    if (S = 'DTScale') or (pos('Date', S) > 0) then
        __SetColumnColor(DBGridEh1.Columns[i], clWhite, clWebSlateBlue)
    else if pos('Data', S) > 0 then
        __SetColumnColor(DBGridEh1.Columns[i], clWebPaleGreen, clBlack)
    else if S = 'IntralDays' then
        __SetColumnColor(DBGridEh1.Columns[i], clWhite, clWebOlive)
    else if S = 'Increment' then
        __SetColumnColor(DBGridEh1.Columns[i], clWebPink, clBlack)
    else if S = 'Inc30Days' then
        __SetColumnColor(DBGridEh1.Columns[i], clWebPlum, clBlack)
    else if S = 'Rate' then
        __SetColumnColor(DBGridEh1.Columns[i], clWebKhaki, clWebSeaGreen);
    { else
        __SetColumnColor(DBGridEh1.Columns[i], clWhite, clBlack); }
    DBGridEh1.Columns[i].OptimizeWidth;
  end;
end;

constructor TfraQuickViewer.Create(AOwner: TComponent);
begin
  inherited;
  dtp2.Date := Now;
  dtp1.Date := Now - 1;
  dtp1.Time := 0;
  dtp2.Time := 0;
  FMeterList := TStringList.Create;
end;

destructor TfraQuickViewer.Destroy;
begin
  FMeterList.Free;
  inherited;
end;

{ -----------------------------------------------------------------------------
  Procedure  : ShowQuickView
  Description: 显示速览内容
----------------------------------------------------------------------------- }
procedure TfraQuickViewer.actCopytoClipboardExecute(Sender: TObject);
begin
  DBGridEh_DoCopyAction(DBGridEh1, True)
end;

procedure TfraQuickViewer.actDecFontSizeExecute(Sender: TObject);
var
  i: Integer;
begin
  if DBGridEh1.Font.Size > 5 then
  begin
    DBGridEh1.Font.Size := DBGridEh1.Font.Size - 1;
    DBGridEh1.TitleFont.Size := DBGridEh1.Font.Size;
    for i := 0 to DBGridEh1.Columns.Count - 1 do
    begin
      DBGridEh1.Columns[i].Font.Size := DBGridEh1.Font.Size;
      DBGridEh1.Columns[i].OptimizeWidth;
    end;
  end;
end;

procedure TfraQuickViewer.actIncFontSizeExecute(Sender: TObject);
var
  i: Integer;
begin
  DBGridEh1.Font.Size := DBGridEh1.Font.Size + 1;
  DBGridEh1.TitleFont.Size := DBGridEh1.Font.Size;
  for i := 0 to DBGridEh1.Columns.Count - 1 do
  begin
    DBGridEh1.Columns[i].Font.Size := DBGridEh1.Font.Size;
    DBGridEh1.Columns[i].OptimizeWidth;
  end;
end;

procedure TfraQuickViewer.actOpenDataSheetExecute(Sender: TObject);
var
  mn: String;
  mt: TMeterDefine;
begin
  if not cdsDatas.Active then
      Exit;
  if IAppServices = nil then
      Exit;
  mn := MemTableEh1.FieldByName('DesignName').AsString;
  mt := ExcelMeters.Meter[mn];
  if mt <> nil then
      TExcelIO.Excel_ShowSheet(mt.DataBook, mt.DataSheet);
end;

procedure TfraQuickViewer.actSetGridFontExecute(Sender: TObject);
var
  i: Integer;
begin
  dlgFont.Font.Assign(DBGridEh1.Font);
  if dlgFont.Execute then
  begin
    DBGridEh1.Font.Assign(dlgFont.Font);
    DBGridEh1.TitleFont.Assign(dlgFont.Font);
    for i := 0 to DBGridEh1.Columns.Count - 1 do
    begin
      DBGridEh1.Columns[i].Font.Assign(dlgFont.Font);
      DBGridEh1.Columns[i].OptimizeWidth;
    end;
  end;
end;

procedure TfraQuickViewer.actShowDatasExecute(Sender: TObject);
var
  mn: String;
begin
  if not cdsDatas.Active then Exit;
  if IAppServices = nil then Exit;
  if IAppServices.FuncDispatcher = nil then Exit;
  mn := MemTableEh1.FieldByName('DesignName').AsString;
  if Trim(mn) = '' then Exit;
  (IAppServices.FuncDispatcher as IFunctionDispatcher).ShowData(mn, nil);
end;

procedure TfraQuickViewer.actShowTrendLineExecute(Sender: TObject);
var
  mn: String;
begin
  if not cdsDatas.Active then Exit;
  if IAppServices = nil then Exit;
  if IAppServices.FuncDispatcher = nil then Exit;
  // mn := cdsDatas.FieldByName('DesignName').AsString;
  mn := MemTableEh1.FieldByName('DesignName').AsString;
  if Trim(mn) = '' then Exit;
  (IAppServices.FuncDispatcher as IFunctionDispatcher).ShowDataGraph(mn, nil);
end;

procedure TfraQuickViewer.btnCreateQuickViewClick(Sender: TObject);
begin
  pnlProgress.Left := (Self.Width - pnlProgress.Width) div 2;
  pnlProgress.Top := (Self.Height - pnlProgress.Height) div 2;
  case rdgQueryType.ItemIndex of
    0: ShowQuickView;
    1: ShowDataIncrement(chkUseFilter.Checked);
    2:
      begin
        pnlDateSelector.Visible := True;
        pnlDateSelector.Left := (Self.Width - pnlDateSelector.Width) div 2;
        pnlDateSelector.Top := (Self.Height - pnlDateSelector.Height) div 2;
      end; // ShowSpecificDatesData;
    3: ShowLastDatas;
  end;
  // ShowQuickView;
end;

procedure TfraQuickViewer.ShowQuickView;
var
  MTList     : TStrings;
  Meter      : TMeterDefine;
  MeterType  : string;
  V1, V2     : TDoubleDynArray;
  iMeter, i  : Integer;
  iMeterCount: Integer;
  iInc, iDec : Integer;
  iOverLine  : Integer;
  WCV        : TWebCrossView;
  Page       : string;
  Body       : string;
    // 判断是否值得显示出来，目前的判断比较僵化，还需要考虑到时间间隔问题，即变化速率
  function _NeedShow: Boolean;
  var
    Delta: Double;
    procedure CountDelta;
    begin
      if Delta > 0 then
          Inc(iInc)
      else
          Inc(iDec);
    end;

  begin
    Result := True;
    if MeterType = '多点位移计' then
    begin
      Delta := V2[1] - V1[1];
            // CountDelta;
      if abs(Delta) < abs(V2[2] - V1[2]) then
          Delta := V2[2] - V1[2];
            // CountDelta;
      if abs(Delta) < abs(V2[3] - V1[3]) then
          Delta := V2[3] - V1[3];
            // CountDelta;
      if abs(Delta) < abs(V2[4] - V1[4]) then
          Delta := V2[4] - V1[4];
      CountDelta;
      if abs(Delta) < MaxDeltaDDWY then
          Result := False;
    end
    else if MeterType = '锚索测力计' then
    begin
      Delta := V2[1] - V1[1];
      CountDelta;
      if abs(Delta) < MaxDeltaMS then
          Result := False;
    end
    else if MeterType = '锚杆应力计' then
    begin
      Delta := V2[1] - V1[1];
      CountDelta;
      if abs(Delta) < MaxDeltaMG then
          Result := False;
    end
    else if MeterType = '渗压计' then
    begin
      Delta := V2[1] - V1[1];
      CountDelta;
      if abs(Delta) < MaxDeltaSY then
          Result := False;
    end
    else if MeterType = '基岩变形计' then
    begin
      Delta := V2[1] - V1[1];
      CountDelta;
      if abs(Delta) < MaxDeltaDDWY then
          Result := False;
    end;
  end;
    // 只显示一次数据
  procedure ShowOneData;
  begin

  end;
    // 显示两次数据
  procedure ShowTwoData;
  var
    DataRow: array of variant;
    i      : Integer;
  begin
        // 如果不值一提就继续下一个
    if not _NeedShow then
        Exit;

    Inc(iOverLine); // 多个超限的

    WCV.Reset;
    WCV.ColCount := Length(V1); //
    WCV.ColHeader[0].Align := taCenter;
    for i := 1 to WCV.ColCount - 1 do
        WCV.ColHeader[i].Align := taRightJustify;

    WCV.TitleRows := 1;
    SetLength(DataRow, WCV.ColCount);
    DataRow[0] := '观测日期';
    for i := 0 to Meter.PDDefines.Count - 1 do
        DataRow[i + 1] := Meter.PDName(i);
    WCV.AddRow(DataRow);
    DataRow[0] := FormatDateTime('yyyy-mm-dd', V1[0]);
    for i := 1 to High(V1) do
        DataRow[i] := V1[i];
    WCV.AddRow(DataRow);

    DataRow[0] := FormatDateTime('yyyy-mm-dd', V2[0]);
    for i := 1 to High(V2) do
        DataRow[i] := V2[i];
    WCV.AddRow(DataRow);
    DataRow[0] := '增量';
    for i := 1 to High(V2) do
        DataRow[i] := V2[i] - V1[i];
    WCV.AddRow(DataRow);
    Body := Body + '<h3>' + Meter.Params.MeterType + '<a href="PopGraph:' +
      Meter.DesignName + '">' + Meter.DesignName + '</a>' + '</h3>' + WCV.CrossGrid;
  end;

begin
  if ExcelMeters.Count = 0 then
      Exit;
    // Body := '';
  Body := '<h2>测值增量超过关注阈值的仪器：</h2>'
    + Format('<div>多点位移计限差:%fmm；锚索测力计限差:%fkN；锚杆应力计限差:%fkN</div>',
    [MaxDeltaDDWY, MaxDeltaMS, MaxDeltaMG]);
  iInc := 0;
  iDec := 0;
  iOverLine := 0;
  MTList := TStringList.Create;
    // 准备仪器列表
  if chkAllMeters.Checked then
    for i := 0 to ExcelMeters.Count - 1 do
        MTList.Add(ExcelMeters.Items[i].DesignName)
  else
  begin
    with IAppServices.FuncDispatcher as IFunctionDispatcher do
    begin
      // 如果能选择部分仪器则
      if HasProc('PopupMeterSelector') then
          CallFunction('PopupMeterSelector', MTList)
      else // 否则选择全部仪器
      begin
        for i := 0 to ExcelMeters.Count - 1 do
            MTList.Add(ExcelMeters.Items[i].DesignName)
      end;
    end;
  end;

  if MTList.Count = 0 then
  begin
    showmessage('没有选择需要查询的仪器，请选择后再查询。');
    Exit;
  end;

  try
    Screen.Cursor := crHourGlass;

    ProgressBar.Max := { ExcelMeters.Count } MTList.Count;
    ProgressBar.Min := 1;
    ProgressBar.Position := 1;
    lblDesignName.Caption := '';
    lblProgress.Caption := '';

    pnlProgress.Visible := True;
    pnlProgress.Left := (Self.Width - pnlProgress.Width) div 2;
    pnlProgress.Top := (Self.Height - pnlProgress.Height) div 2;

    WCV := TWebCrossView.Create;

    for iMeter := 0 to { ExcelMeters.Count } MTList.Count - 1 do
    begin
      // Meter := ExcelMeters.Items[iMeter];
      Meter := ExcelMeters.Meter[MTList.Strings[iMeter]];
      MeterType := Meter.Params.MeterType;

      ProgressBar.Position := iMeter + 1;
      lblDesignName.Caption := Meter.Params.MeterType + Meter.DesignName;
      lblProgress.Caption := Format('正在处理第%d支仪器，共%d支', [iMeter + 1, { ExcelMeters } MTList.Count]);

      IAppServices.ProcessMessages;

      if IAppServices.ClientDatas.GetLastPDDatas(Meter.DesignName, V2) then
      begin
        if IAppServices.ClientDatas.GetLastPDDatasBeforeDate(Meter.DesignName, V2[0], V1)
        then
        begin
          ShowTwoData;
        end
        else
            ShowOneData; // 没有完成这个方法，没有考虑好如何显示单次数据
        Inc(iMeterCount);
      end;
    end;

        // 显示增减数量
    Body := Body + Format('<hr>本次测值增量超过关注阈值的仪器有%d支，其余仪器观测数据变化较小。<br>', [iOverLine]);
    Body := Body + Format('在最近两次观测中，有%d支仪器(传感器)数据增大，有%d支仪器数据减小。', [iInc, iDec]);
    Page := StringReplace(htmPageCode2, '@PageContent@', Body, []);
    if chkUseIE.Checked then
    begin
      wbViewer.Visible := True;
      HtmlViewer.Visible := False;
      wbViewer.Align := alClient;
      WB_LoadHTML(wbViewer, Page);
    end
    else
    begin
      HtmlViewer.Visible := True;
      wbViewer.Visible := False;
      HtmlViewer.Align := alClient;
      HtmlViewer.LoadFromString(Page);
    end;
  finally
    MTList.Free;
    WCV.Free;
    pnlProgress.Visible := False;
    Screen.Cursor := crDefault;
  end;
end;

procedure TfraQuickViewer.wbViewerBeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  const URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
var
  S, cmd, sName: String;
  i            : Integer;
begin
  S := VarToStr(URL);
  if pos('about', S) > 0 then // 加载空页面
      Cancel := False
  else if pos('popgraph', S) > 0 then
  begin
    i := pos(':', S);
    cmd := Copy(S, 1, i - 1);
    sName := Copy(S, i + 1, Length(S) - 1);
    // ShowMessage('Hot link: ' + s);
    if cmd = 'popgraph' then
      (IAppServices.FuncDispatcher as IFunctionDispatcher).PopupDataGraph(sName);
    Cancel := True;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : ShowDataIncrement
  Description: 本方法查询全部仪器在指定时间的观测数据增量及月增量，并在HTMLViewer
  中显示出来。如果UseFilter=True，则过滤掉变化较小的数据，只保留变化大的。
----------------------------------------------------------------------------- }
procedure TfraQuickViewer.btnDateSelectedClick(Sender: TObject);
begin
  pnlDateSelector.Visible := False;
  ShowSpecificDatesData;
end;

procedure TfraQuickViewer.btnShowIncrementClick(Sender: TObject);
begin
  ShowDataIncrement(chkUseFilter.Checked);
end;

{ -----------------------------------------------------------------------------
  Procedure  : btnSpecificDatesClick
  Description: 显示指定日期的两次观测数据，及其增量
----------------------------------------------------------------------------- }
procedure TfraQuickViewer.btnSpecificDatesClick(Sender: TObject);
begin
  pnlDateSelector.Visible := True;
  pnlDateSelector.Left := (Self.Width - pnlDateSelector.Width) div 2;
  pnlDateSelector.Top := (Self.Height - pnlDateSelector.Height) div 2;
end;

{ -----------------------------------------------------------------------------
  Procedure  : HtmlViewerHotSpotClick
  Description: 点击仪器编号超链接，弹出该仪器的过程线或其他类型数据图
----------------------------------------------------------------------------- }
procedure TfraQuickViewer.HtmlViewerHotSpotClick(Sender: TObject; const SRC: string;
  var Handled: Boolean);
var
  cmd, S: string;
  i     : Integer;
begin
    // ShowMessage(src);
  i := pos(':', SRC);
  cmd := Copy(SRC, 1, i - 1);
  S := Copy(SRC, i + 1, Length(SRC) - i);
    // ShowMessage(s);
  if cmd = 'PopGraph' then
    (IAppServices.FuncDispatcher as IFunctionDispatcher).PopupDataGraph(S);;
end;

procedure TfraQuickViewer.miCopyClick(Sender: TObject);
begin
  HtmlViewer.SelectAll;
  HtmlViewer.CopyToClipboard;
  HtmlViewer.SelLength := 0;
end;

procedure TfraQuickViewer.miPrintClick(Sender: TObject);
begin
  with dlgPrint do
    if Execute then
      if PrintRange = prAllPages then
          HtmlViewer.Print(1, 9999)
      else
          HtmlViewer.Print(FromPage, ToPage);
end;

procedure TfraQuickViewer.miSaveClick(Sender: TObject);
var
  strs: TStrings;
begin
  with dlgSave do
    if Execute then
    begin
      strs := TStringList.Create;
      try
        strs.Text := HtmlViewer.DocumentSource;
        strs.SaveToFile(dlgSave.FileName);
      finally
        strs.Free;
      end;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : piCollapseAllLevelClick
  Description: 采用递归收缩所有展开的TreeNode
----------------------------------------------------------------------------- }
procedure TfraQuickViewer.piCollapseAllLevelClick(Sender: TObject);
  procedure _CollapseAll(Node: TGroupDataTreeNodeEh);
  var
    i: Integer;
  begin
    Node.Expanded := False;
    if Node.Count > 0 then
      for i := 0 to Node.Count - 1 do _CollapseAll(Node.Items[i]);
  end;

begin
  _CollapseAll(DBGridEh1.DataGrouping.GroupDataTree.Root);
  DBGridEh1.DataGrouping.GroupDataTree.Root.Expanded := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : piCollapseSubLevelsClick
  Description: 收起本级所有展开
----------------------------------------------------------------------------- }
procedure TfraQuickViewer.piCollapseSubLevelsClick(Sender: TObject);
var
  Nd: TGroupDataTreeNodeEh;
  i : Integer;
begin
  Nd := DBGridEh1.DataGrouping.CurDataNode;
  if Nd.Count > 0 then
    for i := 0 to Nd.Count - 1 do
        Nd.Items[i].Expanded := False;
end;

{ -----------------------------------------------------------------------------
  Procedure  : piCollapseThisLevelClick
  Description: Group Tree收起本级展开节点
----------------------------------------------------------------------------- }
procedure TfraQuickViewer.piCollapseThisLevelClick(Sender: TObject);
begin
  // 先收起选中记录的父节点试试
  if DBGridEh1.DataGrouping.CurDataNode.Parent <> nil then
      DBGridEh1.DataGrouping.CurDataNode.Parent.Expanded := False;
  // DBGridEh1.DataGrouping.GroupDataTree.Collapse(DBGridEh1.DataGrouping.CurDataNode.Parent);
end;

procedure TfraQuickViewer.popGridPopup(Sender: TObject);
begin
  // 判断Grid.DataSet是否Active
  if (popGrid.PopupComponent as TDBGridEh).DataSource.DataSet.Active then
  begin
    piShowTrendLine.Enabled := True;
    piShowDataGrid.Enabled := True;
  end
  else
  begin
    piShowTrendLine.Enabled := False;
    piShowDataGrid.Enabled := False;
  end;
end;

procedure TfraQuickViewer.ShowDataIncrement(UseFilter: Boolean = False);
var
  { MTList: TStrings; }
  Meter : TMeterDefine;
  iMeter: Integer;
  i     : Integer;
  iCount: Integer;
  WCV   : TWebCrossView;
  V     : TVariantDynArray;
  vH    : array of variant;
  Body  : String;
  Page  : String;
  sType : string;
  sPos  : String;
  k     : Integer;     // 特征值项的序号；
  kIdx  : set of Byte; // 特征值序号集合，假设特征值项不超过127个。
  gl    : TGridDataGroupLevelEh;
  procedure ClearValues;
  var
    ii: Integer;
  begin
    SetLength(vH, 0);
    if Length(V) > 0 then
      for ii := 0 to High(V) do
          VarClear(V[ii]);
    SetLength(V, 0);
  end;

  procedure SetGrid;
  var
    ii: Integer;
  begin
    WCV.TitleRows := 1;
    WCV.ColCount := 8;
    WCV.ColHeader[0].AllowColSpan := True;
    WCV.ColHeader[1].AllowColSpan := True;
    WCV.ColHeader[0].AllowRowSpan := True;
    WCV.ColHeader[3].Align := taCenter;
    WCV.ColHeader[4].Align := taCenter;
    for ii := 5 to 7 do
        WCV.ColHeader[ii].Align := taRightJustify;
    SetLength(vH, 8);
    vH[0] := '仪器类型';
    vH[1] := '设计编号';
    vH[2] := '物理量';
    vH[3] := '观测日期';
    vH[4] := '间隔天数';
    vH[5] := '当前测值';
    vH[6] := '最新增量';
    vH[7] := '最近30天增量';
    WCV.AddRow(vH);
  end;

  function IgnoreData(AData: variant; ALimit: Double): Boolean;
  begin
    Result := True;
    if VarIsEmpty(AData) or VarIsNull(AData) then
        Exit;
    if abs(AData) >= ALimit then
        Result := False;
  end;

begin
  HtmlViewer.Clear;
  // 如果WebGrid
  if rdgPresentType.ItemIndex = 0 then
  begin
    DBGridEh1.Visible := False;
    if MemTableEh1.Active then
        MemTableEh1.Close;
    if cdsDatas.Active then
        cdsDatas.Close;
    if chkUseIE.Checked then
    begin
      HtmlViewer.Visible := False;
      wbViewer.Visible := True;
      wbViewer.Align := alClient;
    end
    else
    begin
      HtmlViewer.Visible := True;
      HtmlViewer.Align := alClient;
      wbViewer.Visible := False;
    end;
  end
  else // 否则是EhGrid
  begin
    HtmlViewer.Visible := False;
    wbViewer.Visible := False;
    DBGridEh1.Visible := True;
    DBGridEh1.Align := alClient;
    _CreateIncrementDataSet;
  end;

  { MTList := TStringList.Create; }
  if ExcelMeters.Count = 0 then
      Exit;

  // 准备仪器列表
  if chkAllMeters.Checked then
  begin
    FMeterList.Clear;
    for i := 0 to ExcelMeters.Count - 1 do
        { MTList } FMeterList.Add(ExcelMeters.Items[i].DesignName)
  end
  else
  begin
    with IAppServices.FuncDispatcher as IFunctionDispatcher do
    begin
      // 如果能选择部分仪器则
      if HasProc('PopupMeterSelector') then
          CallFunction('PopupMeterSelector', { MTList } FMeterList)
      else // 否则选择全部仪器
      begin
        for i := 0 to ExcelMeters.Count - 1 do
            { MTList } FMeterList.Add(ExcelMeters.Items[i].DesignName)
      end;
    end;
  end;

  if FMeterList.Count = 0 then
  begin
    showmessage('没有选择需要查询的仪器，请选择后再查询。');
    Exit;
  end;

  if rdgPresentType.ItemIndex = 0 then
  begin
    Body := '<h2>观测数据变化情况表</h2>';
    WCV := TWebCrossView.Create;

    // 如果不是按仪器类型分表，则SetGrid。按类型分表是在遇到新仪器类型的时候才SetGrid，若在此处
    // SetGrid将造成只有表头的空表。
    if not chkTableByType.Checked then SetGrid;

    sType := '';
    sPos := '';
  end;

  IHJXClientFuncs.SessionBegin;

  try
    Screen.Cursor := crHourGlass;
    ProgressBar.Position := 1;
    ProgressBar.Max := { MTList } FMeterList.Count; // ExcelMeters.Count;
    lblProgress.Caption := '';
    lblDesignName.Caption := '';
    iCount := { MTList } FMeterList.Count; // ExcelMeters.Count;
    pnlProgress.Visible := True;

    // sPos := ExcelMeters.Items[0].PrjParams.Position;
    sPos := ExcelMeters.Meter[ { MTList } FMeterList.Strings[0]].PrjParams.Position;
    Body := Body + '<h3>' + sPos + '</h3>';
    for iMeter := 0 to { ExcelMeters.Count - 1 } { MTList } FMeterList.Count - 1 do
    begin
      // Meter := ExcelMeters.Items[iMeter];
      Meter := ExcelMeters.Meter[ { MTList } FMeterList.Strings[iMeter]];

      if Meter.Params.MeterType = '测斜孔' then
          Continue;

      lblDesignName.Caption := Meter.DesignName;
      lblProgress.Caption := Format('正在处理第%d支，共%d支', [iMeter, iCount]);
      ProgressBar.Position := iMeter;
      IAppServices.ProcessMessages;

      if rdgPresentType.ItemIndex = 0 then // WebGrid需要按部位和类型划分页面
      begin
        if Meter.PrjParams.Position <> sPos then
        begin
          sPos := Meter.PrjParams.Position;
          Body := Body + WCV.CrossGrid;
          Body := Body + '<h3>' + sPos + '</h3>';
        // 若不是按类型分表，则就是按部位分表
          if not chkTableByType.Checked then
          begin
            WCV.Reset;
            SetGrid;
          end;

          sType := '';
        end;

        if Meter.Params.MeterType <> sType then
        begin
          if chkTableByType.Checked then
          begin
          // 当stype =''时，说明已经是另一个部位的仪器了，此时WCV内容已经在添加部位标题之前添加到
          // Body了，再添加表格就会在部位标题下面显示一个重复的表格。
            if sType <> '' then
                Body := Body + WCV.CrossGrid;
            Body := Body + '<h4>' + Meter.Params.MeterType + '</h4>';
            WCV.Reset;
            SetGrid;
          end
          else
              WCV.AddCaptionRow([Meter.Params.MeterType]);
          sType := Meter.Params.MeterType;
        end;
      end;

      { 查询仪器数据增量 }
      { 2019-07-31 查询增量的方法已经改为查询仪器带有特征值标记的物理量项目 }
      if IHJXClientFuncs.GetDataIncrement(Meter.DesignName, Now, V) then
      begin
      { 2019-07-31 因增量查询方法已经改为查询具有特征值标记的物理量，因此这里也修改为列出具备特征值
      标记的物理量，暂时不考虑过滤小变化量的情况。关于查询的结果V，参见uHJX.Excel.DataQuery单元中的
      GetDataIncrement方法中的定义 }
        k := 0;
        kIdx := [];
        for i := 0 to Meter.PDDefines.Count - 1 do
          if Meter.PDDefine[i].HasEV then
          begin
            Inc(k);
            include(kIdx, i);
          end;
        if k > 0 then
        begin
          i := 0;
          for k in kIdx do
          begin
            if rdgPresentType.ItemIndex = 0 then
            begin
              vH[0] := sType;
              vH[1] := '<a href="PopGraph:' + Meter.DesignName + '">' +
                Meter.DesignName + '</a>';
              vH[2] := V[i][0]; // 物理量名
              vH[3] := FormatDateTime('yyyy-mm-dd', V[i][1]);
              vH[4] := V[i][2]; // 间隔日期
              vH[5] := V[i][3]; // 最后测值
              vH[6] := V[i][4]; // 与上次测值的增量
              vH[7] := V[i][5]; // 30日增量
              WCV.AddRow(vH);
            end
            else
            begin
              // 2020-06-09------------------------------------------------------------
              cdsDatas.Append;
              cdsDatas.FieldByName('Position').Value := Meter.PrjParams.Position;
              cdsDatas.FieldByName('MeterType').Value := Meter.Params.MeterType;
              cdsDatas.FieldByName('DesignName').Value := Meter.DesignName;
              cdsDatas.FieldByName('PDName').Value := V[i][0];
              cdsDatas.FieldByName('DTScale').Value := V[i][1];
              cdsDatas.FieldByName('InteralDays').Value := V[i][2];
              cdsDatas.FieldByName('Data').Value := V[i][3];
              cdsDatas.FieldByName('Increment').Value := V[i][4];
              cdsDatas.FieldByName('Inc30Days').Value := V[i][5];
              cdsDatas.Post;
            end;
            Inc(i);
          end;
        end;
      end;

    end;

    if rdgPresentType.ItemIndex = 0 then
    begin
      Body := Body + WCV.CrossGrid;
      Page := StringReplace(htmPageCode2, '@PageContent@', Body, []);
      if chkUseIE.Checked then
          WB_LoadHTML(wbViewer, Page)
      else
          HtmlViewer.LoadFromString(Page);
    end
    else
    begin
    // 2020-06-09------------------------------------------------
      for i := 0 to cdsDatas.Fields.Count - 1 do
      begin
        cdsDatas.Fields[i].DisplayLabel := cdsDatas.Fields[i].DisplayName;
        if cdsDatas.Fields[i].DataType = ftFloat then
          (cdsDatas.Fields[i] as TNumericField).DisplayFormat := '0.00';
      end;
      cdsDatas.Open;
      MemTableEh1.Open;
      // FDBGrid.BringToFront;
      // FDBGrid.Align := alClient;
      // FDBGrid.Visible := True;
      DBGridEh1.DataGrouping.Active := False;
      DBGridEh1.DataGrouping.GroupLevels.Clear;
      DBGridEh1.DataGrouping.GroupLevels.Add.Column := DBGridEh1.Columns[0];
      DBGridEh1.DataGrouping.GroupLevels.Add.Column := DBGridEh1.Columns[1];
      // gl := DBGridEh1.DataGrouping.GroupLevels.Add;
      // gl.Column := DBGridEh1.Columns[0];
      DBGridEh1.Columns[0].Visible := False;
      DBGridEh1.Columns[1].Visible := False;
      DBGridEh1.DataGrouping.Active := True;
      DBGridEh1.DataGrouping.GroupPanelVisible := True;
      _SetGridPresent;
    end;
    // -----------------------------------------------------------
  finally
    { MTList.Free; }
    if rdgPresentType.ItemIndex = 0 then
    begin
      WCV.Free;
      ClearValues;
    end;
    IHJXClientFuncs.SessionEnd;
    Screen.Cursor := crDefault;
    pnlProgress.Visible := False;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : ShowSpecificDatesData
  Description: 显示两个指定日期的观测数据，及其增量
----------------------------------------------------------------------------- }
procedure TfraQuickViewer.ShowSpecificDatesData;
var
  WCV  : TWebCrossView;
  Meter: TMeterDefine;
  i, j : Integer;
  k    : Integer;
  kIdx : Set of Byte;
  V, V1: TDoubleDynArray;
  vH   : array of variant;

  dt1, dt2, d1, d2         : Double;
  sPage, sBody, sType, sPos: string;

  procedure _ClearValues;
  var
    ii: Integer;
  begin
    for ii := Low(vH) to High(vH) do VarClear(vH[ii]);
  end;

  procedure _SetGrid;
  var
    ii: Integer;
  begin
    WCV.TitleRows := 2;
    if chkSimpleSDGrid.Checked then
    begin
      WCV.ColCount := 5;
      WCV.ColHeader[4].AllowRowSpan := True;
      WCV.ColHeader[0].AllowColSpan := True;
      for ii in [2, 3, 4] do WCV.ColHeader[ii].Align := taRightJustify;
      SetLength(vH, 5);
      vH[0] := '设计编号';
      vH[1] := '物理量';
      for ii := 2 to 3 do vH[ii] := '观测数据';
      vH[4] := '增量';
      WCV.AddRow(vH);
      vH[2] := '%dt1%'; // 第一个日期
      vH[3] := '%dt2%'; // 第二个日期
      WCV.AddRow(vH);
    end
    else
    begin
      WCV.ColCount := 9;
      WCV.ColHeader[6].AllowRowSpan := True;
      WCV.ColHeader[0].AllowColSpan := True;
      WCV.ColHeader[2].AllowColSpan := True;
      WCV.ColHeader[3].AllowColSpan := True;
      // wcv.ColHeader[6].AllowColSpan := True;
      // wcv.ColHeader[7].AllowColSpan := True;
      // wcv.ColHeader[8].AllowColSpan := True;
      WCV.ColHeader[4].Align := taRightJustify;
      for ii in [4, 5, 6, 7, 8] do WCV.ColHeader[ii].Align := taRightJustify;

      SetLength(vH, 9);
      vH[0] := '设计编号';
      vH[1] := '物理量';
      for ii := 2 to 5 do vH[ii] := '观测数据';
      vH[6] := '增量';
      vH[7] := '日期间隔';
      vH[8] := '变化速率';
      WCV.AddRow(vH);
      vH[2] := '起始日期';
      vH[3] := '截止日期';
      vH[4] := '起始测值';
      vH[5] := '截止测值';
      WCV.AddRow(vH);
    end;

  end;

begin
  if ExcelMeters.Count = 0 then Exit;

// 如果WebGrid
  if rdgPresentType.ItemIndex = 0 then
  begin
    DBGridEh1.Visible := False;
    if MemTableEh1.Active then
        MemTableEh1.Close;
    if cdsDatas.Active then
        cdsDatas.Close;
    if chkUseIE.Checked then
    begin
      HtmlViewer.Visible := False;
      wbViewer.Visible := True;
      wbViewer.Align := alClient;
    end
    else
    begin
      HtmlViewer.Visible := True;
      HtmlViewer.Align := alClient;
      wbViewer.Visible := False;
    end;
  end
  else // 否则是EhGrid
  begin
    HtmlViewer.Visible := False;
    wbViewer.Visible := False;
    DBGridEh1.Visible := True;
    DBGridEh1.Align := alClient;
    _Create2DayIncDataSet;
  end;
(*
  if chkUseIE.Checked then
  begin
    HtmlViewer.Visible := False;
    wbViewer.Visible := True;
    wbViewer.Align := alClient;
  end
  else
  begin
    HtmlViewer.Visible := True;
    wbViewer.Visible := False;
    HtmlViewer.Align := alClient;
  end;
*)
  // 选择仪器
  if chkAllMeters.Checked then
  begin
    FMeterList.Clear;
    for i := 0 to ExcelMeters.Count - 1 do
        FMeterList.Add(ExcelMeters.Items[i].DesignName);
  end
  else
    with IAppServices.FuncDispatcher as IFunctionDispatcher do
      if HasProc('PopupMeterSelector') then
          CallFunction('PopupMeterSelector', FMeterList);

  if FMeterList.Count = 0 then
  begin
    showmessage('没有选择监测仪器');
    Exit;
  end;

  // 准备表格对象
  IAppServices.ClientDatas.SessionBegin;
  // 如果采用WebGrid表现，则
  if rdgPresentType.ItemIndex = 0 then
  begin
    if chkSimpleSDGrid.Checked then SetLength(vH, 5)
    else SetLength(vH, 9);

    WCV := TWebCrossView.Create;
    _SetGrid;
    sType := '';
    sPos := ExcelMeters.Meter[FMeterList[0]].PrjParams.Position;
    sBody := '<h3>' + sPos + '</h3>';
  end;

  try
    Screen.Cursor := crHourGlass;
    ProgressBar.Position := 1;
    ProgressBar.Max := { MTList } FMeterList.Count; // ExcelMeters.Count;
    lblProgress.Caption := '';
    lblDesignName.Caption := '';
    // iCount := { MTList } FMeterList.Count; // ExcelMeters.Count;
    pnlProgress.Visible := True;
    // 准备仪器数据，及填写内容
    for i := 0 to FMeterList.Count - 1 do
    begin
      Meter := ExcelMeters.Meter[FMeterList[i]];
      lblDesignName.Caption := Meter.DesignName;
      lblProgress.Caption := Format('正在处理第%d支，共%d支', [i + 1, FMeterList.Count]);
      ProgressBar.Position := i + 1;

      if Meter.DataSheet = '' then Continue;
      if Meter.Params.MeterType = '测斜孔' then Continue;

      // 如果采用WebGrid，则
      if rdgPresentType.ItemIndex = 0 then
      begin
        // 部位处理
        if Meter.PrjParams.Position <> sPos then
        begin
          sPos := Meter.PrjParams.Position;
          sBody := sBody + WCV.CrossGrid + #13#10'<h3>' + sPos + '</h3>'#13#10;
          WCV.Reset;
          _SetGrid;
        end;
        // 类型检查、处理
        if Meter.Params.MeterType <> sType then
        begin
          sType := Meter.Params.MeterType;
          WCV.AddCaptionRow([sType]);
        end;
        { 2019-07-31采用列出特征值项的方式创建表格，即仪器的特征值量都列入数据查询之中 }
        _ClearValues;
      end;

      // 下面的代码查询和统计仪器的特征值项数量，并将PD序号填入kIdx集合
      j := 0;
      kIdx := [];
      for k := 0 to Meter.PDDefines.Count - 1 do
        if Meter.PDDefine[k].HasEV then
        begin
          Inc(j);
          include(kIdx, k);
        end;

      { 当仪器的特征值项不为零，则创建表格 }
      if j > 0 then
      begin
        // 查询数据
        IAppServices.ClientDatas.GetNearestPDDatas(FMeterList[i], dtp1.Date, V);
        IAppServices.ClientDatas.GetNearestPDDatas(FMeterList[i], dtp2.Date, V1);
        if V[0] = 0 then Continue;
        dt1 := V[0];
        dt2 := V1[0];
        // 如果采用WebGrid，则
        if rdgPresentType.ItemIndex = 0 then
        begin
          vH[0] := '<a href="PopGraph:' + Meter.DesignName + '">' + Meter.DesignName + '</a>';
          if not chkSimpleSDGrid.Checked then
          begin
            vH[2] := FormatDateTime('yyyy-mm-dd', dt1);
            vH[3] := FormatDateTime('yyyy-mm-dd', dt2);
            vH[7] := dt2 - dt1; // 日期间隔
          end;
        end;

        for j in kIdx do // 逐个添加特征值数据行
        begin
          if rdgPresentType.ItemIndex = 0 then // 采用WebGrid
          begin
            vH[1] := Meter.PDName(j);
            if chkSimpleSDGrid.Checked then
            begin
              vH[2] := V[j + 1];
              vH[3] := V1[j + 1];
              vH[4] := V1[j + 1] - V[j + 1];
            end
            else
            begin
              vH[4] := V[j + 1];
              vH[5] := V1[j + 1];
              vH[6] := V1[j + 1] - V[j + 1];
              if dt2 - dt1 <> 0 then vH[8] := (V1[j + 1] - V[j + 1]) / (dt2 - dt1);
            end;
            WCV.AddRow(vH);
          end
          else // 采用EhGrid
          begin
            cdsDatas.Append;
            cdsDatas.FieldByName('Position').Value := Meter.PrjParams.Position;
            cdsDatas.FieldByName('MeterType').Value := Meter.Params.MeterType;
            cdsDatas.FieldByName('DesignName').Value := Meter.DesignName;
            cdsDatas.FieldByName('PDName').Value := Meter.PDName(j);
            cdsDatas.FieldByName('StartDate').Value := dt1;
            cdsDatas.FieldByName('EndDate').Value := dt2;
            cdsDatas.FieldByName('Data1').Value := V[j + 1];
            cdsDatas.FieldByName('Data2').Value := V1[j + 1];
            cdsDatas.FieldByName('IntralDays').Value := dt2 - dt1;
            cdsDatas.FieldByName('Increment').Value := V1[j + 1] - V[j + 1];
            if dt2 - dt1 <> 0 then
                cdsDatas.FieldByName('Rate').Value := (V1[j + 1] - V[j + 1]) / (dt2 - dt1);
            cdsDatas.Post;
          end;
        end;
      end;
    end;

    if rdgPresentType.ItemIndex = 0 then
    begin
    // 显示结果
      sBody := sBody + WCV.CrossGrid;
      if chkSimpleSDGrid.Checked then
      begin
        sBody := StringReplace(sBody, '%dt1%', FormatDateTime('yyyy-mm-dd', dt1), []);
        sBody := StringReplace(sBody, '%dt2%', FormatDateTime('yyyy-mm-dd', dt2), []);
      end;
      sPage := StringReplace(htmPageCode2, '@PageContent@', sBody, []);

      if chkUseIE.Checked then
          WB_LoadHTML(wbViewer, sPage)
      else
          HtmlViewer.LoadFromString(sPage);
    end
    else
    begin
      cdsDatas.Open;
      MemTableEh1.Open;
      DBGridEh1.DataGrouping.Active := False;
      DBGridEh1.DataGrouping.GroupLevels.Clear;
      DBGridEh1.DataGrouping.GroupLevels.Add.Column := DBGridEh1.Columns[0];
      DBGridEh1.DataGrouping.GroupLevels.Add.Column := DBGridEh1.Columns[1];
      DBGridEh1.Columns[0].Visible := False;
      DBGridEh1.Columns[1].Visible := False;
      DBGridEh1.DataGrouping.Active := True;
      DBGridEh1.DataGrouping.GroupPanelVisible := True;
      _SetGridPresent;
    end;

  finally
    if rdgPresentType.ItemIndex = 0 then
    begin
      SetLength(vH, 0);
      WCV.Free;
    end;
    Screen.Cursor := crDefault;
    pnlProgress.Visible := False;
    IAppServices.ClientDatas.SessionEnd;
  end;

end;

{ -----------------------------------------------------------------------------
  Procedure  : ShowLastDatas
  Description: 本方法显示所选仪器的最后一条记录，分部位、按类型分表，显示全部
  物理量。
----------------------------------------------------------------------------- }
procedure TfraQuickViewer.ShowLastDatas;
var
  Meter  : TMeterDefine;
  iMeter : Integer;
  i, iRow: Integer;
  iCount : Integer;
  WCV    : TWebCrossView;
  V      : TVariantDynArray;
  vH     : array of variant;
  Body   : String;
  Page   : String;
  sType  : string;
  sPos   : String;

  procedure ClearValues;
  var
    ii: Integer;
  begin
    SetLength(vH, 0);
    if Length(V) > 0 then
      for ii := 0 to High(V) do
          VarClear(V[ii]);
    SetLength(V, 0);
  end;

  function IgnoreData(AData: variant; ALimit: Double): Boolean;
  begin
    Result := True;
    if VarIsEmpty(AData) or VarIsNull(AData) then
        Exit;
    if abs(AData) >= ALimit then
        Result := False;
  end;

  { 根据仪器类型设置表格 }
  procedure SetGrid;
  var
    iii: Integer;
  begin
    WCV.ColCount := Meter.DataSheetStru.PDs.Count + 3; // 设计编号，观测日期，物理量系列，备注列
    WCV.TitleRows := 1;
    WCV.AddRow;
    WCV.Cells[0, 0].Value := '设计编号';
    WCV.Cells[1, 0].Value := '观测日期';
    for iii := 0 to Meter.DataSheetStru.PDs.Count - 1 do
    begin
      WCV.Cells[2 + iii, 0].Value := Meter.PDDefine[iii].Name;
      WCV.ColHeader[2 + iii].Align := taRightJustify;
    end;
    WCV.Cells[WCV.ColCount - 1, 0].Value := '备注';
  end;

begin
  if ExcelMeters.Count = 0 then Exit;
  DBGridEh1.Visible := False;
  HtmlViewer.Clear;
  if chkUseIE.Checked then
  begin
    HtmlViewer.Visible := False;
    wbViewer.Visible := True;
    wbViewer.Align := alClient;
  end
  else
  begin
    HtmlViewer.Visible := True;
    wbViewer.Visible := False;
    HtmlViewer.Align := alClient;
  end;

  // 准备仪器列表
  if chkAllMeters.Checked then
  begin
    FMeterList.Clear;
    for i := 0 to ExcelMeters.Count - 1 do
        FMeterList.Add(ExcelMeters.Items[i].DesignName)
  end
  else
  begin
    with IAppServices.FuncDispatcher as IFunctionDispatcher do
    begin
    // 如果能选择部分仪器则
      if HasProc('PopupMeterSelector') then
          CallFunction('PopupMeterSelector', { MTList } FMeterList)
      else // 否则选择全部仪器
      begin
        for i := 0 to ExcelMeters.Count - 1 do
            FMeterList.Add(ExcelMeters.Items[i].DesignName)
      end;
    end;
  end;
  if FMeterList.Count = 0 then
  begin
    showmessage('没有选择需要查询的监测仪器，请选择后再查询。');
    Exit;
  end;

  Body := '<h2>观测数据变化情况表</h2>';
  WCV := TWebCrossView.Create;

  // 本方法产生的表格将按照仪器类型分表
  // if not chkTableByType.Checked then SetGrid;

  sType := '';
  sPos := '';
  IHJXClientFuncs.SessionBegin;

  try
    Screen.Cursor := crHourGlass;
    ProgressBar.Position := 1;
    ProgressBar.Max := { MTList } FMeterList.Count; // ExcelMeters.Count;
    lblProgress.Caption := '';
    lblDesignName.Caption := '';
    iCount := { MTList } FMeterList.Count; // ExcelMeters.Count;
    pnlProgress.Visible := True;

    // sPos := ExcelMeters.Items[0].PrjParams.Position;
    sPos := ExcelMeters.Meter[ { MTList } FMeterList.Strings[0]].PrjParams.Position;
    Body := Body + '<h3>' + sPos + '</h3>';

    for iMeter := 0 to { ExcelMeters.Count - 1 } { MTList } FMeterList.Count - 1 do
    begin
      Meter := ExcelMeters.Meter[ { MTList } FMeterList.Strings[iMeter]];

      lblDesignName.Caption := Meter.DesignName;
      lblProgress.Caption := Format('正在处理第%d支，共%d支', [iMeter, iCount]);
      ProgressBar.Position := iMeter;

      if Meter.Params.MeterType = '测斜孔' then
          Continue;

      IAppServices.ProcessMessages;

      if Meter.PrjParams.Position <> sPos then
      begin
        sPos := Meter.PrjParams.Position;
        Body := Body + WCV.CrossGrid;
        Body := Body + '<h3>' + sPos + '</h3>';
        // 若不是按类型分表，则就是按部位分表
        if not chkTableByType.Checked then
        begin
          WCV.Reset;
          SetGrid;
        end;

        sType := '';
      end;

      if Meter.Params.MeterType <> sType then
      begin
        if chkTableByType.Checked then
        begin
          // 当stype =''时，说明已经是另一个部位的仪器了，此时WCV内容已经在添加部位标题之前添加到
          // Body了，再添加表格就会在部位标题下面显示一个重复的表格。
          if sType <> '' then
              Body := Body + WCV.CrossGrid;
          Body := Body + '<h4>' + Meter.Params.MeterType + '</h4>';
          WCV.Reset;
          SetGrid;
        end
        else
            WCV.AddCaptionRow([Meter.Params.MeterType]);
        sType := Meter.Params.MeterType;
      end;

      if IHJXClientFuncs.GetLastPDDatas(Meter.DesignName, V) then
        if V[0] <> 0 then // 若观测日期为0，则表明该仪器没有观测数据
        begin
          WCV.AddRow;
          iRow := WCV.RowCount - 1;
          WCV.Cells[0, iRow].Value := Meter.DesignName;    // 设计编号
          WCV.Cells[1, iRow].Value := VarToDateTime(V[0]); // 观测日期
          // 添加物理量
          for i := 0 to Meter.PDDefines.Count - 1 do
            if VarIsNumeric(V[1 + i]) then
                WCV.Cells[2 + i, iRow].Value := FormatFloat('0.00', V[i + 1]);
          // 添加备注
        end;
    end;

    Body := Body + WCV.CrossGrid;
    Page := StringReplace(htmPageCode2, '@PageContent@', Body, []);
    if chkUseIE.Checked then
        WB_LoadHTML(wbViewer, Page)
    else
        HtmlViewer.LoadFromString(Page);
  finally
    { MTList.Free; }
    WCV.Free;
    ClearValues;
    IHJXClientFuncs.SessionEnd;
    Screen.Cursor := crDefault;
    pnlProgress.Visible := False;
  end;
end;

end.
