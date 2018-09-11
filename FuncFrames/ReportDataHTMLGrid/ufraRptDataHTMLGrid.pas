{ -----------------------------------------------------------------------------
 Unit Name: ufraRptDataHTMLGrid
 Author:    黄伟
 Date:      25-五月-2018
 Purpose:   本单元用来快速生成全部监测仪器的观测数据报表表格，表格为HTML格式。

 History:   2018-06-06
            修正锚索测力计表头错误；将按钮.Caption从“生成报表”改为"生成数据表";
            将对uHJX.Excel.Meters单元的引用改为uHJX.Classes.Meters；

            2018-06-15
            增加仪器图形如过程线到Web页面，过程线可以是保存在外部的文件，也可以
            由Stream提供。前者可以正常显示到Word中，后者则无法显示。

            2018-06-21
            增加选择部分仪器的功能

            2018-08-08
            跳过没有指定数据文件或数据表的仪器
----------------------------------------------------------------------------- }
{ DONE: 增加挑选部分仪器的功能：单选仪器、选某种类别 }
{ DONE: 增加保存为文件的功能 }
{ DONE: 使用功能调度器和接口 }
{ todo: 将针对具体仪器类型的表格生成代码分解到不同的单元，本Frame仅提供界面 }
{ todo: 完成平面变形测点数据表的处理 }
{ DONE: 改用HTMLViewer组件替代IE进行显示 }
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
        FIDList         : TStrings; // 用于仪器组，避免重复处理组中仪器
        FMeterList      : TStrings; // 用户选择的要处理的仪器
        FDataSet        : TClientDataSet;
        FGenBreak       : boolean; // 是否中断生成
        FChartExportPath: string;
        FStream         : TMemoryStream;
        procedure GenRptGrid;
        function GenMeterGrid(AMeter: TMeterDefine): string;
        // 各类仪器分别生成表格
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
    { 注：这里的CSS设置使得表格呈现细线边框 }
    { 针对表格的表头、单元格使用了CSS定义 }
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
        + '.CaptionStyle {font-family:黑体;font-size: 9pt;color: #000000; padding:3px;border:1px solid #000099; background-color:#FFFF99}'#13#10
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
            ShowMessage('没有提供弹出式仪器选择窗功能')
    else
    begin // 若是生成全部仪器的，就将整个仪器列表都添加进去
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
  Description: 生成报告
----------------------------------------------------------------------------- }
{ DONE:将这里的iMeter用实际的Meter对象替代，相关的处理方法的iMeter同样处理。 }
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
    sPage := StringReplace(htmPageCode2, '@PageTitle@', '观测数据报表', [rfReplaceAll]);
    sContent := '';
    sType := '';
    sPos := '';

    if FChartExportPath = '' then
        FChartExportPath := ENV_TempPath;

    if chkCreateChart.Checked then
        if chkExportChart.Checked then
            if SelectDirectory('选择保存数据图形的文件夹', '', FChartExportPath) then
                if Trim(FChartExportPath) <> '' then
                    if Copy(FChartExportPath, Length(FChartExportPath) - 1, 1) <> '\' then
                        FChartExportPath := FChartExportPath + '\';

    FIDList.Clear; // 这里用FIDList保存已经在处理仪器组时生成过数据的仪器，遇到这些仪器跳过
    { DONE:应跳过仪器组中已经生成过数据表的仪器 }
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
        lblMeterName.Caption := '正在处理' + sDsnName + '的数据...';
        lblProgress.Caption := Format('正在处理第%d支，共有%d', [iMeter + 1, iCount]);
        Application.ProcessMessages;

        // 如果仪器没有指定数据表，则下一个
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
        // 添加图形链接
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
    if i > 0 then // 有这个，说明不是外部链接
    begin
        if not Assigned(IGD) then
            Exit;
        i := Pos(':', SRC); // 该类型链接为：GETCHART:DesignName
        sName := Copy(SRC, i + 1, Length(SRC) - i);
        { DONE:需要考虑释放Stream的问题，否则反复使用后，内存会被占用太多 }
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
    { HTMLViewer貌似不能只拷贝文档中间部分的内容，即使只选择了中间某部分，拷贝后都是从文档开头一直
      拷贝到选中部分的末尾，这是个缺陷啊~~ }
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
  Description: 生成观测数据表
----------------------------------------------------------------------------- }
function TfraRptDataHTMLGrid.GenMeterGrid(AMeter: TMeterDefine): string;
var
    sType, sGrid: string;
begin
    Result := '';
    // 如果没有数据表则不生成
    if AMeter.DataSheet = '' then
        Exit;

    // 生成标题
    Result := '<h4>' + AMeter.DesignName + '</h4>';
    // 根据仪器类型调用不同的表格方法
    sType := AMeter.Params.MeterType;
    if sType = '多点位移计' then
        sGrid := GenMeterGridDDWY(AMeter)
    else if sType = '锚索测力计' then
        sGrid := GenMeterGridMS(AMeter)
    else if sType = '锚杆应力计' then
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
  Description: 多点位移计表格标题行设置
----------------------------------------------------------------------------- }
procedure _SetDDWYGridHead(WCV: TWebCrossView; mt: TMeterDefine; V: array of Variant);
var
    i: integer;
begin
    // 第一行
    V[0] := '设计编号';
    for i := 1 to 5 do
        V[i] := mt.DesignName;
    // v[4] := '监测断面';
    // v[5] := mt.PrjParams.Profile;
    WCV.AddRow(V);
    // 第二行
    V[0] := '桩号';
    V[1] := mt.PrjParams.Stake;
    V[2] := '安装高程';
    V[3] := mt.PrjParams.Elevation;
    V[4] := '监测断面';
    V[5] := mt.PrjParams.Profile;
    WCV.AddRow(V);
    // 第三行
    V[0] := '观测日期';
    for i := 1 to 4 do
        V[i] := '区间位移';
    V[5] := '备注';
    WCV.AddRow(V);
    // 第四行
    V[0] := '观测日期';
    for i := 0 to 3 do
        V[i + 1] := mt.PDDefine[i].Name;
    V[5] := '备注';
    WCV.AddRow(V);
end;

{ -----------------------------------------------------------------------------
  Procedure  : _SetMSGridHead
  Description: 锚索测力计表格标题设置
----------------------------------------------------------------------------- }
procedure _SetMSGridHead(WCV: TWebCrossView; mt: TMeterDefine; V: array of Variant);
var
    i: integer;
begin
    // 第一行
    V[0] := '设计编号';
    for i := 1 to 4 do
        V[i] := mt.DesignName;
    WCV.AddRow(V);
    // 第二行
    V[0] := '桩号';
    V[1] := mt.PrjParams.Stake;
    V[2] := mt.PrjParams.Stake;
    V[3] := '安装高程';
    V[4] := mt.PrjParams.Elevation;
    WCV.AddRow(V);
    // 第三行
    V[0] := '观测日期';
    V[2] := '温度℃';
    V[1] := '拉力(kN)';
    V[3] := '预应力损失率(%)';
    V[4] := '备注';
    WCV.AddRow(V);
end;

{ -----------------------------------------------------------------------------
  Procedure  : _SetMGGroupGridHead
  Description: 锚杆组表格表头设置
----------------------------------------------------------------------------- }
procedure _SetMGGroupGridHead(WCV: TWebCrossView; mt: TMeterDefine; mg: TMeterGroupItem;
    V: array of Variant);
var
    i, nCol : integer;
    mt1, mt2: string;
begin
    nCol := 2 + mg.Count * 2;
    // 第一行
    mt1 := ExcelMeters.Meter[mg.Items[0]].DesignName;
    mt2 := ExcelMeters.Meter[mg.Items[1]].DesignName;
    if mg = nil then
        Exit;
    V[0] := '设计编号';
    V[1] := mg.Name; // 这里编号使用组名
    V[2] := '桩   号';
    V[3] := mt.PrjParams.Stake;
    V[4] := '安装高程';
    V[5] := mt.PrjParams.Elevation;
    WCV.AddRow(V);
    // 第二行
    V[0] := '观测日期';
    for i := 0 to mg.Count - 1 do
    begin
        V[i * 2 + 1] := ExcelMeters.Meter[mg.Items[i]].DesignName;
        V[i * 2 + 2] := V[i * 2 + 1];
    end;
    V[nCol - 1] := '备注';
    WCV.AddRow(V);
    // 第三行
    for i := 0 to mg.Count - 1 do
    begin
        V[i * 2 + 1] := '荷载(kN)';
        // V[i * 2 + 2] := '应力(MPa)';
        V[i * 2 + 2] := '温度(℃)';
    end;
    V[0] := '观测日期';
    V[nCol - 1] := '备注';
    WCV.AddRow(V);
end;

{ -----------------------------------------------------------------------------
  Procedure  : GenMeterGridDDWY
  Description: 多点位移计数据表
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
  Description: 锚索测力计数据表
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
                    // 预应力损失率
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
  Description: 锚杆应力计数据表
----------------------------------------------------------------------------- }
function TfraRptDataHTMLGrid.GenMeterGridMG(AMeter: TMeterDefine): string;
begin
    // 已经按组处理了，单支锚杆暂时不做吧
end;

{ -----------------------------------------------------------------------------
  Procedure  : GenMeterGridMGGroup
  Description: 生成锚杆组数据表
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
    // 看组里有多少仪器
    i := mg.Count;
    // 每支锚杆需要两列，则
    nCol := 2 + i * 2; // 日期，(荷载、应力)* i, 备注

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
        // 向fidlist中添加已经处理过的仪器名
        for i := 0 to mg.Count - 1 do
            FIDList.Add(mg.Items[i]);
    finally
        WCV.Free;
        SetLength(V, 0);
    end;
end;

end.
