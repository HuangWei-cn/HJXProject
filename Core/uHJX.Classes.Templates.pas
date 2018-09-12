{ 模板类
    本单元定义的是所有模板类的父类。子类模板包括图表模板、表格模板、Excel数据表模板等
}
unit uHJX.Classes.Templates;

interface

uses
    System.Classes, System.Generics.Collections, System.SysUtils;

type

    { 模板类别:图表模板，WebGrid表格模板，Excel表格模板 }
    /// <remarks>模板类别：Chart模板、WebGrid模板、Excel表格模板。目前仅支持者三种</remarks>
    TTplCategory = (tplChart, tplWebGrid, tplXLGrid);

    { 模板抽象类 }
    TTemplateClass = class of ThjxTemplate;

    /// <summary>
    /// 模板抽象类，是所有其他各类型模板的父类。
    /// </summary>
    /// <remarks> IAppServices接口管理模板集合，从模板集合中可获取
    /// 各个模板对象，但返回的是本类类型，需要调用者再转换为具体的类型。
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
    /// 模板集合，可从IAppServices.Tempaltes属性访问。
    /// </summary>
    /// <remarks>本类是抽象类，具体实现参见<see cref="uHJX.Template.TemplatesImp.pas"/>单元。
    /// 通过访问本集合，插件可获取具体的模板对象。
    /// 本集合管理目前所支持的三类模板，调用者通过本集合获得的模板对象是ThjxTemplate类型，
    /// 必须自行转换为相对应的类型才能使用。
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
