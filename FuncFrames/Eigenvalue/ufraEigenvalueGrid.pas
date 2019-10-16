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
    dlgSave: TSaveDialog;
    btnDrawEVGraph: TButton;
    procedure btnQueryClick(Sender: TObject);
    procedure piCopyAsHTMLClick(Sender: TObject);
    procedure piSaveAsHTMLClick(Sender: TObject);
    procedure piSaveAsRTFClick(Sender: TObject);
    procedure piSaveAsXLSClick(Sender: TObject);
    procedure piCopyToClipBoardClick(Sender: TObject);
    procedure btnDrawEVGraphClick(Sender: TObject);
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
  uHJX.Intf.FunctionDispatcher, DBGridEhImpExp, uMyUtils.CopyHTML2Clipbrd, ufrmEVGraph;
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

procedure TfraEigenvalueGrid.btnDrawEVGraphClick(Sender: TObject);
var
  frm: TfrmEVGraph;
begin
  if cdsEV.RecordCount = 0 then
  begin
    ShowMessage('���ȵò鶫���������ܻ�ͼ~~');
    Exit;
  end;

  if (mtEV.FieldByName('Position').IsNull or mtEV.FieldByName('MeterType').IsNull) then
  begin
    ShowMessage('���ѡ��ĳ����¼���й��̲�λ���������͵ļ�¼~~~');
    Exit;
  end;

  frm := TfrmEVGraph.Create(self);
  frm.DrawEVGraph(mtEV.FieldByName('Position').AsString,
    mtEV.FieldByName('MeterType').AsString, mtEV.FieldByName('PDName').AsString, mtEV);
  frm.ShowModal;
  frm.Release;
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
  AddFieldDef('MeterType', '��������', ftstring);
  AddFieldDef('DesignName', '��Ʊ��', ftstring);
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
  { grdEV.Columns[0].Title.Caption := '��װ��λ';
  grdEV.Columns[1].Title.Caption := '��������';
  grdEV.Columns[2].Title.Caption := '��Ʊ��';
  grdEV.Columns[3].Title.Caption := '�۲�����';
  grdEV.Columns[4].Title.Caption := '��ʷ����| ����ֵ | ���� ';
  grdEV.Columns[5].Title.Caption := '��ʷ����| ����ֵ | ��ֵ ';
  grdEV.Columns[6].Title.Caption := '��ʷ����| ��Сֵ | ���� ';
  grdEV.Columns[7].Title.Caption := '��ʷ����| ��Сֵ | ��ֵ ';
  grdEV.Columns[8].Title.Caption := '��ʷ����| ���� ';
  grdEV.Columns[9].Title.Caption := '��ʷ����| ��� ';

  grdEV.Columns[10].Title.Caption := '�������|����ֵ| ���� ';
  grdEV.Columns[11].Title.Caption := '�������|����ֵ| ��ֵ ';
  grdEV.Columns[12].Title.Caption := '�������|��Сֵ| ���� ';
  grdEV.Columns[13].Title.Caption := '�������|��Сֵ| ��ֵ ';
  grdEV.Columns[14].Title.Caption := '�������|����';
  grdEV.Columns[15].Title.Caption := '�������|���';

  grdEV.Columns[16].Title.Caption := '��ǰ��ֵ|����';
  grdEV.Columns[17].Title.Caption := '��ǰ��ֵ|��ֵ'; }

  grdEV.Columns[0].Field.DisplayLabel := '��װ��λ';
  grdEV.Columns[1].Field.DisplayLabel := '��������';
  grdEV.Columns[2].Field.DisplayLabel := '��Ʊ��';
  grdEV.Columns[3].Field.DisplayLabel := '�۲���';
  grdEV.Columns[4].Field.DisplayLabel := '��ʷ����ֵ|���ֵ|����';
  grdEV.Columns[5].Field.DisplayLabel := '��ʷ����ֵ|���ֵ|��ֵ';
  grdEV.Columns[6].Field.DisplayLabel := '��ʷ����ֵ|��Сֵ|����';
  grdEV.Columns[7].Field.DisplayLabel := '��ʷ����ֵ|��Сֵ|��ֵ';
  grdEV.Columns[8].Field.DisplayLabel := '��ʷ����ֵ|����';
  grdEV.Columns[9].Field.DisplayLabel := '��ʷ����ֵ|���';

  grdEV.Columns[10].Field.DisplayLabel := '�������ֵ|���ֵ|����';
  grdEV.Columns[11].Field.DisplayLabel := '�������ֵ|���ֵ|��ֵ';
  grdEV.Columns[12].Field.DisplayLabel := '�������ֵ|��Сֵ|����';
  grdEV.Columns[13].Field.DisplayLabel := '�������ֵ|��Сֵ|��ֵ';
  grdEV.Columns[14].Field.DisplayLabel := '�������ֵ|����';
  grdEV.Columns[15].Field.DisplayLabel := '�������ֵ|���';

  grdEV.Columns[16].Field.DisplayLabel := '��ǰֵ|����';
  grdEV.Columns[17].Field.DisplayLabel := '��ǰֵ|��ֵ';

  for i := 0 to grdEV.Columns.Count - 1 do
  begin
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
  iMT, i : Integer;
  EVDatas: PEVDataArray;
  Meter  : TMeterDefine;
  bGet   : Boolean;
  j      : Integer;
begin
  FIDList.Text := IDList;
  mtEV.Close;
  cdsEV.Close;
  if FIDList.Count = 0 then Exit;

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

              FieldByName('MaxDTInLife').Value := LifeEV.MaxDate;
              FieldByName('MaxInLife').Value := LifeEV.MaxValue;
              FieldByName('MinDTInLife').Value := LifeEV.MinDate;
              FieldByName('MinInLife').Value := LifeEV.MinValue;
              FieldByName('IncrementInLife').Value := LifeEV.Increment;
              FieldByName('AmplitudeInLife').Value := LifeEV.Amplitude;

              FieldByName('MaxDTInYear').Value := YearEV.MaxDate;
              FieldByName('MaxInYear').Value := YearEV.MaxValue;
              FieldByName('MinDTInYear').Value := YearEV.MinDate;
              FieldByName('MinInYear').Value := YearEV.MinValue;
              FieldByName('IncrementInYear').Value := YearEV.Increment;
              FieldByName('AmplitudeInYear').Value := YearEV.Amplitude;

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
    CopyHTMLToClipboard(ms);
  finally
    ms.Free;
  end;
  // DBGridEh_DoCopyAction(grdEV, True);
end;

procedure TfraEigenvalueGrid.piCopyToClipBoardClick(Sender: TObject);
begin
  DBGridEh_DoCopyAction(grdEV, True);
end;

procedure TfraEigenvalueGrid.piSaveAsHTMLClick(Sender: TObject);
begin
  dlgSave.Filter := 'HTML�ļ�|*.htm;*.html';
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

end.
