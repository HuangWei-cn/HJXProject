{ -----------------------------------------------------------------------------
 Unit Name: uReg_BuilIn_DMTreePanel
 Author:    黄伟
 Date:      08-九月-2016
 Purpose:   本单元是测点树插件注册单元
            本单元将插件注册为“内置”插件，用于调试插件功能。一旦插件设计完毕，
            可用uReg_Plugin_DBTreePanel单元替代本单元，再建立一个DLL工程文件
            就行了。
 History:
----------------------------------------------------------------------------- }

unit uReg_BuilIn_DMTreePanel;

interface

implementation

uses
    System.SysUtils, System.Classes, uIAppServices, uIFuncCompManager, uFuncCompTypes, uIHost,
    ufraDMTreePanel;

var
    CompReg  : PFuncCompRegister;
    App      : IPSMISAppServices;
    fraDMTree: TfraDMTreePanel;
    Host: IHost;

function InitComp(AppServices: IPSMISAppServices): Boolean; stdcall;
begin
    App := AppServices;
    supports(App.Host, ihost, Host);
    fraDMTree := TfraDMTreePanel.Create(host.HostApp);
    host.SetMeToLeftPanel('测点列表','测点列表',fraDMTree);
    //ifd := app.FuncDispatcher as ifunctiondispatcher;
    Result := true;
end;

procedure RegistBuildInComp;
begin
    New(CompReg);
    CompReg^.FuncCompType := fctFuncComp;
    CompReg^.PluginType := ptBuildIn;
    CompReg^.RegisterName := 'DesignPointTreePanel';
    CompReg^.Requires := '';
    CompReg^.Version := '1.0.0';
    CompReg^.DateIssued := '2016-9-8';
    CompReg^.Initiated := False;
    CompReg^.Description := '测点树插件';
    @CompReg^.InitProc := @InitComp;
    CompReg^.UnRegistProc := nil;

    //注意：下面的注册方式只有buildin模式才能使用，因为BuildIn模式的注册单元所包含的uIFuncCompManager
    //单元中的公用变量IFuncCompManager可被BuildIn插件访问。
    if Assigned(IFuncCompManager) then
        IFuncCompManager.RegisterEntry(CompReg);

    { 若是外部插件，比如DLL或是Package，需要export一个注册方法，由主程序调用，调用时将
      IFuncCompManager传递给插件 }
end;

initialization

RegistBuildInComp;

finalization

if Assigned(CompReg) then
    Dispose(CompReg);
//Pointer(App) := nil;
Pointer(Host) := nil;   //不加此句，将出现内存泄露

end.
