{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Classes.Meters
 Author:    黄伟
 Date:      06-六月-2018
 Purpose:   仪器对象定义单元。本单元对象全部是抽象对象，可由插件单元引用。
            在原大岗山程序中，仪器对象模型采用接口在插件之间传递，带来了不少
            麻烦，因为里面所有聚合对象都需要用接口，这样访问起来总感觉不美。
            本次采用抽象类模型在插件之间传递。
            but...一旦本程序开始采用外部独立插件而非整合插件，就只能使用接口
            了。
 History:   2018-06-06 创建本单元
            2018-07-24 增加数据结构预定义对象及其集合，均为抽象类。具体实现
            参见uHJX.Excel.Meters单元
----------------------------------------------------------------------------- }
{ todo: 需增加仪器限差表，针对各类不同的仪器有一个通用限差，即测值变幅达到多少
值得关注；也需要增加针对单个仪器的限差，以便于特别关照某些重点关注仪器。 }
{ todo: 需增加重点关注仪器表集合，用于快速生成简报、日报，省的每次从全部仪器中
挑选。 }
unit uHJX.Classes.Meters;

interface

uses
    System.Classes, System.SysUtils, System.Variants, System.Generics.Collections;

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

    TDataDefines = class
    protected
        // FList: TList;
        function GetItem(Index: Integer): PDataDefine; virtual; abstract;
        // procedure SetItem(Index: Integer; DD: PDataDefine);
        function GetCount: Integer; virtual; abstract;
    public
        // constructor Create;
        // destructor Destroy; override;

        function AddNew: PDataDefine; virtual; abstract;
        function IndexOfDataName(AName: String): Integer; virtual; abstract;
        procedure Clear; virtual; abstract;
        procedure Assign(Source: TDataDefines); virtual; abstract;
        property Items[Index: Integer]: PDataDefine read GetItem; // write SetItem;
        property Count: Integer read GetCount;
    end;

    TDataSheetStructure = record
        DTStartRow: Integer;
        DTStartCol: Integer;
        AnnoCol: Integer;
        BaseLine: Integer;
        MDs: TDataDefines;
        PDs: TDataDefines;
        ChartDefineName: string; // 图表定义名2018-07-25
        ChartTemplate: string;
        WGTemplate: string;
        XLTemplate: string;
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

    TMeterDefine = class
    protected
        // function GetPDDefines: TDataDefines;
        function GetPDDefine(Index: Integer): TDataDefine; virtual; abstract;
    public
        DesignName   : string;
        DataSheet    : string;
        DataBook     : string;
        Params       : TMeterParams;
        PrjParams    : TMeterProjectParams;
        DataSheetStru: TDataSheetStructure;
        ChartPreDef  : TObject; // 过程线预定义对象，在加载参数时赋值
        // constructor Create;
        // destructor Destroy; override;
        function ParamValue(AParamName: string): Variant; virtual; abstract;
        procedure SetParamValue(AParamName: string; Value: Variant); virtual; abstract;
        function PDName(Index: Integer): string; virtual; abstract;
        function PDColumn(Index: Integer): Integer; virtual; abstract;
        property PDDefines: TDataDefines read DataSheetStru.PDs;
        property PDDefine[Index: Integer]: TDataDefine read GetPDDefine;
    end;

    TMeterDefines = class
    protected
        function GetCount: Integer; virtual; abstract;
        function GetItem(Index: Integer): TMeterDefine; virtual; abstract;
        function GetMeter(ADesignName: string): TMeterDefine; virtual; abstract;
    public
        function AddNew: TMeterDefine; virtual; abstract;
        function Add(AMeter: TMeterDefine): Integer; virtual; abstract;
        // 注意：Clear、Delete只移除对象，并不释放！！！
        procedure Clear; virtual; abstract;
        procedure ReleaseAllMeters; virtual; abstract;
        procedure Delete(Index: Integer); overload; virtual; abstract;
        procedure Delete(AName: string); overload; virtual; abstract;
        procedure SortByDesignName; virtual; abstract;
        procedure SortByPosition; virtual; abstract;
        procedure SortByMeterType; virtual; abstract;
        procedure SortByDataFile; virtual; abstract;
        property Count: Integer read GetCount;
        property Items[index: Integer]: TMeterDefine read GetItem;
        property Meter[ADesignName: string]: TMeterDefine read GetMeter;
    end;

    { 2018-05-29 仪器组项
      仪器组主要包含：组名、组类型、组内仪器表，以及其他针对组特性的定义，如数据表格式、过程线格式
      等等。最简单的组定义就是前三个数据项，有这三个就可以单独编写处理单元，避开复杂的格式定义，那
      玩意儿很麻烦，而且不好用 }
    TMeterGroupItem = class
    protected
        FName: string;
        FType: string;
        // FMeters: TStrings;
        function GetMeterCount: Integer; virtual; abstract;
        function GetItem(Index: Integer): string; virtual; abstract;
    public
        // constructor Create;
        // destructor Destroy; override;
        procedure AddMeter(AName: string); virtual; abstract;
        procedure AddMeters(AMeterList: string); virtual; abstract;

        property Name: string read FName write FName;
        property GroupType: string read FType write FType;
        property Count: Integer read GetMeterCount;
        property Items[Index: Integer]: string read GetItem;
    end;

    { 2018-05-29 仪器组集合 }
    TMeterGroup = class
    protected
        function GetCount: Integer; virtual; abstract;
        function GetItem(Index: Integer): TMeterGroupItem; virtual; abstract;
        function GetItemByName(AGroupName: string): TMeterGroupItem; virtual; abstract;
    public
        function AddNew: TMeterGroupItem; virtual; abstract;
        procedure ReleaseAllItems; virtual; abstract;
        property Count: Integer read GetCount;
        property Item[Index: Integer]: TMeterGroupItem read GetItem;
        property ItemByName[AGroupName: string]: TMeterGroupItem read GetItemByName;
    end;

    { 仪器数据表结构预定义项 }
    TPreDefineDataStructure = class
    public
        DefineName: string;
        DataDefine: TDataSheetStructure;
    end;

    TPreDefineDataStruList = class
    protected
        function GetCount: Integer; virtual; abstract;
        function GetItem(Index: Integer): TPreDefineDataStructure; virtual; abstract;
        function GetItemByName(ADefineName: string): TPreDefineDataStructure; virtual; abstract;
    public
        function AddNew: TPreDefineDataStructure; virtual; abstract;
        procedure Clear; virtual; abstract;
        property Count: Integer read GetCount;
        property Item[Index: Integer]: TPreDefineDataStructure read GetItem;
        property ItemByName[ADefineName: string]: TPreDefineDataStructure read GetItemByName;
    end;

type
    { 本程序数据字段名及对应的显示名，用来将DataSet中field名称换为中文名，供菜鸟看。
      这个结构体用于SetFieldDisplayName方法，该方法是接口同名方法的实现。 }
    ThjxDSName = record
        FieldName: string;
        DisplayName: string;
    end;

    PhjxDSName = ^ThjxDSName;

    ThjxDSNames = class
    private
    public
        procedure AddName(AFldName, ADispName: string); virtual; abstract;
        function DispName(AFldName: string): String; virtual; abstract;
    end;

    { 分布图记录 }
    TLayoutRec = record
        Name: string;
        FileName: string;
        MeterList: string;
        Annotation: string;
    end;

    PLayoutRec = ^TLayoutRec;

{ 分布图集合 }
    TLayouts = class
    protected
        function GetCount: Integer; virtual; abstract;
        function GetItem(Index: Integer): PLayoutRec; virtual; abstract;
    public
        function AddNew: PLayoutRec; virtual; abstract;
        procedure Clear; virtual; abstract;
        property Count: Integer read GetCount;
        property Items[Index: Integer]: PLayoutRec read GetItem;
    end;

var
    { todo:ExcelMeters等三个全局对象应在AppServices中声明，或由一个专门的全局对象提供 }
    ExcelMeters: TMeterDefines;
    DSNames    : ThjxDSNames;
    MeterGroup : TMeterGroup;
    Layouts    : TLayouts; // 布置图定义集合
    DSDefines  : TPreDefineDataStruList;

implementation

end.
