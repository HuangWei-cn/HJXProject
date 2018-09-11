{ -----------------------------------------------------------------------------
 Unit Name: uTLDefineProc
 Author:    ��ΰ
 Date:      25-����-2018
 Purpose:   ������Ԥ���崦��Ԫ
            ʵ���ϣ�����Ԫ�ġ�Ԥ���塱��ʵҲ���Ա���Ϊ��Style��Template��������
            �в�����ȷ��������ʱ��Template��ָ���˾��������ʱ����Ԥ����Ĺ�
            ���ߡ�
            ��ǰ��ƽ�Ӧ����ʱ�����ߣ�û�п��ǵ�ʸ��ͼ��ɢ��ͼ(��б����)�ȣ���
            û�к�GraphDispatcher��ϣ�����ģ���uHJX.Excel.InitParams��Ԫ��Ҫ
            ֱ�����ñ���Ԫ����Щ����Ҫ�ں�����һ�Ľ������ơ�
 History:
----------------------------------------------------------------------------- }
{ todo:��������ģ�嶨���ɡ�Ԥ���塱��Ϊ��ģ�塱����PreDefine���Template }
{ todo:����ģ�����÷�Χ���壬���籾��Ԫ�Ķ���������ڹ����� }
{ todo:�޸��ඨ�壬���ӳ���������Ӧ��������Chartģ�� }
unit uTLDefineProc;

interface

uses
    System.Classes, System.SysUtils, System.Generics.Collections, Vcl.Dialogs;

type
    TAXType = (axLeft, axRight, axBottom, axCustom);

    { SubAxis����ṹ }
    TSubAxis = record
        Title: string;
        Visible: Boolean;
        Format: String;
    end;

    { �����ᶨ�� }
    TTLAxis = class
        Title: string;
        AxisType: TAXType;
        IsVertAxis: Boolean;
        LeftSide: Boolean;
        Index: Integer;
        Format: string;
        // subaxis���ں�������ڵ���ʾ
        SubAxis1: TSubAxis;
        SubAxis2: TSubAxis;
        ChartAxis: TObject; // ָ��������Chart�����е����ᣬ��Ҫָ��CustomAxis�����Է�������Series.CustomAxis
    end;

    { �����߶��� }
    TPDSource = (pdsMeter, pdsEnv); // ��������Դ��������������

    TTLSeries = class
    protected
    public
        SourceType: TPDSource;
        SourceName: string; // ���ڼ��������һ��Ϊ*����ȷ����Ʊ�ţ����ڻ�������Ϊ����������
        // MeterIndex: string; // ������String���ͣ�ֵ���������֣�Ҳ�������ַ�n�����ڵ�֧���������ܲ������������

        { MeterIndex = -1,0,1...MAXINT�����У�
        -1Ϊָ����������(��Ʊ��)��0�൱��n��������������������1,2,3...etc��Ϊһ���������ֱ��Ӧ
        ��һ֧���ڶ�ֻ������ֻ�ȵȡ�ʵ��ʹ��ʱ�����ڵ�֧������MeterIndex = 0|1 �Կɣ����������飬
        �����ö�����������ͬ����ÿ��PDǰӦ����<Meter n>����ʱMeterIndex = 0�����߿�ָ��PD��Ӧ��������� }
        MeterIndex: Integer;
        PDIndex   : Integer;
        Title     : String; // Title�п��ܰ�����Ҫ���滻�����ݣ���%name%�� %MeterName%��
        VertAxis  : TTLAxis;
        ShowAnno  : Boolean; // �Ƿ���ʾ���ݵı�ע
    end;

    { ������Ԥ������� }
    TTrendlinePreDefine = class
    private
        procedure SetDefine(Entry, ParamStr: string);
        procedure SetSeries(Entry, ParamStr: string);
        procedure Clear;
    public
        Name        : string;
        ChartTitle  : string;
        HoriAxis    : TTLAxis;
        VertAxis    : TDictionary<string, TTLAxis>;
        Series      : TList<TTLSeries>;
        ApplyToGroup: Boolean;
        DefineStr   : string;
        constructor Create;
        destructor Destroy; override;
        { ����Ԥ���壬���ɸ������� }
        procedure DecodeDefine(DefStr: string);
    end;

var
    TLPreDefines: TDictionary<string, TTrendlinePreDefine>;

implementation

constructor TTrendlinePreDefine.Create;
begin
    inherited;
    VertAxis := TDictionary<string, TTLAxis>.Create;
    HoriAxis := TTLAxis.Create;
    Series := TList<TTLSeries>.Create;
    ApplyToGroup := False;
end;

destructor TTrendlinePreDefine.Destroy;
var
    axis: TTLAxis;
    ss  : TTLSeries;
begin
    for axis in VertAxis.Values do
        axis.Free;
    for ss in Series do
        ss.Free;

    VertAxis.Clear;
    VertAxis.Free;
    Series.Clear;
    Series.Free;
    HoriAxis.Free;
end;

procedure TTrendlinePreDefine.Clear;
var
    ax: TTLAxis;
    ss: TTLSeries;
begin
    name := '';
    ChartTitle := '';
    ApplyToGroup := False;

    HoriAxis.Title := '';
    HoriAxis.AxisType := axBottom;
    HoriAxis.IsVertAxis := False;
    HoriAxis.Index := 0;
    HoriAxis.Format := 'yyyy-mm-dd';
    HoriAxis.ChartAxis := nil;
    HoriAxis.SubAxis1.Visible := False;
    HoriAxis.SubAxis2.Visible := False;
    for ax in VertAxis.Values do
        ax.Free;
    VertAxis.Clear;
    for ss in Series do
        ss.Free;
    Series.Clear;
end;

procedure TTrendlinePreDefine.DecodeDefine(DefStr: string);
var
    S : string;
    SA: TArray<string>;
    i : Integer;
    procedure DecodeLine(sLine: string);
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
    DefineStr := DefStr; // �����屣���������Ա�����
    // �ڽ���֮ǰ�����������ԭ���ã����ǵ��û�������ʹ�ù������ֶ��޸Ķ��壬�Ե�����������ʽ��Ч������
    Clear;

    // ���ȣ�ȥ�����ֻس����У��Լ�ǰ��ո�
    S := Trim(DefStr);
    S := StringReplace(S, #13, '', [rfReplaceAll]);
    S := StringReplace(S, #10, '', [rfReplaceAll]);
    SA := S.Split([';']);
    try
        for i := Low(SA) to High(SA) do
        begin
            S := SA[i].Trim;
            if S = '' then
                Continue;
            DecodeLine(S);
        end;
    finally
        SetLength(SA, 0);
    end;
end;

procedure TTrendlinePreDefine.SetDefine(Entry: string; ParamStr: string);
var
    Params : TArray<string>;
    S      : string;
    i      : Integer;
    NewAxis: TTLAxis;
begin
    if SameText(Entry, 'ChartTitle') then
        Self.ChartTitle := ParamStr
    else if SameText(Entry, 'Axis') then
    begin
        Params := ParamStr.Split(['|']);
        for i := Low(Params) to High(Params) do
            Params[i] := Trim(Params[i]);

        if SameText(Params[0], 'Bottom') then
        begin
            Self.HoriAxis.Title := Params[2];
            HoriAxis.AxisType := axBottom;
            HoriAxis.IsVertAxis := False;
            HoriAxis.Format := Params[3];
            // �ٶ�����þ������SubAxis���ˡ������SubAxis����BottomAxis.Title=''��TitleӦ��������
            // ���·���SubAxis�ϡ�
            if High(Params) >= 4 then
            begin
                HoriAxis.SubAxis1.Visible := True;
                // ����Ӧ���ֽ�Params[4]��ȡ��Format���á���ǰ��ʱ��֧��SubAxis��title������
                i := Pos(':', Params[4]);
                if i > 0 then
                    HoriAxis.SubAxis1.Format := Copy(Params[4], i + 1, Length(Params[4]) - i);
            end;

            if High(Params) >= 5 then
            begin
                HoriAxis.SubAxis2.Visible := True;
                i := Pos(':', Params[5]);
                if i > 0 then
                    HoriAxis.SubAxis2.Format := Copy(Params[5], i + 1, Length(Params[5]) - i);
            end
        end
        else
        begin
            NewAxis := TTLAxis.Create;
            NewAxis.IsVertAxis := True;
            NewAxis.LeftSide := False;

            if SameText(Params[0], 'Left') then
            begin
                NewAxis.AxisType := axLeft;
                NewAxis.LeftSide := True;
            end
            else
                NewAxis.AxisType := axRight;
            NewAxis.Title := Params[2];
            NewAxis.Format := Params[3];
            // �ж��Ƿ���CustomAxis
            i := StrToInt(Params[1]);
            if i <> 0 then
                NewAxis.AxisType := axCustom;
            // ��������������ӵ�VerAxis�ֵ伯����
            S := UpperCase(Params[0]) + 'AXIS[' + IntToStr(i) + ']';
            VertAxis.Add(S, NewAxis);
        end;
    end
    else if Pos('PD', Entry) > 0 then
        SetSeries(Entry, ParamStr);
end;

procedure TTrendlinePreDefine.SetSeries(Entry: string; ParamStr: string);
var
    S, sn    : string;
    Params   : TArray<string>;
    i        : Integer;
    NewSeries: TTLSeries;
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
            ApplyToGroup := False;
            Exit;
        end;
        { �����жϣ�������������������Meter���� }
        if ((ii = 0) and (jj <> 0)) or ((ii <> 0) and (jj = 0)) or (ii > jj) or (jj = ii + 1) then
        begin
            Result := '1';
            pds := pdsMeter;
            sn := '*';
            ApplyToGroup := False;
            Exit;
        end;

        // �������:Meter 1/2/3..., Meter n���ݲ�֧��ָ��������š��������ȸ����������һ����˵
        ss := Copy(Entry, ii + 1, jj - ii - 1);
        mst := ss.Split([' ']);
        for ii := Low(mst) to High(mst) do
            mst[ii] := Trim(mst[ii]);

        if Length(mst) >= 2 then
        begin
            // ��һ��Ӧ��ΪMeter or Env
            if SameText(mst[0], 'Meter') then
                pds := pdsMeter
            else if SameText(mst[0], 'Env') then
                pds := pdsEnv
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
                ApplyToGroup := True;
            end
            else if TryStrToInt(mst[1], ii) then
            begin
                Result := mst[1];
                sn := '*';
                if ii > 1 then
                    ApplyToGroup := True
                else
                    ApplyToGroup := False;
            end
            else // �Ȳ���n��Ҳ�������֣��Ǿ���������Ż��߻���������
            begin
                Result := '-1'; // -1��ʾָ�����Ƶ�����
                sn := mst[1];   // ��ʱ��mst[1]Ӧ���������򻷾���������
                ApplyToGroup := False;
            end;
        end;
        SetLength(mst, 0);
    end;

begin
    S := GetMeterSet;
    if S = 'UNKNOWN' then
        Exit;

    NewSeries := TTLSeries.Create;
    { check Meter setting }
    NewSeries.MeterIndex := StrToInt(S);
    NewSeries.SourceType := pds;
    NewSeries.SourceName := sn;

    Params := ParamStr.Split(['|']);
    i := StrToInt(Params[0]);
    NewSeries.PDIndex := i;
    NewSeries.Title := Params[1];
    if VertAxis.ContainsKey(UpperCase(Params[2])) then
    begin
        NewSeries.VertAxis := VertAxis.Items[UpperCase(Params[2])];
        Series.Add(NewSeries);
    end
    else
    begin
        ShowMessage(Format('������"%s"δ���壬�޷����ƹ�����"%s:%s"', [Params[2], Entry, ParamStr]));
        NewSeries.Free;
    end;
end;

procedure ReleaseDefines;
var
    t: TTrendlinePreDefine;
begin
    for t in TLPreDefines.Values do
        t.Free;
    TLPreDefines.Clear;
    TLPreDefines.Free;
end;

initialization

TLPreDefines := TDictionary<string, TTrendlinePreDefine>.Create;

finalization

ReleaseDefines;
// TLPreDefines.DisposeOf;

end.
