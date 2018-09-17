unit ufrmQuerySetupDate;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls, Vcl.ExtCtrls, System.Types,
    Vcl.ComCtrls;

type
    TfrmQuerySetupDate = class(TForm)
        Panel1: TPanel;
        Button1: TButton;
        Edit1: TEdit;
        grdQuery: TStringGrid;
        ProgressBar1: TProgressBar;
        procedure Button1Click(Sender: TObject);
        procedure FormCreate(Sender: TObject);
    private
    { Private declarations }
    public
    { Public declarations }
    end;

var
    frmQuerySetupDate: TfrmQuerySetupDate;

implementation

uses
    uHJX.Intf.AppServices, uHJX.Classes.Meters, uHJX.Intf.Datas;
{$R *.dfm}


procedure TfrmQuerySetupDate.Button1Click(Sender: TObject);
var
    i: Integer;
    V: TDoubleDynArray;
begin
    ProgressBar1.Position := 0;
    if ExcelMeters.Count = 0 then
        exit;

    grdQuery.RowCount := ExcelMeters.Count + 1;
    with ProgressBar1 do
    begin
        Min := 1;
        Max := ExcelMeters.Count;
        Position := 1;
        visible := True;
    end;

    for i := 0 to ExcelMeters.Count - 1 do
    begin
        ProgressBar1.Position := i + 1;
        with ExcelMeters.Items[i] do
        begin
            grdQuery.Cells[0, i + 1] := Params.MeterType;
            grdQuery.Cells[1, i + 1] := DesignName;
            if Params.SetupDate <> 0 then
                grdQuery.Cells[2, i + 1] := FormatDateTime('yyyy-mm-dd', Params.SetupDate);
            if Params.BaseDate <> 0 then
                grdQuery.Cells[3, i + 1] := FormatDateTime('yyyy-mm-dd', Params.BaseDate);
            if IAppServices.ClientDatas.GetNearestPDDatas(DesignName, 0, V) then
                grdQuery.Cells[4, i + 1] := FormatDateTime('yyyy-mm-dd', V[0]);
        end;
        IAppServices.ProcessMessages;
    end;
    progressbar1.Visible := False;
end;

procedure TfrmQuerySetupDate.FormCreate(Sender: TObject);
const
    HeadStr = '仪器类型|设计编号|安装日期|初值日期|初值日期（数据表）';
begin
    with grdQuery.Rows[0] do
    begin
        Delimiter := '|';
        DelimitedText := HeadStr;
    end;
end;

end.
