{ -----------------------------------------------------------------------------
 Unit Name: uApplicationServices
 Author:    Administrator
 Date:      2016-7-27
 Purpose:   应用服务对象
            Host程序应引用PSMISAppServices，其他功能件应引用本对象的接口实例
            IApplicationServices。
 History:   2016-7-28
                增加了RegisterOpenDBManProc方法，允许数据接口插件注册数据连接
                管理界面；增加了OpenDatabaseManager方法，该方法调用数据连接插
                件中的数据连接管理界面。

            2018-05-23
                1、Logged方法的内容被注释掉了，直接返回结果True
----------------------------------------------------------------------------- }

unit uHJX.IntfImp.AppServices;

interface

uses
    SysUtils, Classes, Controls, {uIAppServices, uIClientDatas, uIProjectGlobal}
    uHJX.Intf.AppServices, uHJX.Intf.Datas, uHJX.Intf.ProjectGlobal;

type
    TProMsgs = procedure of object;

    THJXAppService = class(TInterfacedObject, IHJXAppServices)
    private
        { 基本的、必备的东西 }
        FApplication : TObject;
        FClientDatas : TObject;
        FIProject    : IHJXProject;
        FIGlobalDatas: IHJXProjectGlobalDatas;
        // FHostMenu      : TObject;
        // FHostToolbar   : TObject;
        // FHostPager     : TObject;
        FHost          : TObject;
        FFuncDispatcher: IInterface;
        { 2016-7-28 数据库连接管理方法 }
        FOpenDBManProc: TProcedure;
        { 事件请求者注册 }
        FEvtReqOnLogin     : TList;    // 需要登录成功事件插件
        FEvtReqOnLogout    : TList;    // 需要注销事件的
        FEvtReqOnConnect   : TList;    // 需要连接事件的
        FEvtReqOnDisconnect: TList;    // 需要断开事件的
        FEvtReqOnNotify    : TStrings; // 需要其他通知事件的
        FProcessMessages   : TProMsgs; // 用来令插件调用Application.ProcessMessage方法

        FMeters     : TObject;
        FMeterGroups: TObject;
        FDSNames    : TObject;
        FLayouts    : TObject;
        FTemplates  : TObject;

        procedure ClearAll;

        { 接口方法 }
        function GetClientDatasInterface: IClientFuncs;
        function GetProject: IHJXProject;
        function GetGlobalDatas: IHJXProjectGlobalDatas;
    public
        constructor Create;
        destructor Destroy; override;
        { 取dmClient对象 }
        function GetClientDatas: TObject;
        { 获取调度器 }
        function GetDispatcher(ADispatcherName: string): TObject;
        { 获取功能件接口 }
        function GetFunctionComp(ACompName: string): IInterface;
        { 获取功能件类 }
        function GetFuncCompClass(AClassName: string): TClass;
        { 获取功能件新实例 }
        function GetFuncCompClassInstance(AClassName: string): TObject;
        { 获取功能件实例 }
        function GetComponent(ACompName: string): TObject;
        { 取Host的Application }
        function GetApplication: TObject;
        { 返回Host，即Application.MainForm }
        function GetHost: TObject;
        { 返回IFunctionDispatcher }
        function GetFuncDispatcher: IInterface;
        { 返回仪器集合 }
        function GetMeters: TObject;
        function GetMeterGroups: TObject;
        function GetDSNames: TObject;
        function GetLayouts: TObject;
        function GetTemplates: TObject;

        { 登录状态 }
        function Logged: Boolean;

        procedure RegisterClientDatas(AClientDatas: TObject);
        procedure ReleaseClientDatas;
        { 2016-7-28 注册打开数据库连接管理界面的方法 }
        procedure RegisterOpenDBManProc(AProc: TProcedure);
        procedure OpenDatabaseManager;

        procedure SetProject(AProject: IHJXProject);
        procedure SetGlobalDatas(AGD: IHJXProjectGlobalDatas);
        procedure SetApplication(App: TObject);

        procedure SetMeters(MeterList: TObject);
        procedure SetMeterGroups(MeterGroupList: TObject);
        procedure SetLayouts(ALayoutList: TObject);
        procedure SetDSNames(DSNameList: TObject);
        procedure SetTemplates(ATmpl: TObject);

        { 事件，产生事件的功能件调用这些方法，由AppServices传播到注册需求者 }
        procedure OnLogin(Sender: TObject);
        procedure OnLogout(Sender: TObject);
        procedure OnRemoteConnect(Sender: TObject);
        procedure OnRemoteDisconnect(Sender: TObject);
        procedure OnNotifyEvent(AEvent: string; Sender: TObject);

        { 注册事件需求者 }
        procedure RegEventDemander(DemandEvent: string; OnEvent: TNotifyEvent);

        procedure ProcessMessages;
        { 注册 }
        { properties }
        property ClientDatas: IClientFuncs read GetClientDatasInterface;
        property Project: IHJXProject read GetProject;
        property GlobalDatas: IHJXProjectGlobalDatas read GetGlobalDatas;
        property Application: TObject read GetApplication;
        property Host: TObject read GetHost write FHost;
        property FuncDispatcher: IInterface read GetFuncDispatcher;

        property AppProcessMessages: TProMsgs read FProcessMessages write FProcessMessages;

    end;

var
    HJXAppServices: THJXAppService;

implementation

uses
    {uFuncCompManager} uHJX.IntfImp.FuncCompManager;

{ ----------------------------------------------------------------------------- }
constructor THJXAppService.Create;
begin
    inherited Create;
    FEvtReqOnLogin := TList.Create;
    FEvtReqOnLogout := TList.Create;
    FEvtReqOnConnect := TList.Create;
    FEvtReqOnDisconnect := TList.Create;
    FEvtReqOnNotify := TStringList.Create;
end;

{ ----------------------------------------------------------------------------- }
destructor THJXAppService.Destroy;
begin
    { 千万注意！！！如果在本对象中引用了接口，除非该对象没有在其他地方释放，否则
      必须在这里将引用的接口指针设置为nil，否则当设置接口为nil时，将引起Delphi试
      图释放该接口对象，如果该接口对象实际已释放，将出现一个错误 }
    try
        Pointer(FClientDatas) := nil;
        Pointer(FIProject) := nil;
        Pointer(FIGlobalDatas) := nil;
        Pointer(FFuncDispatcher) := nil;
        FOpenDBManProc := nil; // 2016-7-28
        ClearAll;
        FEvtReqOnLogin.Free;
        FEvtReqOnLogout.Free;
        FEvtReqOnConnect.Free;
        FEvtReqOnDisconnect.Free;
        FEvtReqOnNotify.Free;
    finally
        inherited;
    end;
end;

{ ----------------------------------------------------------------------------- }
procedure THJXAppService.ClearAll;
var
    i: Integer;
begin
    try
        for i := 0 to FEvtReqOnLogin.Count - 1 do
            Dispose(FEvtReqOnLogin[i]);
        for i := 0 to FEvtReqOnLogout.Count - 1 do
            Dispose(FEvtReqOnLogout[i]);
        for i := 0 to FEvtReqOnConnect.Count - 1 do
            Dispose(FEvtReqOnConnect[i]);
        for i := 0 to FEvtReqOnDisconnect.Count - 1 do
            Dispose(FEvtReqOnDisconnect[i]);
        for i := 0 to FEvtReqOnNotify.Count - 1 do
            Dispose(Pointer(FEvtReqOnNotify.Objects[i]));
    finally
    end;
end;

{ ----------------------------------------------------------------------------- }
procedure THJXAppService.RegisterClientDatas(AClientDatas: TObject);
begin
    FClientDatas := AClientDatas;
end;

procedure THJXAppService.ReleaseClientDatas;
begin
    Pointer(FClientDatas) := nil;
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.GetClientDatas: TObject;
begin
    Result := FClientDatas;
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.GetClientDatasInterface: IClientFuncs;
begin
    Result := nil;
    if Assigned(FClientDatas) then
        Supports(FClientDatas, IClientFuncs, Result);
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.GetProject: IHJXProject;
begin
    Result := FIProject;
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.GetGlobalDatas: IHJXProjectGlobalDatas;
begin
    Result := FIGlobalDatas;
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.GetDispatcher(ADispatcherName: string): TObject;
begin
    Result := FuncCompManager.GetDispatcher(ADispatcherName);
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.GetFunctionComp(ACompName: string): IInterface;
begin
    Result := nil;
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.GetComponent(ACompName: string): TObject;
begin
    Result := FuncCompManager.GetComponent(ACompName);
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.GetFuncCompClass(AClassName: string): TClass;
begin
    Result := FuncCompManager.GetClass(AClassName);
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.GetFuncCompClassInstance(AClassName: string): TObject;
begin
    Result := FuncCompManager.GetClassInstance(AClassName);
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.GetApplication: TObject;
begin
    Result := FApplication;
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.GetHost: TObject;
begin
    Result := FHost;
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.GetFuncDispatcher: IInterface;
var
    fd: TObject;
begin
    Result := nil;
    if Assigned(FFuncDispatcher) then
        Result := FFuncDispatcher
    else
    begin
        fd := Self.GetDispatcher('FunctionDispatcher');
        if fd <> nil then
            if Supports(fd, IInterface, FFuncDispatcher) then
                Result := FFuncDispatcher;
    end;
end;

{ ----------------------------------------------------------------------------- }
procedure THJXAppService.SetProject(AProject: IHJXProject);
begin
    FIProject := AProject;
end;

{ ----------------------------------------------------------------------------- }
procedure THJXAppService.SetGlobalDatas(AGD: IHJXProjectGlobalDatas);
begin
    FIGlobalDatas := AGD;
end;

{ ----------------------------------------------------------------------------- }
procedure THJXAppService.SetApplication(App: TObject);
begin
    FApplication := App;
end;

function THJXAppService.GetMeters: TObject;
begin
    Result := FMeters;
end;

procedure THJXAppService.SetMeters(MeterList: TObject);
begin
    FMeters := MeterList;
end;

function THJXAppService.GetMeterGroups: TObject;
begin
    Result := FMeterGroups;
end;

procedure THJXAppService.SetMeterGroups(MeterGroupList: TObject);
begin
    FMeterGroups := MeterGroupList;
end;

function THJXAppService.GetDSNames: TObject;
begin
    Result := FDSNames;
end;

procedure THJXAppService.SetDSNames(DSNameList: TObject);
begin
    FDSNames := DSNameList;
end;

function THJXAppService.GetLayouts: TObject;
begin
    Result := FLayouts;
end;

procedure THJXAppService.SetLayouts(ALayoutList: TObject);
begin
    FLayouts := ALayoutList;
end;

function THJXAppService.GetTemplates: TObject;
begin
    Result := FTemplates;
end;

procedure THJXAppService.SetTemplates(ATmpl: TObject);
begin
    FTemplates := ATmpl;
end;

{ ----------------------------------------------------------------------------- }
function THJXAppService.Logged: Boolean;
begin
(*
        if Assigned(FClientDatas) then
            Result := ClientDatas.AlreadyLogged
        else
            Result := False;
*)
    Result := True;
end;

procedure THJXAppService.RegisterOpenDBManProc(AProc: TProcedure);
begin
    FOpenDBManProc := AProc;
end;

procedure THJXAppService.OpenDatabaseManager;
begin
    if Assigned(FOpenDBManProc) then
        FOpenDBManProc;
end;

{ -----------------------------------------------------------------------------
  以下是事件处理
----------------------------------------------------------------------------- }
type
    TNotifyEventReg = record
        EventName: string;
        EventPort: TNotifyEvent;
    end;

    PNotifyEventReg = ^TNotifyEventReg;

procedure _CallEventDemander(EvtList: TList; Sender: TObject);
var
    i  : Integer;
    Evt: PNotifyEventReg;
begin
    if EvtList.Count = 0 then
        Exit;
    for i := 0 to EvtList.Count - 1 do
    begin
        Evt := EvtList[i];
        Evt^.EventPort(Sender);
    end;
end;

{ ----------------------------------------------------------------------------- }
procedure THJXAppService.OnLogin(Sender: TObject);
begin
    _CallEventDemander(FEvtReqOnLogin, Sender);
end;

{ ----------------------------------------------------------------------------- }
procedure THJXAppService.OnLogout(Sender: TObject);
begin
    _CallEventDemander(FEvtReqOnLogout, Sender);
end;

{ ----------------------------------------------------------------------------- }
procedure THJXAppService.OnRemoteConnect(Sender: TObject);
begin
    _CallEventDemander(FEvtReqOnConnect, Sender);
end;

{ ----------------------------------------------------------------------------- }
procedure THJXAppService.OnRemoteDisconnect(Sender: TObject);
begin
    _CallEventDemander(FEvtReqOnDisconnect, Sender);
end;

{ ----------------------------------------------------------------------------- }
procedure THJXAppService.OnNotifyEvent(AEvent: string; Sender: TObject);
var
    i  : Integer;
    Evt: PNotifyEventReg;
begin
    if FEvtReqOnNotify.Count = 0 then
        Exit;
    for i := 0 to FEvtReqOnNotify.Count - 1 do
        if SameText(AEvent, FEvtReqOnNotify.Strings[i]) then
        begin
            Evt := PNotifyEventReg(FEvtReqOnNotify.Objects[i]);
            Evt.EventPort(Sender);
        end;
end;

{ ----------------------------------------------------------------------------- }
procedure THJXAppService.RegEventDemander(DemandEvent: string; OnEvent: TNotifyEvent);
var
    NewER: PNotifyEventReg;
begin
    New(NewER);
    NewER.EventName := DemandEvent;
    NewER.EventPort := OnEvent;
    if DemandEvent = 'LoginEvent' then
    begin
        FEvtReqOnLogin.Add(NewER)
    end
    else if DemandEvent = 'LogoutEvent' then
        FEvtReqOnLogout.Add(NewER)
    else if DemandEvent = 'AfterConnectedEvent' then
        FEvtReqOnConnect.Add(NewER)
    else if DemandEvent = 'AfterDisconnectEvent' then
        FEvtReqOnDisconnect.Add(NewER)
    else
        FEvtReqOnNotify.AddObject(DemandEvent, TObject(NewER));
end;

{ ----------------------------------------------------------------------------- }
procedure THJXAppService.ProcessMessages;
begin
    if Assigned(FProcessMessages) then
        FProcessMessages;
end;

{ ============================================================================ }
initialization

HJXAppServices := THJXAppService.Create;
IAppServices := HJXAppServices;

finalization

// FreeAndNil(PSMISAppServices);
end.
