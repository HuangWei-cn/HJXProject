{-----------------------------------------------------------------------------
 Unit Name: uFuncCompTypes
 Author:    Administrator
 Date:      10-ʮ����-2012
 Purpose:   ���ܼ�����ṹ
            ÿ�����ܼ���ע��ʱ����Ҫ�ṩ����ṹ��ÿ����������ṩһ��ע���
            ������ʱһ���������������ܼ��������Ϊÿ�����ܼ��ύһ����Ӧ��
            ע���塣

            Requires���ǹ��ܼ�������ķ�����ܼ����г��Ĺ��ܼ�������ڲ���
            ���г�ʼ���������ܼ���������������

            ������أ�
            ��Ҫ���ڲ��֮����Զ����ɺͼ�ʱװ�䡣
            ÿ�����ܼ�������Ϊ�����ṩ�ߺͷ��������ߣ��������ṩһ��������
            ��Ҳ������Ҫ�򱻲������������������б���壬���ṩ�˲��
            �б����ͬʱ����һϵ������������������ߡ��۲����ݡ������༭��
            �������У�����Ҳ��ܾ�ĳЩ��������ʾ�۲���־��ʱ���ߡ��������༭
            �ȵĲ��롣

 History:
        2018-05-23
            ���˸����֣�
-----------------------------------------------------------------------------}
{ 2016-7-27
    1��TFuncCompType������fctInterface���ͣ�
    2�������˲�����÷������壺TPluginSetupProcedure��
    3��TFunctionComponentRegister�ṹ��������SetupProc��;

}
unit uHJX.Core.FuncCompTypes;

interface
uses
    {uIAppServices}uHJX.Intf.AppServices;
type
    { ���ܼ����� }
    TFuncCompType = (fctBase, fctInterface, fctDispatcher, fctFuncComp, fctClass, fctAssistent, fctAgent);
    TPluginType = (ptBuildIn, ptDLL, ptPackage);
    TInitProcedure = function(AppServices: IHJXAppServices): Boolean; stdcall;
    TPluginSetupProcedure = function: Boolean; stdcall;
    { ���в����ע��������Ϊ: UnregisterFuncComp }
    TUnRegistProcedure = procedure; stdcall;
    { ���ܼ�ע���� }
    TFunctionComponentRegister = record
        FuncCompType: TFuncCompType;
        PluginType: TPluginType;
        //�����ʼ������
        InitProc: TInitProcedure;
        //������÷����������������û����ò����һЩ��������Щ�������������ڳ���������ļ���
        SetupProc: TPluginSetupProcedure;
        //�����ע��������һ����˵���������Ҫ������������������Ҫ��������ж�ز��������Ҫ���ˡ�
        UnRegistProc: TUnRegistProcedure;
        Initiated: Boolean;
        RegisterName: string;
        Requires: string; //��Ҫ�ķ����ܣ���ʽ��name1, name2, name3....
        { ����������� }
        ServiceNames: string; //������ṩ�ķ���ServiceName1, ServiceName2,...
        ServiceType: string;  //��������: ItemList, DataContent,
        PermitServices: string; //���������ķ���: Name1,Name2,Name3...
        DenyServices: string; //������ܾ��ķ���: Name1,Name2,Name3...
        InterfaceType: string; //�������ͣ�Frame, Form, Component, None֮һ��
        { TODO:����������� }
        { �汾���������------- }
        Version: string; //����汾�����ڷǲ�����ܼ�������ο��汾
        DateIssued: string; //�������ڣ����ڷǲ�����ܼ��ô���Ϊ�ο�
        Description: string; //Widestring;
    end;
    PFuncCompRegister = ^TFunctionComponentRegister;

implementation
{   ServiceType˵����
    ItemList -- ��Ŀ�б������б������б��ĵ��б�ȵ�
    DataContent -- �������ݣ������ݱ������ߵ�
    Document -- �粼��ͼ���ϴ��ı����
    Editor -- �༭��
    Assistent�� Agent -- ���֡�������û�н���Ĵ�����̻򷽷�

}

end.
