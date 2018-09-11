{ -----------------------------------------------------------------------------
 Unit Name: uIHost
 Author:    Administrator
 Date:      01-一月-2013
 Purpose:   Host接口，有一些必备的方法供其他功能件调用
            凡准备作为MainForm的窗口组件，都应当具备IHost接口，这样其他功能件
            插件可以自行将自己插入到Host的各个界面、主菜单中，实现功能调用。
 History:
----------------------------------------------------------------------------- }

unit uHJX.Intf.Host;

interface

uses SysUtils, Classes, Controls, Forms, {uIAppServices}uHJX.Intf.AppServices;

type
    IHost = interface(IInterface)
        ['{DD04FCFB-CEBE-4C03-8B75-F69587FD2205}']
        function HostMainMenu: TComponent;
        function HostPager: TComponent;
        function HostApp: TComponent;
        function HostActivePage: string;

        { ----------------主菜单相关－－－－－－－－－－－－－－－－ }
        { 注册组件到主菜单
          功能件注册到Host菜单有两种，一种是方法调用，一种是无参过程调用。出现
          在Host主菜单中的功能件，应是功能完整、相对独立的部件或Frame，或Form。 }
        function SetMeToMainMenu(ACategory, AItem, ASubItem: string; CallProc: TProcedure)
            : Boolean; overload;
        function SetMeToMainMenu(ACategory, AItem, ASubItem: string; CallMethod: TCallCompMethod)
            : Boolean; overload;
        { --------------- 主工具条相关----------------------------- }
        { 注册组件到主工具条 }
        function SetMeToMainToolbar(ACategory, AItem, ASubItem: string; CallProc: TProcedure)
            : Boolean; overload;
        function SetMeToMainToolbar(ACategory, AItem, ASubItem: string; CallMethod: TCallCompMethod)
            : Boolean; overload;

        { -----------------主功能页相关--------------------------- }
        { 注册组件到主PageControl，Host将为功能件分配一个持久的Page。返回值为Host
          为其创建的Page对象。注册的Page不会随着page页上的关闭按钮而关闭，而是随着
          Pagecontrol的释放而释放 }
        function SetMeToMainPager(APageCaption: string; AClient: TComponent;
            TabVisible: Boolean = False): TComponent; overload;
        function SetMeToMainPager(AClientClass: TWinControlClass; APageCaption: string;
            TabVisible: Boolean = False): TComponent; overload;

        { 请求一个Page，此page为临时的，可随时释放的 }
        function RequestPage(APageCaption: string; AClient: TComponent): TComponent;
        { 请求将指定的Page至于当前活动的Page，通常是注册到Pager的功能件被调用时，
          请求将自身所在的page称为ActivePage }
        procedure SetPageActive(APage: TComponent); overload;
        procedure SetPageActive(ACaption: String); overload;
        { 是否存在指定Caption的Page }
        function HasPage(ACaption: string; SetActive: Boolean = False): Boolean;

        { ----------------左侧面板相关---------------------------- }
        { 将功能件安置在左侧面板的主功能区 }
        function SetMeToLeftPanel(ACategory, ACaption: string; AClient: TComponent): TComponent;
        { 将功能件安置在左侧面板下方的信息显示区 }
        function SetMeToLBPanel(ACategory, ACaption: string; AClient: TComponent): TComponent;

        { --------------- 其他----------------------- }
        function OnClientFormClose: TCloseEvent;
    end;

implementation

end.
