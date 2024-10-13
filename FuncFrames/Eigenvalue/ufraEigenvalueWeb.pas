{ -----------------------------------------------------------------------------
  Unit Name: ufraEigenvalueWeb
  Author:    ��ΰ
  Date:      14-����-2017
  Purpose:   ����Ԫ�����ݿ�/������ȡ�����������ֵ���ݣ���HTML�����ʽ��ʾ��
  Ƕ���IE������У��û��ɿ���ճ������������С�
  History:
    2018-06-14  �޸��˱���ʽ�������̲�λ����˱��
    2018-09-18  �����˲�ѯʱ���������ֵ�Ĺ��ܣ������ˡ��������͡���������
    2022-10-25  �����������û�ѡ������ֵ��Ĺ��ܣ���ѡ��������У���ѡ3��ʽ��ͷ
  ----------------------------------------------------------------------------- }
{ done:������÷ֱ���ʽ��ʾ����ֵ���ݣ��ɰ���װ��λ���з���ֱ� }
{ done:�����û�ѡ�������ݣ����ѡ�Ƿ���������������������ǰֵ������������ȵȡ�
��Ȼ��ѯ����Ƿ���ȫ�����ݣ����Ǳ�ʾ��ʱ��������ѡ����������һ���޴��񣬻����ٱ༭ }
{ done:�ṩEhGrid��ʾ������ֵ�����������������������ڷ�����������Ƿǳ����õ� }
{ todo:����ѡ��������ĳ�����ݽ�������ֵ��ѯ������ֽ�ƿ���ֻ��Ӧ����������ÿ�ζ�Ҫ�����¶ȣ�
       ���»���ɾ���¶��� }
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
    grpDataSelect: TGroupBox;
    chkMinData: TCheckBox;
    chkIncData: TCheckBox;
    chkAmplitude: TCheckBox;
    GroupBox2: TGroupBox;
    chkSeqNum: TCheckBox;
    chk3TitleRows: TCheckBox;
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
  CN, ii : Integer; // ÿ������ֵ�������
  procedure __SetRow1;
  var
    iiCol: Integer;
  begin
    if chkSeqNum.Checked then
    begin
      V[0] := '���';
      V[1] := '��Ʊ��';
      V[2] := '������';
      i := 3;
    end
    else
    begin
      // V[0] := '��װ��λ';
      // V[1] := '��������';
      V[0] := '��Ʊ��';
      V[1] := '������';
      i := 2;
    end;
    if chkHistoryEV.Checked then
    begin
      for iiCol := i to i + CN - 1 do V[iiCol] := '��ʷ����ֵ';
      Inc(i, CN);
    end;

    if chkYearEV.Checked then
    begin
      for iiCol := i to i + CN - 1 do V[iiCol] := '������ֵ';
      Inc(i, CN);
    end;

    if chkMonthEV.Checked then
    begin
      for iiCol := i to i + CN - 1 do V[iiCol] := '������ֵ';
      Inc(i, CN);
    end;

    if chkLastData.Checked then
    begin
      for iiCol := i to i + 1 do V[iiCol] := '��ǰֵ';
      Inc(i, 2);
    end;
  end;
  // ��������ĳһ��ĸ��У�����ʷ����ֵ��������ֵ��������ֵɶ��
  // ATitle��ֵΪ���ꡱ���¡�����ʷ��ɶ��
  procedure __SetACols(ATitleRow: Integer);
  begin
    ii := 2;
    if chk3TitleRows.Checked then
    begin
      if ATitleRow = 3 then
      begin
        V[i] := '����';
        V[i + 1] := '��ֵ';
      end
      else
      begin
        V[i] := '���ֵ';
        V[i + 1] := '���ֵ';
      end;
    end
    else
    begin
      V[i + 1] := '���ֵ';
      V[i] := '���ֵ����';
    end;

    if chkMinData.Checked then
    begin
      if chk3TitleRows.Checked then
      begin
        if ATitleRow = 3 then
        begin
          V[i + ii] := '����';
          V[i + ii + 1] := '��ֵ';
        end
        else
        begin
          V[i + ii] := '��Сֵ';
          V[i + ii + 1] := '��Сֵ';
        end;
      end
      else
      begin
        V[i + ii + 1] := '��Сֵ';
        V[i + ii] := '��Сֵ����';
      end;
      Inc(ii, 2);
    end;

    if chkIncData.Checked then
    begin
      V[i + ii] := '����';
      Inc(ii);
    end;

    if chkAmplitude.Checked then
    begin
      V[i + ii] := '���';
      Inc(ii);
    end;
    Inc(i, ii);
  end;

  procedure __SetRow2;
  begin
    if chkSeqNum.Checked then
    begin
      V[0] := '���';
      V[1] := '��Ʊ��';
      V[2] := '������';
      i := 3;
    end
    else
    begin
      // V[0] := '��װ��λ';
      // V[1] := '��������';
      V[0] := '��Ʊ��';
      V[1] := '������';
      i := 2;
    end;

    if chkHistoryEV.Checked then
    begin
      __SetACols(2); // ��ʷ����ֵ
    end;

    if chkYearEV.Checked then
    begin
      __SetACols(2);
    end;

    if chkMonthEV.Checked then
    begin
      __SetACols(2);
    end;

    if chkLastData.Checked then
    begin
      if chk3TitleRows.Checked then
      begin
        V[i] := '��ǰֵ';
        V[i + 1] := '��ǰֵ';
      end
      else
      begin
        V[i] := '����';
        V[i + 1] := '��ֵ';
      end;
      Inc(i, 2);
    end;
  end;

  procedure __SetRow3;
  begin
    if chkSeqNum.Checked then
    begin
      V[0] := '���';
      V[1] := '��Ʊ��';
      V[2] := '������';
      i := 3;
    end
    else
    begin
      // V[0] := '��װ��λ';
      // V[1] := '��������';
      V[0] := '��Ʊ��';
      V[1] := '������';
      i := 2;
    end;

    if chkHistoryEV.Checked then
    begin
      __SetACols(3); // ��ʷ����ֵ
    end;

    if chkYearEV.Checked then
    begin
      __SetACols(3);
    end;

    if chkMonthEV.Checked then
    begin
      __SetACols(3);
    end;

    if chkLastData.Checked then
    begin
      V[i] := '����';
      V[i + 1] := '��ֵ';
      Inc(i, 2);
    end;

  end;

begin
    // SetLength(V, 15);
  CN := 2;                                 // �ض��������ֵ������
  if chkMinData.Checked then Inc(CN, 2);   // ���������Сֵ���������
  if chkIncData.Checked then Inc(CN, 1);   // �������������������1��
  if chkAmplitude.Checked then Inc(CN, 1); // ������������������1��
  // if chkSeqNum.Checked then Inc(CN, 1);    // ���������ţ�������1��

// ���б���
  if ARow = 1 then
  begin
    __SetRow1;
  end
  else if ARow = 2 then // �ڶ��б���
  begin
    __SetRow2;
  end
  else if ARow = 3 then // ֻ��ѡ����3�б���ģʽ�Ż��е���������
      __SetRow3;
end;

procedure TfraEigenvalueWeb._SetGrid(AW: TWebCrossView);
var
  V : array of Variant;
  i : Integer;
  CC: Integer; // ColCount
  CN: Integer; // ColNumber per EVItem
  S : String;
begin
  if chk3TitleRows.Checked then
      AW.TitleRows := 3
  else
      AW.TitleRows := 2;
  // 2022-09-09 �����û�ѡ���������ȷ��ÿ������ֵ��ӵ�м���
  CN := 2;                                 // �������ֵ��
  if chkMinData.Checked then Inc(CN, 2);   // ���������Сֵ���������
  if chkIncData.Checked then Inc(CN, 1);   // �������������������1��
  if chkAmplitude.Checked then Inc(CN, 1); // ������������������1��

  CC := 2; // ��������ͷ������Ʊ�ź�����������2020-10-10
  // 2020-10-10 ���´�������û�ѡ��Ĳ�ѯ����������
  if chkSeqNum.Checked then Inc(CC, 1); // ���������ţ�����1��
  if chkHistoryEV.Checked then Inc(CC, CN { 6 } );
  if chkYearEV.Checked then Inc(CC, CN { 6 } );
  if chkMonthEV.Checked then Inc(CC, CN { 6 } );
  if chkLastData.Checked then Inc(CC, 2);

  // AW.ColCount := { 16 } 22; // 2018-09-18 ���������������
  AW.ColCount := CC;
  AW.ColHeader[0].AllowColSpan := True;
  if chk3TitleRows.Checked then AW.ColHeader[1].AllowColSpan := True;

  { todo:�����_GetTitleRowStr�������ñ�ͷ�ķ���̫���ˣ��ο�ufraEigenvalueGrid�����ñ�ͷ�ķ��� }
  SetLength(V, CC);
  // ���ñ�ͷ����
  _GetTitleRowStr(1, V);
  AW.AddRow(V);
  // ���ñ�ͷ�ڶ���
  _GetTitleRowStr(2, V);
  AW.AddRow(V);
  // �����3��ģʽ�����ñ�ͷ������
  if chk3TitleRows.Checked then
  begin
    _GetTitleRowStr(3, V);
    AW.AddRow(V);
  end;

  for i := 0 to CC - 1 do
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

{ -----------------------------------------------------------------------------
  Procedure  : GetEVDatas
  Description: ��������ֵ����HTML����
  2022-09-09 ������ֵ����������Ϊ�����������͵ķֱ����ڿ�����Ҳ���ڽ���
  ����ض����������ض�����
----------------------------------------------------------------------------- }
procedure TfraEigenvalueWeb.GetEVDatas(IDList: string);
var
  i, j   : Integer; // ѭ����
  iCol   : Integer;
  ii     : Integer; // ����ֵ�����������к�
  iSeq   : Integer; // �������
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
  ErrMsg : string;

  // �����û�ѡ���������Ŀ��д���ݣ���������һ�е��к�
  procedure PutEVDatas(EVD: TEVDataEntry);
  begin
    ii := 2;
    if chkHistoryEV.Checked then
    begin
      V[iCol + 1] := EVD.MaxValue;
      V[iCol] := FormatDateTime('yyyy-mm-dd', EVD.MaxDate);
      if chkMinData.Checked then
      begin
        V[iCol + ii + 1] := EVD.MinValue;
        V[iCol + ii] := FormatDateTime('yyyy-mm-dd', EVD.MinDate);
        Inc(ii, 2);
      end;

      if chkIncData.Checked then
      begin
        V[iCol + ii] := EVD.Increment;
        Inc(ii);
      end;

      if chkAmplitude.Checked then
      begin
        V[iCol + ii] := EVD.Amplitude;
        Inc(ii);
      end;
      Inc(iCol, ii);
    end;
  end;

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
  ErrMsg := '';

  WCV := TWebCrossView.Create;

  _SetGrid(WCV);
    // SetLength(V, 16);
  SetLength(V, WCV.ColCount); // 2018-09-18 ���ӡ��������������������

  Body := '<H2>�۲���������ֵ��</H2>';
  try
    sPos := '';
    sType := '';
    iSeq := 1;
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
          Body := Body + '<h4>' + sType + '</h4>';
          // WCV.AddCaptionRow([sType]); ��Ϊÿ�����͵����ɱ�
        end
        else
        begin
          if Meter.PrjParams.Position <> sPos then
          begin
            sPos := Meter.PrjParams.Position;
            sType := Meter.Params.MeterType;
            Body := Body + WCV.CrossGrid;
            Body := Body + '<h3>' + sPos + '�������</h3>';
            Body := Body + '<h4>' + sType + '</h4>';
            WCV.Reset;
            _SetGrid(WCV);
            // WCV.AddCaptionRow([sType]);
            iseq:= 1;
          end;
        end;

        if Meter.Params.MeterType <> sType then
        begin
          Body := Body + WCV.CrossGrid;
          sType := Meter.Params.MeterType;
          Body := Body + '<h4>' + sType + '</h4>';
          WCV.Reset;
          _SetGrid(WCV);
          // WCV.AddCaptionRow([sType]);
          iSeq := 1;
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
            if chkSeqNum.Checked then
            begin
              V[0] := iSeq;
              V[1] := FIDList.Strings[i];
              V[2] := Meter.PDDefine[EVDatas[j].PDIndex].Name;
              iCol := 3;
            end
            else
            begin
              V[0] := FIDList.Strings[i];
              V[1] := Meter.PDDefine[EVDatas[j].PDIndex].Name;
              iCol := 2;
            end;
                        // ��Ӹ���
            with EVDatas[j]^ do
            begin
              // iCol := 2;
              ii := 2;
              PutEVDatas(LifeEV);
(*
                if chkHistoryEV.Checked then
                begin
                  V[iCol] := Lifeev.MaxValue;
                  V[iCol + 1] := FormatDateTime('yyyy-mm-dd', Lifeev.MaxDate);
                  if chkMinData.Checked then
                  begin
                    V[iCol + ii] := Lifeev.MinValue;
                    V[iCol + ii + 1] := FormatDateTime('yyyy-mm-dd', Lifeev.MinDate);
                    Inc(ii, 2);
                  end;

                  if chkIncData.Checked then
                  begin
                    V[iCol + ii] := Lifeev.Increment;
                    Inc(ii);
                  end;

                  if chkAmplitude.Checked then
                  begin
                    V[iCol + ii] := Lifeev.Amplitude;
                    Inc(ii);
                  end;
                  Inc(iCol, ii);
                end;

*)
              if chkYearEV.Checked then
              begin
                PutEVDatas(yearev);
(*
                  V[iCol] := YearEV.MaxValue;
                  V[iCol + 1] := FormatDateTime('yyyy-mm-dd', YearEV.MaxDate);
                  V[iCol + 2] := YearEV.MinValue;
                  V[iCol + 3] := FormatDateTime('yyyy-mm-dd', YearEV.MinDate);
                  V[iCol + 4] := YearEV.Increment;
                  V[iCol + 5] := YearEV.Amplitude;
                  Inc(iCol, 6);

*)
              end;

              if chkMonthEV.Checked then
              begin
                PutEVDatas(MonthEV);
(*
                  V[iCol] := MonthEV.MaxValue;
                  V[iCol + 1] := FormatDateTime('yyyy-mm-dd', MonthEV.MaxDate);
                  V[iCol + 2] := MonthEV.MinValue;
                  V[iCol + 3] := FormatDateTime('yyyy-mm-dd', MonthEV.MinDate);
                  V[iCol + 4] := MonthEV.Increment;
                  V[iCol + 5] := MonthEV.Amplitude;
                  Inc(iCol, 6)

*)
              end;

              if chkLastData.Checked then
              begin
                V[iCol + 1] := CurValue;
                V[iCol] := FormatDateTime('yyyy-mm-dd', CurDate);
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
      Inc(iSeq); // ����һֻ������
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
    if ErrMsg <> '' then ShowMessage('��ѯ�����з������´���'#13#10 + ErrMsg);
    IHJXClientFuncs.SessionEnd;
    IHJXClientFuncs.ClearErrMsg;
  end;

end;

end.
