{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Classes.Meters
 Author:    ��ΰ
 Date:      06-����-2018
 Purpose:   ���������嵥Ԫ������Ԫ����ȫ���ǳ�����󣬿��ɲ����Ԫ���á�
            ��ԭ���ɽ�����У���������ģ�Ͳ��ýӿ��ڲ��֮�䴫�ݣ������˲���
            �鷳����Ϊ�������оۺ϶�����Ҫ�ýӿڣ��������������ܸо�������
            ���β��ó�����ģ���ڲ��֮�䴫�ݡ�
            but...һ��������ʼ�����ⲿ��������������ϲ������ֻ��ʹ�ýӿ�
            �ˡ�
 History:   2018-06-06 ��������Ԫ
            2018-07-24 �������ݽṹԤ��������伯�ϣ���Ϊ�����ࡣ����ʵ��
            �μ�uHJX.Excel.Meters��Ԫ
----------------------------------------------------------------------------- }
{ todo: �����������޲����Ը��಻ͬ��������һ��ͨ���޲����ֵ����ﵽ����
ֵ�ù�ע��Ҳ��Ҫ������Ե����������޲�Ա����ر����ĳЩ�ص��ע������ }
{ todo: �������ص��ע�������ϣ����ڿ������ɼ򱨡��ձ���ʡ��ÿ�δ�ȫ��������
��ѡ�� }
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
        HasEV: Boolean; // ������ֵ��
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
        ChartDefineName: string; // ͼ������2018-07-25
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
        GroupID: string; // ������ID��Ŀǰָ��������  2018-05-29
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
        ChartPreDef  : TObject; // ������Ԥ��������ڼ��ز���ʱ��ֵ
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
        // ע�⣺Clear��Deleteֻ�Ƴ����󣬲����ͷţ�����
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

    { 2018-05-29 ��������
      ��������Ҫ�����������������͡������������Լ�������������ԵĶ��壬�����ݱ��ʽ�������߸�ʽ
      �ȵȡ���򵥵��鶨�����ǰ������������������Ϳ��Ե�����д����Ԫ���ܿ����ӵĸ�ʽ���壬��
      ��������鷳�����Ҳ����� }
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

    { 2018-05-29 �����鼯�� }
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

    { �������ݱ�ṹԤ������ }
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
    { �����������ֶ�������Ӧ����ʾ����������DataSet��field���ƻ�Ϊ�������������񿴡�
      ����ṹ������SetFieldDisplayName�������÷����ǽӿ�ͬ��������ʵ�֡� }
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

    { �ֲ�ͼ��¼ }
    TLayoutRec = record
        Name: string;
        FileName: string;
        MeterList: string;
        Annotation: string;
    end;

    PLayoutRec = ^TLayoutRec;

{ �ֲ�ͼ���� }
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
    { todo:ExcelMeters������ȫ�ֶ���Ӧ��AppServices������������һ��ר�ŵ�ȫ�ֶ����ṩ }
    ExcelMeters: TMeterDefines;
    DSNames    : ThjxDSNames;
    MeterGroup : TMeterGroup;
    Layouts    : TLayouts; // ����ͼ���弯��
    DSDefines  : TPreDefineDataStruList;

implementation

end.
