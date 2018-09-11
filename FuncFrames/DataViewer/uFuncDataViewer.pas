{ -----------------------------------------------------------------------------
 Unit Name: uFuncDataViewer
 Author:    ��ΰ
 Date:      07-����-2018
 Purpose:   ����۲�����(���ݱ��)���ע�ᡢ������Ӧ��Ԫ
 History:   2018-06-07 Created
----------------------------------------------------------------------------- }

unit uFuncDataViewer;

interface

uses
    System.Classes, Vcl.Controls, Vcl.Forms,
    uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher, uHJX.Classes.Meters;

implementation

uses
    ufraHJXDataGrid, ufraHJXWebDataGrid;

type
    { ��Ӧ���� }
    TReplier = class
    public
        procedure OnClientFormClose(Sender: TObject; var CloseAction: TCloseAction);
        procedure OnResize(Sender: TObject);
        procedure OnFrameFree(Sender: TObject);

        procedure PopupDataViewer(ADesignName: string; AContainer: TComponent = nil);
        procedure ShowDataViewer(ADesignName: string; AContainer: TComponent = nil);

    end;

var
    DefaultFrmWidth : integer = 800;
    DefaultFrmHeight: integer = 500;
    Replier         : TReplier;
    IFD             : IFunctionDispatcher;
    Host            : TForm;
    { fraDataViewer�����ϴ���һ�μ��������氲����ĳ���ط��������ṩ�Ը�ʵ���ķ��ʡ����๦��Frame
      ����һ��OnFree��OnClose�¼�����ʵ�����ͷ�ʱ������Ԫ��fraDataViewer������Ϊnil�� }
    fraDataViewer   : TfraHJXDataGrid;

procedure TReplier.OnClientFormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    CloseAction := caFree;
end;

procedure TReplier.OnResize(Sender: TObject);
begin
    with Sender as TForm do
    begin
        DefaultFrmWidth := width;
        DefaultFrmHeight := height;
    end;
end;

{ ��Frame���ͷź󣬱���fraDataViewer��������nil��֮�����û��ٴε���ShowData�����������������
���ڴ˽�����fraDataViewer��Ϊnil }
procedure TReplier.OnFrameFree(Sender: TObject);
begin
    fraDataViewer := nil;
end;

{ -----------------------------------------------------------------------------
  Procedure  : PopupDataViewer
  Description: ����ʽ�����������壬������ע�ᵽFuncDispatcher.PopupDataViewer;
----------------------------------------------------------------------------- }
procedure TReplier.PopupDataViewer(ADesignName: string; AContainer: TComponent = nil);
var
    frm: TForm;
    fra: TfraHJXDataGrid;
begin
    frm := TForm.Create(IAppServices.Host as TForm);
    frm.BorderStyle := bsSizeToolWin;
    frm.width := DefaultFrmWidth;
    frm.height := DefaultFrmHeight;
    frm.OnResize := Replier.OnResize;
    frm.OnClose := Replier.OnClientFormClose;
    frm.Caption := IAppServices.ClientDatas.GetMeterTypeName(ADesignName) + ADesignName + '�۲����ݱ�';

    fra := TfraHJXDataGrid.Create(frm);
    fra.Parent := frm;
    fra.Align := alClient;
    fra.ShowMeterDatas(ADesignName);

    frm.Show;
end;

procedure TReplier.ShowDataViewer(ADesignName: string; AContainer: TComponent = nil);
begin
    if AContainer = nil then
        PopupDataViewer(ADesignName)
    else
    begin
        if fraDataViewer = nil then
        begin
            fraDataViewer := TfraHJXDataGrid.Create(Host);
            fraDataViewer.Parent := AContainer as TWinControl;
            fraDataViewer.Align := alClient;
            fraDataViewer.OnFree := Replier.OnFrameFree;
        end;
        fraDataViewer.ShowMeterDatas(ADesignName);
    end;
end;

procedure RegistSelf;
begin
    IFD := IAppServices.FuncDispatcher as IFunctionDispatcher;
    IFD.RegistFuncPopupDataViewer(Replier.PopupDataViewer);
    IFD.RegistFuncShowData(Replier.ShowDataViewer);
    //Host := TForm(IAppServices.Host); //��ʱ��Host��δָ��
    fraDataViewer := nil;
end;

initialization

Replier := TReplier.Create;
RegistSelf;

finalization
Replier.Free;

end.
