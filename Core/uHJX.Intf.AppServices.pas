{ -----------------------------------------------------------------------------
 Unit Name: uIAppServices
 Author:    Administrator
 Date:      08-ʮ����-2012
 Purpose:   Ӧ�÷���ӿڣ��ṩ���ܼ�������������ӿ�
 History:
    2013-01-01
        ע�Ṧ�ܼ������˵��ȷ���ת�Ƶ�IHost�ӿ��У���AppServices�н�����ʹ�ã�
        ��IHost�ӿڲ������뵽PSMISCommon.bpl�����Host�ķ������Ծ����޸ġ�
    2016-7-28
        ������RegistOpenDBManProc��OpenDatabaseManager�����������ݷ��ʲ����
        ����ʱ���ø÷���ע����������ӽ��淽������Ϊ����ԭ�ȵĲ�����ؼ���
        ʼ�����̣�ֻ�е��������ӽ���֮�󣨼����ӵ����ݿ�֮�󣩲Ż��ʼ������
        ������������ݷ��ʹ���Ҳ��ȡ�����ʽʱ���ͻ�����޷��������ݿ�����Ρ�
        ���ݷ��ʲ������������ض����ݿ�ƽ̨�ķ��ʡ����ӡ�ά���������ܡ�
    2018-05-23
        �ְ�������ϵͳ���˰��죬���ڻ�����һ���ˡ����ӿڡ�IfuncCompManager
        �ӿ��Ǳ����в���������õġ���AppServeces��FuncCompManager��ʵ����
        ��Ԫ��������򹤳��ļ��������ڶ��������ĵ�Ԫ����һ����ShareMem��Ԫ��
        AppServices��FuncCompManager�Ľӿڱ�����ȫ�ֵģ������ǵ�ʵ��Ҳ��ȫ��
        �ģ�ֻ���ڲ����Ӧ��ֻʹ�ýӿڶ��������ֱ��ʹ��ʵ��������������Ԫ
        �໥���ã�ֻ����App�ӿڶ�FuncCompManager�����������صģ�������������
        �����������󡢹��ܼ�ʱ��Appʵ��������FuncCompManagerʵ��ȥ���Ҳ����ء�
        �������ܼ���ע����ʱ��FuncCompManagerע�ᣬ������ʼ������ע�Ṧ��
        ʱ�������������ע�Ṧ�ܺ����򷽷������������FunctionDispacher����Ȼ
        Ҳ����������ָ���ĵ���������ע�ᣬ�������ݱ༭����������ͼ������������
        �������ȵȡ����ڿ�����չ���ֲ�ͬ�ĵ������������ϵͳ�;߱��˼������
        չ�����������ڱ�������ʹ�ò��ϵͳ������Ϊ������Ӧ��ͬ�����ݿ����ͣ�
        ��Ӧ���಻ͬ�����ݱ����廨���ŵĻ�ͼ������ͨ����˵��һ�����ܼ�����
        ��ʱ��Ӧ��֪������Ҫ�����ĵ��������Ѿ����ڵĻ������ܼ���Ҫ��Щ���ܡ�
        ��Щ������չ���ɱ�����ṩ���ȵȡ�
----------------------------------------------------------------------------- }

unit uHJX.Intf.AppServices;

interface

uses
    SysUtils, Classes, Controls, {uIClientDatas} uHJX.Intf.Datas, {uIProjectGlobal}
    uHJX.Intf.ProjectGlobal;

type
    TCallCompMethod = procedure(Sender: TObject) of object;

    IHJXAppServices = interface(IInterface)
        ['{41F58DC3-62E1-4493-99E6-939D7C09DE8B}']
        { ����ClientDatas������������һ���Ƿ���TObject��һ���Ƿ���IClientDatas��
          ʹ�����ַ�����ԭ����dmClient���ܻ��ж���ӿڣ����ڷ�IClientDatas�ĵ�
          ���߿�ʹ��GetClientDatas������ȡ������Ľӿ� }
        function GetClientDatas: TObject;
        // function GetClientDatasInterface: IClientDatas;
        function GetClientDatasInterface: IClientFuncs;
        function GetProject: IHJXProject;
        function GetGlobalDatas: IHJXProjectGlobalDatas;
        /// <summary>��ȡһ��ָ�����Ƶĵ������ӿڡ�ϵͳ����չʱ��ͨ�����õ�����
        /// ���й�����չ���Ա��ڷ�չ��һ�����ϵͳ�����ù���Ĺ����顣
        /// </summary>
        function GetDispatcher(ADispatcherName: string): TObject;
        function GetFunctionComp(ACompName: string): IInterface;
        function GetFuncCompClass(AClassName: string): TClass;
        function GetFuncCompClassInstance(AClassName: string): TObject;
        function GetComponent(ACompName: string): TObject;
        /// <summary>���ڻ��IFunctionDispatcher�ӿڣ�������IClientDatasͬ����Ҫ�Ľӿڣ�
        /// �ṩ�˳��õĹ��ܣ��Լ���������ģ���ڸýӿ�ע��Ĺ��ܵ������</summary>
        function GetFuncDispatcher: IInterface; // ����ӿ���Ҫ�Լ�����ͬ��dmClient
        function GetApplication: TObject;       // �������Application����
        function GetHost: TObject;              // �����������MainForm����
        function GetMeters: TObject;            // ��������
        function GetMeterGroups: TObject;       // �����鼯��
        function GetDSNames: TObject;           // �������Ƽ���
        function GetLayouts: TObject;           // �ֲ�ͼ����
        function GetTemplates: TObject;         // ģ�弯��

        function Logged: Boolean;

        procedure RegisterClientDatas(AClientDatas: TObject);
        procedure ReleaseClientDatas;
        { 2016-7-28 ע����������ӽ���ķ��� }
        procedure RegisterOpenDBManProc(AProc: TProcedure);

        { ���� }
        procedure SetProject(AProject: IHJXProject);
        procedure SetGlobalDatas(AGD: IHJXProjectGlobalDatas);

        //2018-09-13 ������5��Set...��ӵ��ӿ���
        procedure SetMeters(MeterList: TObject);
        procedure SetMeterGroups(MeterGroupList: TObject);
        procedure SetLayouts(ALayoutList: TObject);
        procedure SetDSNames(DSNameList: TObject);
        procedure SetTemplates(ATmpl: TObject);

        { 2016-7-28 }
        procedure OpenDatabaseManager;

        { �¼��������¼��Ĺ��ܼ�������Щ��������AppServices������ע�������� }
        procedure OnLogin(Sender: TObject);
        procedure OnLogout(Sender: TObject);
        procedure OnRemoteConnect(Sender: TObject);
        procedure OnRemoteDisconnect(Sender: TObject);
        procedure OnNotifyEvent(AEvent: string; Sender: TObject);
        /// <summary>���ͨ������IAppServices.ProcessMessage��ʱ������Ȩ�����������Application��
        /// �������ֹͣ��Ӧ��</summary>
        procedure ProcessMessages;

        { ע���¼������� }
        /// <summary>��ϵͳ����ĳ������ʱ��֪ͨע���ߡ����磬��������ɾ��ʱ��֪ͨ�����б�������Ӧ
        /// ���б���ɾ���������������ݿ�رա�����ʱ��֪ͨĳЩ����ģ�鷢������Щ���顣��Ҫ���
        /// �¼���ģ����ڴ�ע���¼������Ƽ�֪ͨ��Ϣ���(�ص�����)��
        /// </summary>
        /// <remarks>
        /// ϵͳԼ����ϵ�л����¼������Ź��ܵ������ƣ���Щ��Ϊ��׼���ܵ�ģ��Ҳ���ܻ�����Լ���
        /// �¼�����Щ���¼�Ҳ���𽥱����뵽��׼�¼��С�
        /// </remarks>
        procedure RegEventDemander(DemandEvent: string; OnEvent: TNotifyEvent);

        { properties }
        // property ClientDatas: IClientDatas read GetClientDatasInterface;
        property ClientDatas: IClientFuncs read GetClientDatasInterface;
        property Project: IHJXProject read GetProject;
        property GlobalDatas: IHJXProjectGlobalDatas read GetGlobalDatas;
        property Application: TObject read GetApplication;
        property Host: TObject read GetHost;
        property FuncDispatcher: IInterface read GetFuncDispatcher;
        /// <summary>��������</summary>
        property Meters: TObject read GetMeters;
        /// <summary>�����鼯��</summary>
        property MeterGroups: TObject read GetMeterGroups;
        property DSNames: TObject read GetDSNames;
        property Layouts: TObject read GetLayouts;
        property Templates: TObject read GetTemplates;
    end;

var
    // IApplicationServices: IHJXAppServices;
    { IAppServices�������������д��ݵĺ��ķ������й��ܼ�ͨ����������������������ܼ��ṩ�Ĺ��ܣ�
      �����ַ���ʵ�ָ���ģ��֮��Ľ�� }
    IAppServices: IHJXAppServices;

implementation

initialization

finalization

// IApplicationServices := nil;
end.
