{-----------------------------------------------------------------------------
 Unit Name: ufrmMeterSelector
 Author:    黄伟
 Date:      21-六月-2018
 Purpose:   仪器选择对话窗
            已向IFunctionDispatcher功能调度器注册了功能"PopupMeterSelector"，
            该功能弹出选择窗口，向调用者传递的TStrings中写入选择的仪器。
 History:
-----------------------------------------------------------------------------}

unit ufrmMeterSelector;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ufraMeterSelector;

type
    TfrmMeterSelector = class(TForm)
        fraMS: TfraMeterSelector;
        Button1: TButton;
        Button2: TButton;
    lblSelNum: TLabel;
        procedure FormCreate(Sender: TObject);
    private
        { Private declarations }
    public
        { Public declarations }
        { 显示用户给定的选择过的仪器 }
        procedure SetSelected(AStrs: TStrings);
        procedure GetSelected(AStrs: TStrings);
    end;

implementation

uses
    uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher;
{$R *.dfm}


procedure TfrmMeterSelector.FormCreate(Sender: TObject);
begin
    fraMS.SetCheckBox;
    fraMS.AppendMeterList;
end;

procedure TfrmMeterSelector.SetSelected(AStrs: TStrings);
begin
    if AStrs.Count > 0 then
        fraMS.SetSelectedList(AStrs);
end;

procedure TfrmMeterSelector.GetSelected(AStrs: TStrings);
begin
    fraMS.GetSelectedMeters(AStrs);
end;

procedure PopupMeterSelector(AStrs: TStrings);
var
    frm: TfrmMeterSelector;
begin
    if Assigned(IAppServices) then
        frm := TfrmMeterSelector.Create(IAppServices.Host as TForm)
    else
        frm := TfrmMeterSelector.Create(nil);

    try
        frm.SetSelected(AStrs); //将用户已选择过的仪器继续设置为选择
        frm.ShowModal;
        if frm.ModalResult = mrOk then
            frm.GetSelected(AStrs);
    finally
        frm.Release;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : RegistFunc
  Description:
----------------------------------------------------------------------------- }
procedure RegistFunc;
begin
    if Assigned(IAppServices) then
        with IAppServices.FuncDispatcher as IFunctionDispatcher do
            RegisterProc('PopupMeterSelector', PopupMeterSelector);
end;

initialization

RegistFunc;

end.
