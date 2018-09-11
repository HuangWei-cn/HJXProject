unit ufrmOriDataWind;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmOriDataWindow = class(TForm)
    mmoData: TMemo;
    lblPath: TLabel;
    btnClose: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowData(AFile: string);
  end;

implementation

{$R *.dfm}

procedure TfrmOriDataWindow.ShowData(AFile: string);
begin
    lblPath.Caption := AFile;
    mmoData.Lines.LoadFromFile(AFile);
end;

end.
