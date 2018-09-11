unit ufrmMultDates;
{ todo:增加一个清空选择的按钮 }
interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst;

type
    TfrmMultDates = class(TForm)
        clstDates: TCheckListBox;
        Button1: TButton;
        Button2: TButton;
    private
        { Private declarations }
    public
        { Public declarations }
        //返回用户选择的日期
        function GetSelectedDates: string;
        //设置用户曾经选择的日期
        procedure SetSelectedDates(ADates: string);
    end;

implementation

{$R *.dfm}

function TfrmMultDates.GetSelectedDates:string;
var i: integer;
begin
    Result := '';
    if clstDates.Count = 0 then
        exit;
    for i := 0 to clstDates.Count -1 do
    begin
        if clstDates.Checked[i] then
            Result := Result + clstDates.Items[i] + #13#10;
    end;

    //去掉最后回车换行符
    Result := Copy(Result, 1, Length(Result) -2);
end;

procedure TfrmMultDates.SetSelectedDates(ADates: string);
var strs: TStrings;
    i,j: integer;
begin
    strs := TStringList.Create;
    try
        strs.Text := ADates;
        for i := 0 to strs.Count -1 do
        begin
            j := clstDates.Items.IndexOf(strs[i]);
            if j<> -1 then
                clstDates.Checked[j] := true;
        end;
    finally
        strs.Free;
    end;
end;

end.
