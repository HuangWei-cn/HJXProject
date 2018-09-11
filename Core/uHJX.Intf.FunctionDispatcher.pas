{ -----------------------------------------------------------------------------
 Unit Name: uIFunctionDispatcher
 Author:    Administrator
 Date:      2016-7-27
 Purpose:   ��װ���ܵ��������μ�uFunctionDispatcher��Ԫ��
            �������������˼����ض��Ĺ��ܣ���һ��ͨ�÷�������
            ÿ������������һ����Ԫ��һ��������ܼ��ṩ��Ҳ��������һ��������
            �ṩ(��EditorDispatcher�����ṩEditSensorParams����)�������߲��ع�
            �ľ�����˭��ִ�С�

            FunctionDispatcher����ע�ṫ�÷����͹��̣�����������������Խ�����
            �Ĺ��÷���ע�ᵽ��������߿��Խ�ͨ��IFunctionDispatcher���ܷ���
            ���������ܡ�������༭�������Ϳ���ע��EditDesignPoint, EditMeter
            ���������ݱ༭������ע��EditData�����������߽���Ҫֱ��һ����ڼ��ɡ�

            ��һ��������д����װ��������������������֪������Щ����Ĺ��ܣ���ֻ
            ��Ҫ�ύ����ķ�����������ṩ�Ĳ�����װ�������Զ���ƥ��Ĺ���ע��
            �������ߵĹ������򵯳��˵��С�

            ͨ�����ܵ������������������չӦ�á�
 History:   2013-01-04
            Ŀǰ��ע�᷽����������Ʋ�֧�ַ��ض������ͣ���Ҫ���ԸĽ���

            2016-7-27
            ����DatabaseManager�������÷����������ݿ����ӹ�����棬�û��ڴ˴���
            �����ӡ��Ͽ����ݿ⡣

            2018-06-05
            1. �޸�TMethodByStr����������������AOwner, AContainer���������Ӳ��������������������ṩ
            �ߴ�����ĳ��������������ҪOwner��Container�����͵���������ʾ����ͼ�η�������������ߣ�
            �÷���ִ�к󽫴�����ʾ�����ߵ�Frame�����FrameҪ��ϵ��������У�����ҪOwner��Container��
            2. �ӿ�������ShowDataGraph������������ʾ�����ߡ�ʸ��ͼ����бͼ�ȣ�ȡ��ԭDrawTrendLine
            �����������ӿ��е�ShowDataGraph����ʵ������ͼ�ε������ṩ��ͼ�ε�������������������ת��
            ��������ע��Ķ�Ӧ�������͵Ļ�ͼ����ȥִ�У���ת�������Ρ�
----------------------------------------------------------------------------- }

unit uHJX.Intf.FunctionDispatcher;

interface

uses
    Classes, Types;

type
    { ============================================================================================ }
    { �����¼�����������紫�ݹ������̣�������ʾ }
    TDoingProgressEvent = procedure(ATotal, ANow: Integer) of object;

    { ע��Ĺ��ܣ����ڷ�װ�Ĺ���������Լ���������ע�ᵽ�������� }
    { �����/���������� }
    // 2018-06-05 ��������������AOwner��AContainer��ǰ�߱�ʾӵ���ߣ�����Ϊ��������Ϊ������ִ�н��
    // �п����Ǵ���һ���������һ��Frame�����Frame������ǵ���ʽ�ģ��ͱ�������������һ������֮����
    // AContainer�����������Ĵ�����AOwner�������������Frame�����磺������������ʾ������ͼ�Σ�
    // ����Ҫ��ʾ�����ĸ���ͼ�ε�Frame��
    // 2018-06-06 ȥ��AOwner�������������������Ϊ��Ҫһ��Owner,�����ѡ��Container��Container.Owner��
    // �������Ҫ�������������Ҳ�����á�
    TMethodByStr = procedure(AStr: string; AContainer: TComponent = nil) of object;

    { �༭�����ù��̣��˷�Method�����������Ҫ���ⴴ���༭���Ĵ��� }
    TProcByStr = procedure(AStr: string);
    { ������/������������ASSList����Ҫ����Ĳ���б� }
    // TFuncMultiSensorsProc = procedure(ASSList: TStrings) of object;

    { ��TStringsΪ�����ķ����͹��� }
    TMethodByStrings = procedure(AStrings: TStrings) of object;
    TProcByStrings   = procedure(AStrings: TStrings);

    { ��TListΪ�����ķ����͹��� }
    TMethodByList = procedure(AList: TList) of object;
    TProcByList   = procedure(AList: TList);

    { ���Ϊ�ַ������鴦���� }
    TMethodByStrArray = procedure(Names: TStringDynArray) of object;
    TProcByStrArray   = procedure(Names: TStringDynArray);

    { ���ΪInteger���鴦���� }
    TMethodByIntArray = procedure(IDs: TIntegerDynArray) of object;
    TProcByIntArray   = procedure(IDs: TIntegerDynArray);

    { �������ID�Ķ�����¼�ķ��� }
    TMethodByID = procedure(AID: Integer) of object;
    TProcByID   = procedure(AID: Integer);

    //TMethodByAny = procedure(V) of object;
    //TProcbyAny   = procedure(V);

    { �޲�������, ����ˢ��ʲô�� }
    TMethodNoneArg = procedure of object;
    { ͨ�÷��� }
    TGeneralProc = procedure(InParams: array of Variant;
        var OutParams: array of Variant);
    TGeneralMethod = procedure(Sender: TObject; InParams: array of Variant;
        var OutParams: array of Variant) of object;

    { ͨ�ú������������ض��� }
    TGeneralCompFunc = function(AOwner: TComponent; InParams: array of Variant):
        TComponent;

    { ������� }
    TArgType = (atNone, atStr, atStrings, atList, atStrArray, atIntArray,
        atID, atVariant, atVariantArray, atUndefine);
// TGeneralFunction = function(InParams: array of Variant;
// var OutParams: array of Variant): TComponent;
    { ============================================================================================ }

    IFunctionDispatcher = interface(IInterface)
        ['{8B5D1907-B1C8-4103-A00C-5BA5875C7D42}']
        { �������ض����͵Ĺ��ܵ��� }
        procedure ShowDMInfos(ADesignName: string);
        { 2018-06-05 ��������������ȡ�������DrawTrandLine��DrawMultiTrendLine }
        procedure ShowDataGraph(ADesignName: string; AContainer: TComponent = nil);
        { 2018-06-06 ��������������������֮��ģ����ָ����AContainer��Frame�������� }
        procedure PopupDataGraph(ADesignName: string; AContainer: TComponent = nil);
        // �ɷ���������ShowDataGraphȡ��
        procedure DrawTrendLine(ADesignName: string);
        // �ɷ���������ShowDataGraphȡ��
        procedure DrawMultiTrendLine(ASensors: TStrings);

        procedure RefreshDMList;
        procedure RefreshGroup;
        // �ɷ���������ShowDataȡ��
        procedure BrowseSensorData(ADesignName: string);
        { 2018-06-07 }
        procedure ShowData(ADesignName: string; AContainer: TComponent = nil);
        procedure PopupDataViewer(ADesignName: string; AContainer: TComponent = nil);

        procedure EditDesignParams(ADesignName: string);
        procedure EditSensorParams(ADesignName: string);
        procedure EditSensorData(ADesignName: string);
        { 2016-7-27����4�������ӿ���ʱ���ṩ }
        // procedure AddPointToFavorite(ADesignName: string);
        // procedure AddPointToGroup(ADesignName: string);
        // procedure GroupBrief(ASensors: TStrings);
        // procedure SetupMeter(AID: Integer); //�Կ�Meter����ѯParams��Update

        { ͨ�õĹ��ܵ��� }
        procedure GeneralProc(AProc: string; Sender: TObject;
            InParams: array of Variant; var OutParams: array of Variant);
        { ͨ�÷��ض���������� }
        function GeneralCompFunc(AFunc: string; AOwner: TComponent;
            InParams: array of Variant): TComponent;

        { ����ͨ�ù��̵�ַ }
        function GetGeneralProc(AProc: string): TGeneralProc;
        { ����ͨ�÷�����ַ }
        function GetGeneralMethod(AMethod: string): TGeneralMethod;

        { ָ�����͵�ͨ�÷������̵��ã����������������ƺʹ������ȷ����ε��� }
        procedure CallFunction(FuncName: string; AStr: string); overload;
        procedure CallFunction(FuncName: string; AStrings: TStrings); overload;
        procedure CallFunction(FuncName: string; AList: TList); overload;
        procedure CallFunction(FuncName: string; StrArray: TStringDynArray); overload;
        procedure CallFunction(FuncName: string; IntArray: TIntegerDynArray); overload;
        procedure CallFunction(FuncName: string; AID: Integer); overload;
        procedure CallFunction(FuncName: string); overload;
        procedure CallFunction(FuncName: string; Sender: TObject; InParams: array of Variant;
            var OutParams: array of Variant); overload;

        { ע��------------------------------------------------------ }
        procedure RegistFuncShowDMInfos(AFunc: TMethodByStr);
        procedure UnRegisterFuncShowDMInfors;

        procedure RegistFuncRefreshDMList(AFunc: TMethodNoneArg);
        procedure UnRegisterFuncRefreshDMList;

        procedure RegistFuncBrowseSensorData(AFunc: TMethodByStr);
        procedure UnRegisterFuncBrowseSensorData;

        procedure RegistFuncEditData(AFunc: TMethodByStr);
        procedure UnRegisterFuncEditData;

        procedure RegistFuncRefreshGroup(AFunc: TMethodNoneArg);
        procedure UnRegisterFuncRefreshGroup;

        procedure RegistFuncAddToFavorite(AFunc: TMethodByStr);
        procedure UnRegisterFuncAddToFavorite;

        procedure RegistFuncAddToGroup(AFunc: TMethodByStr);
        procedure UnRegisterFuncAddToGroup;

        procedure RegistFuncSetupMeter(AFunc: TMethodByID); overload;
        procedure RegistFuncSetupMeterProc(AProc: TProcByID); overload;
        procedure UnRegisterFuncSetupMeter;

        { ע�������༭��ʱ�ڴ˵��ȣ����ս���uSensorTypeProc��Ԫ�е�
          TSensorParamEditorList���������� }
        procedure RegistFuncDesignParamEdit(AFunc: TMethodByStr);
        procedure RegistFuncSensorParamEdit(AFunc: TMethodByStr);

        procedure RegistFuncDrawTrendLine(AFunc: TMethodByStr);

        procedure RegistFuncDrawMultiTrendLine(AFunc: TMethodByStrings
            { TFuncMultiSensorsProc } );
        procedure UnRegisterFuncDrawMultiTrendLine;

        procedure RegistFuncGroupBrief(AFunc: TMethodByStrings);
        procedure UnRegisterFuncGroupBrief;

        { 2018-06-06 ע���������� }
        procedure RegistFuncShowDataGraph(AFunc: TMethodByStr);
        procedure RegistFuncPopupDataGraph(AFunc: TMethodByStr);
        procedure RegistFuncPopupDataViewer(AFunc: TMethodByStr);
        procedure RegistFuncShowData(AFunc: TMethodByStr);

        { ͨ�÷���ע�� }
        procedure RegistGeneralProc(AProcName: string; AProc: TGeneralProc);
        procedure RegistGeneralMethod(AMethodName: string; AMethod:
            TGeneralMethod);
        procedure RegistGeneralCompFunc(AFuncName: string; AFunc:
            TGeneralCompFunc);
        { ע��ͨ�÷��������� }
        procedure UnRegisterGeneral(AGeneralFuncName: string);
        procedure UnRegisterGeneralCompFunc(AFuncName: string);

        { ͨ�ã���ָ�����ͷ���ע�� }
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByStr); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByStrings); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByList); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByStrArray); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByIntArray); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByID); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodNoneArg); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TGeneralMethod); overload;
        { ָ������ͨ�ù���ע�� }
        procedure RegisterProc(AFuncName: string; AProc: TProcByStr); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByStrings); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByList); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByStrArray); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByIntArray); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByID); overload;
        procedure RegisterProc(AFuncName: string; AProc: TGeneralProc); overload;
        { ע��������Щע�� }
        procedure UnRegistMethodProc(AName: string);
        { ����ĳ�����Ƿ���ע�ᣬ�������߾�������Ĳ˵��빤���� }
        function HasProc(AProcName: string): Boolean; overload;
        function HasProc(AProcName: string; ArgType: TArgType): Boolean; overload;
        function HasFunction(AFuncName: string): Boolean;
    end;

implementation

end.
