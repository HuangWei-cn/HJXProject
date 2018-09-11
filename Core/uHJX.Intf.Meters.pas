{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Intf.Meters
 Author:    黄伟
 Date:      30-五月-2018
 Purpose:   仪器定义接口
 History:   2018-05-30 暂时没有投入使用，需再考虑一下是否值得弄这么复杂
----------------------------------------------------------------------------- }

unit uHJX.Intf.Meters;

interface

uses
    System.Classes;

type
    TDataDefine = record
        Name: string;
        Alias: string;
        DataUnit: string;
        Column: Integer;
        HasEV: Boolean; // 有特征值否？
    end;

    PDataDefine = ^TDataDefine;
    // PDataDefines = array of PDataDefine;

    { 数据定义 }
    IDataDefines = interface
        ['{148B0BF3-E148-47C2-BF26-8BEBC9997FFB}']
        function GetItem(Index: Integer): PDataDefine;
        // procedure SetItem(Index: Integer; DD: PDataDefine);
        function GetCount: Integer;
    end;

    TDataSheetStructure = record
        DTStartRow: Integer;
        DTStartCol: Integer;
        AnnoCol: Integer;
        BaseLine: Integer;
        MDs: IDataDefines;
        PDs: IDataDefines;
    end;

    TMeterParams = record
        MeterType: string;
        Model: string;
        SerialNo: string;
        WorkMode: string;
        MinValue: double;
        MaxValue: double;
        SensorCount: Integer;
        SetupDate: TDateTime;
        BaseDate: TDateTime;
        MDCount: Integer;
        PDCount: Integer;
        Annotation: string;
    end;

    TMeterProjectParams = record
        SubProject: string;
        Position: string;
        Elevation: double;
        Stake: string;
        Profile: string;
        Deep: double;
        Annotation: string;
        GroupID: string; // 仪器组ID，目前指“组名”  2018-05-29
    end;

    { 监测仪器 }
    IMeterDefine = interface
        ['{10799F18-B711-4A7F-BD38-C38D4F3AF8D2}']
        function GetPDDefine(Index: Integer): TDataDefine;
        function ParamValue(AParamName: string): Variant;
        procedure SetParamValue(AParamName: string; Value: Variant);
        function PDName(Index: Integer): string;
        function PDColumn(Index: Integer): Integer;
    end;

    { 监测仪器集合 }
    IMeters = interface
        ['{9140E69B-1E3A-497B-8C8C-B4C50D6297FA}']
        function GetCount: Integer;
        function GetItem(Index: Integer): IMeterDefine;
        function GetMeter(ADesignName: string): IMeterDefine;
        procedure SortByDesignName;
        procedure SortByPosition;
        procedure SortByMeterType;
        procedure SortByDataFile;
    end;

    { 仪器组项 }
    IMeterGroupItem = interface
        ['{98CDAF85-0E94-44DB-BCE3-90FED453FE00}']
        function GetMeterCount: Integer;
        function GetItem(Index: Integer): string;
    end;

    { 仪器组对象接口 }
    IMeterGroup = interface
        ['{588D865C-C3DB-436A-9981-78511FCD1266}']
        function GetCount: Integer;
        function GetItem(Index: Integer): IMeterGroupItem;
        function GetItemByName(AGroupName: string): IMeterGroupItem;
    end;

implementation

end.
