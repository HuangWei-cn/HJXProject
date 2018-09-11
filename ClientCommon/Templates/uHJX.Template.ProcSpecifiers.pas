{ ����Ԫ���ڴ���ģ����ռλ��
    ����Ԫ���������������ֱ���������ռλ�����ֶ���ռλ�����ڱ��ģ���У�ͨ�����⡢��ͷ�Ȱ�������
    �������͵�ռλ����������������������ֶ�����ռλ����Ŀǰ��ʱû�п��ǽ����ߺϲ��Ĵ��㡣

    Ӧ����ʹ��TemplateDispatcher����������������Ϊ��Dispatcher�ķ�����ȫ����ṩ��
}
unit uHJX.Template.ProcSpecifiers;

interface

uses
    System.Classes, System.SysUtils, uHJX.Classes.Meters;

{ ����������Ե�ռλ���������������滻������ֵΪ�滻��Ľ�� }
/// <summary>������������⡢��ͷ��λ�õ�ռλ��������ͱ�ͷ�е�ռλ����Ҫ���������ԣ�
/// ������Ʊ�š�׮�š��߳�֮��ģ�������������֮�����������ԡ������滻��
/// ռλ������ֱ��ʹ�á�</summary>
function ProcParamSpecifiers(AStr: string; AMeter: TMeterDefine; AsGroup: Boolean = False): string;

{ ������������ֶε�ռλ��������ռλ������Ӧ���ֶ����������߻���ֶ��������д����ݼ���FindField }
/// <summary>�������������������е�ռλ���� �������е�ռλ��������������������ƣ����ֻҪ�����Ӧ
/// ���ֶ����滻�Ϳ��ԡ��ڴ�������ʱ��ֱ�ӴӶ�Ӧ���ֶ��ж�ȡ�������롣
/// </summary>
function ProcDataSpecifiers(AStr: string; AMeter: TMeterDefine; AsGroup: Boolean = False): string;

implementation

uses
    System.RegularExpressions;

const
    { �����������ʽ���������� %DesignName% �� %PD1.Name% ��%Meter1.PD1.Name%��%Meter1.DesignName% ���͵��
      ��TRegEx.Matches��ʽִ��ʱ�����ؽ���ɷ���:
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

    { �����������ʽ���������е�ƥ�䣺%DTScale|Annotation%, %PD1%, %Meter1.PD1%�����������ƥ��
      �����Ϊ��
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
    MyColl := RegEx.Matches(AStr); // ȡ������ƥ����
    if MyColl.Count = 0 then       // Ϊ����ԭ�����
            Exit;

    // ͨ��ֻ��һ���Ҳ˵��׼ʲôʱ����еĶ��ˣ����磺%MeterType%%DesignName%�۲����ݱ�
    for i := 0 to MyColl.Count - 1 do
    begin
        // MyColl.Item[i].Value; //�����ռλ��������
        // MyGrps.Item[1]��ȥ��%%����
        MyGrps := MyColl.Item[i].Groups;
        // �������Ԫ�������ж����������ͣ��μ����ʽ˵��������
        case MyGrps.Count of
            2: // ��Ӧ��ʽΪ%DesignName%��
                begin
                    { todo:�迼��%GroupName%����� }
                    if SameText(MyGrps.Item[1].Value, 'GroupName') then
                            Result := StringReplace(Result, MyColl.Item[i].Value,
                            AMeter.PrjParams.GroupID, [rfReplaceAll])
                    else
                    begin
                        sParam := AMeter.ParamValue(MyGrps.Item[1].Value);
                        if sParam = '' then sParam := ' ';
                    { if sParam = '' then
                        sParam := Format('����%s�����ڻ���ֵ', [MyGrps.item[1].Value]); }
                        Result := StringReplace(Result, MyColl.Item[i].Value, sParam,
                            [rfReplaceAll, rfIgnoreCase]);
                    end;
                end;

            6: // ��Ӧ��ʽΪ%Meter1.DesignName%�������ʽ��������飬���������飬��ʹ��Ameter.DesignName
               // ʵ�ʿ���չ��Meter�����������У����õĳ���DesignName������Deep��Stake��Elevation�ȼ���
                begin
                    if AsGroup then // ��������鴦���������������滻ռλ��
                    begin
                        j := StrToInt(MyGrps.Item[4].Value); // �������
                        S := MeterGroup.ItemByName[AMeter.PrjParams.GroupID].Items[j - 1];
                        mt := ExcelMeters.Meter[S];
                        if mt <> nil then
                                Result := StringReplace(Result, MyColl.Item[i].Value, mt.DesignName,
                                [rfReplaceAll]);
                    end
                    else // �����ø��������������滻ռλ��
                            Result := StringReplace(Result, MyColl.Item[i].Value, AMeter.DesignName,
                            [rfReplaceAll]);
                end;

            9: // ��Ӧ��ʽΪ%PD1.Name%��%Meter1.PD1.Name%
                begin
                    if MyGrps.Item[2].Value <> '' then // %Meter1.PD1.Name%
                    begin
                        if AsGroup then
                        begin
                            j := StrToInt(MyGrps.Item[4].Value); // ���ֵ��Meter��������֣����ڼ���Meter
                            S := MeterGroup.ItemByName[AMeter.PrjParams.GroupID].Items[j - 1];
                            mt := ExcelMeters.Meter[S]; // �����ݲ��������������⣬ȫ����AMeter���
                        end
                        else mt := AMeter;
                    end
                    else mt := AMeter;

                    k := StrToInt(MyGrps.Item[7].Value); // ���ֵ��PD��MD��������֣����ڼ���PD��
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
        // ��ʱ��ֵÿ�����ݵ�Ԫֻ����һ��ռλ����
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
                    // ���bGroup=false����DS��û��DesignName.PD1���͵��ֶ�����ֻ��PD1��ʽ��
                    // ��Ϊ��bGroup=Falseʱ����ѯ���ݼ�ֻ��ѯ��֧�������ݣ�ֻ��ΪTrueʱ���Ž���
                    // �����ݲ�ѯ
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
