{ -----------------------------------------------------------------------------
 Unit Name: ufrmDataCounts
 Author:    黄伟
 Date:      21-八月-2017
 Purpose:   本窗体用于统计指定时间段里监测仪器的观测点次（暂不包含测斜孔）
 History:   2017年x月x日    已实现统计全部监测仪器观测点次（不含测斜空）
----------------------------------------------------------------------------- }

unit ufrmDataCounts;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
    uHJX.Intf.Datas, {uHJX.Excel.Meters}uHJX.Classes.Meters;

type
    TfrmDataCount = class(TForm)
        dtp1: TDateTimePicker;
        dtp2: TDateTimePicker;
        memDataCount: TMemo;
        Label1: TLabel;
        Label2: TLabel;
        Button1: TButton;
        Button2: TButton;
        procedure FormCreate(Sender: TObject);
        procedure Button2Click(Sender: TObject);
        procedure Button1Click(Sender: TObject);
    private
    { Private declarations }
    public
    { Public declarations }
    end;

implementation

{$R *.dfm}


procedure TfrmDataCount.Button1Click(Sender: TObject);
var
    i                 : Integer;
    ACount, WholeCount: Integer;
begin
    memDataCount.Text := '';
    WholeCount := 0;
    if ExcelMeters.Count = 0 then
        memDataCount.Text := '没有监测仪器';
    for i := 0 to ExcelMeters.Count - 1 do
    begin
        ACount := IHJXClientFuncs.GetDataCount(ExcelMeters.Items[i].DesignName, dtp1.Date,
            dtp2.Date);
        memDataCount.Lines.Add(ExcelMeters.Items[i].DesignName + #9 + IntToStr(ACount));
        WholeCount := WholeCount + ACount;
    end;
    memDataCount.Lines.Add('总观测点次：' + IntToStr(WholeCount));
end;

procedure TfrmDataCount.Button2Click(Sender: TObject);
begin
    self.Close;
end;

procedure TfrmDataCount.FormCreate(Sender: TObject);
begin
    dtp2.Date := now;
end;

end.
