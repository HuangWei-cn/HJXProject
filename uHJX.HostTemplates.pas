///<summary>
///��Host���ڵĹ�����Ӧ���õ�ģ�嵥Ԫ��ģ�������uHJX.Classes.Templates��Ԫ�Ѿ�������
///uHJX.CoreUnits.pas��Ԫ���ˣ��˴�ֻ�������󻯵��ࡢ�����ࡢ����ȡ�
///</summary>
unit uHJX.HostTemplates;

interface

uses
    {ģ������࣬��Templates�ļ���}
    uHJX.Template.TemplatesImp,   // TTemplates�������ʵ��
    uHJX.Template.ProcSpecifiers, // ģ��ռλ���Ĵ���
    uHJX.Template.ChartTemplate,  // Chartģ�����
    uHJX.Template.WebGrid,        // WebGridģ�����
    uHJX.Template.XLGrid,         // Excel Gridģ�����

    {ģ�崦��Ԫ����Functio\Templates�ļ���}
    uHJX.Template.ChartTemplateProc, //Chartģ�崦��Ԫ������ģ���ͼ
    uHJX.Template.WebGridProc,       //WebGridģ�崦��Ԫ������HTML����
    uHJX.Template.XLGridProc;        //Excel���ģ�崦��Ԫ�����ɰ������ݱ�Ĺ�����

implementation

end.
