{ -----------------------------------------------------------------------------
 Unit Name: ufraDataLayoutPresentation
 Author:    ��ΰ
 Date:      25-����-2017
 Purpose:   ����Ԫ�����ݷֲ�ͼ��ʾ
            ����Ԫ��ʾԤ��������ݷֲ�ͼ����Ҫ�����У�
            1. �����ݱ�ע�ڵ�ͼ�ϣ�
            2. �����û����桢 ������ʾ�����
            3. �����û�ѡ��ͬ���ڵ����ݣ�
            4. �����û���ͼ��ѡ�������鿴�乤�����ԡ��۲����ݡ�����ֵ�������ߣ�
 History:
    2018-06-05
            ���ӴӲ���ͼ�л�ȡ��������б�ķ�������MeterList������
    2018-06-14
            ��������ʾ���������Ĺ��ܣ�Ŀǰ��ʱ�����ò�ͬ��ɫ��ʾ��������������
            ��С������һ�����ơ�
    2018-07-11
            ��SimpleGraph��PopupMenu���ObjectPopupMenu�����ͼ�α��������޷�
            �����˵������⡣
    2018-07-16
            ��ɵ���JPEG��GIF��PNG��ʽ�Ĺ��ܣ�֮ǰֻ�ܵ���BMP��ʽ��
----------------------------------------------------------------------------- }
{ todo:����ָ������������ʾ�Ĺ��ܣ���������ʹ�� }
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
    FOnNeedIncrementEvent : TOnNeedDataEvent;       // �������������¼�
    FOnPlayBeginning      : TNotifyEvent;
    FOnPlayFinished       : TNotifyEvent;

    FLayoutFileName: string;
    FAutoDataFormat: Boolean;      // �Ƿ���DataItem�Զ�����������ʾ��ʽ��ȱʡΪ�Զ�
    FMeterList     : TStringList;  // �����б� 2018-06-05
    FSelectedMeter : string;       // 2018-06-07
    FSelectedObj   : TGraphObject; // �����Ҽ������˵�ʱ���Ǹ�ͼ�ζ���ִ��ʱ��������Ϊ����ѡ�񣬹ʡ���

    FOnMeterClick   : TOnMeterEvent; // ѡ�������������¼�������ֵΪ�����˵���ͼ�ε�����
    FPopupDataGraph : TOnMeterEvent; // ��������ͼ���¼�
    FPopupDataViewer: TOnMeterEvent; // �������ݱ��¼�

    FPreCmd      : TGraphCommandMode; // ��һ������
    FHoldSpaceKey: Boolean;           // ����Space��

    procedure LockMap(bLock: Boolean);
    procedure ShowDataItem(AnItem: TdmcDataItem);
    procedure ShowDataIncrement(AnItem: TdmcDataItem);
    { 2019-08-09 }
    procedure ShowDeform(AnItem: TdmcDeformationDirection);
    /// <summary>
    /// ��������������ʵ���Ϸź��Զ��������ݱ�ǩ���ӿ��������̶�
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
  Description: Ŀǰ����������ݶ�����Ե����˵����ṩ�Ĺ���Ϊ��ʾ���ݻ������
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
  bNeedAlign : Boolean; // ��Ҫ���ö���
  bSetDefault: Boolean; // ��Ҫ����ȱʡֵ
  oo         : TGraphObject;
begin
  { ����������ʹ��2022-05-13 }
  // tp := sgDataLayout.ClientToGraph(X, Y);
  // oo := sgDataLayout.FindObjectAt(tp.X, tp.Y);
(*
// ���X��Y���ж�������ΪTGPTEXTNODE��������Ҫ����
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
        piShowDataGraph.Caption := '��ʾ����ͼ��';
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : sgDataLayoutObjectContextPopup
  Description: ���ã���ΪSimpleGraph��PopupMenuȡ����ԭ���ǣ�һ��ͼ�ζ���������
  ���ڶ���ĵ���ʽ�˵��޷�������
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
  Description: ���ز���ͼ�ļ��������������б�
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
                // ���Ҫ���������������Ӧ����ΪFalse�������뱾�����Ĳ��������෴����ˡ���
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
  S := InputBox('��������', '��������Ҫ��ʾ�����ݣ�', S);
  (FSelectedObj as TdmcDataItem).Text := S;
end;

{ -----------------------------------------------------------------------------
  Procedure  : piPopupDataWindowClick
  Description: �����������봰��
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
  Description: ��ʾ���ݷ���
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

    /// ���ֱ�Ӳ�����ѯ���ж���ķ�ʽ������ܶ�ͬһ��������ѯ��Σ���һЩͼ����������棬ͬһֻ����
    /// ���ܳ��ֶ�Σ�û��Ҫȫ����ѯһ�顣��ˣ�ÿ��ѯһ֧��������ͬʱ����Ƿ����ظ��ģ������ظ�����
    /// �����Ѳ�ѯ�������ݣ�Ȼ��ȥ���Ǹ��Ϳ����ˡ�
    { TODO: �����ͬһֻ������ѯ��� }
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
          if Assigned(FOnNeedIncrementEvent) then // �������ʾ��������ʾ��������ʾ����
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
    // �������ø�ʽ
  Play;
end;

procedure TfraDataLayout.ShowDataItem(AnItem: TdmcDataItem);
var
  PDData: Variant;
  DT    : TDateTime;
  S     : String;
begin
  OnNeedDataEvent(AnItem.DesignName, AnItem.DataName, PDData, DT);
    { 5�����ݸ�ʽ��
        0����(�Զ���ʽ)
        1������������
        2�۲����ڣ�����
        3�۲�����|������������
        4������ţ���������|����
        5�������|������������
        6������ţ���������|�۲����ڣ�����

        ����(�Զ���ʽ)
        ������������
        ������ţ���������|����
        �������|������������
        ������ţ���������|�۲����ڣ�����
 }
  if VarIsNull(PDData) or VarIsEmpty(PDData) or (VarToStr(PDData) = '') then
      S := '/'
  else if VarIsNumeric(PDData) then
      S := FormatFloat('0.00', PDData)
  else
      S := VarToStr(PDData);

  case cmbShowStyle.ItemIndex of
    0: // ���ݣ��Զ���ʽ��
           // do nothing
      ;

    1: // ������: ����
      S := AnItem.DataName + ': ' + S;
    2: // �۲����ڣ�����
      S := FormatDateTime('yyyy-mm-dd', DT) + '��' + S;
    3: // �۲�����|������������
      S := Format('%s'#10'%s��%s', [FormatDateTime('yyyy-mm-dd', DT), AnItem.DataName, S]);
    4: // ������ţ���������|����
      S := Format('%s(%s)'#10'%s', [AnItem.DesignName, AnItem.DataName, S]);

    5: // �������|������������
      S := Format('%s'#10'%s: %s', [AnItem.DesignName, AnItem.DataName, S]);

    6: // ������ţ���������|�۲����ڣ�����
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
  // �����������ؽ���еĸ���Hint����
  i := Pos('#', S);
  sHint := Copy(S, i + 1, length(S) - i);
  S := Copy(S, 0, i - 1);

    // �ж�S���Ƿ����ϼ�ͷ���¼�ͷ���ϼ�ͷ���������¼�ͷ���ݼ���
  if Pos('��', S) > 0 then
      Incr := 1
  else if Pos('��', S) > 0 then
      Incr := -1
  else
      Incr := 0;

    // ������ɫ
    { TODO: ʹ�ò�ͬ��ɫ��ʾ������������ɫΪ������ɫΪ���ȵ� }
    // ��ʾ����
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
  Description: ��קͼԪ���ж��Ƿ���Ҫ�Զ�����
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
  // ֻ��TdmcDataItem��TdmcMeterLabel�����ܱ����̵Ĵ���
  if not((GraphObject is TdmcDataItem) or (GraphObject is TdmcMeterLabel)) then
  begin
    Cancelled := True;
    Exit;
  end;

  // ֻ�е�GraphObject�����������������ʱ��Ž��д���
  with GraphObject as TGraphNode do
  begin
    Obj := Graph.FindObjectAt(GraphObject.BoundsRect.Left - 4, GraphObject.BoundsRect.Top - 4);
    { todo:�������Ƿ��������TextNode��ִ���Զ����� }
    if Obj is TGPTextNode { (Obj is TdmcDataItem) or (Obj is TdmcMeterLabel) } then
    begin
{$IFDEF DEBUG}
      OutputDebugString(PChar('���������������' + (Obj as TGPTextNode).Text + #13#10));
{$ENDIF}
      // ȡ����
      // coLT := Point((Obj as TGPTextNode).Left, (Obj as TGPTextNode).Top);
      coLT := Obj.BoundsRect.TopLeft;
      coBR := Obj.BoundsRect.BottomRight;
      goLT := GraphObject.BoundsRect.TopLeft;
      dW := (coBR.X - coLT.X) div 3; // ȡ�жϵķ�Χ��������������֮һ��
      dH := (coBR.Y - coLT.Y) div 3;
      drpSide := 0;
      // ���潫Snap��Obj���·������Ҹ����Ϸŵ�λ���Զ����ö���
      // �ж��Ƿ��õ���໹���Ҳ�
      if (goLT.X >= coLT.X) and (goLT.X <= coLT.X + dW) then
          drpSide := 10
      else if (goLT.X >= coBR.X - dW) and (goLT.X <= coBR.X) then
          drpSide := 20;

      // �жϷ��õ������ǵף��ֻ�����
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
      // ���潫Snap��Obj���·������Ҷ���
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
  Description: �������ݱ༭���ڣ������ֹ���������
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
