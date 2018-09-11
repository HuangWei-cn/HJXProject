{-----------------------------------------------------------------------------
 Unit Name: uIClientFuncs
 Author:    Administrator
 Date:      04-一月-2013
 Purpose:   本单元将dmClient的常用方法接口化，用于适应插件架构
            在PSMIS重构为插件架构之前，所有对数据的访问都由使用者调用dmClient
            实现，调用者必须在代码中Uses udmClient单元。现在将dmClient的所有
            方法分解到几个接口中，调用者只需要引用接口即可。
 History:
-----------------------------------------------------------------------------}

unit uIClientFuncs;

interface
uses
    SysUtils, Classes, Controls, Forms, ComCtrls, DB, DBClient{, uBaseTypes};

type
    IClientFuncs = interface(IInterface)
        ['{CEDBD386-8612-46EE-AFAF-BB33001C43CC}']
        { 暂时取消原接口所有方法，在开发过程中根据本程序的需要逐渐添加和实现 }

//        { 列出所有设计监测点和设计编号 }
//        procedure ListDesignNames(ANames: TStrings);
//        { 列出指定编号仪器的所有SubSensor }
//        procedure ListSubSensors(ADesignID: Integer; ASubs: TStrings);
//        { 列出指定编号仪器的所有SubValues }
//        procedure ListMultiValues(ADesignID: Integer; ASubs: TStrings);
//        { 按观测类型分组设计观测点 }
//        procedure ListDNsGroupByMT(Tree: TTreeNodes);
//        { 按仪器类型分组设计观测点 }
//        procedure ListDNsGroupByST(Tree: TTreeNodes);
//        { 按安装部位分组设计观测点 }
//        procedure ListDNsGroupByLaidPos(Tree: TTreeNodes);
//        { 按观测断面分组设计观测点 }
//        procedure ListDNsGroupByProfile(Tree: TTreeNodes);
//        { 取得指定设计编号仪器的设计信息 }
//        procedure GetDesignInfo(InfoList: TStrings; ADesignName: string);
//        { 取得指定仪器的仪器信息 }
//        procedure GetSensorInfo(InfoList: TStrings; ASensorName: string);
//        { 取得工程部位列表 }
//        procedure GetPrjPosList(AList: TStrings);
//        { 取得埋设部位列表 }
//        procedure GetLaidPosList(AList: TStrings);
//        { 取得断面列表 }
//        procedure GetProfileList(AList: TStrings);
//        { 取得监测项目列表 }
//        procedure GetMonitoringTypeList(AList: TStrings);
//        { 取得仪器类型列表，可选仅列出在用的仪器类型表 }
//        procedure GetSensorTypeList(AList: TStrings; InUse: Boolean = False);
//        { 取得工作模式列表 }
//        procedure GetWorkModeList(AList: TStrings);
//        { 取得标段列表 }
//        procedure GetBidSectionList(AList: TStrings);
//        { 取得厂家列表 }
//        procedure GetVendorList(AList: TStrings);
//        { 取得公式列表 }
//        procedure GetFormulaList(AList: TStrings);
//        { 取厂家振弦式仪器产品型号列表 }
//        procedure GetVWMeterModelNoList(AVendor: string; AStrings: TStrings);
//        { 取厂家标准信号仪器产品型号列表 }
//        procedure GetSSMeterModelNoList(AVendor: string; AStrings: TStrings);
//        { 取某测点观测值日期列表 }
//        procedure GetSDDTScaleList(AStrings: TStrings; ASensorID:
//            Longint; ASC: Boolean = True);
//        { 取测斜仪各个测段 }
//        procedure GetCXYSubs(ASensorID: Longint; var Subs: TCXYSubs);
//        { 取得单位列表}
//        procedure GetUnitsList(AStrings: TStrings);
//        { 取得在用的环境量名表 }
//        procedure GetInUseEnvironments(AStrings: TStrings);
//        { 取得事件类别 }
//        procedure GetEventCategories(AStrings: TStrings);
//        { 系列常用方法------------------------------------------ }
//        function GetDesignID(ADesignName: string): Integer;
//        function GetDesignName(ADesignID: Integer): string;
//        function GetSubSensorCount(ADesignID: Integer): Integer;
//        function GetMultiValueCount(ADesignID: Integer): Integer;
//        function GetSensorType(ADesignID: Integer): Integer;
//        function GetSensorWorkMode(ADesignID: Integer): Integer;
//        function IsGroupSensor(ADesignID: Integer): Boolean;
//        function IsMultiValueSensor(ADesignID: Integer): Boolean;
//        function GetSensorTypeName(ATypeID: Integer): string;
//        function GetSubSensorName(ADesignID, ASubID: Integer): string;
//        function GetPDFieldsCaptionStr(ATypeID: Integer): string;
//        function GetPDListStr(ATypeID: integer): string; overload;
//        function GetPDListStr(ATypeName: string): string; overload;
//        function GetSDFieldsCaptionStr(ATypeID: Integer): string;
//        function GetSDFieldCaption(ATypeID: Integer; AFieldName: string):
//            string;
//        function GetPDFieldCaption(ATypeID: Integer; AFieldName: string):
//            string;
//        function GetSensorTypeRec(ATypeName: string): TSensorType; overload;
//        function GetSensorTypeRec(ATypeID: Integer): TSensorType; overload;
//        function GetFormula(AName: string): TSMFormulaRec; overload;
//        function GetFormula(AID: Integer): TSMFormulaRec; overload;
//        function GetFormula(UID: TGUID): TSMFormulaRec; overload;
//        function GetFormulaUID(AID: Integer): string; overload;
//        function GetFormulaUID(AName: string): string; overload;
//        function GetFormulaID(UID: TGUID): Integer; overload;
//        function GetFormulaID(AName: string): Integer; overload;
//        function GetSensorInitDate(ADesignID, ASubID: Integer): TDateTime;
//        function GetDesignParamRec(ADesignID: Longint): TDesignParams;
//        function GetVWSParamRec(ADesignID, ASubID: Longint):
//            TVibratingWireSensorParams;
//        function GetSSSParamRec(ADesignID, ASubID: Longint):
//            TStandardSignalSensorParams;
//        function GetDeformParamRec(ADesignID: Longint): TDeformParams;
//        function GetSDRecordID(ADT: TDateTime; ASensorID, ASubID: Integer):
//            Integer;
//        function GetDeformDataRecordID(ADT: TDateTime; ASensorID: Integer):
//            Integer;
//        function GetVWSignalData(ASensorID, ASubID: Integer; ADate: TDateTime;
//            var SgnData: TVWSignalData): Boolean;
//        function UpdateDeformInitValue(ADesignID: Integer; ADate: TDateTime;
//            X, Y, EL: Double): Boolean;
//        function UpdateVWSInitValue(ASensorID, ASubID: Integer; ADate:
//            TDateTime;
//            IV1, IV2: Double): Boolean;
//        function UpdateVWSStandardValue(ASensorID, ASubID: Integer;
//            AStdFreqM, AStdTemp: Double): Boolean;
//
//        function GetMaxID(ATableName, AIDField: string; KeyField, KeyValue:
//            string): Integer; overload;
//        function GetMaxID(ATableName, AIDField, KeyField: string; KeyValue:
//            Integer): Integer; overload;
//        function GetVendorID(AVendor: string; AutoAppend: Boolean = False):
//            Integer;
//        function GetSensorTypeID(ASensorType: string; AutoAppend: Boolean =
//            False): Integer;
//        function GetMonitoringTypeID(AMonitoringType: string; AutoAppend: Boolean
//            = False): Integer;
//        function GetMonitoringItemID(AMonitoringType, AMonitoringItem: string;
//            AutoAppend: Boolean = False): Integer;
//
//        { 取得指定仪器的数据，为_testDrawTrendLine准备。本方法应当重新写 }
//        procedure GetSensorDatas(ASensor: string; var ds: TClientDataSet; var
//            ASensorType: Integer);
//        { 返回指定日期或最接近指定日期的指定的数据项，可能是测量值也可能是物理量 }
//        function GetSensorDataCloseToDT(ASensor, ADataName: string; ASubID:
//            Integer;
//            ADT: TDateTime; var AValue: Double): Boolean; overload;
//        function GetSensorDataCloseToDT(SSID, ASubID: Integer; ADataName:
//            string;
//            ADT: TDateTime; var AValue: Double): Boolean; overload;
//
//        procedure DeleteMultiSensorDefine(ASSID: Longint);
//        procedure DeleteMultiValueDefine(ASSID: Longint);
//        { 删除数据记录，测量值或物理量 }
//        function DeleteSDRecByID(ARecID: Longint): Integer;
//        function DeleteSDRec(ASensorID, ASubID: Longint; ADT: TDateTime):
//            Integer; overload;
//        function DeleteSDRec(ASensorID: Longint; ADT: TDateTime): Integer;
//            overload;
//        function DeletePDRecByID(ARecID: Longint): Integer;
//        function DeletePDRecBySDID(ASDID: Longint): Integer;
//        function DeletePDRec(ASensorID, ASubID: Longint; ADT: TDateTime):
//            Integer; overload;
//        function DeletePDRec(ASensorID: Longint; ADT: TDateTime): Integer;
//            overload;
//        function DeleteDeformDataByID(ARecID: Longint): Integer;
//        function DeleteDeformDataRec(ADesignID: Longint; ADT: TDateTime):
//            Integer;
//        { 返回记录ID }
//        function RecordExists(ASQL: string): Boolean;
//        function PDRecID(ADT: TDateTime; ASensorID, ASubID: Longint): Longint;
//        { 测点组操作，加载仪器组 }
//        procedure ListSensorGroups(Tree: TTreeNodes; APrivacy: Integer;
//            bFavorite: Boolean = False);
//        { 列出组名. CanEdit为False则列出所有能访问的组，为True只列出能编辑的组 }
//        procedure GetGroupList(APrivacy: Integer; AList: TStrings; CanEdit:
//            Boolean = False);
//        { 将一个测点加入到某个组 }
//        function AddPointToGroup(AGroupID, AMemberID, AMemberType: Integer):
//            Boolean; overload;
//        function AddPointToFavorite(ADesignID: Integer): Boolean; overload;
//        function AddPointToFavorite(ADesignName: string): Boolean; overload;
//
//        function GetGroupDefine(AGroupName: string; APrivacy: Integer;
//            AUID, AUName: string; AFavorite: Boolean = False): TDMPGroup;
//        function GetSensorGroupID(AGroupName: string; APrivacy: Integer;
//            AOwner: string): Integer;
//        procedure GetGroupMembers(AGroupID: Integer; AMembers: TStrings);
//        procedure CreateGroupDefine(var AGroup: TDMPGroup);
//        procedure UpdateGroupDefine(AGroup: TDMPGroup);
//        procedure UpdateGroupMembers(AGroupID: Integer; AMembers: TStrings);
//        function DeleteGroup(AGroupID: Integer): Boolean;
//
//        { 仪器参数操作 }
//        function UpdateMeter(MeterID: Integer;
//            AVendor, AParams: string;
//            ALaidDate, AStdDate, AInitDate: TDateTime;
//            AMeterModel: string = '';
//            AttLevel: Integer = -1;
//            CheckRuleID: Integer = -1;
//            AddInfo: string = '';
//            Annotation: string = '';
//            Valid: Boolean = True;
//            InvalidDate: TDateTime = 0;
//            BeenReplaced: Boolean = False): Boolean;
//        { 更新仪器状态 }
//        function UpdateMeterState(MeterID: Integer; AttLevel, CheckRuleID:
//            Integer): Boolean; overload;
//        function UpdateMeterState(MeterID: Integer; AddInfo, Annotation: string):
//            Boolean; overload;
//        function UpdateMeterState(MeterID: Integer; Valid: Boolean; InvalidDate:
//            TDateTime; BeenReplaced: Boolean): Boolean; overload;
//        function UpdateMeterState(MeterID: Integer; LaidDate, StdDate, InitDate:
//            TDateTime): Boolean; overload;
//        { 取仪器ParamStr }
//        function GetMeterParamStr(AID: Integer): string;

    end;

implementation

end.

