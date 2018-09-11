{ -----------------------------------------------------------------------------
 Unit Name: uApplicationServices
 Author:    Administrator
 Date:      2016-7-27
 Purpose:   Ӧ�÷������
            Host����Ӧ����PSMISAppServices���������ܼ�Ӧ���ñ�����Ľӿ�ʵ��
            IApplicationServices��
 History:   2016-7-28
                ������RegisterOpenDBManProc�������������ݽӿڲ��ע����������
                ������棻������OpenDatabaseManager�������÷��������������Ӳ�
                ���е��������ӹ�����档

            2018-05-23
                1��Logged���������ݱ�ע�͵��ˣ�ֱ�ӷ��ؽ��True
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
        { �����ġ��ر��Ķ��� }
        FApplication : TObject;
        FClientDatas : TObject;
        FIProject    : IHJXProject;
        FIGlobalDatas: IHJXProjectGlobalDatas;
        // FHostMenu      : TObject;
        // FHostToolbar   : TObject;
        // FHostPager     : TObject;
        FHost          : TObject;
        FFuncDispatcher: IInterface;
        { 2016-7-28 ���ݿ����ӹ����� }
        FOpenDBManProc: TProcedure;
        { �¼�������ע�� }
        FEvtReqOnLogin     : TList;    // ��Ҫ��¼�ɹ��¼����
        FEvtReqOnLogout    : TList;    // ��Ҫע���¼���
        FEvtReqOnConnect   : TList;    // ��Ҫ�����¼���
        FEvtReqOnDisconnect: TList;    // ��Ҫ�Ͽ��¼���
        FEvtReqOnNotify    : TStrings; // ��Ҫ����֪ͨ�¼���
        FProcessMessages   : TProMsgs; // ������������Application.ProcessMessage����

        FMeters     : TObject;
        FMeterGroups: TObject;
        FDSNames    : TObject;
        FLayouts    : TObject;
        FTemplates  : TObject;

        procedure ClearAll;

        { �ӿڷ��� }
        function GetClientDatasInterface: IClientFuncs;
        function GetProject: IHJXProject;
        function GetGlobalDatas: IHJXProjectGlobalDatas;
    public
        constructor Create;
        destructor Destroy; override;
        { ȡdmClient���� }
        function GetClientDatas: TObject;
        { ��ȡ������ }
        function GetDispatcher(ADispatcherName: string): TObject;
        { ��ȡ���ܼ��ӿ� }
        function GetFunctionComp(ACompName: string): IInterface;
        { ��ȡ���ܼ��� }
        function GetFuncCompClass(AClassName: string): TClass;
        { ��ȡ���ܼ���ʵ�� }
        function GetFuncCompClassInstance(AClassName: string): TObject;
        { ��ȡ���ܼ�ʵ�� }
        function GetComponent(ACompName: string): TObject;
        { ȡHost��Application }
        function GetApplication: TObject;
        { ����Host����Application.MainForm }
        function GetHost: TObject;
        { ����IFunctionDispatcher }
        function GetFuncDispatcher: IInterface;
        { ������������ }
        function GetMeters: TObject;
        function GetMeterGroups: TObject;
        function GetDSNames: TObject;
        function GetLayouts: TObject;
        function GetTemplates: TObject;

        { ��¼״̬ }
        function Logged: Boolean;

        procedure RegisterClientDatas(AClientDatas: TObject);
        procedure ReleaseClientDatas;
        { 2016-7-28 ע������ݿ����ӹ������ķ��� }
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

        { �¼��������¼��Ĺ��ܼ�������Щ��������AppServices������ע�������� }
        procedure OnLogin(Sender: TObject);
        procedure OnLogout(Sender: TObject);
        procedure OnRemoteConnect(Sender: TObject);
        procedure OnRemoteDisconnect(Sender: TObject);
        procedure OnNotifyEvent(AEvent: string; Sender: TObject);

        { ע���¼������� }
        procedure RegEventDemander(DemandEvent: string; OnEvent: TNotifyEvent);

        procedure ProcessMessages;
        { ע�� }
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
    { ǧ��ע�⣡��������ڱ������������˽ӿڣ����Ǹö���û���������ط��ͷţ�����
      ���������ｫ���õĽӿ�ָ������Ϊnil���������ýӿ�Ϊnilʱ��������Delphi��
      ͼ�ͷŸýӿڶ�������ýӿڶ���ʵ�����ͷţ�������һ������ }
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
  �������¼�����
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
