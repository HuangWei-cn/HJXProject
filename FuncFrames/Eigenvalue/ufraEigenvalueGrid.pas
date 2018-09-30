{ -----------------------------------------------------------------------------
 Unit Name: ufraEigenvalueGrid
 Author:    黄伟
 Date:      30-九月-2018
 Purpose:   使用EhGrid為控件的特征值查詢功能件
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

  // 安裝部位
  AddFieldDef('Position', '安裝部位', ftstring);
  AddFieldDef('MeterType', '儀器類型', ftstring);
  AddFieldDef('DesignName', '設計編號', ftstring);
  AddFieldDef('PDName', '物理量', ftstring);
  // 自古以來系列----------------------------
  AddFieldDef('MaxDTInLife', '日期', ftDateTime);
  AddFieldDef('MaxInLife', '最大值', ftFloat);
  AddFieldDef('MinDTInLife', '日期', ftDateTime);
  AddFieldDef('MinInLife', '最小值', ftFloat);
  AddFieldDef('IncrementInLife', '增量', ftFloat);
  AddFieldDef('AmplitudeInLife', '振幅', ftFloat);
  // 年特征系列-----------------------------
  AddFieldDef('MaxDTInYear', '日期', ftDateTime);
  AddFieldDef('MaxInYear', '最大值', ftFloat);
  AddFieldDef('MinDTInYear', '日期', ftDateTime);
  AddFieldDef('MinInYear', '最小值', ftFloat);
  AddFieldDef('IncrementInYear', '增量', ftFloat);
  AddFieldDef('AmplitudeInYear', '振幅', ftFloat);
  // 當前值系列-----------------------------
  AddFieldDef('DTScale', '日期', ftDateTime);
  AddFieldDef('Value', '測值', ftFloat);

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
  grdEV.Columns[0].Title.Caption := '安裝部位';
  grdEV.Columns[1].Title.Caption := '儀器類型';
  grdEV.Columns[2].Title.Caption := '設計編號';
  grdEV.Columns[3].Title.Caption := '觀測量';
  grdEV.Columns[4].Title.Caption := '自安裝以來|最大值|日期';
  grdEV.Columns[5].Title.Caption := '自安裝以來|最大值|測值';
  grdEV.Columns[6].Title.Caption := '自安裝以來|最小值|日期';
  grdEV.Columns[7].Title.Caption := '自安裝以來|最小值|測值';
  grdEV.Columns[8].Title.Caption := '自安裝以來|增量';
  grdEV.Columns[9].Title.Caption := '自安裝以來|振幅';

  grdEV.Columns[10].Title.Caption := '年度|最大值|日期';
  grdEV.Columns[11].Title.Caption := '年度|最大值|測值';
  grdEV.Columns[12].Title.Caption := '年度|最小值|日期';
  grdEV.Columns[13].Title.Caption := '年度|最小值|測值';
  grdEV.Columns[14].Title.Caption := '年度|增量';
  grdEV.Columns[15].Title.Caption := '年度|振幅';

  grdEV.Columns[16].Title.Caption := '當前值|日期';
  grdEV.Columns[17].Title.Caption := '當前值|測值';
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
