unit uPluginMenuItem;

interface

uses
    Winapi.Windows, System.Classes, System.SysUtils, Vcl.Menus, uIAppServices;

type
    { ���ע��Ĳ˵��������Ҫ���ṩ�˹��̵���CallProc�����ֻ�Ƿ����������
      ����OnClick = CallCompMethod���� }
    TPluginMenuItem = class(TMenuItem)
    private
        { ���̵��÷��� }
        FCallProc  : TProcedure;
        FCallMethod: TCallCompMethod;
        procedure CallSelf(Sender: TObject);
    public
        constructor Create(AOwner: TComponent); override;
        property CallProc: TProcedure read FCallProc write FCallProc;
        property CallMethod: TCallCompMethod read FCallMethod write FCallMethod;
    end;

implementation

constructor TPluginMenuItem.Create(AOwner: TComponent);
begin
    inherited;
    OnClick := CallSelf;
end;

{ ----------------------------------------------------------------------------- }
procedure TPluginMenuItem.CallSelf(Sender: TObject);
begin
    if Assigned(FCallProc) then
        FCallProc
    else if Assigned(FCallMethod) then
        FCallMethod(Self);
end;

end.
