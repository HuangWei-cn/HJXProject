{-----------------------------------------------------------------------------
 Unit Name: ufrmMeterSelector
 Author:    ��ΰ
 Date:      21-����-2018
 Purpose:   ����ѡ��Ի���
            ����IFunctionDispatcher���ܵ�����ע���˹���"PopupMeterSelector"��
            �ù��ܵ���ѡ�񴰿ڣ�������ߴ��ݵ�TStrings��д��ѡ���������
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
        { ��ʾ�û�������ѡ��������� }
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
        frm.SetSelected(AStrs); //���û���ѡ�����������������Ϊѡ��
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
