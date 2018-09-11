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
        function GetLastPDDatas(ADsnName: string; var Values: TDoubleDynArray): Boolean;
        { 取回指定时段内监测仪器的最后一次数据 }
        function GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
            var Values: TDoubleDynArray): Boolean;
        { 取回最接近指定日期的观测数据 }
        function GetNearestPDDatas(ADsnName: String; DT: TDateTime; var Values: TDoubleDynArray;
            DTDelta: Integer = 0): Boolean;
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
            var EVDatas: TDoubleDynArray): Boolean;
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
          位移计数据长度为4，每个元素都是一个VariantArray，长度为6，内容为上述格式定义。
        }
        function GetDataIncrement(ADsnName: string; DT: TDateTime; var Values: TVariantDynArray): Boolean;
    end;

var
    IHJXClientFuncs: IClientFuncs;

implementation

end.
