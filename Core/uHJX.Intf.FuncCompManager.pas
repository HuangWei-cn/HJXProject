{-----------------------------------------------------------------------------
 Unit Name: uHJX.Intf.FuncCompManager
 Author:    ��ΰ
 Date:      11-����-2018
 Purpose:   ������������������
            ��ϵͳ�ĺ��ĵ�Ԫ֮һ�����ڲ����������������ע�ᵽϵͳ�С�
            ���ӿڵ�ʵ�ֵ�Ԫ�������˷�����Щ����ķ������������ʼ��������
            �����������������Щע������г�ʼ�����������֮����໥����
            ָ�븳ֵ��
 History:
-----------------------------------------------------------------------------}

unit uHJX.Intf.FuncCompManager;

interface
uses
    system.SysUtils, {Classes, }{uIAppServices}uHJX.Intf.AppServices, uHJX.Core.FuncCompTypes;

type
    EPluginLoadError = class(Exception);

    IFunctionComponentManager = interface(IInterface)
        ['{CFBA9B03-A2D7-4F7E-A940-33D326ECAD1A}']
        { ע������� }
        procedure RegisterDispatcher(AFCType: PFuncCompRegister; ADispatcher: TObject);
        { ע���� }
        procedure RegisterClass(AFCType: PFuncCompRegister; AClass: TClass);
        { ע�����ʵ�� }
        procedure RegisterComponent(AFCType: PFuncCompRegister; AComponent: TObject);
        { ע�ắ�������̡�������ֻ��ע����Ϣ����������Ӧ�ĵ��������� }
        procedure RegisterEntry(AFCType: PFuncCompRegister);
    end;

    { ���в����ע�������Ϊ:RegisterFuncComp }
    TRegistProcedure = procedure(Manager: IFunctionComponentManager); stdcall;

var
    IFuncCompManager: IFunctionComponentManager;
implementation

initialization

finalization
    //IFuncCompManager := nil;

end.
