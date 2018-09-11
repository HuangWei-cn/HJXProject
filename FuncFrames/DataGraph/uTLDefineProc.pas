{ -----------------------------------------------------------------------------
 Unit Name: uTLDefineProc
 Author:    黄伟
 Date:      25-七月-2018
 Purpose:   过程线预定义处理单元
            实际上，本单元的“预定义”其实也可以被称为是Style或Template，当定义
            中不包含确定的仪器时是Template，指明了具体的仪器时，是预定义的过
            程线。
            当前设计仅应对历时过程线，没有考虑到矢量图、散点图(测斜曲线)等，且
            没有和GraphDispatcher结合，加载模板的uHJX.Excel.InitParams单元需要
            直接引用本单元，这些都需要在后期逐一改进、完善。
 History:
----------------------------------------------------------------------------- }
{ todo:将过程线模板定义由“预定义”改为“模板”，从PreDefine变成Template }
{ todo:增加模板适用范围定义，比如本单元的定义就适用于过程线 }
{ todo:修改类定义，增加抽象类以适应其他类型Chart模板 }
unit uTLDefineProc;

interface

uses
    System.Classes, System.SysUtils, System.Generics.Collections, Vcl.Dialogs;

type
    TAXType = (axLeft, axRight, axBottom, axCustom);

    { SubAxis定义结构 }
    TSubAxis = record
        Title: string;
        Visible: Boolean;
        Format: String;
    end;

    { 坐标轴定义 }
    TTLAxis = class
        Title: string;
        AxisType: TAXType;
        IsVertAxis: Boolean;
        LeftSide: Boolean;
        Index: Integer;
        Format: string;
        // subaxis用于横轴对日期的显示
        SubAxis1: TSubAxis;
        SubAxis2: TSubAxis;
        ChartAxis: TObject; // 指向在设置Chart过程中的竖轴，主要指向CustomAxis，可以方便设置Series.CustomAxis
    end;

    { 过程线定义 }
    TPDSource = (pdsMeter, pdsEnv); // 物理量来源：仪器，环境量

    TTLSeries = class
    protected
    public
        SourceType: TPDSource;
        SourceName: string; // 对于监测仪器，一般为*或明确的设计编号，对于环境量则为环境量名称
        // MeterIndex: string; // 这里是String类型，值可能是数字，也可能是字符n，对于单支仪器，可能不考虑这个属性

        { MeterIndex = -1,0,1...MAXINT，其中：
        -1为指定仪器名称(设计编号)；0相当于n，可适用于所有仪器；1,2,3...etc，为一组仪器，分别对应
        第一支、第二只、第三只等等。实际使用时，对于单支仪器，MeterIndex = 0|1 皆可，对于仪器组，
        若设置对所有仪器相同，则每个PD前应加上<Meter n>，这时MeterIndex = 0；或者可指定PD对应的仪器序号 }
        MeterIndex: Integer;
        PDIndex   : Integer;
        Title     : String; // Title有可能包含需要被替换的内容，如%name%， %MeterName%等
        VertAxis  : TTLAxis;
        ShowAnno  : Boolean; // 是否显示数据的备注
    end;

    { 过程线预定义对象 }
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
        { 解码预定义，生成各种设置 }
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
    DefineStr := DefStr; // 将定义保存下来，以备后用
    // 在解码之前，考虑先清空原设置，考虑到用户可能在使用过程中手动修改定义，以调整过程线样式及效果……
    Clear;

    // 首先，去掉各种回车换行，以及前后空格
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
            // 再多的设置就是针对SubAxis的了。如果有SubAxis，则BottomAxis.Title=''，Title应当设置在
            // 最下方的SubAxis上。
            if High(Params) >= 4 then
            begin
                HoriAxis.SubAxis1.Visible := True;
                // 这里应当分解Params[4]，取出Format设置。当前暂时不支持SubAxis的title等属性
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
            // 判断是否是CustomAxis
            i := StrToInt(Params[1]);
            if i <> 0 then
                NewAxis.AxisType := axCustom;
            // 将坐标轴名称添加到VerAxis字典集合中
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
        { 没有<Meter>项，说明该设置适应所有仪器，返回值为n, 或* }
        if (ii = 0) and (jj = 0) then
        begin
            Result := '1'; // 当没有<Meter X>项时，默认等于<Meter 1>
            pds := pdsMeter;
            sn := '*';
            ApplyToGroup := False;
            Exit;
        end;
        { 错误判断，出现下面的情况，忽略Meter设置 }
        if ((ii = 0) and (jj <> 0)) or ((ii <> 0) and (jj = 0)) or (ii > jj) or (jj = ii + 1) then
        begin
            Result := '1';
            pds := pdsMeter;
            sn := '*';
            ApplyToGroup := False;
            Exit;
        end;

        // 其他情况:Meter 1/2/3..., Meter n；暂不支持指定仪器编号、环境量等复杂情况，下一步再说
        ss := Copy(Entry, ii + 1, jj - ii - 1);
        mst := ss.Split([' ']);
        for ii := Low(mst) to High(mst) do
            mst[ii] := Trim(mst[ii]);

        if Length(mst) >= 2 then
        begin
            // 第一项应该为Meter or Env
            if SameText(mst[0], 'Meter') then
                pds := pdsMeter
            else if SameText(mst[0], 'Env') then
                pds := pdsEnv
            else
            begin
                Result := 'UNKNOWN';
                Exit;
            end;

            // 第二项应该为数字、字母‘n’、‘*’、或仪器编号、或环境量名称
            if (mst[1] = 'n') then
            begin
                Result := '0'; // mst[1]; MeterIndex = 0相当于n，对所有仪器有效
                sn := '*';     // sn是SourceName项，*表示任何仪器
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
            else // 既不是n，也不是数字，那就是仪器编号或者环境量名称
            begin
                Result := '-1'; // -1表示指定名称的仪器
                sn := mst[1];   // 此时，mst[1]应该是仪器或环境量的名称
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
        ShowMessage(Format('坐标轴"%s"未定义，无法绘制过程线"%s:%s"', [Params[2], Entry, ParamStr]));
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
