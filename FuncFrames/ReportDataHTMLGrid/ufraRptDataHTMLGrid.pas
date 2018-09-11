{ -----------------------------------------------------------------------------
 Unit Name: ufraRptDataHTMLGrid
 Author:    ��ΰ
 Date:      25-����-2018
 Purpose:   ����Ԫ������������ȫ����������Ĺ۲����ݱ����񣬱��ΪHTML��ʽ��

 History:   2018-06-06
            ����ê�������Ʊ�ͷ���󣻽���ť.Caption�ӡ����ɱ�����Ϊ"�������ݱ�";
            ����uHJX.Excel.Meters��Ԫ�����ø�ΪuHJX.Classes.Meters��

            2018-06-15
            ��������ͼ��������ߵ�Webҳ�棬�����߿����Ǳ������ⲿ���ļ���Ҳ����
            ��Stream�ṩ��ǰ�߿���������ʾ��Word�У��������޷���ʾ��

            2018-06-21
            ����ѡ�񲿷������Ĺ���

            2018-08-08
            ����û��ָ�������ļ������ݱ������
----------------------------------------------------------------------------- }
{ DONE: ������ѡ���������Ĺ��ܣ���ѡ������ѡĳ����� }
{ DONE: ���ӱ���Ϊ�ļ��Ĺ��� }
{ DONE: ʹ�ù��ܵ������ͽӿ� }
{ todo: ����Ծ����������͵ı�����ɴ���ֽ⵽��ͬ�ĵ�Ԫ����Frame���ṩ���� }
{ todo: ���ƽ����β�����ݱ�Ĵ��� }
{ DONE: ����HTMLViewer������IE������ʾ }
unit ufraRptDataHTMLGrid;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.OleCtrls,
    SHDocVw, Datasnap.DBClient, Vcl.FileCtrl,
    uHJX.Data.Types, uHJX.Intf.Datas, uHJX.Classes.Meters, uHJX.Intf.AppServices,
    Vcl.ComCtrls, HTMLUn2, HtmlView, Vcl.Menus, Vcl.Buttons;

type
    TfraRptDataHTMLGrid = class(TFrame)
        Panel1: TPanel;
        GroupBox1: TGroupBox;
        rbAllDatas: TRadioButton;
        rdDataRange: TRadioButton;
        btnCreateReport: TButton;
        pnlProgress: TPanel;
        Progress: TProgressBar;
        lblProgress: TLabel;
        lblMeterName: TLabel;
        dtpStart: TDateTimePicker;
        dtpEnd: TDateTimePicker;
        lblBreak: TLabel;
        hvReport: THtmlViewer;
        PopupMenu1: TPopupMenu;
        miCopyAll: TMenuItem;
        chkExportChart: TCheckBox;
        chkCreateChart: TCheckBox;
        miCopySelected: TMenuItem;
        N1: TMenuItem;
        miPrint: TMenuItem;
        dlgPrint: TPrintDialog;
        miPrintPreview: TMenuItem;
        N2: TMenuItem;
        miSave: TMenuItem;
        dlgSave: TSaveDialog;
        rdgMeterOption: TRadioGroup;
        GroupBox2: TGroupBox;
        pnlSetup: TPanel;
        pnlCloseSetupPanel: TSpeedButton;
        btnShowSetupPanel: TSpeedButton;
        rdgDTRangeOption: TRadioGroup;
        procedure btnCreateReportClick(Sender: TObject);
        procedure FrameResize(Sender: TObject);
        procedure lblBreakClick(Sender: TObject);
        procedure dtpStartClick(Sender: TObject);
        procedure miCopyAllClick(Sender: TObject);
        procedure hvReportImageRequest(Sender: TObject; const SRC: string; var Stream: TStream);
        procedure chkCreateChartClick(Sender: TObject);
        procedure miCopySelectedClick(Sender: TObject);
        procedure miPrintClick(Sender: TObject);
        procedure miPrintPreviewClick(Sender: TObject);
        procedure miSaveClick(Sender: TObject);
        procedure btnShowSetupPanelClick(Sender: TObject);
        procedure pnlCloseSetupPanelClick(Sender: TObject);
    private
        { Private declarations }
        FIDList         : TStrings; // ���������飬�����ظ�������������
        FMeterList      : TStrings; // �û�ѡ���Ҫ���������
        FDataSet        : TClientDataSet;
        FGenBreak       : boolean; // �Ƿ��ж�����
        FChartExportPath: string;
        FStream         : TMemoryStream;
        procedure GenRptGrid;
        function GenMeterGrid(AMeter: TMeterDefine): string;
        // ���������ֱ����ɱ��
        function GenMeterGridDDWY(AMeter: TMeterDefine): string;
        function GenMeterGridMS(AMeter: TMeterDefine): string;
        function GenMeterGridMG(AMeter: TMeterDefine): string;
        function GenMeterGridMGGroup(AMeter: TMeterDefine): string;
    public
        { Public declarations }
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;

    end;

implementation

uses
    uWBLoadHTML, uWebGridCross, uWeb_DataSet2HTML, uHJX.Intf.GraphDispatcher,
    uHJX.Intf.FunctionDispatcher, uHJX.EnvironmentVariables,
    PreviewForm;

const
    { ע�������CSS����ʹ�ñ�����ϸ�߱߿� }
    { ��Ա��ı�ͷ����Ԫ��ʹ����CSS���� }
    htmPageCode2 = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10
        + '<html>'#13#10
        + '<head>'#13#10
        + '<meta http-equiv="Content-Type" content="text/html; charset=GB2312" />'#13#10
        + '@PageTitle@'#13#10
        + '<style type="text/css">'#13#10
        + '.DataGrid {border:1px solid #000099;border-width:1px 1px 1px 1px;margin:1px 1px 1px 1px;border-collapse:collapse}'#13#10
        + '.thStyle {font-size: 8pt; font-family: Consolas; color: #000000; padding:3px;border:1px solid #000099}'#13#10
        + '.tdStyle {font-size: 8pt; font-family: Consolas; color: #000000; background-color:#FFFFFF;empty-cells:show;'
    // #F7F7F7
        + '          border:1px solid #000099; padding:3px}'#13#10
        + '.CaptionStyle {font-family:����;font-size: 9pt;color: #000000; padding:3px;border:1px solid #000099; background-color:#FFFF99}'#13#10
        + '</style>'#13#10
        + '</head>'#13#10
        + '<body>'#13#10
        + '@PageContent@'#13#10
        + '</body>'#13#10
        + '</html>';
{$R *.dfm}


var
    IGD: IGraphDispatcher;
    IFD: IFunctionDispatcher;

procedure TfraRptDataHTMLGrid.btnCreateReportClick(Sender: TObject);
var
    i: integer;
begin
    if rdgMeterOption.ItemIndex = 1 then
        if IFD.HasProc('PopupMeterSelector') then
            IFD.CallFunction('PopupMeterSelector', FMeterList)
        else
            ShowMessage('û���ṩ����ʽ����ѡ�񴰹���')
    else
    begin // ��������ȫ�������ģ��ͽ����������б���ӽ�ȥ
        FMeterList.Clear;
        ExcelMeters.SortByPosition;
        for i := 0 to ExcelMeters.Count - 1 do
            FMeterList.Add(ExcelMeters.Items[i].DesignName);
    end;

    GenRptGrid;
end;

procedure TfraRptDataHTMLGrid.btnShowSetupPanelClick(Sender: TObject);
begin
    pnlSetup.Visible := True;
end;

procedure TfraRptDataHTMLGrid.chkCreateChartClick(Sender: TObject);
begin
    chkExportChart.Enabled := chkCreateChart.Checked;
end;

constructor TfraRptDataHTMLGrid.Create(AOwner: TComponent);
begin
    inherited;
    FIDList := TStringList.Create;
    FMeterList := TStringList.Create;
    FDataSet := TClientDataSet.Create(Self);
    dtpEnd.Date := now;
    dtpStart.Date := IncMonth(now, -1);
    FStream := TMemoryStream.Create;
    FChartExportPath := ENV_TempPath;
    if not Supports(IAppServices.getdispatcher('GraphDispatcher'), IGraphDispatcher, IGD) then
        IGD := nil;
    IFD := IAppServices.FuncDispatcher as IFunctionDispatcher;
end;

destructor TfraRptDataHTMLGrid.Destroy;
begin
    FIDList.Free;
    FMeterList.Free;
    FDataSet.Free;
    FStream.Free;
    inherited;
end;

procedure TfraRptDataHTMLGrid.dtpStartClick(Sender: TObject);
begin
    rdDataRange.Checked := True;
end;

procedure TfraRptDataHTMLGrid.FrameResize(Sender: TObject);
begin
    pnlProgress.Left := (Self.ClientWidth - pnlProgress.Width) div 2;
    pnlProgress.Top := (Self.ClientHeight - pnlProgress.Height) div 2;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GenRptGrid
  Description: ���ɱ���
----------------------------------------------------------------------------- }
{ DONE:�������iMeter��ʵ�ʵ�Meter�����������صĴ�������iMeterͬ������ }
procedure TfraRptDataHTMLGrid.GenRptGrid;
const
    SImgLink = '<img src="%s">';
var
    sDsnName          : string;
    sPage, sContent   : string;
    sType, sPos, s, s1: string;
    sImg              : string;
    sImgFile          : string;
    AMeter            : TMeterDefine;
    iMeter            : integer;
    i, iCount         : integer;
begin
    sPage := StringReplace(htmPageCode2, '@PageTitle@', '�۲����ݱ���', [rfReplaceAll]);
    sContent := '';
    sType := '';
    sPos := '';

    if FChartExportPath = '' then
        FChartExportPath := ENV_TempPath;

    if chkCreateChart.Checked then
        if chkExportChart.Checked then
            if SelectDirectory('ѡ�񱣴�����ͼ�ε��ļ���', '', FChartExportPath) then
                if Trim(FChartExportPath) <> '' then
                    if Copy(FChartExportPath, Length(FChartExportPath) - 1, 1) <> '\' then
                        FChartExportPath := FChartExportPath + '\';

    FIDList.Clear; // ������FIDList�����Ѿ��ڴ���������ʱ���ɹ����ݵ�������������Щ��������
    { DONE:Ӧ�������������Ѿ����ɹ����ݱ������ }
    Screen.Cursor := crHourGlass;
    lblProgress.Caption := '';
    lblMeterName.Caption := '';
    pnlProgress.Visible := True;
    iCount := FMeterList.Count; // ExcelMeters.Count;
    Progress.Min := 1;
    Progress.Max := iCount;
    FGenBreak := False;
    // Progress.Position := 1;
    IHJXClientFuncs.SessionBegin;
    for iMeter := 0 to FMeterList.Count - 1 { ExcelMeters.Count - 1 } do
    begin
        AMeter := ExcelMeters.Meter[FMeterList.Strings[iMeter]];
        Progress.Position := iMeter + 1;
        sDsnName := AMeter.DesignName; // ExcelMeters.Items[iMeter].DesignName;
        lblMeterName.Caption := '���ڴ���' + sDsnName + '������...';
        lblProgress.Caption := Format('���ڴ����%d֧������%d', [iMeter + 1, iCount]);
        Application.ProcessMessages;

        // �������û��ָ�����ݱ�����һ��
        if (AMeter.DataBook = '') or (AMeter.DataSheet = '') then
            Continue;

        if FIDList.IndexOf(sDsnName) <> -1 then
            Continue;

        s1 := AMeter.PrjParams.Position; // ExcelMeters.Items[iMeter].PrjParams.Position;
        if sPos <> s1 then
        begin
            sPos := s1;
            sContent := sContent + '<h2>' + sPos + '</h2>';
        end;

        s := AMeter.Params.MeterType; // ExcelMeters.Items[iMeter].Params.MeterType;
        if s <> sType then
        begin
            sType := s;
            sContent := sContent + '<h3>' + sType + '</h3>';
        end;

        sContent := sContent + GenMeterGrid(AMeter { ExcelMeters.Items[iMeter] } );
        // ���ͼ������
        if chkCreateChart.Checked then
        begin
            if chkExportChart.Checked then
            begin
                if Assigned(IGD) then
                begin
                    if rdgDTRangeOption.ItemIndex = 0 then
                        sImgFile := IGD.ExportChartToFile(sDsnName, 0, 0,
                            FChartExportPath, 600, 300)
                    else
                        sImgFile := IGD.ExportChartToFile(sDsnName, dtpStart.DateTime,
                            dtpEnd.DateTime, FChartExportPath, 600, 300);

                    if sImgFile <> '' then
                    begin
                        sImg := Format(SImgLink, [sImgFile]);
                        sContent := sContent + sImg;
                    end;
                end;
            end
            else
            begin
                sContent := sContent + Format('<img src="GETCHART:%s">', [sDsnName]);
            end;
        end;

        Application.ProcessMessages;
        if FGenBreak then
            break;
    end;
    IHJXClientFuncs.SessionEnd;
    sPage := StringReplace(sPage, '@PageContent@', sContent, [rfReplaceAll]);
    hvReport.Clear;
    hvReport.LoadFromString(sPage);
    Screen.Cursor := crDefault;
    pnlProgress.Visible := False;
end;

procedure TfraRptDataHTMLGrid.hvReportImageRequest(Sender: TObject; const SRC: string;
    var Stream: TStream);
var
    sName: string;
    i    : integer;
    // AStream:TMemoryStream;
begin
    i := Pos('GETCHART', SRC);
    if i > 0 then // �������˵�������ⲿ����
    begin
        if not Assigned(IGD) then
            Exit;
        i := Pos(':', SRC); // ����������Ϊ��GETCHART:DesignName
        sName := Copy(SRC, i + 1, Length(SRC) - i);
        { DONE:��Ҫ�����ͷ�Stream�����⣬���򷴸�ʹ�ú��ڴ�ᱻռ��̫�� }
        if FStream = nil then
            FStream := TMemoryStream.Create;
        FStream.Clear;
        if rdgDTRangeOption.ItemIndex = 0 then
            IGD.SaveChartToStream(sName, 0, 0, FStream, 600, 300)
        else
            IGD.SaveChartToStream(sName, dtpStart.DateTime, dtpEnd.DateTime, FStream, 600, 300);
        Stream := FStream;
    end;
end;

procedure TfraRptDataHTMLGrid.lblBreakClick(Sender: TObject);
begin
    FGenBreak := True;
end;

procedure TfraRptDataHTMLGrid.miCopyAllClick(Sender: TObject);
begin
    hvReport.SelectAll;
    hvReport.CopyToClipboard;
    hvReport.SelLength := 0;
end;

procedure TfraRptDataHTMLGrid.miCopySelectedClick(Sender: TObject);
begin
    { HTMLViewerò�Ʋ���ֻ�����ĵ��м䲿�ֵ����ݣ���ʹֻѡ�����м�ĳ���֣��������Ǵ��ĵ���ͷһֱ
      ������ѡ�в��ֵ�ĩβ�����Ǹ�ȱ�ݰ�~~ }
    if hvReport.SelLength <> 0 then
        hvReport.CopyToClipboard;
end;

procedure TfraRptDataHTMLGrid.miPrintClick(Sender: TObject);
begin
    // hvReport.Print(1, 2);
    with dlgPrint do
        if Execute then
            if PrintRange = prAllPages then
                hvReport.Print(1, 9999)
            else
                hvReport.Print(FromPage, ToPage);
end;

procedure TfraRptDataHTMLGrid.miPrintPreviewClick(Sender: TObject);
var
    frm  : TPreviewForm;
    Abort: boolean;
begin
    frm := TPreviewForm.CreateIt(Self, hvReport, Abort);
    try
        if not Abort then
            frm.ShowModal
    finally
        frm.Release;
    end;
end;

procedure TfraRptDataHTMLGrid.miSaveClick(Sender: TObject);
var
    Strs: TStrings;
begin
    with dlgSave do
        if Execute then
        begin
            Strs := TStringList.Create;
            try
                Strs.Text := hvReport.DocumentSource;
                Strs.SaveToFile(dlgSave.FileName);
            finally
                Strs.Free;
            end;
        end;
end;

procedure TfraRptDataHTMLGrid.pnlCloseSetupPanelClick(Sender: TObject);
begin
    pnlSetup.Visible := False;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GenMeterGrid
  Description: ���ɹ۲����ݱ�
----------------------------------------------------------------------------- }
function TfraRptDataHTMLGrid.GenMeterGrid(AMeter: TMeterDefine): string;
var
    sType, sGrid: string;
begin
    Result := '';
    // ���û�����ݱ�������
    if AMeter.DataSheet = '' then
        Exit;

    // ���ɱ���
    Result := '<h4>' + AMeter.DesignName + '</h4>';
    // �����������͵��ò�ͬ�ı�񷽷�
    sType := AMeter.Params.MeterType;
    if sType = '���λ�Ƽ�' then
        sGrid := GenMeterGridDDWY(AMeter)
    else if sType = 'ê��������' then
        sGrid := GenMeterGridMS(AMeter)
    else if sType = 'ê��Ӧ����' then
    begin
        if AMeter.PrjParams.GroupID <> '' then
        begin
            Result := '<h4>' + AMeter.PrjParams.GroupID + '</h4>';
            sGrid := GenMeterGridMGGroup(AMeter);
        end
        else
            sGrid := GenMeterGridMG(AMeter);
    end;
    Result := Result + sGrid + '<p> </p>';
end;

{ -----------------------------------------------------------------------------
  Procedure  : _SetDDWYGridHead
  Description: ���λ�ƼƱ�����������
----------------------------------------------------------------------------- }
procedure _SetDDWYGridHead(WCV: TWebCrossView; mt: TMeterDefine; V: array of Variant);
var
    i: integer;
begin
    // ��һ��
    V[0] := '��Ʊ��';
    for i := 1 to 5 do
        V[i] := mt.DesignName;
    // v[4] := '������';
    // v[5] := mt.PrjParams.Profile;
    WCV.AddRow(V);
    // �ڶ���
    V[0] := '׮��';
    V[1] := mt.PrjParams.Stake;
    V[2] := '��װ�߳�';
    V[3] := mt.PrjParams.Elevation;
    V[4] := '������';
    V[5] := mt.PrjParams.Profile;
    WCV.AddRow(V);
    // ������
    V[0] := '�۲�����';
    for i := 1 to 4 do
        V[i] := '����λ��';
    V[5] := '��ע';
    WCV.AddRow(V);
    // ������
    V[0] := '�۲�����';
    for i := 0 to 3 do
        V[i + 1] := mt.PDDefine[i].Name;
    V[5] := '��ע';
    WCV.AddRow(V);
end;

{ -----------------------------------------------------------------------------
  Procedure  : _SetMSGridHead
  Description: ê�������Ʊ���������
----------------------------------------------------------------------------- }
procedure _SetMSGridHead(WCV: TWebCrossView; mt: TMeterDefine; V: array of Variant);
var
    i: integer;
begin
    // ��һ��
    V[0] := '��Ʊ��';
    for i := 1 to 4 do
        V[i] := mt.DesignName;
    WCV.AddRow(V);
    // �ڶ���
    V[0] := '׮��';
    V[1] := mt.PrjParams.Stake;
    V[2] := mt.PrjParams.Stake;
    V[3] := '��װ�߳�';
    V[4] := mt.PrjParams.Elevation;
    WCV.AddRow(V);
    // ������
    V[0] := '�۲�����';
    V[2] := '�¶ȡ�';
    V[1] := '����(kN)';
    V[3] := 'ԤӦ����ʧ��(%)';
    V[4] := '��ע';
    WCV.AddRow(V);
end;

{ -----------------------------------------------------------------------------
  Procedure  : _SetMGGroupGridHead
  Description: ê�������ͷ����
----------------------------------------------------------------------------- }
procedure _SetMGGroupGridHead(WCV: TWebCrossView; mt: TMeterDefine; mg: TMeterGroupItem;
    V: array of Variant);
var
    i, nCol : integer;
    mt1, mt2: string;
begin
    nCol := 2 + mg.Count * 2;
    // ��һ��
    mt1 := ExcelMeters.Meter[mg.Items[0]].DesignName;
    mt2 := ExcelMeters.Meter[mg.Items[1]].DesignName;
    if mg = nil then
        Exit;
    V[0] := '��Ʊ��';
    V[1] := mg.Name; // ������ʹ������
    V[2] := '׮   ��';
    V[3] := mt.PrjParams.Stake;
    V[4] := '��װ�߳�';
    V[5] := mt.PrjParams.Elevation;
    WCV.AddRow(V);
    // �ڶ���
    V[0] := '�۲�����';
    for i := 0 to mg.Count - 1 do
    begin
        V[i * 2 + 1] := ExcelMeters.Meter[mg.Items[i]].DesignName;
        V[i * 2 + 2] := V[i * 2 + 1];
    end;
    V[nCol - 1] := '��ע';
    WCV.AddRow(V);
    // ������
    for i := 0 to mg.Count - 1 do
    begin
        V[i * 2 + 1] := '����(kN)';
        // V[i * 2 + 2] := 'Ӧ��(MPa)';
        V[i * 2 + 2] := '�¶�(��)';
    end;
    V[0] := '�۲�����';
    V[nCol - 1] := '��ע';
    WCV.AddRow(V);
end;

{ -----------------------------------------------------------------------------
  Procedure  : GenMeterGridDDWY
  Description: ���λ�Ƽ����ݱ�
----------------------------------------------------------------------------- }
function TfraRptDataHTMLGrid.GenMeterGridDDWY(AMeter: TMeterDefine): string;
var
    WCV     : TWebCrossView;
    iCol    : integer;
    V       : array of Variant;
    bGetData: boolean;
begin
    Result := '';
    WCV := TWebCrossView.Create;
    WCV.TitleRows := 4;
    WCV.ColCount := 6;
    for iCol := 1 to 5 do
    begin
        WCV.ColHeader[iCol].Align := taRightJustify;
        WCV.ColHeader[iCol].AllowRowSpan := False;
        // WCV.ColHeader[iRow].AllowColSpan := True;
    end;
    WCV.ColHeader[0].AllowColSpan := True;
    WCV.ColHeader[0].Align := taCenter;

    SetLength(V, 6);
    _SetDDWYGridHead(WCV, AMeter, V);

    try
        bGetData := False;
        if rbAllDatas.Checked then
            bGetData := IHJXClientFuncs.GetAllPDDatas(AMeter.DesignName, FDataSet)
        else
            bGetData := IHJXClientFuncs.GetPDDatasInPeriod(AMeter.DesignName, dtpStart.DateTime,
                dtpEnd.DateTime, FDataSet);

        if bGetData then
            if FDataSet.RecordCount > 0 then
            begin
                FDataSet.First;
                while not FDataSet.Eof do
                begin
                    V[0] := FormatDateTime('yyyy-mm-dd', FDataSet.Fields[0].AsDateTime);
                    V[1] := FDataSet.Fields[1].Value;
                    V[2] := FDataSet.Fields[2].Value;
                    V[3] := FDataSet.Fields[3].Value;
                    V[4] := FDataSet.Fields[4].Value;
                    WCV.AddRow(V);
                    FDataSet.Next;
                end;
            end;
        Result := WCV.CrossGrid;
    finally
        WCV.Free;
        SetLength(V, 0);
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GenMeterGridMS
  Description: ê�����������ݱ�
----------------------------------------------------------------------------- }
function TfraRptDataHTMLGrid.GenMeterGridMS(AMeter: TMeterDefine): string;
var
    WCV     : TWebCrossView;
    iCol    : integer;
    V       : array of Variant;
    bGetData: boolean;
begin
    Result := '';
    WCV := TWebCrossView.Create;
    WCV.TitleRows := 3;
    WCV.ColCount := 5;
    for iCol := 1 to 4 do
    begin
        WCV.ColHeader[iCol].Align := taRightJustify;
        WCV.ColHeader[iCol].AllowRowSpan := False;
        // WCV.ColHeader[iRow].AllowColSpan := True;
    end;
    WCV.ColHeader[0].AllowColSpan := True;
    WCV.ColHeader[0].Align := taCenter;

    SetLength(V, 5);
    _SetMSGridHead(WCV, AMeter, V);

    try
        bGetData := False;
        if rbAllDatas.Checked then
            bGetData := IHJXClientFuncs.GetAllPDDatas(AMeter.DesignName, FDataSet)
        else
            bGetData := IHJXClientFuncs.GetPDDatasInPeriod(AMeter.DesignName, dtpStart.DateTime,
                dtpEnd.DateTime, FDataSet);
        if bGetData then
            if FDataSet.RecordCount > 0 then
            begin
                FDataSet.First;
                while not FDataSet.Eof do
                begin
                    // V[0] := FDataSet.Fields[0].Value;
                    V[0] := FormatDateTime('yyyy-mm-dd', FDataSet.Fields[0].AsDateTime);
                    V[1] := FDataSet.Fields[1].Value;
                    V[2] := FDataSet.Fields[2].Value;
                    // ԤӦ����ʧ��
                    V[3] := FormatFloat('0.00', FDataSet.Fields[3].AsFloat * 100) + '%';
                    WCV.AddRow(V);
                    FDataSet.Next;
                end;
            end;
        Result := WCV.CrossGrid;
    finally
        WCV.Free;
        SetLength(V, 0);
    end;

end;

{ -----------------------------------------------------------------------------
  Procedure  : GenMeterGridMG
  Description: ê��Ӧ�������ݱ�
----------------------------------------------------------------------------- }
function TfraRptDataHTMLGrid.GenMeterGridMG(AMeter: TMeterDefine): string;
begin
    // �Ѿ����鴦���ˣ���֧ê����ʱ������
end;

{ -----------------------------------------------------------------------------
  Procedure  : GenMeterGridMGGroup
  Description: ����ê�������ݱ�
----------------------------------------------------------------------------- }
function TfraRptDataHTMLGrid.GenMeterGridMGGroup(AMeter: TMeterDefine): string;
var
    WCV       : TWebCrossView;
    mg        : TMeterGroupItem;
    i, nCol   : integer;
    iRow, iCol: integer;
    V         : array of Variant;
    bGetData  : boolean;
begin
    Result := '';
    WCV := TWebCrossView.Create;
    mg := MeterGroup.ItemByName[AMeter.PrjParams.GroupID];
    // �������ж�������
    i := mg.Count;
    // ÿ֧ê����Ҫ���У���
    nCol := 2 + i * 2; // ���ڣ�(���ء�Ӧ��)* i, ��ע

    WCV.TitleRows := 3;
    WCV.ColCount := nCol;
    for iCol := 1 to nCol - 1 do
    begin
        WCV.ColHeader[iCol].AllowRowSpan := False;
        WCV.ColHeader[iCol].Align := taRightJustify;
        // WCV.ColHeader[iRow].AllowColSpan := True;
    end;
    WCV.ColHeader[0].Align := taCenter;
    WCV.ColHeader[0].AllowColSpan := True;
    WCV.ColHeader[nCol - 1].AllowColSpan := True;

    SetLength(V, nCol);
    _SetMGGroupGridHead(WCV, AMeter, mg, V);
    bGetData := False;
    try
        if rbAllDatas.Checked then
            bGetData := IHJXClientFuncs.GetGroupAllPDDatas(mg.Name, FDataSet)
        else
            bGetData := IHJXClientFuncs.GetGroupPDDatasInPeriod(mg.Name, dtpStart.DateTime,
                dtpEnd.DateTime, FDataSet);

        if bGetData then
            if FDataSet.RecordCount > 0 then
            begin
                FDataSet.First;
                while not FDataSet.Eof do
                begin
                    V[0] := FormatDateTime('yyyy-mm-dd', FDataSet.Fields[0].AsDateTime);
                    for i := 1 to FDataSet.Fields.Count - 1 do
                        V[i] := FDataSet.Fields[i].Value;
                    WCV.AddRow(V);
                    FDataSet.Next;
                end;
            end;

        Result := WCV.CrossGrid;
        // ��fidlist������Ѿ��������������
        for i := 0 to mg.Count - 1 do
            FIDList.Add(mg.Items[i]);
    finally
        WCV.Free;
        SetLength(V, 0);
    end;
end;

end.
