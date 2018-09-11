{-----------------------------------------------------------------------------
 Unit Name: uFuncCompTypes
 Author:    Administrator
 Date:      10-十二月-2012
 Purpose:   功能件定义结构
            每个功能件在注册时都需要提供这个结构，每个插件至少提供一个注册结
            构，有时一个插件包含多个功能件，则可以为每个功能件提交一个对应的
            注册体。

            Requires：是功能件所必须的服务或功能件，列出的功能件必须存在并且
            先行初始化，否则功能件不能正常工作。

            服务相关：
            主要用于插件之间的自动集成和即时装配。
            每个功能件可以视为服务提供者和服务需求者，它可以提供一个或多个服
            务，也可能需要或被插入多个其他服务。如测点列表面板，它提供了测点
            列表服务，同时允许一系列其他服务诸如过程线、观测数据、参数编辑等
            插入其中，但它也会拒绝某些服务如显示观测日志、时间线、环境量编辑
            等的插入。

 History:
        2018-05-23
            改了个名字；
-----------------------------------------------------------------------------}
{ 2016-7-27
    1、TFuncCompType增加了fctInterface类型；
    2、增加了插件设置方法定义：TPluginSetupProcedure；
    3、TFunctionComponentRegister结构体增加了SetupProc项;

}
unit uHJX.Core.FuncCompTypes;

interface
uses
    {uIAppServices}uHJX.Intf.AppServices;
type
    { 功能件类型 }
    TFuncCompType = (fctBase, fctInterface, fctDispatcher, fctFuncComp, fctClass, fctAssistent, fctAgent);
    TPluginType = (ptBuildIn, ptDLL, ptPackage);
    TInitProcedure = function(AppServices: IHJXAppServices): Boolean; stdcall;
    TPluginSetupProcedure = function: Boolean; stdcall;
    { 所有插件的注销过程名为: UnregisterFuncComp }
    TUnRegistProcedure = procedure; stdcall;
    { 功能件注册体 }
    TFunctionComponentRegister = record
        FuncCompType: TFuncCompType;
        PluginType: TPluginType;
        //插件初始化方法
        InitProc: TInitProcedure;
        //插件设置方法，用于运行期用户设置插件的一些参数。这些参数都将保存在程序的配置文件中
        SetupProc: TPluginSetupProcedure;
        //插件的注销方法。一般来说，插件不需要这个方法。但是如果需要在运行期卸载插件，就需要它了。
        UnRegistProc: TUnRegistProcedure;
        Initiated: Boolean;
        RegisterName: string;
        Requires: string; //必要的服务功能，格式：name1, name2, name3....
        { 服务相关描述 }
        ServiceNames: string; //本插件提供的服务：ServiceName1, ServiceName2,...
        ServiceType: string;  //服务类型: ItemList, DataContent,
        PermitServices: string; //本插件允许的服务: Name1,Name2,Name3...
        DenyServices: string; //本插件拒绝的服务: Name1,Name2,Name3...
        InterfaceType: string; //界面类型：Frame, Form, Component, None之一。
        { TODO:服务入口描述 }
        { 版本及描述相关------- }
        Version: string; //代码版本，对于非插件功能件用这个参考版本
        DateIssued: string; //发布日期，对于非插件功能件用次作为参考
        Description: string; //Widestring;
    end;
    PFuncCompRegister = ^TFunctionComponentRegister;

implementation
{   ServiceType说明；
    ItemList -- 项目列表，如测点列表、仪器列表、文档列表等等
    DataContent -- 数据内容，如数据表、过程线等
    Document -- 如布置图、上传的报告等
    Editor -- 编辑器
    Assistent， Agent -- 助手、代理，是没有界面的处理过程或方法

}

end.
