{ -----------------------------------------------------------------------------
  Unit Name: uHJX.IntfImp.GraphDispatcher
  Author:    ��ΰ
  Date:      17-����-2018
  Purpose:   ����ͼ�ӿڵ�ʵ��
  2018-07-17 ȡ����ԭufuncDataGraph��Ԫ�Ĺ��ܣ�ȫ��Ǩ��������Ԫʵ�֣�
  ԭuFuncDataGraph��Ԫ������������Ҫ�ṩ���ܵ�ʵ�ʹ��ܵ�Ԫ��
  History:
  ----------------------------------------------------------------------------- }
{ todo:����������û�һ�����ú����е���ʽChart�Ƿ��Ǽ����� }
{ todo:Ŀǰͼ�ε�������֧��ÿ���ض����ͼ��������Ӧһ�����͵�ͼ�Σ��糣���ڹۼ������������ʾ�����ߣ�
  ˮƽλ�Ʋ�����ʾʸ��ͼ����б�׽���ʾ��б���ߣ���δ��ɣ�������֧��һ��������ʾ����ͼ�Σ�������ͼ��
  �������ߣ�Ҳ��֧�����ͼ���ع����ͼ }
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
  // ��ͼ����ע��ṹ��
  TDrawFuncReg = record
    MeterType: string;
    ChartType: String;
    Func: TDrawFunc;
  end;

  PDrawFuncReg = ^TDrawFuncReg;

  // �������ļ�����ע��ṹ��
  TExportFuncReg = record
    MeterType: string;
    ChartType: string;
    Func: TExportChartToFileFunc;
  end;

  PExportFuncReg = ^TExportFuncReg;

  // ���浽Stream����ע��ṹ��
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
    { TODO -ohw -cGraphDispatcher : ����������ʱ���Զ�����λ�ã�ʹ֮�������� }
    MainForm := IAppServices.host as TForm;
    frm := TTaskForm.Create(MainForm);
    frm.OnClose := MainForm.OnClose;
    frm.width := FDefFormWidth;
    frm.height := FDefFormHeight;
    frm.OnResize := Self.Resize;
    // frm.BorderStyle := bsSizeToolWin;
    frm.ScreenSnap := True;
    frm.Tag := 100; // ��Tag=100�ģ����ǵ�����Chart
    frm.Caption := IAppServices.ClientDatas.GetMeterTypeName(ADesignName) + ADesignName + '�۲�����ͼ��';
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
          Result := '������';
        cttVector:
          Result := 'ʸ��ͼ';
        cttDisplacement:
          Result := 'λ��ͼ';
        cttHoriLine:
          Result := '����ͼ';
        cttPoints:
          Result := 'ɢ��ͼ';
        cttBar:
          Result := '��ͼ';
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
    /// <summary>˵����
    /// �����߶���ģ���ͼ������Ϊ�������ߡ�����ufraTrendLineShell��Ԫ���й���ע��ʱ���ԡ������ߡ�Ϊ��
    /// ������ע�ᣬ������ChartTemplate��ChartTypeΪcttTrendLine��ģ�嶼��ufraTrendLineShell����
    /// ��ͼ��ͬʱ���õ�ԪҲע����һ����������ͣ�����ĳ����û�ж���ChartTemplate����ô������������
    /// ��ufraTrendLineShellע������ͷ�Χ�ڣ���ɻ��ƹ����ߡ�����ͼ�����ơ�
    /// ���ԣ����������Ҹ�������ģ�壬�����������ģ�������ҵ���Ӧ�Ĵ���������û��ģ�壬���������
    /// �����Ҷ�Ӧ�Ĵ�������
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
      raise Exception.Create('δ֪���������ͣ��޷����ƹ����ߡ�');
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
  /// ���������˵���μ�ShowDataGraph��������Ӧ�����˵��
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
      raise Exception.Create('δ֪����ͼ����');
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
    { TODO -ohw -cGraphDispatcher : ����������ʱ���Զ�����λ�ã�ʹ֮�������� }
    MainForm := IAppServices.host as TForm;
    frm := TTaskForm.Create(MainForm);
    frm.OnClose := MainForm.OnClose;
    frm.width := FDefFormWidth;
    frm.height := FDefFormHeight;
    frm.OnResize := Self.Resize;
    // frm.BorderStyle := bsSizeToolWin;
    frm.ScreenSnap := True;
    frm.Tag := 100; // ��Tag=100�ģ����ǵ�����Chart
    if AMeters.Count > 0 then
      frm.Caption := '������ͼ��(' + AMeters[0] + ' ~ ' + AMeters[AMeters.Count - 1] + ')'
    else
      frm.Caption := '������ͼ�Σ�ɶ������û��';
    { IAppServices.ClientDatas.GetMeterTypeName(ADesignName) + ADesignName
      + '�۲�����ͼ��'; }
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
  Reg.Description := 'ͼ�ι��ܵ�����';

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
