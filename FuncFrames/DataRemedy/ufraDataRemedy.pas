{ 本单元提供一个显示原始观测值的Frame，允许用户通过拖拽点的方式调整观测数据，
  并将数据写回到计算表
}
unit ufraDataRemedy;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TfraDataRemedy = class(TFrame)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
