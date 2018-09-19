{ -----------------------------------------------------------------------------
 Unit Name: uHJX.IntfImp.GraphDispatcher
 Author:    黄伟
 Date:      17-七月-2018
 Purpose:   数据图接口的实现
            2018-07-17 取消了原ufuncDataGraph单元的功能，全部迁移至本单元实现，
            原uFuncDataGraph单元仅用于引用需要提供功能的实际功能单元。
 History:
----------------------------------------------------------------------------- }
{ todo:考虑如何让用户一次设置好所有弹出式Chart是否是极简风格 }
unit uHJX.IntfImp.GraphDispatcher;

interface

uses
    System.Classes, uHJX.Intf.AppServices, uHJX.Core.FuncCompTypes, uHJX.Intf.FuncCompManager,
    uHJX.Intf.GraphDispatcher, Vcl.Controls, Vcl.Forms;

type
    TGraphDispatcher = class(TInterfacedPersistent, IGraphDispatcher)
    private
        FExportFunc       : TExportChartToFileFunc;
        FSaveStreamFunc   : TExportChartToStreamFunc;
        FDefFormWidth     : integer;
        FDefFormHeight    : integer;
        FDrawFuncs        : TList;
        FExpFuncs         : TList;
        FSaveToStreamFuncs: TList;
        procedure ClearFuncs;
        procedure Resize(Sender: TObject);
    public
        constructor Create;
        destructor Destroy; override;

        procedure PopupDataGraph(ADesignName: string; AContainer: TComponent = nil);
        procedure ShowDataGraph(ADesignName: string; AContainer: TComponent = nil);
        function ExportChartToFile(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
            AWidth, AHeight: integer): string;
        function SaveChartToStream(ADesignName: string; DTStart, DTEnd: TDateTime; AStream: TStream;
            AWidth, AHeight: integer): Boolean;

        procedure RegistDrawfuncs(AMeterType: string; AFunc: TDrawFunc);
        procedure RegistExportFunc(AMeterType: string; AFunc: TExportChartToFileFunc);
        procedure RegistSaveStreamFunc(AMeterType: string; AFunc: TExportChartToStreamFunc);

        property ExportFunc: TExportChartToFileFunc read FExportFunc write FExportFunc;
        property SaveStreamFunc: TExportChartToStreamFunc read FSaveStreamFunc
            write FSaveStreamFunc;
    end;

implementation

uses
    uHJX.Classes.Meters, uHJX.Intf.FunctionDispatcher;

type
    // TDrawFunc = function(ADesignName: string): TFrame;
    // 绘图方法注册结构体
    TDrawFuncReg = record
        MeterType: string;
        Func: TDrawFunc;
    end;

    PDrawFuncReg = ^TDrawFuncReg;

    // 导出到文件方法注册结构体
    TExportFuncReg = record
        MeterType: string;
        Func: TExportChartToFileFunc;
    end;

    PExportFuncReg = ^TExportFuncReg;

    // 保存到Stream方法注册结构体
    TSaveToStreamFuncReg = record
        MeterType: string;
        Func: TExportChartToStreamFunc;
    end;

    PSaveToStreamFuncReg = ^TSaveToStreamFuncReg;

var
    GraphDispatcher: TGraphDispatcher;
    Reg            : PFuncCompRegister;

constructor TGraphDispatcher.Create;
begin
    inherited;
    FDefFormWidth := 600;
    FDefFormHeight := 400;
    FDrawFuncs := TList.Create;
    FExpFuncs := TList.Create;
    FSaveToStreamFuncs := TList.Create;
end;

destructor TGraphDispatcher.Destroy;
begin
    ClearFuncs;
    FDrawFuncs.Free;
    FExpFuncs.Free;
    FSaveToStreamFuncs.Free;
    inherited;
end;

procedure TGraphDispatcher.ClearFuncs;
var
    i: integer;
begin
    try
        for i := 0 to FDrawFuncs.Count - 1 do
            Dispose(FDrawFuncs.Items[i]);
        for i := 0 to FExpFuncs.Count - 1 do
            Dispose(FExpFuncs.Items[i]);
        for i := 0 to FSaveToStreamFuncs.Count - 1 do
            Dispose(FSaveToStreamFuncs.Items[i]);
    finally
        FDrawFuncs.Clear;
        FExpFuncs.Clear;
        FSaveToStreamFuncs.Clear;
    end;
end;

procedure TGraphDispatcher.Resize(Sender: TObject);
begin
    with Sender as TForm do
    begin
        FDefFormWidth := width;
        FDefFormHeight := height;
    end;
end;

procedure TGraphDispatcher.RegistDrawfuncs(AMeterType: string; AFunc: TDrawFunc);
var
    NewReg: PDrawFuncReg;
begin
    New(NewReg);
    NewReg.MeterType := AMeterType;
    NewReg.Func := AFunc;
    FDrawFuncs.Add(NewReg);
end;

procedure TGraphDispatcher.RegistExportFunc(AMeterType: string; AFunc: TExportChartToFileFunc);
var
    NewReg: PExportFuncReg;
begin
    New(NewReg);
    NewReg.MeterType := AMeterType;
    NewReg.Func := AFunc;
    FExpFuncs.Add(NewReg);
    // FExportFunc := AFunc;
end;

procedure TGraphDispatcher.RegistSaveStreamFunc(AMeterType: string;
    AFunc: TExportChartToStreamFunc);
var
    NewReg: PSaveToStreamFuncReg;
begin
    New(NewReg);
    NewReg.MeterType := AMeterType;
    NewReg.Func := AFunc;
    FSaveToStreamFuncs.Add(NewReg);
    // FSaveStreamFunc := AFunc;
end;

procedure TGraphDispatcher.PopupDataGraph(ADesignName: string; AContainer: TComponent = nil);
var
    frm, MainForm: TForm;
begin
    if AContainer <> nil then
        ShowDataGraph(ADesignName, AContainer)
    else
    begin
        MainForm := IAppServices.host as TForm;
        frm := TForm.Create(MainForm);
        frm.OnClose := MainForm.OnClose;
        frm.width := FDefFormWidth;
        frm.height := FDefFormHeight;
        frm.OnResize := Self.Resize;
        frm.BorderStyle := bsSizeToolWin;
        frm.ScreenSnap := True;
        frm.Caption := IAppServices.ClientDatas.GetMeterTypeName(ADesignName) + ADesignName
            + '观测数据图形';
        try
            Screen.Cursor := crHourGlass;
            ShowDataGraph(ADesignName, frm);
        finally
            Screen.Cursor := crDefault;
        end;
        frm.show;
    end;
end;

procedure TGraphDispatcher.ShowDataGraph(ADesignName: string; AContainer: TComponent = nil);
var
    fra: TFrame;
    function DrawDataGraph(ADesignName: string; AOwner: TComponent): TFrame;
    var
        mt : string;
        i  : integer;
        Reg: PDrawFuncReg;
    begin
        Result := nil;
        mt := ExcelMeters.Meter[ADesignName].Params.MeterType;
        for i := 0 to FDrawFuncs.Count - 1 do
        begin
            Reg := PDrawFuncReg(FDrawFuncs.Items[i]);
            if Reg.MeterType = mt then
            begin
                Result := Reg.Func(ADesignName, AOwner) as TFrame;
                break;
            end;
        end;
    end;

begin
    if AContainer = nil then
        PopupDataGraph(ADesignName, nil)
    else
    begin
        fra := DrawDataGraph(ADesignName, AContainer);
        fra.Align := alClient;
        fra.Parent := AContainer as TWinControl;
    end;
end;

function TGraphDispatcher.ExportChartToFile(ADesignName: string; DTStart, DTEnd: TDateTime;
    APath: string; AWidth: integer; AHeight: integer): string;
var
    mt : string;
    i  : integer;
    Reg: PExportFuncReg;
begin
    Result := '';
    if FExpFuncs.Count = 0 then
        Exit;
    mt := ExcelMeters.Meter[ADesignName].Params.MeterType;
    for i := 0 to FExpFuncs.Count - 1 do
    begin
        Reg := PExportFuncReg(FExpFuncs.Items[i]);
        if Reg.MeterType = mt then
        begin
            Result := Reg.Func(ADesignName, DTStart, DTEnd, APath, AWidth, AHeight);
            break;
        end;
    end;
// if Assigned(FExportFunc) then
// Result := FExportFunc(ADesignName, DTStart, DTEnd, APath, AWidth, AHeight);
end;

function TGraphDispatcher.SaveChartToStream(ADesignName: string; DTStart, DTEnd: TDateTime;
    AStream: TStream; AWidth: integer; AHeight: integer): Boolean;
var
    mt : string;
    i  : integer;
    Reg: PSaveToStreamFuncReg;
begin
    Result := False;
    if FSaveToStreamFuncs.Count = 0 then
        Exit;
    mt := ExcelMeters.Meter[ADesignName].Params.MeterType;
    for i := 0 to FSaveToStreamFuncs.Count - 1 do
    begin
        Reg := PSaveToStreamFuncReg(FSaveToStreamFuncs.Items[i]);
        if Reg.MeterType = mt then
        begin
            Result := Reg.Func(ADesignName, DTStart, DTEnd, AStream, AWidth, AHeight);
            break;
        end;
    end;
// if Assigned(FSaveStreamFunc) then
// Result := FSaveStreamFunc(ADesignName, DTStart, DTEnd, AStream, AWidth, AHeight);
end;

function InitProc(APP: IHJXAppServices): Boolean; stdcall;
begin
    Result := True;
end;

procedure RegistDispatcher;
begin
    New(Reg);
    Reg.FuncCompType := fctDispatcher;
    Reg.PluginType := ptBuildIn;
    Reg.InitProc := InitProc;
    Reg.RegisterName := 'GraphDispatcher';
    Reg.ServiceNames := 'GraphDispatcher';
    Reg.Requires := '';
    Reg.Version := '1.0.0';
    Reg.DateIssued := '2018-06-14';
    Reg.Description := '图形功能调度器';

    if Assigned(IFuncCompManager) then
        IFuncCompManager.RegisterDispatcher(Reg, GraphDispatcher);
    if Assigned(IAppServices) then
        with IAppServices.FuncDispatcher as IFunctionDispatcher do
        begin
            RegistFuncShowDataGraph(GraphDispatcher.ShowDataGraph);
            RegistFuncPopupDataGraph(GraphDispatcher.PopupDataGraph);
        end;
end;

initialization

GraphDispatcher := TGraphDispatcher.Create;
RegistDispatcher;

finalization

GraphDispatcher.Free;
Dispose(Reg);

end.
