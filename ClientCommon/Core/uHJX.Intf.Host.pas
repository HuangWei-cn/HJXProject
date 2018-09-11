{ -----------------------------------------------------------------------------
 Unit Name: uIHost
 Author:    Administrator
 Date:      01-һ��-2013
 Purpose:   Host�ӿڣ���һЩ�ر��ķ������������ܼ�����
            ��׼����ΪMainForm�Ĵ����������Ӧ���߱�IHost�ӿڣ������������ܼ�
            ����������н��Լ����뵽Host�ĸ������桢���˵��У�ʵ�ֹ��ܵ��á�
 History:
----------------------------------------------------------------------------- }

unit uHJX.Intf.Host;

interface

uses SysUtils, Classes, Controls, Forms, {uIAppServices}uHJX.Intf.AppServices;

type
    IHost = interface(IInterface)
        ['{DD04FCFB-CEBE-4C03-8B75-F69587FD2205}']
        function HostMainMenu: TComponent;
        function HostPager: TComponent;
        function HostApp: TComponent;
        function HostActivePage: string;

        { ----------------���˵���أ������������������������������� }
        { ע����������˵�
          ���ܼ�ע�ᵽHost�˵������֣�һ���Ƿ������ã�һ�����޲ι��̵��á�����
          ��Host���˵��еĹ��ܼ���Ӧ�ǹ�����������Զ����Ĳ�����Frame����Form�� }
        function SetMeToMainMenu(ACategory, AItem, ASubItem: string; CallProc: TProcedure)
            : Boolean; overload;
        function SetMeToMainMenu(ACategory, AItem, ASubItem: string; CallMethod: TCallCompMethod)
            : Boolean; overload;
        { --------------- �����������----------------------------- }
        { ע��������������� }
        function SetMeToMainToolbar(ACategory, AItem, ASubItem: string; CallProc: TProcedure)
            : Boolean; overload;
        function SetMeToMainToolbar(ACategory, AItem, ASubItem: string; CallMethod: TCallCompMethod)
            : Boolean; overload;

        { -----------------������ҳ���--------------------------- }
        { ע���������PageControl��Host��Ϊ���ܼ�����һ���־õ�Page������ֵΪHost
          Ϊ�䴴����Page����ע���Page��������pageҳ�ϵĹرհ�ť���رգ���������
          Pagecontrol���ͷŶ��ͷ� }
        function SetMeToMainPager(APageCaption: string; AClient: TComponent;
            TabVisible: Boolean = False): TComponent; overload;
        function SetMeToMainPager(AClientClass: TWinControlClass; APageCaption: string;
            TabVisible: Boolean = False): TComponent; overload;

        { ����һ��Page����pageΪ��ʱ�ģ�����ʱ�ͷŵ� }
        function RequestPage(APageCaption: string; AClient: TComponent): TComponent;
        { ����ָ����Page���ڵ�ǰ���Page��ͨ����ע�ᵽPager�Ĺ��ܼ�������ʱ��
          �����������ڵ�page��ΪActivePage }
        procedure SetPageActive(APage: TComponent); overload;
        procedure SetPageActive(ACaption: String); overload;
        { �Ƿ����ָ��Caption��Page }
        function HasPage(ACaption: string; SetActive: Boolean = False): Boolean;

        { ----------------���������---------------------------- }
        { �����ܼ���������������������� }
        function SetMeToLeftPanel(ACategory, ACaption: string; AClient: TComponent): TComponent;
        { �����ܼ��������������·�����Ϣ��ʾ�� }
        function SetMeToLBPanel(ACategory, ACaption: string; AClient: TComponent): TComponent;

        { --------------- ����----------------------- }
        function OnClientFormClose: TCloseEvent;
    end;

implementation

end.
