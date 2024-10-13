{-----------------------------------------------------------------------------
 Unit Name: ufraBaseBarChart
 Author:    黄伟
 Date:      28-十月-2022
 Purpose:   本单元提供绘制棒图的基础操作
            本单元绘制监测仪器某一物理量及其增量，也可以单独绘制物理量
 History:
-----------------------------------------------------------------------------}
unit ufraBaseBarChart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, Vcl.Menus, VCLTee.TeEngine,
  Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart,VclTee.TeeChineseSimp, VCLTee.Series;

type
  TfraBaseBarChart = class(TFrame)
    chtBar: TChart;
    PopupMenu1: TPopupMenu;
    ssMeterData: TBarSeries;
    ssDelta: TBarSeries;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ClearSeries;
    procedure AddData(ADsnName:string; AData, ADelta:Double);
  end;

implementation

{$R *.dfm}

procedure TfraBaseBarChart.ClearSeries;
begin

end;

procedure TfraBaseBarChart.AddData(ADsnName: string; AData: Double; ADelta: Double);
begin

end;

end.
