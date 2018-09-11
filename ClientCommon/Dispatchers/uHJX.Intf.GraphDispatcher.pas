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
    TDrawFunc = function (ADesignName: string; AOwner:TComponent):TComponent;

    { 导出图形到文件函数定义，导出格式默认为JPEG，主要用于Web页面的图形链接。输入参数DTStart、DTEnd
      都为0，则输出该仪器全部观测数据；DTStart=0，从第一个数据开始，DTEnd=0，则为调用时当天。 }
    TExportChartToFileFunc = function(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
        AWidth, AHeight: Integer): string;
    { 导出图形到Stream函数定义，用于HTMLViewer请求图形 }
    TExportChartToStreamFunc = function(ADesignName: string; DTStart, DTEnd: TDateTime;
        var AStream: TStream; AWidth, AHeight: Integer): Boolean;

    IGraphDispatcher = interface(IInterface)
        ['{50C43445-00A5-4B90-883D-A248F79196D5}']
        procedure PopupDataGraph(ADesignName:String; AContainer:TComponent = nil);
        procedure ShowDataGraph(ADesignName:string; AContainer:TComponent = nil);
        function ExportChartToFile(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
            AWidth, AHeight: Integer): string;
        function SaveChartToStream(ADesignName: string; DTStart, DTEnd: TDateTime; AStream: TStream;
            AWidth, AHeight: Integer): Boolean;

        procedure RegistDrawFuncs(AMeterType:string; AFunc: TDrawFunc);
        procedure RegistExportFunc(AMeterType:String; AFunc: TExportChartToFileFunc);
        procedure RegistSaveStreamFunc(AMeterType: string; AFunc: TExportChartToStreamFunc);
    end;

implementation

end.
