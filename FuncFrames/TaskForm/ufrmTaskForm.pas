unit ufrmTaskForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TTaskForm = class(TForm)
  private
    { Private declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
  end;

var
  TaskForm: TTaskForm;

implementation

{$R *.dfm}

procedure TTaskform.CreateParams(var Params: TCreateParams);
begin
  inherited;
  //params.WndParent := 0;
end;

end.
