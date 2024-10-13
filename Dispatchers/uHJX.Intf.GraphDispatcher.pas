{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Intf.GraphDispatcher
 Author:    黄伟
 Date:      14-六月-2018
 Purpose:   图形处理调度器
    图形功能调度器向本程序提供了一系列图形处理的方法，如过程线、矢量图、位移图、
    分布图等等，以及其他扩展分析功能所需或所提供的图形功能的调用接口。
    这些功能的实现者向本接口注册相关的功能入口，访问者通过接口进行调用，本接口
    将调用请求转发给功能提供者，返回结果，就这样。
 History:   2018-06-14 创建日
    2018-07-17 将原uFuncDataGraph单元中的功能迁移至本接口中
----------------------------------------------------------------------------- }

unit uHJX.Intf.GraphDispatcher;

interface

uses
  System.Classes;

type
  TGroupGraphType = (ggtTrendLine { 过程线 } , ggtBar { 棒图 } , ggtMeterLine { 分布图 } );

    { todo:TDrawFunc没有要求StartDate和EndDate，无法绘制数据区间的内容 }
    /// <summary>
    /// 绘图方法。完成对某仪器的绘图后，返回一个包含TeeChart组件的Component实例，
    /// 该实例的parent和Owner都是参数AOwner，且返回的Component.Align = alClient。
    /// 若AOwner = nil，则弹出一个form，绘图结果在此form中。
    /// </summary>
    /// <remarks>这个函数目前没有提供StartDate和EndDate，只能从头画到尾。</remarks>
  TDrawFunc = function(ADesignName: string; AOwner: TComponent): TComponent;

    /// <summary>
    /// 绘多个仪器过程线方法。
    /// </summary>
    /// <remarks></remarks>
  TDrawGroupGraphFunc = function(AMeters: TStrings; AOwner: TComponent): TComponent;

    { 导出图形到文件函数定义，导出格式默认为JPEG，主要用于Web页面的图形链接。输入参数DTStart、DTEnd
      都为0，则输出该仪器全部观测数据；DTStart=0，从第一个数据开始，DTEnd=0，则为调用时当天。 }
  TExportChartToFileFunc = function(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
    AWidth, AHeight: Integer): string;
    { 导出图形到Stream函数定义，用于HTMLViewer请求图形 }
  TExportChartToStreamFunc = function(ADesignName: string; DTStart, DTEnd: TDateTime;
    var AStream: TStream; AWidth, AHeight: Integer): Boolean;

    /// <summary>
    /// 绘图功能调度器。在主功能调度器IFunctionDispatcher中已经有了DrawGraph方法用于绘制监测仪器
    /// 过程线，一般情况下已经够用了。但是，那个接口的规格已经定死，要扩展就需要使用通用方法的形式
    /// 注册绘图方法，使用起来比较麻烦，因此增加了这个图形功能调度器。本调度器目前提供了4个功能
    /// 方法，和三个注册方法，用于绘图、输出、注册。
    /// </summary>
  IGraphDispatcher = interface(IInterface)
    ['{50C43445-00A5-4B90-883D-A248F79196D5}']
        /// <summary>
        /// 弹出包含绘图结果的窗口。这个方法和ShowDataGraph的区别在于AContainer = nil。当
        /// ShowDataGraph的参数AContainer = nil时，结果等同于调用本方法。弹出的窗口Form的Onwer是
        /// Host，且form.OnCloseEvent = Host.OnClose。Host.OnClose事件中的Action = caClose，这样
        /// 当Form关闭时，将释放自身及其所有组件。
        /// <para>本方法执行时，由于AContainer = nil，因此本方法创建了一个Form作为Container，然后
        /// 调用ShowDataGraph，将创建的form作为Container传递给它。
        /// </para>
        /// </summary>
    procedure PopupDataGraph(ADesignName: String; AContainer: TComponent = nil);
        /// <summary>
        /// 绘图方法。通常用于绘制观测过程线、矢量图、位移图等。本方法执行后，绘图提供者会创建
        /// 一个包含绘图结果的Frame，该Frame将包含在AContainer中，且最大化，即Frame.Parent =
        /// AContainer, Frame.Align = alClient。当AContainer = nil时，本方法等同于PopupDataGraph。
        /// </summary>
    procedure ShowDataGraph(ADesignName: string; AContainer: TComponent = nil);
        /// <summary>
        /// 2022-10-27
        /// 绘制一组仪器过程线方法。与ShowDataGraph不同在于，这两个只绘制过程线；ShowDataGraph则
        /// 根据注册的方法实例决定如何绘图，可能是过程线，也可能是箭头图、散点图等。
        /// </summary>
    procedure ShowGroupGraph(AGraphType: TGroupGraphType; AMeters: TStrings;
      AContainer: TComponent = nil);
    procedure PopupGroupGraph(AGraphType: TGroupGraphType; AMeters: TStrings;
      AContainer: TComponent = nil);
        /// <summary>
        /// 导出数据图形到文件。通常情况是导出为jpg格式。参数AWidth, AHeight是导出图形的长宽。
        /// </summary>
    function ExportChartToFile(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
      AWidth, AHeight: Integer): string;
        /// <summary>
        /// 导出Chart到Stream，这个方法用于在不导出文件的情况下在内嵌浏览器(HTMLViewer)中显示图形，
        /// 算是个专门的用途。
        /// </summary>
    function SaveChartToStream(ADesignName: string; DTStart, DTEnd: TDateTime; AStream: TStream;
      AWidth, AHeight: Integer): Boolean;

    { 以下三个方法注册绘图方法、导出方法、存为Stream方法 }
    procedure RegistDrawFuncs(AMeterType: string; AFunc: TDrawFunc);
    procedure RegistExportFunc(AMeterType: String; AFunc: TExportChartToFileFunc);
    procedure RegistSaveStreamFunc(AMeterType: string; AFunc: TExportChartToStreamFunc);
    /// <summary>
    /// 注册绘制组过程线方法
    /// </summary>
    procedure RegistDrawGroupGraphFunc(AGraphType: TGroupGraphType; AFunc: TDrawGroupGraphFunc);
  end;

implementation

end.
