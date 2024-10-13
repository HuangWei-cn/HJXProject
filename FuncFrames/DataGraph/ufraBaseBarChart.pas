{-----------------------------------------------------------------------------
 Unit Name: ufraBaseBarChart
 Author:    ��ΰ
 Date:      28-ʮ��-2022
 Purpose:   ����Ԫ�ṩ���ư�ͼ�Ļ�������
            ����Ԫ���Ƽ������ĳһ����������������Ҳ���Ե�������������
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
