{ -----------------------------------------------------------------------------
 Unit Name: uIFunctionDispatcher
 Author:    Administrator
 Date:      2016-7-27
 Purpose:   封装功能调度器，参见uFunctionDispatcher单元。
            本调度器设置了几个特定的功能，和一个通用方法调用
            每个方法可以由一个单元、一个插件或功能件提供，也可以由另一个调度器
            提供(如EditorDispatcher可以提供EditSensorParams方法)。调用者不必关
            心具体由谁来执行。

            FunctionDispatcher可以注册公用方法和过程，因此其他调度器可以将自身
            的公用方法注册到这里，调用者可以仅通过IFunctionDispatcher就能访问
            到多数功能。如参数编辑调度器就可以注册EditDesignPoint, EditMeter
            方法，数据编辑器可以注册EditData方法，调用者仅需要直到一个入口即可。

            下一步，将编写功能装配器，调用者无需事先知道有哪些具体的功能，它只
            需要提交允许的服务和它所能提供的参数，装配器将自动将匹配的功能注入
            到调用者的工具条或弹出菜单中。

            通过功能调度器、插件，可以扩展应用。
 History:   2013-01-04
            目前的注册方法、过程设计不支持返回对象类型，需要加以改进。

            2016-7-27
            增加DatabaseManager方法，该方法启动数据库连接管理界面，用户在此窗体
            中连接、断开数据库。

            2018-06-05
            1. 修改TMethodByStr方法参数，增加了AOwner, AContainer参数。增加参数的意义在于若方法提供
            者创建了某个组件，该组件需要Owner和Container。典型的例子是显示数据图形方法，比如过程线，
            该方法执行后将创建显示过程线的Frame，这个Frame要结合到主界面中，就需要Owner和Container。
            2. 接口增加了ShowDataGraph方法，用于显示过程线、矢量图、测斜图等，取代原DrawTrendLine
            方法。而本接口中的ShowDataGraph方法实例是由图形调度器提供，图形调度器根据仪器类型再转给
            调度器中注册的对应仪器类型的绘图方法去执行，即转包了两次。
----------------------------------------------------------------------------- }

unit uHJX.Intf.FunctionDispatcher;

interface

uses
    Classes, Types;

type
    { ============================================================================================ }
    { 进程事件，用于向外界传递工作进程，便于显示 }
    TDoingProgressEvent = procedure(ATotal, ANow: Integer) of object;

    { 注册的功能，用于封装的功能组件将自己的主方法注册到调度中心 }
    { 单测点/仪器处理方法 }
    // 2018-06-05 增加两个参数：AOwner和AContainer，前者表示拥有者，后者为容器，因为方法的执行结果
    // 有可能是创建一个组件，如一个Frame，这个Frame如果不是弹出式的，就必须在主界面有一个存身之处，
    // AContainer就是这个组件的存身处。AOwner则用于销毁这个Frame。例如：在主界面中显示的数据图形，
    // 就需要显示创建的各种图形的Frame。
    // 2018-06-06 去掉AOwner参数。如果被调用者认为需要一个Owner,则可以选择Container或Container.Owner，
    // 如果不需要，传递这个参数也不会用。
    TMethodByStr = procedure(AStr: string; AContainer: TComponent = nil) of object;

    { 编辑器调用过程，此非Method，以免出现需要另外创建编辑器的代码 }
    TProcByStr = procedure(AStr: string);
    { 多个测点/仪器处理方法，ASSList是需要处理的测点列表 }
    // TFuncMultiSensorsProc = procedure(ASSList: TStrings) of object;

    { 以TStrings为参数的方法和过程 }
    TMethodByStrings = procedure(AStrings: TStrings) of object;
    TProcByStrings   = procedure(AStrings: TStrings);

    { 以TList为参数的方法和过程 }
    TMethodByList = procedure(AList: TList) of object;
    TProcByList   = procedure(AList: TList);

    { 入参为字符串数组处理方法 }
    TMethodByStrArray = procedure(Names: TStringDynArray) of object;
    TProcByStrArray   = procedure(Names: TStringDynArray);

    { 入参为Integer数组处理方法 }
    TMethodByIntArray = procedure(IDs: TIntegerDynArray) of object;
    TProcByIntArray   = procedure(IDs: TIntegerDynArray);

    { 处理具有ID的对象或记录的方法 }
    TMethodByID = procedure(AID: Integer) of object;
    TProcByID   = procedure(AID: Integer);

    //TMethodByAny = procedure(V) of object;
    //TProcbyAny   = procedure(V);

    { 无参数方法, 比如刷新什么的 }
    TMethodNoneArg = procedure of object;
    { 通用方法 }
    TGeneralProc = procedure(InParams: array of Variant;
        var OutParams: array of Variant);
    TGeneralMethod = procedure(Sender: TObject; InParams: array of Variant;
        var OutParams: array of Variant) of object;

    { 通用函数方法，返回对象 }
    TGeneralCompFunc = function(AOwner: TComponent; InParams: array of Variant):
        TComponent;

    { 入参类型 }
    TArgType = (atNone, atStr, atStrings, atList, atStrArray, atIntArray,
        atID, atVariant, atVariantArray, atUndefine);
// TGeneralFunction = function(InParams: array of Variant;
// var OutParams: array of Variant): TComponent;
    { ============================================================================================ }

    IFunctionDispatcher = interface(IInterface)
        ['{8B5D1907-B1C8-4103-A00C-5BA5875C7D42}']
        { 以下是特定类型的功能调用 }
        procedure ShowDMInfos(ADesignName: string);
        { 2018-06-05 新增方法，用于取代下面的DrawTrandLine和DrawMultiTrendLine }
        procedure ShowDataGraph(ADesignName: string; AContainer: TComponent = nil);
        { 2018-06-06 新增方法，弹出过程线之类的，如果指定了AContainer则将Frame放置其中 }
        procedure PopupDataGraph(ADesignName: string; AContainer: TComponent = nil);
        // 旧方法，将被ShowDataGraph取代
        procedure DrawTrendLine(ADesignName: string);
        // 旧方法，将被ShowDataGraph取代
        procedure DrawMultiTrendLine(ASensors: TStrings);

        procedure RefreshDMList;
        procedure RefreshGroup;
        // 旧方法，将被ShowData取代
        procedure BrowseSensorData(ADesignName: string);
        { 2018-06-07 }
        procedure ShowData(ADesignName: string; AContainer: TComponent = nil);
        procedure PopupDataViewer(ADesignName: string; AContainer: TComponent = nil);

        procedure EditDesignParams(ADesignName: string);
        procedure EditSensorParams(ADesignName: string);
        procedure EditSensorData(ADesignName: string);
        { 2016-7-27以下4个方法接口暂时不提供 }
        // procedure AddPointToFavorite(ADesignName: string);
        // procedure AddPointToGroup(ADesignName: string);
        // procedure GroupBrief(ASensors: TStrings);
        // procedure SetupMeter(AID: Integer); //对空Meter，查询Params并Update

        { 通用的功能调用 }
        procedure GeneralProc(AProc: string; Sender: TObject;
            InParams: array of Variant; var OutParams: array of Variant);
        { 通用返回对象、组件函数 }
        function GeneralCompFunc(AFunc: string; AOwner: TComponent;
            InParams: array of Variant): TComponent;

        { 返回通用过程地址 }
        function GetGeneralProc(AProc: string): TGeneralProc;
        { 返回通用方法地址 }
        function GetGeneralMethod(AMethod: string): TGeneralMethod;

        { 指定类型的通用方法过程调用，本调度器根据名称和传入参数确定如何调用 }
        procedure CallFunction(FuncName: string; AStr: string); overload;
        procedure CallFunction(FuncName: string; AStrings: TStrings); overload;
        procedure CallFunction(FuncName: string; AList: TList); overload;
        procedure CallFunction(FuncName: string; StrArray: TStringDynArray); overload;
        procedure CallFunction(FuncName: string; IntArray: TIntegerDynArray); overload;
        procedure CallFunction(FuncName: string; AID: Integer); overload;
        procedure CallFunction(FuncName: string); overload;
        procedure CallFunction(FuncName: string; Sender: TObject; InParams: array of Variant;
            var OutParams: array of Variant); overload;

        { 注册------------------------------------------------------ }
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

        { 注：参数编辑暂时在此调度，最终将从uSensorTypeProc单元中的
          TSensorParamEditorList对象中启动 }
        procedure RegistFuncDesignParamEdit(AFunc: TMethodByStr);
        procedure RegistFuncSensorParamEdit(AFunc: TMethodByStr);

        procedure RegistFuncDrawTrendLine(AFunc: TMethodByStr);

        procedure RegistFuncDrawMultiTrendLine(AFunc: TMethodByStrings
            { TFuncMultiSensorsProc } );
        procedure UnRegisterFuncDrawMultiTrendLine;

        procedure RegistFuncGroupBrief(AFunc: TMethodByStrings);
        procedure UnRegisterFuncGroupBrief;

        { 2018-06-06 注册新增方法 }
        procedure RegistFuncShowDataGraph(AFunc: TMethodByStr);
        procedure RegistFuncPopupDataGraph(AFunc: TMethodByStr);
        procedure RegistFuncPopupDataViewer(AFunc: TMethodByStr);
        procedure RegistFuncShowData(AFunc: TMethodByStr);

        { 通用方法注册 }
        procedure RegistGeneralProc(AProcName: string; AProc: TGeneralProc);
        procedure RegistGeneralMethod(AMethodName: string; AMethod:
            TGeneralMethod);
        procedure RegistGeneralCompFunc(AFuncName: string; AFunc:
            TGeneralCompFunc);
        { 注销通用方法、过程 }
        procedure UnRegisterGeneral(AGeneralFuncName: string);
        procedure UnRegisterGeneralCompFunc(AFuncName: string);

        { 通用，但指定类型方法注册 }
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByStr); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByStrings); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByList); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByStrArray); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByIntArray); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByID); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodNoneArg); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TGeneralMethod); overload;
        { 指定类型通用过程注册 }
        procedure RegisterProc(AFuncName: string; AProc: TProcByStr); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByStrings); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByList); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByStrArray); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByIntArray); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByID); overload;
        procedure RegisterProc(AFuncName: string; AProc: TGeneralProc); overload;
        { 注销上述这些注册 }
        procedure UnRegistMethodProc(AName: string);
        { 查找某方法是否已注册，供调用者决定自身的菜单与工具条 }
        function HasProc(AProcName: string): Boolean; overload;
        function HasProc(AProcName: string; ArgType: TArgType): Boolean; overload;
        function HasFunction(AFuncName: string): Boolean;
    end;

implementation

end.
