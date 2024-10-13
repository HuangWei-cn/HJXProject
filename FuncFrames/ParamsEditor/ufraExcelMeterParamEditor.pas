{ -----------------------------------------------------------------------------
 Unit Name: ufraExcelMeterParamEditor
 Author:    黄伟
 Date:      05-五月-2017
 Purpose:   本单元是仪器属性编辑器，编辑给定的MeterDefine的属性。
            为简单起见，没有使用更高级更复杂的属性编辑器，而是用ValueListEditor
            进行编辑。
            保存参数有两种途径，一是先修改FMeter对象的各个属性，再调用InitParams
            单元中的SaveParams函数保存FMeter；二是直接将编辑器内容保存，同时修改
            Fmeter属性。
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
    FprmChanged    : boolean; // 仪器参数发生变化
    FprjChanged    : boolean; // 工程属性发生变化
    FdtsChanged    : boolean; // 数据结构发生变化
    FdsgNameChanged: boolean; // 设计编号发生变化
    FdfChanged     : boolean; // 数据工作簿或工作表发生变化
    FNewMeter      : boolean; // 是否是新仪器
    procedure SetItemProps;
    procedure OnLogin(Sender: TObject);
    procedure Clear;
    procedure SelectDataFile; // 允许用户选择数据工作簿及工作表
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
  uHJX.Excel.InitParams, uHJX.Excel.IO{, ufrmMeterDataSelector 可能TMS组件安装问题，导致找不到AdvListEditor的库，暂时禁止这个功能};

constructor TfraXLSParamEditor.Create(AOwner: TComponent);
begin
  inherited;
    // FMeters := TMeterDefines.Create;
  SetItemProps;
  // 如果IAppService存在，则注册OnLogin事件需求
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
  Description: 本方法设置各个ValueListEdit的Item的ItemProps属性
----------------------------------------------------------------------------- }
procedure TfraXLSParamEditor.SetItemProps;
begin
  with vleMeterParams do
  begin
    ItemProps['仪器类型'].EditStyle := esPickList;
    ItemProps['仪器类型'].PickList := pg_meterTypes;
  end;

  with vlePrjParams do
  begin
    ItemProps['工程部位'].EditStyle := esPickList;
    ItemProps['工程部位'].PickList := PG_Locations;
  end;

  with vleDataStru do
  begin
    ItemProps['观测量名称'].EditStyle := esEllipsis;
    ItemProps['物理量名称'].EditStyle := esEllipsis;
    ItemProps['观测值列'].EditStyle := esEllipsis;
    ItemProps['物理量列'].EditStyle := esEllipsis;
    ItemProps['特征值项'].EditStyle := esEllipsis;
  end;
end;

procedure TfraXLSParamEditor.vleDataStruStringsChange(Sender: TObject);
begin
  FdtsChanged := True;
end;

procedure TfraXLSParamEditor.vleMeterParamsGetEditMask(Sender: TObject; ACol, ARow: Integer;
  var Value: string);
begin
    // 设置数字格式的mask
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
  if vleMeterParams.Cells[0, ARow].Contains('日期') then
  begin
        // 这一部分可以考虑改写为一个方法
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
// if vleMeterParams.Cells[0, ARow].Contains('日期') and dtpDateEdit.Visible then
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
        EVStr := EVStr + IntToStr(i + 1) + '|'; // 特征值项序号起始为1，不是0
  end;
        // 去掉尾部的"|"符号
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
    Values['日期起始行'] := IntToStr(FMeter.DataSheetStru.DTStartRow);
    Values['日期起始列'] := IntToStr(FMeter.DataSheetStru.DTStartCol);
    Values['初值行'] := IntToStr(FMeter.DataSheetStru.BaseLine);
    Values['备注列'] := IntToStr(FMeter.DataSheetStru.AnnoCol);
        // 下面需要将分离的观测量和物理量合并：
    DataDefineStr(FMeter.DataSheetStru.MDs, S1, S2, S3);
    Values['观测量名称'] := S1;
    Values['观测值列'] := S2;
    DataDefineStr(FMeter.DataSheetStru.PDs, S1, S2, S3);
    Values['物理量名称'] := S1;
    Values['物理量列'] := S2;
    Values['特征值项'] := S3;
  end;
end;

procedure TfraXLSParamEditor.EditMeter(AMeter: TMeterDefine);
var
  S1, S2, S3: String;
begin
  FMeter := AMeter;
  Clear;
  edtDesignID.Text := FMeter.DesignName;
    // 填写仪器参数---------------------------------------
  with vleMeterParams do
  begin
    Values['仪器类型'] := FMeter.Params.MeterType;
    Values['型号'] := FMeter.Params.Model;
    Values['出厂编号'] := FMeter.Params.SerialNo;
    Values['工作方式'] := FMeter.Params.WorkMode;
    Values['量程下限'] := FloatToStr(FMeter.Params.MinValue);
    Values['量程上限'] := FloatToStr(FMeter.Params.MaxValue);
    Values['安装日期'] := DateTimeToStr(FMeter.Params.SetupDate);
    Values['初值日期'] := DateTimeToStr(FMeter.Params.BaseDate);
    Values['传感器数量'] := IntToStr(FMeter.Params.SensorCount);
    Values['观测数据数量'] := IntToStr(FMeter.Params.MDCount);
    Values['物理量数量'] := IntToStr(FMeter.Params.PDCount);
    Values['备注'] := FMeter.Params.Annotation;
  end;
    // 填写工程参数----------------------------------------
  with vlePrjParams do
  begin
    Values['单位工程名'] := FMeter.PrjParams.SubProject;
    Values['工程部位'] := FMeter.PrjParams.Position;
    Values['高程'] := FloatToStr(FMeter.PrjParams.Elevation);
    Values['桩号'] := FMeter.PrjParams.Stake;
    Values['断面'] := FMeter.PrjParams.Profile;
    Values['备注'] := FMeter.PrjParams.Annotation;
    Values['安装深度'] := FloatToStr(FMeter.PrjParams.Deep);
  end;

// with vleDataStru do
// begin
// Values['日期起始行'] := IntToStr(FMeter.DataSheetStru.DTStartRow);
// Values['日期起始列'] := IntToStr(FMeter.DataSheetStru.DTStartCol);
// Values['初值行'] := IntToStr(FMeter.DataSheetStru.BaseLine);
// Values['备注列'] := IntToStr(FMeter.DataSheetStru.AnnoCol);
// // 下面需要将分离的观测量和物理量合并：
// DataDefineStr(FMeter.DataSheetStru.MDs, S1, S2, S3);
// Values['观测量名称'] := S1;
// Values['观测值列'] := S2;
// DataDefineStr(FMeter.DataSheetStru.PDs, S1, S2, S3);
// Values['物理量名称'] := S1;
// Values['物理量列'] := S2;
// Values['特征值项'] := S3;
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
  Description: 允许用户选择工作簿及工作表
  本方法令用户选择工作簿文件，列出其中所有工作表供用户选择。必要时开打工作表
  显示其中内容供用户使用
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
    frm.Caption := FMeter.Params.MeterType + FMeter.DesignName + '数据表结构定义';
    try
      if FMeter.DataBook = dlgOpen.FileName then
          frm.EditMeter(FMeter)
      else
          frm.EditMeter(FMeter, dlgOpen.FileName);
            // frm.LoadWorkbook(dlgOpen.FileName, lblWorkSheet.Caption);
      frm.ShowModal;
      if frm.ModalResult = mrOk then
      begin
                { DONE:检查是否有改变，若有改变才更改Label内容，并设置编辑标志 }
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
                // 如果数据结构定义变化，显示之：
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
  // 当登录数据库后，需要将设置填写到各个组件中。
  cmbPreDefineDataStruc.Clear;
  cmbGraphDefine.Clear;
  cmbGridFormat.Clear;
  cmbXLSFormat.Clear;

  // 填写预定义数据结构

  // 通常，仪器选定预定义数据结构后，绘图、表格、Excel模板就都定了。但是，总是有但是，
  // 程序允许用户选择不一样的绘图、表格和Excel导出格式作为定制设置
  // 填写过程线定义

  // 填入数据表格式定义

  // 填写Excel工作表格式定义

end;

end.
