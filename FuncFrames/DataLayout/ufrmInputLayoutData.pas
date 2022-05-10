{-----------------------------------------------------------------------------
 Unit Name: ufrmInputLayoutData
 Author:    ��ΰ
 Date:      15-ʮһ��-2021
 Purpose:   ����Ԫ���ڿ���������޸Ĳ���ͼ�м�����ݡ�
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
    if MessageBox(0, '�������޸ģ��Ƿ��˳���', '��ȷ��', MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL or
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

  // ������д�ص����ݱ�ǩ�У�����2�е�Object�Ƿ�Ϊnil����������˵���������ݱ��޸Ĺ���
  for iRow := 1 to grdItemDatas.RowCount - 1 do
    if grdItemDatas.Objects[1, iRow] <> nil then
    begin
      if grdItemDatas.Objects[0, iRow] <> nil then
      begin
        TdmcDataItem(grdItemDatas.Objects[0, iRow]).Text := grdItemDatas.Cells[3, iRow];
        grdItemDatas.Objects[1, iRow] := nil;
      end;
    end;
  // ����޸ı�־
  FModified := False;
  lblModifiedFlag.Caption := '   ';

  // �ر�
  Close;
end;

procedure TfrmInputLayoutData.FormCreate(Sender: TObject);
begin
  // ��ʼ�����
  with grdItemDatas do
  begin
    Cells[0, 0] := '��Ʊ��';
    Cells[1, 0] := '��������';
    Cells[2, 0] := '�۲�ʱ��';
    Cells[3, 0] := '�۲�����';
  end;
end;

procedure TfrmInputLayoutData.grdItemDatasSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  FModified := True;
  lblModifiedFlag.Caption := '���޸�';
  lblModifiedFlag.Font.Color := clBlack;
  // ���õ�2�е�Object���������е����ݱ��༭�����൱��һ��Flag���
  // ����������ʱ����0�ж����Ѿ�ָ�����ݱ�ǩ����Ϊnil��
  grdItemDatas.Objects[1, ARow] := grdItemDatas.Objects[0, ARow];
end;

procedure TfrmInputLayoutData.SetDataLayout(fra: TfraDataLayout);
var
  i, j, n: Integer;
  Item   : TdmcDataItem;
begin
  FLayout := fra;
  // �Է���һ���Ƚ���������Ϊnil
  for i := 0 to grdItemDatas.RowCount - 1 do
  begin
    grdItemDatas.Objects[0, i] := nil;
    grdItemDatas.Objects[1, i] := nil;
  end;

  n := fra.sgDataLayout.ObjectsCount(TdmcDataItem);
  grdItemDatas.RowCount := n + 1;
  j := 1;

  // �г���ǰ����ͼ���������ݱ�ǩ�����ݣ�ע��Objects[0,j]ָ������ݱ�ǩ
  with fra do
    for i := 0 to sgDataLayout.ObjectsCount - 1 do
      if sgDataLayout.Objects.Items[i] is TdmcDataItem then
      begin
        Item := sgDataLayout.Objects.Items[i] as TdmcDataItem;
        grdItemDatas.Cells[0, j] := Item.DesignName;
        grdItemDatas.Cells[1, j] := Item.DataName;
        grdItemDatas.Cells[2, j] := FormatDateTime('yyyy-mm-dd', Item.DTScale);
        grdItemDatas.Cells[3, j] := Item.Text;
        // ���е�Objectָ���Ӧ��TdmcDataItem;
        grdItemDatas.Objects[0, j] := Item;
        inc(j);
      end;
  FModified := False;
end;

end.
