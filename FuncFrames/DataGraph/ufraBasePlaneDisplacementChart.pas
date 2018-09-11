{ -----------------------------------------------------------------------------
 Unit Name: ufraBasePlaneDisplacementChart
 Author:    ��ΰ
 Date:      05-����-2018
 Purpose:   ����ƽ��λ��ͼ
        �ṩһ��TeeChart����ƽ��λ��ʸ��ͼ��ֻ�����ͼ���֡�������ר��ܡ�
        �ṩ���ݻ������߼���ʾ������һ����Frame�ṩ������ufraTrendlineShell
        ��Ԫ��
 History:
----------------------------------------------------------------------------- }

unit ufraBasePlaneDisplacementChart;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
    VclTee.Series, VclTee.ArrowCha, Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, Vcl.Menus;

type
    TfraBasePlaneDisplacementChart = class(TFrame)
        chtDisplacement: TChart;
        ssDisplacement: TArrowSeries;
        popChart: TPopupMenu;
        piCopyAsBitmap: TMenuItem;
        piCopyAsMetafile: TMenuItem;
        N1: TMenuItem;
        piSaveAs: TMenuItem;
        procedure piCopyAsBitmapClick(Sender: TObject);
        procedure piCopyAsMetafileClick(Sender: TObject);
        procedure piSaveAsClick(Sender: TObject);
    private
        { Private declarations }
    public
        { Public declarations }
        procedure ClearDatas;
        procedure ShowSampleDatas;
        procedure AddData(X0, Y0, X1, Y1: Double; ALabel: string = '');
        procedure SetChartTitle(ATitle: string);
    end;

implementation

uses
    VclTee.TeExport;
{$R *.dfm}


procedure TfraBasePlaneDisplacementChart.ClearDatas;
begin
    ssDisplacement.Clear;
end;

procedure TfraBasePlaneDisplacementChart.piCopyAsBitmapClick(Sender: TObject);
begin
    chtDisplacement.CopyToClipboardBitmap;
end;

procedure TfraBasePlaneDisplacementChart.piCopyAsMetafileClick(Sender: TObject);
begin
    chtDisplacement.CopyToClipboardMetafile(True);
end;

procedure TfraBasePlaneDisplacementChart.piSaveAsClick(Sender: TObject);
begin
    TeeExport(nil, chtDisplacement);
end;

{ -----------------------------------------------------------------------------
  Procedure  : ShowSampleDatas
  Description: ʾ�����ݣ���ʾһ�������׵�������
----------------------------------------------------------------------------- }
procedure TfraBasePlaneDisplacementChart.ShowSampleDatas;
var
    R     : Double;
    X0, Y0: Double;
    X1, Y1: Double;
begin
    ssDisplacement.StartXValues.DateTime := False;
    ssDisplacement.EndXValues.DateTime := False;
    ClearDatas;
    X0 := 0;
    Y0 := 0;
    // X1 := 0;
    // Y1 := 0;
    R := 0;
    // �������һ��ʾ������
    repeat
        X1 := R * sin(R);
        Y1 := R * cos(R);
        if (X1 <> X0) and (Y1 <> Y0) then
            ssDisplacement.AddArrow(X0, Y0, X1, Y1);
        X0 := X1;
        Y0 := Y1;
        R := R + 0.2;
    until R > 10;
end;

function MaxValue(D: array of Double): Double;
var
    i: integer;
begin
    Result := Abs(D[Low(D)]);
    for i := Low(D) to High(D) do
        if Abs(D[i]) > Result then
            Result := Abs(D[i]);
end;

{ -----------------------------------------------------------------------------
  Procedure  : AddData
  Description: ���һ����ͷ
----------------------------------------------------------------------------- }
procedure TfraBasePlaneDisplacementChart.AddData(X0, Y0, X1, Y1: Double;
    ALabel: string = '');
var
    MaxX, MaxY: Double;
    MinX, MinY: Double;
begin
    MaxX := MaxValue([X0, Y0, X1, Y1]);
    chtDisplacement.LeftAxis.Automatic := False;
    chtDisplacement.BottomAxis.Automatic := False;

    ssDisplacement.AddArrow(X0, Y0, X1, Y1, ALabel, clBlue);

    // ����Ĺ���Ϊ�˽�(0,0)����Chart������
    with ssDisplacement do
        MaxX := MaxValue([MaxX, XValues.MaxValue, XValues.MinValue, YValues.MaxValue,
            YValues.MinValue]);
// MaxX := Abs(ssDisplacement.XValues.MaxValue);
// MaxY := Abs(ssDisplacement.YValues.MaxValue);
// MinX := Abs(ssDisplacement.XValues.MinValue);
// MinY := Abs(ssDisplacement.YValues.MinValue);
// if MinX > MaxX then
// MaxX := MinX;
// if MinY > MaxY then
// MaxY := MinY;
// if MaxY > MaxX then
// MaxX := MaxY;

    chtDisplacement.LeftAxis.Minimum := -MaxX;
    chtDisplacement.LeftAxis.Maximum := MaxX;
    chtDisplacement.BottomAxis.Minimum := -MaxX;
    chtDisplacement.BottomAxis.Maximum := MaxX;
end;

procedure TfraBasePlaneDisplacementChart.SetChartTitle(ATitle: string);
begin
    chtDisplacement.Title.Caption := ATitle;
end;

end.
