{-----------------------------------------------------------------------------
 Unit Name: ufrmInputLayoutData
 Author:    黄伟
 Date:      15-十一月-2021
 Purpose:   本单元用于快速填入或修改布置图中监测数据。
 History:
-----------------------------------------------------------------------------}

unit ufrmInputLayoutData;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  ufraDataLayout, uhwSGEx.DataMapClasses;

type
  TfrmInputLayoutData = class(TForm)
    grdItemDatas: TStringGrid;
    btnOK: TButton;
    btnCancel: TButton;
    lblModifiedFlag: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure grdItemDatasSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
    FModified: Boolean;
    FLayout  : TfraDataLayout;
    procedure SetDataLayout(fra: TfraDataLayout);
  public
    { Public declarations }
    property Layout: TfraDataLayout read FLayout write SetDataLayout;
  end;

var
  frmInputLayoutData: TfrmInputLayoutData;

implementation

{$R *.dfm}


procedure TfrmInputLayoutData.btnCancelClick(Sender: TObject);
begin
  if FModified then
  begin
    if MessageBox(0, '内容已修改，是否退出？', '请确认', MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL or
      MB_DEFBUTTON2) = IDYES then Close;
  end
  else
      Close;
end;

procedure TfrmInputLayoutData.btnOKClick(Sender: TObject);
var
  iRow: Integer;
begin
  if not FModified then Close;

  // 将数据写回到数据标签中，检查第2列的Object是否为nil，若不是则说明该列数据被修改过。
  for iRow := 1 to grdItemDatas.RowCount - 1 do
    if grdItemDatas.Objects[1, iRow] <> nil then
    begin
      if grdItemDatas.Objects[0, iRow] <> nil then
      begin
        TdmcDataItem(grdItemDatas.Objects[0, iRow]).Text := grdItemDatas.Cells[3, iRow];
        grdItemDatas.Objects[1, iRow] := nil;
      end;
    end;
  // 清除修改标志
  FModified := False;
  lblModifiedFlag.Caption := '   ';

  // 关闭
  Close;
end;

procedure TfrmInputLayoutData.FormCreate(Sender: TObject);
begin
  // 初始化表格
  with grdItemDatas do
  begin
    Cells[0, 0] := '设计编号';
    Cells[1, 0] := '数据名称';
    Cells[2, 0] := '观测时间';
    Cells[3, 0] := '观测数据';
  end;
end;

procedure TfrmInputLayoutData.grdItemDatasSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  FModified := True;
  lblModifiedFlag.Caption := '已修改';
  lblModifiedFlag.Font.Color := clBlack;
  // 设置第2列的Object，表明该列的数据被编辑过，相当于一个Flag标记
  // 在填入数据时，第0列对象已经指向数据标签，不为nil。
  grdItemDatas.Objects[1, ARow] := grdItemDatas.Objects[0, ARow];
end;

procedure TfrmInputLayoutData.SetDataLayout(fra: TfraDataLayout);
var
  i, j, n: Integer;
  Item   : TdmcDataItem;
begin
  FLayout := fra;
  // 以防万一，先将对象设置为nil
  for i := 0 to grdItemDatas.RowCount - 1 do
  begin
    grdItemDatas.Objects[0, i] := nil;
    grdItemDatas.Objects[1, i] := nil;
  end;

  n := fra.sgDataLayout.ObjectsCount(TdmcDataItem);
  grdItemDatas.RowCount := n + 1;
  j := 1;

  // 列出当前布置图中所有数据标签及内容，注意Objects[0,j]指向该数据标签
  with fra do
    for i := 0 to sgDataLayout.ObjectsCount - 1 do
      if sgDataLayout.Objects.Items[i] is TdmcDataItem then
      begin
        Item := sgDataLayout.Objects.Items[i] as TdmcDataItem;
        grdItemDatas.Cells[0, j] := Item.DesignName;
        grdItemDatas.Cells[1, j] := Item.DataName;
        grdItemDatas.Cells[2, j] := FormatDateTime('yyyy-mm-dd', Item.DTScale);
        grdItemDatas.Cells[3, j] := Item.Text;
        // 该行的Object指向对应的TdmcDataItem;
        grdItemDatas.Objects[0, j] := Item;
        inc(j);
      end;
  FModified := False;
end;

end.
