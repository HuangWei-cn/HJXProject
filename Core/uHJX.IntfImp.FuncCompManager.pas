{-----------------------------------------------------------------------------
 Unit Name: uFuncCompManager
 Author:    Administrator
 Date:      2016-7-27
 Purpose:   ���ܼ�������
    ʹ�÷�����
            �ڹ����ļ��У�����ԪӦ���������б���Ӧλ�ӵڶ�����һ��uApplicationServices����
            �Ծ����ʼ��������ʼ����ʱ������˳�򴴽�AppServices��FuncCompManager��
            ��Application��ʼ��������������ʱ���ڽ�������ⲿ�������ע����ϣ�
            ���Խ��г�ʼ���ˡ�

            �����μ��ز�����û���ѡ�������뿪�أ�LoadPluginFirst, OnlyBuildIn��
            ���ڹ�����������LoadPluginFirstʱ����������������Create֮���Զ�����
            PluginĿ¼�µĲ�����������Ҫ�û����ü��ز����ʱ����
            �û����ڹ����л�Host��ɳ�ʼ��֮ǰ���ز�����磺
            $IFNDEF LoadPluginFirst
                $IFNDEL OnlyBuildIn
                    FuncCompManager.LoadPlugIns;
                $ENDIF
            $ENDIF

            ���ָ����OnlyBuildIn����������������ⲿ������������������ڽ�
            ��ע�Ṧ�ܼ���

 History:
-----------------------------------------------------------------------------}

unit uHJX.IntfImp.FuncCompManager;

interface
uses
    SysUtils, Classes, Windows, Forms, {uIAppservices, uFuncCompTypes,
    uIFuncCompManager} uHJX.Intf.AppServices, uHJX.Core.FuncCompTypes, uHJX.Intf.FuncCompManager;

type
    TFunctionComponentManager = class(TInterfacedObject, IFunctionComponentManager)
    private
        FDispList: TList;               //����������
        FComps: TList;                  //���ܼ�ʵ�����ϣ�����Ҫ�ٱ�����
        FClasses: TList;                //�༯�ϣ�ͨ�����ɴ����������ʵ��
        //FFuncs: TList; //���̡��������ϣ�������IFunctionDispatcher���
        FRegister: TList;               //���ܼ�ע����
        FInitMsg: string;               //��ʼ�����̲�������Ϣ
        FLoadMsg: string;               //���ز�����̲�������Ϣ
        FPlugins: TList;                //���ص��ⲿ������˳�ʱ��Ҫ��һ�ͷ�
        FPluginLoaded: Boolean;         //�Ƿ��Ѿ����ع����
        FOwnerCmp: TComponent;          //һ����ΪOwner��Component
        procedure Clear;
        procedure AddRegister(ARegister: PFuncCompRegister; AEntry: Pointer =
            nil);
        procedure LoadDLLPlugin(FileName: string);
        procedure LoadPackagePlugin(FileName: string);
        //procedure UnloadPlugins;
    public
        constructor Create;
        destructor Destroy; override;
        { ���ز�����ڱ���������ʼ������У���ѡ���ڹ����ļ���Application.Initialize
          ֮��Ҳ����ѡ����Host.FormCreate�¼��С������Ҫ�ڱ���������ʼ��֮����أ�
          Ӧ���ñ��뿪��LoadPluginFirst�� }
        procedure LoadPlugins;
        { ж�ز����Host��FormDestroy�¼��е��ã��������������صĲ����һֱ��
          �����ڴ��� }
        procedure UnloadPlugins;
        { ע�����ʼ�����̡������й��ܼ����ز�ע�����֮����Host���ô˷����Ը�
          �����ܼ����г�ʼ����һ����Host��FormCreate�¼��е��ã���ʱ���б����õ�
          Ԫ��Host���Ѿ���ɳ�ʼ�������е�ʵ�����Ѿ������ˡ� }
        procedure InitFuncComps;
        { ���в����ʼ��֮���Զ����ɣ��������๦�ܼ�֮�����װ�䡢���� }
        procedure AutoIntegrated;
        { ���ص�����ʵ������TPSMISAppServiceʹ�ã��ӿ���û��������� }
        function GetDispatcher(ADispName: string): TObject;
        { ����ָ�����Ƶ��� }
        function GetClass(AClassName: string): TClass;
        { ����ָ��Class��ʵ�� }
        function GetClassInstance(AClassName: string): TObject;
        { ����ָ�����Ƶ���� }
        function GetComponent(ACompName: string): TObject;

        { ----- �ӿڷ���ʵ��------ }
        { ע������� }
        procedure RegisterDispatcher(AFCType: PFuncCompRegister; ADispatcher:
            TObject);
        { ע���� }
        procedure RegisterClass(AFCType: PFuncCompRegister; AClass: TClass);
        { ע�����ʵ�� }
        procedure RegisterComponent(AFCType: PFuncCompRegister; AComponent:
            TObject);
        { ע�ắ�������̡�������ֻ��ע����Ϣ����������Ӧ�ĵ���������ÿ�������
          ���ܼ��ڼ���ע��ʱ�����ṩע����Ϣ��ͬʱ�ڴ�ע�������ṩ��ʼ��������
          ������ܼ�ͬʱ�ṩ�ࡢ����ȣ���ע����Entry֮����ע���ࡢ������������ȡ�
          һЩ�߱��������ܵĲ���������д���ע�ᣬ�����ǵĵ��ÿ�����ͨ�����˵���ɡ�
          �����Ҫ���������ܼ��������ҵ������Լ�ע��Ϊ�ࡢ����ȣ���ע�ᵽ�������С� }
        procedure RegisterEntry(AFCType: PFuncCompRegister);
        /// <summary>
        /// ��ʼ�����̲�������Ϣ���������жϳ�ʼ�������г��ֵ����⡣
        /// </summary>
        property InitMessage: string read FInitMsg;
        /// <summary>
        /// ���ع��̲�������Ϣ
        /// </summary>
        property LoadMessage: string read FLoadMsg;
    end;

var
    FuncCompManager: TFunctionComponentManager;

implementation
const
    PluginExtension = 'plg';            //�����չ��

type
    PRegEntryRec = ^TRegEntryRec;
    TRegEntryRec = record
        Entry: Pointer;
        Name: string;
    end;

    PPluginEntry = ^TPluginEntry;
    TPluginEntry = record
        FileName: string;
        Handle: THandle;
        PluginType: TPluginType;
    end;
    { ==============================================================================
                    <<<<<<<<<<<<<   TFunctionComponentManager   >>>>>>>>>>>>>>>
      ClassName:    TFunctionComponentManager
      Comment:
     =============================================================================== }
constructor TFunctionComponentManager.Create;
begin
    inherited Create;
    FDispList := TList.Create;
    FComps := TList.Create;
    FClasses := TList.Create;
    FRegister := TList.Create;
    FPlugins := TList.Create;
    FPluginLoaded := False;
    { FOwnerCmp������Ϊ�����½�Component��Owner����Mannageer�ͷ�ʱ�Զ��ͷ���Щ
      ����������� }
    FOwnerCmp := TComponent.Create(nil);
{$IFDEF LoadPluginFirst}
    LoadPlugins;
{$ENDIF}                                // LoadPluginFirst
end;
{-----------------------------------------------------------------------------}
destructor TFunctionComponentManager.Destroy;
begin
    Clear;
    FDispList.Free;
    FComps.Free;
    FClasses.Free;
    FRegister.Free;
    FPlugins.Free;
    FreeAndNil(FOwnerCmp);
    inherited;
end;
{-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.AddRegister(ARegister: PFuncCompRegister;
    AEntry: Pointer = nil);
begin
    FRegister.Add(ARegister);
end;
{-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.Clear;
var
    i     : Integer;
    //PluginEnt: PPluginEntry;
    //UnregProc: TUnRegistProcedure;
begin
    for i := 0 to FDispList.Count - 1 do
        Dispose(PRegEntryRec(FDispList.Items[i]));
    for i := 0 to FClasses.Count - 1 do
        Dispose(PRegEntryRec(FClasses.Items[i]));
    for i := 0 to FComps.Count - 1 do
        Dispose(PRegEntryRec(FComps[i]));
    FDispList.Clear;
    FClasses.Clear;
    FComps.Clear;
    FRegister.Clear;

    { ����ע�������ⲿ��� }
    UnloadPlugins;
    FPlugins.Clear;
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.LoadPlugin
  Description:  ���ض�̬���ӿ���
-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.LoadDLLPlugin(FileName: string);
var
    PluginEnt: PPluginEntry;
    RegProc: TRegistProcedure;
    AHandle: THandle;
begin
    try
        AHandle := LoadLibrary(PChar(FileName));
        if AHandle <= 0 then
            FLoadMsg := FLoadMsg + '���ز��' + FileName + 'ʧ��, ������룺' +
                IntToStr(GetLastError) + #13#10
                //        raise EPluginLoadError.Create('���ز��' + FileName + 'ʧ��, ������룺' +
//            IntToStr(GetLastError))
        else
        begin
            { ��Ӳ����Ϣ�������˳�ʱע����ж�� }
            New(PluginEnt);
            PluginEnt^.FileName := FileName;
            PluginEnt^.Handle := AHandle;
            PluginEnt^.PluginType := ptDLL;
            FPlugins.Add(PluginEnt);

            @RegProc := GetProcAddress(AHandle, PChar('RegisterFuncComp'));
        end;

        if not Assigned(RegProc) then
            FLoadMsg := FLoadMsg + 'GetProcAddress���󣬴�����룺' +
                IntToStr(GetLastError) + #13#10
        else
            RegProc(Self);
        // statements to try
    except
        on e: Exception do
            Application.HandleException(Self);
    end;                                // try/except

end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.LoadPackagePlugin
  Description:  ���ذ����
-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.LoadPackagePlugin(FileName: string);
type
    TRegFunc = function: TRegistProcedure;
var
    PluginEnt: PPluginEntry;
    RegProc: TRegistProcedure;
    AHandle: THandle;
begin
    try
        AHandle := LoadPackage(FileName);
        if AHandle <= 0 then
            FLoadMsg := FLoadMsg + '���ز��' + FileName + 'ʧ��'
        else
        begin
            New(PluginEnt);
            PluginEnt^.FileName := FileName;
            PluginEnt^.Handle := AHandle;
            PluginEnt^.PluginType := ptPackage;
            FPlugins.Add(PluginEnt);
            @RegProc := GetProcAddress(AHandle, PChar('RegisterFuncComp'));
            if Assigned(@RegProc) then
                RegProc(Self);
        end;
        // statements to try
    except
        on e: Exception do
            Application.HandleException(Self);
    end;                                // try/except
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.LoadPlugins
  Description:	���ز��
-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.LoadPlugins;
var
    path  : string;
    FileName: string;
    Found : Integer;
    sr    : TSearchRec;
begin
{ ���ָ����OnlyBuildIn���أ��򲻼����ⲿ��� }
{$IFDEF OnlyBuildIn}
    Exit;
{$ENDIF}                                // OnlyBuildIn

    //�������Ѿ����ع��������ظ������ˡ�
    if FPluginLoaded then Exit;

    FLoadMsg := '';
    //
    path := ExtractFilePath(Application.ExeName) + 'Plugins\';

    try
        Found := FindFirst(path + '*.bpl', 0, sr);
        while Found = 0 do
        begin
            FileName := sr.Name;
            LoadPackagePlugin(path + FileName);
            Found := FindNext(sr);
        end;                            // while
    finally
        SysUtils.FindClose(sr);
    end;

    { ����DLL��� }
    try
        Found := FindFirst(path + '*.dll' {+ PluginExtension}, 0, sr);
        while Found = 0 do
        begin
            FileName := sr.Name;
            LoadDLLPlugin(path + FileName);
            Found := FindNext(sr);
        end;                            // while
    finally
        SysUtils.FindClose(sr);
    end;

    FPluginLoaded := True;
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.UnloadPlugins
  Description:  ж�ز��
-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.UnloadPlugins;
var
    i     : Integer;
    AHandle: THandle;
    PluginEnt: PPluginEntry;
    UnregProc: TUnRegistProcedure;
begin
    for i := 0 to FPlugins.Count - 1 do
    begin
        PluginEnt := FPlugins[i];
        AHandle := PluginEnt.Handle;
        if PluginEnt^.PluginType = ptDLL then
        begin
            @UnregProc := GetProcAddress(PluginEnt^.Handle,
                PChar('UnregisterFuncComp'));
            if Assigned(UnregProc) then
            try
                UnregProc;
            finally
            end;

            FreeLibrary(PluginEnt^.Handle);
            Dispose(PluginEnt);
        end
        else if PluginEnt^.PluginType = ptPackage then
        begin
            //FinalizePackage(PluginEnt^.Handle);
            UnloadPackage(PluginEnt^.Handle);
            Dispose(PluginEnt);
        end;
    end;
    FPlugins.Clear;
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.InitFuncComps
  Description:  ���ܼ���ʼ�����̡�ÿ�����ܼ����������ڽ�������ǲ�����ڼ���
  ʱ����ע�ᣬ����ʼ����BuildIn���ܼ��ڵ�Ԫ��Initialization��ע���Լ��������
  ��������м��ء�ע�ᡣ��ʼ������Ҫ�����й��ܼ�ȫ��ע�����֮��Ž��У�ԭ��
  ���ڹ��ܼ�֮����ڵ��û�ע���ϵ������Agent���͵Ĺ��ܼ���������Ӧ�ĵ�������
  ʼ��֮����ܳ�ʼ����
-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.InitFuncComps;
var
    i     : Integer;
    pFCR  : PFuncCompRegister;

    function FindEntry(AName: string): PFuncCompRegister;
    var
        kk: Integer;
    begin
        for kk := 0 to FRegister.Count - 1 do
        begin
            Result := FRegister[kk];
            if Result^.RegisterName = AName then Exit;
        end;
        Result := nil;
    end;

    { �����̳�ʼ������ע���壬��ʹ�õݹ鷽ʽ��ʼ�����б������ע���塣
      ע�⣺������û�м��ѭ�����õ����⣬���������һ����� }
    { TODO:������ܼ�֮�������ѭ�����⡣ }
    function ExecInitProc(ARegister: PFuncCompRegister): Boolean;
    var
        strReq: string;
        reqs: TStrings;
        reqEnt: PFuncCompRegister;
        ReqInited: Boolean;
        k : Integer;
    begin
        Result := True;
        if ARegister^.Initiated then Exit;
        if not Assigned(ARegister^.InitProc) then Exit;

        strReq := ARegister^.Requires;
        { ִ�����������ע����ĳ�ʼ�� }
        if strReq <> '' then
        begin
            reqs := TStringList.Create;
            ReqInited := True;
            try
                ExtractStrings([','], [' '], PChar(Trim(strReq)), reqs);
                for k := 0 to reqs.Count - 1 do
                begin
                    reqEnt := FindEntry(reqs.Strings[k]);
                    if reqEnt <> nil then
                    begin
                        //�ݹ��ʼ����ֱ��ÿһ�����������ʼ�����
                        //����������ʼ��ʧ�ܣ��������������ʼ��ʧ�ܱ�־������
                        //��ֹͣ������ʼ�������������
                        if ExecInitProc(reqEnt) = False then ReqInited := False;
                    end;
                end;
                { �������ȫ��Ū���� }
            finally
                reqs.Free;
            end;
        end
        else
            ReqInited := True; //�����Ϊ�����������ܳ�ʼ��������Ҫ���strreqs

        try
            { ��������û����ɳ�ʼ������ע������޷���ȷִ�еģ�����Ҳ�Ͳ�����ִ���� }
            if not ReqInited then Exit;

            if ARegister^.InitProc(IAppServices) then
                ARegister^.Initiated := True
            else
            begin
                Result := False;
                FInitMsg := FInitMsg + ARegister^.RegisterName +
                    '��ʼ��ʧ��'#13#10;
            end;
        finally
        end;
    end;
begin
    FInitMsg := '';
    //InitList := TList.Create;
    try
        for i := 0 to FRegister.Count - 1 do
        begin
            pFCR := FRegister[i];
            try
                ExecInitProc(pFCR);
            except
                on e: Exception do
                    FInitMsg := FInitMsg + '���ܼ�' + pFCR^.RegisterName +
                        '��ʼ�����󣬴�����Ϣ��'#13#10
                        + e.Message + #13#10;
//                    ShowMessage('���ܼ�' + pFCR^.RegisterName + '��ʼ�����󣬴�����Ϣ��'#13#10
//                        + e.Message);
            end;
        end;

    finally
    end;
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.AutoIntegrated
  Description:  ��ʵ�����Ĳ��֮���Զ����ɹ��̡�����������Host�Ͳ����ʼ��֮��
  ִ�У�����Ѿ�ʵ�����Ĳ��֮����໥���ɡ������Host�ļ��ɹ����ɲ��������ɣ�
  ���ǲ��֮��ļ������ɱ�����ʵʩ��
  ĳЩ����ṩ�����࣬��δʵ����������ʵ����ʱ���������һ�����������������
  ���ܲ��롣
  ��ʱ�����Ǽ�ʱװ�䡣
-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.AutoIntegrated;
begin
    // do nothing now.
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.GetDispatcher
  Description:
-----------------------------------------------------------------------------}
function TFunctionComponentManager.GetDispatcher(ADispName: string): TObject;
var
    i     : Integer;
    Ent   : PRegEntryRec;
begin
    Result := nil;
    for i := 0 to FDispList.Count - 1 do
    begin
        Ent := FDispList[i];
        if Ent.Name = ADispName then
        begin
            Result := TObject(Ent^.Entry);
            Exit;
        end;
    end;
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.GetClass
  Description:
-----------------------------------------------------------------------------}
function TFunctionComponentManager.GetClass(AClassName: string): TClass;
var
    i     : Integer;
    Ent   : PRegEntryRec;
begin
    Result := nil;
    for i := 0 to FClasses.Count - 1 do
    begin
        Ent := FClasses[i];
        if Ent.Name = AClassName then
        begin
            Result := TClass(Ent^.Entry);
            Exit;
        end;
    end;
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.GetClassInstance
  Description:
-----------------------------------------------------------------------------}
function TFunctionComponentManager.GetClassInstance(AClassName: string): TObject;
var
    //i     : Integer;
    Cls   : TClass;
begin
    Result := nil;
    Cls := GetClass(AClassName);
    if Cls = nil then Exit;

    if Cls.InheritsFrom(TComponent) then
    begin
        Result := TComponentClass(Cls).Create(FOwnerCmp);
        TComponent(Result).Name := Cls.ClassName + '_' +
            IntToStr(Integer(Result));
    end
    else
        Result := Cls.Create;
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.GetComponent
  Description:
-----------------------------------------------------------------------------}
function TFunctionComponentManager.GetComponent(ACompName: string): TObject;
var
    i     : Integer;
    Ent   : PRegEntryRec;
begin
    Result := nil;
    for i := 0 to FComps.Count - 1 do
    begin
        Ent := FComps[i];
        if Ent.Name = ACompName then
        begin
            Result := TObject(Ent^.Entry);
            Exit;
        end;
    end;
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.RegisterDispatcher
  Description:
-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.RegisterDispatcher(AFCType: PFuncCompRegister;
    ADispatcher: TObject);
var
    Entry : PRegEntryRec;
begin
    New(Entry);
    Entry^.Name := AFCType^.RegisterName;
    Entry^.Entry := ADispatcher;
    AddRegister(AFCType);
    FDispList.Add(Entry);
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.RegisterClass
  Description:
-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.RegisterClass(AFCType: PFuncCompRegister;
    AClass: TClass);
var
    Entry : PRegEntryRec;
begin
    New(Entry);
    Entry.Name := AFCType.RegisterName;
    Entry.Entry := AClass;
    AddRegister(AFCType);
    FClasses.Add(Entry);
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.RegisterComponent
  Description:
-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.RegisterComponent(AFCType: PFuncCompRegister;
    AComponent: TObject);
var
    Entry : PRegEntryRec;
begin
    New(Entry);
    Entry.Name := AFCType.RegisterName;
    Entry.Entry := AComponent;
    AddRegister(AFCType);
    FComps.Add(Entry);
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.RegisterFunction
  Description:
-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.RegisterEntry(AFCType: PFuncCompRegister);
begin
    AddRegister(AFCType);
end;

initialization
    FuncCompManager := TFunctionComponentManager.Create;
    IFuncCompManager := FuncCompManager;

finalization
    //FreeandNil(FuncCompManager);
end.

