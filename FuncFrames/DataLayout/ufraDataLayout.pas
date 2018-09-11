{ -----------------------------------------------------------------------------
 Unit Name: ufraDataLayoutPresentation
 Author:    黄伟
 Date:      25-四月-2017
 Purpose:   本单元是数据分布图演示
            本单元演示预定义的数据分布图，主要功能有：
            1. 将数据标注在底图上，
            2. 允许用户保存、 拷贝演示结果；
            3. 允许用户选择不同日期的数据；
            4. 允许用户在图中选择仪器查看其工程属性、观测数据、特征值、过程线；
 History:
    2018-06-05
            增加从布置图中获取仪器编号列表的方法，在MeterList属性中
    2018-06-14
            增加了显示数据增量的功能，目前暂时不能用不同颜色标示出增量的正负和
            大小，等下一步完善。
    2018-07-11
            用SimpleGraph的PopupMenu替代ObjectPopupMenu，解决图形被锁定后无法
            弹出菜单的问题。
    2018-07-16
            完成导出JPEG，GIF，PNG格式的功能，之前只能导出BMP格式。
----------------------------------------------------------------------------- }
{ todo:增加指定仪器高亮显示的功能，共调用者使用 }
unit ufraDataLayout;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SimpleGraph, System.Actions, Vcl.ActnList, Vcl.ComCtrls,
    System.ImageList, Vcl.ImgList, Vcl.ToolWin, Vcl.Imaging.jpeg, Vcl.StdCtrls, Vcl.Menus,
    Vcl.Imaging.GIFImg, Vcl.Imaging.pngimage,
    uhwSGEx, uhwSGEx.DataMapClasses;

type
    TOnNeedDataEvent = procedure(AID: string; ADataName: string; var Data: Variant;
        var DT: TDateTime) of object;

    TOnMeterEvent = procedure(AID: string; var Param: string) of object;

    TfraDataLayout = class(TFrame)
        sgDataLayout: TSimpleGraph;
        ToolBar1: TToolBar;
        ImageList: TImageList;
        ToolButton1: TToolButton;
        ToolButton2: TToolButton;
        ToolButton3: TToolButton;
        ToolButton4: TToolButton;
        ToolButton5: TToolButton;
        Actions: TActionList;
        ToolButton6: TToolButton;
        ToolButton7: TToolButton;
        ToolButton8: TToolButton;
        ToolButton9: TToolButton;
        ToolButton10: TToolButton;
        actSelectMode: TAction;
        actPanMode: TAction;
        actZoomIn: TAction;
        actZoomOut: TAction;
        actActualSize: TAction;
        actViewWholeGraph: TAction;
        actCopyToClipboard: TAction;
        actExportToFile: TAction;
        dlgExportLayout: TSaveDialog;
        ToolButton11: TToolButton;
        chkViewOnly: TCheckBox;
        ToolButton12: TToolButton;
        cmbShowStyle: TComboBox;
        popGraphFormat: TPopupMenu;
        piBitmap: TMenuItem;
        piMetafile: TMenuItem;
        actBitmap: TAction;
        actMetafile: TAction;
        popMeterOp: TPopupMenu;
        piShowDataGraph: TMenuItem;
        piShowData: TMenuItem;
        procedure sgDataLayoutObjectMouseEnter(Graph: TSimpleGraph; GraphObject: TGraphObject);
        procedure sgDataLayoutObjectMouseLeave(Graph: TSimpleGraph; GraphObject: TGraphObject);
        procedure sgDataLayoutObjectSelect(Graph: TSimpleGraph; GraphObject: TGraphObject);
        procedure sgDataLayoutObjectClick(Graph: TSimpleGraph; GraphObject: TGraphObject);
        procedure sgDataLayoutObjectDblClick(Graph: TSimpleGraph; GraphObject: TGraphObject);
        procedure actViewWholeGraphExecute(Sender: TObject);
        procedure actActualSizeExecute(Sender: TObject);
        procedure actActualSizeUpdate(Sender: TObject);
        procedure actViewWholeGraphUpdate(Sender: TObject);
        procedure actZoomOutExecute(Sender: TObject);
        procedure actZoomOutUpdate(Sender: TObject);
        procedure actZoomInExecute(Sender: TObject);
        procedure actZoomInUpdate(Sender: TObject);
        procedure actPanModeExecute(Sender: TObject);
        procedure actPanModeUpdate(Sender: TObject);
        procedure actSelectModeExecute(Sender: TObject);
        procedure actSelectModeUpdate(Sender: TObject);
        procedure actCopyToClipboardExecute(Sender: TObject);
        procedure actExportToFileExecute(Sender: TObject);
        procedure actExportToFileUpdate(Sender: TObject);
        procedure chkViewOnlyClick(Sender: TObject);
        procedure cmbShowStyleChange(Sender: TObject);
        procedure actCopyToClipboardUpdate(Sender: TObject);
        procedure actBitmapUpdate(Sender: TObject);
        procedure actMetafileUpdate(Sender: TObject);
        procedure piShowDataClick(Sender: TObject);
        procedure piShowDataGraphClick(Sender: TObject);
        procedure sgDataLayoutObjectContextPopup(Graph: TSimpleGraph; GraphObject: TGraphObject;
            const MousePos: TPoint; var Handled: Boolean);
        procedure sgDataLayoutContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    private
        { Private declarations }
        FOnNeedDataEvent     : TOnNeedDataEvent;
        FOnNeedIncrementEvent: TOnNeedDataEvent; // 请求数据增量事件
        FOnPlayBeginning     : TNotifyEvent;
        FOnPlayFinished      : TNotifyEvent;

        FLayoutFileName: string;
        FAutoDataFormat: Boolean;     // 是否由DataItem自动设置数据显示格式，缺省为自动
        FMeterList     : TStringList; // 仪器列表 2018-06-05
        FSelectedMeter : string;      // 2018-06-07

        FOnMeterClick   : TOnMeterEvent; // 选中仪器产生的事件，返回值为弹出菜单中图形的名称
        FPopupDataGraph : TOnMeterEvent; // 弹出数据图形事件
        FPopupDataViewer: TOnMeterEvent; // 弹出数据表事件

        procedure LockMap(bLock: Boolean);
        procedure ShowDataItem(AnItem: TdmcDataItem);
        procedure ShowDataIncrement(AnItem: TdmcDataItem);
    public
        { Public declarations }
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure LoadDataLayout(AFile: string);
        procedure Play(ShowIncrement: Boolean = False);
        procedure ClearDatas;
        property OnNeedDataEvent: TOnNeedDataEvent read FOnNeedDataEvent write FOnNeedDataEvent;
        property OnNeedIncrementEvent: TOnNeedDataEvent read FOnNeedIncrementEvent
            write FOnNeedIncrementEvent;
        property OnMeterClickEvent: TOnMeterEvent read FOnMeterClick write FOnMeterClick;
        property OnPopupDataGraph: TOnMeterEvent read FPopupDataGraph write FPopupDataGraph;
        property OnPopupDataViewer: TOnMeterEvent read FPopupDataViewer write FPopupDataViewer;
        property OnPlayBeginning: TNotifyEvent read FOnPlayBeginning write FOnPlayBeginning;
        property OnPlayFinished: TNotifyEvent read FOnPlayFinished write FOnPlayFinished;
        property MeterList: TStringList read FMeterList; // 2018-06-05
    end;

implementation

{$R *.dfm}


constructor TfraDataLayout.Create(AOwner: TComponent);
begin
    inherited;
    FAutoDataFormat := True;
    FMeterList := TStringList.Create;
end;

destructor TfraDataLayout.Destroy;
begin
    FMeterList.Free;
    inherited;
end;

{ -----------------------------------------------------------------------------
  Procedure  : sgDataLayoutContextPopup
  Description: 目前，仅针对数据对象可以弹出菜单，提供的功能为显示数据或过程线
----------------------------------------------------------------------------- }
procedure TfraDataLayout.sgDataLayoutContextPopup(Sender: TObject; MousePos: TPoint;
    var Handled: Boolean);
var
    S  : String;
    Obj: TGraphObject;
begin
    Obj := sgDataLayout.ObjectAtCursor;
    // ShowMessage(Obj.ClassName);
    if Obj is TdmcDataItem then
    begin
        FSelectedMeter := (Obj as TdmcDataItem).DesignName;
        FOnMeterClick((Obj as TdmcDataItem).DesignName, S);
        piShowDataGraph.caption := S;
        Handled := False;
    end
    else
        Handled := True;
end;

procedure TfraDataLayout.sgDataLayoutObjectClick(Graph: TSimpleGraph; GraphObject:
    TGraphObject);
var
    S: string;
begin
    if GraphObject is TdmcDataItem then
    begin
        FSelectedMeter := (GraphObject as TdmcDataItem).DesignName;
        popMeterOp.AutoPopup := True;
        if Assigned(FOnMeterClick) then
        begin
            S := '';
            FOnMeterClick((GraphObject as TdmcDataItem).DesignName, S);
            if S <> '' then
                piShowDataGraph.caption := S
            else
                piShowDataGraph.caption := '显示数据图形';
        end;
    end
    else
    begin
        popMeterOp.AutoPopup := False;
        FSelectedMeter := '';
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : sgDataLayoutObjectContextPopup
  Description: 弃用，改为SimpleGraph的PopupMenu取代。原因是，一旦图形对象被锁定，
  基于对象的弹出式菜单无法弹出。
----------------------------------------------------------------------------- }
procedure TfraDataLayout.sgDataLayoutObjectContextPopup(Graph: TSimpleGraph;
    GraphObject: TGraphObject; const MousePos: TPoint; var Handled: Boolean);
var
    S: string;
begin
    if GraphObject is TdmcDataItem then
    begin
        FOnMeterClick((GraphObject as TdmcDataItem).DesignName, S);
        piShowDataGraph.caption := S;
        Handled := False;
    end
    else
        Handled := True;
end;

procedure TfraDataLayout.sgDataLayoutObjectDblClick(Graph: TSimpleGraph; GraphObject:
    TGraphObject);
begin
//
end;

procedure TfraDataLayout.sgDataLayoutObjectMouseEnter(Graph: TSimpleGraph; GraphObject:
    TGraphObject);
begin
//
end;

procedure TfraDataLayout.sgDataLayoutObjectMouseLeave(Graph: TSimpleGraph; GraphObject:
    TGraphObject);
begin
//
end;

procedure TfraDataLayout.sgDataLayoutObjectSelect(Graph: TSimpleGraph; GraphObject:
    TGraphObject);
begin
//
end;

procedure TfraDataLayout.actActualSizeExecute(Sender: TObject);
begin
    sgDataLayout.ChangeZoom(100, zoTopLeft);
end;

procedure TfraDataLayout.actActualSizeUpdate(Sender: TObject);
begin
    actActualSize.Enabled := (sgDataLayout.Zoom <> 100);
end;

procedure TfraDataLayout.actBitmapUpdate(Sender: TObject);
begin
    actBitmap.Enabled := True;
end;

procedure TfraDataLayout.actCopyToClipboardExecute(Sender: TObject);
begin
    if actBitmap.Checked then
    begin
        if not(cfBitmap in sgDataLayout.ClipboardFormats) then
            sgDataLayout.ClipboardFormats := sgDataLayout.ClipboardFormats + [cfBitmap]
    end
    else
        if not(cfMetafile in sgDataLayout.ClipboardFormats) then
        sgDataLayout.ClipboardFormats := sgDataLayout.ClipboardFormats + [cfMetafile];

    sgDataLayout.CopyToClipboard(False);
end;

procedure TfraDataLayout.actCopyToClipboardUpdate(Sender: TObject);
begin
    actCopyToClipboard.Enabled := sgDataLayout.Objects.Count > 0;
end;

procedure TfraDataLayout.actExportToFileExecute(Sender: TObject);
var
    JpgImg: TJPEGImage;
    GIFImg: TGIFImage;
    PngImg: TPngImage;
begin
    if actBitmap.Checked then
    begin
        dlgExportLayout.Filter := GraphicFilter(TBitmap);
        dlgExportLayout.DefaultExt := GraphicExtension(TBitmap);
        dlgExportLayout.FileName := ChangeFileExt(FLayoutFileName,
            '.' + dlgExportLayout.DefaultExt);
        if dlgExportLayout.Execute then
        begin

            case dlgExportLayout.FilterIndex of
                0, 1, 2:
                    sgDataLayout.SaveAsBitmap(dlgExportLayout.FileName);
                3, 4:
                    begin
                        JpgImg := TJPEGImage.Create;
                        try
                            sgDataLayout.CopyToGraphic(JpgImg);
                            JpgImg.SaveToFile(dlgExportLayout.FileName);
                        finally
                            JpgImg.Free;
                        end;
                    end;
                5:
                    begin
                        GIFImg := TGIFImage.Create;
                        try
                            sgDataLayout.CopyToGraphic(GIFImg);
                            GIFImg.SaveToFile(dlgExportLayout.FileName);
                        finally
                            GIFImg.Free;
                        end;
                    end;
                6:
                    begin
                        PngImg := TPngImage.Create;
                        try
                            sgDataLayout.CopyToGraphic(PngImg);
                            PngImg.SaveToFile(dlgExportLayout.FileName);
                        finally
                            PngImg.Free;
                        end;
                    end;
            end;

        end;
    end
    else
    begin
        dlgExportLayout.Filter := GraphicFilter(TMetafile);
        dlgExportLayout.DefaultExt := GraphicExtension(TMetafile);
        dlgExportLayout.FileName := ChangeFileExt(FLayoutFileName,
            '.' + dlgExportLayout.DefaultExt);
        if dlgExportLayout.Execute then
            sgDataLayout.SaveAsMetafile(dlgExportLayout.FileName);
    end;
end;

procedure TfraDataLayout.actExportToFileUpdate(Sender: TObject);
begin
    actExportToFile.Enabled := sgDataLayout.Objects.Count > 0;
end;

procedure TfraDataLayout.actMetafileUpdate(Sender: TObject);
begin
    actMetafile.Enabled := True;
end;

procedure TfraDataLayout.actPanModeExecute(Sender: TObject);
begin
    sgDataLayout.CommandMode := cmPan;
end;

procedure TfraDataLayout.actPanModeUpdate(Sender: TObject);
begin
    actPanMode.Checked := (sgDataLayout.CommandMode = cmPan);
    actPanMode.Enabled := (sgDataLayout.HorzScrollBar.IsScrollBarVisible or
        sgDataLayout.VertScrollBar.IsScrollBarVisible);
end;

procedure TfraDataLayout.actSelectModeExecute(Sender: TObject);
begin
    sgDataLayout.CommandMode := cmViewOnly;
end;

procedure TfraDataLayout.actSelectModeUpdate(Sender: TObject);
begin
    // actSelectMode.Enabled := (sgDataLayout.CommandMode in [cmViewOnly]);
end;

procedure TfraDataLayout.actViewWholeGraphExecute(Sender: TObject);
begin
    sgDataLayout.ZoomGraph;
end;

procedure TfraDataLayout.actViewWholeGraphUpdate(Sender: TObject);
begin
    actViewWholeGraph.Enabled := (sgDataLayout.Objects.Count > 0);
end;

procedure TfraDataLayout.actZoomOutExecute(Sender: TObject);
begin
    sgDataLayout.ChangeZoomBy(-10, zoCursorCenter);
end;

procedure TfraDataLayout.actZoomOutUpdate(Sender: TObject);
begin
    actZoomOut.Enabled := (sgDataLayout.Zoom > Low(tzoom));
end;

procedure TfraDataLayout.chkViewOnlyClick(Sender: TObject);
begin
    if chkViewOnly.Checked then
        sgDataLayout.CommandMode := cmViewOnly
    else
        sgDataLayout.CommandMode := cmEdit;
end;

procedure TfraDataLayout.actZoomInExecute(Sender: TObject);
begin
    sgDataLayout.ChangeZoomBy(10, zoCursorCenter);
end;

procedure TfraDataLayout.actZoomInUpdate(Sender: TObject);
begin
    actZoomIn.Enabled := (sgDataLayout.Zoom < High(tzoom));
end;

{ -----------------------------------------------------------------------------
  Procedure  : LoadDataLayout
  Description: 加载布置图文件，并更新仪器列表
----------------------------------------------------------------------------- }
procedure TfraDataLayout.LoadDataLayout(AFile: string);
var
    i: integer;
    S: string;
begin
    FLayoutFileName := AFile;
    FMeterList.Clear;
    sgDataLayout.LoadFromFile(AFile);
    // sgDataLayout.CommandMode := cmViewOnly;
    sgDataLayout.Zoom := 100;
    LockMap(True);
    with sgDataLayout.Objects do
    begin
        for i := 0 to Count - 1 do
            if Items[i] is TdmcDataItem then
            begin
                S := TdmcDataItem(Items[i]).DesignName;
                if FMeterList.IndexOf(S) = -1 then
                    FMeterList.Add(S);
            end;
        FMeterList.Sort;
    end;
end;

procedure TfraDataLayout.LockMap(bLock: Boolean);
var
    i: integer;
begin
    with sgDataLayout.Objects do
        for i := 0 to Count - 1 do
            if Items[i] is TdmcMap then
            begin
                // 如果要锁定，下面的属性应设置为False，正好与本方法的参数含义相反，因此……
                TdmcMap(Items[i]).Selectable := not bLock;
                TdmcMap(Items[i]).Resizeable := not bLock;
                TdmcMap(Items[i]).Moveable := not bLock;
            end;
end;

procedure TfraDataLayout.piShowDataClick(Sender: TObject);
var
    S: string;
begin
    if Assigned(FPopupDataViewer) then
        FPopupDataViewer(FSelectedMeter, S);
end;

procedure TfraDataLayout.piShowDataGraphClick(Sender: TObject);
var
    S: string;
begin
    if Assigned(FPopupDataGraph) then
        FPopupDataGraph(FSelectedMeter, S);
end;

procedure TfraDataLayout.Play(ShowIncrement: Boolean = False);
var
    i: integer;
begin
    if (not ShowIncrement) and (not Assigned(FOnNeedDataEvent)) then
        Exit;
    try
        Screen.Cursor := crHourGlass;
        sgDataLayout.CommandMode := cmViewOnly;
        sgDataLayout.ShowHint := True;
        if Assigned(FOnPlayBeginning) then
            FOnPlayBeginning(Self);
        // LockMap(True);
        for i := 0 to sgDataLayout.ObjectsCount - 1 do
            if sgDataLayout.Objects.Items[i] is TdmcDataItem then
                if not ShowIncrement then
                    ShowDataItem(sgDataLayout.Objects.Items[i] as TdmcDataItem)
                else
                    if Assigned(FOnNeedIncrementEvent) then // 如果能显示增量就显示，否则显示数据
                    ShowDataIncrement(sgDataLayout.Objects.Items[i] as TdmcDataItem)
                else
                    ShowDataItem(sgDataLayout.Objects.Items[i] as TdmcDataItem);
        chkViewOnly.Checked := True;

    finally
        Screen.Cursor := crDefault;
        if Assigned(FOnPlayFinished) then
            FOnPlayFinished(Self);
    end;
end;

procedure TfraDataLayout.ClearDatas;
var
    i: integer;
begin
    for i := 0 to sgDataLayout.Objects.Count - 1 do
        if sgDataLayout.Objects.Items[i] is TdmcDataItem then
            TdmcDataItem(sgDataLayout.Objects.Items[i]).ClearData;
    sgDataLayout.CommandMode := cmEdit;
    // LockMap(False);
    chkViewOnly.Checked := False;
end;

procedure TfraDataLayout.cmbShowStyleChange(Sender: TObject);
begin
    // 重新设置格式
    Play;
end;

procedure TfraDataLayout.ShowDataItem(AnItem: TdmcDataItem);
var
    PDData: Variant;
    DT    : TDateTime;
    S     : String;
begin
    OnNeedDataEvent(AnItem.DesignName, AnItem.DataName, PDData, DT);
    { 5种数据格式：
        0数据(自动格式)
        1数据名：数据
        2观测日期：数据
        3观测日期|数据名：数据
        4仪器编号（数据名）|数据
        5仪器编号|数据名：数据
        6仪器编号（数据名）|观测日期：数据

        数据(自动格式)
        数据名：数据
        仪器编号（数据名）|数据
        仪器编号|数据名：数据
        仪器编号（数据名）|观测日期：数据
 }
    if VarIsNull(PDData) or VarIsEmpty(PDData) or (VarToStr(PDData) = '') then
        S := '/'
    else if VarIsFloat(PDData) then
        S := FormatFloat('0.00', PDData)
    else
        S := VarToStr(PDData);

    case cmbShowStyle.ItemIndex of
        0: // 数据（自动格式）
           // do nothing
            ;

        1: // 数据名: 数据
            S := AnItem.DataName + ': ' + S;
        2: // 观测日期：数据
            S := FormatDateTime('yyyy-mm-dd', DT) + '：' + S;
        3: // 观测日期|数据名：数据
            S := Format('%s'#10'%s：%s', [FormatDateTime('yyyy-mm-dd', DT), AnItem.DataName, S]);
        4: // 仪器编号（数据名）|数据
            S := Format('%s(%s)'#10'%s', [AnItem.DesignName, AnItem.DataName, S]);

        5: // 仪器编号|数据名：数据
            S := Format('%s'#10'%s: %s', [AnItem.DesignName, AnItem.DataName, S]);

        6: // 仪器编号（数据名）|观测日期：数据
            S := Format('%s(%s)'#10'%s: %s', [AnItem.DesignName, AnItem.DataName,
                FormatDateTime('yyyy-mm-dd', DT), S]);
    end;
    AnItem.ShowData(S, DT);
end;

procedure TfraDataLayout.ShowDataIncrement(AnItem: TdmcDataItem);
var
    Data: Variant;
    DT  : TDateTime;
    S   : string;
    Incr: integer;
begin
    OnNeedIncrementEvent(AnItem.DesignName, AnItem.DataName, Data, DT);
    if (VarIsNull(Data)) or (VarIsEmpty(Data)) or (VarToStr(Data) = '') then
        S := '/'
    else
        S := VarToStr(Data);

    // 判断S中是否有上箭头或下箭头，上箭头数据增大，下箭头数据减少
    if Pos('↑', S) > 0 then
        Incr := 1
    else if Pos('↓', S) > 0 then
        Incr := -1
    else
        Incr := 0;

    // 设置颜色
    { TODO: 使用不同颜色显示增量情况，如红色为正，蓝色为负等等 }
    // 显示内容
    AnItem.ShowData(S, DT);
end;

end.
