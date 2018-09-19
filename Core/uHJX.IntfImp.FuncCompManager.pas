{-----------------------------------------------------------------------------
 Unit Name: uFuncCompManager
 Author:    Administrator
 Date:      2016-7-27
 Purpose:   功能件管理器
    使用方法；
            在工程文件中，本单元应列在引用列表中应位居第二（第一是uApplicationServices），
            以尽早初始化。程序开始运行时，将按顺序创建AppServices，FuncCompManager，
            待Application初始化、创建主窗体时，内建插件与外部插件都已注册完毕，
            可以进行初始化了。

            针对如何加载插件，用户可选两个编译开关：LoadPluginFirst, OnlyBuildIn。
            当在工程中设置了LoadPluginFirst时，管理器将在自身Create之后自动加载
            Plugin目录下的插件，否则就需要用户设置加载插件的时机。
            用户可在工程中或Host完成初始化之前加载插件，如：
            $IFNDEF LoadPluginFirst
                $IFNDEL OnlyBuildIn
                    FuncCompManager.LoadPlugIns;
                $ENDIF
            $ENDIF

            如果指定了OnlyBuildIn，则管理器不加载外部插件，仅仅管理工程中内建
            的注册功能件。

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
        FDispList: TList;               //调度器集合
        FComps: TList;                  //功能件实例集合，不需要再被创建
        FClasses: TList;                //类集合，通过它可创建对象、组件实例
        //FFuncs: TList; //过程、方法集合，考虑用IFunctionDispatcher替代
        FRegister: TList;               //功能件注册体
        FInitMsg: string;               //初始化过程产生的信息
        FLoadMsg: string;               //加载插件过程产生的信息
        FPlugins: TList;                //加载的外部插件，退出时需要逐一释放
        FPluginLoaded: Boolean;         //是否已经加载过插件
        FOwnerCmp: TComponent;          //一个作为Owner的Component
        procedure Clear;
        procedure AddRegister(ARegister: PFuncCompRegister; AEntry: Pointer =
            nil);
        procedure LoadDLLPlugin(FileName: string);
        procedure LoadPackagePlugin(FileName: string);
        //procedure UnloadPlugins;
    public
        constructor Create;
        destructor Destroy; override;
        { 加载插件是在本管理器初始化后进行，可选择在工程文件的Application.Initialize
          之后，也可以选择在Host.FormCreate事件中。如果需要在本管理器初始化之后加载，
          应设置编译开关LoadPluginFirst。 }
        procedure LoadPlugins;
        { 卸载插件在Host的FormDestroy事件中调用，如果不调用则加载的插件将一直保
          留在内存中 }
        procedure UnloadPlugins;
        { 注册件初始化过程。当所有功能件加载并注册完毕之后，由Host调用此方法对各
          个功能件进行初始化，一般在Host的FormCreate事件中调用，此时所有被引用单
          元及Host都已经完成初始化，该有的实例都已经建立了。 }
        procedure InitFuncComps;
        { 所有插件初始化之后，自动集成，将界面类功能件之间进行装配、插入 }
        procedure AutoIntegrated;
        { 返回调度器实例，供TPSMISAppService使用，接口中没有这个方法 }
        function GetDispatcher(ADispName: string): TObject;
        { 返回指定名称的类 }
        function GetClass(AClassName: string): TClass;
        { 返回指定Class的实例 }
        function GetClassInstance(AClassName: string): TObject;
        { 返回指定名称的组件 }
        function GetComponent(ACompName: string): TObject;

        { ----- 接口方法实现------ }
        { 注册调度器 }
        procedure RegisterDispatcher(AFCType: PFuncCompRegister; ADispatcher:
            TObject);
        { 注册类 }
        procedure RegisterClass(AFCType: PFuncCompRegister; AClass: TClass);
        { 注册组件实例 }
        procedure RegisterComponent(AFCType: PFuncCompRegister; AComponent:
            TObject);
        { 注册函数、过程、方法，只有注册信息，东西由相应的调度器管理。每个插件和
          功能件在加载注册时都会提供注册信息，同时在此注册体中提供初始化方法，
          如果功能件同时提供类、组件等，在注册了Entry之后再注册类、组件、调度器等。
          一些具备完整功能的插件往往仅有此项注册，对它们的调用可以是通过主菜单完成。
          如果需要被其他功能件搜索查找到，则将自己注册为类、组件等，或注册到调度器中。 }
        procedure RegisterEntry(AFCType: PFuncCompRegister);
        /// <summary>
        /// 初始化过程产生的消息。常用来判断初始化过程中出现的问题。
        /// </summary>
        property InitMessage: string read FInitMsg;
        /// <summary>
        /// 加载过程产生的消息
        /// </summary>
        property LoadMessage: string read FLoadMsg;
    end;

var
    FuncCompManager: TFunctionComponentManager;

implementation
const
    PluginExtension = 'plg';            //插件扩展名

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
    { FOwnerCmp用于作为无主新建Component的Owner，在Mannageer释放时自动释放这些
      被创建的组件 }
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

    { 清理、注销所有外部插件 }
    UnloadPlugins;
    FPlugins.Clear;
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.LoadPlugin
  Description:  加载动态链接库插件
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
            FLoadMsg := FLoadMsg + '加载插件' + FileName + '失败, 错误代码：' +
                IntToStr(GetLastError) + #13#10
                //        raise EPluginLoadError.Create('加载插件' + FileName + '失败, 错误代码：' +
//            IntToStr(GetLastError))
        else
        begin
            { 添加插件信息，用于退出时注销、卸载 }
            New(PluginEnt);
            PluginEnt^.FileName := FileName;
            PluginEnt^.Handle := AHandle;
            PluginEnt^.PluginType := ptDLL;
            FPlugins.Add(PluginEnt);

            @RegProc := GetProcAddress(AHandle, PChar('RegisterFuncComp'));
        end;

        if not Assigned(RegProc) then
            FLoadMsg := FLoadMsg + 'GetProcAddress错误，错误代码：' +
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
  Description:  加载包插件
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
            FLoadMsg := FLoadMsg + '加载插件' + FileName + '失败'
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
  Description:	加载插件
-----------------------------------------------------------------------------}
procedure TFunctionComponentManager.LoadPlugins;
var
    path  : string;
    FileName: string;
    Found : Integer;
    sr    : TSearchRec;
begin
{ 如果指定了OnlyBuildIn开关，则不加载外部插件 }
{$IFDEF OnlyBuildIn}
    Exit;
{$ENDIF}                                // OnlyBuildIn

    //如果插件已经加载过，则不再重复加载了。
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

    { 加载DLL插件 }
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
  Description:  卸载插件
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
  Description:  功能件初始化过程。每个功能件，无论是内建组件还是插件，在加载
  时都仅注册，不初始化。BuildIn功能件在单元的Initialization段注册自己，插件由
  本对象进行加载、注册。初始化过程要在所有功能件全部注册完毕之后才进行，原因
  在于功能件之间存在调用或注册关系。比如Agent类型的功能件必须在相应的调度器初
  始化之后才能初始化。
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

    { 本过程初始化给定注册体，并使用递归方式初始化所有被需求的注册体。
      注意：本方法没有检查循环引用的问题，这个将在下一步解决 }
    { TODO:解决功能件之间的需求循环问题。 }
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
        { 执行所有需求的注册体的初始化 }
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
                        //递归初始化，直到每一个被需求件初始化完成
                        //如果需求件初始化失败，则设置需求件初始化失败标志，但是
                        //不停止继续初始化其他需求件。
                        if ExecInitProc(reqEnt) = False then ReqInited := False;
                    end;
                end;
                { 被需求件全部弄完了 }
            finally
                reqs.Free;
            end;
        end
        else
            ReqInited := True; //这句是为了无需求者能初始化，否则还要检查strreqs

        try
            { 如果需求件没有完成初始化，则本注册件是无法正确执行的，所以也就不继续执行了 }
            if not ReqInited then Exit;

            if ARegister^.InitProc(IAppServices) then
                ARegister^.Initiated := True
            else
            begin
                Result := False;
                FInitMsg := FInitMsg + ARegister^.RegisterName +
                    '初始化失败'#13#10;
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
                    FInitMsg := FInitMsg + '功能件' + pFCR^.RegisterName +
                        '初始化错误，错误信息：'#13#10
                        + e.Message + #13#10;
//                    ShowMessage('功能件' + pFCR^.RegisterName + '初始化错误，错误信息：'#13#10
//                        + e.Message);
            end;
        end;

    finally
    end;
end;
{-----------------------------------------------------------------------------
  Procedure:    TFunctionComponentManager.AutoIntegrated
  Description:  已实例化的插件之间自动集成过程。本方法是在Host和插件初始化之后
  执行，完成已经实例化的插件之间的相互集成。插件向Host的集成过程由插件自身完成，
  但是插件之间的集成则由本过程实施。
  某些插件提供的是类，尚未实例化。当它实例化时，则调用另一个方法对它自身进行
  功能插入。
  暂时不考虑即时装配。
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

