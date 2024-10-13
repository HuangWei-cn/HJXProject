unit ufraHJXDataGrid;

{ DONE:将标准DBGrid组件更换为EhGrid，设置筛选、过滤等功能 }
{ todo:允许在本Frame中用Filter属性设置一定程度的过滤功能 }
{ DONE:允许将数据集拷贝到内存，以便于粘贴到其他软件中 }
{ todo:允许用户更换字体、字号 }
{ todo:允许对超出限度的数据使用自定义颜色 }
{ todo:统计观测次数、时间跨度 }
{ todo:显示数据集中数据的特征值 }
{ todo:允许连接到过程线功能 }
{ todo:允许连接到仪器参数功能 }
{ todo:使用仪器的WebGridTemplate定制仪器的表头、需要显示的列 }
{ todo:将本功能扩展到可以显示特征值、观测值（及物理量）、变差值等多种形式 }
{ todo:充分利用EhGrid的分组、Local Filter、DetailPanel等高级特性，增强数据表现力 }
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient, MidasLib,
  uHJX.Intf.Datas, Vcl.StdCtrls, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  MemTableDataEh, DataDriverEh, MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, EhLibMTE,
  DBGridEhImpExp, Vcl.Menus, Vcl.Clipbrd;

type
  TfraHJXDataGrid = class(TFrame)
    cdsMeterDatas: TClientDataSet;
    DBGridEh1: TDBGridEh;
    MemTableEh1: TMemTableEh;
    DataSetDriverEh1: TDataSetDriverEh;
    DataSource1: TDataSource;
    popDataGrid: TPopupMenu;
    piCopyToCliboardAsHTML: TMenuItem;
    N1: TMenuItem;
    piCopyToClipboard: TMenuItem;
    N3: TMenuItem;
    piSaveAsHTML: TMenuItem;
    piSaveAsTEXT: TMenuItem;
    piSaveAsRTF: TMenuItem;
    piSaveAsXLSX: TMenuItem;
    piSaveAsXLS: TMenuItem;
    dlgSave: TSaveDialog;
    procedure piCopyToCliboardAsHTMLClick(Sender: TObject);
    procedure piCopyToClipboardClick(Sender: TObject);
    procedure piSaveAsHTMLClick(Sender: TObject);
    procedure piSaveAsTEXTClick(Sender: TObject);
    procedure piSaveAsRTFClick(Sender: TObject);
    procedure piSaveAsXLSXClick(Sender: TObject);
    procedure piSaveAsXLSClick(Sender: TObject);
  private
        { Private declarations }
    FDesignName: String;
    FOnFree    : TNotifyEvent;
  public
        { Public declarations }
    destructor Destroy; override;
        /// <summary>显示指定仪器的观测数据（物理量）</summary>
    procedure ShowMeterDatas(DesignName: string);
    property OnFree: TNotifyEvent read FOnFree write FOnFree;
  end;

implementation

uses
  uMyUtils.CopyHTML2Clipbrd, uHJX.Classes.Meters {uHJX.Excel.Meters};

{$R *.dfm}


destructor TfraHJXDataGrid.Destroy;
begin
  if Assigned(FOnFree) then
      FOnFree(Self);
  inherited;
end;

procedure TfraHJXDataGrid.piSaveAsHTMLClick(Sender: TObject);
begin
  if dlgSave.Execute then
      SaveDBGridEhToExportFile(TDBGridEhExportAsHTML, DBGridEh1, dlgSave.FileName, True);
end;

procedure TfraHJXDataGrid.piSaveAsTEXTClick(Sender: TObject);
begin
  if dlgSave.Execute then
      SaveDBGridEhToExportFile(TDBGridEhExportAsText, DBGridEh1, dlgSave.FileName, True);
end;

procedure TfraHJXDataGrid.piCopyToCliboardAsHTMLClick(Sender: TObject);
var
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  try
    WriteDBGridEhToExportStream(TDBGridEhExportAsHTML, DBGridEh1, ms, True);
    CopyHTMLToClipboard(ms);
  finally
    ms.Free;
  end;
end;

procedure TfraHJXDataGrid.piCopyToClipboardClick(Sender: TObject);
begin
  DBGridEh_DoCopyAction(DBGridEh1, True);
end;

procedure TfraHJXDataGrid.piSaveAsRTFClick(Sender: TObject);
begin
  if dlgSave.Execute then
      SaveDBGridEhToExportFile(TDBGridEhExportAsRTF, DBGridEh1, dlgSave.FileName, True);
end;

{ -----------------------------------------------------------------------------
  Procedure  : ShowMeterDatas
  Description: 显示观测数据
----------------------------------------------------------------------------- }
procedure TfraHJXDataGrid.ShowMeterDatas(DesignName: string);
var
  i      : Integer;
  Meter  : TMeterDefine;
  GrpName: string;
begin
  FDesignName := DesignName;
  if IHJXClientFuncs = nil then
      exit;
  if cdsMeterDatas.Active then
      cdsMeterDatas.Close;
  if MemTableEh1.Active then
      MemTableEh1.Close;

    // 2018-05-29 对于成组锚杆应力计特殊对待
  Meter := ExcelMeters.Meter[DesignName];
    // 2020-06-04 可以显示成组仪器，不仅限于锚杆应力计，应变计组也可以正常显示了。
  if { Meter.Params.MeterType = '锚杆应力计' } Meter.PrjParams.GroupID <> '' then
  begin
    GrpName := Meter.PrjParams.GroupID;
    if GrpName <> '' then
    begin
            { todo:这里需要重新设置一下表头 }
      IHJXClientFuncs.GetGroupAllPDDatas(GrpName, cdsMeterDatas);
      DBGridEh1.TitleLines := 2;
    end
    else
        IHJXClientFuncs.GetAllDatas(DesignName, cdsMeterDatas)
            { IHJXClientFuncs.GetAllPDDatas(DesignName, cdsMeterDatas); }
  end
  else
        { IHJXClientFuncs.GetAllPDDatas(DesignName, cdsMeterDatas) }
      IHJXClientFuncs.GetAllDatas(DesignName, cdsMeterDatas);
  cdsMeterDatas.Open;
  MemTableEh1.Open;
  MemTableEh1.AggregatesActive := True;
    // memtableeh1.AggFields
  for i := 0 to DBGridEh1.Columns.Count - 1 do
  begin
    DBGridEh1.Columns[i].Title.TitleButton := True;
        // 如果某列内容为空，则该列宽度非常小，故这里适当放宽
        // if DBGridEh1.Columns[i].Width < 10 then
        // DBGridEh1.Columns[i].Width := 30;
        { 针对平面位移测点设置表头 }
    if Meter.Params.MeterType = '平面位移测点' then
      with DBGridEh1.Columns[i] do
      begin
        if pos('1', Field.DisplayLabel) <> 0 then
        begin
          if pos('Sd', Field.DisplayLabel) = 1 then
              Field.DisplayLabel := '本地坐标(X-临空面,Y-右侧)|累积变形|' + Field.DisplayLabel
          else if pos('d', Field.DisplayLabel) = 1 then
              Field.DisplayLabel := '本地坐标(X-临空面,Y-右侧)|变形量|' + Field.DisplayLabel;

        end
        else if pos('2', Field.DisplayLabel) <> 0 then
        begin
          if pos('Sd', Field.DisplayLabel) = 1 then
              Field.DisplayLabel := '施工坐标(X-对岸,Y-下游)|累积变形|' + Field.DisplayLabel
          else if pos('d', Field.DisplayLabel) = 1 then
              Field.DisplayLabel := '施工坐标(X-对岸,Y-下游)|变形量|' + Field.DisplayLabel;

        end
        else
        begin
          if pos('Sd', Field.DisplayLabel) = 1 then
              Field.DisplayLabel := '大地坐标(X-正北,Y-正东)|累积变形|' + Field.DisplayLabel
          else if pos('d', Field.DisplayLabel) = 1 then
              Field.DisplayLabel := '大地坐标(X-正北,Y-正东)|变形量|' + Field.DisplayLabel;
        end;
      end
    else if Meter.Params.MeterType = '多点位移计' then
    begin
      with DBGridEh1.Columns[i] do
        if pos('PD', FieldName) = 1 then
        begin
            Field.DisplayLabel := '区间位移|' + Field.DisplayLabel;
            Color := clWebLightSkyBlue;
        end
        else if pos('MD', FieldName) = 1 then
        begin
            Field.DisplayLabel := '观测值|' + Field.DisplayLabel;
            Color := clWebLightGreen;
        end;
    end
    else
    begin
      with DBGridEh1.Columns[i] do
        if pos('PD', FieldName) = 1 then
        begin
            Field.DisplayLabel := '物理量|' + Field.DisplayLabel;
            Color := clWebLightSkyBlue;
        end
        else if pos('MD', FieldName) = 1 then
        begin
            field.DisplayLabel := '观测值|' + Field.DisplayLabel;
            Color := clWebLightGreen;
        end;
    end;
  end;
end;

procedure TfraHJXDataGrid.piSaveAsXLSClick(Sender: TObject);
begin
  if dlgSave.Execute then
      SaveDBGridEhToExportFile(TDBGridEhExportAsXLS, DBGridEh1, dlgSave.FileName, True);
end;

procedure TfraHJXDataGrid.piSaveAsXLSXClick(Sender: TObject);
begin
  if dlgSave.Execute then
      SaveDBGridEhToExportFile(TDBGridEhExportAsXlsx, DBGridEh1, dlgSave.FileName, True);
end;

end.
