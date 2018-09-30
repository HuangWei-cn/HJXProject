{ -----------------------------------------------------------------------------
 Unit Name: ufraEigenvalueGrid
 Author:    ��ΰ
 Date:      30-����-2018
 Purpose:   ʹ��EhGrid��ؼ�������ֵ��ԃ���ܼ�
 History:
----------------------------------------------------------------------------- }

unit ufraEigenvalueGrid;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Vcl.ExtCtrls,
  MemTableDataEh, Data.DB, DataDriverEh, Datasnap.DBClient, MemTableEh, Vcl.StdCtrls,
  {-------------}
  uHJX.Intf.AppServices, uHJX.Intf.Datas, uHJX.Classes.Meters, uHJX.Data.Types, Vcl.ComCtrls,
  Vcl.Menus;

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
    procedure btnQueryClick(Sender: TObject);
    procedure piCopyAsHTMLClick(Sender: TObject);
    procedure piSaveAsHTMLClick(Sender: TObject);
    procedure piSaveAsRTFClick(Sender: TObject);
    procedure piSaveAsXLSClick(Sender: TObject);
    procedure piCopyToClipBoardClick(Sender: TObject);
  private
    { Private declarations }
    FIDList: TStrings;
    procedure SetFields;
    procedure SetDisplay;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GetEVDatas(IDList: String);
  end;

implementation

uses
  uHJX.Intf.FunctionDispatcher, DBGridEhImpExp, uMyUtils.CopyHTML2Clipbrd;
{$R *.dfm}


constructor TfraEigenvalueGrid.Create(AOwner: TComponent);
begin
  inherited;
  FIDList := TStringList.Create;
end;

destructor TfraEigenvalueGrid.Destroy;
begin
  FIDList.Free;
  inherited;
end;

procedure TfraEigenvalueGrid.btnQueryClick(Sender: TObject);
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
    GetEVDatas(S);
  finally
    Screen.Cursor := crDefault;
    prgBar.Visible := False;
  end;

end;

procedure TfraEigenvalueGrid.SetFields;
var
  fd: TFieldDef;
  i : Integer;
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

  // ���b��λ
  AddFieldDef('Position', '���b��λ', ftstring);
  AddFieldDef('MeterType', '�x�����', ftstring);
  AddFieldDef('DesignName', '�OӋ��̖', ftstring);
  AddFieldDef('PDName', '������', ftstring);
  // �Թ��ԁ�ϵ��----------------------------
  AddFieldDef('MaxDTInLife', '����', ftDateTime);
  AddFieldDef('MaxInLife', '���ֵ', ftFloat);
  AddFieldDef('MinDTInLife', '����', ftDateTime);
  AddFieldDef('MinInLife', '��Сֵ', ftFloat);
  AddFieldDef('IncrementInLife', '����', ftFloat);
  AddFieldDef('AmplitudeInLife', '���', ftFloat);
  // ������ϵ��-----------------------------
  AddFieldDef('MaxDTInYear', '����', ftDateTime);
  AddFieldDef('MaxInYear', '���ֵ', ftFloat);
  AddFieldDef('MinDTInYear', '����', ftDateTime);
  AddFieldDef('MinInYear', '��Сֵ', ftFloat);
  AddFieldDef('IncrementInYear', '����', ftFloat);
  AddFieldDef('AmplitudeInYear', '���', ftFloat);
  // ��ǰֵϵ��-----------------------------
  AddFieldDef('DTScale', '����', ftDateTime);
  AddFieldDef('Value', '�yֵ', ftFloat);

  cdsEV.CreateDataSet;
  for i := 0 to cdsEV.FieldCount - 1 do
    if cdsEV.Fields[i].DataType = ftFloat then
      (cdsEV.Fields[i] as TNumericField).DisplayFormat := '0.00';
end;

procedure TfraEigenvalueGrid.SetDisplay;
var
  i : Integer;
  gl: TGridDataGroupLevelEh;
  procedure SetDisplayLabel(fdName, sLabel: string);
  begin
    cdsEV.FieldByName(fdName).DisplayLabel := sLabel;
  end;

begin
  { with cdsEV do
  begin
    SetDisplayLabel('Position', '���b��λ');
    SetDisplayLabel('MeterType', '�x�����');
    SetDisplayLabel('DesignName', '�OӋ��̖');
    SetDisplayLabel('PDName', '�^�y��');
    SetDisplayLabel('MaxDTInLife', '����');
    SetDisplayLabel('MaxInLife', '���ֵ');
    SetDisplayLabel('MinDTInLife', '����');
    SetDisplayLabel('MinInLife', '��Сֵ');
    SetDisplayLabel('IncrementInLife', '����');
    SetDisplayLabel('AmplitudeInLife', '���');
    SetDisplayLabel('MaxDTInYear', '����');
    SetDisplayLabel('MaxInYear', '���ֵ');
    SetDisplayLabel('MinDTInYear', '����');
    SetDisplayLabel('MinInYear', '��Сֵ');
    SetDisplayLabel('IncrementInYear', '����');
    SetDisplayLabel('AmplitudeInYear', '���');
    SetDisplayLabel('DTScale', '����');
    SetDisplayLabel('Value', '�yֵ');
  end; }
  grdEV.UseMultiTitle := True;
  grdEV.Columns[0].Title.Caption := '���b��λ';
  grdEV.Columns[1].Title.Caption := '�x�����';
  grdEV.Columns[2].Title.Caption := '�OӋ��̖';
  grdEV.Columns[3].Title.Caption := '�^�y��';
  grdEV.Columns[4].Title.Caption := '�԰��b�ԁ�|���ֵ|����';
  grdEV.Columns[5].Title.Caption := '�԰��b�ԁ�|���ֵ|�yֵ';
  grdEV.Columns[6].Title.Caption := '�԰��b�ԁ�|��Сֵ|����';
  grdEV.Columns[7].Title.Caption := '�԰��b�ԁ�|��Сֵ|�yֵ';
  grdEV.Columns[8].Title.Caption := '�԰��b�ԁ�|����';
  grdEV.Columns[9].Title.Caption := '�԰��b�ԁ�|���';

  grdEV.Columns[10].Title.Caption := '���|���ֵ|����';
  grdEV.Columns[11].Title.Caption := '���|���ֵ|�yֵ';
  grdEV.Columns[12].Title.Caption := '���|��Сֵ|����';
  grdEV.Columns[13].Title.Caption := '���|��Сֵ|�yֵ';
  grdEV.Columns[14].Title.Caption := '���|����';
  grdEV.Columns[15].Title.Caption := '���|���';

  grdEV.Columns[16].Title.Caption := '��ǰֵ|����';
  grdEV.Columns[17].Title.Caption := '��ǰֵ|�yֵ';
  // grdEV.
  for i := 0 to grdEV.Columns.Count - 1 do
    grdEV.Columns[i].OptimizeWidth;

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
  iMT, i : Integer;
  EVDatas: PEVDataArray;
  Meter  : TMeterDefine;
  bGet   : Boolean;
  j      : Integer;
begin
  FIDList.Text := IDList;
  mtEV.Close;
  cdsEV.Close;
  if FIDList.Count = 0 then
    Exit;

  prgBar.Max := FIDList.Count;
  prgBar.Position := 0;
  prgBar.Visible := True;

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

              FieldByName('MaxDTInLife').Value := lifeev.MaxDate;
              FieldByName('MaxInLife').Value := lifeev.MaxValue;
              FieldByName('MinDTInLife').Value := lifeev.MinDate;
              FieldByName('MinInLife').Value := lifeev.MinValue;
              FieldByName('IncrementInLife').Value := lifeev.Increment;
              FieldByName('AmplitudeInLife').Value := lifeev.Amplitude;

              FieldByName('MaxDTInYear').Value := yearev.MaxDate;
              FieldByName('MaxInYear').Value := yearev.MaxValue;
              FieldByName('MinDTInYear').Value := yearev.MinDate;
              FieldByName('MinInYear').Value := yearev.MinValue;
              FieldByName('IncrementInYear').Value := yearev.Increment;
              FieldByName('AmplitudeInYear').Value := yearev.Amplitude;

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
end;

procedure TfraEigenvalueGrid.piCopyAsHTMLClick(Sender: TObject);
var
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  try
    WriteDBGridEhToExportStream(TDBGridEhExportAsHTML, grdEV, ms, True);
    copyhtmltoclipboard(ms);
  finally
    ms.Free;
  end;
  //DBGridEh_DoCopyAction(grdEV, True);
end;

procedure TfraEigenvalueGrid.piCopyToClipBoardClick(Sender: TObject);
begin
  DBGridEh_DoCopyAction(grdEV, True);
end;

procedure TfraEigenvalueGrid.piSaveAsHTMLClick(Sender: TObject);
begin
  //
end;

procedure TfraEigenvalueGrid.piSaveAsRTFClick(Sender: TObject);
begin
  //
end;

procedure TfraEigenvalueGrid.piSaveAsXLSClick(Sender: TObject);
begin
  //
end;

end.
