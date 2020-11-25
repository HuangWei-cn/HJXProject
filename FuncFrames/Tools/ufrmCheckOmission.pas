{-----------------------------------------------------------------------------
 Unit Name: ufrmCheckOmission
 Author:    黄伟
 Date:      25-十一月-2020
 Purpose:   本单元用于查找漏测的监测仪器、漏测天数、最后一次观测日期
            允许将结果拷贝到剪贴板，粘贴到word或excel等软件中
 History:
-----------------------------------------------------------------------------}

unit ufrmCheckOmission;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Types, System.DateUtils,
  uHJX.Intf.AppServices, uHJX.Intf.Datas, uHJX.Classes.Meters, uHJX.Intf.FunctionDispatcher,
  DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, MemTableDataEh, Data.DB, Datasnap.DBClient, DataDriverEh,
  MemTableEh, EhLibVCL, GridsEh, DBAxisGridsEh, DBGridEh, Vcl.Menus;

type
  TfrmCheckOmission = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ProgressBar1: TProgressBar;
    grpCheckSetup: TGroupBox;
    edtPeriod: TLabeledEdit;
    btnDoCheck: TButton;
    dbgOmission: TDBGridEh;
    MemTableEh1: TMemTableEh;
    DataSetDriverEh1: TDataSetDriverEh;
    DataSource1: TDataSource;
    cdsOmission: TClientDataSet;
    cdsOmissionDesignName: TStringField;
    cdsOmissionMeterType: TStringField;
    cdsOmissionPosition: TStringField;
    cdsOmissionOmissionDays: TIntegerField;
    cdsOmissionLastDT: TDateField;
    popOmission: TPopupMenu;
    piPopupGraph: TMenuItem;
    piPopupDataGrid: TMenuItem;
    N1: TMenuItem;
    piCopy: TMenuItem;
    procedure btnDoCheckClick(Sender: TObject);
    procedure piPopupGraphClick(Sender: TObject);
    procedure piPopupDataGridClick(Sender: TObject);
    procedure piCopyClick(Sender: TObject);
  private
    { Private declarations }
    FPeriodDays: Integer;
    procedure CheckOmission;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
  end;

var
  frmCheckOmission: TfrmCheckOmission;

implementation
uses
  DBGridEhImpExp;
{$R *.dfm}


procedure TfrmCheckOmission.btnDoCheckClick(Sender: TObject);
begin
  CheckOmission;
end;

{ -----------------------------------------------------------------------------
  Procedure  : CreateParams
  Description: 本方法用于将窗体显示在Windows的任务栏上。
----------------------------------------------------------------------------- }
procedure TfrmCheckOmission.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := 0;
end;

procedure TfrmCheckOmission.piCopyClick(Sender: TObject);
begin
  if MemTableEh1.Active then DBGridEh_DoCopyAction(dbgOmission, True);
end;

procedure TfrmCheckOmission.piPopupDataGridClick(Sender: TObject);
var mn:String;
begin
  if not cdsOmission.Active then Exit;
  if IAppServices = nil then Exit;
  if IAppServices.FuncDispatcher = nil then Exit;
  mn := MemTableEh1.FieldByName('DesignName').AsString;
  if Trim(mn)='' then Exit;
  (IAppServices.FuncDispatcher as IFunctionDispatcher).ShowData(mn, nil);
end;

procedure TfrmCheckOmission.piPopupGraphClick(Sender: TObject);
var mn:String;
begin
  if not cdsOmission.Active then Exit;
  if IAppServices = nil then Exit;
  if IAppServices.FuncDispatcher = nil then Exit;
  mn := MemTableEh1.FieldByName('DesignName').AsString;
  if Trim(mn)='' then Exit;
  (IAppServices.FuncDispatcher as IFunctionDispatcher).ShowDataGraph(mn, nil);
end;

{ -----------------------------------------------------------------------------
  Procedure  : CheckOmission
  Description: 开始查询漏测的仪器
----------------------------------------------------------------------------- }
procedure TfrmCheckOmission.CheckOmission;
var
  iMeter: Integer;
  Datas : TDoubleDynArray;
  LastDT: TDateTime;
  Days  : Integer;
begin
  if TryStrToInt(edtPeriod.Text, FPeriodDays) = False then FPeriodDays := 7;
  ProgressBar1.Min := 0;
  ProgressBar1.Max := excelmeters.Count;
  ProgressBar1.Position := 0;
  ProgressBar1.Visible := True;

  if MemTableEh1.Active then MemTableEh1.Close;
  if cdsOmission.Active then cdsOmission.Close;
  if not cdsOmission.Active then cdsOmission.CreateDataSet;
  cdsOmission.Open;
  cdsOmission.EmptyDataSet;

  try
    IAppServices.ClientDatas.SessionBegin;
    for iMeter := 0 to excelmeters.Count - 1 do
    begin
      ProgressBar1.Position := iMeter + 1;
      with excelmeters.Items[iMeter] do
      begin
        if DataSheet = '' then Continue;

        if IAppServices.ClientDatas.GetLastPDDatas(DesignName, Datas) then
        begin
          LastDT := Datas[0];
          Days := DaysBetween(Now, LastDT);
          if Days >= FPeriodDays then
          begin
            cdsOmission.Append;
            cdsOmission.FieldByName('DesignName').Value := DesignName;
            cdsOmission.FieldByName('MeterType').Value := Params.MeterType;
            cdsOmission.FieldByName('Position').Value := PrjParams.Position;
            cdsOmission.FieldByName('OmissionDays').Value := Days;
            cdsOmission.FieldByName('LastDT').Value := LastDT;
            cdsOmission.Post;
            // Break;
          end;
        end;
      end;
    end;
  finally
    IAppServices.ClientDatas.SessionEnd;
    ProgressBar1.Visible := False;
    MemTableEh1.Open;

    //设置分组显示
    with dbgOmission do
    begin
      with DataGrouping do
      begin
        Active := False;
        GroupLevels.Clear;
        GroupLevels.Add.Column := dbgOmission.Columns[2];
        GroupLevels.Add.Column := dbgOmission.Columns[1];
      end;
      Columns[2].Visible := False;
      Columns[1].Visible := False;
      DataGrouping.Active := True;
      DataGrouping.GroupPanelVisible := True;
    end;
  end;
end;

end.
