{ -----------------------------------------------------------------------------
  Unit Name: uHJX.Template.ChartTemplatye ( ԭuTLDefineProc��Ԫ)
  Author:    ��ΰ
  Date:      2018-08-30
  Purpose:   Chartģ�嵥Ԫ
  ����ԪԴ��uTLDefineProc��Ԫ����Ҫ�仯��TChartTemplate��̳���uHJX.Classes.Templates��Ԫ��
  ��ThjxTemplate�࣬�ұ���Ԫ�е���Ϊ�����࣬�Ա���ͨ��AppServices���ݸ������
  ��Ҫ����TChartTemplate�����౻GraphDispatcher���Ϲ��������߿���ͨ�����ʸü��ϻ����Ӧ��ģ�塣
  ���󻯵�����TChartTLTemplate, TChartVectorTemplate���ֱ��ǹ�����
  ģ���ʸ��ͼģ�塣��б��ͼ����Ҫ����Chart�����г���ר�ŶԴ���

  ����Ԫ��ģ�����Ľ���û�в���������ʽ����������Ӧ�Ķ���Ƚϼ򵥡���һ��Ӧ��Ϊ
  ������ʽ����ģ�嶨����롣

  History:
  ----------------------------------------------------------------------------- }
{ DONE:��������ģ�嶨���ɡ�Ԥ���塱��Ϊ��ģ�塱����PreDefine���Template }
{ todo:ʹ��������ʽ����Chartģ�� }
unit uHJX.Template.ChartTemplate;

interface

uses
    System.Classes, System.SysUtils, System.Generics.Collections, Vcl.Dialogs,
    uHJX.Classes.Templates;

type
    { ���������� }
    /// <remarks>���������ͣ����ҡ��ס������Զ���</remarks>
    TAXType = (axLeft, axRight, axBottom, axTop, axCustom);

    { SubAxis����ṹ }
    TSubAxis = record
        Title: string;
        Visible: Boolean;
        Format: string;
    end;

    { �����ᶨ�� }
    TchtAxis = class
        Title: string;
        AxisType: TAXType;
        IsVertAxis: Boolean; // �Ƿ�����
        LeftSide: Boolean;   // �Ƿ�����
        BottomSide: Boolean; // �Ƿ��º���
        Index: Integer;
        Format: string;
        // subaxis���ں�������ڵ���ʾ
        SubAxis1: TSubAxis;
        SubAxis2: TSubAxis;
        // ָ��������Chart�����е����ᣬ��Ҫָ��CustomAxis�����Է�������
        // Series.CustomAxis
        ChartAxis: TObject;
    end;

    /// <remarks>ͼ��������Դ�����������������</remarks>
    TPDSource = (pdsMeter, pdsEnv); // ��������Դ�����������������������ܻ�֧���������͵�����Դ
    { Series����, Ŀǰ֧�ֹ����ߣ�ʸ��ͼ��ɢ��ͼ���������ܻ�֧��ͳ��ͼ�� }
    /// <remarks>Series���ͣ�����ͼ(��Ӧ������)����ͷͼ(��Ӧʸ��ͼ��ƽ��λ��ͼ)��ɢ��(��Ӧλ��ͼ��
    /// ��б�ס����ߡ������ߡ�����ˮ׼������׼ֱ��)</remarks>
    TcsType = (csLine, csArrow, csPoints);

    { ģ��Series���� }
    /// <summary>ģ��Series���塣��ͼ����ɸ��ݱ����崴��TeeChart Series�������е�SeriesTypeָ����
    /// Series�����ͣ�SourceType������������Դ����������򻷾�������SourceName������������Ż�
    /// ���������ƣ�PDIndex�������������ĵڼ�����������HoriAxis��VertAxis�����˱�Series�ĺ����
    /// ���ᡣ
    /// </summary>
    TchtSeries = class
    private
        FType      : TcsType;
        FSourceType: TPDSource;
        FSourceName: string;
        FMeterIndex: Integer;
        FPDIndex   : Integer;
        FTitle     : string;
        FHoriAxis  : TchtAxis;
        FVertAxis  : TchtAxis;
        FShowAnno  : Boolean;
    published
        // Series���ͣ�Line��Arrow��Point���ֱ��Ӧ�����ߡ�ʸ��ͼ��ɢ��ͼ
        property SeriesType: TcsType read FType write FType;
        // ����Դ���ͣ������������������
        property SourceType: TPDSource read FSourceType write FSourceType;
        // ���ڼ��������һ��Ϊ*����ȷ����Ʊ�ţ����ڻ�������Ϊ����������
        /// <remarks>���ڼ��������һ��Ϊ*����ȷ����Ʊ�ţ����ڻ�������Ϊ����������</remarks>
        property SourceName: string read FSourceName write FSourceName;

        { MeterIndex = -1,0,1...MAXINT�����У�
          -1Ϊָ����������(��Ʊ��)��0�൱��n��������������������1,2,3...etc��Ϊһ���������ֱ��Ӧ
          ��һ֧���ڶ�ֻ������ֻ�ȵȡ�ʵ��ʹ��ʱ�����ڵ�֧������MeterIndex = 0|1 �Կɣ����������飬
          �����ö�����������ͬ����ÿ��PDǰӦ����<Meter n>����ʱMeterIndex = 0�����߿�ָ��PD��Ӧ��������� }
        /// <summary>MeterIndex = -1,0,1...MAXINT�����У�
        /// -1Ϊָ����������(��Ʊ��)��0�൱��n��������������������1,2,3...etc��Ϊһ���������ֱ��Ӧ
        /// ��һ֧���ڶ�ֻ������ֻ�ȵȡ�ʵ��ʹ��ʱ�����ڵ�֧������MeterIndex = 0|1 �Կɣ����������飬
        /// �����ö�����������ͬ����ÿ��PDǰӦ����"��Meter n��"����ʱMeterIndex = 0�����߿�ָ��PD��Ӧ��������š�
        /// </summary>
        property MeterIndex: Integer read FMeterIndex write FMeterIndex;
        ///<summary>��������ţ���ʼΪ1</summary>
        property PDIndex   : Integer read FPDIndex write FPDIndex;
        // Title�п��ܰ�����Ҫ���滻�����ݣ���%name%�� %MeterName%��
        property Title   : string read FTitle write FTitle;
        property HoriAxis: TchtAxis read FHoriAxis write FHoriAxis;
        property VertAxis: TchtAxis read FVertAxis write FVertAxis;
        property ShowAnno: Boolean read FShowAnno write FShowAnno; // �Ƿ���ʾ���ݵı�ע
    end;

    { Chart�����ͣ������ߣ�ʸ��ͼ��λ��ͼ }
    /// <summary>Chart���ͣ�������ͼ��ʸ��ͼ��λ��ͼ����ʱֻ֧������������Chart</summary>
    /// <remarks>������Chart����Ӧ��Series���ͷֱ�ΪcsLine, csArror, csPoints��</remarks>
    TchtType = (cttTrendLine, cttVector, cttDisplacement);

    { Chartģ����� }
    TChartTemplate = class(ThjxTemplate)
    private
        FTempStr     : string;
        FApplyToGroup: Boolean;
        FChartTitle  : string;
        FChartType   : TchtType;
        FEnvType     : Integer;
        ///<summary>�ڱ������У���Ҫ���ñ���������ᡣSeries�����õ���SetSeries����ʵ�֡�
        ///</summary>
        procedure SetDefine(Entry, ParamStr: string);
        procedure SetSeries(Entry, ParamStr: string);

    public
        // EnvType: Integer; // ���������ͣ��¶ȣ�ˮλ��������û�뵽��
        // �������ᣬ�����ж�����ᣬ�����Զ�����
        HoriAxises: TDictionary<string, TchtAxis>;
        // ���ᣬ���������ᣬ�����Զ�������
        VertAxises: TDictionary<string, TchtAxis>;
        // ģ���ж����ͼ������
        Series: TList<TchtSeries>;

        constructor Create; override;
        destructor Destroy; override;
        procedure Clear;
        /// <summary>����������ģ����룬�ֽ�Ϊ�ɹ������Ķ���͸�������</summary>
        /// <param name="tmpStr">ģ������ַ���</param>
        /// <remarks>Ŀǰֻ����˹�����ģ��ĸ�ʽ���﷨����û�п���ʸ��ͼ��λ��ͼ���﷨�͸�ʽ��
        /// ����в���ȷ������ȷ�������������͵�ģ��</remarks>
        procedure SetTemplate(tmpStr: string); virtual;

        { ģ�����ﲻ�ṩ���������������Ǹ��Ի��ģ��ɻ�ͼ����ṩ����ע�ᵽ�������С�ģ ��ֻ�ṩ
          ���屾���ÿ����Ĺ鿭�����ϵ۵Ĺ��ϵ۰ɡ� }
        // procedure Draw(ADesignName: string; AChart: TObject); virtual; abstract;
    published
        // Chart���ͣ������ߣ�ʸ��ͼ��ɢ��ͼ����б�������ߡ����ߵȣ�
        property ChartType : TchtType read FChartType write FChartType;
        property ChartTitle: string read FChartTitle;
        // ģ�嶨�������
        /// <summary>ģ�����<see cref="procedure SetTemplate"/></summary>
        property TemplateStr: string read FTempStr write SetTemplate;
        // ģ�����֧���飬������Ӧ������Ҳ�����飬�������Chart������ֻ�ܻ��Ƶ�֧����������ͼ��
        /// <summary>ģ���Ƿ�֧�������飿���ģ��֧�������飬�Ҹ�������Ҳ����ĳ���飬����Ƹ���
        /// ͼ�Σ���������֧�����������һֻ�����������������塣
        /// </summary> array[0..10] of Integer = ();
        property ApplyToGroup: Boolean read FApplyToGroup;
        /// <summary>����������</summary>
        property EnvType: Integer read FEnvType write FEnvType;
    end;

{ TLPreDefines�Ѿ���HJXTemplates��������߽���ΪAppServices�����Թ�����ģ����á�
var
    TLPreDefines: TDictionary<string, TChartTemplate>;
}
implementation

constructor TChartTemplate.Create;
begin
    inherited;
    VertAxises := TDictionary<string, TchtAxis>.Create;
    HoriAxises := TDictionary<string, TchtAxis>.Create;
    Series := TList<TchtSeries>.Create;
    FApplyToGroup := False;
    Self.Category := tplChart;
end;

destructor TChartTemplate.Destroy;
var
    ax: TchtAxis;
    ss: TchtSeries;
begin
    for ax in VertAxises.Values do ax.Free;
    for ax in HoriAxises.Values do ax.Free;
    VertAxises.Free;
    HoriAxises.Free;
    for ss in Series do ss.Free;
    Series.Free;
    inherited;
end;

procedure TChartTemplate.Clear;
var
    ax: TchtAxis;
    ss: TchtSeries;
begin
    for ax in VertAxises.Values do ax.Free;
    for ax in HoriAxises.Values do ax.Free;
    for ss in Series do ss.Free;
    VertAxises.Clear;
    HoriAxises.Clear;
    Series.Clear;
end;

procedure TChartTemplate.SetTemplate(tmpStr: string);
var
    S : string;
    SA: TArray<string>;
    i : Integer;
    /// <summary>proc every line</summary>
    procedure _DecodeLine(sLine: string);
    var
        sEntry: string;
        sParam: string;
        ii    : Integer;
    begin
        ii := Pos(':', sLine);
        if ii > 0 then
        begin
            sEntry := Trim(Copy(sLine, 0, ii - 1));
            sParam := Trim(Copy(sLine, ii + 1, Length(sLine) - ii));
            SetDefine(sEntry, sParam);
        end;
    end;

begin
    FTempStr := tmpStr;
    Clear;
    S := Trim(FTempStr);
    S := StringReplace(S, #13, '', [rfReplaceAll]);
    S := StringReplace(S, #10, '', [rfReplaceAll]);
    SA := S.Split([';']);
    try
        for i := low(SA) to high(SA) do
        begin
            S := SA[i].Trim;
            if S = '' then Continue;
            _DecodeLine(S);
        end;
    finally
        SetLength(SA, 0);
    end;
end;

procedure TChartTemplate.SetDefine(Entry: string; ParamStr: string);
var
    Params : TArray<string>;
    S      : string;
    i      : Integer;
    NewAxis: TchtAxis;
begin
    if SameText(Entry, 'ChartTitle') then FChartTitle := ParamStr
    else if SameText(Entry, 'ChartType') then
    begin
        if ParamStr = '������' then Self.FChartType := cttTrendLine
        else if ParamStr = 'ʸ��ͼ' then FChartType := cttVector
        else if ParamStr = 'λ��ͼ' then FChartType := cttDisplacement;
    end
    else if SameText(Entry, 'Metertype') then MeterType := ParamStr
    else if SameText(Entry, 'Axis') then
    begin
        Params := ParamStr.Split(['|']);
        for i := low(Params) to high(Params) do Params[i] := Trim(Params[i]);

        { �ݲ�֧�ֺ����CustomAxis��ֻ���������CustomAxis }
        if (SameText(Params[0], 'Bottom') or SameText(Params[0], 'Top')) then
        begin
            NewAxis := TchtAxis.Create;
            NewAxis.IsVertAxis := False;
            NewAxis.LeftSide := False;
            if SameText(Params[0], 'Bottom') then
            begin
                NewAxis.BottomSide := True;
                NewAxis.AxisType := axBottom;
            end
            else
            begin
                NewAxis.BottomSide := False;
                NewAxis.AxisType := axTop;
            end;

            NewAxis.Title := Params[2];
            NewAxis.Format := Params[3];

            HoriAxises.Add(Params[0], NewAxis);

            { Self.HoriAxis.Title := Params[2];
            HoriAxis.AxisType := axBottom;
            HoriAxis.IsVertAxis := False;
            HoriAxis.Format := Params[3]; }
            // �ٶ�����þ������SubAxis���ˡ������SubAxis����BottomAxis.Title=''��TitleӦ��������
            // ���·���SubAxis�ϡ�
            if high(Params) >= 4 then
            begin
                NewAxis.SubAxis1.Visible := True;
            // ����Ӧ���ֽ�Params[4]��ȡ��Format���á���ǰ��ʱ��֧��SubAxis��title������
                i := Pos(':', Params[4]);
                if i > 0 then
                        NewAxis.SubAxis1.Format := Copy(Params[4], i + 1, Length(Params[4]) - i);
            end;

            if high(Params) >= 5 then
            begin
                NewAxis.SubAxis2.Visible := True;
                i := Pos(':', Params[5]);
                if i > 0 then
                        NewAxis.SubAxis2.Format := Copy(Params[5], i + 1, Length(Params[5]) - i);
            end
        end
        else
        begin
            NewAxis := TchtAxis.Create;
            NewAxis.IsVertAxis := True;
            NewAxis.LeftSide := False;

            if SameText(Params[0], 'Left') then
            begin
                NewAxis.AxisType := axLeft;
                NewAxis.LeftSide := True;
            end
            else NewAxis.AxisType := axRight;
            NewAxis.Title := Params[2];
            NewAxis.Format := Params[3];
            // �ж��Ƿ���CustomAxis
            i := StrToInt(Params[1]);
            if i <> 0 then NewAxis.AxisType := axCustom;
            // ��������������ӵ�VerAxis�ֵ伯����
            S := UpperCase(Params[0]) + 'AXIS[' + IntToStr(i) + ']';
            VertAxises.Add(S, NewAxis);
        end;
    end
    else if Pos('PD', Entry) > 0 then SetSeries(Entry, ParamStr);

end;

{ Ŀǰ�������ֻ�����˹��������ͣ�û�п���ʸ��ͼ��λ��ͼ���� }
{ todo:����ʸ��ͼģ��(ƽ��λ�Ʋ��)�Ľ��� }
{ todo:����λ��ͼģ��(�����ߡ����ߡ�����ˮ׼������)�Ľ��� }
procedure TChartTemplate.SetSeries(Entry: string; ParamStr: string);
var
    S, sn    : string;
    Params   : TArray<string>;
    i        : Integer;
    NewSeries: TchtSeries;
    pds      : TPDSource;
    function GetMeterSet: string;
    var
        ii, jj: Integer;
        ss    : string;
        mst   : TArray<string>;
    begin
        Result := '';
        ii := Pos('<', Entry);
        jj := Pos('>', Entry);
        { û��<Meter>�˵����������Ӧ��������������ֵΪn, ��* }
        if (ii = 0) and (jj = 0) then
        begin
            Result := '1'; // ��û��<Meter X>��ʱ��Ĭ�ϵ���<Meter 1>
            pds := pdsMeter;
            sn := '*';
            FApplyToGroup := False;
            Exit;
        end;
        { �����жϣ�������������������Meter���� }
        if ((ii = 0) and (jj <> 0)) or ((ii <> 0) and (jj = 0)) or (ii > jj) or (jj = ii + 1) then
        begin
            Result := '1';
            pds := pdsMeter;
            sn := '*';
            FApplyToGroup := False;
            Exit;
        end;

        // �������:Meter 1/2/3..., Meter n���ݲ�֧��ָ��������š��������ȸ����������һ����˵
        ss := Copy(Entry, ii + 1, jj - ii - 1);
        mst := ss.Split([' ']);
        for ii := low(mst) to high(mst) do mst[ii] := Trim(mst[ii]);

        if Length(mst) >= 2 then
        begin
            // ��һ��Ӧ��ΪMeter or Env
            if SameText(mst[0], 'Meter') then pds := pdsMeter
            else if SameText(mst[0], 'Env') then pds := pdsEnv
            else
            begin
                Result := 'UNKNOWN';
                Exit;
            end;

            // �ڶ���Ӧ��Ϊ���֡���ĸ��n������*������������š��򻷾�������
            if (mst[1] = 'n') then
            begin
                Result := '0'; // mst[1]; MeterIndex = 0�൱��n��������������Ч
                sn := '*';     // sn��SourceName�*��ʾ�κ�����
                FApplyToGroup := True;
            end
            else if TryStrToInt(mst[1], ii) then
            begin
                Result := mst[1];
                sn := '*';
                if ii > 1 then FApplyToGroup := True
                else FApplyToGroup := False;
            end
            else // �Ȳ���n��Ҳ�������֣��Ǿ���������Ż��߻���������
            begin
                Result := '-1'; // -1��ʾָ�����Ƶ�����
                sn := mst[1];   // ��ʱ��mst[1]Ӧ���������򻷾���������
                FApplyToGroup := False;
            end;
        end;
        SetLength(mst, 0);
    end;

begin
    S := GetMeterSet;
    if S = 'UNKNOWN' then Exit;

    NewSeries := TchtSeries.Create;
    { check Meter setting }
    NewSeries.MeterIndex := StrToInt(S);
    NewSeries.SourceType := pds;
    NewSeries.SourceName := sn;
    { ����Chart��������Series���ͣ��ݲ�֧�ֻ������ }
    if FChartType = cttVector then NewSeries.FType := csArrow
    else if FChartType = cttDisplacement then NewSeries.FType := csPoints
    else NewSeries.FType := csLine;

    Params := ParamStr.Split(['|']);
    i := StrToInt(Params[0]);
    NewSeries.PDIndex := i;
    NewSeries.Title := Params[1];
    if VertAxises.ContainsKey(UpperCase(Params[2])) then
    begin
        NewSeries.VertAxis := VertAxises.Items[UpperCase(Params[2])];
        Series.Add(NewSeries);
    end
    else
    begin
        ShowMessage(Format('������"%s"δ���壬�޷����ƹ�����"%s:%s"', [Params[2], Entry, ParamStr]));
        NewSeries.Free;
    end;

end;

{
procedure ReleaseDefines;
var
    t: TChartTemplate;
begin
    for t in TLPreDefines.Values do t.Free;
    TLPreDefines.Clear;
    TLPreDefines.Free;
end;

initialization

TLPreDefines := TDictionary<string, TChartTemplate>.Create;

finalization

ReleaseDefines; }

end.
