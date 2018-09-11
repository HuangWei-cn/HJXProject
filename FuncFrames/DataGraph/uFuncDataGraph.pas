{ -----------------------------------------------------------------------------
  Unit Name: uFuncDataGraph
  Author:    ��ΰ
  Date:      07-����-2018
  Purpose:   ͼ�ι���ע�ᡢ���÷���ע�ᵥԪ
          һ����˵���ڹ����ļ������ñ���Ԫ���ɻ������������ͼ�ι���(��Ҫ���ò���
          ·��)������ʵ�ֵĵ�Ԫ��ufraTrendLineShell.pas�Ͳ��������ˡ�

          ����Ԫ��IFunctionDispatcher��ע����ShowDataGraph��PopupDataGraph������Ҫ
          ��������Ҫʹ������ͼ�ε�ģ�����з���IFunctionDispatcher��ط�����
          Ϊ��Ӧ��������ͼ�Σ�����Ԫ�ṩ��RegistDrawfuncs�������ṩ����ͼ�λ��Ƶĵ�
          Ԫ�ø÷���ע���Լ���
  History:
    2018-06-07 ������
        �����˵���ChartΪjpeg�ļ��Ĺ��ܡ���Chart��Jpeg��ʽд��Stream�Ĺ��ܡ�ͬʱ��
        Ҳ������IGraphDispatcher�ӿڵ�Ԫ����Implement��Ԫ������������������Ϊ
        ����������Ĺ������������������е㸴�ӣ����ⲿ������HTMLViewer��ҪͼƬ
        ʱ��Ҫô�Ƚ���ͼƬ�ļ����ã�Ҫôд��Stream����ʱ����Ҫ��ȡGraphDispatcher,
        ��GD��ExportChartTofile��SaveChartToStream������������������������ʵ��
        ���õ��Ǳ���Ԫ��ͬ������������д�������͵�Chart���ܻ�Ԫ�������Ʒ���
        ע�ᵽ����Ԫ��������Diapatcher���ñ���Ԫ��RegistExportchartToFileFuncs
        ��RegistSaveChartToStreamFuncsע��һ������ض��������͵ķ�����
        ����������Ͻ��������ķ�����������ʵ�Ǳ���Ԫ����GraphDispatcherֻ����
        �ṩ�˽ӿڿ��Թ㷺�������ѡ�
    2018-07-17
        ������Ԫ�Ĺ���Ǩ����uhjx.intfimp.graphdispatcher��Ԫ������Ԫ������
        ���úͻ�ͼ��صĵ�Ԫ��ȷ����Щ���ܱ����뵽�����С�
----------------------------------------------------------------------------- }
{ todo:Ӧ���ӻ���ָ�����ڷ�Χͼ�εĹ��� }
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
//    { ��ͼ�������Ͷ��� }
//    TDrawFunc = function(ADesignName: string; AOwner: TComponent): TFrame;
//
//{ ��ͼ����ע����̡���ĳ����ͼģ�����ĳ���ض����͵ļ������������ñ����̽���ע�� }
//procedure RegistDrawFuncs(AMeterType: string; AFunc: TDrawFunc);
//{ �����ļ�����ע����� }
//procedure RegistExportChartToFileFuncs(AMeterType: string; AFunc: TExportChartToFileFunc);
//{ ����ͼ�ε�Stream����ע����� }
//procedure RegistSaveChartToStreamFuncs(AMeterType: string; AFunc: TExportChartToStreamFunc);

implementation

//uses
//    ufraTrendLineShell, ufraDisplacementChartShell, uHJX.IntfImp.GraphDispatcher,
//    ufraBasePlaneDisplacementChart;

//type
//{ ��Ӧ������ }
//    TFrmEventObj = class
//    public
//        procedure Resize(Sender: TObject);
//        procedure PopupDataGraph(ADesignName: string; AContainer: TObject = nil);
//        procedure ShowDataGraph(ADesignName: string; AContainer: TObject = nil);
//    end;
//
//    // TDrawFunc = function(ADesignName: string): TFrame;
//    // ��ͼ����ע��ṹ��
//    TFuncReg = record
//        MeterType: string;
//        Func: TDrawFunc;
//    end;
//
//    PFuncReg = ^TFuncReg;
//
//    // �������ļ�����ע��ṹ��
//    TExportFuncReg = record
//        MeterType: string;
//        Func: TExportChartToFileFunc;
//    end;
//
//    PExportFuncReg = ^TExportFuncReg;
//
//    // ���浽Stream����ע��ṹ��
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
//  Description: ��ʾ����ͼ�Ρ�����������һ��Frame����Frame����ʾ����ͼ�Σ�����
//  Frame����AContainer�С��ڱ�������AContainer��Ϊnil�������PopupDataGraph����
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
//      Description: �������壬��ʾ����ͼ�Ρ���AContainer��Ϊnil�������ShowDataGraph��
//      ���򴴽�����
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
//            + '�۲�����ͼ��';
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
