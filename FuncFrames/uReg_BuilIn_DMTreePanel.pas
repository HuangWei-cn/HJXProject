{ -----------------------------------------------------------------------------
 Unit Name: uReg_BuilIn_DMTreePanel
 Author:    ��ΰ
 Date:      08-����-2016
 Purpose:   ����Ԫ�ǲ�������ע�ᵥԪ
            ����Ԫ�����ע��Ϊ�����á���������ڵ��Բ�����ܡ�һ����������ϣ�
            ����uReg_Plugin_DBTreePanel��Ԫ�������Ԫ���ٽ���һ��DLL�����ļ�
            �����ˡ�
 History:
----------------------------------------------------------------------------- }

unit uReg_BuilIn_DMTreePanel;

interface

implementation

uses
    System.SysUtils, System.Classes, uIAppServices, uIFuncCompManager, uFuncCompTypes, uIHost,
    ufraDMTreePanel;

var
    CompReg  : PFuncCompRegister;
    App      : IPSMISAppServices;
    fraDMTree: TfraDMTreePanel;
    Host: IHost;

function InitComp(AppServices: IPSMISAppServices): Boolean; stdcall;
begin
    App := AppServices;
    supports(App.Host, ihost, Host);
    fraDMTree := TfraDMTreePanel.Create(host.HostApp);
    host.SetMeToLeftPanel('����б�','����б�',fraDMTree);
    //ifd := app.FuncDispatcher as ifunctiondispatcher;
    Result := true;
end;

procedure RegistBuildInComp;
begin
    New(CompReg);
    CompReg^.FuncCompType := fctFuncComp;
    CompReg^.PluginType := ptBuildIn;
    CompReg^.RegisterName := 'DesignPointTreePanel';
    CompReg^.Requires := '';
    CompReg^.Version := '1.0.0';
    CompReg^.DateIssued := '2016-9-8';
    CompReg^.Initiated := False;
    CompReg^.Description := '��������';
    @CompReg^.InitProc := @InitComp;
    CompReg^.UnRegistProc := nil;

    //ע�⣺�����ע�᷽ʽֻ��buildinģʽ����ʹ�ã���ΪBuildInģʽ��ע�ᵥԪ��������uIFuncCompManager
    //��Ԫ�еĹ��ñ���IFuncCompManager�ɱ�BuildIn������ʡ�
    if Assigned(IFuncCompManager) then
        IFuncCompManager.RegisterEntry(CompReg);

    { �����ⲿ���������DLL����Package����Ҫexportһ��ע�᷽��������������ã�����ʱ��
      IFuncCompManager���ݸ���� }
end;

initialization

RegistBuildInComp;

finalization

if Assigned(CompReg) then
    Dispose(CompReg);
//Pointer(App) := nil;
Pointer(Host) := nil;   //���Ӵ˾䣬�������ڴ�й¶

end.
