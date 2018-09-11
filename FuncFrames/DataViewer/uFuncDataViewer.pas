{ -----------------------------------------------------------------------------
 Unit Name: uFuncDataViewer
 Author:    黄伟
 Date:      07-六月-2018
 Purpose:   浏览观测数据(数据表格)插件注册、管理、响应单元
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
    { 响应对象 }
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
    { fraDataViewer理论上创建一次即被主界面安放在某个地方，这里提供对该实例的访问。这类功能Frame
      都有一个OnFree或OnClose事件，当实例被释放时，本单元的fraDataViewer被设置为nil。 }
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

{ 当Frame被释放后，变量fraDataViewer并不等于nil。之后若用户再次调用ShowData方法，将会产生错误，
故在此将变量fraDataViewer设为nil }
procedure TReplier.OnFrameFree(Sender: TObject);
begin
    fraDataViewer := nil;
end;

{ -----------------------------------------------------------------------------
  Procedure  : PopupDataViewer
  Description: 弹出式数据浏览表格窗体，本方法注册到FuncDispatcher.PopupDataViewer;
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
    frm.Caption := IAppServices.ClientDatas.GetMeterTypeName(ADesignName) + ADesignName + '观测数据表';

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
    //Host := TForm(IAppServices.Host); //这时候Host还未指定
    fraDataViewer := nil;
end;

initialization

Replier := TReplier.Create;
RegistSelf;

finalization
Replier.Free;

end.
