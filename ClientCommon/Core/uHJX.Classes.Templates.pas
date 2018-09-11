{ ģ����
    ����Ԫ�����������ģ����ĸ��ࡣ����ģ�����ͼ��ģ�塢���ģ�塢Excel���ݱ�ģ���
}
unit uHJX.Classes.Templates;

interface

uses
    System.Classes, System.Generics.Collections, System.SysUtils;

type

    { ģ�����:ͼ��ģ�壬WebGrid���ģ�壬Excel���ģ�� }
    /// <remarks>ģ�����Chartģ�塢WebGridģ�塢Excel���ģ�塣Ŀǰ��֧��������</remarks>
    TTplCategory = (tplChart, tplWebGrid, tplXLGrid);

    { ģ������� }
    TTemplateClass = class of ThjxTemplate;

    /// <summary>
    /// ģ������࣬����������������ģ��ĸ��ࡣ
    /// </summary>
    /// <remarks> IAppServices�ӿڹ���ģ�弯�ϣ���ģ�弯���пɻ�ȡ
    /// ����ģ����󣬵����ص��Ǳ������ͣ���Ҫ��������ת��Ϊ��������͡�
    /// </remarks>
    ThjxTemplate = class
    private
        FTemplateName: string;
        FMeterType   : string;
        FCatege      : TTplCategory;
        FAnnotation  : string;
    public
        constructor Create; virtual;
    published
        property TemplateName: string read FTemplateName write FTemplateName;
        property MeterType   : string read FMeterType write FMeterType;
        property Category    : TTplCategory read FCatege write FCatege;
        property Annotation  : string read FAnnotation write FAnnotation;
    end;

    /// <summary>
    /// ģ�弯�ϣ��ɴ�IAppServices.Tempaltes���Է��ʡ�
    /// </summary>
    /// <remarks>�����ǳ����࣬����ʵ�ֲμ�<see cref="uHJX.Template.TemplatesImp.pas"/>��Ԫ��
    /// ͨ�����ʱ����ϣ�����ɻ�ȡ�����ģ�����
    /// �����Ϲ���Ŀǰ��֧�ֵ�����ģ�壬������ͨ�������ϻ�õ�ģ�������ThjxTemplate���ͣ�
    /// ��������ת��Ϊ���Ӧ�����Ͳ���ʹ�á�
    /// </remarks>
    TTemplates = class
    protected
        function GetCount: Integer; virtual; abstract;
        function GetChartTemplateCount: Integer; virtual; abstract;
        function GetWGTemplateCount: Integer; virtual; abstract;
        function GetXLTemplateCount: Integer; virtual; abstract;
        function GetItemByName(AName: string): ThjxTemplate; virtual; abstract;
        function GetCT(Index: Integer): ThjxTemplate; virtual; abstract;
        function GetWG(Index: Integer): ThjxTemplate; virtual; abstract;
        function GetXL(Index: Integer): ThjxTemplate; virtual; abstract;
    public
        procedure ClearAll; virtual; abstract;
        function AddChartTemplate(ChrtTmplClass: TTemplateClass): ThjxTemplate; virtual; abstract;
        function AddWGTemplate(WGTmplClass: TTemplateClass): ThjxTemplate; virtual; abstract;
        function AddXLTemplate(XLTmplClass: TTemplateClass): ThjxTemplate; virtual; abstract;

        property Count: Integer read GetCount;
        property ChartTemplateCount: Integer read GetChartTemplateCount;
        property WebGridTemplateCount: Integer read GetWGTemplateCount;
        property XLSGridTemplateCount: Integer read GetXLTemplateCount;

        property ItemByName[AName: string]: ThjxTemplate read GetItemByName;
        property ChartTemplate[index: Integer]: ThjxTemplate read GetCT;
        property WebGridTemplate[index: Integer]: ThjxTemplate read GetWG;
        property XLSGridTemplate[index: Integer]: ThjxTemplate read GetXL;
    end;

implementation

constructor ThjxTemplate.Create;
begin
    inherited;
end;

end.
