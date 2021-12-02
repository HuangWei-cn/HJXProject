{ -----------------------------------------------------------------------------
 Unit Name: ufraQuickViewer
 Author:    ��ΰ
 Date:      07-����-2018
 Purpose:   �۲�����������ʾ��Ԫ
    ����Ԫͨ�����ÿֻ����������ι۲����ݱ仯���±仯����������ֵ����������
    ������ʾ������ͬʱͳ����������ͼ�С���������˽⵱ǰ���ơ�
 History:
    2018-06-14 ��������ʾ���������Ĺ��ܣ�Ŀǰ�в���ָ�����ڣ������Թ��˵�΢С
    �仯��
    2020-06-10 ������ʹ��DBGridEh�����ʾ�����Ĺ��ܡ�����ǰ����������ʾ���һ��
    ��¼�Ĺ���
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
    // ���������������ݼ�
    procedure _CreateIncrementDataSet;
    // ����ָ������������ݼ�
    procedure _Create2DayIncDataSet;
    // ����DBGridEh����ɫ��
    procedure _SetGridPresent;
    { ��ʾ����ָ�����ڵ����ݣ��������� }
    procedure ShowSpecificDatesData;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { ��ʾ�۲�������� }
    procedure ShowQuickView;
    { ��ʾ�۲�������������UseFilter = False����ʾȫ����������������������ֻ��ʾ���޵� }
    procedure ShowDataIncrement(UseFilter: Boolean = False);
    { ��ʾ���µĹ۲����ݣ�ÿ֧����һ����¼�������ͷֱ� }
    procedure ShowLastDatas;
  end;

implementation

uses
  uHJX.Data.Types, uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher, uHJX.Intf.Datas,
  uHJX.Classes.Meters, uHJX.Excel.IO,
  uWebGridCross, uWBLoadHTML, DBGridEhImpExp;
{$R *.dfm}


const
    { ע�������CSS����ʹ�ñ�����ϸ�߱߿� }
    { ��Ա��ı�ͷ����Ԫ��ʹ����CSS���� }
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
    + '.CaptionStyle {font-family:����;font-size: 9pt;color: #000000; padding:2px;border:1px solid #1F4E79; background-color:#FFFF99}'#13#10
    + '</style>'#13#10
    + '</head>'#13#10
    + '<body>'#13#10
    + '@PageContent@'#13#10
    + '</body>'#13#10
    + '</html>';

  FN_INCDATA: array [0 .. 8] of string = ('��װ��λ', '��������', '��Ʊ��', '������', '�۲�����', '�������', '��ǰ��ֵ',
    '��������', '30������');
  FN_2DDATA: array [0 .. 10] of string = ('��װ��λ', '��������', '��Ʊ��', '������', '��ʼ����', '��ʼ��ֵ', '��ֹ����',
    '��ֹ��ֵ', '�������', '����', '�վ�����');

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

  // ��װ��λ
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Position';
  DF.DataType := ftstring;
  DF.DisplayName := '��װ��λ';
  // ��������
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'MeterType';
  DF.DataType := ftstring;
  DF.DisplayName := '��������';
  // ��Ʊ��
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'DesignName';
  DF.DataType := ftstring;
  DF.DisplayName := '��Ʊ��';
  // ������
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'PDName';
  DF.DataType := ftstring;
  DF.DisplayName := '������';
  // �۲�����
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'DTScale';
  DF.DataType := ftDateTime;
  DF.DisplayName := '�۲�����';
  // �������
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'InteralDays';
  DF.DataType := ftFloat;
  DF.DisplayName := '�������';
  // ��ǰ��ֵ
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Data';
  DF.DataType := ftFloat;
  DF.DisplayName := '��ǰ��ֵ';
  // ��������
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Increment';
  DF.DataType := ftFloat;
  DF.DisplayName := '��������';
  // ���30������
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Inc30Days';
  DF.DataType := ftFloat;
  DF.DisplayName := '���30������';

  // �������
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
  // 1��װ��λ
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Position';
  DF.DataType := ftstring;
  // 2��������
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'MeterType';
  DF.DataType := ftstring;
  // 3��Ʊ��
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'DesignName';
  DF.DataType := ftstring;
  // 4������
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'PDName';
  DF.DataType := ftstring;
  // 5��ʼ����
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'StartDate';
  DF.DataType := ftDateTime;
  // 6��ֵ
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Data1';
  DF.DataType := ftFloat;
  // 7��ֹ����
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'EndDate';
  DF.DataType := ftDateTime;
  // 8��ֵ
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Data2';
  DF.DataType := ftFloat;
  // 9�������
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'IntralDays';
  DF.DataType := ftFloat;
  // 10����
  DF := cdsDatas.FieldDefs.AddFieldDef;
  DF.Name := 'Increment';
  DF.DataType := ftFloat;
  // 11�仯��
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
  // �����ù��е�����
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
  Description: ��ʾ��������
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
    // �ж��Ƿ�ֵ����ʾ������Ŀǰ���жϱȽϽ���������Ҫ���ǵ�ʱ�������⣬���仯����
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
    if MeterType = '���λ�Ƽ�' then
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
    else if MeterType = 'ê��������' then
    begin
      Delta := V2[1] - V1[1];
      CountDelta;
      if abs(Delta) < MaxDeltaMS then
          Result := False;
    end
    else if MeterType = 'ê��Ӧ����' then
    begin
      Delta := V2[1] - V1[1];
      CountDelta;
      if abs(Delta) < MaxDeltaMG then
          Result := False;
    end
    else if MeterType = '��ѹ��' then
    begin
      Delta := V2[1] - V1[1];
      CountDelta;
      if abs(Delta) < MaxDeltaSY then
          Result := False;
    end
    else if MeterType = '���ұ��μ�' then
    begin
      Delta := V2[1] - V1[1];
      CountDelta;
      if abs(Delta) < MaxDeltaDDWY then
          Result := False;
    end;
  end;
    // ֻ��ʾһ������
  procedure ShowOneData;
  begin

  end;
    // ��ʾ��������
  procedure ShowTwoData;
  var
    DataRow: array of variant;
    i      : Integer;
  begin
        // �����ֵһ��ͼ�����һ��
    if not _NeedShow then
        Exit;

    Inc(iOverLine); // ������޵�

    WCV.Reset;
    WCV.ColCount := Length(V1); //
    WCV.ColHeader[0].Align := taCenter;
    for i := 1 to WCV.ColCount - 1 do
        WCV.ColHeader[i].Align := taRightJustify;

    WCV.TitleRows := 1;
    SetLength(DataRow, WCV.ColCount);
    DataRow[0] := '�۲�����';
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
    DataRow[0] := '����';
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
  Body := '<h2>��ֵ����������ע��ֵ��������</h2>'
    + Format('<div>���λ�Ƽ��޲�:%fmm��ê���������޲�:%fkN��ê��Ӧ�����޲�:%fkN</div>',
    [MaxDeltaDDWY, MaxDeltaMS, MaxDeltaMG]);
  iInc := 0;
  iDec := 0;
  iOverLine := 0;
  MTList := TStringList.Create;
    // ׼�������б�
  if chkAllMeters.Checked then
    for i := 0 to ExcelMeters.Count - 1 do
        MTList.Add(ExcelMeters.Items[i].DesignName)
  else
  begin
    with IAppServices.FuncDispatcher as IFunctionDispatcher do
    begin
      // �����ѡ�񲿷�������
      if HasProc('PopupMeterSelector') then
          CallFunction('PopupMeterSelector', MTList)
      else // ����ѡ��ȫ������
      begin
        for i := 0 to ExcelMeters.Count - 1 do
            MTList.Add(ExcelMeters.Items[i].DesignName)
      end;
    end;
  end;

  if MTList.Count = 0 then
  begin
    showmessage('û��ѡ����Ҫ��ѯ����������ѡ����ٲ�ѯ��');
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
      lblProgress.Caption := Format('���ڴ����%d֧��������%d֧', [iMeter + 1, { ExcelMeters } MTList.Count]);

      IAppServices.ProcessMessages;

      if IAppServices.ClientDatas.GetLastPDDatas(Meter.DesignName, V2) then
      begin
        if IAppServices.ClientDatas.GetLastPDDatasBeforeDate(Meter.DesignName, V2[0], V1)
        then
        begin
          ShowTwoData;
        end
        else
            ShowOneData; // û��������������û�п��Ǻ������ʾ��������
        Inc(iMeterCount);
      end;
    end;

        // ��ʾ��������
    Body := Body + Format('<hr>���β�ֵ����������ע��ֵ��������%d֧�����������۲����ݱ仯��С��<br>', [iOverLine]);
    Body := Body + Format('��������ι۲��У���%d֧����(������)����������%d֧�������ݼ�С��', [iInc, iDec]);
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
  if pos('about', S) > 0 then // ���ؿ�ҳ��
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
  Description: ��������ѯȫ��������ָ��ʱ��Ĺ۲�����������������������HTMLViewer
  ����ʾ���������UseFilter=True������˵��仯��С�����ݣ�ֻ�����仯��ġ�
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
  Description: ��ʾָ�����ڵ����ι۲����ݣ���������
----------------------------------------------------------------------------- }
procedure TfraQuickViewer.btnSpecificDatesClick(Sender: TObject);
begin
  pnlDateSelector.Visible := True;
  pnlDateSelector.Left := (Self.Width - pnlDateSelector.Width) div 2;
  pnlDateSelector.Top := (Self.Height - pnlDateSelector.Height) div 2;
end;

{ -----------------------------------------------------------------------------
  Procedure  : HtmlViewerHotSpotClick
  Description: ���������ų����ӣ������������Ĺ����߻�������������ͼ
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
  Description: ���õݹ���������չ����TreeNode
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
  Description: ���𱾼�����չ��
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
  Description: Group Tree���𱾼�չ���ڵ�
----------------------------------------------------------------------------- }
procedure TfraQuickViewer.piCollapseThisLevelClick(Sender: TObject);
begin
  // ������ѡ�м�¼�ĸ��ڵ�����
  if DBGridEh1.DataGrouping.CurDataNode.Parent <> nil then
      DBGridEh1.DataGrouping.CurDataNode.Parent.Expanded := False;
  // DBGridEh1.DataGrouping.GroupDataTree.Collapse(DBGridEh1.DataGrouping.CurDataNode.Parent);
end;

procedure TfraQuickViewer.popGridPopup(Sender: TObject);
begin
  // �ж�Grid.DataSet�Ƿ�Active
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
  k     : Integer;     // ����ֵ�����ţ�
  kIdx  : set of Byte; // ����ֵ��ż��ϣ���������ֵ�����127����
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
    vH[0] := '��������';
    vH[1] := '��Ʊ��';
    vH[2] := '������';
    vH[3] := '�۲�����';
    vH[4] := '�������';
    vH[5] := '��ǰ��ֵ';
    vH[6] := '��������';
    vH[7] := '���30������';
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
  // ���WebGrid
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
  else // ������EhGrid
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

  // ׼�������б�
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
      // �����ѡ�񲿷�������
      if HasProc('PopupMeterSelector') then
          CallFunction('PopupMeterSelector', { MTList } FMeterList)
      else // ����ѡ��ȫ������
      begin
        for i := 0 to ExcelMeters.Count - 1 do
            { MTList } FMeterList.Add(ExcelMeters.Items[i].DesignName)
      end;
    end;
  end;

  if FMeterList.Count = 0 then
  begin
    showmessage('û��ѡ����Ҫ��ѯ����������ѡ����ٲ�ѯ��');
    Exit;
  end;

  if rdgPresentType.ItemIndex = 0 then
  begin
    Body := '<h2>�۲����ݱ仯�����</h2>';
    WCV := TWebCrossView.Create;

    // ������ǰ��������ͷֱ���SetGrid�������ͷֱ������������������͵�ʱ���SetGrid�����ڴ˴�
    // SetGrid�����ֻ�б�ͷ�Ŀձ�
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

      if Meter.Params.MeterType = '��б��' then
          Continue;

      lblDesignName.Caption := Meter.DesignName;
      lblProgress.Caption := Format('���ڴ����%d֧����%d֧', [iMeter, iCount]);
      ProgressBar.Position := iMeter;
      IAppServices.ProcessMessages;

      if rdgPresentType.ItemIndex = 0 then // WebGrid��Ҫ����λ�����ͻ���ҳ��
      begin
        if Meter.PrjParams.Position <> sPos then
        begin
          sPos := Meter.PrjParams.Position;
          Body := Body + WCV.CrossGrid;
          Body := Body + '<h3>' + sPos + '</h3>';
        // �����ǰ����ͷֱ�����ǰ���λ�ֱ�
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
          // ��stype =''ʱ��˵���Ѿ�����һ����λ�������ˣ���ʱWCV�����Ѿ�����Ӳ�λ����֮ǰ��ӵ�
          // Body�ˣ�����ӱ��ͻ��ڲ�λ����������ʾһ���ظ��ı��
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

      { ��ѯ������������ }
      { 2019-07-31 ��ѯ�����ķ����Ѿ���Ϊ��ѯ������������ֵ��ǵ���������Ŀ }
      if IHJXClientFuncs.GetDataIncrement(Meter.DesignName, Now, V) then
      begin
      { 2019-07-31 ��������ѯ�����Ѿ���Ϊ��ѯ��������ֵ��ǵ����������������Ҳ�޸�Ϊ�г��߱�����ֵ
      ��ǵ�����������ʱ�����ǹ���С�仯������������ڲ�ѯ�Ľ��V���μ�uHJX.Excel.DataQuery��Ԫ�е�
      GetDataIncrement�����еĶ��� }
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
              vH[2] := V[i][0]; // ��������
              vH[3] := FormatDateTime('yyyy-mm-dd', V[i][1]);
              vH[4] := V[i][2]; // �������
              vH[5] := V[i][3]; // ����ֵ
              vH[6] := V[i][4]; // ���ϴβ�ֵ������
              vH[7] := V[i][5]; // 30������
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
  Description: ��ʾ����ָ�����ڵĹ۲����ݣ���������
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
      vH[0] := '��Ʊ��';
      vH[1] := '������';
      for ii := 2 to 3 do vH[ii] := '�۲�����';
      vH[4] := '����';
      WCV.AddRow(vH);
      vH[2] := '%dt1%'; // ��һ������
      vH[3] := '%dt2%'; // �ڶ�������
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
      vH[0] := '��Ʊ��';
      vH[1] := '������';
      for ii := 2 to 5 do vH[ii] := '�۲�����';
      vH[6] := '����';
      vH[7] := '���ڼ��';
      vH[8] := '�仯����';
      WCV.AddRow(vH);
      vH[2] := '��ʼ����';
      vH[3] := '��ֹ����';
      vH[4] := '��ʼ��ֵ';
      vH[5] := '��ֹ��ֵ';
      WCV.AddRow(vH);
    end;

  end;

begin
  if ExcelMeters.Count = 0 then Exit;

// ���WebGrid
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
  else // ������EhGrid
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
  // ѡ������
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
    showmessage('û��ѡ��������');
    Exit;
  end;

  // ׼��������
  IAppServices.ClientDatas.SessionBegin;
  // �������WebGrid���֣���
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
    // ׼���������ݣ�����д����
    for i := 0 to FMeterList.Count - 1 do
    begin
      Meter := ExcelMeters.Meter[FMeterList[i]];
      lblDesignName.Caption := Meter.DesignName;
      lblProgress.Caption := Format('���ڴ����%d֧����%d֧', [i + 1, FMeterList.Count]);
      ProgressBar.Position := i + 1;

      if Meter.DataSheet = '' then Continue;
      if Meter.Params.MeterType = '��б��' then Continue;

      // �������WebGrid����
      if rdgPresentType.ItemIndex = 0 then
      begin
        // ��λ����
        if Meter.PrjParams.Position <> sPos then
        begin
          sPos := Meter.PrjParams.Position;
          sBody := sBody + WCV.CrossGrid + #13#10'<h3>' + sPos + '</h3>'#13#10;
          WCV.Reset;
          _SetGrid;
        end;
        // ���ͼ�顢����
        if Meter.Params.MeterType <> sType then
        begin
          sType := Meter.Params.MeterType;
          WCV.AddCaptionRow([sType]);
        end;
        { 2019-07-31�����г�����ֵ��ķ�ʽ������񣬼�����������ֵ�����������ݲ�ѯ֮�� }
        _ClearValues;
      end;

      // ����Ĵ����ѯ��ͳ������������ֵ������������PD�������kIdx����
      j := 0;
      kIdx := [];
      for k := 0 to Meter.PDDefines.Count - 1 do
        if Meter.PDDefine[k].HasEV then
        begin
          Inc(j);
          include(kIdx, k);
        end;

      { ������������ֵ�Ϊ�㣬�򴴽���� }
      if j > 0 then
      begin
        // ��ѯ����
        IAppServices.ClientDatas.GetNearestPDDatas(FMeterList[i], dtp1.Date, V);
        IAppServices.ClientDatas.GetNearestPDDatas(FMeterList[i], dtp2.Date, V1);
        if V[0] = 0 then Continue;
        dt1 := V[0];
        dt2 := V1[0];
        // �������WebGrid����
        if rdgPresentType.ItemIndex = 0 then
        begin
          vH[0] := '<a href="PopGraph:' + Meter.DesignName + '">' + Meter.DesignName + '</a>';
          if not chkSimpleSDGrid.Checked then
          begin
            vH[2] := FormatDateTime('yyyy-mm-dd', dt1);
            vH[3] := FormatDateTime('yyyy-mm-dd', dt2);
            vH[7] := dt2 - dt1; // ���ڼ��
          end;
        end;

        for j in kIdx do // ����������ֵ������
        begin
          if rdgPresentType.ItemIndex = 0 then // ����WebGrid
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
          else // ����EhGrid
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
    // ��ʾ���
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
  Description: ��������ʾ��ѡ���������һ����¼���ֲ�λ�������ͷֱ���ʾȫ��
  ��������
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

  { ���������������ñ�� }
  procedure SetGrid;
  var
    iii: Integer;
  begin
    WCV.ColCount := Meter.DataSheetStru.PDs.Count + 3; // ��Ʊ�ţ��۲����ڣ�������ϵ�У���ע��
    WCV.TitleRows := 1;
    WCV.AddRow;
    WCV.Cells[0, 0].Value := '��Ʊ��';
    WCV.Cells[1, 0].Value := '�۲�����';
    for iii := 0 to Meter.DataSheetStru.PDs.Count - 1 do
    begin
      WCV.Cells[2 + iii, 0].Value := Meter.PDDefine[iii].Name;
      WCV.ColHeader[2 + iii].Align := taRightJustify;
    end;
    WCV.Cells[WCV.ColCount - 1, 0].Value := '��ע';
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

  // ׼�������б�
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
    // �����ѡ�񲿷�������
      if HasProc('PopupMeterSelector') then
          CallFunction('PopupMeterSelector', { MTList } FMeterList)
      else // ����ѡ��ȫ������
      begin
        for i := 0 to ExcelMeters.Count - 1 do
            FMeterList.Add(ExcelMeters.Items[i].DesignName)
      end;
    end;
  end;
  if FMeterList.Count = 0 then
  begin
    showmessage('û��ѡ����Ҫ��ѯ�ļ����������ѡ����ٲ�ѯ��');
    Exit;
  end;

  Body := '<h2>�۲����ݱ仯�����</h2>';
  WCV := TWebCrossView.Create;

  // �����������ı�񽫰����������ͷֱ�
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
      lblProgress.Caption := Format('���ڴ����%d֧����%d֧', [iMeter, iCount]);
      ProgressBar.Position := iMeter;

      if Meter.Params.MeterType = '��б��' then
          Continue;

      IAppServices.ProcessMessages;

      if Meter.PrjParams.Position <> sPos then
      begin
        sPos := Meter.PrjParams.Position;
        Body := Body + WCV.CrossGrid;
        Body := Body + '<h3>' + sPos + '</h3>';
        // �����ǰ����ͷֱ�����ǰ���λ�ֱ�
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
          // ��stype =''ʱ��˵���Ѿ�����һ����λ�������ˣ���ʱWCV�����Ѿ�����Ӳ�λ����֮ǰ��ӵ�
          // Body�ˣ�����ӱ��ͻ��ڲ�λ����������ʾһ���ظ��ı��
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
        if V[0] <> 0 then // ���۲�����Ϊ0�������������û�й۲�����
        begin
          WCV.AddRow;
          iRow := WCV.RowCount - 1;
          WCV.Cells[0, iRow].Value := Meter.DesignName;    // ��Ʊ��
          WCV.Cells[1, iRow].Value := VarToDateTime(V[0]); // �۲�����
          // ���������
          for i := 0 to Meter.PDDefines.Count - 1 do
            if VarIsNumeric(V[1 + i]) then
                WCV.Cells[2 + i, iRow].Value := FormatFloat('0.00', V[i + 1]);
          // ��ӱ�ע
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
