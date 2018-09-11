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
    Vcl.StdCtrls, Vcl.ComCtrls, Vcl.WinXCtrls, Vcl.Menus;

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
        procedure btnCreateQuickViewClick(Sender: TObject);
        procedure btnShowIncrementClick(Sender: TObject);
        procedure HtmlViewerHotSpotClick(Sender: TObject; const SRC: string; var Handled: Boolean);
        procedure miCopyClick(Sender: TObject);
        procedure miPrintClick(Sender: TObject);
        procedure miSaveClick(Sender: TObject);
    private
        { Private declarations }
    public
        { Public declarations }
        { ��ʾ�۲�������� }
        procedure ShowQuickView;
        { ��ʾ�۲�������������UseFilter = False����ʾȫ����������������������ֻ��ʾ���޵� }
        procedure ShowDataIncrement(UseFilter: Boolean = False);
    end;

implementation

uses
    uHJX.Data.Types, uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher, uHJX.Intf.Datas,
    uHJX.Classes.Meters,
    uWebGridCross;
{$R *.dfm}


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
        + '.thStyle {font-size: 8pt; font-family: Tahoma; color: #000000; padding:3px;border:1px solid #000099}'#13#10
        + '.tdStyle {font-size: 8pt; font-family: Tahoma; color: #000000; background-color:#FFFFFF;empty-cells:show;'
    // #F7F7F7
        + '          border:1px solid #000099; padding:3px}'#13#10
        + '.CaptionStyle {font-family:����;font-size: 9pt;color: #000000; padding:3px;border:1px solid #000099; background-color:#FFFF99}'#13#10
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
    Meter      : TMeterDefine;
    MeterType  : string;
    V1, V2     : TDoubleDynArray;
    iMeter     : Integer;
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
    try
        Screen.Cursor := crHourGlass;

        ProgressBar.Max := ExcelMeters.Count;
        ProgressBar.Min := 1;
        ProgressBar.Position := 1;
        lblDesignName.Caption := '';
        lblProgress.Caption := '';

        pnlProgress.Visible := True;
        pnlProgress.Left := (Self.Width - pnlProgress.Width) div 2;
        pnlProgress.Top := (Self.Height - pnlProgress.Height) div 2;

        WCV := TWebCrossView.Create;

        for iMeter := 0 to ExcelMeters.Count - 1 do
        begin
            Meter := ExcelMeters.Items[iMeter];
            MeterType := Meter.Params.MeterType;

            ProgressBar.Position := iMeter + 1;
            lblDesignName.Caption := Meter.Params.MeterType + Meter.DesignName;
            lblProgress.Caption := Format('���ڴ����%d֧��������%d֧', [iMeter + 1, ExcelMeters.Count]);

            IAppServices.ProcessMessages;

            if IAppServices.ClientDatas.GetLastPDDatas(Meter.DesignName, V2) then
            begin
                if IAppServices.ClientDatas.GetLastPDDatasBeforeDate(Meter.DesignName, V2[0], V1)
                then
                begin
                    ShowTwoData;
                end
                else
                    ShowOneData;  //û��������������û�п��Ǻ������ʾ��������
                Inc(iMeterCount);
            end;
        end;

        // ��ʾ��������
        Body := Body + Format('<hr>���β�ֵ����������ע��ֵ��������%d֧�����������۲����ݱ仯��С��<br>', [iOverLine]);
        Body := Body + Format('��������ι۲��У���%d֧����(������)����������%d֧�������ݼ�С��', [iInc, iDec]);
        Page := StringReplace(htmPageCode2, '@PageContent@', Body, []);

        HtmlViewer.LoadFromString(Page);
    finally
        WCV.Free;
        pnlProgress.Visible := False;
        Screen.Cursor := crDefault;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : ShowDataIncrement
  Description: ��������ѯȫ��������ָ��ʱ��Ĺ۲�����������������������HTMLViewer
  ����ʾ���������UseFilter=True������˵��仯��С�����ݣ�ֻ�����仯��ġ�
----------------------------------------------------------------------------- }
procedure TfraQuickViewer.btnShowIncrementClick(Sender: TObject);
begin
    ShowDataIncrement(chkUseFilter.Checked);
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
    i := Pos(':', SRC);
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
            strs := Tstringlist.Create;
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
        vH[7] := '������';
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
    if ExcelMeters.Count = 0 then
        Exit;

    Body := '<h2>�۲����ݱ仯�����</h2>';
    WCV := TWebCrossView.Create;
    SetGrid;
    sType := '';
    sPos := '';
    IHJXClientFuncs.SessionBegin;
    try
        Screen.Cursor := crHourGlass;
        ProgressBar.Position := 1;
        ProgressBar.Max := ExcelMeters.Count;
        lblProgress.Caption := '';
        lblDesignName.Caption := '';
        iCount := ExcelMeters.Count;
        pnlProgress.Visible := True;

        sPos := ExcelMeters.Items[0].PrjParams.Position;
        Body := Body + '<h3>' + sPos + '</h3>';
        for iMeter := 0 to ExcelMeters.Count - 1 do
        begin
            Meter := ExcelMeters.Items[iMeter];

            lblDesignName.Caption := Meter.DesignName;
            lblProgress.Caption := Format('���ڴ����%d֧����%d֧', [iMeter, iCount]);
            ProgressBar.Position := iMeter;
            IAppServices.ProcessMessages;

            if Meter.PrjParams.Position <> sPos then
            begin
                sPos := Meter.PrjParams.Position;
                Body := Body + WCV.CrossGrid;
                Body := Body + '<h3>' + sPos + '</h3>';
                WCV.Reset;
                SetGrid;
                // WCV.AddCaptionRow([sPos]);
                sType := '';
            end;

            if Meter.Params.MeterType = '��б��' then
                Continue;
            if Meter.Params.MeterType <> sType then
            begin
                sType := Meter.Params.MeterType;
                WCV.AddCaptionRow([sType]);
            end;

            { ��ѯ������������ }
            if IHJXClientFuncs.GetDataIncrement(Meter.DesignName, now, V) then
            begin
                if (sType = 'ê��������') or (sType = 'ê��Ӧ����') then
                begin
                    if UseFilter then
                        if sType = 'ê��������' then
                        begin
                            if IgnoreData(V[0][4], MaxDeltaMS) and IgnoreData(V[0][5], MaxDeltaMS)
                            then
                                Continue
                        end
                        else if sType = 'ê��Ӧ����' then
                            if IgnoreData(V[0][4], MaxDeltaMG) and IgnoreData(V[0][5], MaxDeltaMG)
                            then
                                Continue;

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
                end;
            end;

        end;
        Body := Body + WCV.CrossGrid;
        Page := StringReplace(htmPageCode2, '@PageContent@', Body, []);
        HtmlViewer.LoadFromString(Page);
    finally
        WCV.Free;
        ClearValues;
        IHJXClientFuncs.SessionEnd;
        Screen.Cursor := crDefault;
        pnlProgress.Visible := False;
    end;
end;

end.
