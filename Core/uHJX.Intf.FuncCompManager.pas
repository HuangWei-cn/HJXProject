{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Intf.FuncCompManager
 Author:    黄伟
 Date:      11-九月-2018
 Purpose:   功能组件、插件管理器
            本系统的核心单元之一，用于插件、调度器将自身注册到系统中。
            本接口的实现单元还包含了访问这些插件的方法、各插件初始化方法，
            在主程序启动后对这些注册件进行初始化，完成他们之间的相互调用
            指针赋值。
 History:
----------------------------------------------------------------------------- }

unit uHJX.Intf.FuncCompManager;

interface

uses
    system.SysUtils, {Classes,}{uIAppServices} uHJX.Intf.AppServices, uHJX.Core.FuncCompTypes;

type
    EPluginLoadError = class(Exception);

    /// <summary>
    /// 功能件管理器接口，供插件、功能件等需要和主程序解耦的模块使用。
    /// <para>
    /// 每个提供独立功能的模块，都向本管理器进行注册。在填写了注册信息后，可以使用相应的方法进行
    /// 注册。如调度器用RegisterDispatcher方法，插件用RegisterEntry方法等等。本接口主要面向和主程序
    /// 解耦的模块、插件。
    /// </para>
    /// <para>主接口AppServices则访问本接口的实现类TFunctionComponentManager，通过该类实例向程序
    /// 其他部分提供调度器、组件、对象、方法等。
    /// </para>
    /// </summary>
    IFunctionComponentManager = interface(IInterface)
        ['{CFBA9B03-A2D7-4F7E-A940-33D326ECAD1A}']
        { 注册调度器 }
        procedure RegisterDispatcher(AFCType: PFuncCompRegister; ADispatcher: TObject);
        { 注册类 }
        procedure RegisterClass(AFCType: PFuncCompRegister; AClass: TClass);
        { 注册组件实例 }
        procedure RegisterComponent(AFCType: PFuncCompRegister; AComponent: TObject);
        { 注册函数、过程、方法，只有注册信息，东西由相应的调度器管理 }
        procedure RegisterEntry(AFCType: PFuncCompRegister);
    end;

    { 所有插件的注册过程名为:RegisterFuncComp }
    TRegistProcedure = procedure(Manager: IFunctionComponentManager); stdcall;

var
    IFuncCompManager: IFunctionComponentManager;

implementation

initialization

finalization

// IFuncCompManager := nil;

end.
