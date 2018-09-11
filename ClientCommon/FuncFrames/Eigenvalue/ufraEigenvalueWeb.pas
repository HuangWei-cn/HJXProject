{ -----------------------------------------------------------------------------
  Unit Name: ufraEigenvalueWeb
  Author:    ��ΰ
  Date:      14-����-2017
  Purpose:   ����Ԫ�����ݿ�/������ȡ�����������ֵ���ݣ���HTML�����ʽ��ʾ��
  Ƕ���IE������У��û��ɿ���ճ������������С�
  History:
    2018-06-14  �޸��˱���ʽ�������̲�λ����˱��
  ----------------------------------------------------------------------------- }
{ todo:������÷ֱ���ʽ��ʾ����ֵ���ݣ��ɰ���װ��λ���з���ֱ� }
unit ufraEigenvalueWeb;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
    System.StrUtils, System.Types,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.OleCtrls,
    SHDocVw, Vcl.ComCtrls,
    uHJX.Data.Types, uHJX.Intf.Datas, {uHJX.Excel.Meters} uHJX.Classes.Meters,
    uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher;

type
    TfraEigenvalueWeb = class(TFrame)
        Panel1: TPanel;
        btnGetEVData: TButton;
        wbEVPage: TWebBrowser;
        GroupBox1: TGroupBox;
        optLast: TRadioButton;
        optSpecialDate: TRadioButton;
        dtpSpecial: TDateTimePicker;
        rdgMeterOption: TRadioGroup;
        procedure btnGetEVDataClick(Sender: TObject);
    private
        { Private declarations }
        FIDList: TStrings; // �����б�
    public
        { Public declarations }
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        // ȡ�ص�һ��������������ֵ
        procedure GetFirstEVDatas(IDList: string);
        // ȡ���������ݶ����о߱�����ֵ�����ݵ�����ֵ
        procedure GetEVDatas(IDList: string);
    end;

implementation

uses
    uWBLoadHTML, uWebGridCross, uWeb_DataSet2HTML;
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

procedure TfraEigenvalueWeb.btnGetEVDataClick(Sender: TObject);
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
    end;
end;

constructor TfraEigenvalueWeb.Create(AOwner: TComponent);
begin
    inherited;
    FIDList := tstringlist.Create;
end;

destructor TfraEigenvalueWeb.Destroy;
begin
    FIDList.Free;
    inherited;
end;

procedure _GetTitleRowStr(ARow: Integer; var V: array of Variant);
var
    i: Integer;
begin
    // SetLength(V, 15);
    if ARow = 1 then
    begin
        // V[0] := '��װ��λ';
        // V[1] := '��������';
        V[0] := '��Ʊ��';
        V[1] := '������';
        for i := 2 to 5 do
            V[i] := '�԰�װ��������ֵ';
        for i := 6 to 9 do
            V[i] := '������ֵ';
        for i := 10 to 13 do
            V[i] := '������ֵ';
        for i := 14 to 15 do
            V[i] := '��ǰֵ';
    end
    else
    begin
        // V[0] := '��װ��λ';
        // V[1] := '��������';
        V[0] := '��Ʊ��';
        V[1] := '������';

        V[2] := '���ֵ';
        V[3] := '���ֵ����';
        V[4] := '��Сֵ';
        V[5] := '��Сֵ����';
        V[6] := '�����ֵ';
        V[7] := '���ֵ����';
        V[8] := '����Сֵ';
        V[9] := '��Сֵ����';
        V[10] := '�����ֵ';
        V[11] := '���ֵ����';
        V[12] := '����Сֵ';
        V[13] := '��Сֵ����';
        V[14] := '��ǰֵ';
        V[15] := '�۲�����';
    end;
end;

procedure _SetGrid(AW: TWebCrossView);
var
    V: array of Variant;
    i: Integer;
begin
    AW.TitleRows := 2;
    AW.ColCount := 16;
    AW.ColHeader[0].AllowColSpan := true;
    // AW.ColHeader[1].AllowColSpan := true;
    // AW.ColHeader[2].AllowColSpan := true;
    for i := 2 to 15 do
    begin
        if (i mod 2 = 0) then
            AW.ColHeader[i].Align := taRightJustify
        else
            AW.ColHeader[i].Align := taCenter;
    end;

    SetLength(V, 16);
    _GetTitleRowStr(1, V);
    AW.AddRow(V);
    // WCV.AddCaptionRow(V);
    _GetTitleRowStr(2, V);
    AW.AddRow(V);
    // WCV.AddCaptionRow(V);
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetFirstEVDatas
  Description: �����������ص�һ��������������ֵ
  ----------------------------------------------------------------------------- }
procedure TfraEigenvalueWeb.GetFirstEVDatas(IDList: string);
var
    i, j: Integer;
    // EVData: PEVDataStru;
    Meter: TMeterDefine;
    WCV  : TWebCrossView;
    V    : array of Variant;
    D    : TDoubleDynArray;
begin
    FIDList.Text := IDList;
    if FIDList.Count = 0 then
        Exit;

    WCV := TWebCrossView.Create;
    _SetGrid(WCV);
    SetLength(V, 16);
    try
        for i := 0 to FIDList.Count - 1 do
            if IHJXClientFuncs.GetEVData(FIDList.Strings[i], D) then
            begin
                Meter := ExcelMeters.Meter[FIDList.Strings[i]];
                // V[0] := Meter.PrjParams.Position;
                // V[1] := Meter.Params.MeterType;
                V[0] := FIDList.Strings[i];
                V[1] := Meter.PDDefine[0].Name;
                for j := 0 to 13 do
                begin
                    if j mod 2 = 1 then
                        V[j + 2] := FormatDateTime('yyyy-mm-dd', FloatToDateTime(D[j]))
                    else
                        V[j + 2] := D[j];
                end;
                WCV.AddRow(V);
            end;
        WB_LoadHTML(wbEVPage, WCV.CrossPage);
    finally
        WCV.Free;
        SetLength(V, 0);
    end;
end;

procedure TfraEigenvalueWeb.GetEVDatas(IDList: string);
var
    i, j   : Integer;
    EVDatas: PEVDataArray;
    Meter  : TMeterDefine;
    WCV    : TWebCrossView;
    V      : array of Variant;
    page   : string;
    Body   : string;
    sPos   : string;
    sType  : string;
begin
    FIDList.Text := IDList;
    if FIDList.Count = 0 then
        Exit;

    WCV := TWebCrossView.Create;
// WCV.TitleRows := 2;
// WCV.ColCount := 18;
// WCV.ColHeader[0].AllowColSpan := true;
// WCV.ColHeader[1].AllowColSpan := true;
// WCV.ColHeader[2].AllowColSpan := true;
// for i := 4 to 17 do
// begin
// if (i mod 2 = 0) then
// WCV.ColHeader[i].Align := taRightJustify
// else
// WCV.ColHeader[i].Align := taCenter;
// end;
//
// SetLength(V, 18);
// _GetTitleRowStr(1, V);
// WCV.AddRow(V);
// //WCV.AddCaptionRow(V);
// _GetTitleRowStr(2, V);
// WCV.AddRow(V);
// //WCV.AddCaptionRow(V);

    _SetGrid(WCV);
    SetLength(V, 16);

    Body := '<H2>�۲���������ֵ��</H2>';
    try
        for i := 0 to FIDList.Count - 1 do
            if IHJXClientFuncs.GetEVDatas(FIDList.Strings[i], EVDatas) then
            begin
                Meter := ExcelMeters.Meter[FIDList.Strings[i]];
                if i = 0 then
                begin
                    sPos := Meter.PrjParams.Position;
                    sType := Meter.Params.MeterType;
                    Body := Body + '<h3>' + sPos + '�������</h3>';
                    WCV.AddCaptionRow([sType]);
                end
                else
                begin
                    if Meter.PrjParams.Position <> sPos then
                    begin
                        sPos := Meter.PrjParams.Position;
                        sType := Meter.Params.MeterType;
                        Body := Body + WCV.CrossGrid;
                        Body := Body + '<h3>' + sPos + '�������</h3>';
                        WCV.Reset;
                        _SetGrid(WCV);
                        WCV.AddCaptionRow([sType]);
                    end;
                end;

                if Meter.Params.MeterType <> sType then
                begin
                    sType := Meter.Params.MeterType;
                    WCV.AddCaptionRow([sType]);
                end;

                if Length(EVDatas) > 0 then
                begin
                    for j := Low(EVDatas) to High(EVDatas) do
                    begin
                        // V[0] := Meter.PrjParams.Position;
                        // V[1] := Meter.Params.MeterType;
                        V[0] := FIDList.Strings[i];
                        V[1] := Meter.PDDefine[EVDatas[j].PDIndex].Name;
                        // ��Ӹ���
                        with EVDatas[j]^ do
                        begin
                            V[2] := Lifeev.MaxValue;
                            V[3] := FormatDateTime('yyyy-mm-dd', Lifeev.MaxDate);
                            V[4] := Lifeev.MinValue;
                            V[5] := FormatDateTime('yyyy-mm-dd', Lifeev.MinDate);

                            V[6] := YearEV.MaxValue;
                            V[7] := FormatDateTime('yyyy-mm-dd', YearEV.MaxDate);
                            V[8] := YearEV.MinValue;
                            V[9] := FormatDateTime('yyyy-mm-dd', YearEV.MinDate);

                            V[10] := MonthEV.MaxValue;
                            V[11] := FormatDateTime('yyyy-mm-dd', MonthEV.MaxDate);
                            V[12] := MonthEV.MinValue;
                            V[13] := FormatDateTime('yyyy-mm-dd', MonthEV.MinDate);

                            V[14] := CurValue;
                            V[15] := FormatDateTime('yyyy-mm-dd', CurDate);
                        end;
                        WCV.AddRow(V);
                    end;
                end;
                // V[0]  := Meter.PrjParams.Position;
                // V[1]  := Meter.Params.MeterType;
                // V[2]  := FIDList.Strings[i];
                // v[3] := meter.PDDefine[0].Name;
                // for j := 0 to 13 do
                // begin
                // if j mod 2 = 1 then
                // V[j + 4] := FormatDateTime('yyyy-mm-dd', FloatToDateTime(D[j]))
                // else
                // V[j + 4] := D[j];
                // end;
            end;
        Body := Body + WCV.CrossGrid;
        page := StringReplace(htmPageCode2, '@PageTitle@', '�۲���������ֵ��', []);
        page := StringReplace(page, '@PageContent@', Body, []);
        // WB_LoadHTML(wbEVPage, WCV.CrossPage);
        WB_LoadHTML(wbEVPage, page);
    finally
        WCV.Free;
        SetLength(V, 0);
        if Length(EVDatas) > 0 then
        begin
            for i := Low(EVDatas) to High(EVDatas) do
                try
                    Dispose(EVDatas[i]);
                except
                end;
            SetLength(EVDatas, 0);
        end;
    end;

end;

end.
