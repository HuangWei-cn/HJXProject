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
----------------------------------------------------------------------------- }

unit ufraQuickViewer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, HTMLUn2, HtmlView, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.WinXCtrls, Vcl.Menus, Vcl.OleCtrls, SHDocVw;

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
  private
    { Private declarations }
    FMeterList: TStrings;
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
  end;

implementation

uses
  uHJX.Data.Types, uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher, uHJX.Intf.Datas,
  uHJX.Classes.Meters,
  uWebGridCross, uWBLoadHTML;
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

var
  MaxDeltaDDWY: Double = 0.1;
  MaxDeltaMS  : Double = 5;
  MaxDeltaMG  : Double = 5;
  MaxDeltaSY  : Double = 1;

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
procedure TfraQuickViewer.btnCreateQuickViewClick(Sender: TObject);
begin
  ShowQuickView;
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
  try
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
      WB_LoadHTML(wbViewer, Page);
    end
    else
    begin
      HtmlViewer.Visible := True;
      wbViewer.Visible := False;
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
  s, cmd, sName: String;
  i            : Integer;
begin
  s := VarToStr(URL);
  if Pos('about', s) > 0 then // ���ؿ�ҳ��
      Cancel := False
  else if Pos('popgraph', s) > 0 then
  begin
    i := Pos(':', s);
    cmd := Copy(s, 1, i - 1);
    sName := Copy(s, i + 1, Length(s) - 1);
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
  cmd, s: string;
  i     : Integer;
begin
    // ShowMessage(src);
  i := Pos(':', SRC);
  cmd := Copy(SRC, 1, i - 1);
  s := Copy(SRC, i + 1, Length(SRC) - i);
    // ShowMessage(s);
  if cmd = 'PopGraph' then
    (IAppServices.FuncDispatcher as IFunctionDispatcher).PopupDataGraph(s);;
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
  end;

  { MTList := TStringList.Create; }
  if ExcelMeters.Count = 0 then
      Exit;

  Body := '<h2>�۲����ݱ仯�����</h2>';
  WCV := TWebCrossView.Create;

  // ������ǰ��������ͷֱ���SetGrid�������ͷֱ������������������͵�ʱ���SetGrid�����ڴ˴�
  // SetGrid�����ֻ�б�ͷ�Ŀձ�
  if not chkTableByType.Checked then SetGrid;

  sType := '';
  sPos := '';
  IHJXClientFuncs.SessionBegin;
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

      lblDesignName.Caption := Meter.DesignName;
      lblProgress.Caption := Format('���ڴ����%d֧����%d֧', [iMeter, iCount]);
      ProgressBar.Position := iMeter;
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

      if Meter.Params.MeterType = '��б��' then
          Continue;
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

      { ��ѯ������������ }
      { 2019-07-31 ��ѯ�����ķ����Ѿ���Ϊ��ѯ������������ֵ��ǵ���������Ŀ }
      if IHJXClientFuncs.GetDataIncrement(Meter.DesignName, Now, V) then
      begin
        { todo:�ı�����޴��ķ�����������д�������ļ���ȥ }
        (*
        if (sType = 'ê��������') or (sType = 'ê��Ӧ����') or (sType = '��ѹ��') or (sType = '���ұ��μ�')
          or (sType = '����') or (sType = '�ѷ��') or (sType = 'λ���') or (sType = '�ֽ��')
          or (sType = '�ְ��') or (sType = 'ˮλ��') or (sType = 'ˮλ') or (sType = '��ˮ��')
          or (sType = 'Ӧ���') or (sType = '��Ӧ����') then
        begin
          if UseFilter then
            if sType = 'ê��������' then
            begin
              if IgnoreData(V[0][4], MaxDeltaMS) and IgnoreData(V[0][5], MaxDeltaMS)
              then
                  Continue
            end
            else if sType = 'ê��Ӧ����' then
            begin
              if IgnoreData(V[0][4], MaxDeltaMG) and IgnoreData(V[0][5], MaxDeltaMG)
              then
                  Continue;
            end
            else if sType = '��ѹ��' then
            begin
              if IgnoreData(V[0][4], MaxDeltaSY) and IgnoreData(V[0][5], MaxDeltaSY) then
                  Continue;
            end
            else if sType = '���ұ��μ�' then
            begin
              if IgnoreData(V[0][4], MaxDeltaDDWY) and IgnoreData(V[0][5], MaxDeltaDDWY) then
                  Continue;
            end;

          vH[0] := sType;
          vH[1] := '<a href="PopGraph:' + Meter.DesignName + '">' +
            Meter.DesignName + '</a>';
          vH[2] := Meter.PDName(0);
          vH[3] := FormatDateTime('yyyy-mm-dd', V[0][1]);
          vH[4] := V[0][2];
          vH[5] := V[0][3];
          vH[6] := V[0][4];
          vH[7] := V[0][5];
          WCV.AddRow(vH);
        end
        else if sType = '���λ�Ƽ�' then
        begin
          for i := Low(V) to High(V) do
          begin
            if UseFilter then
              if IgnoreData(V[i][4], MaxDeltaDDWY) and
                IgnoreData(V[i][5], MaxDeltaDDWY)
              then
                  Continue;

            vH[0] := sType;
            vH[1] := '<a href="PopGraph:' + Meter.DesignName + '">' +
              Meter.DesignName + '</a>';
            vH[2] := Meter.PDName(i);
            vH[3] := FormatDateTime('yyyy-mm-dd', V[i][1]);
            vH[4] := V[i][2];
            vH[5] := V[i][3];
            vH[6] := V[i][4];
            vH[7] := V[i][5];
            WCV.AddRow(vH);
          end;
        end
        else if sType = 'ƽ��λ�Ʋ��' then
        begin
          for i := Low(V) to High(V) do
          begin
            vH[0] := sType;
            vH[1] := '<a href="PopGraph:' + Meter.DesignName + '">' +
              Meter.DesignName + '</a>';
            vH[2] := V[i][0]; // Meter.PDName(i);
            vH[3] := FormatDateTime('yyyy-mm-dd', V[i][1]);
            vH[4] := V[i][2];
            vH[5] := V[i][3];
            vH[6] := V[i][4];
            vH[7] := V[i][5];
            WCV.AddRow(vH);
          end;
        end;
 *)
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

            Inc(i);
          end;
        end;
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
      WCV.ColHeader[4].AllowColSpan := True;
      //wcv.ColHeader[6].AllowColSpan := True;
      //wcv.ColHeader[7].AllowColSpan := True;
      //wcv.ColHeader[8].AllowColSpan := True;
      WCV.ColHeader[3].Align := taRightJustify;
      for ii in [3, 5, 6, 7, 8] do WCV.ColHeader[ii].Align := taRightJustify;

      SetLength(vH, 9);
      vH[0] := '��Ʊ��';
      vH[1] := '������';
      for ii := 2 to 5 do vH[ii] := '�۲�����';
      vH[6] := '����';
      vH[7] := '���ڼ��';
      vH[8] := '�仯����';
      WCV.AddRow(vH);
      vH[2] := '��ʼ����';
      vH[3] := '��ֵ';
      vH[4] := '��ֹ����';
      vH[5] := '��ֵ';
      WCV.AddRow(vH);
    end;

  end;

begin
  if ExcelMeters.Count = 0 then Exit;
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
  end;
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
    ShowMessage('û��ѡ��������');
    Exit;
  end;

  // ׼��������
  IAppServices.ClientDatas.SessionBegin;

  if chkSimpleSDGrid.Checked then SetLength(vH, 5)
  else SetLength(vH, 9);

  WCV := TWebCrossView.Create;
  _SetGrid;
  sType := '';
  sPos := ExcelMeters.Meter[FMeterList[0]].PrjParams.Position;
  sBody := '<h3>' + sPos + '</h3>';
  try
    // ׼���������ݣ�����д����
    for i := 0 to FMeterList.Count - 1 do
    begin
      Meter := ExcelMeters.Meter[FMeterList[i]];
      if Meter.DataSheet = '' then Continue;

      // ��λ����
      if Meter.PrjParams.Position <> sPos then
      begin
        sPos := Meter.PrjParams.Position;
        sBody := sBody + WCV.CrossGrid + #13#10'<h3>' + sPos + '</h3>'#13#10;
        WCV.Reset;
        _SetGrid;
      end;

      if Meter.Params.MeterType = '��б��' then Continue;
      // ���ͼ�顢����
      if Meter.Params.MeterType <> sType then
      begin
        sType := Meter.Params.MeterType;
        WCV.AddCaptionRow([sType]);
      end;

      (*
      // ׼������
      if Meter.Params.MeterType = '���λ�Ƽ�' then
      begin
        _ClearValues;
        vH[0] := '<a href="PopGraph:' + Meter.DesignName + '">' + Meter.DesignName + '</a>';
        IAppServices.ClientDatas.GetNearestPDDatas(FMeterList[i], dtp1.Date, V);
        IAppServices.ClientDatas.GetNearestPDDatas(FMeterList[i], dtp2.Date, V1);
        if V[0] = 0 then Continue;

        dt1 := V[0];
        dt2 := V1[0];
        vH[2] := FormatDateTime('yyyy-mm-dd', dt1);
        vH[4] := FormatDateTime('yyyy-mm-dd', dt2);
        vH[7] := dt2 - dt1;
        // ��һ��
        // vH[1] := Meter.PDName(0);
        // vH[3] := V[1];
        // vH[5] := V1[1];
        // vH[6] := V1[1] - V[1];
        // if dt2 - dt1 <> 0 then vH[8] := (V1[1] - V[1]) / (dt2 - dt1);
        // WCV.AddRow(vH);
        for j := 0 to 3 do
        begin
          vH[1] := Meter.PDName(j);
          vH[3] := V[j + 1];
          vH[5] := V1[j + 1];
          vH[6] := V1[j + 1] - V[j + 1];
          if dt2 - dt1 <> 0 then vH[8] := (V1[j + 1] - V[j + 1]) / (dt2 - dt1);
          WCV.AddRow(vH);
        end;
      end
      else if Meter.Params.MeterType = 'ƽ��λ�Ʋ��' then
      begin
        _ClearValues;
        vH[0] := '<a href="PopGraph:' + Meter.DesignName + '">' + Meter.DesignName + '</a>';
        IAppServices.ClientDatas.GetNearestPDDatas(FMeterList[i], dtp1.Date, V);
        IAppServices.ClientDatas.GetNearestPDDatas(FMeterList[i], dtp2.Date, V1);
        if V[0] = 0 then Continue;

        dt1 := V[0];
        dt2 := V1[0];
        vH[2] := FormatDateTime('yyyy-mm-dd', dt1);
        vH[4] := FormatDateTime('yyyy-mm-dd', dt2);
        vH[7] := dt2 - dt1; // ���ڼ��
        { ƽ��λ�Ʋ��ֻ�Ƚϱ�������͸̵߳Ĳ�ֵ }
        for j in [11, 12, 8] do
        begin
          vH[1] := Meter.PDName(j);
          vH[3] := V[j + 1];
          vH[5] := V1[j + 1];
          vH[6] := V1[j + 1] - V[j + 1];
          if dt2 - dt1 <> 0 then vH[8] := (V1[j + 1] - V[j + 1]) / (dt2 - dt1);
          WCV.AddRow(vH);
        end;

      end
      else
      begin
        _ClearValues;
      // ����һ������
        IAppServices.ClientDatas.GetNearestPDDatas(FMeterList[i], dtp1.Date, V);
        if V[0] = 0 then Continue;

        vH[2] := FormatDateTime('yyyy-mm-dd', V[0]);
        vH[3] := V[1];
        dt1 := V[0];
        d1 := V[1];
      // ���ڶ�������
        IAppServices.ClientDatas.GetNearestPDDatas(FMeterList[i], dtp2.Date, V);
        vH[4] := FormatDateTime('yyyy-mm-dd', V[0]);
        vH[5] := V[1];
        dt2 := V[0];
        d2 := V[1];
      // ����
        vH[0] := '<a href="PopGraph:' + Meter.DesignName + '">' + Meter.DesignName + '</a>';
        // Meter.DesignName;
        vH[1] := Meter.PDName(0);
      // vH[2] := dtp1.DateTime;
      // vH[4] := dtp2.DateTime;
        vH[6] := d2 - d1;
        vH[7] := dt2 - dt1;
        if d2 - d1 <> 0 then
            vH[8] := (d2 - d1) / (dt2 - dt1)
        else
            vH[8] := '';
        WCV.AddRow(vH);
      end;
 *)

      { 2019-07-31�����г�����ֵ��ķ�ʽ������񣬼�����������ֵ�����������ݲ�ѯ֮�� }
      _ClearValues;
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
        vH[0] := '<a href="PopGraph:' + Meter.DesignName + '">' + Meter.DesignName + '</a>';
        // ��ѯ����
        IAppServices.ClientDatas.GetNearestPDDatas(FMeterList[i], dtp1.Date, V);
        IAppServices.ClientDatas.GetNearestPDDatas(FMeterList[i], dtp2.Date, V1);
        if V[0] = 0 then Continue;
        dt1 := V[0];
        dt2 := V1[0];
        if not chkSimpleSDGrid.Checked then
        begin
          vH[2] := FormatDateTime('yyyy-mm-dd', dt1);
          vH[4] := FormatDateTime('yyyy-mm-dd', dt2);
          vH[7] := dt2 - dt1; // ���ڼ��
        end;

        for j in kIdx do // ����������ֵ������
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
            vH[3] := V[j + 1];
            vH[5] := V1[j + 1];
            vH[6] := V1[j + 1] - V[j + 1];
            if dt2 - dt1 <> 0 then vH[8] := (V1[j + 1] - V[j + 1]) / (dt2 - dt1);
          end;
          WCV.AddRow(vH);
        end;
      end;
    end;

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

  finally
    SetLength(vH, 0);
    WCV.Free;
    Screen.Cursor := crDefault;
    pnlProgress.Visible := False;
    IAppServices.ClientDatas.SessionEnd;
  end;

end;

end.
