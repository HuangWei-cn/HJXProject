unit uHJX.IntfImp.FunctionDispatcher;

interface

uses
    Windows, SysUtils, Classes, Graphics, Forms, dialogs, Types,
    {uBaseTypes,} {uIFuncCompManager, uIAppServices, uFuncCompTypes,
    uIFunctionDispatcher} uHJX.Intf.AppServices, uHJX.Intf.FuncCompManager, uHJX.Core.FuncCompTypes,
    uHJX.Intf.FunctionDispatcher;

type
    { 功能调度中心，所有frame或者已封装的功能组件，都将自己注册到这里，以便于其他封装模块调用。
      用法：先声明功能类，如下面的TFuncShowDMInfos，之后组件初始化之后将自己的对应方法注册到本类。
      调用者将调用本类的对应方法完成预定义的功能，由本类再派发到相应的功能组件去完成 }
    TFuncDispatchCenter = class( { TInterfacedObject } TInterfacedPersistent, IFunctionDispatcher)
    private
        FShowDMAndSensorInfo: TMethodByStr;
        FRefreshDMList      : TMethodNoneArg;
        FRefreshGroup       : TMethodNoneArg;
        FDrawTrendLineA     : TMethodByStr;
        FDrawMultiLineA     : TMethodByStrings; // TFuncMultiSensorsProc;
        FBrowseSensorData   : TMethodByStr;
        FDesignParamEdit    : TMethodByStr;
        FSensorParamEdit    : TMethodByStr;
        FSensorDataEdit     : TMethodByStr;
        FAddToFavorite      : TMethodByStr;
        FAddToGroup         : TMethodByStr;
        FGroupBrief         : TMethodByStrings; // TFuncMultiSensorsProc;
        FSetupMeter         : TMethodByID;      // Update Meter的方法
        FSetupMeterProc     : TProcByID;
        { 2018-06-06 }
        FShowDataGraph  : TMethodByStr;
        FPopupDataGraph : TMethodByStr;
        FPopupDataViewer: TMethodByStr;
        FShowData       : TMethodByStr;

        { 注册的方法与过程 }
        FProcList    : TStrings;
        FMethodList  : TList;
        FCompFuncList: TStrings;
        { 新注册体集合 }
        FFuncRegList: TList;
    public
        constructor Create;
        destructor Destroy; override;
        { 功能------------------------------------------------------ }
        procedure ShowDMInfos(ADesignName: string);
        // 2018-06-06
        procedure ShowDataGraph(ADesignName: string; AContainer: TComponent = nil);
        procedure PopupDataGraph(ADesignName: string; AContainer: TComponent = nil);

        procedure DrawTrendLine(ADesignName: string);
        procedure DrawMultiTrendLine(ASensors: TStrings);
        procedure RefreshDMList;
        procedure RefreshGroup;
        procedure BrowseSensorData(ADesignName: string);
        // 2018-06-07
        procedure PopupDataViewer(ADesignName: string; AContainer: TComponent = nil);
        procedure ShowData(ADesignName: string; AContainer: TComponent = nil);

        procedure EditDesignParams(ADesignName: string);
        procedure EditSensorParams(ADesignName: string);
        procedure EditSensorData(ADesignName: string);
        procedure AddPointToFavorite(ADesignName: string);
        procedure AddPointToGroup(ADesignName: string);
        procedure GroupBrief(ASensors: TStrings);
        procedure SetupMeter(AID: Integer);

        { 通用功能调用 }
        procedure GeneralProc(AProc: string; Sender: TObject; InParams: array of Variant;
            var OutParams: array of Variant);

        { 通用返回对象、组件函数 }
        function GeneralCompFunc(AFunc: string; AOwner: TComponent; InParams: array of Variant)
            : TComponent;

        { 返回通用过程地址 }
        function GetGeneralProc(AProc: string): TGeneralProc;
        { 返回通用方法地址 }
        function GetGeneralMethod(AMethod: string): TGeneralMethod;

        { 指定类型的通用方法过程调用 }
        procedure CallFunction(FuncName: string; AStr: string); overload;
        procedure CallFunction(FuncName: string; AStrings: TStrings); overload;
        procedure CallFunction(FuncName: string; AList: TList); overload;
        procedure CallFunction(FuncName: string; StrArray: TStringDynArray); overload;
        procedure CallFunction(FuncName: string; IntArray: TIntegerDynArray); overload;
        procedure CallFunction(FuncName: string; AID: Integer); overload;
        procedure CallFunction(FuncName: string); overload;
        procedure CallFunction(FuncName: string; Sender: TObject; InParams: array of Variant;
            var OutParams: array of Variant); overload;

        { 内置的方法、过程注册------------------------------------------------ }
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

        procedure RegistFuncDrawMultiTrendLine(AFunc: TMethodByStrings);
        procedure UnRegisterFuncDrawMultiTrendLine;

        procedure RegistFuncGroupBrief(AFunc: TMethodByStrings);
        procedure UnRegisterFuncGroupBrief;
        // procedure RegistDesignParamEditor(AClass: TClassSensorParamEditor);
// procedure RegistDesignParamsEditor(AMType, ASType, AWorkMode: Integer;
// AMultiSensor, AMultiValue: Boolean; AEditor: TCustomDesignParamEditor);
        { 2018-06-06 }
        procedure RegistFuncShowDataGraph(AFunc: TMethodByStr);
        procedure RegistFuncPopupDataGraph(AFunc: TMethodByStr);
        procedure RegistFuncPopupDataViewer(AFunc: TMethodByStr);
        procedure RegistFuncShowData(AFunc: TMethodByStr);

        { 注册与注销通用方法 }
        { 通用方法注册 }
        procedure RegistGeneralProc(AProcName: string; AProc: TGeneralProc);
        procedure RegistGeneralMethod(AMethodName: string; AMethod: TGeneralMethod);
        procedure RegistGeneralCompFunc(AFuncName: string; AFunc: TGeneralCompFunc);
        { 注销通用方法、过程 }
        procedure UnRegisterGeneral(AGeneralFuncName: string);
        procedure UnRegisterGeneralCompFunc(AFuncName: string);

        { 通用，但指定类型方法与过程注册 }
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByStr); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByStrings); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByList); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByStrArray); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByIntArray); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodByID); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TMethodNoneArg); overload;
        procedure RegisterMethod(MethodName: string; AMethod: TGeneralMethod); overload;

        procedure RegisterProc(AFuncName: string; AProc: TProcByStr); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByStrings); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByList); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByStrArray); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByIntArray); overload;
        procedure RegisterProc(AFuncName: string; AProc: TProcByID); overload;
        procedure RegisterProc(AFuncName: string; AProc: TGeneralProc); overload;
        { 注销上述这些注册 }
        procedure UnRegistMethodProc(AName: string);
        { 查找某方法是否已注册，供调用者决定自身的菜单与工具条设置 }
        function HasProc(AProcName: string): Boolean; overload;
        function HasProc(AProcName: string; ArgType: TArgType): Boolean; overload;
        function HasFunction(AFuncName: string): Boolean;
    end;

var
    FuncDispatcher: TFuncDispatchCenter;

implementation

type
    PGMRec = ^TGMRec;

    TGMRec = record
        MethodName: string;
        Method: TGeneralMethod;
    end;

    // 2013-07-05 试验
    // 测试使用相同的注册体结构注册方法与过程，如果可行则用这个统一管理注册的
    // 方法和过程
    // PMethod = ^TMethod;
    TFuncType = (ftGeneralProc, ftGeneralMethod, { 通用过程，方法 }
        ftMethodByStr, ftProcByStr,              { 字符串入参方法，过程 }
        ftMethodByStrings, ftProcByStrings, ftMethodByList, ftProcByList, ftMethodByStrArray,
        ftProcByStrArray, ftMethodByIntArray, ftProcByIntArray, ftMethodByID, ftProcByID,
        { 传入参数为ID的处理过程 }
        ftNoArgMethod,      { 无参方法 }
        ftProgressEvent,    { 进程事件 }
        ftGeneralCompFunc); { 通用返回组件的函数 }

    TFuncRegister = record
        FuncName: string;
        FuncType: TFuncType;
        Proc: Pointer;
        Method: TMethod;
    end;

    PFuncRegister = ^TFuncRegister;

{ ==============================================================================
                <<<<<<<<<<<<<   TFuncDispatchCenter   >>>>>>>>>>>>>>>
  ClassName:    TFuncDispatchCenter
  Comment:
 =============================================================================== }
constructor TFuncDispatchCenter.Create;
begin
    inherited;
    FProcList := TStringList.Create;
    FMethodList := TList.Create;
    FCompFuncList := TStringList.Create;
    { 2013-07-05 test }
    FFuncRegList := TList.Create;
end;

destructor TFuncDispatchCenter.Destroy;
var
    i: Integer;
begin
    FProcList.Free;
    FCompFuncList.Free;
    for i := 0 to FMethodList.Count - 1 do
        Dispose(PGMRec(FMethodList.Items[i]));
    FMethodList.Free;

    { 2013-07-05 test }
    for i := 0 to FFuncRegList.Count - 1 do
        Dispose(PFuncRegister(FFuncRegList.Items[i]));
    FFuncRegList.Free;

    inherited;
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.RegistFuncShowDMInfos
  Description:
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.RegistFuncShowDMInfos(AFunc: TMethodByStr);
begin
    FShowDMAndSensorInfo := AFunc;
end;

procedure TFuncDispatchCenter.UnRegisterFuncShowDMInfors;
begin
    FShowDMAndSensorInfo := nil;
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.RegistFuncRefreshDMList
  Description:
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.RegistFuncRefreshDMList(AFunc: TMethodNoneArg);
begin
    FRefreshDMList := AFunc;
end;

procedure TFuncDispatchCenter.UnRegisterFuncRefreshDMList;
begin
    FRefreshDMList := nil;
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.RegistFuncDrawTrendLine
  Description:
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.RegistFuncDrawTrendLine(AFunc: TMethodByStr);
var
    FuncReg: PFuncRegister;
begin
    FDrawTrendLineA := AFunc;

    { 2013-07-05 test }
    New(FuncReg);
    with FuncReg^ do
    begin
        FuncName := 'DrawTrendLine';
        FuncType := ftMethodByStr;
        Proc := nil;
        Method := TMethod(AFunc);
    end; // with
    FFuncRegList.Add(FuncReg);
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.ShowDMInfos
  Description:
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.ShowDMInfos(ADesignName: string);
begin
    if Assigned(FShowDMAndSensorInfo) then
        FShowDMAndSensorInfo(ADesignName);
end;

procedure TFuncDispatchCenter.ShowDataGraph(ADesignName: string; AContainer: TComponent = nil);
begin
    if Assigned(FShowDataGraph) then
        FShowDataGraph(ADesignName, AContainer);
end;

procedure TFuncDispatchCenter.PopupDataGraph(ADesignName: string; AContainer: TComponent = nil);
begin
    if Assigned(FPopupDataGraph) then
        FPopupDataGraph(ADesignName, AContainer);
end;

procedure TFuncDispatchCenter.PopupDataViewer(ADesignName: string; AContainer: TComponent = nil);
begin
    if Assigned(FPopupDataViewer) then
        FPopupDataViewer(ADesignName, AContainer);
end;

procedure TFuncDispatchCenter.ShowData(ADesignName: string; AContainer: TComponent = nil);
begin
    if Assigned(FShowData) then
        FShowData(ADesignName, AContainer);
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.DrawTrendLine
  Description:
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.DrawTrendLine(ADesignName: string);
var
    v: Variant;
// freg: pfuncregister;
// i: Integer;
begin
    if Assigned(FDrawTrendLineA) then
        FDrawTrendLineA(ADesignName)
    else if HasProc('DrawTrendLine', atStr) then
        CallFunction('DrawTrendLine', ADesignName);

// else if HasFunction('DrawTrendLine') then
// GeneralProc('DrawTrendLine', nil, [ADesignName], v);
    { 2013-07-05 测试 }
// for i := 0 to ffuncreglist.Count -1 do
// begin
// freg := ffuncreglist.Items[i];
// if sametext('DrawTrendLine', freg.FuncName) then
// begin
// TfuncSensorProc(freg.Method^)(ADesignName);
// Exit;
// end;
// end;
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.RefreshDMList
  Description:
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.RefreshDMList;
begin
    if Assigned(FRefreshDMList) then
        FRefreshDMList;
end;

{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.GeneralFunction
  Description:  通用方法调用
----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.GeneralProc(AProc: string; Sender: TObject;
    InParams: array of Variant; var OutParams: array of Variant);
var
    i : Integer;
    gp: TGeneralProc;
    gm: PGMRec;

    FuncReg: PFuncRegister;
begin
// i := FProcList.IndexOf(AProc);
// if i <> -1 then
// begin
// @gp := @TGeneralProc(FProcList.Objects[i]);
// gp(InParams, OutParams);
// end
// else
// for i := 0 to FMethodList.Count - 1 do
// begin
// gm := FMethodList[i];
// if SameText(AProc, gm.MethodName) then
// begin
// gm^.Method(Sender, InParams, OutParams);
// Exit;
// end;
// end;

    { 2013-07-06 test }
    for i := 0 to FFuncRegList.Count - 1 do
    begin
        FuncReg := FFuncRegList.Items[i];
        if FuncReg.FuncType <> ftGeneralProc then
            Continue;
        if not SameText(AProc, FuncReg.FuncName) then
            Continue;

        TGeneralProc(FuncReg.Proc)(InParams, OutParams);
    end;
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.BrowseSensorData
  Description:  浏览测点观测数据
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.BrowseSensorData(ADesignName: string);
var
    v: Variant;
begin
    if Assigned(FBrowseSensorData) then
        FBrowseSensorData(ADesignName)
    else if Self.HasFunction('BrowseSensorData') then
        GeneralProc('BrowseSensorData', nil, [ADesignName], v);
end;

{ ----------------------------------------------------------------------------- }
function TFuncDispatchCenter.GeneralCompFunc(AFunc: string; AOwner: TComponent;
    InParams: array of Variant): TComponent;
var
    i  : Integer;
    gcf: TGeneralCompFunc;
begin
    Result := nil;
    i := FCompFuncList.IndexOf(AFunc);
    if i <> -1 then
    begin
        try
            @gcf := @TGeneralCompFunc(FCompFuncList.Objects[i]);
            Result := gcf(AOwner, InParams);
        except
            on e: Exception do
                ShowMessage('执行' + AFunc + '出现错误：'#13#10 + e.Message);
        end;
    end;
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegistFuncBrowseSensorData(AFunc: TMethodByStr);
begin
    FBrowseSensorData := AFunc;
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.UnRegisterFuncBrowseSensorData;
begin
    FBrowseSensorData := nil;
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.RegistFuncDesignParamEdit
  Description:  编辑设计参数
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.RegistFuncDesignParamEdit(AFunc: TMethodByStr);
begin
    FDesignParamEdit := AFunc;
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.RegistFuncSensorParamEdit
  Description:  编辑仪器参数功能
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.RegistFuncSensorParamEdit(AFunc: TMethodByStr);
begin
    FSensorParamEdit := AFunc;
end;

procedure TFuncDispatchCenter.EditDesignParams(ADesignName: string);
begin
    if Assigned(FDesignParamEdit) then
        FDesignParamEdit(ADesignName)
    else
        ShowMessage('没有编辑器注册，无法编辑测点参数');
end;

procedure TFuncDispatchCenter.EditSensorParams(ADesignName: string);
begin
    if Assigned(FSensorParamEdit) then
        FSensorParamEdit(ADesignName)
    else
        ShowMessage('没有编辑器注册，无法编辑仪器参数');
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.EditSensorData
  Description:  编辑仪器数据功能
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.EditSensorData(ADesignName: string);
begin
    if Assigned(FSensorDataEdit) then
        FSensorDataEdit(ADesignName)
    else
        ShowMessage('没有数据编辑器注册，无法编辑仪器数据');
end;

procedure TFuncDispatchCenter.RegistFuncEditData(AFunc: TMethodByStr);
begin
    FSensorDataEdit := AFunc;
end;

procedure TFuncDispatchCenter.UnRegisterFuncEditData;
begin
    FSensorDataEdit := nil;
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.RefreshGroup
  Description:  刷新组
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.RefreshGroup;
begin
    if Assigned(FRefreshGroup) then
        FRefreshGroup;
end;

procedure TFuncDispatchCenter.RegistFuncRefreshGroup(AFunc: TMethodNoneArg);
begin
    FRefreshGroup := AFunc;
end;

procedure TFuncDispatchCenter.UnRegisterFuncRefreshGroup;
begin
    FRefreshGroup := nil;
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.AddPointToFavorite
  Description:
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.AddPointToFavorite(ADesignName: string);
begin
    if Assigned(FAddToFavorite) then
        FAddToFavorite(ADesignName);
end;

procedure TFuncDispatchCenter.RegistFuncAddToFavorite(AFunc: TMethodByStr);
begin
    FAddToFavorite := AFunc;
end;

procedure TFuncDispatchCenter.UnRegisterFuncAddToFavorite;
begin
    FAddToFavorite := nil;
end;
{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.AddPointToGroup
  Description:
----------------------------------------------------------------------------- }

procedure TFuncDispatchCenter.AddPointToGroup(ADesignName: string);
begin
    if Assigned(FAddToGroup) then
        FAddToGroup(ADesignName);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegistFuncAddToGroup(AFunc: TMethodByStr);
begin
    FAddToGroup := AFunc;
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.UnRegisterFuncAddToGroup;
begin
    FAddToGroup := nil;
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.DrawMultiTrendLine(ASensors: TStrings);
begin
    if Assigned(FDrawMultiLineA) then
        FDrawMultiLineA(ASensors);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegistFuncDrawMultiTrendLine(AFunc: TMethodByStrings);
begin
    FDrawMultiLineA := AFunc;
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.UnRegisterFuncDrawMultiTrendLine;
begin
    FDrawMultiLineA := nil;
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.GroupBrief(ASensors: TStrings);
begin
    if Assigned(FGroupBrief) then
        FGroupBrief(ASensors);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegistFuncGroupBrief(AFunc: TMethodByStrings);
begin
    FGroupBrief := AFunc;
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.UnRegisterFuncGroupBrief;
begin
    FGroupBrief := nil;
end;

procedure TFuncDispatchCenter.RegistFuncShowDataGraph(AFunc: TMethodByStr);
begin
    FShowDataGraph := AFunc;
end;

procedure TFuncDispatchCenter.RegistFuncPopupDataGraph(AFunc: TMethodByStr);
begin
    FPopupDataGraph := AFunc;
    { 同时注册到方法表中 }
    RegisterMethod('PopupDataGraph', AFunc);
end;

procedure TFuncDispatchCenter.RegistFuncPopupDataViewer(AFunc: TMethodByStr);
begin
    FPopupDataViewer := AFunc;
    RegisterMethod('PopupDataViewer', AFunc);
end;

procedure TFuncDispatchCenter.RegistFuncShowData(AFunc: TMethodByStr);
begin
    FShowData := AFunc;
    RegisterMethod('ShowData', AFunc);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegistGeneralProc(AProcName: string; AProc: TGeneralProc);
var
    i      : Integer;
    FuncReg: PFuncRegister;
begin
    i := FProcList.IndexOf(AProcName);
    { 如果有重名者，替换之 }
    if i = -1 then
        FProcList.AddObject(AProcName, TObject(@AProc))
    else
        FProcList.Objects[i] := TObject(@AProc);

    { 2013-07-06 }
    New(FuncReg);
    FuncReg.FuncName := AProcName;
    FuncReg.FuncType := ftGeneralProc;
    // FuncReg.Method := nil;
    FuncReg.Proc := @AProc;
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegistGeneralMethod(AMethodName: string; AMethod: TGeneralMethod);
var
    i    : Integer;
    found: Boolean;
    gm   : PGMRec;

    FuncReg: PFuncRegister; // 2013-07-06
begin
    found := False;
    for i := 0 to FMethodList.Count - 1 do
        if SameText(AMethodName, PGMRec(FMethodList[i]).MethodName) then
        begin
            found := True;
            break;
        end;

    if found then
    begin
        gm := FMethodList[i];
        gm.Method := AMethod;
    end
    else
    begin
        New(gm);
        gm^.MethodName := AMethodName;
        gm^.Method := AMethod;
        FMethodList.Add(gm);
    end;

    { 2013-07-06 Test }
    New(FuncReg);
    FuncReg.FuncName := AMethodName;
    FuncReg.FuncType := ftGeneralMethod;
    FuncReg.Proc := nil;
    FuncReg.Method := TMethod(AMethod);
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegistGeneralCompFunc(AFuncName: string; AFunc: TGeneralCompFunc);
var
    i: Integer;
begin
    i := FCompFuncList.IndexOf(AFuncName);
    if i = -1 then
        FCompFuncList.AddObject(AFuncName, TObject(@AFunc))
    else
        FCompFuncList.Objects[i] := TObject(@AFunc);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.UnRegisterGeneral(AGeneralFuncName: string);
var
    i : Integer;
    gm: PGMRec;
begin
    i := FProcList.IndexOf(AGeneralFuncName);

    if i <> -1 then
        FProcList.Delete(i);

    for i := 0 to FMethodList.Count - 1 do
    begin
        gm := FMethodList[i];
        if SameText(gm.MethodName, AGeneralFuncName) then
        begin
            FMethodList.Remove(gm);
            Dispose(gm);
            Exit;
        end;
    end;
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.UnRegisterGeneralCompFunc(AFuncName: string);
var
    i: Integer;
begin
    i := FCompFuncList.IndexOf(AFuncName);
    if i <> -1 then
        FProcList.Delete(i);
end;

{ ----------------------------------------------------------------------------- }
function TFuncDispatchCenter.HasProc(AProcName: string): Boolean;
var
    i: Integer;
begin
    Result := False;
    i := FProcList.IndexOf(AProcName);
    if i <> -1 then
    begin
        Result := True;
        Exit;
    end;

    for i := 0 to FMethodList.Count - 1 do
    begin
        if SameText(AProcName, PGMRec(FMethodList[i]).MethodName) then
        begin
            Result := True;
            Exit;
        end;
    end;

    for i := 0 to FFuncRegList.Count - 1 do
    begin
        if SameText(AProcName, PFuncRegister(FFuncRegList.Items[i]).FuncName) then
        begin
            Result := True;
            Exit;
        end;
    end;

    { 其他内置的方法 }
    if SameText('ShowDMInfos', AProcName) then
        Result := Assigned(FShowDMAndSensorInfo)
    else if SameText('RefreshDBList', AProcName) then
        Result := Assigned(FRefreshDMList)
    else if SameText('DrawTrendLine', AProcName) then
        Result := Assigned(FDrawTrendLineA)
    else if SameText('DrawMultiTrendLine', AProcName) then
        Result := Assigned(FDrawMultiLineA)
    else if SameText('RefreshGroup', AProcName) then
        Result := Assigned(FRefreshGroup)
    else if SameText('BrowseSensorData', AProcName) then
        Result := Assigned(FBrowseSensorData)
    else if SameText('EditDesignParams', AProcName) then
        Result := Assigned(FDesignParamEdit)
    else if SameText('EditSensorParams', AProcName) then
        Result := Assigned(FSensorParamEdit)
    else if SameText('EditSensorData', AProcName) then
        Result := Assigned(FSensorDataEdit)
    else if SameText('AddPointToFavorite', AProcName) then
        Result := Assigned(FAddToFavorite)
    else if SameText('AddPointToGroup', AProcName) then
        Result := Assigned(FAddToGroup)
    else if SameText('GroupBrief', AProcName) then
        Result := Assigned(FGroupBrief)
    else if SameText('SetupMeter', AProcName) then
        Result := (Assigned(FSetupMeter)) or (Assigned(FSetupMeterProc));
end;

{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.HasProc
  Description:  是否有指定名称、指定参数类型的方法或过程
----------------------------------------------------------------------------- }
function TFuncDispatchCenter.HasProc(AProcName: string; ArgType: TArgType): Boolean;
var
    i : Integer;
    FG: PFuncRegister;
begin
    Result := False;
    for i := 0 to FFuncRegList.Count - 1 do
    begin
        FG := FFuncRegList.Items[i];
        if not SameText(FG.FuncName, AProcName) then
            Continue;

        case ArgType of //
            atNone:
                Result := FG.FuncType = ftNoArgMethod;
            atStr:
                Result := FG.FuncType in [ftMethodByStr, ftProcByStr];
            atStrings:
                Result := FG.FuncType in [ftMethodByStrings, ftProcByStrings];
            atList:
                Result := FG.FuncType in [ftMethodByList, ftProcByList];
            atStrArray:
                Result := FG.FuncType in [ftMethodByStrArray, ftProcByStrArray];
            atIntArray:
                Result := FG.FuncType in [ftMethodByIntArray, ftProcByIntArray];
            atID:
                Result := FG.FuncType in [ftMethodByID, ftProcByID];
            atVariantArray:
                Result := FG.FuncType in [ftGeneralProc, ftGeneralMethod];
        end;

        if Result then
            Exit;
    end;
end;

{ ----------------------------------------------------------------------------- }
function TFuncDispatchCenter.HasFunction(AFuncName: string): Boolean;
var
    i: Integer;
begin
    Result := False;
    i := FCompFuncList.IndexOf(AFuncName);
    if i <> -1 then
    begin
        Result := True;
        Exit;
    end;
end;

{ ----------------------------------------------------------------------------- }
function TFuncDispatchCenter.GetGeneralProc(AProc: string): TGeneralProc;
var
    i: Integer;
begin
    Result := nil;
    i := FProcList.IndexOf(AProc);
    if i <> -1 then
        @Result := @TGeneralProc(FProcList.Objects[i]);
end;

{ ----------------------------------------------------------------------------- }
function TFuncDispatchCenter.GetGeneralMethod(AMethod: string): TGeneralMethod;
var
    i : Integer;
    gm: PGMRec;
begin
    Result := nil;
    for i := 0 to FMethodList.Count - 1 do
    begin
        gm := FMethodList[i];
        if SameText(AMethod, gm.MethodName) then
            Result := gm^.Method;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure:    TFuncDispatchCenter.UpdateMeter
  Description:	本方法用于加载指定ID的Meter参数并调用其Update方法。
  由于一次性从服务器获取全部仪器的Params极为耗时，因此采用了只根据meterParams
  表记录创建仪器对象但不设置参数的方法。为了能在使用时得到真实的仪器对象，就
  需要在后台或必须的时候设置所需要的仪器的参数，一次设置一只仪器。本注册方法
  就是用于设置空仪器参数的方法，供所需者调用。
----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.SetupMeter(AID: Integer);
begin
    if Assigned(FSetupMeter) then
        FSetupMeter(AID)
    else if Assigned(FSetupMeterProc) then
        FSetupMeterProc(AID)
    else
        ShowMessage('没有注册UpdateMeter方法');
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegistFuncSetupMeter(AFunc: TMethodByID);
begin
    FSetupMeter := AFunc;
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegistFuncSetupMeterProc(AProc: TProcByID);
begin
    FSetupMeterProc := AProc;
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.UnRegisterFuncSetupMeter;
begin
    FSetupMeter := nil;
    FSetupMeterProc := nil;
end;

{ -----------------------------------------------------------------------------
  Procedure:    _FindFuncReg
  Description:  查找某个注册
----------------------------------------------------------------------------- }
function _FindFuncReg(ARegName: string; RegList: TList): PFuncRegister;
var
    i: Integer;
begin
    Result := nil;
    for i := 0 to RegList.Count - 1 do
    begin
        if SameText(ARegName, PFuncRegister(RegList.Items[i]).FuncName) then
        begin
            Result := RegList.Items[i];
            Exit;
        end;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure:    _FindFuncRegByType
  Description:  查找指定名称、类型的注册
----------------------------------------------------------------------------- }
function _FindFuncRegByType(ARegName: string; AType: TFuncType; RegList: TList): PFuncRegister;
var
    i: Integer;
begin
    Result := nil;
    for i := 0 to RegList.Count - 1 do
    begin
        if PFuncRegister(RegList.Items[i]).FuncType <> AType then
            Continue;

        if SameText(ARegName, PFuncRegister(RegList.Items[i]).FuncName) then
        begin
            Result := RegList.Items[i];
            Exit;
        end;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure:    _FuncType2ArgType
  Description:
----------------------------------------------------------------------------- }
function _FuncType2ArgType(AFuncType: TFuncType): TArgType;
begin
    case AFuncType of //
        ftGeneralProc, ftGeneralMethod:
            Result := atVariantArray;
        ftMethodByStr, ftProcByStr:
            Result := atStr;
        ftMethodByStrings, ftProcByStrings:
            Result := atStrings;
        ftMethodByList, ftProcByList:
            Result := atList;
        ftMethodByStrArray, ftProcByStrArray:
            Result := atStrArray;
        ftMethodByIntArray, ftProcByIntArray:
            Result := atIntArray;
        ftMethodByID, ftProcByID:
            Result := atID;
        ftNoArgMethod:
            Result := atNone;
    else
        Result := atUndefine;
    end; // case
end;

{ -----------------------------------------------------------------------------
  Procedure:    _GetFuncRegByArgType
  Description:  查找符合名称和入参类型的方法或过程、函数。本函数用于外部调用，
  对于外部调用者来说，只要名称和入参符合即可调用执行，不在乎具体的执行者是方
  法、过程还是函数。
----------------------------------------------------------------------------- }
function _GetFuncRegByArgType(AFuncName: string; ArgType: TArgType; RegList: TList): PFuncRegister;
var
    i: Integer;
begin
    Result := nil;
    for i := 0 to RegList.Count - 1 do
    begin
        Result := RegList.Items[i];
        if SameText(Result.FuncName, AFuncName) then
            if _FuncType2ArgType(Result.FuncType) = ArgType then
                Exit;
    end;
    Result := nil;
end;

{ ----------------------------------------------------------------------------- }
{ 注册与注销指定类型通用方法 }
{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterMethod(MethodName: string; AMethod: TMethodByStr);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := MethodName;
    FuncReg^.FuncType := ftMethodByStr;
    FuncReg^.Proc := nil;
    FuncReg^.Method := TMethod(AMethod);
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterMethod(MethodName: string; AMethod: TMethodByStrings);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := MethodName;
    FuncReg^.FuncType := ftMethodByStrings;
    FuncReg^.Proc := nil;
    FuncReg^.Method := TMethod(AMethod);
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterMethod(MethodName: string; AMethod: TMethodByList);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := MethodName;
    FuncReg^.FuncType := ftMethodByList;
    FuncReg^.Proc := nil;
    FuncReg^.Method := TMethod(AMethod);
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterMethod(MethodName: string; AMethod: TMethodByStrArray);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := MethodName;
    FuncReg^.FuncType := ftMethodByStrArray;
    FuncReg^.Proc := nil;
    FuncReg^.Method := TMethod(AMethod);
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterMethod(MethodName: string; AMethod: TMethodByIntArray);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := MethodName;
    FuncReg^.FuncType := ftMethodByIntArray;
    FuncReg^.Proc := nil;
    FuncReg^.Method := TMethod(AMethod);
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterMethod(MethodName: string; AMethod: TMethodByID);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := MethodName;
    FuncReg^.FuncType := ftMethodByID;
    FuncReg^.Proc := nil;
    FuncReg^.Method := TMethod(AMethod);
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterMethod(MethodName: string; AMethod: TMethodNoneArg);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := MethodName;
    FuncReg^.FuncType := ftNoArgMethod;
    FuncReg^.Proc := nil;
    FuncReg^.Method := TMethod(AMethod);
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterMethod(MethodName: string; AMethod: TGeneralMethod);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := MethodName;
    FuncReg^.FuncType := ftGeneralMethod;
    FuncReg^.Proc := nil;
    FuncReg^.Method := TMethod(AMethod);
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterProc(AFuncName: string; AProc: TProcByStr);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := AFuncName;
    FuncReg^.FuncType := ftProcByStr;
    // FuncReg^.Method := nil;
    FuncReg^.Proc := @AProc;
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterProc(AFuncName: string; AProc: TProcByStrings);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := AFuncName;
    FuncReg^.FuncType := ftProcByStrings;
    // FuncReg^.Method := nil;
    FuncReg^.Proc := @AProc;
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterProc(AFuncName: string; AProc: TProcByList);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := AFuncName;
    FuncReg^.FuncType := ftProcByList;
    // FuncReg^.Method := nil;
    FuncReg^.Proc := @AProc;
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterProc(AFuncName: string; AProc: TProcByStrArray);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := AFuncName;
    FuncReg^.FuncType := ftProcByStrArray;
    // FuncReg^.Method := nil;
    FuncReg^.Proc := @AProc;
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterProc(AFuncName: string; AProc: TProcByIntArray);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := AFuncName;
    FuncReg^.FuncType := ftProcByIntArray;
    // FuncReg^.Method := nil;
    FuncReg^.Proc := @AProc;
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterProc(AFuncName: string; AProc: TProcByID);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := AFuncName;
    FuncReg^.FuncType := ftProcByID;
    // FuncReg^.Method := nil;
    FuncReg^.Proc := @AProc;
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.RegisterProc(AFuncName: string; AProc: TGeneralProc);
var
    FuncReg: PFuncRegister;
begin
    New(FuncReg);
    FuncReg^.FuncName := AFuncName;
    FuncReg^.FuncType := ftGeneralProc;
    // FuncReg^.Method := nil;
    FuncReg^.Proc := @AProc;
    FFuncRegList.Add(FuncReg);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.UnRegistMethodProc(AName: string);
var
    i: Integer;
begin
    for i := FFuncRegList.Count - 1 downto 0 do
    begin
        if SameText(AName, PFuncRegister(FFuncRegList.Items[i]).FuncName) then
        begin
            Dispose(FFuncRegList.Items[i]);
            FFuncRegList.Delete(i);
        end;
    end;
end;

{ ----------------------------------------------------------------------------- }
{ 调用指定类型的通用方法、过程 }
{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.CallFunction(FuncName: string; AStr: string);
var
    fr : PFuncRegister;
    Msg: string;
begin
    fr := _GetFuncRegByArgType(FuncName, atStr, FFuncRegList);
    if fr = nil then
    begin
        Msg := Format('没有找到名为%s的方法或过程', [FuncName]);
        MessageBox(0, PChar(Msg), '错误', MB_ICONERROR or MB_OK);
        Exit;
    end;
    { ------------------------ }
    case fr.FuncType of //
        ftMethodByStr:
            TMethodByStr(fr.Method)(AStr);
        ftProcByStr:
            TProcByStr(fr.Proc)(AStr);
    end; // case
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.CallFunction(FuncName: string; AStrings: TStrings);
var
    fr : PFuncRegister;
    Msg: string;
begin
    fr := _GetFuncRegByArgType(FuncName, atStrings, FFuncRegList);
    if fr = nil then
    begin
        Msg := Format('没有找到名为%s的方法或过程', [FuncName]);
        MessageBox(0, PChar(Msg), '错误', MB_ICONERROR or MB_OK);
        Exit;
    end;
    { ------------------------ }
    case fr.FuncType of //
        ftMethodByStrings:
            TMethodByStrings(fr.Method)(AStrings);
        ftProcByStrings:
            TProcByStrings(fr.Proc)(AStrings);
    end; // case
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.CallFunction(FuncName: string; AList: TList);
var
    fr : PFuncRegister;
    Msg: string;
begin
    fr := _GetFuncRegByArgType(FuncName, atList, FFuncRegList);
    if fr = nil then
    begin
        Msg := Format('没有找到名为%s的方法或过程', [FuncName]);
        MessageBox(0, PChar(Msg), '错误', MB_ICONERROR or MB_OK);
        Exit;
    end;
    { ------------------------ }
    case fr.FuncType of //
        ftMethodByList:
            TMethodByList(fr.Method)(AList);
        ftProcByList:
            TProcByList(fr.Proc)(AList);
    end; // case
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.CallFunction(FuncName: string; StrArray: TStringDynArray);
var
    fr : PFuncRegister;
    Msg: string;
begin
    fr := _GetFuncRegByArgType(FuncName, atStrArray, FFuncRegList);
    if fr = nil then
    begin
        Msg := Format('没有找到名为%s的方法或过程', [FuncName]);
        MessageBox(0, PChar(Msg), '错误', MB_ICONERROR or MB_OK);
        Exit;
    end;
    { ------------------------ }
    case fr.FuncType of //
        ftMethodByStrArray:
            TMethodByStrArray(fr.Method)(StrArray);
        ftProcByStrArray:
            TProcByStrArray(fr.Proc)(StrArray);
    end; // case
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.CallFunction(FuncName: string; IntArray: TIntegerDynArray);
var
    fr : PFuncRegister;
    Msg: string;
begin
    fr := _GetFuncRegByArgType(FuncName, atIntArray, FFuncRegList);
    if fr = nil then
    begin
        Msg := Format('没有找到名为%s的方法或过程', [FuncName]);
        MessageBox(0, PChar(Msg), '错误', MB_ICONERROR or MB_OK);
        Exit;
    end;
    { ------------------------ }
    case fr.FuncType of //
        ftMethodByIntArray:
            TMethodByIntArray(fr.Method)(IntArray);
        ftProcByIntArray:
            TProcByIntArray(fr.Proc)(IntArray);
    end; // case
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.CallFunction(FuncName: string; AID: Integer);
var
    fr : PFuncRegister;
    Msg: string;
begin
    fr := _GetFuncRegByArgType(FuncName, atID, FFuncRegList);
    if fr = nil then
    begin
        Msg := Format('没有找到名为%s的方法或过程', [FuncName]);
        MessageBox(0, PChar(Msg), '错误', MB_ICONERROR or MB_OK);
        Exit;
    end;
    { ------------------------ }
    case fr.FuncType of //
        ftMethodByID:
            TMethodByID(fr.Method)(AID);
        ftProcByID:
            TProcByID(fr.Proc)(AID);
    end; // case
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.CallFunction(FuncName: string);
var
    fr : PFuncRegister;
    Msg: string;
begin
    fr := _GetFuncRegByArgType(FuncName, atNone, FFuncRegList);
    if fr = nil then
    begin
        Msg := Format('没有找到名为%s的方法或过程', [FuncName]);
        MessageBox(0, PChar(Msg), '错误', MB_ICONERROR or MB_OK);
        Exit;
    end;
    { ------------------------ }
    { 调用方法 }
    TMethodNoneArg(fr.Method);
end;

{ ----------------------------------------------------------------------------- }
procedure TFuncDispatchCenter.CallFunction(FuncName: string; Sender: TObject;
    InParams: array of Variant; var OutParams: array of Variant);
var
    fr : PFuncRegister;
    Msg: string;
begin
    fr := _GetFuncRegByArgType(FuncName, atVariantArray, FFuncRegList);
    if fr = nil then
    begin
        Msg := Format('没有找到名为%s的方法或过程', [FuncName]);
        MessageBox(0, PChar(Msg), '错误', MB_ICONERROR or MB_OK);
        Exit;
    end;
    { ------------------------ }
    case fr.FuncType of //
        ftGeneralMethod:
            TGeneralMethod(fr.Method)(Sender, InParams, OutParams);
        ftGeneralProc:
            TGeneralProc(fr.Proc)(InParams, OutParams);
    end;
end;

{ ============================================================================ }
{ 下面的代码向IFuncCompManager注册本调度器 }
{ ============================================================================ }
var
    RegistRec: PFuncCompRegister;

    { -----------------------------------------------------------------------------
      Procedure:    InitDispatcher
      Description:  调度器初始化过程
    ----------------------------------------------------------------------------- }
function InitDispatcher(AppServices: IHJXAppServices): Boolean; stdcall;
begin
    Result := True;
    RegistRec.Initiated := True;
end;

{ -----------------------------------------------------------------------------
  Procedure:    RegistMe
  Description:  向功能管理器注册自己
----------------------------------------------------------------------------- }
procedure RegistMe;
    procedure OutRegister(out Value: PFuncCompRegister);
    begin
        with Value^ do
        begin
            FuncCompType := fctDispatcher;
            PluginType := ptBuildIn;
            requires := 'ClientDataModule';
            InitProc := InitDispatcher;
            Initiated := False;
            Version := '1.0.1';
            DateIssued := '2018-06-07';
            Description := '常用功能调度器及通用功能注册调度器';
            RegisterName := 'FunctionDispatcher';
        end;
    end;

begin
    New(RegistRec);
    // OutRegister(RegistRec);
    with RegistRec^ do
    begin
        FuncCompType := fctDispatcher;
        PluginType := ptBuildIn;
        RegisterName := 'FunctionDispatcher';
        requires := 'ClientDataModule';
        InitProc := InitDispatcher;
        Initiated := False;
        Version := '1.0.1';
        DateIssued := '2018-06-07';
        Description := '常用功能调度器及通用功能注册调度器';
    end; // with

    FuncDispatcher := TFuncDispatchCenter.Create;

    if Assigned(IFuncCompManager) then
        IFuncCompManager.RegisterDispatcher(RegistRec, FuncDispatcher);
end;

{ -----------------------------------------------------------------------------
  Procedure:    ReleaseDispatcher
  Description:
----------------------------------------------------------------------------- }
procedure ReleaseDispatcher;
begin
// with RegistRec^ do
// begin
// SetLength(RegisterName, 0);
// SetLength(Requires, 0);
// SetLength(Version, 0);
// SetLength(DateIssued, 0);
// SetLength(Description, 0);
// end;
    Dispose(RegistRec);
    FreeAndNil(FuncDispatcher);
end;

{ ============================================================================ }
initialization

RegistMe;

finalization

ReleaseDispatcher;

end.
