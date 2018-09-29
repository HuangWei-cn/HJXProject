{ -----------------------------------------------------------------------------
  Unit Name: ufraMeterList
  Author:    ��ΰ
  Date:      06-����-2017
  Purpose:   ����Excel�������壬��ʾ��������б�
  History:
  ----------------------------------------------------------------------------- }
{ todo:������ɫ��ʾ�� }
{ todo:���Ӳ�ͬ�����л� }
unit ufraMeterList;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, {uHJX.Excel.Meters}
    uHJX.Intf.AppServices, uHJX.Classes.Meters,
    Vcl.StdCtrls, Vcl.Menus, System.Actions, Vcl.ActnList;

type
    // �����������¼�������Ҫ��Ʊ��һ�����������¼����Ͷ��彫����
    // Ǩ�Ƶ����ܵ��Ƚӿڵ�Ԫ��
    TOnMeterOpEvent = procedure(ADesignName: string) of object;

    TfraMeterList = class(TFrame)
        tvwMeters: TTreeView;
        edtSearch: TEdit;
        popMeterOp: TPopupMenu;
        piShowMeterDatas: TMenuItem;
        actlstMeterOp: TActionList;
        actShowMeterDatas: TAction;
        actShowTrendLine: TAction;
        actShowTrendLine1: TMenuItem;
        actOpenDataBook: TAction;
        N1: TMenuItem;
        N2: TMenuItem;
        procedure tvwMetersCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
        procedure edtSearchChange(Sender: TObject);
        procedure tvwMetersCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
            State: TCustomDrawState; var DefaultDraw: Boolean);
        procedure tvwMetersContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
        procedure actShowMeterDatasExecute(Sender: TObject);
        procedure actShowTrendLineExecute(Sender: TObject);
        procedure tvwMetersDblClick(Sender: TObject);
        procedure actOpenDataBookExecute(Sender: TObject);
    private
        { Private declarations }
        FOnShowMeterDatas      : TOnMeterOpEvent; // ��ʾ���ݱ�
        FOnShowMeterTrendLine  : TOnMeterOpEvent; // ��ʾ������
        FOnShowMeterVectorGraph: TOnMeterOpEvent; // ��ʾ����ͼ
        FOnDblClickMeter       : TOnMeterOpEvent; // ˫�������¼�
        procedure OnDBConnected(Sender:TObject);  //���ݿ����Ӻ�
    public
        { Public declarations }
        constructor Create(AOwner: TComponent);
        procedure ShowMeters;
    published
        property OnShowMeterDatas: TOnMeterOpEvent read FOnShowMeterDatas write FOnShowMeterDatas;
        property OnShowMeterTrendLine: TOnMeterOpEvent read FOnShowMeterTrendLine
            write FOnShowMeterTrendLine;
        property OnShowMeterVectorGraph: TOnMeterOpEvent read FOnShowMeterVectorGraph
            write FOnShowMeterVectorGraph;
        property OnDblClickMeter: TOnMeterOpEvent read FOnDblClickMeter write FOnDblClickMeter;
    end;

implementation

uses ShellAPI;

{$R *.dfm}


type
    TNodeType = (ntClass, ntMeter);

    TmeterNode = class(TTreeNode)
    public
        NodeType: TNodeType;
        Valid   : Boolean;
        Meter   : TMeterDefine;
        Grouped : Boolean; // �Ƿ����
    end;

constructor TfraMeterList.Create(AOwner: TComponent);
begin
    inherited;
    IAppServices.RegEventDemander('AfterConnectedEvent', OnDBConnected);
end;

procedure TfraMeterList.actOpenDataBookExecute(Sender: TObject);
var
    S: String;
begin
    if tvwMeters.Selected = nil then
        Exit;

    with tvwMeters.Selected as TmeterNode do
        if Meter <> nil then
            ShellExecute(0, PChar('open'), PChar(Meter.DataBook), nil, nil, SW_SHOWNORMAL);
end;

procedure TfraMeterList.actShowMeterDatasExecute(Sender: TObject);
begin
    if (tvwMeters.Selected = nil) or (not Assigned(FOnShowMeterDatas)) then
        Exit;
    with tvwMeters.Selected as TmeterNode do
        if Meter <> nil then
            FOnShowMeterDatas(Meter.DesignName);
end;

{ -----------------------------------------------------------------------------
  Procedure  : edtSearchChange
  Description: ���ٲ����б����е�����
  ----------------------------------------------------------------------------- }
procedure TfraMeterList.actShowTrendLineExecute(Sender: TObject);
begin
    if Assigned(FOnShowMeterTrendLine) and (tvwMeters.Selected <> nil) then
        with tvwMeters.Selected as TmeterNode do
            if Meter <> nil then
                FOnShowMeterTrendLine(Meter.DesignName);
end;

procedure TfraMeterList.edtSearchChange(Sender: TObject);
var
    i: integer;
    S: string;
begin
    if edtSearch.Text = '' then
        Exit;
    // ���ң�
    S := UpperCase(edtSearch.Text);
    for i := 0 to tvwMeters.Items.Count - 1 do
        if Pos(S, UpperCase(tvwMeters.Items[i].Text)) > 0 then
        begin
            tvwMeters.Items[i].Selected := True;
            tvwMeters.Items[i].MakeVisible;
            Exit;
        end;
    tvwMeters.Selected := nil;
end;

{ -----------------------------------------------------------------------------
  Procedure  : ShowMeters
  Description: ��ʾ���������
  ----------------------------------------------------------------------------- }
procedure TfraMeterList.ShowMeters;
var
    i                  : integer;
    AMeter             : TMeterDefine;
    nPos, nType, nMeter: TTreeNode;
    sPos, sType        : String;
begin
    tvwMeters.Items.Clear;
    ExcelMeters.SortByPosition;
    sPos := '';
    sType := '';
    nPos := nil;
    nType := nil;
    for i := 0 to ExcelMeters.Count - 1 do
    begin
        AMeter := ExcelMeters.Items[i];
        if AMeter.PrjParams.Position <> sPos then
        begin
            sPos := AMeter.PrjParams.Position;
            sType := AMeter.Params.MeterType;
            nPos := tvwMeters.Items.Add(nil, sPos);
            nType := tvwMeters.Items.AddChild(nPos, sType);
            TmeterNode(nPos).NodeType := ntClass;
            TmeterNode(nType).NodeType := ntClass;
        end;
        if AMeter.Params.MeterType <> sType then
        begin
            sType := AMeter.Params.MeterType;
            nType := tvwMeters.Items.AddChild(nPos, sType);
            TmeterNode(nType).NodeType := ntClass;
        end;
        nMeter := tvwMeters.Items.AddChild(nType, AMeter.DesignName);
        if nMeter is TmeterNode then
        begin
            TmeterNode(nMeter).Meter := AMeter;
            if AMeter.PrjParams.GroupID <> '' then
            begin
                TmeterNode(nMeter).Grouped := True;
                nMeter.Text := nMeter.Text + '(' + AMeter.PrjParams.GroupID + ')';
            end;
            TmeterNode(nMeter).NodeType := ntMeter;
            if AMeter.DataBook = '' then
                TmeterNode(nMeter).Valid := False
            else
                TmeterNode(nMeter).Valid := True;
        end;

    end;
end;

procedure TfraMeterList.tvwMetersContextPopup(Sender: TObject; MousePos: TPoint;
    var Handled: Boolean);
begin
    if tvwMeters.Selected = nil then
    begin
        Handled := False;
        Exit;
    end;

    with tvwMeters.Selected as TmeterNode do
        if (NodeType = ntMeter) then
            piShowMeterDatas.Enabled := True
        else
            piShowMeterDatas.Enabled := False;
    tvwMeters.PopupMenu.AutoPopup := True;
end;

procedure TfraMeterList.tvwMetersCreateNodeClass(Sender: TCustomTreeView;
    var NodeClass: TTreeNodeClass);
begin
    NodeClass := TmeterNode;
end;

procedure TfraMeterList.tvwMetersCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
    State: TCustomDrawState; var DefaultDraw: Boolean);
begin
    if not(Node is TmeterNode) then
        Exit;
    with Node as TmeterNode do
    begin
        if NodeType = ntClass then
        begin
            Sender.Canvas.Font.Color := clBlack;
            Sender.Canvas.Font.Style := [];
        end
        else if Valid then
        begin
            if Grouped then
                Sender.Canvas.Font.Color := clGreen
            else
                Sender.Canvas.Font.Color := clBlue;
            Sender.Canvas.Font.Style := [];
        end
        else
        begin
            Sender.Canvas.Font.Color := clGray;
            Sender.Canvas.Font.Style := [fsStrikeOut, fsItalic];
        end;
    end;
end;

procedure TfraMeterList.tvwMetersDblClick(Sender: TObject);
begin
    if tvwMeters.Selected = nil then
        Exit;

    with tvwMeters.Selected as TmeterNode do
        if (NodeType = ntMeter) then
            if Assigned(FOnDblClickMeter) then
                FOnDblClickMeter(Meter.DesignName);
end;

procedure TfraMeterList.OnDBConnected(Sender: TObject);
begin
    ShowMeters;
end;

end.
