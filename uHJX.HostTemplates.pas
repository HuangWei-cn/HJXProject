///<summary>
///在Host所在的工程中应引用的模板单元，模板基础类uHJX.Classes.Templates单元已经包含在
///uHJX.CoreUnits.pas单元中了，此处只包含具象化的类、处理类、子类等。
///</summary>
unit uHJX.HostTemplates;

interface

uses
    {模板对象类，在Templates文件夹}
    uHJX.Template.TemplatesImp,   // TTemplates抽象类的实现
    uHJX.Template.ProcSpecifiers, // 模板占位符的处理
    uHJX.Template.ChartTemplate,  // Chart模板对象
    uHJX.Template.WebGrid,        // WebGrid模板对象
    uHJX.Template.XLGrid,         // Excel Grid模板对象

    {模板处理单元，在Functio\Templates文件夹}
    uHJX.Template.ChartTemplateProc, //Chart模板处理单元，根据模板绘图
    uHJX.Template.WebGridProc,       //WebGrid模板处理单元，生成HTML代码
    uHJX.Template.XLGridProc;        //Excel表格模板处理单元，生成包含数据表的工作簿

implementation

end.
