{ -----------------------------------------------------------------------------
 Unit Name: uhwSGEx.DataMapClasses
 Author:    ��ΰ
 Date:      20-����-2017
 Purpose:   ����SimpleGraph������ͼԪ����
            ����Ԫ��̳���uhwSGEx��Ԫ���Ƕ�SimpleGraph����չ��������ʾ����
            �ֲ�ͼ
 History:
----------------------------------------------------------------------------- }

unit uhwSGEx.DataMapClasses;

interface

uses
    Winapi.Windows, System.Classes, System.SysUtils, System.UITypes, System.Variants,
    Vcl.Graphics, Vcl.Forms, Vcl.Controls,
    SimpleGraph, SynGdiPlus, uhwSGEx;

type
    { ��ͼ�� }
    { DONE:��������ȹ��� }
    { todo:ȡ����Linkable������ }
    { DONE:����ͼ�κ�ֻĬ����������������ԭͼ���š����û������Ƿ�1:1��ʾͼֽ }
    TdmcMap = class(TGPRectangularNode)
    private
        FRatio    : double; // ԭʼͼƬ�����
        FLockRatio: Boolean;
        procedure SetLockRatio(b: Boolean);
        procedure SetMovable(b: Boolean);
        procedure SetSelectable(b: Boolean);
        procedure SetResizable(b: Boolean);
    protected
        procedure BackgroundChanged(Sender: TObject); override;
    public
        constructor Create(AOwner: TSimpleGraph); override;
        procedure SetBounds(aLeft, aTop, aWidth, aHeight: Integer); override;
        procedure SetBoundRectOriginal;
    published
        property LockRatio : Boolean read FLockRatio write SetLockRatio;
        property Moveable  : Boolean write SetMovable;
        property Selectable: Boolean write SetSelectable;
        property Resizeable: Boolean write SetResizable;
    end;

    { �������� }
    { todo:���ʱ����ʾ���+������������ʱ����ʾ���ݣ�������+���ݣ�HintΪ���+������ }
    { todo:�ṩ���ֲ�ͬ����ʾ��ʽ���硰���ݡ����������������ݡ��������ڣ����ݡ��ȵ� }
    { todo:��������ʾ���ݺ���ʾ������֮���л� }
    TdmcDataItem = class(TGPTextNode)
    private
        FDesignName: string;
        FDataName  : String;
        FDataUnit  : string;
        FData      : Variant;
        FDTScale   : TDateTime;
        procedure SetData(v: Variant);
        procedure SetDTScale(dt: TDateTime);
        function GetShowBorder: Boolean;
        procedure SetShowBorder(b: Boolean);
    public
        procedure ShowData(AData: String; dt: TDateTime);
        procedure ClearData;
    published
        property DesignName: string read FDesignName write FDesignName;
        property DataName  : string read FDataName write FDataName;
        property DataUnit  : string read FDataUnit write FDataUnit;
        property Data      : Variant read FData write SetData;
        property DTScale   : TDateTime read FDTScale write SetDTScale;
        property ShowBorder: Boolean read GetShowBorder write SetShowBorder;
    end;

    { 2018-06-14 ����������ǩ���󡣱�����δ������չ�����У�1)��ʾ���ݲ�һ������ʹ��TdmcDataItem
      ���󣬱�������ShowData֮���Զ��������ݱ�ǩ�����ݼ�ͷ��2)�������ܻ�û��� }
    TdmcMeterLabel = class(TGPTextNode)
    private
        FDesignName: string;
        FMeterType : string;
    published
        property DesignName: string read FDesignName write FDesignName;
        property MeterType : string read FMeterType write FMeterType;
    end;

    { 2019-06-19 ���ӱ�ʾ�������ݴ�С�ͷ���ļ�ͷ����ҪĿ����ʵ��ƽ��������ݵķ���ʹ�С }
    TdmcDataArrow = class(TGPGraphicLink)
    private
    published
    end;

implementation

constructor TdmcMap.Create(AOwner: TSimpleGraph);
begin
    inherited;
    Options := [goSelectable, goShowCaption];
    LockRatio := True;
    FRatio := 1.33;
end;

procedure TdmcMap.BackgroundChanged(Sender: TObject);
var
    rc: TRect;
begin
    inherited;
    { ���ݵ�ͼʵ�ʳߴ����ñ������С���û�����֮�������µ��� }
    rc := GetBoundsRect;
    if (Background.Width <> 0) and (Background.Height <> 0) then
    begin
        FRatio := Background.Width / Background.Height;
        rc.Width := round(rc.Height * FRatio);
        SetBoundsRect(rc);
    end
    else
        FRatio := 0;
end;

procedure TdmcMap.SetLockRatio(b: Boolean);
var
    rc: TRect;
begin
    FLockRatio := b;
    if b then
    begin
        rc := GetBoundsRect;
        SetBounds(rc.Left, rc.Top, rc.Width, rc.Height);
    end;
end;

procedure TdmcMap.SetBounds(aLeft: Integer; aTop: Integer; aWidth: Integer; aHeight: Integer);
begin
    if FLockRatio then
    begin
        aWidth := round(aHeight * Self.FRatio);
    end;
    inherited;
end;

procedure TdmcMap.SetBoundRectOriginal;
var
    rc: TRect;
begin
    if (Background.Width <> 0) and (Background.Height <> 0) then
    begin
        rc := GetBoundsRect;
        rc.Width := Background.Width;
        rc.Height := Background.Height;
        SetBoundsRect(rc);
    end;
end;

procedure TdmcMap.SetMovable(b: Boolean);
begin
    if b then
    begin
        if not(gnoMovable in Self.NodeOptions) then
            NodeOptions := NodeOptions + [gnoMovable];
    end
    else
        if gnoMovable in NodeOptions then
        NodeOptions := NodeOptions - [gnoMovable];
end;

procedure TdmcMap.SetSelectable(b: Boolean);
begin
    if b then
    begin
        if not(goSelectable in Options) then
            Options := Options + [goSelectable];
    end
    else
        if goSelectable in Options then
        Options := Options - [goSelectable];
end;

procedure TdmcMap.SetResizable(b: Boolean);
begin
    if b then
    begin
        if not(gnoResizable in Self.NodeOptions) then
            NodeOptions := NodeOptions + [gnoResizable];
    end
    else
        if gnoMovable in NodeOptions then
        NodeOptions := NodeOptions - [gnoResizable];
end;

procedure TdmcDataItem.SetData(v: Variant);
begin
    FData := v;
    { todo:���Ӷ�v�����ͼ�顢ת����顢��ʽ���� }
    // Self.Text := v;
end;

procedure TdmcDataItem.ShowData(AData: string; dt: TDateTime);
begin
    Text := AData;
    Self.FDTScale := dt;
    Hint := DesignName + ' : ' + DataName + #13#10'�۲�����: ' + FormatDateTime('yyyy-mm-dd', dt);
end;

procedure TdmcDataItem.ClearData;
begin
    DTScale := 0;
    FData := '';
    Text := DesignName + ':' + DataName;
    Hint := Text;
end;

procedure TdmcDataItem.SetDTScale(dt: TDateTime);
begin
    { todo:���ʱ�����Ƿ�Ϊ�գ�����ʱ�����ʽ��ʱӦ���� }
    FDTScale := dt;
    Self.Hint := FormatDateTime('yyyy-mm-dd', dt);
end;

function TdmcDataItem.GetShowBorder: Boolean;
begin
    if pen.Style = psClear then
        Result := False
    else
        Result := True;
end;

procedure TdmcDataItem.SetShowBorder(b: Boolean);
begin
    if b then
        pen.Style := psSolid
    else
        pen.Style := psClear;
end;

initialization

TSimpleGraph.Register(TdmcMap);
TSimpleGraph.Register(TdmcDataItem);

finalization

TSimpleGraph.Unregister(TdmcMap);
TSimpleGraph.Unregister(TdmcDataItem);

end.
