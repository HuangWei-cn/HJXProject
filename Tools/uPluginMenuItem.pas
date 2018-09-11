unit uPluginMenuItem;

interface

uses
    Winapi.Windows, System.Classes, System.SysUtils, Vcl.Menus, uIAppServices;

type
    { 插件注册的菜单项对象，主要是提供了过程调用CallProc。如果只是方法调用则可
      以令OnClick = CallCompMethod即可 }
    TPluginMenuItem = class(TMenuItem)
    private
        { 过程调用方法 }
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
