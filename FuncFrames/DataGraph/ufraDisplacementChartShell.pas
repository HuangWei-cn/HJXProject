{ -----------------------------------------------------------------------------
 Unit Name: ufraDisplacementChartShell
 Author:    黄伟
 Date:      06-七月-2018
 Purpose:   平面位移图
        内嵌了fraBasePlaneDisplacementChart，通过操纵该Frame完成绘图。
 History:
        2018-07-06 创建日。目前没有实现对施工坐标系的转换，仅支持大地坐标系
----------------------------------------------------------------------------- }

unit ufraDisplacementChartShell;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uHJX.Intf.Datas, uHJX.Intf.AppServices, uHJX.Intf.GraphDispatcher,
  ufraBasePlaneDisplacementChart {, uFuncDataGraph};

type
  TfraDisplacementChartShell = class(TFrame)
    procedure FrameResize(Sender: TObject);
  private
        { Private declarations }
    fraPDChart: TfraBasePlaneDisplacementChart;
  public
        { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DrawDatas(ADsnName: string); overload;
    procedure DrawDatas(ADsnName: string; DTStart, DTEnd: TDateTime); overload;
  end;

implementation

uses
  uHJX.Classes.Meters, VCLTee.TeeJPEG, Datasnap.DBClient;
{$R *.dfm}


var
  fraPDTool: TfraDisplacementChartShell;
  JpgFmt   : TJPEGExportFormat;

constructor TfraDisplacementChartShell.Create(AOwner: TComponent);
begin
  inherited;
  fraPDChart := TfraBasePlaneDisplacementChart.Create(Self);
  fraPDChart.Parent := Self;
  fraPDChart.Left := 0;
  fraPDChart.Top := 0;
end;

destructor TfraDisplacementChartShell.Destroy;
begin
  fraPDChart.Free;
  inherited;
end;

{ -----------------------------------------------------------------------------
  Procedure  : FrameResize
  Description: 需要确保里面的Chart是正方形
----------------------------------------------------------------------------- }
procedure TfraDisplacementChartShell.FrameResize(Sender: TObject);
begin
  fraPDChart.SetBounds(0, 0, ClientWidth, ClientHeight);
// if ClientWidth > ClientHeight then
// fraPDChart.SetBounds(0, 0, ClientHeight, ClientHeight)
// else
// fraPDChart.SetBounds(0, 0, ClientWidth, ClientWidth);
end;

procedure TfraDisplacementChartShell.DrawDatas(ADsnName: string);
var
  mt    : TMeterDefine;
  DS    : TClientDataSet;
  X0, Y0: double;
  X1, Y1: double;
begin
  fraPDChart.ClearDatas;
  if IHJXClientFuncs = nil then
      Exit;

  mt := ExcelMeters.Meter[ADsnName];
  if mt = nil then
      Exit;
  if mt.Params.MeterType <> '平面位移测点' then
      Exit;

  fraPDChart.SetChartTitle(mt.PrjParams.Position + '平面位移测点' + mt.DesignName + '位移轨迹图');
    { 2019-08-06 将坐标轴标题改为本地坐标 }
  fraPDChart.chtDisplacement.LeftAxis.Title.Caption := 'X方向-临空面(mm)';
  fraPDChart.chtDisplacement.BottomAxis.Title.Caption := 'Y方向-右侧(mm)';

  with fraPDChart do
  begin
    chtCumulativeDeform.Title.Text.Text := '平面位移测点'+mt.DesignName +'累积位移';
    chtCumulativeDeform.LeftAxis.Title.Caption := 'X方向-临空面(mm)';
    chtCumulativeDeform.BottomAxis.Title.Caption := 'Y方向-右侧(mm)';
  end;

  DS := TClientDataSet.Create(Self);
  try
    if IHJXClientFuncs.GetAllPDDatas(ADsnName, DS) then
      if DS.RecordCount > 0 then
      begin
        DS.First;
        X0 := 0;
        Y0 := 0;
        repeat
                    { 2019-08-06 物理量增加了本地坐标、施工坐标 }
                    (*
                    X1 := DS.Fields[5].AsFloat; // SdY;
                    Y1 := DS.Fields[4].AsFloat; // SdX;
 *)
          X1 := DS.Fields[13].AsFloat; // SdY' 本地坐标Y方向
          Y1 := DS.Fields[12].AsFloat; // SdX' 本地坐标X方向
                    // 重合点不绘图，否则那箭头很难看
          if (X1 <> X0) and (Y1 <> Y0) then
              fraPDChart.AddData(X0, Y0, X1, Y1);
          X0 := X1;
          Y0 := Y1;
          DS.Next;
        until DS.Eof;
      end;
  finally
    DS.Free;
  end;
end;

procedure TfraDisplacementChartShell.DrawDatas(ADsnName: string; DTStart, DTEnd: TDateTime);
var
  mt    : TMeterDefine;
  DS    : TClientDataSet;
  X0, Y0: double;
  X1, Y1: double;
begin
  fraPDChart.ClearDatas;
  if (DTStart = 0) and (DTEnd = 0) then
      DrawDatas(ADsnName)
  else
  begin
    fraPDChart.ClearDatas;
    if IHJXClientFuncs = nil then
        Exit;

    mt := ExcelMeters.Meter[ADsnName];
    if mt = nil then
        Exit;
    if mt.Params.MeterType <> '平面位移测点' then
        Exit;
    fraPDChart.SetChartTitle(mt.PrjParams.Position + '平面位移测点' + mt.DesignName + '位移轨迹图');
    frapdchart.chtCumulativeDeform.Title.Text.Text := '平面位移测点' + mt.DesignName + '累积位移';
    DS := TClientDataSet.Create(Self);
    try
      if (DTEnd = 0) then
          DTEnd := Now;
      if IHJXClientFuncs.GetPDDatasInPeriod(ADsnName, DTStart, DTEnd, DS) then
        if DS.RecordCount > 0 then
        begin
          X0 := 0;
          Y0 := 0;
          DS.First;
          repeat
            X1 := DS.Fields[5].AsFloat;
            Y1 := DS.Fields[4].AsFloat;
            if (X1 <> X0) and (Y1 <> Y0) then
                fraPDChart.AddData(X0, Y0, X1, Y1);

            X0 := X1;
            Y0 := Y1;
            DS.Next;
          until DS.Eof;
        end;
    finally
      DS.Free;
    end;
  end;
end;

function DrawDisplacement(ADesignName: String; AOwner: TComponent): TComponent; // TFrame;
begin
  Result := TfraDisplacementChartShell.Create(AOwner);
  (Result as TfraDisplacementChartShell).DrawDatas(ADesignName);
end;

function ExportGraphToFile(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
  AWidth, AHeight: Integer): string;
var
  S      : String;
  TmpPath: array [0 .. 255] of Char;
begin
  if not Assigned(fraPDTool) then
      fraPDTool := TfraDisplacementChartShell.Create(nil);
  fraPDTool.SetBounds(0, 0, AWidth, AHeight);
  fraPDTool.DrawDatas(ADesignName, DTStart, DTEnd);
  if (APath = '') or not DirectoryExists(APath) then
  begin
    Winapi.Windows.GetTempPath(255, @TmpPath);
    APath := StrPas(TmpPath);
  end;

  S := APath + ADesignName + '.jpg';
  if AWidth > AHeight then
      AWidth := AHeight;
  TeeSaveToJPEG(fraPDTool.fraPDChart.chtDisplacement, S, AWidth, AHeight);
  Result := S;
end;

function ExportGraphToStream(ADesignName: string; DTStart, DTEnd: TDateTime; var AStream: TStream;
  AWidth, AHeight: Integer): boolean;
begin
  if not Assigned(fraPDTool) then
      fraPDTool := TfraDisplacementChartShell.Create(nil);
  fraPDTool.SetBounds(0, 0, AWidth, AHeight);
  if not Assigned(JpgFmt) then
      JpgFmt := TJPEGExportFormat.Create;
  JpgFmt.Panel := fraPDTool.fraPDChart.chtDisplacement;
  fraPDTool.DrawDatas(ADesignName, DTStart, DTEnd);
  JpgFmt.SaveToStream(AStream);
  Result := true;
end;

procedure RegistSelf;
var
  IGD: IGraphDispatcher;
begin
  if Assigned(IAppServices) then
    if IAppServices.GetDispatcher('GraphDispatcher') <> nil then
      if Supports(IAppServices.GetDispatcher('GraphDispatcher'), IGraphDispatcher, IGD) then
      begin
        IGD.RegistDrawFuncs('平面位移测点', DrawDisplacement);
        IGD.RegistExportFunc('平面位移测点', ExportGraphToFile);
        IGD.RegistSaveStreamFunc('平面位移测点', ExportGraphToStream);
      end;
// uFuncDataGraph.RegistDrawFuncs('平面位移测点', DrawDisplacement);
// uFuncDataGraph.RegistExportChartToFileFuncs('平面位移测点', ExportGraphToFile);
// uFuncDataGraph.RegistSaveChartToStreamFuncs('平面位移测点', ExportGraphToStream);
end;

initialization

RegistSelf;

finalization

if Assigned(fraPDTool) then
    FreeAndNil(fraPDTool);
if Assigned(JpgFmt) then
    JpgFmt.Free;

end.
