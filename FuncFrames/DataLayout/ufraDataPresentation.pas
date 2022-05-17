{ -----------------------------------------------------------------------------
 Unit Name: ufraDataPresentation
 Author:    黄伟
 Date:      25-四月-2017
 Purpose:   本单元包装了fraDataLayout
            本单元介于fraDataLayout和数据访问界面之间，提供数据访问、用户操作
            等功能，而fraDataLayout保留了相对纯粹的数据分布图显示功能。
 History:
    2018-06-14 增加了显示数据增量的功能，但只能显示最新增量
    2021-11-09 调整了界面功能布局，调整了显示增量的功能，允许查询用户指定时间
    段的数据增量。
----------------------------------------------------------------------------- }
{ DONE:增加显示仪器数据表功能 }
{ DONE:增加显示仪器过程线功能 }
{ todo:增加显示仪器特征值功能 }
{ todo:增加高亮显示指定仪器s的功能 }
{ todo:增加将打开的布置图添加到布置图列表中的功能 }
unit ufraDataPresentation;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Types,
  System.DateUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufraDataLayout, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls,
  uHJX.Intf.Datas, {uHJX.Excel.Meters} uHJX.Classes.Meters, uHJX.Intf.AppServices, uHJX.Data.Types,
  uHJX.Intf.FunctionDispatcher, Vcl.Menus, sFrameAdapter, Vcl.Buttons, System.ImageList, Vcl.ImgList;

type
  TfraDataPresentation = class(TFrame)
    pnlFuncs: TPanel;
    btnQryInc: TButton;
    dtpSpecialDate: TDateTimePicker;
    btnClearDatas: TButton;
    btnLoadLayout: TButton;
    dlgOpenDataLayout: TOpenDialog;
    btnSpecialDate: TButton;
    popLayoutList: TPopupMenu;
    chkShowIncrement: TCheckBox;
    cbxIncOptions: TComboBox;
    gbx01: TGroupBox;
    gbxQueryData: TGroupBox;
    gbxInc: TGroupBox;
    dtpStartDate: TDateTimePicker;
    dtpEndDate: TDateTimePicker;
    btnFillinData: TButton;
    btnHideData: TButton;
    ImageList1: TImageList;
    BitBtnLoadLayout: TBitBtn;
    BitBtnClearDatas: TBitBtn;
    BitBtnQuerySpecialDate: TBitBtn;
    BitBtnQryIncData: TBitBtn;
    BitBtnFillInData: TBitBtn;
    BitBtnListAllGraphObjects: TBitBtn;
    GroupBox1: TGroupBox;
    procedure btnLoadLayoutClick(Sender: TObject);
    procedure btnClearDatasClick(Sender: TObject);
    procedure btnQryIncClick(Sender: TObject);
    procedure btnSpecialDateClick(Sender: TObject);
    procedure chkShowIncrementClick(Sender: TObject);
    procedure cbxIncOptionsClick(Sender: TObject);
    procedure btnFillinDataClick(Sender: TObject);
    procedure btnHideDataClick(Sender: TObject);
  private
        { Private declarations }
    fraDataLayout: TfraDataLayout;
    FDataOpts: integer; // 0-last; 1-special;
    FDTScale : TDateTime;
    procedure OnNeedData(AID: string; ADataName: string; var Data: Variant; var DT: TDateTime);
    procedure OnNeedIncrement(AID: string; ADataName: string; var Data: Variant;
      var DT: TDateTime);

    procedure OnNeedDeformData(AID: string; XName, YName: string; var XData: Variant;
      var YData: Variant; var DT: TDateTime);

    procedure OnMeterClick(AID: string; var Param: string);
    procedure OnPopupDataViewer(AID: string; var Param: string);
    procedure OnPopupDataGraph(AID: string; var Param: string);
    procedure OnLayoutItemClick(Sender: TObject);
    procedure OnPlayBeginning(Sender: TObject);
    procedure OnPlayFinished(Sender: TObject);
    // 2019-11-19
    procedure OnAppIdle(Sender: TObject);

    procedure DatabaseOpened(Sender: TObject);
  public
        { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

implementation

USES uHJX.EnvironmentVariables;
{$R *.dfm}


constructor TfraDataPresentation.Create(AOwner: TComponent);
begin
  inherited;
  fraDataLayout := TfraDataLayout.Create(Self);
  fraDataLayout.Parent := Self;
  fraDataLayout.Align :=alClient;
  fraDataLayout.OnNeedDataEvent := Self.OnNeedData;
  fraDataLayout.OnNeedIncrementEvent := Self.OnNeedIncrement;
  fraDataLayout.OnNeedDeformEvent := Self.OnNeedDeformData;
  dtpSpecialDate.Date := now;

    { todo:判断一下，IFunctionDispatcher中这些功能是否可用，若可用再设置 }
  fraDataLayout.OnMeterClickEvent := Self.OnMeterClick;
  fraDataLayout.OnPopupDataGraph := Self.OnPopupDataGraph;
  fraDataLayout.OnPopupDataViewer := Self.OnPopupDataViewer;
  fraDataLayout.OnPlayBeginning := OnPlayBeginning;
  fraDataLayout.OnPlayFinished := OnPlayFinished;

    // 注册请求发送数据库登录事件
    { todo:不应在此处使用IAppServices，且使用前需要判断该接口是否有效 }
  IAppServices.RegEventDemander('LoginEvent', Self.DatabaseOpened);
  IAppServices.RegEventDemander('OnIdleEvent', Self.OnAppIdle);
end;

procedure TfraDataPresentation.btnClearDatasClick(Sender: TObject);
begin
  fraDataLayout.ClearDatas;
end;

{ -----------------------------------------------------------------------------
  Procedure  : btnQryIncClick
  Description: btnQryInc前身是btnLastData。原本用于查询最新数据或者查询最新
  增量，现在修改为专门查询数据增量
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.btnQryIncClick(Sender: TObject);
begin
  // FDataOpts := 0; //0-Now
  // fraDataLayout.Play(chkShowIncrement.Checked);
  fraDataLayout.Play(True); // 查询增量
  { 具体增量的查询方式，则在本单元中实现，fraDataLayout只负责显示结果。
    在本功能中，增量的查询方式有：最新增量、周增量、月增量、年增量、指定时间段内增量。
    其中，前4种，均和查询数据功能中的那个日期有关，即以那个日期为时间点查询一定间隔内
    的增量。
    只有“指定时间段内增量”功能，采用的是增量查询GroupBox中的两个日期选择。 }
end;

procedure TfraDataPresentation.btnFillinDataClick(Sender: TObject);
begin
  fraDataLayout.PopupEditorWindow;
end;

procedure TfraDataPresentation.btnHideDataClick(Sender: TObject);
begin
  fraDataLayout.PopupGraphObjList;
end;

procedure TfraDataPresentation.btnLoadLayoutClick(Sender: TObject);
begin
  dlgOpenDataLayout.InitialDir := ENV_SchemePath;
  if dlgOpenDataLayout.Execute then
      fraDataLayout.LoadDataLayout(dlgOpenDataLayout.FileName);
end;

{ -----------------------------------------------------------------------------
  Procedure  : btnSpecialDateClick
  Description: btnSpecialDate查询指定日期的观测数据，或最新观测数据（不查询增量）
  要查询最新数据，只要将日期设置为今天即可。
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.btnSpecialDateClick(Sender: TObject);
begin
  // 检查日期设置是否是今天，如果是今天则将FDataOpts设置为0，即查询最新数据，否则按照日期来查
  if DateOf(dtpSpecialDate.Date) = DateOf(now) then
      FDataOpts := 0
  else
      FDataOpts := 1;
  // 1-指定日期。通常程序加载的时候已经自动将日期设置为当天了
  fraDataLayout.Play;
end;

procedure TfraDataPresentation.cbxIncOptionsClick(Sender: TObject);
begin
  dtpStartDate.Enabled := cbxIncOptions.ItemIndex = 4;
  dtpEndDate.Enabled := cbxIncOptions.ItemIndex = 4;
end;

{ -----------------------------------------------------------------------------
  Procedure  : chkShowIncrementClick
  Description: 这个方法作废了
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.chkShowIncrementClick(Sender: TObject);
begin
  // 取消了chkShowIncrement控件，因此这个方法作废
  cbxIncOptions.Visible := chkShowIncrement.Checked;
end;

{ -----------------------------------------------------------------------------
  Procedure  : OnNeedData
  Description:
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.OnNeedData(AID: string; ADataName: string; var Data: Variant;
  var DT: TDateTime);
var
  Datas: TDoubleDynArray;
  i    : integer;
begin
  if FDataOpts = 0 then
      DT := now
  else
      DT := dtpSpecialDate.DateTime;
  Data := Null;

  if IHJXClientFuncs = nil then
      exit;
  IHJXClientFuncs.SessionBegin;
  if IHJXClientFuncs.GetNearestPDDatas(AID, DT, Datas) then
  begin
    i := ExcelMeters.Meter[AID].PDDefines.IndexOfDataName(ADataName);
    if i <> -1 then
    begin
      DT := Datas[0];
      Data := Datas[i + 1];
    end;
  end;
  IHJXClientFuncs.SessionEnd;
  SetLength(Datas, 0);
end;

procedure TfraDataPresentation.OnMeterClick(AID: string; var Param: string);
var
  S: string;
begin
  S := IAppServices.ClientDatas.GetMeterTypeName(AID);
  if S = '平面位移测点' then
      Param := '位移矢量图'
  else if S = '测斜孔' then
      Param := '测斜孔偏移图'
  else
      Param := '历时过程线';
end;

procedure TfraDataPresentation.OnPopupDataViewer(AID: string; var Param: string);
begin
  (IAppServices.FuncDispatcher as IFunctionDispatcher).PopupDataViewer(AID, nil);
end;

procedure TfraDataPresentation.OnPopupDataGraph(AID: string; var Param: string);
begin
  (IAppServices.FuncDispatcher as IFunctionDispatcher).PopupDataGraph(AID, nil);
end;

{ -----------------------------------------------------------------------------
  Procedure  : DatabaseOpened
  Description: 对数据库登录/打开事件的响应。
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.DatabaseOpened(Sender: TObject);
var
  i  : integer;
  Rec: PLayoutRec;
  mi : TMenuItem;
begin
    // 向PopLayoutList菜单中添加布置图
  for i := popLayoutList.Items.Count - 1 downto 0 do
      popLayoutList.Items[i].Free;

  for i := 0 to Layouts.Count - 1 do
  begin
    mi := popLayoutList.CreateMenuItem;
    popLayoutList.Items.Add(mi);
    mi.Caption := Layouts.Items[i].Name;
    mi.OnClick := Self.OnLayoutItemClick;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : OnLayoutItemClick
  Description: 2018-06-07 增加了布置图列表菜单项的点击响应：打开布置图
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.OnLayoutItemClick(Sender: TObject);
var
  mi: TMenuItem;
  i : integer;
begin
  mi := Sender as TMenuItem;
  i := popLayoutList.Items.IndexOf(mi);
  fraDataLayout.LoadDataLayout(Layouts.Items[i].FileName);
end;

{ -----------------------------------------------------------------------------
  Procedure  : OnNeedIncrement
  Description: 2018-06-14 增加了相应显示增量事件的方法
  此处采用的增量查询方法是直接调用IClientDatas中的方法，而不是速览功能中对不同
  日期各查询一次，再计算增量的方法。
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.OnNeedIncrement(AID: string; ADataName: string; var Data: Variant;
  var DT: TDateTime);
var
  Datas       : TVariantDynArray;
  sType       : string;
  i           : integer;
  iIncDays    : integer;
  iInteralDays: integer;   // 实际查询的两次时间间隔
  dt0         : TDateTime; // 实际查询到的起始日期
  sDT         : String;    // 显示数据起止时间和间隔天数
  GetData     : Boolean;
  function FormatData(D: Variant): String;
  begin
    if (VarIsEmpty(D)) or (VarIsNull(D)) or (vartostr(D) = '') then
        Result := ''
    else if VarIsNumeric(D) then
        Result := FormatFloat('0.00', D);
  end;

begin
// if FDataOpts = 0 then
// DT := now
// else
// DT := dtpSpecialDate.DateTime;
  Data := Null;
  DT := dtpSpecialDate.Date;
  if IHJXClientFuncs = nil then
      exit;
  IHJXClientFuncs.SessionBegin;

  case cbxIncOptions.ItemIndex of
    0: { 最新增量 }
      GetData := IHJXClientFuncs.GetDataIncrement(AID, DT, Datas);
    // 4: { 指定起止日期 };
  else
    begin
      case cbxIncOptions.ItemIndex of
        1: iIncDays := 7;
        2: iIncDays := 30;
        3: iIncDays := 365;
        4: iIncDays := DaysBetween(dtpStartDate.Date, dtpEndDate.Date)
      end;
      GetData := IHJXClientFuncs.GetDataIncrement2(AID, DT, iIncDays, Datas);
    end;
  end;

  if GetData then
  begin
    for i := 0 to High(Datas) do
    begin
      if ADataName = Datas[i][0] then
      begin
        sType := ExcelMeters.Meter[AID].Params.MeterType;
        DT := Datas[i][1];

        iInteralDays := Datas[i][2];      // 实际间隔天数
        dt0 := IncDay(DT, -iInteralDays); // 实际起始日期
        sDT := '#数据起止日期: ' + formatdatetime('yyyy-mm-dd', dt0) + ' ~ ' + formatdatetime('yyyy-mm-dd',
          DT) + #13#10 + '间隔天数: ' + FormatData(iInteralDays);

        Data := FormatData(Datas[i][3]);
        if Datas[i][4] > 0 then
            Data := Data + '；↑' + FormatData(Datas[i][4])
        else if Datas[i][4] < 0 then
            Data := Data + '；↓' + FormatData(Datas[i][4])
        else
            Data := Data + '；△' + FormatData(Datas[i][4]);
        //2021-11-09 注意：在这里添加了增量数据特有的起止时间和间隔天数，用来作为Hint
        Data := Data + sDT;
      end;
    end;
  end;
  IHJXClientFuncs.SessionEnd;

  for i := Low(Datas) to high(Datas) do
      VarClear(Datas[i]);
  SetLength(Datas, 0);
end;

procedure TfraDataPresentation.OnPlayBeginning(Sender: TObject);
begin
  IAppServices.ClientDatas.SessionBegin;
end;

procedure TfraDataPresentation.OnPlayFinished(Sender: TObject);
begin
  IAppServices.ClientDatas.SessionEnd;
  ShowMessage('数据更新完毕.');
end;

procedure TfraDataPresentation.OnNeedDeformData(AID: string; XName: string; YName: string;
  var XData: Variant; var YData: Variant; var DT: TDateTime);
var
  Datas: TDoubleDynArray;
  i    : integer;
begin
  if FDataOpts = 0 then
      DT := now
  else
      DT := dtpSpecialDate.DateTime;
  XData := Null;
  YData := Null;

  if IHJXClientFuncs = nil then exit;
  IHJXClientFuncs.SessionBegin;
  if IHJXClientFuncs.GetNearestPDDatas(AID, DT, Datas) then
  begin
    i := ExcelMeters.Meter[AID].PDDefines.IndexOfDataName(XName);
    if i <> -1 then
    begin
      DT := Datas[0];
      XData := Datas[i + 1];
    end;

    i := ExcelMeters.Meter[AID].PDDefines.IndexOfDataName(YName);
    if i <> -1 then YData := Datas[i + 1];
  end;
  IHJXClientFuncs.SessionEnd;
  SetLength(Datas, 0);
end;

procedure TfraDataPresentation.OnAppIdle(Sender: TObject);
begin
  if fraDataLayout.sgDataLayout.PZState = 1 then
  begin
    fraDataLayout.sgDataLayout.PZState := 0;
    fraDataLayout.sgDataLayout.Invalidate;
  end;
end;

end.
