{ -----------------------------------------------------------------------------
  Unit Name: ufraMeterListGrid
  Author:    ��ΰ
  Date:      17-����-2017
  Purpose:   ���з�����(EhGrid)�ļ�������б�
  ����Ԫ��uHJX.Excel.Meters��Ԫ�л�ȡ���ص������б���ʾ�ڱ����
  History:
  ----------------------------------------------------------------------------- }

unit ufraMeterListGrid;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MemTableDataEh, Data.DB, DBGridEhGrouping,
    ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh,
    DataDriverEh, MemTableEh, Datasnap.DBClient, MidasLib,
    uHJX.Intf.Datas;

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
    public
        { Public declarations }
        procedure ListMeters;
    end;

implementation

uses
    {uHJX.Excel.Meters} uHJX.Classes.Meters;
{$R *.dfm}


{ -----------------------------------------------------------------------------
  Procedure  : _CreateDataSet
  Description: ��������cdsMeters�д���DataSet�������ֶΡ�
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
    _CFD('Position', '��װ��λ', ftString);
    // MeterType
    _CFD('MeterType', '��������', ftString);
    // DesignName
    _CFD('DesignName', '��Ʊ��', ftString);
    // Stake
    _CFD('Stake', '׮��', ftString);
    // Elevation
    _CFD('Elevation', '�߳�', ftFloat);
    // SetupDate
    _CFD('SetupDate', '��װ����', ftDateTime);
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

    // ����DataSet
    _CreateDataSet;
    cdsMeters.CreateDataSet;
    // ��������
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
    cdsMeters.Open;
    IHJXClientFuncs.SetFieldDisplayName(cdsMeters);
    mtMeters.Open;

    for i := 0 to dbgMeters.Columns.Count - 1 do
        dbgMeters.Columns[i].OptimizeWidth;

    dbgMeters.DataGrouping.Active := False;
    gl := dbgMeters.DataGrouping.GroupLevels.Add;
    gl.Column := dbgMeters.Columns[0];

    dbgMeters.DataGrouping.GroupLevels.Add.Column := dbgMeters.Columns[1];
    dbgMeters.Columns[0].Visible := False;
    dbgMeters.Columns[1].Visible := False;
    dbgMeters.DataGrouping.Active := True;
    dbgMeters.DataGrouping.GroupPanelVisible := True;
end;

end.
