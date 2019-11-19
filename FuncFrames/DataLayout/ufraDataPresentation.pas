{ -----------------------------------------------------------------------------
 Unit Name: ufraDataPresentation
 Author:    ��ΰ
 Date:      25-����-2017
 Purpose:   ����Ԫ��װ��fraDataLayout
            ����Ԫ����fraDataLayout�����ݷ��ʽ���֮�䣬�ṩ���ݷ��ʡ��û�����
            �ȹ��ܣ���fraDataLayout��������Դ�������ݷֲ�ͼ��ʾ���ܡ�
 History:
    2018-06-14 ��������ʾ���������Ĺ��ܣ���ֻ����ʾ��������
----------------------------------------------------------------------------- }
{ DONE:������ʾ�������ݱ��� }
{ DONE:������ʾ���������߹��� }
{ todo:������ʾ��������ֵ���� }
{ todo:���Ӹ�����ʾָ������s�Ĺ��� }
unit ufraDataPresentation;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufraDataLayout, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls,
  uHJX.Intf.Datas, {uHJX.Excel.Meters} uHJX.Classes.Meters, uHJX.Intf.AppServices, uHJX.Data.Types,
  uHJX.Intf.FunctionDispatcher, Vcl.Menus;

type
  TfraDataPresentation = class(TFrame)
    pnlFuncs: TPanel;
    fraDataLayout: TfraDataLayout;
    btnLastDatas: TButton;
    dtpSpecialDate: TDateTimePicker;
    btnClearDatas: TButton;
    btnLoadLayout: TButton;
    dlgOpenDataLayout: TOpenDialog;
    btnSpecialDate: TButton;
    popLayoutList: TPopupMenu;
    chkShowIncrement: TCheckBox;
    procedure btnLoadLayoutClick(Sender: TObject);
    procedure btnClearDatasClick(Sender: TObject);
    procedure btnLastDatasClick(Sender: TObject);
    procedure btnSpecialDateClick(Sender: TObject);
  private
        { Private declarations }
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
    //2019-11-19
    procedure OnAppIdle(Sender:TObject);

    procedure DatabaseOpened(Sender: TObject);
  public
        { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}


constructor TfraDataPresentation.Create(AOwner: TComponent);
begin
  inherited;
  fraDataLayout.OnNeedDataEvent := Self.OnNeedData;
  fraDataLayout.OnNeedIncrementEvent := Self.OnNeedIncrement;
  fraDataLayout.OnNeedDeformEvent := self.OnNeedDeformData;
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
  iappservices.RegEventDemander('OnIdleEvent', Self.OnAppIdle);
end;

procedure TfraDataPresentation.btnClearDatasClick(Sender: TObject);
begin
  fraDataLayout.ClearDatas;
end;

procedure TfraDataPresentation.btnLastDatasClick(Sender: TObject);
begin
  FDataOpts := 0;
  fraDataLayout.Play(chkShowIncrement.Checked);
end;

procedure TfraDataPresentation.btnLoadLayoutClick(Sender: TObject);
begin
  if dlgOpenDataLayout.Execute then
      fraDataLayout.LoadDataLayout(dlgOpenDataLayout.FileName);
end;

procedure TfraDataPresentation.btnSpecialDateClick(Sender: TObject);
begin
  FDataOpts := 1;
  fraDataLayout.Play;
end;

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
----------------------------------------------------------------------------- }
procedure TfraDataPresentation.OnNeedIncrement(AID: string; ADataName: string; var Data: Variant;
  var DT: TDateTime);
var
  Datas: TVariantDynArray;
  sType: string;
  i    : integer;
  function FormatData(D: Variant): String;
  begin
    if (VarIsEmpty(D)) or (VarIsNull(D)) or (vartostr(D) = '') then
        Result := ''
    else if VarIsFloat(D) then
        Result := FormatFloat('0.00', D);
  end;

begin
// if FDataOpts = 0 then
// DT := now
// else
// DT := dtpSpecialDate.DateTime;
  Data := Null;
  DT := now;
  if IHJXClientFuncs = nil then
      exit;
  IHJXClientFuncs.SessionBegin;
  if IHJXClientFuncs.GetDataIncrement(AID, DT, Datas) then
  begin
      { 2019-08-06 ��ѯ����������Ϊ��ѯ��������ֵ���Ե�������˷��ص������а�������ֵ��˳�����м�¼ }
        (* i := ExcelMeters.Meter[AID].PDDefines.IndexOfDataName(ADataName); *)
    for i := 0 to High(Datas) do
    begin
      if ADataName = Datas[i][0] then
      begin
        sType := ExcelMeters.Meter[AID].Params.MeterType;
        DT := Datas[i][1];
        Data := FormatData(Datas[i][3]);
        if Datas[i][4] > 0 then
            Data := Data + '����' + FormatData(Datas[i][4])
        else if Datas[i][4] < 0 then
            Data := Data + '����' + FormatData(Datas[i][4])
        else
            Data := Data + '����' + FormatData(Datas[i][4]);
      end;
    end;
        (*
        sType := ExcelMeters.Meter[AID].Params.MeterType;
        if i <> -1 then
        begin

            if (sType = 'ê��������') or (sType = 'ê��Ӧ����') then
            begin
                DT := Datas[0][1];
                Data := FormatData(Datas[0][3]);
                if Datas[0][4] > 0 then
                    Data := Data + '����' + FormatData(Datas[0][4])
                else if Datas[0][4] < 0 then
                    Data := Data + '����' + FormatData(Datas[0][4])
                else
                    Data := Data + '����' + FormatData(Datas[0][4]);
            end
            else if sType = '���λ�Ƽ�' then
            begin
                DT := Datas[i][1];
                Data := FormatData(Datas[i][3]);
                if Datas[i][4] > 0 then
                    Data := Data + '����' + FormatData(Datas[i][4])
                else if Datas[i][4] < 0 then
                    Data := Data + '����' + FormatData(Datas[i][4])
                else
                    Data := Data + '����' + FormatData(Datas[i][4]);
            end;

          DT := Datas[i][1];
          Data := FormatData(Datas[i][3]);
          if Datas[i][4] > 0 then
              Data := Data + '����' + FormatData(Datas[i][4])
          else if Datas[i][4] < 0 then
              Data := Data + '����' + FormatData(Datas[i][4])
          else
              Data := Data + '����' + FormatData(Datas[i][4]);
        end;
 *)
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
    fradatalayout.sgDataLayout.Invalidate;
  end;
end;

end.
