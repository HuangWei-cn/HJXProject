{ -----------------------------------------------------------------------------
 Unit Name: ufraMeterSelector
 Author:    黄伟
 Date:      21-六月-2018
 Purpose:   仪器选择器，返回一个TStrings，或一个String数组
 History:
----------------------------------------------------------------------------- }
unit ufraMeterSelector;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
    uHJX.Intf.AppServices, uHJX.Classes.Meters,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Winapi.CommCtrl;

type
    TfraMeterSelector = class(TFrame)
        tvwMeters: TTreeView;
        procedure tvwMetersCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
        procedure tvwMetersClick(Sender: TObject);
        procedure tvwMetersCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
            State: TCustomDrawState; var DefaultDraw: Boolean);
    private
        { Private declarations }
        function IsChecked(Node: TTreeNode): Boolean;
        procedure SetChecked(Node: TTreeNode; Checked: Boolean);
        procedure tvToggleCheckbox(TreeView: TTreeView; Node: TTreeNode; IsClick: Boolean = False);

    public
        { Public declarations }
        constructor Create(AOwner: TComponent); override;
        procedure SetCheckBox;
        procedure AppendMeterList;
        procedure SetSelectedList(AStrs: TStrings);
        procedure GetSelectedMeters(SelectedMeters: TStrings);
    end;

// procedure PopupMeterSelector(AMeters: TStrings);

implementation

{$R *.dfm}


type
    TNodeType = (ntClass, ntMeter);

    // 注意：这里的TmeterNode与ufraMeterList单元中定义的TmeterNode不同
    TmeterNode = class(TTreeNode)
    public
        NodeType : TNodeType;
        Valid    : Boolean;
        MeterName: string;
        // Grouped : Boolean; // 是否成组
    end;

const
    TVIS_CHECKED = $2000;

constructor TfraMeterSelector.Create(AOwner: TComponent);
begin
    inherited;
end;

procedure TfraMeterSelector.SetCheckBox;
begin
    // 令Treeview增加复选框
    SetWindowLong(tvwMeters.Handle, GWL_STYLE, GetWindowLong(tvwMeters.Handle, GWL_STYLE) or
        $00000100);
end;

procedure TfraMeterSelector.tvwMetersClick(Sender: TObject);
var
    P   : TPoint;
    Node: TTreeNode;
begin
    GetCursorPos(P);
    P := tvwMeters.ScreenToClient(P);
    if (htOnStateIcon in tvwMeters.GetHitTestInfoAt(P.X, P.Y)) then
    begin
        Node := tvwMeters.GetNodeAt(P.X, P.Y);
        tvToggleCheckbox(tvwMeters, Node, True);
    end;
end;

procedure TfraMeterSelector.tvwMetersCreateNodeClass(Sender: TCustomTreeView;
    var NodeClass: TTreeNodeClass);
begin
    NodeClass := TmeterNode;
end;

procedure TfraMeterSelector.tvwMetersCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
    State: TCustomDrawState; var DefaultDraw: Boolean);
var
    i: integer;
begin
    // 如果子节点有选择的，则字体为粗体，否则正常
    if Node.HasChildren then
    begin
        Sender.Canvas.Font.Style := [];
        for i := 0 to Node.count - 1 do
            if IsChecked(Node.Item[i]) then
            begin
                Sender.Canvas.Font.Color := clBlue;
                Sender.Canvas.Font.Style := [fsBold];
                Break;
            end;
    end
    else
        DefaultDraw := True;
end;

function TfraMeterSelector.IsChecked(Node: TTreeNode): Boolean;
var
    TvItem: TTVItem;
begin
    TvItem.Mask := TVIF_STATE;
    TvItem.hItem := Node.ItemId;
    TreeView_GetItem(Node.TreeView.Handle, TvItem);
    Result := (TvItem.State and TVIS_CHECKED) = TVIS_CHECKED;
end;

procedure TfraMeterSelector.SetChecked(Node: TTreeNode; Checked: Boolean);
var
    TvItem: TTVItem;
begin
    FillChar(TvItem, SizeOf(TvItem), 0);
    with TvItem do
    begin
        hItem := Node.ItemId;
        Mask := TVIF_STATE;
        StateMask := TVIS_STATEIMAGEMASK;
        if Checked then
            TvItem.State := TVIS_CHECKED
        else
            TvItem.State := TVIS_CHECKED shr 1;
        TreeView_SetItem(Node.TreeView.Handle, TvItem);
    end;
end;

procedure TfraMeterSelector.tvToggleCheckbox(TreeView: TTreeView; Node: TTreeNode;
    IsClick: Boolean = False);
var
    CurNode, ParentNode  : TTreeNode;
    GrandSonNode, sonNode: TTreeNode;
    flg1                 : Boolean;
begin
    CurNode := Node;
    with TreeView do
    begin
        if IsChecked(CurNode) then //
        begin
            sonNode := CurNode.GetFirstChild; // 遍历子树,选中 则子节点 全部 为选中；
            while sonNode <> nil do
            begin
                SetChecked(sonNode, True);
                tvToggleCheckbox(TreeView, sonNode, True);
                sonNode := sonNode.GetNextSibling;
            end;

            ParentNode := CurNode.Parent; // 父；
            if ParentNode <> nil then
            begin
                if not IsChecked(ParentNode) then
                begin
                    GrandSonNode := ParentNode.GetFirstChild; // 遍历子树；
                    flg1 := False;
                    while GrandSonNode <> nil do
                    begin
                        if (not IsChecked(GrandSonNode)) then // true,有未选中
                            flg1 := True;
                        if flg1 then // 已有、退出loop;
                            GrandSonNode := nil
                        else
                            GrandSonNode := GrandSonNode.GetNextSibling;
                    end;
                    SetChecked(ParentNode, not flg1);
                    tvToggleCheckbox(TreeView, ParentNode, False);
                end;
            end; // end parentNode 不等于空
        end
        else if not IsChecked(CurNode) then
        begin
            ParentNode := CurNode.Parent; // 父；
            if ParentNode <> nil then
            begin
                if IsChecked(ParentNode) then
                begin
                    SetChecked(ParentNode, False);
                    tvToggleCheckbox(TreeView, ParentNode);
                end;
            end; // end parentnode

            if (IsClick) then
            begin
                sonNode := CurNode.GetFirstChild; // 遍历子树,未选中 则子节点 全部 为未选中；
                while sonNode <> nil do
                begin
                    SetChecked(sonNode, False);
                    tvToggleCheckbox(TreeView, sonNode, True);
                    sonNode := sonNode.GetNextSibling;
                end;
            end;

        end;
    end;
end;

procedure TfraMeterSelector.AppendMeterList;
var
    i                  : integer;
    AMeter             : TMeterDefine;
    nPos, nType, nMeter: TTreeNode;
    sPos, sType        : String;
begin
    tvwMeters.Items.Clear;
    if ExcelMeters = nil then
        Exit;
    if ExcelMeters.count = 0 then
        Exit;
    ExcelMeters.SortByPosition;
    sPos := '';
    sType := '';
    nPos := nil;
    nType := nil;
    for i := 0 to ExcelMeters.count - 1 do
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
            TmeterNode(nMeter).MeterName := AMeter.DesignName;
            TmeterNode(nMeter).NodeType := ntMeter;
            if AMeter.DataBook = '' then
                TmeterNode(nMeter).Valid := False
            else
                TmeterNode(nMeter).Valid := True;
        end;
    end;
end;

procedure TfraMeterSelector.SetSelectedList(AStrs: TStrings);
var
    i: integer;
begin
    for i := 0 to tvwMeters.Items.count - 1 do
        if AStrs.IndexOf(tvwMeters.Items[i].Text) <> -1 then
            SetChecked(tvwMeters.Items[i], True);
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetSelectedMeters
  Description:
----------------------------------------------------------------------------- }
procedure TfraMeterSelector.GetSelectedMeters(SelectedMeters: TStrings);
var
    i : integer;
    nd: TmeterNode;
begin
    SelectedMeters.Clear;
    for i := 0 to tvwMeters.Items.count - 1 do
    begin
        nd := tvwMeters.Items[i] as TmeterNode;
        if nd.NodeType = ntMeter then
            if IsChecked(nd) then
                SelectedMeters.Add(nd.MeterName);
    end;
end;

// procedure PopupMeterSelector(AMeters: TStrings);
// var
// frm : TForm;
// fra : TfraMeterSelector;
// strs: TStrings;
// begin
// frm := TForm.Create(Application.MainForm);
// frm.Width := 300;
// frm.Height := 400;
// fra := TfraMeterSelector.Create(frm);
// fra.Parent := frm;
// fra.Align := alClient;
// fra.SetCheckBox;     // 必须在fra创建完毕后才能设置CheckBox，否则不显示
// fra.AppendMeterList; // 必须在设置CheckBox之后再添加仪器表
//
// strs := TStringList.Create;
// try
// frm.ShowModal;
// fra.GetSelectedMeters(strs);
// ShowMessage(strs.Text);
// finally
// frm.Release;
// strs.Free;
// end;
// end;

end.
