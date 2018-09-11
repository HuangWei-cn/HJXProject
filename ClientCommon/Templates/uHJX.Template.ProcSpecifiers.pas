{ 本单元用于处理模板中占位符
    本单元包含两个函数，分别处理属性类占位符和字段类占位符。在表格模板中，通常标题、表头等包含的是
    属性类型的占位符，而数据区则包含的是字段类型占位符。目前暂时没有考虑将两者合并的打算。

    应考虑使用TemplateDispatcher，将这两个函数作为该Dispatcher的方法向全社会提供。
}
unit uHJX.Template.ProcSpecifiers;

interface

uses
    System.Classes, System.SysUtils, uHJX.Classes.Meters;

{ 处理包含属性的占位符，用仪器属性替换。返回值为替换后的结果 }
/// <summary>本函数处理标题、表头等位置的占位符。标题和表头中的占位符主要是仪器属性，
/// 比如设计编号、桩号、高程之类的，本函数处理完之后即用仪器属性、参数替换了
/// 占位符，可直接使用。</summary>
function ProcParamSpecifiers(AStr: string; AMeter: TMeterDefine; AsGroup: Boolean = False): string;

{ 处理包含数据字段的占位符，返回占位符所对应的字段名，调用者获得字段名后自行从数据集中FindField }
/// <summary>本函数处理数据区域中的占位符。 数据区中的占位符基本都是数据项的名称，因此只要用相对应
/// 的字段名替换就可以。在处理数据时，直接从对应的字段中读取数据填入。
/// </summary>
function ProcDataSpecifiers(AStr: string; AMeter: TMeterDefine; AsGroup: Boolean = False): string;

implementation

uses
    System.RegularExpressions;

const
    { 下面的正则表达式适用于类似 %DesignName% 、 %PD1.Name% 、%Meter1.PD1.Name%、%Meter1.DesignName% 类型的项。
      当TRegEx.Matches方式执行时，返回结果可分组:
            ====New match====================================
            Match #0: %DesignName%
            Group: 0
            Value 0: %DesignName%
            Value 1: DesignName
            ====New match====================================
            Match #1: %PD1.Name%
            Group: 1
            Value 0: %PD1.Name%
            Value 1: PD1.Name
            Value 2:
            Value 3:
            Value 4:
            Value 5: PD1.Name
            Value 6: PD
            Value 7: 1
            Value 8: Name
            ====New match====================================
            Match #2: %Meter1.PD1.Name%
            Group: 2
            Value 0: %Meter1.PD1.Name%
            Value 1: Meter1.PD1.Name
            Value 2: Meter1.
            Value 3: Meter
            Value 4: 1
            Value 5: PD1.Name
            Value 6: PD
            Value 7: 1
            Value 8: Name
            ====New match====================================
            Match #3: %Meter1.DesignName%
            Group: 3
            Value 0: %Meter1.DesignName%
            Value 1: Meter1.DesignName
            Value 2: Meter1.
            Value 3: Meter
            Value 4: 1
            Value 5: DesignName
 }
    RegExStr =
        '%([a-zA-Z]*|((Meter)([1-9][0-9]*)\.)?(DesignName|(PD|MD)([1-9][0-9]*)\.(Name|Alias|DataUnit)))%';

    { 下面的正则表达式用于数据行的匹配：%DTScale|Annotation%, %PD1%, %Meter1.PD1%这三类情况，匹配
      后分组为：
            ====New match====================================
            Match #0: %dtscale%
            Group: 0
            Value 0: %dtscale%
            Value 1: dtscale
            ====New match====================================
            Match #1: %pd1%
            Group: 1
            Value 0: %pd1%
            Value 1: pd1
            Value 2:
            Value 3:
            Value 4:
            Value 5: pd
            Value 6: 1
            ====New match====================================
            Match #2: %meter1.pd1%
            Group: 2
            Value 0: %meter1.pd1%
            Value 1: meter1.pd1
            Value 2: meter1.
            Value 3: meter
            Value 4: 1
            Value 5: pd
            Value 6: 1
 }
    DataRowRegStr = '%(DTScale|Annotation|((Meter)(n|[1-9][0-9]*)\.)?(PD|MD)([1-9][0-9]*))%';

var
    RegEx    : TRegEx;
    RegExData: TRegEx;
    MyColl   : TMatchCollection;
    MyGrps   : TGroupCollection;

function ProcParamSpecifiers(AStr: string; AMeter: TMeterDefine; AsGroup: Boolean = False): string;
var
    i, j  : Integer;
    k     : Integer;
    sParam: string;
    S     : string;
    iPD   : Integer;
    DF    : TDataDefine;
    mt    : TMeterDefine;
begin
    Result := AStr;
    MyColl := RegEx.Matches(AStr); // 取回所有匹配项
    if MyColl.Count = 0 then       // 为零则原文输出
            Exit;

    // 通常只有一项，但也说不准什么时候就有的多了，比如：%MeterType%%DesignName%观测数据表
    for i := 0 to MyColl.Count - 1 do
    begin
        // MyColl.Item[i].Value; //这个是占位符的内容
        // MyGrps.Item[1]是去掉%%的项
        MyGrps := MyColl.Item[i].Groups;
        // 根据组的元素数量判断是哪种类型，参见表达式说明和样例
        case MyGrps.Count of
            2: // 对应型式为%DesignName%，
                begin
                    { todo:需考虑%GroupName%的情况 }
                    if SameText(MyGrps.Item[1].Value, 'GroupName') then
                            Result := StringReplace(Result, MyColl.Item[i].Value,
                            AMeter.PrjParams.GroupID, [rfReplaceAll])
                    else
                    begin
                        sParam := AMeter.ParamValue(MyGrps.Item[1].Value);
                        if sParam = '' then sParam := ' ';
                    { if sParam = '' then
                        sParam := Format('参数%s不存在或无值', [MyGrps.item[1].Value]); }
                        Result := StringReplace(Result, MyColl.Item[i].Value, sParam,
                            [rfReplaceAll, rfIgnoreCase]);
                    end;
                end;

            6: // 对应型式为%Meter1.DesignName%，这个形式针对仪器组，若非仪器组，则使用Ameter.DesignName
               // 实际可扩展到Meter的所有属性中，常用的除了DesignName，还有Deep，Stake，Elevation等几项
                begin
                    if AsGroup then // 如果进行组处理，则用组内仪器替换占位符
                    begin
                        j := StrToInt(MyGrps.Item[4].Value); // 仪器序号
                        S := MeterGroup.ItemByName[AMeter.PrjParams.GroupID].Items[j - 1];
                        mt := ExcelMeters.Meter[S];
                        if mt <> nil then
                                Result := StringReplace(Result, MyColl.Item[i].Value, mt.DesignName,
                                [rfReplaceAll]);
                    end
                    else // 否则用给定的仪器参数替换占位符
                            Result := StringReplace(Result, MyColl.Item[i].Value, AMeter.DesignName,
                            [rfReplaceAll]);
                end;

            9: // 对应形式为%PD1.Name%和%Meter1.PD1.Name%
                begin
                    if MyGrps.Item[2].Value <> '' then // %Meter1.PD1.Name%
                    begin
                        if AsGroup then
                        begin
                            j := StrToInt(MyGrps.Item[4].Value); // 这个值是Meter后面的数字，即第几个Meter
                            S := MeterGroup.ItemByName[AMeter.PrjParams.GroupID].Items[j - 1];
                            mt := ExcelMeters.Meter[S]; // 这里暂不考虑仪器组问题，全部用AMeter替代
                        end
                        else mt := AMeter;
                    end
                    else mt := AMeter;

                    k := StrToInt(MyGrps.Item[7].Value); // 这个值是PD或MD后面的数字，即第几个PD项
                    if UpperCase(MyGrps.Item[6].Value) = 'PD' then
                            DF := mt.DataSheetStru.PDs.Items[k - 1]^
                    else DF := mt.DataSheetStru.MDs.Items[k - 1]^;

                    S := UpperCase(MyGrps.Item[8].Value);
                    if SameText(S, 'Name') then sParam := DF.Name
                    else if SameText(S, 'Alias') then sParam := DF.Alias
                    else if SameText(S, 'DataUnit') then sParam := DF.DataUnit;

                    Result := StringReplace(Result, MyColl.Item[i].Value, sParam, [rfReplaceAll]);
                end;
        end;
    end;
end;

function ProcDataSpecifiers(AStr: string; AMeter: TMeterDefine; AsGroup: Boolean = False): string;
var
    i: Integer;
    S: string;
begin
    Result := '';
    MyColl := RegExData.Matches(AStr);
    if MyColl.Count > 0 then
    begin
        // 暂时限值每个数据单元只能有一个占位符。
        MyGrps := MyColl.Item[0].Groups;
        case MyGrps.Count of
            2:
                begin
                    // apply two field: dtscale and annotation.
                    if SameText(MyGrps.Item[1].Value, 'DTScale') then Result := 'DTScale'
                            // DataField := DS.FindField('DTScale')
                    else if SameText(MyGrps.Item[1].Value, 'Annotation') then
                            Result := 'Annotation';
                            // DataField := DS.FindField('Annotation');
                end;

            7: if MyGrps.Item[3].Value = '' then // like PD1, etc.
                begin
                    // DataField := DS.FindField(MyGrps.Item[1].Value)
                    Result := MyGrps.Item[1].Value;
                end
                else // like Meter1.PD1
                begin
                    // 如果bGroup=false，则DS中没有DesignName.PD1类型的字段名，只有PD1形式的
                    // 因为当bGroup=False时，查询数据集只查询单支仪器数据；只有为True时，才进行
                    // 组数据查询
                    if AsGroup then
                    begin
                        i := StrToInt(MyGrps.Item[4].Value); // meter's number
                        S := MeterGroup.ItemByName[AMeter.PrjParams.GroupID].Items[i - 1];
                        S := S + '.' + MyGrps.Item[5].Value + MyGrps.Item[6].Value;
                        // DataField := DS.FindField(S);
                    end
                    else
                    begin
                        S := MyGrps.Item[5].Value + MyGrps.Item[6].Value;
                        // DataField := DS.FindField(S);
                    end;

                    Result := S;
                end;
        end;
    end;
end;

initialization

RegEx := TRegEx.Create(RegExStr, [roIgnoreCase]);
RegExData := TRegEx.Create(DataRowRegStr, [roIgnoreCase]);

end.
