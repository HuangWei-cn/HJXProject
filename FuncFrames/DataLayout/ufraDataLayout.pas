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

// TOnNeedDataIncEvent = procedure(AID:string; ADataName:string; var Data:Variant;
// var DT1,DT2:TDateTime) of object;

  TOnMeterEvent = procedure(AID: string; var Param: string) of object;

  TOnNeedDeformDataEvent = procedure(AID: String; XName, YName: string; var XData: Variant;
    var YData: Variant; var DT: TDateTime) of object;

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
    ProgressBar1: TProgressBar;
    N1: TMenuItem;
    piHideObject: TMenuItem;
    piInputMeterData: TMenuItem;
    N2: TMenuItem;
    piPopupDataWindow: TMenuItem;
    btnListObjects: TToolButton;
    ToolButton14: TToolButton;
    procedure sgDataLayoutObjectMouseEnter(Graph: TSimpleGraph; GraphObject: TGraphObject);
    procedure sgDataLayoutObjectMouseLeave(Graph: TSimpleGraph; GraphObject: TGraphObject);
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
    procedure sgDataLayoutKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure sgDataLayoutKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure sgDataLayoutMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
      var Handled: Boolean);
    procedure sgDataLayoutMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
      var Handled: Boolean);
    procedure piHideObjectClick(Sender: TObject);
    procedure sgDataLayoutDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure piInputMeterDataClick(Sender: TObject);
    procedure piPopupDataWindowClick(Sender: TObject);
    procedure btnListObjectsClick(Sender: TObject);
  private
        { Private declarations }
    FOnNeedDataEvent      : TOnNeedDataEvent;
    FOnNeedDeformDataEvent: TOnNeedDeformDataEvent; // 2019-08-09
    FOnNeedIncrementEvent : TOnNeedDataEvent;       // 请求数据增量事件
    FOnPlayBeginning      : TNotifyEvent;
    FOnPlayFinished       : TNotifyEvent;

    FLayoutFileName: string;
    FAutoDataFormat: Boolean;      // 是否由DataItem自动设置数据显示格式，缺省为自动
    FMeterList     : TStringList;  // 仪器列表 2018-06-05
    FSelectedMeter : string;       // 2018-06-07
    FSelectedObj   : TGraphObject; // 按下右键弹出菜单时的那个图形对象。执行时对象设置为不可选择，故……

    FOnMeterClick   : TOnMeterEvent; // 选中仪器产生的事件，返回值为弹出菜单中图形的名称
    FPopupDataGraph : TOnMeterEvent; // 弹出数据图形事件
    FPopupDataViewer: TOnMeterEvent; // 弹出数据表事件

    FPreCmd      : TGraphCommandMode; // 上一次命令
    FHoldSpaceKey: Boolean;           // 按下Space键

    procedure LockMap(bLock: Boolean);
    procedure ShowDataItem(AnItem: TdmcDataItem);
    procedure ShowDataIncrement(AnItem: TdmcDataItem);
    { 2019-08-09 }
    procedure ShowDeform(AnItem: TdmcDeformationDirection);
    /// <summary>
    /// 在这里，用这个方法实现拖放后自动对齐数据标签，加快版面整洁程度
    /// </summary>
    procedure GraphEndDragging(Graph: TSimpleGraph; GraphObject: TGraphObject; HT: DWORD;
      Cancelled: Boolean);

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadDataLayout(AFile: string);
    procedure Play(ShowIncrement: Boolean = False);
    procedure ClearDatas;
    procedure PopupEditorWindow;
    procedure PopupGraphObjList;

    { properties.... }
    property OnNeedDataEvent: TOnNeedDataEvent read FOnNeedDataEvent write FOnNeedDataEvent;
    property OnNeedDeformEvent: TOnNeedDeformDataEvent read FOnNeedDeformDataEvent
      write FOnNeedDeformDataEvent;
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

uses ufrmInputLayoutData, ufrmDataItemsList;
{$R *.dfm}


constructor TfraDataLayout.Create(AOwner: TComponent);
begin
  inherited;
  FAutoDataFormat := True;
  FMeterList := TStringList.Create;
  sgDataLayout.OnObjectEndDrag := Self.GraphEndDragging;
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
  FSelectedObj := Obj;
  if Obj is TdmcDataItem then
  begin
    FSelectedMeter := (Obj as TdmcDataItem).DesignName;
    FOnMeterClick((Obj as TdmcDataItem).DesignName, S);
    piShowDataGraph.Caption := S;
    piHideObject.Enabled := True;
    piInputMeterData.Enabled := True;
    Handled := False;
  end
  else
  begin
    piHideObject.Enabled := False;
    piInputMeterData.Enabled := False;
    Handled := True;
  end;
end;

procedure TfraDataLayout.sgDataLayoutDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  go         : TGraphNode;
  tp         : TPoint;
  bNeedAlign : Boolean; // 需要设置对齐
  bSetDefault: Boolean; // 需要设置缺省值
  oo         : TGraphObject;
begin
  { 本方法不再使用2022-05-13 }
  // tp := sgDataLayout.ClientToGraph(X, Y);
  // oo := sgDataLayout.FindObjectAt(tp.X, tp.Y);
(*
// 如果X，Y处有东西，且为TGPTEXTNODE对象，则需要对齐
  if (oo <> nil) and (oo is TGPTextNode) then
  begin
    bNeedAlign := True;
    if not FdefAlignRight then
    begin
      tp.X := (oo as TGPTextNode).Left;
      tp.Y := (oo as TGPTextNode).BoundsRect.Bottom + 2;
    end
    else
    begin
      tp.X := (oo as TGPTextNode).BoundsRect.Right - 10;
      tp.Y := (oo as TGPTextNode).BoundsRect.Bottom + 2;
    end;
  end
  else
    bNeedAlign := False;

 *)
end;

procedure TfraDataLayout.sgDataLayoutKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FHoldSpaceKey := Key = 32;
  if sgDataLayout.CommandMode <> cmPan then
    if FHoldSpaceKey then
    begin
      FPreCmd := sgDataLayout.CommandMode;
      sgDataLayout.CommandMode := cmPan;
    end;
end;

procedure TfraDataLayout.sgDataLayoutKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 32 then
  begin
    if FHoldSpaceKey then
    begin
      FHoldSpaceKey := False;
      sgDataLayout.CommandMode := FPreCmd;
      if FPreCmd <> cmPan then
          sgDataLayout.Invalidate;
    end;
  end;
end;

procedure TfraDataLayout.sgDataLayoutMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  MousePos := sgDataLayout.ScreenToClient(MousePos);
  if PtInRect(sgDataLayout.ClientRect, MousePos) then
  begin
    sgDataLayout.ChangeZoomBy(-1, zocursor);
    sgDataLayout.Update;
    Handled := True;
  end;
end;

procedure TfraDataLayout.sgDataLayoutMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  MousePos := sgDataLayout.ScreenToClient(MousePos);
  if PtInRect(sgDataLayout.ClientRect, MousePos) then
  begin
    sgDataLayout.ChangeZoomBy(1, zocursor);
    sgDataLayout.Update;
    Handled := True;
  end;
end;

procedure TfraDataLayout.sgDataLayoutObjectClick(Graph: TSimpleGraph; GraphObject:
  TGraphObject);
var
  S: string;
begin
  FSelectedObj := nil;
  if GraphObject is TdmcDataItem then
  begin
    FSelectedMeter := (GraphObject as TdmcDataItem).DesignName;
    piInputMeterData.Enabled := True;
  end
  else if GraphObject is TdmcMeterLabel then
      FSelectedMeter := (GraphObject as TdmcMeterLabel).DesignName
  else
  begin
    piHideObject.Enabled := False;
    piInputMeterData.Enabled := False;
    popMeterOp.AutoPopup := False;
    FSelectedMeter := '';
    Exit;
  end;

  FSelectedObj := GraphObject;
  piHideObject.Enabled := True;
  popMeterOp.AutoPopup := True;
  if Assigned(FOnMeterClick) then
  begin
    S := '';
    FOnMeterClick(FSelectedMeter, S);
    if S <> '' then
        piShowDataGraph.Caption := S
    else
        piShowDataGraph.Caption := '显示数据图形';
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
    piShowDataGraph.Caption := S;
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

procedure TfraDataLayout.btnListObjectsClick(Sender: TObject);
begin
  PopupGraphObjList;
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
  i: Integer;
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
      end
      else if Items[i] is tdmcMap then
          SetBackgroundMap(Items[i] as tdmcMap);
    FMeterList.Sort;
  end;
end;

procedure TfraDataLayout.LockMap(bLock: Boolean);
var
  i: Integer;
begin
  with sgDataLayout.Objects do
    for i := 0 to Count - 1 do
      if Items[i] is tdmcMap then
      begin
                // 如果要锁定，下面的属性应设置为False，正好与本方法的参数含义相反，因此……
        tdmcMap(Items[i]).Selectable := not bLock;
        tdmcMap(Items[i]).Resizeable := not bLock;
        tdmcMap(Items[i]).Moveable := not bLock;
      end;
end;

procedure TfraDataLayout.piHideObjectClick(Sender: TObject);
begin
  if FSelectedObj <> nil then
      FSelectedObj.Visible := False;
end;

procedure TfraDataLayout.piInputMeterDataClick(Sender: TObject);
var
  S: String;
begin
  if FSelectedObj = nil then Exit;
  if not(FSelectedObj is TdmcDataItem) then Exit;

  S := (FSelectedObj as TdmcDataItem).Text;
  S := InputBox('输入数据', '请输入需要显示的数据：', S);
  (FSelectedObj as TdmcDataItem).Text := S;
end;

{ -----------------------------------------------------------------------------
  Procedure  : piPopupDataWindowClick
  Description: 弹出数据输入窗口
----------------------------------------------------------------------------- }
procedure TfraDataLayout.piPopupDataWindowClick(Sender: TObject);
begin
  PopupEditorWindow;
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

{ -----------------------------------------------------------------------------
  Procedure  : Play
  Description: 显示数据方法
----------------------------------------------------------------------------- }
procedure TfraDataLayout.Play(ShowIncrement: Boolean = False);
var
  i      : Integer;
  qryObjs: TStrings;
  DataItem: TdmcDataItem;
begin
  if (not ShowIncrement) and (not Assigned(FOnNeedDataEvent)) then
      Exit;
  qryObjs := TStringList.Create;
  try
    Screen.Cursor := crHourGlass;
    sgDataLayout.CommandMode := cmViewOnly;
    sgDataLayout.ShowHint := True;
    if Assigned(FOnPlayBeginning) then FOnPlayBeginning(Self);
        // LockMap(True);

    ProgressBar1.Min := 0;
    ProgressBar1.Max := sgDataLayout.ObjectsCount;
    ProgressBar1.Position := 0;
    ProgressBar1.Visible := True;

    /// 如果直接采用轮询所有对象的方式，则可能对同一个仪器查询多次，有一些图包含多个断面，同一只仪器
    /// 可能出现多次，没必要全部查询一遍。因此，每查询一支仪器，就同时检查是否有重复的，若有重复的则
    /// 填入已查询到的数据，然后去掉那个就可以了。
    { TODO: 避免对同一只仪器查询多次 }
(*
      for i := 0 to sgDataLayout.ObjectsCount - 1 do
        if sgDataLayout.Objects.Items[i] is TdmcDataItem then
          with sgDataLayout.Objects.Items[i] as TdmcDataItem do
          begin
            qryObjs.Add(DesignName);
            qryObjs.Objects[qryObjs.Count - 1] := sgDataLayout.Objects.Items[i];
          end;

      while qryObjs.Count >0 do
      begin
        DataItem := qryObjs.Objects[0] as TdmcDataItem;
      end;

*)
    for i := 0 to sgDataLayout.ObjectsCount - 1 do
    begin
      ProgressBar1.Position := i + 1;
      if sgDataLayout.Objects.Items[i] is TdmcDataItem then
      begin
        if not ShowIncrement then
            ShowDataItem(sgDataLayout.Objects.Items[i] as TdmcDataItem)
        else
          if Assigned(FOnNeedIncrementEvent) then // 如果能显示增量就显示，否则显示数据
            ShowDataIncrement(sgDataLayout.Objects.Items[i] as TdmcDataItem)
        else
            ShowDataItem(sgDataLayout.Objects.Items[i] as TdmcDataItem);
      end
      else if sgDataLayout.Objects.Items[i] is TdmcDeformationDirection then
          ShowDeform(sgDataLayout.Objects.Items[i] as TdmcDeformationDirection);
    end;

    chkViewOnly.Checked := True;
  finally
    Screen.Cursor := crDefault;
    if Assigned(FOnPlayFinished) then FOnPlayFinished(Self);
    ProgressBar1.Visible := False;
    qryObjs.Free;
  end;
end;

procedure TfraDataLayout.ClearDatas;
var
  i: Integer;
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
  else if VarIsNumeric(PDData) then
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
  Data : Variant;
  DT   : TDateTime;
  i    : Integer;
  S    : string;
  sHint: string;
  Incr : Integer;
begin
  OnNeedIncrementEvent(AnItem.DesignName, AnItem.DataName, Data, DT);
  if (VarIsNull(Data)) or (VarIsEmpty(Data)) or (VarToStr(Data) = '') then
      S := '/'
  else
      S := VarToStr(Data);
  // 处理增量返回结果中的附加Hint部分
  i := Pos('#', S);
  sHint := Copy(S, i + 1, length(S) - i);
  S := Copy(S, 0, i - 1);

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
  AnItem.Hint := AnItem.DesignName + ' : ' + AnItem.DataName + #13#10 + sHint;
end;

procedure TfraDataLayout.ShowDeform(AnItem: TdmcDeformationDirection);
var
  PDData: Variant;
  DT    : TDateTime;
  S     : String;
  X, Y  : Variant;
begin
  // OnNeedDataEvent(AnItem.DesignName, AnItem.DataName, PDData, DT);
  OnNeedDeformEvent(AnItem.DesignName, AnItem.XDataName, AnItem.YDataName, X, Y, DT);
  AnItem.SetData(X, Y);
  // AnItem.North := X;
  // AnItem.East := Y;
  AnItem.ShowData('', DT);
end;

{ -----------------------------------------------------------------------------
  Procedure  : GraphEndDragging
  Description: 拖拽图元，判断是否需要自动对齐
----------------------------------------------------------------------------- }
procedure TfraDataLayout.GraphEndDragging(Graph: TSimpleGraph; GraphObject: TGraphObject;
  HT: Cardinal;
  Cancelled: Boolean);
var
  Obj       : TGraphObject;
  drpSide   : Integer;
  coLT, coBR: TPoint; // Covered object top-left point & bottom-right point
  goLT      : TPoint; // graphobject top-left point
  dW, dH    : Integer;
begin
  // 只有TdmcDataItem和TdmcMeterLabel才享受本过程的处理
  if not((GraphObject is TdmcDataItem) or (GraphObject is TdmcMeterLabel)) then
  begin
    Cancelled := True;
    Exit;
  end;

  // 只有当GraphObject盖在其他东西上面的时候才进行处理
  with GraphObject as TGraphNode do
  begin
    Obj := Graph.FindObjectAt(GraphObject.BoundsRect.Left - 4, GraphObject.BoundsRect.Top - 4);
    { todo:再斟酌是否针对所有TextNode都执行自动对齐 }
    if Obj is TGPTextNode { (Obj is TdmcDataItem) or (Obj is TdmcMeterLabel) } then
    begin
{$IFDEF DEBUG}
      OutputDebugString(PChar('覆盖了这个东西：' + (Obj as TGPTextNode).Text + #13#10));
{$ENDIF}
      // 取坐标
      // coLT := Point((Obj as TGPTextNode).Left, (Obj as TGPTextNode).Top);
      coLT := Obj.BoundsRect.TopLeft;
      coBR := Obj.BoundsRect.BottomRight;
      goLT := GraphObject.BoundsRect.TopLeft;
      dW := (coBR.X - coLT.X) div 3; // 取判断的范围，基本上是三分之一吧
      dH := (coBR.Y - coLT.Y) div 3;
      drpSide := 0;
      // 下面将Snap到Obj的下方，并且根据拖放的位置自动设置对齐
      // 判断是放置到左侧还是右侧
      if (goLT.X >= coLT.X) and (goLT.X <= coLT.X + dW) then
          drpSide := 10
      else if (goLT.X >= coBR.X - dW) and (goLT.X <= coBR.X) then
          drpSide := 20;

      // 判断放置到顶还是底，抑或两侧
      if (goLT.Y >= coLT.Y) and (goLT.Y <= coLT.Y + dH) then
          drpSide := drpSide + 0
      else if (goLT.Y >= coBR.Y - dH) and (goLT.Y <= coBR.Y) then
          drpSide := drpSide + 2
      else
          drpSide := drpSide + 1;
          // auto align graph object
      case drpSide of
        10: // top and left align
          with (GraphObject as TGPTextNode) do
          begin
            DataAlignRight := False;
            Left := Obj.BoundsRect.Left;
            Top := Obj.BoundsRect.Top - Height - 2;
          end;
        11: // left side and right align
          with (GraphObject as TGPTextNode) do
          begin
            DataAlignRight := True;
            Left := Obj.BoundsRect.Left - Width - 2;
            Top := Obj.BoundsRect.Top;
          end;
        12: // bottom side and left align
          with (GraphObject as TGPTextNode) do
          begin
            DataAlignRight := False;
            Left := Obj.BoundsRect.Left;
            Top := Obj.BoundsRect.Bottom + 2;
          end;
        20: // top side and right align
          with (GraphObject as TGPTextNode) do
          begin
            DataAlignRight := True;
            Left := coBR.X - Width;
            Top := Obj.BoundsRect.Top - Height - 2;
          end;
        21: // right side and left align
          with (GraphObject as TGPTextNode) do
          begin
            DataAlignRight := False;
            Left := coBR.X + 2;
            Top := Obj.BoundsRect.Top;
          end;
        22: // bottom side and right align
          with (GraphObject as TGPTextNode) do
          begin
            DataAlignRight := True;
            Left := coBR.X - Width;
            Top := Obj.BoundsRect.Bottom + 2;
          end;
      else
              // do nothing;
      end;
      // 下面将Snap到Obj的下方，并且对齐
      // align right side
      (*
      if (GraphObject as TGPTextNode).DataAlignRight then
        with GraphObject as TGraphNode do
        begin
          Left := (Obj as TGraphNode).BoundsRect.Right - Width;
          Top := (Obj as TGraphNode).BoundsRect.Bottom + 2;
        end
      else // align left side
        with GraphObject as TGraphNode do
        begin
          Left := (Obj as TGraphNode).Left;
          Top := (Obj as TGraphNode).BoundsRect.Bottom + 2;
        end;
 *)
    end;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : PopupEditorWindow
  Description: 弹出数据编辑窗口，方便手工输入数据
----------------------------------------------------------------------------- }
procedure TfraDataLayout.PopupEditorWindow;
var
  frm: TfrmInputLayoutData;
begin
  frm := TfrmInputLayoutData.Create(Self);
  frm.Layout := Self;
  frm.ShowModal;
  frm.Release;
end;

procedure TfraDataLayout.PopupGraphObjList;
var
  frm: TfrmDataItemsList;
begin
  frm := TfrmDataItemsList.Create(Self);
  frm.SGraph := Self.sgDataLayout;
  frm.ShowModal;
  frm.Release;
end;

end.
