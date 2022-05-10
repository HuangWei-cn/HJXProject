{ -----------------------------------------------------------------------------
  Unit Name: ufraEigenvalueWeb
  Author:    ��ΰ
  Date:      14-����-2017
  Purpose:   ����Ԫ�����ݿ�/������ȡ�����������ֵ���ݣ���HTML�����ʽ��ʾ��
  Ƕ���IE������У��û��ɿ���ճ������������С�
  History:
    2018-06-14  �޸��˱���ʽ�������̲�λ����˱��
    2018-09-18  �����˲�ѯʱ���������ֵ�Ĺ��ܣ������ˡ��������͡���������
  ----------------------------------------------------------------------------- }
{ todo:������÷ֱ���ʽ��ʾ����ֵ���ݣ��ɰ���װ��λ���з���ֱ� }
{ todo:�����û�ѡ�������ݣ����ѡ�Ƿ���������������������ǰֵ������������ȵȡ�
��Ȼ��ѯ����Ƿ���ȫ�����ݣ����Ǳ�ʾ��ʱ��������ѡ����������һ���޴��񣬻����ٱ༭ }
{ todo:�ṩEhGrid��ʾ������ֵ�����������������������ڷ�����������Ƿǳ����õ� }
unit ufraEigenvalueWeb;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.StrUtils, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.OleCtrls,
  SHDocVw, Vcl.ComCtrls,
  uHJX.Data.Types, uHJX.Intf.Datas, {uHJX.Excel.Meters} uHJX.Classes.Meters,
  uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher, uWebGridCross;

type
  TfraEigenvalueWeb = class(TFrame)
    Panel1: TPanel;
    btnGetEVData: TButton;
    wbEVPage: TWebBrowser;
    GroupBox1: TGroupBox;
    optLast: TRadioButton;
    optSpecialDate: TRadioButton;
    dtpStart: TDateTimePicker;
    rdgMeterOption: TRadioGroup;
    dtpEnd: TDateTimePicker;
    ProgressBar1: TProgressBar;
    grpEVItemSelect: TGroupBox;
    chkHistoryEV: TCheckBox;
    chkYearEV: TCheckBox;
    chkMonthEV: TCheckBox;
    chkLastData: TCheckBox;
    procedure btnGetEVDataClick(Sender: TObject);
    procedure wbEVPageBeforeNavigate2(ASender: TObject; const pDisp: IDispatch; const URL, Flags,
      TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
  private
        { Private declarations }
    FIDList  : TStrings; // �����б�
    FLoadding: Boolean;
    procedure _GetTitleRowStr(ARow: Integer; var V: array of Variant);
    procedure _SetGrid(AW: TWebCrossView);
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
  uWBLoadHTML, uWeb_DataSet2HTML;
{$R *.dfm}


const
    { ע�������CSS����ʹ�ñ�����ϸ�߱߿� }
    { ��Ա��ı�ͷ����Ԫ��ʹ����CSS���� }
  htmPageCode2 = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10
    + '<html>'#13#10
    + '<head>'#13#10
    + '<meta http-equiv="Content-Type" content="text/html; charset=GB2312" />'#13#10
    + '<style type="text/css">'#13#10
    + '.DataGrid {border:1px solid #1F4E79;border-width:1px 1px 1px 1px;margin:1px 1px 1px 1px;border-collapse:collapse}'#13#10
    + '.thStyle {font-size: 8pt; font-family: Consolas; color: #000000; padding:3px;border:1px solid #1F4E79}'#13#10
    + '.tdStyle {font-size: 8pt; font-family: Consolas; color: #000000; background-color:#FFFFFF;empty-cells:show;'
    // #F7F7F7
    + '          border:1px solid #1F4E79; padding:3px}'#13#10
    + '.CaptionStyle {font-family:����;font-size: 9pt;color: #000000; padding:3px;border:1px solid #1F4E79; background-color:#FFFF99}'#13#10
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
  if (chkHistoryEV.Checked or chkYearEV.Checked or chkMonthEV.Checked) = False then
  begin
    ShowMessage('���ܵ�ѡ��һ������ֵʱ�Σ�������ʷ���ꡢ�µȣ���ѡ�Ͳ��飡');
    Exit;
  end;

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
    ProgressBar1.Visible := False;
  end;
end;

constructor TfraEigenvalueWeb.Create(AOwner: TComponent);
begin
  inherited;
  FIDList := tstringlist.Create;
  dtpEnd.Date := Now;
end;

destructor TfraEigenvalueWeb.Destroy;
begin
  FIDList.Free;
  inherited;
end;

procedure TfraEigenvalueWeb._GetTitleRowStr(ARow: Integer; var V: array of Variant);
var
  i, iCol: Integer;
begin
    // SetLength(V, 15);
  // ���б���
  if ARow = 1 then
  begin
        // V[0] := '��װ��λ';
        // V[1] := '��������';
    V[0] := '��Ʊ��';
    V[1] := '������';
    i := 2;
    if chkHistoryEV.Checked then
    begin
      for iCol := i to i + 5 do V[iCol] := '��ʷ����ֵ';
      Inc(i, 6);
    end;

    if chkYearEV.Checked then
    begin
      for iCol := i to i + 5 do V[iCol] := '������ֵ';
      Inc(i, 6);
    end;

    if chkMonthEV.Checked then
    begin
      for iCol := i to i + 5 do V[iCol] := '������ֵ';
      Inc(i, 6);
    end;

    if chkLastData.Checked then
    begin
      for iCol := i to i + 1 do V[iCol] := '��ǰֵ';
      Inc(i, 2);
    end;
  end
  else // �ڶ��б���
  begin
    V[0] := '��Ʊ��';
    V[1] := '������';
    i := 2;
    if chkHistoryEV.Checked then
    begin
      V[i] := '���ֵ';
      V[i + 1] := '���ֵ����';
      V[i + 2] := '��Сֵ';
      V[i + 3] := '��Сֵ����';
      V[i + 4] := '����';
      V[i + 5] := '���';
      Inc(i, 6);
    end;

    if chkYearEV.Checked then
    begin
      V[i] := '�����ֵ';
      V[i + 1] := '���ֵ����';
      V[i + 2] := '����Сֵ';
      V[i + 3] := '��Сֵ����';
      V[i + 4] := '������';
      V[i + 5] := '����';
      Inc(i, 6);
    end;

    if chkMonthEV.Checked then
    begin
      V[i] := '�����ֵ';
      V[i + 1] := '���ֵ����';
      V[i + 2] := '����Сֵ';
      V[i + 3] := '��Сֵ����';
      V[i + 4] := '������';
      V[i + 5] := '�±��';
      Inc(i, 6);
    end;

    if chkLastData.Checked then
    begin
      V[i] := '��ǰֵ';
      V[i + 1] := '�۲�����';
      Inc(i, 2);
    end;
  end;
end;

procedure TfraEigenvalueWeb._SetGrid(AW: TWebCrossView);
var
  V : array of Variant;
  i : Integer;
  CC: Integer; // ColCount
  S : String;
begin
  AW.TitleRows := 2;
  CC := 2; // ��������ͷ������Ʊ�ź�����������2020-10-10
  // 2020-10-10 ���´�������û�ѡ��Ĳ�ѯ����������
  if chkHistoryEV.Checked then Inc(CC, 6);
  if chkYearEV.Checked then Inc(CC, 6);
  if chkMonthEV.Checked then Inc(CC, 6);
  if chkLastData.Checked then Inc(CC, 2);

  // AW.ColCount := { 16 } 22; // 2018-09-18 ���������������
  AW.ColCount := CC;
  AW.ColHeader[0].AllowColSpan := True;
  SetLength(V, CC);
  // ���ñ�ͷ����
  _GetTitleRowStr(1, V);
  AW.AddRow(V);
  // ���ñ�ͷ�ڶ���
  _GetTitleRowStr(2, V);
  AW.AddRow(V);

  for i := 2 to CC - 1 do
  begin
    S := AW.Cells[i, 1].StrValue; // ȡ�ñ���ڶ������ݣ�
    if ((Pos('ֵ', S) > 0) and (Pos('����', S) = 0)) or (Pos('����', S) > 0) or (Pos('���', S) > 0) then
        AW.ColHeader[i].Align := taRightJustify
    else
        AW.ColHeader[i].Align := tacenter;
    (*
    case i of
      2, 4, 6, 7, 8, 10, 12, 13, 14, 16, 18, 19, 20:
        AW.ColHeader[i].Align := taRightJustify;
    else
      AW.ColHeader[i].Align := taCenter;
    end;
 *)
  end;

    // WCV.AddCaptionRow(V);
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetFirstEVDatas
  Description: �����������ص�һ��������������ֵ(�ѷ���������������
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

procedure TfraEigenvalueWeb.wbEVPageBeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  const URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
begin
    // ��������ֵҳ��ʱ����������ת�����¼�
  if FLoadding then
      Exit;

    { TODO -ohw -c����ֵ : �����ﴦ���û����������������¼� }
    // showmessage(vartostr(URL));
  Cancel := True;
end;

procedure TfraEigenvalueWeb.GetEVDatas(IDList: string);
var
  i, j   : Integer; // ѭ����
  iCol   : Integer;
  EVDatas: PEVDataArray;
  Meter  : TMeterDefine;
  WCV    : TWebCrossView;
  V      : array of Variant;
  page   : string;
  Body   : string;
  sPos   : string;
  sType  : string;
  bGet   : Boolean;
  S      : string;
  ErrMsg:string;
begin
  FIDList.Text := IDList;
  if FIDList.Count = 0 then
      Exit;

  ProgressBar1.Min := 1;
  ProgressBar1.Max := FIDList.Count;
  ProgressBar1.Position := 1;
  ProgressBar1.Visible := True;

  IHJXClientFuncs.SessionBegin;
  IHJXClientFuncs.ClearErrMsg;
  errmsg:='';

  WCV := TWebCrossView.Create;

  _SetGrid(WCV);
    // SetLength(V, 16);
  SetLength(V, wcv.ColCount); // 2018-09-18 ���ӡ��������������������

  Body := '<H2>�۲���������ֵ��</H2>';
  try
    for i := 0 to FIDList.Count - 1 do
    begin
      ProgressBar1.Position := i + 1;

      if optLast.Checked then
          bGet := IHJXClientFuncs.GetEVDatas(FIDList.Strings[i], EVDatas)
      else
          bGet := IHJXClientFuncs.GetEVDataInPeriod(FIDList.Strings[i], dtpStart.Date,
          dtpEnd.Date, EVDatas);

      if bGet then
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
          { TODO -ohw -c����ֵ : ��������Ӧ�ÿ�ѡ }
            S := FIDList.Strings[i];
                        // V[0] := Format('<a href="Meter:%s">%s</a>', [S, S]);
            V[0] := FIDList.Strings[i];
            V[1] := Meter.PDDefine[EVDatas[j].PDIndex].Name;
                        // ��Ӹ���
            with EVDatas[j]^ do
            begin
              iCol := 2;
              if chkHistoryEV.Checked then
              begin
                V[iCol] := Lifeev.MaxValue;
                V[iCol + 1] := FormatDateTime('yyyy-mm-dd', Lifeev.MaxDate);
                V[iCol + 2] := Lifeev.MinValue;
                V[iCol + 3] := FormatDateTime('yyyy-mm-dd', Lifeev.MinDate);
                V[iCol + 4] := Lifeev.Increment;
                V[iCol + 5] := Lifeev.Amplitude;
                Inc(iCol, 6);
              end;

              if chkYearEV.Checked then
              begin
                V[iCol] := YearEV.MaxValue;
                V[iCol + 1] := FormatDateTime('yyyy-mm-dd', YearEV.MaxDate);
                V[iCol + 2] := YearEV.MinValue;
                V[iCol + 3] := FormatDateTime('yyyy-mm-dd', YearEV.MinDate);
                V[iCol + 4] := YearEV.Increment;
                V[iCol + 5] := YearEV.Amplitude;
                Inc(iCol, 6);
              end;

              if chkMonthEV.Checked then
              begin
                V[iCol] := MonthEV.MaxValue;
                V[iCol + 1] := FormatDateTime('yyyy-mm-dd', MonthEV.MaxDate);
                V[iCol + 2] := MonthEV.MinValue;
                V[iCol + 3] := FormatDateTime('yyyy-mm-dd', MonthEV.MinDate);
                V[iCol + 4] := MonthEV.Increment;
                V[iCol + 5] := MonthEV.Amplitude;
                Inc(iCol, 6)
              end;

              if chkLastData.Checked then
              begin
                V[iCol] := CurValue;
                V[iCol + 1] := FormatDateTime('yyyy-mm-dd', CurDate);
              end;
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
      IAppServices.ProcessMessages;
    end;
    Body := Body + WCV.CrossGrid;
    page := StringReplace(htmPageCode2, '@PageTitle@', '�۲���������ֵ��', []);
    page := StringReplace(page, '@PageContent@', Body, []);
        // WB_LoadHTML(wbEVPage, WCV.CrossPage);
    FLoadding := True;
    WB_LoadHTML(wbEVPage, page);
    FLoadding := False;
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
    ProgressBar1.Visible := False;

    ErrMsg := IHJXClientFuncs.ErrorMsg;
    if ErrMsg <> '' then showmessage('��ѯ�����з������´���'#13#10 + ErrMsg);
    IHJXClientFuncs.ClearErrMsg;
  end;

end;

end.
