unit ufrmMultDates;
{ todo:����һ�����ѡ��İ�ť }
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
        //�����û�ѡ�������
        function GetSelectedDates: string;
        //�����û�����ѡ�������
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

    //ȥ�����س����з�
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
