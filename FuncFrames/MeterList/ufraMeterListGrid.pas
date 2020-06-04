{ -----------------------------------------------------------------------------
  Unit Name: ufraMeterListGrid
  Author:    黄伟
  Date:      17-四月-2017
  Purpose:   带有分组表格(EhGrid)的监测仪器列表
  本单元从uHJX.Excel.Meters单元中获取加载的仪器列表，显示在表格中
  History:
  ----------------------------------------------------------------------------- }
{ todo:增加显示仪器数据、图表的功能 }
unit ufraMeterListGrid;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MemTableDataEh, Data.DB, DBGridEhGrouping,
    ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh,
    DataDriverEh, MemTableEh, Datasnap.DBClient, MidasLib,
    uHJX.Intf.AppServices,   uHJX.Intf.Datas;

type
    TfraMeterListGrid = class(TFrame)
        dsMeters: TDataSource;
        cdsMeters: TClientDataSet;
        mtMeters: TMemTableEh;
        dsdMeters: TDataSetDriverEh;
        dbgMeters: TDBGridEh;
    private
        { Private declarations }
        procedure _CreateDataSet;
        procedure OnDBConnected(Sender: TObject);
    public
        { Public declarations }
        constructor Create(AOwner: TComponent); override;
        procedure ListMeters;
    end;

implementation

uses
    {uHJX.Excel.Meters} uHJX.Classes.Meters;
{$R *.dfm}


{ -----------------------------------------------------------------------------
  Procedure  : _CreateDataSet
  Description: 本方法在cdsMeters中创建DataSet，设置字段。
  ----------------------------------------------------------------------------- }
procedure TfraMeterListGrid._CreateDataSet;
    procedure _CFD(AName, ADisplayName: String; ADataType: TFieldType);
    begin
        with cdsMeters.FieldDefs.AddFieldDef do
        begin
            Name := AName;
            DisplayName := ADisplayName;
            DataType := ADataType;
        end;
    end;

begin
    // Position
    _CFD('Position', '安装部位', ftString);
    // MeterType
    _CFD('MeterType', '仪器类型', ftString);
    // DesignName
    _CFD('DesignName', '设计编号', ftString);
    // Stake
    _CFD('Stake', '桩号', ftString);
    // Elevation
    _CFD('Elevation', '高程', ftFloat);
    // SetupDate
    _CFD('SetupDate', '安装日期', ftDateTime);
end;

constructor TfraMeterListGrid.Create(AOwner: TComponent);
begin
  inherited;
    IAppServices.RegEventDemander('AfterConnectedEvent', OnDBConnected);
end;

procedure TfraMeterListGrid.ListMeters;
var
    i    : Integer;
    Meter: TMeterDefine;
    gl   : TGridDataGroupLevelEh;
    procedure SetValue(AName: string; AValue: Variant);
    begin
        cdsMeters.FieldByName(AName).Value := AValue;
    end;

begin
    mtMeters.Close;
    cdsMeters.Close;

    for i := cdsMeters.FieldDefs.Count - 1 downto 0 do
        cdsMeters.FieldDefs.Items[i].Free;
    cdsMeters.FieldDefs.Clear;

    if ExcelMeters.Count = 0 then
        exit;

    // 创建DataSet
    _CreateDataSet;
    cdsMeters.CreateDataSet;
    // 填入内容
    for i := 0 to ExcelMeters.Count - 1 do
    begin
        Meter := ExcelMeters.Items[i];
        cdsMeters.Append;
        SetValue('Position', Meter.PrjParams.Position);
        SetValue('MeterType', Meter.Params.MeterType);
        SetValue('DesignName', Meter.DesignName);
        SetValue('Stake', Meter.PrjParams.Stake);
        SetValue('Elevation', Meter.PrjParams.Elevation);
        SetValue('SetupDate', Meter.Params.SetupDate);
        cdsMeters.Post;
    end;

    dbgMeters.StartLoadingStatus('正在加载数据...');
    cdsMeters.Open;
    IHJXClientFuncs.SetFieldDisplayName(cdsMeters);
    mtMeters.Open;

    for i := 0 to dbgMeters.Columns.Count - 1 do
    begin
        dbgMeters.Columns[i].OptimizeWidth;
        dbgMeters.Columns[i].Title.TitleButton := True;
    end;

    dbgMeters.DataGrouping.Active := False;
    gl := dbgMeters.DataGrouping.GroupLevels.Add;
    gl.Column := dbgMeters.Columns[0];

    dbgMeters.DataGrouping.GroupLevels.Add.Column := dbgMeters.Columns[1];
    dbgMeters.Columns[0].Visible := False;
    dbgMeters.Columns[1].Visible := False;
    dbgMeters.DataGrouping.Active := True;
    dbgMeters.DataGrouping.GroupPanelVisible := True;
    dbgmeters.FinishLoadingStatus;
end;

procedure TfraMeterListGrid.OnDBConnected(Sender: TObject);
begin
    ListMeters;
end;

end.
