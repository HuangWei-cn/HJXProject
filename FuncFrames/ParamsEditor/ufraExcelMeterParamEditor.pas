{ -----------------------------------------------------------------------------
 Unit Name: ufraExcelMeterParamEditor
 Author:    ��ΰ
 Date:      05-����-2017
 Purpose:   ����Ԫ���������Ա༭�����༭������MeterDefine�����ԡ�
            Ϊ�������û��ʹ�ø��߼������ӵ����Ա༭����������ValueListEditor
            ���б༭��
            �������������;����һ�����޸�FMeter����ĸ������ԣ��ٵ���InitParams
            ��Ԫ�е�SaveParams��������FMeter������ֱ�ӽ��༭�����ݱ��棬ͬʱ�޸�
            Fmeter���ԡ�
 History:
----------------------------------------------------------------------------- }

unit ufraExcelMeterParamEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.ValEdit, uHJX.ProjectGlobal, Vcl.ComCtrls, {uHJX.Excel.Meters,}
  uHJX.Intf.AppServices, uHJX.Classes.Meters, Vcl.Mask;

type
  TfraXLSParamEditor = class(TFrame)
    vleMeterParams: TValueListEditor;
    CategoryPanelGroup1: TCategoryPanelGroup;
    CategoryPanel1: TCategoryPanel;
    CategoryPanel2: TCategoryPanel;
    CategoryPanel3: TCategoryPanel;
    Panel1: TPanel;
    edtDesignID: TLabeledEdit;
    Button1: TButton;
    Button2: TButton;
    vlePrjParams: TValueListEditor;
    vleDataStru: TValueListEditor;
    dtpDateEdit: TDateTimePicker;
    lblSelectDatafile: TLabel;
    lblWorkBook: TLabel;
    lblWorkSheet: TLabel;
    dlgOpen: TOpenDialog;
    CategoryPanel4: TCategoryPanel;
    cmbPreDefineDataStruc: TComboBox;
    memPreDDSContent: TMemo;
    CategoryPanel5: TCategoryPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    cmbGraphDefine: TComboBox;
    cmbGridFormat: TComboBox;
    cmbXLSFormat: TComboBox;
    procedure vleMeterParamsSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure vleMeterParamsGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure dtpDateEditKeyPress(Sender: TObject; var Key: Char);
    procedure dtpDateEditChange(Sender: TObject);
    procedure vleMeterParamsGetEditMask(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure vleMeterParamsStringsChange(Sender: TObject);
    procedure vlePrjParamsStringsChange(Sender: TObject);
    procedure vleDataStruStringsChange(Sender: TObject);
    procedure edtDesignIDChange(Sender: TObject);
    procedure lblSelectDatafileDblClick(Sender: TObject);
  private
        { Private declarations }
    FMeter         : TMeterDefine;
    FParamFile     : string;
    FDLFile        : string;
    FOnGetText     : boolean;
    FprmChanged    : boolean; // �������������仯
    FprjChanged    : boolean; // �������Է����仯
    FdtsChanged    : boolean; // ���ݽṹ�����仯
    FdsgNameChanged: boolean; // ��Ʊ�ŷ����仯
    FdfChanged     : boolean; // ���ݹ��������������仯
    FNewMeter      : boolean; // �Ƿ���������
    procedure SetItemProps;
    procedure OnLogin(Sender: TObject);
    procedure Clear;
    procedure SelectDataFile; // �����û�ѡ�����ݹ�������������
    procedure DataDefineStr(dts: TDataDefines; var DefStr, FldsColStr, EVStr: string);
    procedure ShowMeterDataStruParam;
  public
        { Public declarations }
    procedure EditMeter(AMeter: TMeterDefine);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}


uses
  uHJX.Excel.InitParams, uHJX.Excel.IO{, ufrmMeterDataSelector ����TMS�����װ���⣬�����Ҳ���AdvListEditor�Ŀ⣬��ʱ��ֹ�������};

constructor TfraXLSParamEditor.Create(AOwner: TComponent);
begin
  inherited;
    // FMeters := TMeterDefines.Create;
  SetItemProps;
  // ���IAppService���ڣ���ע��OnLogin�¼�����
  if IAppServices <> nil then
      IAppServices.RegEventDemander('LoginEvent', Self.OnLogin);
end;

destructor TfraXLSParamEditor.Destroy;
begin
    // FMeters.Free;
  inherited;
end;

procedure TfraXLSParamEditor.dtpDateEditChange(Sender: TObject);
begin
  if not FOnGetText then
  begin
    vleMeterParams.Cells[1, vleMeterParams.Row] := DateToStr(dtpDateEdit.Date);
  end;
end;

procedure TfraXLSParamEditor.dtpDateEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    vleMeterParams.Cells[1, vleMeterParams.Row] := DateToStr(dtpDateEdit.Date);
    dtpDateEdit.Visible := False;
    vleMeterParams.SetFocus;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : SetItemProps
  Description: ���������ø���ValueListEdit��Item��ItemProps����
----------------------------------------------------------------------------- }
procedure TfraXLSParamEditor.SetItemProps;
begin
  with vleMeterParams do
  begin
    ItemProps['��������'].EditStyle := esPickList;
    ItemProps['��������'].PickList := pg_meterTypes;
  end;

  with vlePrjParams do
  begin
    ItemProps['���̲�λ'].EditStyle := esPickList;
    ItemProps['���̲�λ'].PickList := PG_Locations;
  end;

  with vleDataStru do
  begin
    ItemProps['�۲�������'].EditStyle := esEllipsis;
    ItemProps['����������'].EditStyle := esEllipsis;
    ItemProps['�۲�ֵ��'].EditStyle := esEllipsis;
    ItemProps['��������'].EditStyle := esEllipsis;
    ItemProps['����ֵ��'].EditStyle := esEllipsis;
  end;
end;

procedure TfraXLSParamEditor.vleDataStruStringsChange(Sender: TObject);
begin
  FdtsChanged := True;
end;

procedure TfraXLSParamEditor.vleMeterParamsGetEditMask(Sender: TObject; ACol, ARow: Integer;
  var Value: string);
begin
    // �������ָ�ʽ��mask
  case ARow of
    5, 6:
      Value := '!#9999.99;1';
    7, 10, 11:
      Value := '!99';
  end;
end;

procedure TfraXLSParamEditor.vleMeterParamsGetEditText(Sender: TObject; ACol, ARow: Integer;
  var Value: string);
begin
  if vleMeterParams.Cells[0, ARow].Contains('����') then
  begin
        // ��һ���ֿ��Կ��Ǹ�дΪһ������
    FOnGetText := True;
    dtpDateEdit.BoundsRect := vleMeterParams.CellRect(ACol, ARow);
    dtpDateEdit.Left := dtpDateEdit.Left + 4;
    dtpDateEdit.Width := dtpDateEdit.Width - 4;
    dtpDateEdit.Top := dtpDateEdit.Top + 2;
    dtpDateEdit.Visible := True;
    if Value <> '' then
        dtpDateEdit.Date := StrToDate(Value);
    FOnGetText := False;
  end
  else
      dtpDateEdit.Visible := False;
end;

procedure TfraXLSParamEditor.vleMeterParamsSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  OutputDebugString(PWideChar(Value));
// if vleMeterParams.Cells[0, ARow].Contains('����') and dtpDateEdit.Visible then
// begin
// dtpDateEdit.Visible := false;
// vleMeterParams.Cells[ACol, ARow] := DateToStr(dtpDateEdit.Date);
// // ShowMessage(value);
/// / if vleMeterParams.EditorMode then
/// / begin
/// / vleMeterParams.Cells[ACol, ARow] := DateToStr(dtpDateEdit.Date);
/// / dtpDateEdit.Visible := false;
/// / vleMeterParams.EditorMode := False;
/// / end;
// end;
end;

procedure TfraXLSParamEditor.vleMeterParamsStringsChange(Sender: TObject);
begin
  FprmChanged := True;
end;

procedure TfraXLSParamEditor.vlePrjParamsStringsChange(Sender: TObject);
begin
  FprjChanged := True;
end;

procedure TfraXLSParamEditor.Clear;
var
  i: Integer;
begin
  for i := 1 to vleMeterParams.RowCount - 1 do
      vleMeterParams.Cells[1, i] := '';
  for i := 1 to vlePrjParams.RowCount - 1 do
      vlePrjParams.Cells[1, i] := '';
  for i := 1 to vleDataStru.RowCount - 1 do
      vleDataStru.Cells[1, i] := '';
  lblWorkSheet.Caption := '';
  lblWorkBook.Caption := '';
end;

procedure TfraXLSParamEditor.DataDefineStr(dts: TDataDefines; var DefStr: string;
  var FldsColStr: string; var EVStr: string);
var
  i: Integer;
begin
  DefStr := '';
  FldsColStr := '';
  EVStr := '';
  for i := 0 to dts.Count - 1 do
  begin
    DefStr := DefStr + dts.Items[i].Name + '|';
    FldsColStr := FldsColStr + IntToStr(dts.Items[i].Column) + '|';
    if dts.Items[i].HasEV then
        EVStr := EVStr + IntToStr(i + 1) + '|'; // ����ֵ�������ʼΪ1������0
  end;
        // ȥ��β����"|"����
  if DefStr <> '' then
      DefStr := Copy(DefStr, 1, Length(DefStr) - 1);
  if FldsColStr <> '' then
      FldsColStr := Copy(FldsColStr, 1, Length(FldsColStr) - 1);
  if EVStr <> '' then
      EVStr := Copy(EVStr, 1, Length(EVStr) - 1);
end;

procedure TfraXLSParamEditor.ShowMeterDataStruParam;
var
  S1, S2, S3: string;
begin
  with vleDataStru do
  begin
    Values['������ʼ��'] := IntToStr(FMeter.DataSheetStru.DTStartRow);
    Values['������ʼ��'] := IntToStr(FMeter.DataSheetStru.DTStartCol);
    Values['��ֵ��'] := IntToStr(FMeter.DataSheetStru.BaseLine);
    Values['��ע��'] := IntToStr(FMeter.DataSheetStru.AnnoCol);
        // ������Ҫ������Ĺ۲������������ϲ���
    DataDefineStr(FMeter.DataSheetStru.MDs, S1, S2, S3);
    Values['�۲�������'] := S1;
    Values['�۲�ֵ��'] := S2;
    DataDefineStr(FMeter.DataSheetStru.PDs, S1, S2, S3);
    Values['����������'] := S1;
    Values['��������'] := S2;
    Values['����ֵ��'] := S3;
  end;
end;

procedure TfraXLSParamEditor.EditMeter(AMeter: TMeterDefine);
var
  S1, S2, S3: String;
begin
  FMeter := AMeter;
  Clear;
  edtDesignID.Text := FMeter.DesignName;
    // ��д��������---------------------------------------
  with vleMeterParams do
  begin
    Values['��������'] := FMeter.Params.MeterType;
    Values['�ͺ�'] := FMeter.Params.Model;
    Values['�������'] := FMeter.Params.SerialNo;
    Values['������ʽ'] := FMeter.Params.WorkMode;
    Values['��������'] := FloatToStr(FMeter.Params.MinValue);
    Values['��������'] := FloatToStr(FMeter.Params.MaxValue);
    Values['��װ����'] := DateTimeToStr(FMeter.Params.SetupDate);
    Values['��ֵ����'] := DateTimeToStr(FMeter.Params.BaseDate);
    Values['����������'] := IntToStr(FMeter.Params.SensorCount);
    Values['�۲���������'] := IntToStr(FMeter.Params.MDCount);
    Values['����������'] := IntToStr(FMeter.Params.PDCount);
    Values['��ע'] := FMeter.Params.Annotation;
  end;
    // ��д���̲���----------------------------------------
  with vlePrjParams do
  begin
    Values['��λ������'] := FMeter.PrjParams.SubProject;
    Values['���̲�λ'] := FMeter.PrjParams.Position;
    Values['�߳�'] := FloatToStr(FMeter.PrjParams.Elevation);
    Values['׮��'] := FMeter.PrjParams.Stake;
    Values['����'] := FMeter.PrjParams.Profile;
    Values['��ע'] := FMeter.PrjParams.Annotation;
    Values['��װ���'] := FloatToStr(FMeter.PrjParams.Deep);
  end;

// with vleDataStru do
// begin
// Values['������ʼ��'] := IntToStr(FMeter.DataSheetStru.DTStartRow);
// Values['������ʼ��'] := IntToStr(FMeter.DataSheetStru.DTStartCol);
// Values['��ֵ��'] := IntToStr(FMeter.DataSheetStru.BaseLine);
// Values['��ע��'] := IntToStr(FMeter.DataSheetStru.AnnoCol);
// // ������Ҫ������Ĺ۲������������ϲ���
// DataDefineStr(FMeter.DataSheetStru.MDs, S1, S2, S3);
// Values['�۲�������'] := S1;
// Values['�۲�ֵ��'] := S2;
// DataDefineStr(FMeter.DataSheetStru.PDs, S1, S2, S3);
// Values['����������'] := S1;
// Values['��������'] := S2;
// Values['����ֵ��'] := S3;
// end;
  ShowMeterDataStruParam;

  lblWorkSheet.Caption := FMeter.DataSheet;
  lblWorkBook.Caption := FMeter.DataBook;

  FprmChanged := False;
  FprjChanged := False;
  FdtsChanged := False;
  FdsgNameChanged := False;
  FdfChanged := False;
end;

procedure TfraXLSParamEditor.edtDesignIDChange(Sender: TObject);
begin
  FdsgNameChanged := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : SelectDataFile
  Description: �����û�ѡ��������������
  ���������û�ѡ�������ļ����г��������й������û�ѡ�񡣱�Ҫʱ��������
  ��ʾ�������ݹ��û�ʹ��
----------------------------------------------------------------------------- }
procedure TfraXLSParamEditor.SelectDataFile;
(*var
  frm: TfrmMeterDataFileSelection;*)
begin
(*
  if lblWorkBook.Caption <> '' then
      dlgOpen.FileName := lblWorkBook.Caption;
  if dlgOpen.Execute then
  begin
    frm := TfrmMeterDataFileSelection.Create(Self);
    frm.Caption := FMeter.Params.MeterType + FMeter.DesignName + '���ݱ�ṹ����';
    try
      if FMeter.DataBook = dlgOpen.FileName then
          frm.EditMeter(FMeter)
      else
          frm.EditMeter(FMeter, dlgOpen.FileName);
            // frm.LoadWorkbook(dlgOpen.FileName, lblWorkSheet.Caption);
      frm.ShowModal;
      if frm.ModalResult = mrOk then
      begin
                { DONE:����Ƿ��иı䣬���иı�Ÿ���Label���ݣ������ñ༭��־ }
        if mepcDataFile in frm.ChangedParams then
        begin
          lblWorkBook.Caption := dlgOpen.FileName;
          lblWorkSheet.Caption := frm.WorkSheet;
          if (FMeter.DataBook <> dlgOpen.FileName) or (FMeter.DataSheet <> frm.WorkSheet)
          then
          begin
            FdfChanged := True;
            FMeter.DataBook := dlgOpen.FileName;
            FMeter.DataSheet := frm.WorkSheet;
          end;
        end;
                // ������ݽṹ����仯����ʾ֮��
        FdtsChanged := mepcDataStru in frm.ChangedParams;
        if FdtsChanged then
            ShowMeterDataStruParam;
      end;
    finally
      frm.Release;
    end;
  end;
*)
end;

procedure TfraXLSParamEditor.lblSelectDatafileDblClick(Sender: TObject);
begin
  SelectDataFile;
end;

procedure TfraXLSParamEditor.OnLogin(Sender: TObject);
var
  i: Integer;
begin
  // ����¼���ݿ����Ҫ��������д����������С�
  cmbPreDefineDataStruc.Clear;
  cmbGraphDefine.Clear;
  cmbGridFormat.Clear;
  cmbXLSFormat.Clear;

  // ��дԤ�������ݽṹ

  // ͨ��������ѡ��Ԥ�������ݽṹ�󣬻�ͼ�����Excelģ��Ͷ����ˡ����ǣ������е��ǣ�
  // ���������û�ѡ��һ���Ļ�ͼ������Excel������ʽ��Ϊ��������
  // ��д�����߶���

  // �������ݱ��ʽ����

  // ��дExcel�������ʽ����

end;

end.
