{ -----------------------------------------------------------------------------
  Unit Name: uFuncDataGraph
  Author:    黄伟
  Date:      07-六月-2018
  Purpose:   图形功能注册、调用方法注册单元
          一般来说，在工程文件中引用本单元即可获得完整的数据图形功能(需要设置查找
          路径)，具体实现的单元如ufraTrendLineShell.pas就不必引用了。

          本单元向IFunctionDispatcher中注册了ShowDataGraph、PopupDataGraph两个主要
          方法，需要使用数据图形的模块自行访问IFunctionDispatcher相关方法。
          为适应各类数据图形，本单元提供了RegistDrawfuncs方法，提供具体图形绘制的单
          元用该方法注册自己。
  History:
    2018-06-07 创建日
        增加了导出Chart为jpeg文件的功能、将Chart以Jpeg格式写入Stream的功能。同时，
        也创建了IGraphDispatcher接口单元及其Implement单元。上述两个功能是作为
        这个调度器的公开方法。事情整的有点复杂：当外部功能如HTMLViewer需要图片
        时，要么先将从图片文件调用，要么写入Stream。这时候需要获取GraphDispatcher,
        用GD的ExportChartTofile或SaveChartToStream方法。调度器的这两个方法实际
        调用的是本单元的同名方法。若编写了新类型的Chart功能或单元，则类似方法
        注册到本单元，而不是Diapatcher。用本单元的RegistExportchartToFileFuncs
        和RegistSaveChartToStreamFuncs注册一个针对特定仪器类型的方法。
        从这个意义上讲，真正的方法调度器其实是本单元，而GraphDispatcher只不过
        提供了接口可以广泛传播而已。
    2018-07-17
        将本单元的功能迁移至uhjx.intfimp.graphdispatcher单元，本单元仅用于
        引用和绘图相关的单元，确保这些功能被加入到工程中。
----------------------------------------------------------------------------- }
{ todo:应增加绘制指定日期范围图形的功能 }
unit uFuncDataGraph;

interface

uses
    System.Classes,
    ufraTrendLineShell,
    ufraDisplacementChartShell,
    ufraBasePlaneDisplacementChart;
    {, Vcl.Controls, Vcl.Forms, System.SysUtils,
    uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher, uHJX.Classes.Meters,
    uHJX.Intf.GraphDispatcher}

//type
//    { 绘图函数类型定义 }
//    TDrawFunc = function(ADesignName: string; AOwner: TComponent): TFrame;
//
//{ 绘图方法注册过程。若某个绘图模块针对某个特定类型的监测仪器，则调用本过程进行注册 }
//procedure RegistDrawFuncs(AMeterType: string; AFunc: TDrawFunc);
//{ 导出文件方法注册过程 }
//procedure RegistExportChartToFileFuncs(AMeterType: string; AFunc: TExportChartToFileFunc);
//{ 导出图形到Stream方法注册过程 }
//procedure RegistSaveChartToStreamFuncs(AMeterType: string; AFunc: TExportChartToStreamFunc);

implementation

//uses
//    ufraTrendLineShell, ufraDisplacementChartShell, uHJX.IntfImp.GraphDispatcher,
//    ufraBasePlaneDisplacementChart;

//type
//{ 相应器对象 }
//    TFrmEventObj = class
//    public
//        procedure Resize(Sender: TObject);
//        procedure PopupDataGraph(ADesignName: string; AContainer: TObject = nil);
//        procedure ShowDataGraph(ADesignName: string; AContainer: TObject = nil);
//    end;
//
//    // TDrawFunc = function(ADesignName: string): TFrame;
//    // 绘图方法注册结构体
//    TFuncReg = record
//        MeterType: string;
//        Func: TDrawFunc;
//    end;
//
//    PFuncReg = ^TFuncReg;
//
//    // 导出到文件方法注册结构体
//    TExportFuncReg = record
//        MeterType: string;
//        Func: TExportChartToFileFunc;
//    end;
//
//    PExportFuncReg = ^TExportFuncReg;
//
//    // 保存到Stream方法注册结构体
//    TSaveFuncReg = record
//        MeterType: string;
//        Func: TExportChartToStreamFunc;
//    end;
//
//    PSaveFuncReg = ^TSaveFuncReg;
//
//var
//    FrmDefaultWidth : Integer = 600;
//    FrmDefaultHeight: Integer = 400;
//    frmEventObj     : TFrmEventObj;
//    DrawFuncs       : TList;
//    ExpFuncs        : TList;
//    SaveStreamFuncs : TList;
//    IGD             : IGraphDispatcher;
//
//function DrawDataGraph(ADesignName: string; AOwner: TComponent): TFrame;
//var
//    mt : string;
//    i  : Integer;
//    Reg: PFuncReg;
//begin
//    result := nil;
//    mt := ExcelMeters.Meter[ADesignName].Params.MeterType;
//    for i := 0 to DrawFuncs.Count - 1 do
//    begin
//        Reg := PFuncReg(DrawFuncs.Items[i]);
//        if Reg.MeterType = mt then
//        begin
//            result := Reg.Func(ADesignName, AOwner);
//            Break;
//        end;
//    end;
//end;
//
//function ExportChartToImage(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
//    AWidth, AHeight: Integer): string;
//var
//    mt : string;
//    i  : Integer;
//    Reg: PExportFuncReg;
//begin
//    result := '';
//    mt := ExcelMeters.Meter[ADesignName].Params.MeterType;
//    for i := 0 to ExpFuncs.Count - 1 do
//    begin
//        Reg := PExportFuncReg(ExpFuncs.Items[i]);
//        if Reg.MeterType = mt then
//        begin
//            result := Reg.Func(ADesignName, DTStart, DTEnd, APath, AWidth, AHeight);
//            Break;
//        end;
//    end;
//end;
//
//function SaveChartToStream(ADesignName: string; DTStart, DTEnd: TDateTime; var AStream: TStream;
//    AWidth, AHeight: Integer): Boolean;
//var
//    mt : string;
//    i  : Integer;
//    Reg: PSaveFuncReg;
//begin
//    result := false;
//    mt := ExcelMeters.Meter[ADesignName].Params.MeterType;
//    for i := 0 to SaveStreamFuncs.Count - 1 do
//    begin
//        Reg := PSaveFuncReg(SaveStreamFuncs.Items[i]);
//        if Reg.MeterType = mt then
//        begin
//            result := Reg.Func(ADesignName, DTStart, DTEnd, AStream, AWidth, AHeight);
//            Break;
//        end;
//    end;
//end;
//
//{ -----------------------------------------------------------------------------
//  Procedure  : ShowDataGraph
//  Description: 显示数据图形。本方法创建一个Frame，在Frame中显示数据图形，并将
//  Frame放入AContainer中。在本方法中AContainer若为nil，则调用PopupDataGraph方法
//  ----------------------------------------------------------------------------- }
//procedure TFrmEventObj.ShowDataGraph(ADesignName: string; AContainer: TObject = nil);
//var
//    fra: TFrame;
//begin
//    if AContainer = nil then
//        PopupDataGraph(ADesignName, AContainer)
//    else
//    begin
//        fra := DrawDataGraph(ADesignName, AContainer as TComponent);
//        fra.Align := alClient;
//        fra.Parent := AContainer as TWinControl;
//    end;
//end;
//
//    { -----------------------------------------------------------------------------
//      Procedure  : PopupDataGraph
//      Description: 弹出窗体，显示数据图形。若AContainer不为nil，则调用ShowDataGraph，
//      否则创建窗体
//      ----------------------------------------------------------------------------- }
//procedure TFrmEventObj.PopupDataGraph(ADesignName: string; AContainer: TObject = nil);
//var
//    frm, MainForm: TForm;
//begin
//    if AContainer <> nil then
//        ShowDataGraph(ADesignName, AContainer)
//    else
//    begin
//        MainForm := IAppServices.Host as TForm;
//        frm := TForm.Create(MainForm);
//        frm.OnClose := MainForm.OnClose;
//        frm.Width := FrmDefaultWidth;
//        frm.Height := FrmDefaultHeight;
//        frm.OnResize := frmEventObj.Resize;
//        frm.BorderStyle := bsSizeToolWin;
//        frm.Caption := IAppServices.ClientDatas.GetMeterTypeName(ADesignName) + ADesignName
//            + '观测数据图形';
//        try
//            Screen.Cursor := crHourGlass;
//            ShowDataGraph(ADesignName, frm);
//        finally
//            Screen.Cursor := crDefault;
//        end;
//
//        frm.Show;
//    end;
//end;
//
//procedure RegistDrawFuncs(AMeterType: string; AFunc: TDrawFunc);
//var
//    NewReg: PFuncReg;
//begin
//    New(NewReg);
//    NewReg.MeterType := AMeterType;
//    NewReg.Func := AFunc;
//    DrawFuncs.Add(NewReg);
//end;
//
//procedure RegistExportChartToFileFuncs(AMeterType: string; AFunc: TExportChartToFileFunc);
//var
//    NewReg: PExportFuncReg;
//begin
//    New(NewReg);
//    NewReg.MeterType := AMeterType;
//    NewReg.Func := AFunc;
//    ExpFuncs.Add(NewReg);
//end;
//
//procedure RegistSaveChartToStreamFuncs(AMeterType: string; AFunc: TExportChartToStreamFunc);
//var
//    NewReg: PSaveFuncReg;
//begin
//    New(NewReg);
//    NewReg.MeterType := AMeterType;
//    NewReg.Func := AFunc;
//    SaveStreamFuncs.Add(NewReg);
//end;
//
//procedure TFrmEventObj.Resize(Sender: TObject);
//begin
//    with Sender as TForm do
//    begin
//        FrmDefaultWidth := Width;
//        FrmDefaultHeight := Height;
//    end;
//end;
//
//procedure ClearFuncs;
//var
//    i: Integer;
//begin
//    for i := 0 to DrawFuncs.Count - 1 do
//        Dispose(DrawFuncs.Items[i]);
//    DrawFuncs.Clear;
//    for i := 0 to ExpFuncs.Count - 1 do
//        Dispose(ExpFuncs.Items[i]);
//    ExpFuncs.Clear;
//    for i := 0 to SaveStreamFuncs.Count - 1 do
//        Dispose(SaveStreamFuncs.Items[i]);
//    SaveStreamFuncs.Clear;
//end;
//
//procedure RegisterToDispatcher;
//var
//    IFD: IFunctionDispatcher;
//begin
//    IFD := IAppServices.FuncDispatcher as IFunctionDispatcher;
//    //IFD.RegistFuncShowDataGraph(frmEventObj.ShowDataGraph);
//    //IFD.RegistFuncPopupDataGraph(frmEventObj.PopupDataGraph);
//    if Supports(IAppServices.GetDispatcher('GraphDispatcher'), IGraphDispatcher, IGD) then
//        if Assigned(IGD) then
//        begin
//            //IGD.RegistExportFunc(ExportChartToImage);
//            //IGD.RegistSaveStreamFunc(SaveChartToStream);
//        end;
//end;

//initialization
//
//frmEventObj := TFrmEventObj.Create;
//DrawFuncs := TList.Create;
//ExpFuncs := TList.Create;
//SaveStreamFuncs := TList.Create;
//
//RegisterToDispatcher;
//
//finalization
//
//frmEventObj.Free;
//ClearFuncs;
//DrawFuncs.Free;
//ExpFuncs.Free;
//SaveStreamFuncs.Free;

end.
