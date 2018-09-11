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
        FOnNeedIncrementEvent: TOnNeedDataEvent; // �������������¼�
        FOnPlayBeginning     : TNotifyEvent;
        FOnPlayFinished      : TNotifyEvent;

        FLayoutFileName: string;
        FAutoDataFormat: Boolean;     // �Ƿ���DataItem�Զ�����������ʾ��ʽ��ȱʡΪ�Զ�
        FMeterList     : TStringList; // �����б� 2018-06-05
        FSelectedMeter : string;      // 2018-06-07

        FOnMeterClick   : TOnMeterEvent; // ѡ�������������¼�������ֵΪ�����˵���ͼ�ε�����
        FPopupDataGraph : TOnMeterEvent; // ��������ͼ���¼�
        FPopupDataViewer: TOnMeterEvent; // �������ݱ��¼�

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
  Description: Ŀǰ����������ݶ�����Ե����˵����ṩ�Ĺ���Ϊ��ʾ���ݻ������
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
                piShowDataGraph.caption := '��ʾ����ͼ��';
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
  Description: ���ز���ͼ�ļ��������������б�
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
                // ���Ҫ���������������Ӧ����ΪFalse�������뱾�����Ĳ��������෴����ˡ���
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
                    if Assigned(FOnNeedIncrementEvent) then // �������ʾ��������ʾ��������ʾ����
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
    else if VarIsFloat(PDData) then
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
end;

end.
