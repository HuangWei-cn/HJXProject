{ -----------------------------------------------------------------------------
  Unit Name: ufraEigenvalueGrid
  Author:    黄伟
  Date:      30-九月-2018
  Purpose:   使用EhGrid為控件的特征值查詢功能件
  History:   2022-10-26 允许用户选择是否查询年特征值；特征值项中允许选择最小值
  增量、变幅等项目；改善了拷贝为HTML格式的方法，采用了HTMLViewer
  作为拷贝中间载体。原EhGrid没有提供拷贝为HTML方法。
  ----------------------------------------------------------------------------- }
{ TODO:允许用户编辑表中数据，如果修改了最大最小值，则自动重新计算增量和变幅 }
{ TODO:添加 1. 显示选中仪器过程线；2. 显示仪器观测数据；3. 打开该仪器所在原始数据表 }
{ TODO:允许更新表中单支仪器数据 }
{ TODO:允许写入Word表，可以预先做一些约定，比如对Table.Title的内容格式约定，以方便
  确定表格中仪器的类型、物理量，以及表格的格式 }
{ TODO:允许用户更新表中当前仪器特征值数据。当用户完成一次查询后，发现某仪器数据异常，在
  编辑Excel文件后，仅更新当前仪器的数据即可，无需再次重新查询全部仪器 }
unit ufraEigenvalueGrid;

{ 2024-10-11:
    1. 用户可以修改表格中的数据；
    2. 可以将数据保存，可以加载之前保存的数据，继续修改、编辑 }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.StrUtils, System.Types, DBGridEhGrouping,
  ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh,
  Vcl.ExtCtrls, MemTableDataEh, Data.DB, DataDriverEh, Datasnap.DBClient, MemTableEh, Vcl.StdCtrls,
  {-------------}
  uHJX.Intf.AppServices, uHJX.Intf.Datas, uHJX.Classes.Meters, uHJX.Data.Types, Vcl.ComCtrls,
  Vcl.Menus, Vcl.OleCtrls, SHDocVw, Activex;

type
  TfraEigenvalueGrid = class(TFrame)
    Panel1: TPanel;
    Splitter1: TSplitter;
    grdEV: TDBGridEh;
    mtEV: TMemTableEh;
    dsEV: TDataSource;
    cdsEV: TClientDataSet;
    dsdEV: TDataSetDriverEh;
    btnQuery: TButton;
    rdgMeterOption: TRadioGroup;
    GroupBox1: TGroupBox;
    optLast: TRadioButton;
    optSpecialDate: TRadioButton;
    dtpStart: TDateTimePicker;
    dtpEnd: TDateTimePicker;
    prgBar: TProgressBar;
    popEV: TPopupMenu;
    piCopyAsHTML: TMenuItem;
    N1: TMenuItem;
    piSaveAsHTML: TMenuItem;
    piSaveAsRTF: TMenuItem;
    piSaveAsXLS: TMenuItem;
    piCopyToClipBoard: TMenuItem;
    dlgSave: TSaveDialog;
    btnDrawEVGraph: TButton;
    Timer1: TTimer;
    grpEVItemSelect: TGroupBox;
    chkHistoryEV: TCheckBox;
    chkYearEV: TCheckBox;
    grpDataSelect: TGroupBox;
    chkMinData: TCheckBox;
    chkIncData: TCheckBox;
    chkAmplitude: TCheckBox;
    piCopyUseWebGrid: TMenuItem;
    ieBrowser: TWebBrowser;
    GroupBox2: TGroupBox;
    chkGroupByPos: TCheckBox;
    N2: TMenuItem;
    piPopupTreandLine: TMenuItem;
    piPopupDatas: TMenuItem;
    piOpenExcelData: TMenuItem;
    N6: TMenuItem;
    piUpdateMeterData: TMenuItem;
    piUpdateWordTables: TMenuItem;
    N3: TMenuItem;
    piAllowEdit: TMenuItem;
    N4: TMenuItem;
    piSaveDatas: TMenuItem;
    piLoadDatas: TMenuItem;
    dlgOpen: TOpenDialog;
    procedure btnQueryClick(Sender: TObject);
    procedure piCopyAsHTMLClick(Sender: TObject);
    procedure piSaveAsHTMLClick(Sender: TObject);
    procedure piSaveAsRTFClick(Sender: TObject);
    procedure piSaveAsXLSClick(Sender: TObject);
    procedure piCopyToClipBoardClick(Sender: TObject);
    procedure btnDrawEVGraphClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure piCopyUseWebGridClick(Sender: TObject);
    procedure dtpEndChange(Sender: TObject);
    procedure piPopupTreandLineClick(Sender: TObject);
    procedure piPopupDatasClick(Sender: TObject);
    procedure piOpenExcelDataClick(Sender: TObject);
    procedure piUpdateMeterDataClick(Sender: TObject);
    procedure piUpdateWordTablesClick(Sender: TObject);
    procedure cdsEVAfterEdit(DataSet: TDataSet);
    procedure cdsEVAfterPost(DataSet: TDataSet);
    procedure cdsEVAfterApplyUpdates(Sender: TObject; var OwnerData: OleVariant);
    procedure mtEVBeforeEdit(DataSet: TDataSet);
    procedure piAllowEditClick(Sender: TObject);
    procedure piSaveDatasClick(Sender: TObject);
    procedure piLoadDatasClick(Sender: TObject);
  private
    { Private declarations }
    FIDList: TStrings;
    procedure SetFields;
    procedure SetDisplay;
    /// <summary>
    /// 用WebCrossView对象生成HTML表格。EhGrid表格很善于筛选数据，因此可用
    /// 该组件对查询结果进行筛选，但是该组件查询结果的导出、拷贝，在其他软件
    /// 中并不一定合适，尤其是难以直接用到Word中，因此需要对表格进行一定程度
    /// 的修饰
    /// </summary>
    procedure CopyAsWebGrid;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GetEVDatas(IDList: string);
  end;

implementation

uses
  uHJX.Intf.FunctionDispatcher, DBGridEhImpExp, uMyUtils.CopyHTML2Clipbrd, ufrmEVGraph,
  uWebGridCross, uWBLoadHTML, uHJX.Excel.IO;
{$R *.dfm}

const
  { 注：这里的CSS设置使得表格呈现细线边框 }
  { 针对表格的表头、单元格使用了CSS定义 }
  htmPageCode2 = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10 + '<html>'#13#10 +
    '<head>'#13#10 + '<meta http-equiv="Content-Type" content="text/html; charset=GB2312" />'#13#10
    + '<style type="text/css">'#13#10 +
    '.DataGrid {border:1px solid #1F4E79;border-width:1px 1px 1px 1px;margin:0px 0px 0px 0px;border-collapse:collapse}'#13#10
    + '.thStyle {font-size: 8pt; font-family: Consolas; color: #000000; padding:2px;border:1px solid #1F4E79}'#13#10
    + '.tdStyle {font-size: 8pt; font-family: Consolas; color: #000000; background-color:#FFFFFF;empty-cells:show;'
  // #F7F7F7
    + '          border:1px solid #1F4E79; padding:2px}'#13#10 +
    '.CaptionStyle {font-family:黑体;font-size: 9pt;color: #000000; padding:2px;border:1px solid #1F4E79; background-color:#FFFF99}'#13#10
    + '</style>'#13#10 + '</head>'#13#10 + '<body>'#13#10 + '@PageContent@'#13#10 + '</body>'#13#10
    + '</html>';

var
  IDF: IFunctionDispatcher;

constructor TfraEigenvalueGrid.Create(AOwner: TComponent);
begin
  inherited;
  FIDList := TStringList.Create;
  idf := IAppservices.FuncDispatcher as ifunctiondispatcher;
end;

destructor TfraEigenvalueGrid.Destroy;
begin
  FIDList.Free;
  inherited;
end;

procedure TfraEigenvalueGrid.dtpEndChange(Sender: TObject);
begin
  optSpecialDate.Checked := True;
end;

procedure TfraEigenvalueGrid.btnDrawEVGraphClick(Sender: TObject);
var
  frm: TfrmEVGraph;
begin
  if cdsEV.RecordCount = 0 then
  begin
    ShowMessage('你先得查东西来，才能绘图~~');
    Exit;
  end;

  if (mtEV.FieldByName('Position').IsNull or mtEV.FieldByName('MeterType').IsNull) then
  begin
    ShowMessage('你得选中某条记录，有工程部位和仪器类型的记录~~~');
    Exit;
  end;

  (* )
    frm := TfrmEVGraph.Create(self);
    frm.DrawEVGraph(mtEV.FieldByName('Position').AsString,
    mtEV.FieldByName('MeterType').AsString, mtEV.FieldByName('PDName').AsString, mtEV);
    frm.ShowModal;
    frm.Release;
  *)
  popupevgraph(mtEV.FieldByName('Position').AsString, mtEV.FieldByName('MeterType').AsString,
    mtEV.FieldByName('PDName').AsString, mtEV, chkGroupByPos.Checked);
end;

procedure TfraEigenvalueGrid.btnQueryClick(Sender: TObject);
var
  S: string;
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
  if not Assigned(IAppServices) then
    Exit;
  // show why cannot query;
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
    grdEV.StartLoadingStatus('正在加载数据，请稍后......');
    GetEVDatas(S);
  finally
    grdEV.FinishLoadingStatus;
    Screen.Cursor := crDefault;
    prgBar.Visible := False;
  end;

end;

procedure TfraEigenvalueGrid.cdsEVAfterApplyUpdates(Sender: TObject; var OwnerData: OleVariant);
begin
//
end;

procedure TfraEigenvalueGrid.cdsEVAfterEdit(DataSet: TDataSet);
var
  dMax,dMin,dInc,dRange:double;
  fld:TField;
begin
{todo:编辑完数据，计算增量和变幅}
  //如果没有最小值，就无法自动计算
  fld := cdsev.FieldByName('MinInLife');
  if fld = nil then    Exit;

  dmin := fld.AsFloat;
  fld := cdsev.FieldByName('MaxInLife');
  dmax := fld.AsFloat;

  drange := dmax - dmin;
  fld  := cdsev.FieldByName('AmplitudeInLife');
  fld.Value := drange;

  fld := cdsev.FieldByName('IncrementInLife');
//  增量要用……
//  if fld <> nil then
//    fld.Value := d


end;

procedure TfraEigenvalueGrid.cdsEVAfterPost(DataSet: TDataSet);
begin
//
end;

procedure TfraEigenvalueGrid.SetFields;
var
  fd: TFieldDef;
  i: Integer;

  procedure AddFieldDef(fdName, fdDisplayName: string; fdType: TFieldType);
  begin
    fd := cdsEV.FieldDefs.AddFieldDef;
    fd.Name := fdName;
    fd.DisplayName := fdDisplayName;
    fd.DataType := fdType;
  end;

begin
  if cdsEV.Active then
    cdsEV.Close;
  cdsEV.FieldDefs.Clear;
  cdsEV.IndexDefs.Clear;

  // 安裝部位
  AddFieldDef('Position', '安裝部位', ftstring);
  AddFieldDef('MeterType', '仪器类型', ftstring);
  AddFieldDef('DesignName', '设计编号', ftstring);
  AddFieldDef('PDName', '物理量', ftstring);
  // 自古以來系列----------------------------
  AddFieldDef('MaxDTInLife', '日期', ftDateTime);
  AddFieldDef('MaxInLife', '最大值', ftFloat);
  if chkMinData.Checked then
    AddFieldDef('MinDTInLife', '日期', ftDateTime);
  if chkMinData.Checked then
    AddFieldDef('MinInLife', '最小值', ftFloat);
  if chkIncData.Checked then
    AddFieldDef('IncrementInLife', '增量', ftFloat);
  if chkAmplitude.Checked then
    AddFieldDef('AmplitudeInLife', '变幅', ftFloat);
  // 年特征系列-----------------------------
  if chkYearEV.Checked then
  begin
    AddFieldDef('MaxDTInYear', '日期', ftDateTime);
    AddFieldDef('MaxInYear', '最大值', ftFloat);
    if chkMinData.Checked then
      AddFieldDef('MinDTInYear', '日期', ftDateTime);
    if chkMinData.Checked then
      AddFieldDef('MinInLife', '最小值', ftFloat);
    if chkIncData.Checked then
      AddFieldDef('IncrementInLife', '增量', ftFloat);
    if chkAmplitude.Checked then
      AddFieldDef('AmplitudeInLife', '变幅', ftFloat);
    // AddFieldDef('MinInYear', '最小值', ftFloat);
    // AddFieldDef('IncrementInYear', '增量', ftFloat);
    // AddFieldDef('AmplitudeInYear', '变幅', ftFloat);
  end;
  // 當前值系列-----------------------------
  AddFieldDef('DTScale', '日期', ftDateTime);
  AddFieldDef('Value', '測值', ftFloat);

  cdsEV.CreateDataSet;
  for i := 0 to cdsEV.FieldCount - 1 do
    if cdsEV.Fields[i].DataType = ftFloat then
      (cdsEV.Fields[i] as TNumericField).DisplayFormat := '0.00'
    else if cdsEV.Fields[i].DataType = ftDateTime then
      (cdsEV.Fields[i] as TDateTimeField).DisplayFormat := 'yyyy-mm-dd';
end;

procedure TfraEigenvalueGrid.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  ieBrowser.ExecWB(OLECMDID_COPY, 0);
  ShowMessage('拷贝完成');
end;

procedure TfraEigenvalueGrid.SetDisplay;
var
  i: Integer;
  gl: TGridDataGroupLevelEh;

  procedure SetDisplayLabel(fdName, sLabel: string);
  begin
    cdsEV.FieldByName(fdName).DisplayLabel := sLabel;
  end;

begin
  { with cdsEV do
    begin
    SetDisplayLabel('Position', '安裝部位');
    SetDisplayLabel('MeterType', '儀器類型');
    SetDisplayLabel('DesignName', '設計編號');
    SetDisplayLabel('PDName', '觀測量');
    SetDisplayLabel('MaxDTInLife', '日期');
    SetDisplayLabel('MaxInLife', '最大值');
    SetDisplayLabel('MinDTInLife', '日期');
    SetDisplayLabel('MinInLife', '最小值');
    SetDisplayLabel('IncrementInLife', '增量');
    SetDisplayLabel('AmplitudeInLife', '振幅');
    SetDisplayLabel('MaxDTInYear', '日期');
    SetDisplayLabel('MaxInYear', '最大值');
    SetDisplayLabel('MinDTInYear', '日期');
    SetDisplayLabel('MinInYear', '最小值');
    SetDisplayLabel('IncrementInYear', '增量');
    SetDisplayLabel('AmplitudeInYear', '振幅');
    SetDisplayLabel('DTScale', '日期');
    SetDisplayLabel('Value', '測值');
    end; }
  grdEV.UseMultiTitle := True;
  { grdEV.Columns[0].Title.Caption := '安装部位';
    grdEV.Columns[1].Title.Caption := '仪器类型';
    grdEV.Columns[2].Title.Caption := '设计编号';
    grdEV.Columns[3].Title.Caption := '观测量　';
    grdEV.Columns[4].Title.Caption := '历史特征| 最大测值 | 日期 ';
    grdEV.Columns[5].Title.Caption := '历史特征| 最大测值 | 测值 ';
    grdEV.Columns[6].Title.Caption := '历史特征| 最小值 | 日期 ';
    grdEV.Columns[7].Title.Caption := '历史特征| 最小值 | 测值 ';
    grdEV.Columns[8].Title.Caption := '历史特征| 增量 ';
    grdEV.Columns[9].Title.Caption := '历史特征| 变幅 ';

    grdEV.Columns[10].Title.Caption := '年度特征|最大测值| 日期 ';
    grdEV.Columns[11].Title.Caption := '年度特征|最大测值| 测值 ';
    grdEV.Columns[12].Title.Caption := '年度特征|最小值| 日期 ';
    grdEV.Columns[13].Title.Caption := '年度特征|最小值| 测值 ';
    grdEV.Columns[14].Title.Caption := '年度特征|增量';
    grdEV.Columns[15].Title.Caption := '年度特征|变幅';

    grdEV.Columns[16].Title.Caption := '当前测值|日期';
    grdEV.Columns[17].Title.Caption := '当前测值|测值'; }

  grdEV.Columns[0].Field.DisplayLabel := '安装部位';
  grdEV.Columns[1].Field.DisplayLabel := '仪器类型';
  grdEV.Columns[2].Field.DisplayLabel := '设计编号';
  grdEV.Columns[3].Field.DisplayLabel := '观测项';
  grdEV.Columns[4].Field.DisplayLabel := '历史特征值|最大值|日期';
  grdEV.Columns[5].Field.DisplayLabel := '历史特征值|最大值|测值';
  i := 6;
  if chkMinData.Checked then
  begin
    grdEV.Columns[6].Field.DisplayLabel := '历史特征值|最小值|日期';
    grdEV.Columns[7].Field.DisplayLabel := '历史特征值|最小值|测值';
    i := 8;
  end;

  if chkIncData.Checked then
  begin
    grdEV.Columns[i].Field.DisplayLabel := '历史特征值|增量';
    Inc(i);
  end;

  if chkAmplitude.Checked then
  begin
    grdEV.Columns[i].Field.DisplayLabel := '历史特征值|变幅';
    Inc(i);
  end;

  if chkYearEV.Checked then
  begin
    grdEV.Columns[i].Field.DisplayLabel := '年度特征值|最大值|日期';
    grdEV.Columns[i + 1].Field.DisplayLabel := '年度特征值|最大值|测值';
    Inc(i, 2);
    if chkMinData.Checked then
    begin
      grdEV.Columns[i].Field.DisplayLabel := '年度特征值|最小值|日期';
      grdEV.Columns[i + 1].Field.DisplayLabel := '年度特征值|最小值|测值';
      Inc(i, 2);
    end;
    if chkIncData.Checked then
    begin
      grdEV.Columns[i].Field.DisplayLabel := '年度特征值|增量';
      Inc(i);
    end;
    if chkAmplitude.Checked then
    begin
      grdEV.Columns[i].Field.DisplayLabel := '年度特征值|变幅';
      Inc(i);
    end;
  end;

  grdEV.Columns[i].Field.DisplayLabel := '当前值|日期';
  grdEV.Columns[i + 1].Field.DisplayLabel := '当前值|测值';

  for i := 0 to grdEV.Columns.Count - 1 do
  begin
    if i < 4 then
      grdEV.Columns[i].Alignment := taCenter;
    if pos('日期', grdEV.Columns[i].Title.Caption, 1) > 0 then
      grdEV.Columns[i].Alignment := taCenter;

    grdEV.Columns[i].OptimizeWidth;
    grdEV.Columns[i].Width := grdEV.Columns[i].Width + 10;
  end;

  grdEV.DataGrouping.Active := False;
  // gl := grdEV.DataGrouping.GroupLevels.Add;
  // gl.Column := grdev.Columns[0];
  grdEV.DataGrouping.GroupLevels.Add.Column := grdEV.Columns[0];
  grdEV.DataGrouping.GroupLevels.Add.Column := grdEV.Columns[1];
  grdEV.Columns[0].Visible := False;
  grdEV.Columns[1].Visible := False;
  grdEV.DataGrouping.Active := True;
  grdEV.DataGrouping.GroupPanelVisible := True;
end;

procedure TfraEigenvalueGrid.GetEVDatas(IDList: string);
var
  iMT, i: Integer;
  EVDatas: PEVDataArray;
  Meter: TMeterDefine;
  bGet: Boolean;
  j: Integer;
  ErrMsg: string;

  procedure ReleaseEVDatas;
  var
    ii: Integer;
  begin
    if length(EVDatas) > 0 then
      for ii := Low(EVDatas) to High(EVDatas) do
        try
          Dispose(EVDatas[ii]);
        except
        end;
    SetLength(EVDatas, 0);
  end;
begin
  FIDList.Text := IDList;
  mtEV.Close;
  cdsEV.Close;
  if FIDList.Count = 0 then
    Exit;

  prgBar.Max := FIDList.Count;
  prgBar.Position := 0;
  prgBar.Visible := True;

  IHJXClientFuncs.SessionBegin;
  IHJXClientFuncs.ClearErrMsg;
  ErrMsg := '';

  SetFields;

  for iMT := 0 to FIDList.Count - 1 do
  begin
    prgBar.Position := iMT + 1;
    prgBar.Update;

    if optLast.Checked then
      bGet := IAppServices.ClientDatas.GetEVDatas(FIDList.Strings[iMT], EVDatas)
    else
      bGet := IAppServices.ClientDatas.GetEVDataInPeriod(FIDList.Strings[iMT], dtpStart.Date,
        dtpEnd.Date, EVDatas);

    if bGet then
    begin
      Meter := ExcelMeters.Meter[FIDList.Strings[iMT]];

      if Length(EVDatas) > 0 then
        for i := low(EVDatas) to High(EVDatas) do
          with cdsEV, EVDatas[i]^ do
          begin
            try
              cdsEV.Append;
              FieldByName('Position').Value := Meter.PrjParams.Position;
              FieldByName('MeterType').Value := Meter.Params.MeterType;
              FieldByName('DesignName').Value := Meter.DesignName;
              FieldByName('PDName').Value := Meter.PDDefine[EVDatas[i].PDIndex].Name;

              FieldByName('MaxDTInLife').Value := LifeEV.MaxDate;
              FieldByName('MaxInLife').Value := LifeEV.MaxValue;
              if chkMinData.Checked then
              begin
                FieldByName('MinDTInLife').Value := LifeEV.MinDate;
                FieldByName('MinInLife').Value := LifeEV.MinValue;
              end;
              if chkIncData.Checked then
                FieldByName('IncrementInLife').Value := LifeEV.Increment;
              if chkAmplitude.Checked then
                FieldByName('AmplitudeInLife').Value := LifeEV.Amplitude;

              if chkYearEV.Checked then
              begin
                FieldByName('MaxDTInYear').Value := YearEV.MaxDate;
                FieldByName('MaxInYear').Value := YearEV.MaxValue;
                if chkMinData.Checked then
                begin
                  FieldByName('MinDTInYear').Value := YearEV.MinDate;
                  FieldByName('MinInYear').Value := YearEV.MinValue;
                end;
                if chkIncData.Checked then
                  FieldByName('IncrementInYear').Value := YearEV.Increment;
                if chkAmplitude.Checked then
                  FieldByName('AmplitudeInYear').Value := YearEV.Amplitude;
              end;

              FieldByName('DTScale').Value := CurDate;
              FieldByName('Value').Value := CurValue;

              cdsEV.Post;
            except
            end;
          end;
    end;
  end;
  cdsEV.Open;
  mtEV.Open;
  SetDisplay;
  {todo:EVDatas没有清理？}
  ReleaseEVDatas;

  ErrMsg := IHJXClientFuncs.ErrorMsg;
  if ErrMsg <> '' then
    ShowMessage('查询过程中发现以下错误：'#13#10 + ErrMsg);
  IHJXClientFuncs.SessionEnd;
  IHJXClientFuncs.ClearErrMsg
end;

procedure TfraEigenvalueGrid.mtEVBeforeEdit(DataSet: TDataSet);
begin
  // 用outdebugstr调试，mtEV.FieldByName('DesignName').AsString;
  OutputDebugString(PChar('mtEVBeforeEdit'));
  //utDebugStr(pchar(mtev))
end;

procedure TfraEigenvalueGrid.piAllowEditClick(Sender: TObject);
begin
  piAllowEdit.Checked := not piallowedit.Checked;
  if piAllowEdit.Checked then
    grdEV.AllowedOperations := [alopUpdateEh]
  else
    grdEV.AllowedOperations := [];
end;

procedure TfraEigenvalueGrid.piCopyAsHTMLClick(Sender: TObject);
var
  ms: TStringStream;
  S: string;
begin
  ms := TStringStream.Create;
  try
    WriteDBGridEhToExportStream(TDBGridEhExportAsHTML, grdEV, ms, True);
    S := ms.ReadString(ms.Size);
    WB_LoadHTML(ieBrowser, S);
    (*
      htmlMedia.LoadFromStream(ms);
      // CopyHTMLToClipboard(ms);
      htmlMedia.SelectAll;
      htmlMedia.CopyToClipboard;
      htmlMedia.SelStart := 0;
      htmlMedia.SelLength := 0;
      htmlMedia.Visible := True;

    *) Timer1.Enabled := True; // 显示生成的HTML表格几秒钟，然后隐藏起来
  finally
    ms.Free;
  end;
  // DBGridEh_DoCopyAction(grdEV, True);
end;

procedure TfraEigenvalueGrid.piCopyToClipBoardClick(Sender: TObject);
begin
  DBGridEh_DoCopyAction(grdEV, True);
end;

procedure TfraEigenvalueGrid.piCopyUseWebGridClick(Sender: TObject);
begin
  CopyAsWebGrid;
end;

procedure TfraEigenvalueGrid.piLoadDatasClick(Sender: TObject);
var i:Integer;
begin
  dlgOpen.Filter := '特征值数据文件|*.evdatas';
  dlgOpen.DefaultExt := 'evdatas';
  if dlgOpen.Execute then
  begin
    if cdsEV.Active then
      cdsev.Close;
    cdsEV.LoadFromFile(dlgOpen.FileName);
    for i := 0 to cdsev.Fields.Count -1 do
      if cdsev.Fields[i].DataType = ftFloat then
        (cdsev.Fields[i] as TNumericField).DisplayFormat := '0.00'
      else if cdsev.Fields[i].DataType = ftdatetime then
           (cdsev.Fields[i] as tdatetimefield).DisplayFormat := 'yyyy-mm-dd';
    if not mtEV.Active then mtev.Open;
    Setdisplay;
  end;
end;

procedure TfraEigenvalueGrid.piOpenExcelDataClick(Sender: TObject);
var
  Meter: TMeterDefine;
begin
  // metername := grdev.
  Meter := ExcelMeters.Meter[mtEV.FieldByName('DesignName').AsString];
  if Meter <> nil then
    ExcelIO.Excel_ShowSheet(Meter.DataBook, Meter.DataSheet);
end;

procedure TfraEigenvalueGrid.piPopupDatasClick(Sender: TObject);
begin
  //
  idf.PopupDataViewer(mtev.FieldByName('DesignName').AsString);
end;

procedure TfraEigenvalueGrid.piPopupTreandLineClick(Sender: TObject);
begin
  //
  idf.PopupDataGraph(mtev.FieldByName('DesignName').AsString);
end;

procedure TfraEigenvalueGrid.piSaveAsHTMLClick(Sender: TObject);
begin
  dlgSave.Filter := 'HTML文件|*.htm;*.html';
  dlgSave.DefaultExt := 'htm';
  if dlgSave.Execute then
    SaveDBGridEhToExportFile(TDBGridEhExportAsHTML, grdEV, dlgSave.FileName, True);
end;

procedure TfraEigenvalueGrid.piSaveAsRTFClick(Sender: TObject);
begin
  //
end;

procedure TfraEigenvalueGrid.piSaveAsXLSClick(Sender: TObject);
begin
  //
end;

/// 保存特征值查询结果，本功能用于如下目的：
/// 查询到的特征值结果可能存在需要用户修正、调整的情况，有时候未必能够一次性做完，需要较长时间
/// 才能完成此项工作，因此中间可能中断。所以需要将数据保存下来，下次加载后再继续。这个功能一般
/// 配合LoadDatas方法一起使用.
procedure TfraEigenvalueGrid.piSaveDatasClick(Sender: TObject);
begin//
  dlgSave.Filter := '特征值数据文件|*.evdatas';
  dlgSave.DefaultExt := 'evdatas';
  if dlgSave.Execute then
    cdsEV.SaveToFile(dlgsave.FileName);
end;

procedure TfraEigenvalueGrid.piUpdateMeterDataClick(Sender: TObject);
begin
  //
end;

procedure TfraEigenvalueGrid.piUpdateWordTablesClick(Sender: TObject);
begin
  //
end;

{ -----------------------------------------------------------------------------
  Procedure  : CopyAsWebGrid
  Description: 本方法将EhGrid查询、筛选结果用WebCrossView制作成HTML表格，然后
  拷贝到剪切板中，本方法力求生成的结果可以直接粘贴到Word中。
  ----------------------------------------------------------------------------- }
procedure TfraEigenvalueGrid.CopyAsWebGrid;
var
  WCV: TWebCrossView;
  Page: String;
  Body: String;
  // 根据grdEV的Title设计，设置WebGrid的表头Title行

  procedure _SetGridTitle;
  var
    i, nCols: Integer;
    iCol, iRow: Integer;
    S: string;
    SS: TStringDynArray;
  begin
    nCols := 0;
    // 隐藏的列不算数
    for i := 0 to grdEV.Columns.Count - 1 do
      if grdEV.Columns[i].Visible then
        Inc(nCols);
    WCV.ColCount := nCols;
    WCV.TitleRows := 3; // 采用3行式标题
    // 添加行: 注意，这里没有按照通行的办法按照部位和仪器类型进行分表
    for i := 0 to 2 do
      WCV.AddRow;
    // 设置表头, grdEV是3行式表头
    i := 0;
    for iCol := 0 to grdEV.Columns.Count - 1 do
    begin
      if not grdEV.Columns[iCol].Visible then
        Continue;
      // 设置表头
      S := grdEV.Columns[iCol].Field.DisplayLabel;
      SS := splitstring(S, '|');
      for iRow := 0 to 2 do
      begin
        if iRow < high(SS) then
          WCV.Cells[i, iRow].Value := SS[iRow]
        else
          WCV.Cells[i, iRow].Value := SS[High(SS)];
      end;

      if (WCV.Cells[i, 0].Value = '安装部位') or (WCV.Cells[i, 0].Value = '仪器类型') or
        (WCV.Cells[i, 0].Value = '设计编号') then
      begin
        WCV.ColHeader[i].AllowColSpan := True;
        WCV.ColHeader[i].Align := taCenter;
      end;

      // 设置列数据显示格式，主要是日期列和数字列
      case grdEV.Columns[iCol].Field.DataType of
        ftFloat:
          begin
            WCV.ColHeader[i].FormatStr := '0.00';
            WCV.ColHeader[i].Align := taRightJustify;
          end;
        ftDateTime:
          begin
            WCV.ColHeader[i].FormatStr := 'yyyy-mm-dd';
            WCV.ColHeader[i].Align := taCenter;
          end;
      end;

      Inc(i);
    end;
  end;

  procedure _AddDatas;
  var
    iCol, i, nRow: Integer;
  begin
    if mtEV.RecordCount = 0 then
      Exit;
    mtEV.First;
    repeat
      WCV.AddRow;
      nRow := WCV.RowCount - 1;
      i := 0;
      for iCol := 0 to grdEV.Columns.Count - 1 do
        if grdEV.Columns[iCol].Visible then
        begin
          WCV.Cells[i, nRow].Value := grdEV.Columns[iCol].Field.Value;
          Inc(i);
        end;
      mtEV.Next;
    until mtEV.Eof;
  end;

begin
  if (not mtEV.Active) then
    Exit;
  if mtEV.RecordCount = 0 then
    Exit;

  WCV := TWebCrossView.Create;

  WCV.HeadFormat.FontName := 'Consolas';
  WCV.HeadFormat.FontSize := 8;
  WCV.HeadFormat.BGColor := $E0E0E0;
  WCV.BodyFormat.FontName := 'Consolas';
  WCV.BodyFormat.FontSize := 8;

  try
    { todo: 生成数据的循环在这里，并根据安装部位、仪器类型进行划分表格 }
    _SetGridTitle;
    _AddDatas;
    // Page := htmPageCode2;
    Body := WCV.CrossGrid;
    Page := StringReplace(htmPageCode2, '@PageContent@', Body, []);

    // WB_LoadHTML(ieBrowser, {WCV.CrossPage}Page);
    WB_LoadHTML(ieBrowser, WCV.CrossPage { Page } );
    application.ProcessMessages;
    while ieBrowser.Busy do
      application.ProcessMessages;

    ieBrowser.ExecWB(OLECMDID_SELECTALL, 0); // SELECT ALL
    while ieBrowser.Busy do
      application.ProcessMessages;

    (*
      if (ieBrowser.QueryStatusWB(OLECMDID_COPY) = OLECMDF_ENABLED) then
      begin
      ieBrowser.ExecWB(OLECMDID_COPY, 0); // copy
      end;

    *)    // CopyHTMLToClipboard(WCV.CrossPage); //拷贝结果存在乱码
    Timer1.Enabled := True;
  finally
    WCV.Free;
  end;
end;

initialization

Oleinitialize(nil);

finalization

OleUninitialize;

end.
