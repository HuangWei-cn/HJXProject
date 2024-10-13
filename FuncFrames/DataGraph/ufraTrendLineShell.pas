{ -----------------------------------------------------------------------------
  Unit Name: Unit1
  Author:    黄伟
  Date:      04-五月-2018
  Purpose:   fraBaseTrendLine的壳，负责调用该Frame，本单元为其封装。
  需要绘制过程线的功能块则调用本Frame。
  TfraTrendLineShell组件一方面可以作为独立组件被实例化，在用户程序
  中显示出来，成为用户程序中的一部分；另一方面，本单元向图形调度器
  提供了DrawMeterGraph方法的实际执行者。
  History:   2018-07-26 增加根据预定义Template绘图的功能
  2018-09-21 当Frame宽度小于450或高度小于210时，自动转变为极简模式

  2022-10-27 增加了DrawMultiLine方法，支持绘制给定的一组仪器过程线
  注册方法：DrawGroupLine，调用TfraTrendLineShell的DrawMultiLine
  方法；
  DrawMultiLine则调用ChartTemplateProc.DrawGroupLines方法完成绘制
  过程。
  为能将平面变形测点的过程线也绘制出来，在预定义模板中定义了平面
  测点，但在本过程没有向GraphDispatcher中注册该类型的过程线，因此
  在绘制平面点时，仍然是绘制其矢量图。只有在绘制组过程线时才会绘
  制平面点的过程线。单个平面点的过程线在它单独的绘制方法中已经有了
  ----------------------------------------------------------------------------- }

unit ufraTrendLineShell;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  uHJX.Intf.Datas, uHJX.Intf.AppServices, uHJX.Intf.GraphDispatcher, uHJX.ProjectGlobal,
  ufraBasicTrendLine {, uFuncDataGraph};

type
  TfraTrendLineShell = class(TFrame)
    procedure FrameResize(Sender: TObject);
  private
    { Private declarations }
    FMeterName      : String;
    FDTStart, FDTEnd: TDateTime;
    FfraTL          : TfraBasicTrendLine;
    // 根据仪器类型设置坐标轴标题,本方法为临时方法
    procedure SetAxisTitles(AMeterType: string);
    { 绘制通用仪器过程线，多点、锚杆之类的 }
    procedure _DrawNormalLine(ADsnName: string; DTStart, DTEnd: TDateTime);
    { 绘制锚杆组过程线 }
    procedure _DrawMGGroupLine(AGrpName: string; DTStart, DTEnd: TDateTime);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { -------------- }
    { 给设计编号，显示全部数据的过程线。目前不考虑过程线样式之类的东东 }
    procedure DrawLine(ADsnName: string); overload; // 2018-06-05 方法名应改为DrawDatas，以统一各类图形
    { 之所以重载DrawLine方法，是为了不改变其他代码。当然，最终两个方法将合二为一 }
    procedure DrawLine(ADsnName: string; DTStart, DTEnd: TDateTime); overload;
    { 绘制多仪器的过程线在一个Chart中 }
    procedure DrawMutiLine(AMeters: TStrings);
  end;

implementation

uses
  {uHJX.Excel.Meters} uHJX.Classes.Meters, uHJX.Classes.Templates,
  {
    uTLDefineProc, uFuncDrawTLByStyle, //2018-07-26增加根据Style绘图相关的单元
    2018-09-13 这两个单元被ChartTemplate、ChartTemplateProc单元取代
  }
  uHJX.Template.ChartTemplate, uHJX.Template.ChartTemplateProc, // 2018-09-13 新绘图模板类及其处理
  VCLTee.TeeJPEG, VCLTee.TeePNG, VCLTee.TeeHTML5Canvas;
{$R *.dfm}

var
  fraTLTool: TfraTrendLineShell; // 本单元初始化时创建一个实例，用于导出过程线
  JpgFmt   : TJPEGExportFormat;

constructor TfraTrendLineShell.Create(AOwner: TComponent);
begin
  inherited;
  FfraTL := TfraBasicTrendLine.Create(Self);
  FfraTL.Parent := Self;
  FfraTL.Align := alClient;
end;

destructor TfraTrendLineShell.Destroy;
begin
  FfraTL.Free;
  inherited;
end;

{ -----------------------------------------------------------------------------
  Procedure  : DrawLine
  Description: 给个设计编号，显示该仪器的测值过程线
  ----------------------------------------------------------------------------- }
procedure TfraTrendLineShell.DrawLine(ADsnName: string);
var
  mt: TMeterDefine;
begin
  FMeterName := ADsnName;
  FDTStart := 0;
  FDTEnd := 0;
  FfraTL.ReleaseTrendLines;
  // FfraTL.ClearDatas(FfraTL.Series1);
  if IHJXClientFuncs = nil then
    Exit;

  mt := ExcelMeters.Meter[ADsnName];
  { 2018-07-26 用过程线定义绘图 }
  if mt.ChartPreDef <> nil then
    DrawMeterSeries(FfraTL.chtLine, mt.ChartPreDef as TChartTemplate { TTrendlinePreDefine } ,
      ADsnName, 0, 0)
  else
  begin
    if (mt.Params.MeterType = '锚杆应力计') and (mt.PrjParams.GroupID <> '') then
      _DrawMGGroupLine(mt.PrjParams.GroupID, 0, 0)
    else
      _DrawNormalLine(mt.DesignName, 0, 0);
  end;
  // 测试代码，绘图完毕，保存
  // FfraTL.chtLine.SaveToMetafileEnh('e:\test_'+adsnname+'.emf');
end;

procedure TfraTrendLineShell.DrawLine(ADsnName: string; DTStart: TDateTime; DTEnd: TDateTime);
var
  mt: TMeterDefine;
begin
  if (DTStart = 0) and (DTEnd = 0) then
    DrawLine(ADsnName)
  else
  begin
    FMeterName := ADsnName;
    FDTStart := DTStart;
    FDTEnd := DTEnd;
    FfraTL.ReleaseTrendLines;
    if IHJXClientFuncs = nil then
      Exit;
    mt := ExcelMeters.Meter[ADsnName];
    { 2018-07-26 用过程线预定义绘图 }
    if mt.ChartPreDef <> nil then
      DrawMeterSeries(FfraTL.chtLine, mt.ChartPreDef as TChartTemplate { TTrendlinePreDefine } ,
        ADsnName, DTStart, DTEnd)
    else
    begin
      if (mt.Params.MeterType = '锚杆应力计') and (mt.PrjParams.GroupID <> '') then
        _DrawMGGroupLine(mt.PrjParams.GroupID, DTStart, DTEnd)
      else
        _DrawNormalLine(mt.DesignName, DTStart, DTEnd);
    end;
  end;
end;

procedure TfraTrendLineShell.FrameResize(Sender: TObject);
begin
  if (Width <= 450) or (Height <= 210) then
    FfraTL.Minimalism := True
  else
    FfraTL.Minimalism := False;
end;

{ -----------------------------------------------------------------------------
  Procedure  : _DrawNormalLine
  Description: 绘制普通仪器的过程线
  ----------------------------------------------------------------------------- }
procedure TfraTrendLineShell._DrawNormalLine(ADsnName: string; DTStart, DTEnd: TDateTime);
var
  DS  : TClientDataSet;
  Flds: TList;
  NewL: Integer;
  i   : Integer;
  mt  : TMeterDefine;
  // 锚索测力计过程线
  procedure _SetMSLines;
  begin
    FfraTL.NewLine(DS.Fields[1].DisplayName);        // 拉力，预应力
    FfraTL.NewLine(DS.Fields[2].DisplayName, False); // 温度
    DS.First;
    repeat
      FfraTL.AddData(0, DS.Fields[0].AsDateTime, DS.Fields[1].Value { .AsFloat } );
      FfraTL.AddData(1, DS.Fields[0].AsDateTime, DS.Fields[2].Value { .AsFloat } );
      DS.Next;
    until DS.Eof;
  end;

begin
  mt := ExcelMeters.Meter[ADsnName];
  SetAxisTitles(mt.Params.MeterType);
  DS := TClientDataSet.Create(Self);
  Flds := TList.Create;
  try
    if (DTStart = 0) and (DTEnd = 0) then
    begin
      if (TrendLineSetting.DTStart = 0) and (TrendLineSetting.DTEnd = 0) then
        IHJXClientFuncs.GetAllPDDatas(ADsnName, DS)
      else
        IHJXClientFuncs.GetPDDatasInPeriod(ADsnName, TrendLineSetting.DTStart,
          TrendLineSetting.DTEnd, DS);
    end
    else
    begin
      if DTEnd = 0 then
        DTEnd := Now;
      IHJXClientFuncs.GetPDDatasInPeriod(ADsnName, DTStart, DTEnd, DS);
    end;

    FfraTL.SetChartTitle(mt.Params.MeterType + ADsnName + '历时过程线图');
    // FfraTL.Series1.Title := ds.Fields[1].DisplayName;
    // 判断是否取回数据
    if DS.RecordCount <> 0 then
    begin
      // 对每个物理量创建一个Line
      if mt.Params.MeterType = '锚索测力计' then
        _SetMSLines
      else
      begin
        for i := 1 to DS.FieldCount - 1 do
          if DS.Fields[i].DataType = ftFloat then
          begin
            if Pos('温度', DS.Fields[i].DisplayName) = 0 then
              NewL := FfraTL.NewLine(DS.Fields[i].DisplayName)
            else
              NewL := FfraTL.NewLine(DS.Fields[i].DisplayName, False);

            // 由于所有的浮点字段都创建一条线，因此将Serials序号和字段对应起来
            // Flds集合中的Index对应着FFraTL中Serials的序号，Item对应着数据字段
            Flds.Add(DS.Fields[i]);
          end;

        DS.First;
        repeat
          // fields[0]为观测日期
          // for i := 1 to DS.FieldCount - 1 do
          // FfraTL.DrawLine(i - 1, DS.Fields[0].AsDateTime, DS.Fields[i].AsFloat);
          for i := 0 to Flds.Count - 1 do
            FfraTL.AddData(i, DS.Fields[0].AsDateTime, TField(Flds.Items[i]).Value);
          (* 2022-05-11 原代码避开了Null点，将导致过程线不符合实际，比如渗压计水位曲线
            if not TField(Flds.Items[i]).IsNull then
            FfraTL.AddData(i, DS.Fields[0].AsDateTime, TField(Flds.Items[i]).AsFloat);
          *)
          DS.Next;
        until DS.Eof;
      end;
    end;
  finally
    DS.Free;
    Flds.Free;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : _DrawMGGroupLine
  Description: 绘制锚杆组过程线
  ----------------------------------------------------------------------------- }
procedure TfraTrendLineShell._DrawMGGroupLine(AGrpName: string; DTStart, DTEnd: TDateTime);
var
  DS  : TClientDataSet;
  NewL: Integer;
  iMT : Integer;
  mt  : TMeterDefine;
  grp : TMeterGroupItem;
begin
  grp := MeterGroup.ItemByName[AGrpName];
  if grp = nil then
    Exit;
  DS := TClientDataSet.Create(Self);
  mt := ExcelMeters.Meter[grp.Items[0]];
  FfraTL.SetChartTitle(mt.Params.MeterType + '组' + AGrpName + '历时过程线图');
  SetAxisTitles(mt.Params.MeterType);

  // 提取、填入数据；
  try
    for iMT := 0 to grp.Count - 1 do
    begin
      mt := ExcelMeters.Meter[grp.Items[iMT]];
      if mt = nil then
        Continue;

      // 取回这支仪器的数据
      if (DTStart = 0) and (DTEnd = 0) then
        IHJXClientFuncs.GetAllPDDatas(mt.DesignName, DS)
      else
      begin
        if DTEnd = 0 then
          DTEnd := Now;
        IHJXClientFuncs.GetPDDatasInPeriod(mt.DesignName, DTStart, DTEnd, DS);
      end;
      if DS.RecordCount > 0 then
      begin
        NewL := FfraTL.NewLine(mt.DesignName + mt.PDName(0));
        DS.First;
        repeat
          FfraTL.AddData(NewL, DS.Fields[0].AsDateTime, DS.Fields[1].Value);
          { 2022-05-11 原代码避开了Null点，将导致过程线不符合实际
            if not DS.Fields[1].IsNull then
            FfraTL.AddData(NewL, DS.Fields[0].AsDateTime, DS.Fields[1].AsFloat);
          }
          DS.Next;
        until DS.Eof;
      end;
    end;

  finally
    DS.Free;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : SetAxisTitles
  Description: 设置坐标轴标题
  ----------------------------------------------------------------------------- }
procedure TfraTrendLineShell.SetAxisTitles(AMeterType: string);
begin
  if AMeterType = '多点位移计' then
  begin
    FfraTL.chtLine.LeftAxis.Title.Caption := '位移(mm)';
  end
  else if AMeterType = '锚索测力计' then
  begin
    FfraTL.chtLine.LeftAxis.Title.Caption := '预应力(kN)';
    FfraTL.chtLine.RightAxis.Title.Caption := '温度(℃)';
  end
  else if AMeterType = '锚杆应力计' then
  begin
    FfraTL.chtLine.LeftAxis.Title.Caption := '荷载(kN)';
    FfraTL.chtLine.RightAxis.Title.Caption := '温度(℃)';
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : DrawMutiLine
  Description: 2022-10-27绘制一组仪器的过程线在一个Chart中
  ----------------------------------------------------------------------------- }
procedure TfraTrendLineShell.DrawMutiLine(AMeters: TStrings);
begin
  // ShowMessage('哦吼，想要一组过程线了 :) 仪器：' + IntToStr(AMeters.Count));
  DrawGroupLines(FfraTL.chtLine, AMeters);
end;

{ -----------------------------------------------------------------------------
  Procedure  : DrawTrendLine
  Description: 注册的绘图方法
  ----------------------------------------------------------------------------- }
function DrawTrendLine(ADesignName: String; AOwner: TComponent): TComponent; // TFrame;
begin
  Result := TfraTrendLineShell.Create(AOwner);
  (Result as TfraTrendLineShell).DrawLine(ADesignName);
end;

{ -----------------------------------------------------------------------------
  Procedure  : DrawGroupLine
  Description: 用于注册的绘制任意给定一组仪器过程线的方法
  ----------------------------------------------------------------------------- }
function DrawGroupLine(AMeters: TStrings; AOwner: TComponent): TComponent;
begin
  Result := TfraTrendLineShell.Create(AOwner);
  (Result as TfraTrendLineShell).DrawMutiLine(AMeters);
end;

{ -----------------------------------------------------------------------------
  Procedure  : ExportGraphToFile
  Description: 注册的导出图形到JPEG格式方法。返回值为Path+ADesignName+'.jpg'
  ----------------------------------------------------------------------------- }
function ExportGraphToFile(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
  AWidth, AHeight: Integer): string;
var
  S      : string;
  TmpPath: array [0 .. 255] of Char;
begin
  if not Assigned(fraTLTool) then
    fraTLTool := TfraTrendLineShell.Create(nil);
  fraTLTool.Width := AWidth;
  fraTLTool.Height := AHeight;
  fraTLTool.DrawLine(ADesignName, DTStart, DTEnd);
  if (APath = '') or not DirectoryExists(APath) then
  begin
    Winapi.Windows.GetTempPath(255, @TmpPath);
    APath := StrPas(TmpPath);
  end;

  S := APath + ADesignName + '.jpg';
  fraTLTool.FfraTL.chtLine.Legend.CheckBoxes := False;
  TeeSaveToJPEG(fraTLTool.FfraTL.chtLine, S, AWidth, AHeight);
  Result := S;
end;

{ -----------------------------------------------------------------------------
  Procedure  : ExportGraphToStream
  Description: 注册的导出图形到Stream方法
  ----------------------------------------------------------------------------- }
function ExportGraphToStream(ADesignName: string; DTStart, DTEnd: TDateTime; var AStream: TStream;
  AWidth, AHeight: Integer): Boolean;
begin
  if not Assigned(fraTLTool) then
    fraTLTool := TfraTrendLineShell.Create(nil);
  fraTLTool.Width := AWidth;
  fraTLTool.Height := AHeight;

  if not Assigned(JpgFmt) then
    JpgFmt := TJPEGExportFormat.Create;

  JpgFmt.Panel := fraTLTool.FfraTL.chtLine;
  fraTLTool.DrawLine(ADesignName);
  fraTLTool.FfraTL.chtLine.Legend.CheckBoxes := False;
  JpgFmt.SaveToStream(AStream);
  Result := True;
end;

procedure RegistSelf;
var
  IGD: IGraphDispatcher;
  //TS : TTemplates;
  //CT : TChartTemplate;
  //i  : Integer;
begin
  if Assigned(IAppServices) then
    if IAppServices.GetDispatcher('GraphDispatcher') <> nil then
      if Supports(IAppServices.GetDispatcher('GraphDispatcher'), IGraphDispatcher, IGD) then
      begin
        //TS := IAppServices.Templates as TTemplates;
        /// 所有过程线均用本模块绘图
        IGD.RegistDrawFuncs('过程线', DrawTrendLine);
        IGD.RegistExportFunc('过程线', ExportGraphToFile);
        IGD.RegistSaveStreamFunc('过程线', ExportGraphToStream);
        {
          for i := 0 to ts.ChartTemplateCount  -1 do
          begin
          ct := ts.ChartTemplate[i] as Tcharttemplate;
          if ct.ChartType = cttTrendLine then
          begin
          ///这里尝试用模板名代替仪器类型，与此同时应该更改GraphDispatcher中调度方法，那里是根据
          ///  注册结构来分配的，而注册结构是用仪器类型……
          ///  可惜，这个做法是错误的。当本单元注册时，参数表还没有加载，模板数量是0……
          IGD.RegistDrawFuncs(ct.TemplateName , DrawTrendLine);
          IGD.RegistExportFunc(ct.TemplateName, ExportGraphToFile);
          IGD.RegistSaveStreamFunc(ct.TemplateName, ExportGraphToStream);
          end;
          end;
        }
        { 2018-07-26 现在具备了根据预定义的Style绘图的功能，理论上讲，只要一个仪器有对应的
          Style，则无论仪器类型都可以绘图，这种根据仪器类型进行绘图注册的方式已经落后于时代
          了，需要改进 }
        { DONE -ohw -cDrawGraph : 注册方法应该改进，根据模板中仪器类型和图形类型注册，而非代码中写死 }
        /// 这里注册仪器类型的原因是，若一支仪器的ChartTemplate为空，则根据仪器类型绘图，若类型符合
        ///  注册类型，就可以用此功能。
        IGD.RegistDrawFuncs('多点位移计', DrawTrendLine);
        IGD.RegistDrawFuncs('锚索测力计', DrawTrendLine);
        IGD.RegistDrawFuncs('锚杆应力计', DrawTrendLine);
        IGD.RegistDrawFuncs('应变计', DrawTrendLine);
        IGD.RegistDrawFuncs('无应力计', DrawTrendLine);
        IGD.RegistDrawFuncs('基岩变形计', DrawTrendLine);
        IGD.RegistDrawFuncs('渗压计', DrawTrendLine);
        IGD.RegistDrawFuncs('测压管', DrawTrendLine);
        IGD.RegistDrawFuncs('水位计', DrawTrendLine);
        IGD.RegistDrawFuncs('测缝计', DrawTrendLine);
        IGD.RegistDrawFuncs('裂缝计', DrawTrendLine);
        IGD.RegistDrawFuncs('位错计', DrawTrendLine);
        IGD.RegistDrawFuncs('钢筋计', DrawTrendLine);
        IGD.RegistDrawFuncs('钢板计', DrawTrendLine);
        IGD.RegistDrawFuncs('温度计', DrawTrendLine);
        IGD.RegistDrawFuncs('水位', DrawTrendLine);
        IGD.RegistDrawFuncs('量水堰', DrawTrendLine);
        IGD.RegistDrawFuncs('水位观测孔', DrawTrendLine);
        IGD.RegistDrawFuncs('环境量', DrawTrendLine);
        IGD.RegistDrawFuncs('静力水准', DrawTrendLine);
        IGD.RegistDrawFuncs('引张线', DrawTrendLine);
        IGD.RegistDrawFuncs('双金属标', DrawTrendLine);

        IGD.RegistExportFunc('多点位移计', ExportGraphToFile);
        IGD.RegistExportFunc('锚索测力计', ExportGraphToFile);
        IGD.RegistExportFunc('锚杆应力计', ExportGraphToFile);
        IGD.RegistExportFunc('应变计', ExportGraphToFile);
        IGD.RegistExportFunc('无应力计', ExportGraphToFile);
        IGD.RegistExportFunc('基岩变形计', ExportGraphToFile);
        IGD.RegistExportFunc('渗压计', ExportGraphToFile);
        IGD.RegistExportFunc('测压管', ExportGraphToFile);
        IGD.RegistExportFunc('水位计', ExportGraphToFile);
        IGD.RegistExportFunc('测缝计', ExportGraphToFile);
        IGD.RegistExportFunc('裂缝计', ExportGraphToFile);
        IGD.RegistExportFunc('位错计', ExportGraphToFile);
        IGD.RegistExportFunc('钢筋计', ExportGraphToFile);
        IGD.RegistExportFunc('钢板计', ExportGraphToFile);
        IGD.RegistExportFunc('温度计', ExportGraphToFile);
        IGD.RegistExportFunc('水位', ExportGraphToFile);
        IGD.RegistExportFunc('量水堰', ExportGraphToFile);
        IGD.RegistExportFunc('水位观测孔', ExportGraphToFile);
        IGD.RegistExportFunc('环境量', ExportGraphToFile);
        IGD.RegistExportFunc('静力水准', ExportGraphToFile);
        IGD.RegistExportFunc('引张线', ExportGraphToFile);
        IGD.RegistExportFunc('双金属标', ExportGraphToFile);

        IGD.RegistSaveStreamFunc('多点位移计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('锚索测力计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('锚杆应力计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('基岩变形计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('渗压计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('测压管', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('水位计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('测缝计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('裂缝计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('位错计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('钢筋计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('钢板计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('温度计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('应变计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('无应力计', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('水位', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('量水堰', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('水位观测孔', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('环境量', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('静力水准', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('引张线', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('双金属标', ExportGraphToStream);

        IGD.RegistDrawGroupGraphFunc(ggtTrendLine, DrawGroupLine);
      end;

  // uFuncDataGraph.RegistDrawFuncs('多点位移计', DrawTrendLine);
  // uFuncDataGraph.RegistDrawFuncs('锚索测力计', DrawTrendLine);
  // uFuncDataGraph.RegistDrawFuncs('锚杆应力计', DrawTrendLine);
  // uFuncDataGraph.RegistExportChartToFileFuncs('多点位移计', ExportGraphToFile);
  // uFuncDataGraph.RegistExportChartToFileFuncs('锚索测力计', ExportGraphToFile);
  // uFuncDataGraph.RegistExportChartToFileFuncs('锚杆应力计', ExportGraphToFile);
  // uFuncDataGraph.RegistSaveChartToStreamFuncs('多点位移计', ExportGraphToStream);
  // uFuncDataGraph.RegistSaveChartToStreamFuncs('锚索测力计', ExportGraphToStream);
  // uFuncDataGraph.RegistSaveChartToStreamFuncs('锚杆应力计', ExportGraphToStream);
end;

initialization

RegistSelf;

finalization

if Assigned(fraTLTool) then
  FreeAndNil(fraTLTool);
if Assigned(JpgFmt) then
  JpgFmt.Free;

end.
