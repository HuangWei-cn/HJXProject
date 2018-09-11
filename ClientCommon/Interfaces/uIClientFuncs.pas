{-----------------------------------------------------------------------------
 Unit Name: uIClientFuncs
 Author:    Administrator
 Date:      04-һ��-2013
 Purpose:   ����Ԫ��dmClient�ĳ��÷����ӿڻ���������Ӧ����ܹ�
            ��PSMIS�ع�Ϊ����ܹ�֮ǰ�����ж����ݵķ��ʶ���ʹ���ߵ���dmClient
            ʵ�֣������߱����ڴ�����Uses udmClient��Ԫ�����ڽ�dmClient������
            �����ֽ⵽�����ӿ��У�������ֻ��Ҫ���ýӿڼ��ɡ�
 History:
-----------------------------------------------------------------------------}

unit uIClientFuncs;

interface
uses
    SysUtils, Classes, Controls, Forms, ComCtrls, DB, DBClient{, uBaseTypes};

type
    IClientFuncs = interface(IInterface)
        ['{CEDBD386-8612-46EE-AFAF-BB33001C43CC}']
        { ��ʱȡ��ԭ�ӿ����з������ڿ��������и��ݱ��������Ҫ����Ӻ�ʵ�� }

//        { �г�������Ƽ������Ʊ�� }
//        procedure ListDesignNames(ANames: TStrings);
//        { �г�ָ���������������SubSensor }
//        procedure ListSubSensors(ADesignID: Integer; ASubs: TStrings);
//        { �г�ָ���������������SubValues }
//        procedure ListMultiValues(ADesignID: Integer; ASubs: TStrings);
//        { ���۲����ͷ�����ƹ۲�� }
//        procedure ListDNsGroupByMT(Tree: TTreeNodes);
//        { ���������ͷ�����ƹ۲�� }
//        procedure ListDNsGroupByST(Tree: TTreeNodes);
//        { ����װ��λ������ƹ۲�� }
//        procedure ListDNsGroupByLaidPos(Tree: TTreeNodes);
//        { ���۲���������ƹ۲�� }
//        procedure ListDNsGroupByProfile(Tree: TTreeNodes);
//        { ȡ��ָ����Ʊ�������������Ϣ }
//        procedure GetDesignInfo(InfoList: TStrings; ADesignName: string);
//        { ȡ��ָ��������������Ϣ }
//        procedure GetSensorInfo(InfoList: TStrings; ASensorName: string);
//        { ȡ�ù��̲�λ�б� }
//        procedure GetPrjPosList(AList: TStrings);
//        { ȡ�����貿λ�б� }
//        procedure GetLaidPosList(AList: TStrings);
//        { ȡ�ö����б� }
//        procedure GetProfileList(AList: TStrings);
//        { ȡ�ü����Ŀ�б� }
//        procedure GetMonitoringTypeList(AList: TStrings);
//        { ȡ�����������б���ѡ���г����õ��������ͱ� }
//        procedure GetSensorTypeList(AList: TStrings; InUse: Boolean = False);
//        { ȡ�ù���ģʽ�б� }
//        procedure GetWorkModeList(AList: TStrings);
//        { ȡ�ñ���б� }
//        procedure GetBidSectionList(AList: TStrings);
//        { ȡ�ó����б� }
//        procedure GetVendorList(AList: TStrings);
//        { ȡ�ù�ʽ�б� }
//        procedure GetFormulaList(AList: TStrings);
//        { ȡ��������ʽ������Ʒ�ͺ��б� }
//        procedure GetVWMeterModelNoList(AVendor: string; AStrings: TStrings);
//        { ȡ���ұ�׼�ź�������Ʒ�ͺ��б� }
//        procedure GetSSMeterModelNoList(AVendor: string; AStrings: TStrings);
//        { ȡĳ���۲�ֵ�����б� }
//        procedure GetSDDTScaleList(AStrings: TStrings; ASensorID:
//            Longint; ASC: Boolean = True);
//        { ȡ��б�Ǹ������ }
//        procedure GetCXYSubs(ASensorID: Longint; var Subs: TCXYSubs);
//        { ȡ�õ�λ�б�}
//        procedure GetUnitsList(AStrings: TStrings);
//        { ȡ�����õĻ��������� }
//        procedure GetInUseEnvironments(AStrings: TStrings);
//        { ȡ���¼���� }
//        procedure GetEventCategories(AStrings: TStrings);
//        { ϵ�г��÷���------------------------------------------ }
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
//        { ȡ��ָ�����������ݣ�Ϊ_testDrawTrendLine׼����������Ӧ������д }
//        procedure GetSensorDatas(ASensor: string; var ds: TClientDataSet; var
//            ASensorType: Integer);
//        { ����ָ�����ڻ���ӽ�ָ�����ڵ�ָ��������������ǲ���ֵҲ������������ }
//        function GetSensorDataCloseToDT(ASensor, ADataName: string; ASubID:
//            Integer;
//            ADT: TDateTime; var AValue: Double): Boolean; overload;
//        function GetSensorDataCloseToDT(SSID, ASubID: Integer; ADataName:
//            string;
//            ADT: TDateTime; var AValue: Double): Boolean; overload;
//
//        procedure DeleteMultiSensorDefine(ASSID: Longint);
//        procedure DeleteMultiValueDefine(ASSID: Longint);
//        { ɾ�����ݼ�¼������ֵ�������� }
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
//        { ���ؼ�¼ID }
//        function RecordExists(ASQL: string): Boolean;
//        function PDRecID(ADT: TDateTime; ASensorID, ASubID: Longint): Longint;
//        { �������������������� }
//        procedure ListSensorGroups(Tree: TTreeNodes; APrivacy: Integer;
//            bFavorite: Boolean = False);
//        { �г�����. CanEditΪFalse���г������ܷ��ʵ��飬ΪTrueֻ�г��ܱ༭���� }
//        procedure GetGroupList(APrivacy: Integer; AList: TStrings; CanEdit:
//            Boolean = False);
//        { ��һ�������뵽ĳ���� }
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
//        { ������������ }
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
//        { ��������״̬ }
//        function UpdateMeterState(MeterID: Integer; AttLevel, CheckRuleID:
//            Integer): Boolean; overload;
//        function UpdateMeterState(MeterID: Integer; AddInfo, Annotation: string):
//            Boolean; overload;
//        function UpdateMeterState(MeterID: Integer; Valid: Boolean; InvalidDate:
//            TDateTime; BeenReplaced: Boolean): Boolean; overload;
//        function UpdateMeterState(MeterID: Integer; LaidDate, StdDate, InitDate:
//            TDateTime): Boolean; overload;
//        { ȡ����ParamStr }
//        function GetMeterParamStr(AID: Integer): string;

    end;

implementation

end.

