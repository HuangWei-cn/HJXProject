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
        { 取回指定监测仪器的最后一次监测数据 }
    function GetLastPDDatas(ADsnName: string; var Values: TDoubleDynArray): Boolean; overload;
    function GetLastPDDatas(ADsnName: string; var Values: TVariantDynArray): Boolean; overload;
        { 取回指定时段内监测仪器的最后一次数据 }
    function GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
      var Values: TDoubleDynArray): Boolean; overload;
    function GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
      var Values: TVariantDynArray): Boolean; overload;
        { 取回最接近指定日期的观测数据 }
    function GetNearestPDDatas(ADsnName: String; DT: TDateTime; var Values: TDoubleDynArray;
      DTDelta: Integer = 0): Boolean; overload;
    function GetNearestPDDatas(ADsnName: String; DT: TDateTime; var Values: TVariantDynArray;
      DTDelta: Integer = 0): Boolean; overload;
        { 取回指定时段内监测仪器所有观测数据 }
    function GetPDDatasInPeriod(ADsnName: string; DT1, DT2: TDateTime; DS: TDataSet): Boolean;
        { 取回全部观测数据 }
    function GetAllPDDatas(ADsnName: string; DS: TDataSet): Boolean;
        { 取回仪器组观测数据 }
    function GetGroupAllPDDatas(AGrpName: string; DS: TDataSet): Boolean;
        { 取回仪器组指定时段内观测数据 }
    function GetGroupPDDatasInPeriod(AGrpName: string; DT1, DT2: TDateTime;
      DS: TDataSet): Boolean;
        { 取回当前特征值，弃用，被GetEVDatas方法取代。 }
    function GetEVData(ADsnName: string; EVData: PEVDataStru): Boolean; overload;
    function GetEVData(ADsnName: string; var EVDatas: TDoubleDynArray): Boolean; overload;
        { 取回指定仪器所有具有特征值的物理量的特征值 }
    function GetEVDatas(ADsnName: String; var EVDatas: PEVDataArray): Boolean;
        { 取回指定时段内的特征值 }
    function GetEVDataInPeriod(ADsnName: string; DT1, DT2: TDateTime;
      var EVDatas: PEVDataArray): Boolean;
        { 取回指定时段内的观测点次(即数据量，每个数据相当于一个点次) }
    function GetDataCount(ADsnName: string; DT1, DT2: TDateTime): Integer;
        { 设置DataSet的字段别名 }
    procedure SetFieldDisplayName(DS: TDataSet);
        { 返回仪器类型名称 }
    function GetMeterTypeName(ADsnName: string): string;
        { 返回仪器数据增量(不包括测斜孔数据)。返回两测次间增量及月增量，返回数据格式为：
                物理量名|观测日期|间隔天数|DT时间当前值|两测次增量值|月增量值
          对于只需要查询计算一个物理量的仪器，如锚杆、锚索等，Values数组只有一个元素，数据长度为1，
          但Values[0]是一个VariantArray，其内容即为上述格式，长度为6；对于有多个物理量需要查询计算
          的仪器，如多点位移计、平面位移测点等，则Values数据长度等于需要查询的物理量个数，对于多点
          位移计数据长度为4，每个元素都是一个VariantArray，长度为6，内容为上述格式定义。 }
    function GetDataIncrement(ADsnName: string; DT: TDateTime;
      var Values: TVariantDynArray): Boolean;
        { 返回指定仪器在指定日期间隔期间的增量，返回值为：
                pdName|DTScale|间隔天数|测值|增量
          本函数与GetDataIncrement有差别，本函数没有30天增量，因此只有5列数据。 }
    function GetDataIncrement2(ADsnName: String; DT: TDateTime; InteralDays: Integer;
      var Values: TVariantDynArray): Boolean;

      { 返回指定时间段内指定仪器的指定周期增量，如返回月增量、周增量、季度增量、半年增量、年增量等。
        本函数每次执行仅查询一个传感器的某一物理量的周期增量，若需要查询一堆仪器或仪器的多个物理量，
        则需要调用多次。
        输入参数：
        1、APDIndex：待查仪器的物理量序号。对于多数仪器，APDIndex为0；但对于多点位移计，若需要列出各
           深度测点的周期间隔，则需要逐一调用。某些仪器可能需要查询其他物理量，比如钢筋计查询温度，
           水平位移测点查询其他方向、或者坐标变换结果等，此时APDIndex均不为0；
        2、StartDay指周期起始日期是该周期第几天，如月增量按照黄金峡为每月20日~次月19日。年、季的
           StartDay均如此。但是周增量的StartDay = 1~7，对应周一~周日，超过7的视为1。
        3、Period=0~3，分别对应月、年、季、周，一般用不到周增量，间隔太小。

        返回值为Variant类型数组，其记录格式为：
              日期间隔名称| 起始日期| 截至日期| 起始值| 截止值| 增量| 最大值| 最小值| 变幅

        返回数据项格式说明：
          1、日期间隔名称：如“2019年8月”、“2020年第一季度”、“2016年”
          2、起始值、截止值、增量：分别为该周期第一天测值、该周期最后一天测值、起始和截止测值差值
          3、最大值、最小值：分别为该周期内的最大值、最小值、变幅
        用户程序可以通过调用本方法获取数据后填写仪器的增量表
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
