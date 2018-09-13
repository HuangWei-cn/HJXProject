{ -----------------------------------------------------------------------------
 Unit Name: uIAppServices
 Author:    Administrator
 Date:      08-十二月-2012
 Purpose:   应用服务接口，提供功能件所必须的其他接口
 History:
    2013-01-01
        注册功能件到主菜单等方法转移到IHost接口中，在AppServices中将不再使用，
        而IHost接口并不编译到PSMISCommon.bpl，因此Host的方法可以经常修改。
    2016-7-28
        增加了RegistOpenDBManProc、OpenDatabaseManager方法，由数据访问插件在
        加载时调用该方法注册打开数据连接界面方法。因为按照原先的插件加载及初
        始化流程，只有当数据连接建立之后（即连接到数据库之后）才会初始化各个
        插件，而当数据访问功能也采取插件形式时，就会造成无法连接数据库的情形。
        数据访问插件包含了针对特定数据库平台的访问、连接、维护、管理功能。
    2018-05-23
        又把这个插件系统看了半天，现在回想起一点了。本接口、IfuncCompManager
        接口是被所有插件必须引用的。且AppServeces和FuncCompManager的实例化
        单元是主体程序工程文件中排名第二、第三的单元，第一个是ShareMem单元。
        AppServices和FuncCompManager的接口变量是全局的，且他们的实例也是全局
        的，只是在插件中应该只使用接口对象而不是直接使用实例对象。这两个单元
        相互引用，只不过App接口对FuncCompManager的引用是隐藏的，当访问者请求
        调度器、对象、功能件时，App实例将调用FuncCompManager实例去查找并返回。
        各个功能件在注册插件时向FuncCompManager注册，由它初始化；在注册功能
        时则向各个调度器注册功能函数或方法，比如基本的FunctionDispacher。当然
        也可以向其他指定的调度器进行注册，比如数据编辑调度器、绘图调度器、报表
        调度器等等。由于可以扩展各种不同的调度器，本插件系统就具备了极大的扩
        展能力。比如在本程序中使用插件系统，就是为了能适应不同的数据库类型，
        适应各类不同的数据报表、五花八门的绘图能力。通常来说，一个功能件在设
        计时就应当知道它需要怎样的调度器，已经存在的基本功能件需要哪些功能、
        哪些功能扩展可由本插件提供，等等。
----------------------------------------------------------------------------- }

unit uHJX.Intf.AppServices;

interface

uses
    SysUtils, Classes, Controls, {uIClientDatas} uHJX.Intf.Datas, {uIProjectGlobal}
    uHJX.Intf.ProjectGlobal;

type
    TCallCompMethod = procedure(Sender: TObject) of object;

    IHJXAppServices = interface(IInterface)
        ['{41F58DC3-62E1-4493-99E6-939D7C09DE8B}']
        { 对于ClientDatas有两个方法，一个是返回TObject，一个是返回IClientDatas，
          使用两种方法的原因是dmClient可能会有多个接口，对于非IClientDatas的调
          用者可使用GetClientDatas，自行取出所需的接口 }
        function GetClientDatas: TObject;
        // function GetClientDatasInterface: IClientDatas;
        function GetClientDatasInterface: IClientFuncs;
        function GetProject: IHJXProject;
        function GetGlobalDatas: IHJXProjectGlobalDatas;
        /// <summary>获取一个指定名称的调度器接口。系统在扩展时，通常采用调度器
        /// 进行功能扩展，以便于发展出一套另成系统、调用规则的功能组。
        /// </summary>
        function GetDispatcher(ADispatcherName: string): TObject;
        function GetFunctionComp(ACompName: string): IInterface;
        function GetFuncCompClass(AClassName: string): TClass;
        function GetFuncCompClassInstance(AClassName: string): TObject;
        function GetComponent(ACompName: string): TObject;
        /// <summary>用于获得IFunctionDispatcher接口，这是与IClientDatas同等重要的接口，
        /// 提供了常用的功能，以及其他功能模块在该接口注册的功能调用入口</summary>
        function GetFuncDispatcher: IInterface; // 这个接口重要性几乎等同于dmClient
        function GetApplication: TObject;       // 主程序的Application对象
        function GetHost: TObject;              // 返回主程序的MainForm对象
        function GetMeters: TObject;            // 仪器集合
        function GetMeterGroups: TObject;       // 仪器组集合
        function GetDSNames: TObject;           // 数据名称集合
        function GetLayouts: TObject;           // 分布图集合
        function GetTemplates: TObject;         // 模板集合

        function Logged: Boolean;

        procedure RegisterClientDatas(AClientDatas: TObject);
        procedure ReleaseClientDatas;
        { 2016-7-28 注册打开数据连接界面的方法 }
        procedure RegisterOpenDBManProc(AProc: TProcedure);

        { 设置 }
        procedure SetProject(AProject: IHJXProject);
        procedure SetGlobalDatas(AGD: IHJXProjectGlobalDatas);

        //2018-09-13 将下面5个Set...添加到接口中
        procedure SetMeters(MeterList: TObject);
        procedure SetMeterGroups(MeterGroupList: TObject);
        procedure SetLayouts(ALayoutList: TObject);
        procedure SetDSNames(DSNameList: TObject);
        procedure SetTemplates(ATmpl: TObject);

        { 2016-7-28 }
        procedure OpenDatabaseManager;

        { 事件，产生事件的功能件调用这些方法，由AppServices传播到注册需求者 }
        procedure OnLogin(Sender: TObject);
        procedure OnLogout(Sender: TObject);
        procedure OnRemoteConnect(Sender: TObject);
        procedure OnRemoteDisconnect(Sender: TObject);
        procedure OnNotifyEvent(AEvent: string; Sender: TObject);
        /// <summary>插件通过调用IAppServices.ProcessMessage暂时将控制权交给主程序的Application，
        /// 以免界面停止响应。</summary>
        procedure ProcessMessages;

        { 注册事件需求者 }
        /// <summary>当系统发生某件事情时，通知注册者。比如，当仪器被删除时，通知仪器列表作出响应
        /// 从列表中删除该仪器；或当数据库关闭、更新时，通知某些敏感模块发生了这些事情。需要获得
        /// 事件的模块可在此注册事件的名称及通知消息入口(回调方法)。
        /// </summary>
        /// <remarks>
        /// 系统约定了系列基本事件。随着功能的逐渐完善，那些成为标准功能的模块也可能会产生自己的
        /// 事件，这些新事件也将逐渐被加入到标准事件中。
        /// </remarks>
        procedure RegEventDemander(DemandEvent: string; OnEvent: TNotifyEvent);

        { properties }
        // property ClientDatas: IClientDatas read GetClientDatasInterface;
        property ClientDatas: IClientFuncs read GetClientDatasInterface;
        property Project: IHJXProject read GetProject;
        property GlobalDatas: IHJXProjectGlobalDatas read GetGlobalDatas;
        property Application: TObject read GetApplication;
        property Host: TObject read GetHost;
        property FuncDispatcher: IInterface read GetFuncDispatcher;
        /// <summary>仪器集合</summary>
        property Meters: TObject read GetMeters;
        /// <summary>仪器组集合</summary>
        property MeterGroups: TObject read GetMeterGroups;
        property DSNames: TObject read GetDSNames;
        property Layouts: TObject read GetLayouts;
        property Templates: TObject read GetTemplates;
    end;

var
    // IApplicationServices: IHJXAppServices;
    { IAppServices是在整个程序中传递的核心服务。所有功能件通过访问这个服务获得其他功能件提供的功能，
      用这种方法实现各个模块之间的解耦。 }
    IAppServices: IHJXAppServices;

implementation

initialization

finalization

// IApplicationServices := nil;
end.
