{ -----------------------------------------------------------------------------
 Unit Name: ufraDataPresentation
 Author:    ��ΰ
 Date:      25-����-2017
 Purpose:   ����Ԫ��װ��fraDataLayout
            ����Ԫ����fraDataLayout�����ݷ��ʽ���֮�䣬�ṩ���ݷ��ʡ��û�����
            �ȹ��ܣ���fraDataLayout��������Դ�������ݷֲ�ͼ��ʾ���ܡ�
 History:
    2018-06-14 ��������ʾ���������Ĺ��ܣ���ֻ����ʾ��������
    2021-11-09 �����˽��湦�ܲ��֣���������ʾ�����Ĺ��ܣ������ѯ�û�ָ��ʱ��
    �ε�����������
----------------------------------------------------------------------------- }
{ DONE:������ʾ�������ݱ��� }
{ DONE:������ʾ���������߹��� }
{ todo:������ʾ��������ֵ���� }
{ todo:���Ӹ�����ʾָ������s�Ĺ��� }
{ todo:���ӽ��򿪵Ĳ���ͼ��ӵ�����ͼ�б��еĹ��� }
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

    { todo:�ж�һ�£�IFunctionDispatcher����Щ�����Ƿ���ã������������� }
  fraDataLayout.OnMeterClickEvent := Self.OnMeterClick;
  fraDataLayout.OnPopupDataGraph := Self.OnPopupDataGraph;
  fraDataLayout.OnPopupDataViewer := Self.OnPopupDataViewer;
  fraDataLayout.OnPlayBeginning := OnPlayBeginning;
  fraDataLayout.OnPlayFinished := OnPlayFinished;

    // ע�����������ݿ��¼�¼�
    { todo:��Ӧ�ڴ˴�ʹ��IAppServices����ʹ��ǰ��Ҫ�жϸýӿ��Ƿ���Ч }
  IAppServices.RegEventDemander('LoginEvent', Self.DatabaseOpened);
  IAppServices.RegEventDemander('OnIdleEvent', Self.OnAppIdle);
end;

procedure TfraDataPresentation.btnClearDatasClick(Sender: TObject);
begin
  fraDataLayout.ClearDatas;
end;

{ -----------------------------------------------------------------------------
  Procedure  : btnQryIncClick
  Description: btnQryIncǰ����btnLastData��ԭ�����ڲ�ѯ�������ݻ��߲�ѯ����
  �����������޸�Ϊר�Ų�ѯ��������
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.btnQryIncClick(Sender: TObject);
begin
  // FDataOpts := 0; //0-Now
  // fraDataLayout.Play(chkShowIncrement.Checked);
  fraDataLayout.Play(True); // ��ѯ����
  { ���������Ĳ�ѯ��ʽ�����ڱ���Ԫ��ʵ�֣�fraDataLayoutֻ������ʾ�����
    �ڱ������У������Ĳ�ѯ��ʽ�У�����������������������������������ָ��ʱ�����������
    ���У�ǰ4�֣����Ͳ�ѯ���ݹ����е��Ǹ������йأ������Ǹ�����Ϊʱ����ѯһ�������
    ��������
    ֻ�С�ָ��ʱ��������������ܣ����õ���������ѯGroupBox�е���������ѡ�� }
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
  Description: btnSpecialDate��ѯָ�����ڵĹ۲����ݣ������¹۲����ݣ�����ѯ������
  Ҫ��ѯ�������ݣ�ֻҪ����������Ϊ���켴�ɡ�
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.btnSpecialDateClick(Sender: TObject);
begin
  // ������������Ƿ��ǽ��죬����ǽ�����FDataOpts����Ϊ0������ѯ�������ݣ���������������
  if DateOf(dtpSpecialDate.Date) = DateOf(now) then
      FDataOpts := 0
  else
      FDataOpts := 1;
  // 1-ָ�����ڡ�ͨ��������ص�ʱ���Ѿ��Զ�����������Ϊ������
  fraDataLayout.Play;
end;

procedure TfraDataPresentation.cbxIncOptionsClick(Sender: TObject);
begin
  dtpStartDate.Enabled := cbxIncOptions.ItemIndex = 4;
  dtpEndDate.Enabled := cbxIncOptions.ItemIndex = 4;
end;

{ -----------------------------------------------------------------------------
  Procedure  : chkShowIncrementClick
  Description: �������������
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.chkShowIncrementClick(Sender: TObject);
begin
  // ȡ����chkShowIncrement�ؼ�����������������
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
  if S = 'ƽ��λ�Ʋ��' then
      Param := 'λ��ʸ��ͼ'
  else if S = '��б��' then
      Param := '��б��ƫ��ͼ'
  else
      Param := '��ʱ������';
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
  Description: �����ݿ��¼/���¼�����Ӧ��
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.DatabaseOpened(Sender: TObject);
var
  i  : integer;
  Rec: PLayoutRec;
  mi : TMenuItem;
begin
    // ��PopLayoutList�˵�����Ӳ���ͼ
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
  Description: 2018-06-07 �����˲���ͼ�б�˵���ĵ����Ӧ���򿪲���ͼ
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
  Description: 2018-06-14 ��������Ӧ��ʾ�����¼��ķ���
  �˴����õ�������ѯ������ֱ�ӵ���IClientDatas�еķ��������������������жԲ�ͬ
  ���ڸ���ѯһ�Σ��ټ��������ķ�����
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.OnNeedIncrement(AID: string; ADataName: string; var Data: Variant;
  var DT: TDateTime);
var
  Datas       : TVariantDynArray;
  sType       : string;
  i           : integer;
  iIncDays    : integer;
  iInteralDays: integer;   // ʵ�ʲ�ѯ������ʱ����
  dt0         : TDateTime; // ʵ�ʲ�ѯ������ʼ����
  sDT         : String;    // ��ʾ������ֹʱ��ͼ������
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
    0: { �������� }
      GetData := IHJXClientFuncs.GetDataIncrement(AID, DT, Datas);
    // 4: { ָ����ֹ���� };
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

        iInteralDays := Datas[i][2];      // ʵ�ʼ������
        dt0 := IncDay(DT, -iInteralDays); // ʵ����ʼ����
        sDT := '#������ֹ����: ' + formatdatetime('yyyy-mm-dd', dt0) + ' ~ ' + formatdatetime('yyyy-mm-dd',
          DT) + #13#10 + '�������: ' + FormatData(iInteralDays);

        Data := FormatData(Datas[i][3]);
        if Datas[i][4] > 0 then
            Data := Data + '����' + FormatData(Datas[i][4])
        else if Datas[i][4] < 0 then
            Data := Data + '����' + FormatData(Datas[i][4])
        else
            Data := Data + '����' + FormatData(Datas[i][4]);
        //2021-11-09 ע�⣺����������������������е���ֹʱ��ͼ��������������ΪHint
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
  ShowMessage('���ݸ������.');
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
