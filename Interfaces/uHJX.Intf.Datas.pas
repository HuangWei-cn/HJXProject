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
    function GetLastPDDatas(ADsnName: string; var Values: TDoubleDynArray): Boolean; overload;
    function GetLastPDDatas(ADsnName: string; var Values: TVariantDynArray): Boolean; overload;
        { ȡ��ָ��ʱ���ڼ�����������һ������ }
    function GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
      var Values: TDoubleDynArray): Boolean; overload;
    function GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
      var Values: TVariantDynArray): Boolean; overload;
        { ȡ����ӽ�ָ�����ڵĹ۲����� }
    function GetNearestPDDatas(ADsnName: String; DT: TDateTime; var Values: TDoubleDynArray;
      DTDelta: Integer = 0): Boolean; overload;
    function GetNearestPDDatas(ADsnName: String; DT: TDateTime; var Values: TVariantDynArray;
      DTDelta: Integer = 0): Boolean; overload;
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
      var EVDatas: PEVDataArray): Boolean;
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
          λ�Ƽ����ݳ���Ϊ4��ÿ��Ԫ�ض���һ��VariantArray������Ϊ6������Ϊ������ʽ���塣 }
    function GetDataIncrement(ADsnName: string; DT: TDateTime;
      var Values: TVariantDynArray): Boolean;
        { ����ָ��������ָ�����ڼ���ڼ������������ֵΪ��
                pdName|DTScale|�������|��ֵ|����
          ��������GetDataIncrement�в�𣬱�����û��30�����������ֻ��5�����ݡ� }
    function GetDataIncrement2(ADsnName: String; DT: TDateTime; InteralDays: Integer;
      var Values: TVariantDynArray): Boolean;

      { ����ָ��ʱ�����ָ��������ָ�������������緵���������������������������������������������ȡ�
        ������ÿ��ִ�н���ѯһ����������ĳһ����������������������Ҫ��ѯһ�������������Ķ����������
        ����Ҫ���ö�Ρ�
        ���������
        1��APDIndex��������������������š����ڶ���������APDIndexΪ0�������ڶ��λ�Ƽƣ�����Ҫ�г���
           ��Ȳ������ڼ��������Ҫ��һ���á�ĳЩ����������Ҫ��ѯ����������������ֽ�Ʋ�ѯ�¶ȣ�
           ˮƽλ�Ʋ���ѯ�������򡢻�������任����ȣ���ʱAPDIndex����Ϊ0��
        2��StartDayָ������ʼ�����Ǹ����ڵڼ��죬�����������ջƽ�ϿΪÿ��20��~����19�ա��ꡢ����
           StartDay����ˡ�������������StartDay = 1~7����Ӧ��һ~���գ�����7����Ϊ1��
        3��Period=0~3���ֱ��Ӧ�¡��ꡢ�����ܣ�һ���ò��������������̫С��

        ����ֵΪVariant�������飬���¼��ʽΪ��
              ���ڼ������| ��ʼ����| ��������| ��ʼֵ| ��ֵֹ| ����| ���ֵ| ��Сֵ| ���

        �����������ʽ˵����
          1�����ڼ�����ƣ��硰2019��8�¡�����2020���һ���ȡ�����2016�ꡱ
          2����ʼֵ����ֵֹ���������ֱ�Ϊ�����ڵ�һ���ֵ�����������һ���ֵ����ʼ�ͽ�ֹ��ֵ��ֵ
          3�����ֵ����Сֵ���ֱ�Ϊ�������ڵ����ֵ����Сֵ�����
        �û��������ͨ�����ñ�������ȡ���ݺ���д������������
 }
    function GetPeriodIncrement(ADsnName: String; APDIndex: Integer; StartDate, EndDate: TDateTime;
      var Values: TVariantDynArray; StartDay: Integer = 20; Period: Integer = 0): Boolean;
    function ErrorMsg:String;
    procedure ClearErrMsg;
  end;

var
  IHJXClientFuncs: IClientFuncs;

implementation

end.
