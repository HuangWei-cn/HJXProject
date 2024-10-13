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
{ todo:目前图形调度器仅支持每种特定类型监测仪器对应一种类型的图形，如常规内观监测仪器仅能显示过程线，
  水平位移测点仅显示矢量图、测斜孔仅显示倾斜曲线（尚未完成），还不支持一种仪器显示多种图形，如增量图、
  特征曲线，也不支持相关图、回归分析图 }
unit uHJX.IntfImp.GraphDispatcher;

interface

uses
  System.Classes, System.SysUtils, {System.Generics.Collections,}
  uHJX.Intf.AppServices, uHJX.Core.FuncCompTypes,
  uHJX.Intf.FuncCompManager,
  uHJX.Intf.GraphDispatcher,
  uHJX.Classes.Templates,
  uHJX.Template.TemplatesImp,
  Vcl.Controls, Vcl.Forms;

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

    FDrawGroupGraphFuncs: TList;

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

    procedure ShowGroupGraph(AGraphType: TGroupGraphType; AMeters: TStrings;
      AContainer: TComponent = nil);
    procedure PopupGroupGraph(AGraphType: TGroupGraphType; AMeters: TStrings;
      AContainer: TComponent = nil);
    procedure RegistDrawGroupGraphFunc(AGraphType: TGroupGraphType; AFunc: TDrawGroupgraphFunc);

    property ExportFunc: TExportChartToFileFunc read FExportFunc write FExportFunc;
    property SaveStreamFunc: TExportChartToStreamFunc read FSaveStreamFunc write FSaveStreamFunc;
  end;

implementation

uses
  uHJX.Classes.Meters, uHJX.Intf.FunctionDispatcher,
  uHJX.Template.ChartTemplate,
  ufrmTaskForm;

type
  // TDrawFunc = function(ADesignName: string): TFrame;
  // 绘图方法注册结构体
  TDrawFuncReg = record
    MeterType: string;
    ChartType: String;
    Func: TDrawFunc;
  end;

  PDrawFuncReg = ^TDrawFuncReg;

  // 导出到文件方法注册结构体
  TExportFuncReg = record
    MeterType: string;
    ChartType: string;
    Func: TExportChartToFileFunc;
  end;

  PExportFuncReg = ^TExportFuncReg;

  // 保存到Stream方法注册结构体
  TSaveToStreamFuncReg = record
    MeterType: string;
    ChartType: String;
    Func: TExportChartToStreamFunc;
  end;

  PSaveToStreamFuncReg = ^TSaveToStreamFuncReg;

  TDrawGroupGraphFuncReg = record
    GraphType: TGroupGraphType;
    Func: TDrawGroupgraphFunc;
  end;

  PDrawGroupGraphFuncReg = ^TDrawGroupGraphFuncReg;

var
  GraphDispatcher: TGraphDispatcher;
  Reg            : PFuncCompRegister;

constructor TGraphDispatcher.Create;
begin
  inherited;
  FDefFormWidth := 700;
  FDefFormHeight := 400;
  FDrawFuncs := TList.Create;
  FExpFuncs := TList.Create;
  FSaveToStreamFuncs := TList.Create;
  FDrawGroupGraphFuncs := TList.Create;
end;

destructor TGraphDispatcher.Destroy;
begin
  ClearFuncs;
  FDrawFuncs.Free;
  FExpFuncs.Free;
  FSaveToStreamFuncs.Free;
  FDrawGroupGraphFuncs.Free;
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
    for i := 0 to FDrawGroupGraphFuncs.Count - 1 do
      Dispose(FDrawGroupGraphFuncs.Items[i]);
  finally
    FDrawFuncs.Clear;
    FExpFuncs.Clear;
    FSaveToStreamFuncs.Clear;
    FDrawGroupGraphFuncs.Clear;
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
  MainForm: TForm;
  frm     : TTaskForm;
begin
  if AContainer <> nil then
    ShowDataGraph(ADesignName, AContainer)
  else
  begin
    { TODO -ohw -cGraphDispatcher : 当弹出窗口时，自动排列位置，使之整整齐齐 }
    MainForm := IAppServices.host as TForm;
    frm := TTaskForm.Create(MainForm);
    frm.OnClose := MainForm.OnClose;
    frm.width := FDefFormWidth;
    frm.height := FDefFormHeight;
    frm.OnResize := Self.Resize;
    // frm.BorderStyle := bsSizeToolWin;
    frm.ScreenSnap := True;
    frm.Tag := 100; // 凡Tag=100的，都是弹出的Chart
    frm.Caption := IAppServices.ClientDatas.GetMeterTypeName(ADesignName) + ADesignName + '观测数据图形';
    try
      Screen.Cursor := crHourGlass;
      ShowDataGraph(ADesignName, frm);
    finally
      Screen.Cursor := crDefault;
    end;
    frm.show;
  end;
end;

function _GetChartType(ChartName: string): string;
var
  tpl: ThjxTemplate;
begin
  Result := '';
  tpl := hjxTemplates.ItemByName[ChartName];
  if tpl <> nil then
    if tpl is TChartTemplate then
      case (tpl as TChartTemplate).ChartType of
        cttTrendLine:
          Result := '过程线';
        cttVector:
          Result := '矢量图';
        cttDisplacement:
          Result := '位移图';
        cttHoriLine:
          Result := '竖线图';
        cttPoints:
          Result := '散点图';
        cttBar:
          Result := '棒图';
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
    S  : String;
  begin
    Result := nil;
    /// 2023-06-23
    /// <summary>说明：
    /// 过程线定义模板的图形类型为“过程线”，在ufraTrendLineShell单元进行功能注册时，以“过程线”为名
    /// 进行了注册，即所有ChartTemplate的ChartType为cttTrendLine的模板都由ufraTrendLineShell负责
    /// 绘图；同时，该单元也注册了一大堆仪器类型，即若某仪器没有定义ChartTemplate，那么该仪器的类型
    /// 在ufraTrendLineShell注册的类型范围内，亦可绘制过程线。其他图形类似。
    /// 所以，在这里先找该仪器的模板，若存在则根据模板名称找到对应的处理方法；若没有模板，则根据仪器
    /// 类型找对应的处理方法。
    /// </summary>
    mt := ExcelMeters.Meter[ADesignName].DataSheetStru.ChartDefineName;
    if mt <> '' then
      S := _GetChartType(mt)
    else
      S := ExcelMeters.Meter[ADesignName].Params.MeterType;

    if S <> '' then
      for i := 0 to FDrawFuncs.Count - 1 do
      begin
        Reg := PDrawFuncReg(FDrawFuncs.Items[i]);
        if Reg.MeterType = S then
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
    if fra <> nil then
    begin
      fra.Align := alClient;
      fra.Parent := AContainer as TWinControl;
    end
    else
      raise Exception.Create('未知的仪器类型，无法绘制过程线。');
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
  /// 下面两句的说明参见ShowDataGraph方法中相应的语句说明
  // mt := ExcelMeters.Meter[ADesignName].Params.MeterType;
  mt := ExcelMeters.Meter[ADesignName].DataSheetStru.ChartDefineName;
  if mt <> '' then
    mt := _GetChartType(mt)
  else
    mt := ExcelMeters.Meter[ADesignName].Params.MeterType;

  if mt <> '' then
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
  // mt := ExcelMeters.Meter[ADesignName].Params.MeterType;
  mt := ExcelMeters.Meter[ADesignName].DataSheetStru.ChartDefineName;
  if mt <> '' then
    mt := _GetChartType(mt)
  else
    mt := ExcelMeters.Meter[ADesignName].Params.MeterType;

  if mt <> '' then
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

procedure TGraphDispatcher.RegistDrawGroupGraphFunc(AGraphType: TGroupGraphType;
  AFunc: TDrawGroupgraphFunc);
var
  NewReg: PDrawGroupGraphFuncReg;
begin
  New(NewReg);
  NewReg.GraphType := AGraphType;
  NewReg.Func := AFunc;
  FDrawGroupGraphFuncs.Add(NewReg);
end;

procedure TGraphDispatcher.ShowGroupGraph(AGraphType: TGroupGraphType; AMeters: TStrings;
  AContainer: TComponent = nil);
var
  fra: TFrame;
  function DrawGraph: TFrame;
  var
    i  : integer;
    Reg: PDrawGroupGraphFuncReg;
  begin
    Result := nil;
    for i := 0 to FDrawGroupGraphFuncs.Count - 1 do
    begin
      Reg := PDrawGroupGraphFuncReg(FDrawGroupGraphFuncs.Items[i]);
      if Reg.GraphType = AGraphType then
      begin
        Result := Reg.Func(AMeters, AContainer) as TFrame;
        break;
      end;
    end;

  end;

begin
  if AContainer = nil then
    PopupGroupGraph(AGraphType, AMeters, nil)
  else
  begin
    fra := DrawGraph;
    if fra <> nil then
    begin
      fra.Align := alClient;
      fra.Parent := AContainer as TWinControl;
    end
    else
      raise Exception.Create('未知的组图类型');
  end;
end;

procedure TGraphDispatcher.PopupGroupGraph(AGraphType: TGroupGraphType; AMeters: TStrings;
  AContainer: TComponent = nil);
var
  MainForm: TForm;
  frm     : TTaskForm;
begin
  if AContainer <> nil then
    ShowGroupGraph(AGraphType, AMeters, AContainer)
  else
  begin
    { TODO -ohw -cGraphDispatcher : 当弹出窗口时，自动排列位置，使之整整齐齐 }
    MainForm := IAppServices.host as TForm;
    frm := TTaskForm.Create(MainForm);
    frm.OnClose := MainForm.OnClose;
    frm.width := FDefFormWidth;
    frm.height := FDefFormHeight;
    frm.OnResize := Self.Resize;
    // frm.BorderStyle := bsSizeToolWin;
    frm.ScreenSnap := True;
    frm.Tag := 100; // 凡Tag=100的，都是弹出的Chart
    if AMeters.Count > 0 then
      frm.Caption := '仪器组图形(' + AMeters[0] + ' ~ ' + AMeters[AMeters.Count - 1] + ')'
    else
      frm.Caption := '仪器组图形：啥仪器都没有';
    { IAppServices.ClientDatas.GetMeterTypeName(ADesignName) + ADesignName
      + '观测数据图形'; }
    try
      Screen.Cursor := crHourGlass;
      ShowGroupGraph(AGraphType, AMeters, frm);
    finally
      Screen.Cursor := crDefault;
    end;
    frm.show;
  end;
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
