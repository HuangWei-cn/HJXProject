{ -----------------------------------------------------------------------------
  Unit Name: uHJX.Template.ChartTemplatye ( 原uTLDefineProc单元)
  Author:    黄伟
  Date:      2018-08-30
  Purpose:   Chart模板单元
  本单元源自uTLDefineProc单元，主要变化是TChartTemplate类继承自uHJX.Classes.Templates单元中
  的ThjxTemplate类，且本单元中的类为抽象类，以便于通过AppServices传递给插件。
  主要类是TChartTemplate，该类被GraphDispatcher集合管理，调用者可以通过访问该集合获得相应的模板。
  具象化的类是TChartTLTemplate, TChartVectorTemplate，分别是过程线
  模板和矢量图模板。测斜孔图因需要两个Chart，另有程序专门对待。

  本单元对模板代码的解析没有采用正则表达式，导致能适应的定义比较简单。下一步应改为
  正则表达式处理模板定义代码。

  History:
  ----------------------------------------------------------------------------- }
{ DONE:将过程线模板定义由“预定义”改为“模板”，从PreDefine变成Template }
{ todo:使用正则表达式处理Chart模板 }
unit uHJX.Template.ChartTemplate;

interface

uses
    System.Classes, System.SysUtils, System.Generics.Collections, Vcl.Dialogs,
    uHJX.Classes.Templates;

type
    { 坐标轴类型 }
    /// <remarks>坐标轴类型：左、右、底、顶、自定义</remarks>
    TAXType = (axLeft, axRight, axBottom, axTop, axCustom);

    { SubAxis定义结构 }
    TSubAxis = record
        Title: string;
        Visible: Boolean;
        Format: string;
    end;

    { 坐标轴定义 }
    TchtAxis = class
        Title: string;
        AxisType: TAXType;
        IsVertAxis: Boolean; // 是否竖轴
        LeftSide: Boolean;   // 是否左轴
        BottomSide: Boolean; // 是否下横轴
        Index: Integer;
        Format: string;
        // subaxis用于横轴对日期的显示
        SubAxis1: TSubAxis;
        SubAxis2: TSubAxis;
        // 指向在设置Chart过程中的竖轴，主要指向CustomAxis，可以方便设置
        // Series.CustomAxis
        ChartAxis: TObject;
    end;

    /// <remarks>图标数据来源：监测仪器、环境量</remarks>
    TPDSource = (pdsMeter, pdsEnv); // 物理量来源：仪器，环境量。将来可能会支持其他类型的数据源
    { Series类型, 目前支持过程线，矢量图，散点图。将来可能会支持统计图形 }
    /// <remarks>Series类型：线形图(对应过程线)、箭头图(对应矢量图如平面位移图)、散点(对应位移图如
    /// 测斜孔、垂线、引张线、静力水准、激光准直等)</remarks>
    TcsType = (csLine, csArrow, csPoints);

    { 模板Series定义 }
    /// <summary>模板Series定义。绘图程序可根据本定义创建TeeChart Series，属性中的SeriesType指明了
    /// Series的类型；SourceType标明了数据来源（监测仪器或环境量）；SourceName标明了仪器编号或
    /// 环境量名称；PDIndex标明了是仪器的第几个物理量；HoriAxis和VertAxis标明了本Series的横轴和
    /// 竖轴。
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
        // Series类型：Line，Arrow，Point。分别对应过程线、矢量图、散点图
        property SeriesType: TcsType read FType write FType;
        // 数据源类型：监测仪器，环境量。
        property SourceType: TPDSource read FSourceType write FSourceType;
        // 对于监测仪器，一般为*或明确的设计编号，对于环境量则为环境量名称
        /// <remarks>对于监测仪器，一般为*或明确的设计编号，对于环境量则为环境量名称</remarks>
        property SourceName: string read FSourceName write FSourceName;

        { MeterIndex = -1,0,1...MAXINT，其中：
          -1为指定仪器名称(设计编号)；0相当于n，可适用于所有仪器；1,2,3...etc，为一组仪器，分别对应
          第一支、第二只、第三只等等。实际使用时，对于单支仪器，MeterIndex = 0|1 皆可，对于仪器组，
          若设置对所有仪器相同，则每个PD前应加上<Meter n>，这时MeterIndex = 0；或者可指定PD对应的仪器序号 }
        /// <summary>MeterIndex = -1,0,1...MAXINT，其中：
        /// -1为指定仪器名称(设计编号)；0相当于n，可适用于所有仪器；1,2,3...etc，为一组仪器，分别对应
        /// 第一支、第二只、第三只等等。实际使用时，对于单支仪器，MeterIndex = 0|1 皆可，对于仪器组，
        /// 若设置对所有仪器相同，则每个PD前应加上"＜Meter n＞"，这时MeterIndex = 0；或者可指定PD对应的仪器序号。
        /// </summary>
        property MeterIndex: Integer read FMeterIndex write FMeterIndex;
        ///<summary>物理量序号，起始为1</summary>
        property PDIndex   : Integer read FPDIndex write FPDIndex;
        // Title有可能包含需要被替换的内容，如%name%， %MeterName%等
        property Title   : string read FTitle write FTitle;
        property HoriAxis: TchtAxis read FHoriAxis write FHoriAxis;
        property VertAxis: TchtAxis read FVertAxis write FVertAxis;
        property ShowAnno: Boolean read FShowAnno write FShowAnno; // 是否显示数据的备注
    end;

    { Chart的类型：过程线，矢量图，位移图 }
    /// <summary>Chart类型：过程线图、矢量图、位移图。暂时只支持这三类仪器Chart</summary>
    /// <remarks>这三类Chart所对应的Series类型分别为csLine, csArror, csPoints。</remarks>
    TchtType = (cttTrendLine, cttVector, cttDisplacement);

    { Chart模板对象 }
    TChartTemplate = class(ThjxTemplate)
    private
        FTempStr     : string;
        FApplyToGroup: Boolean;
        FChartTitle  : string;
        FChartType   : TchtType;
        FEnvType     : Integer;
        ///<summary>在本方法中，主要设置标题和坐标轴。Series的设置调用SetSeries方法实现。
        ///</summary>
        procedure SetDefine(Entry, ParamStr: string);
        procedure SetSeries(Entry, ParamStr: string);

    public
        // EnvType: Integer; // 环境量类型：温度，水位……其他没想到的
        // 横坐标轴，允许有多个横轴，及其自定义轴
        HoriAxises: TDictionary<string, TchtAxis>;
        // 竖轴，允许多个竖轴，包括自定义竖轴
        VertAxises: TDictionary<string, TchtAxis>;
        // 模板中定义的图表序列
        Series: TList<TchtSeries>;

        constructor Create; override;
        destructor Destroy; override;
        procedure Clear;
        /// <summary>本方法解析模板代码，分解为可供操作的对象和各类属性</summary>
        /// <param name="tmpStr">模板代码字符串</param>
        /// <remarks>目前只设计了过程线模板的格式和语法，暂没有考虑矢量图和位移图的语法和格式，
        /// 因此尚不能确定能正确处理这两种类型的模板</remarks>
        procedure SetTemplate(tmpStr: string); virtual;

        { 模板这里不提供处理方法。处理方法是个性化的，由绘图插件提供，并注册到调度器中。模 板只提供
          定义本身，让凯撒的归凯撒，上帝的归上帝吧。 }
        // procedure Draw(ADesignName: string; AChart: TObject); virtual; abstract;
    published
        // Chart类型：过程线，矢量图，散点图（测斜、引张线、垂线等）
        property ChartType : TchtType read FChartType write FChartType;
        property ChartTitle: string read FChartTitle;
        // 模板定义的内容
        /// <summary>模板代码<see cref="procedure SetTemplate"/></summary>
        property TemplateStr: string read FTempStr write SetTemplate;
        // 模板如果支持组，则若对应的仪器也属于组，则绘制组Chart，否则只能绘制单支仪器的数据图形
        /// <summary>模板是否支持仪器组？如果模板支持仪器组，且给定仪器也属于某个组，则绘制该组
        /// 图形；若仪器单支，则仅绘制这一只仪器，忽略其他定义。
        /// </summary> array[0..10] of Integer = ();
        property ApplyToGroup: Boolean read FApplyToGroup;
        /// <summary>环境量类型</summary>
        property EnvType: Integer read FEnvType write FEnvType;
    end;

{ TLPreDefines已经被HJXTemplates替代。后者将成为AppServices的属性共其他模块调用。
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
        if ParamStr = '过程线' then Self.FChartType := cttTrendLine
        else if ParamStr = '矢量图' then FChartType := cttVector
        else if ParamStr = '位移图' then FChartType := cttDisplacement;
    end
    else if SameText(Entry, 'Metertype') then MeterType := ParamStr
    else if SameText(Entry, 'Axis') then
    begin
        Params := ParamStr.Split(['|']);
        for i := low(Params) to high(Params) do Params[i] := Trim(Params[i]);

        { 暂不支持横轴的CustomAxis，只有竖轴才有CustomAxis }
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
            // 再多的设置就是针对SubAxis的了。如果有SubAxis，则BottomAxis.Title=''，Title应当设置在
            // 最下方的SubAxis上。
            if high(Params) >= 4 then
            begin
                NewAxis.SubAxis1.Visible := True;
            // 这里应当分解Params[4]，取出Format设置。当前暂时不支持SubAxis的title等属性
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
            // 判断是否是CustomAxis
            i := StrToInt(Params[1]);
            if i <> 0 then NewAxis.AxisType := axCustom;
            // 将坐标轴名称添加到VerAxis字典集合中
            S := UpperCase(Params[0]) + 'AXIS[' + IntToStr(i) + ']';
            VertAxises.Add(S, NewAxis);
        end;
    end
    else if Pos('PD', Entry) > 0 then SetSeries(Entry, ParamStr);

end;

{ 目前这个方法只处理了过程线类型，没有考虑矢量图和位移图类型 }
{ todo:增加矢量图模板(平面位移测点)的解析 }
{ todo:增加位移图模板(引张线、垂线、静力水准等类型)的解析 }
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
        { 没有<Meter>项，说明该设置适应所有仪器，返回值为n, 或* }
        if (ii = 0) and (jj = 0) then
        begin
            Result := '1'; // 当没有<Meter X>项时，默认等于<Meter 1>
            pds := pdsMeter;
            sn := '*';
            FApplyToGroup := False;
            Exit;
        end;
        { 错误判断，出现下面的情况，忽略Meter设置 }
        if ((ii = 0) and (jj <> 0)) or ((ii <> 0) and (jj = 0)) or (ii > jj) or (jj = ii + 1) then
        begin
            Result := '1';
            pds := pdsMeter;
            sn := '*';
            FApplyToGroup := False;
            Exit;
        end;

        // 其他情况:Meter 1/2/3..., Meter n；暂不支持指定仪器编号、环境量等复杂情况，下一步再说
        ss := Copy(Entry, ii + 1, jj - ii - 1);
        mst := ss.Split([' ']);
        for ii := low(mst) to high(mst) do mst[ii] := Trim(mst[ii]);

        if Length(mst) >= 2 then
        begin
            // 第一项应该为Meter or Env
            if SameText(mst[0], 'Meter') then pds := pdsMeter
            else if SameText(mst[0], 'Env') then pds := pdsEnv
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
                FApplyToGroup := True;
            end
            else if TryStrToInt(mst[1], ii) then
            begin
                Result := mst[1];
                sn := '*';
                if ii > 1 then FApplyToGroup := True
                else FApplyToGroup := False;
            end
            else // 既不是n，也不是数字，那就是仪器编号或者环境量名称
            begin
                Result := '-1'; // -1表示指定名称的仪器
                sn := mst[1];   // 此时，mst[1]应该是仪器或环境量的名称
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
    { 根据Chart类型设置Series类型，暂不支持混合类型 }
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
        ShowMessage(Format('坐标轴"%s"未定义，无法绘制过程线"%s:%s"', [Params[2], Entry, ParamStr]));
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
