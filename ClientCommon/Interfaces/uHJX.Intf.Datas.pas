unit uHJX.Intf.Datas;

interface

uses
    System.Classes, System.Types, Data.DB,
    uHJX.Data.Types;

type
    IClientFuncs = interface(IInterface)
        ['{E54FEFEB-41EF-49F8-B242-8983452D7593}']
        procedure SessionBegin;
        procedure SessionEnd;
        { ȡ��ָ��������������һ�μ������ }
        function GetLastPDDatas(ADsnName: string; var Values: TDoubleDynArray): Boolean;
        { ȡ��ָ��ʱ���ڼ�����������һ������ }
        function GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
            var Values: TDoubleDynArray): Boolean;
        { ȡ����ӽ�ָ�����ڵĹ۲����� }
        function GetNearestPDDatas(ADsnName: String; DT: TDateTime; var Values: TDoubleDynArray;
            DTDelta: Integer = 0): Boolean;
        { ȡ��ָ��ʱ���ڼ���������й۲����� }
        function GetPDDatasInPeriod(ADsnName: string; DT1, DT2: TDateTime; DS: TDataSet): Boolean;
        { ȡ��ȫ���۲����� }
        function GetAllPDDatas(ADsnName: string; DS: TDataSet): Boolean;
        { ȡ��������۲����� }
        function GetGroupAllPDDatas(AGrpName: string; DS: TDataSet): Boolean;
        { ȡ��������ָ��ʱ���ڹ۲����� }
        function GetGroupPDDatasInPeriod(AGrpName: string; DT1, DT2: TDateTime;
            DS: TDataSet): Boolean;
        { ȡ�ص�ǰ����ֵ�����ã���GetEVDatas����ȡ���� }
            function GetEVData(ADsnName: string; EVData: PEVDataStru): Boolean; overload;
        function GetEVData(ADsnName: string; var EVDatas: TDoubleDynArray): Boolean; overload;
        { ȡ��ָ���������о�������ֵ��������������ֵ }
        function GetEVDatas(ADsnName: String; var EVDatas: PEVDataArray): Boolean;
        { ȡ��ָ��ʱ���ڵ�����ֵ }
        function GetEVDataInPeriod(ADsnName: string; DT1, DT2: TDateTime;
            var EVDatas: TDoubleDynArray): Boolean;
        { ȡ��ָ��ʱ���ڵĹ۲���(����������ÿ�������൱��һ�����) }
        function GetDataCount(ADsnName: string; DT1, DT2: TDateTime): Integer;
        { ����DataSet���ֶα��� }
        procedure SetFieldDisplayName(DS: TDataSet);
        { ���������������� }
        function GetMeterTypeName(ADsnName: string): string;
        { ����������������(��������б������)����������μ����������������������ݸ�ʽΪ��
                ��������|�۲�����|�������|DTʱ�䵱ǰֵ|���������ֵ|������ֵ
          ����ֻ��Ҫ��ѯ����һ������������������ê�ˡ�ê���ȣ�Values����ֻ��һ��Ԫ�أ����ݳ���Ϊ1��
          ��Values[0]��һ��VariantArray�������ݼ�Ϊ������ʽ������Ϊ6�������ж����������Ҫ��ѯ����
          ������������λ�Ƽơ�ƽ��λ�Ʋ��ȣ���Values���ݳ��ȵ�����Ҫ��ѯ�����������������ڶ��
          λ�Ƽ����ݳ���Ϊ4��ÿ��Ԫ�ض���һ��VariantArray������Ϊ6������Ϊ������ʽ���塣
        }
        function GetDataIncrement(ADsnName: string; DT: TDateTime; var Values: TVariantDynArray): Boolean;
    end;

var
    IHJXClientFuncs: IClientFuncs;

implementation

end.
