{-----------------------------------------------------------------------------
 Unit Name: ufrmDataItemsList
 Author:    黄伟
 Date:      10-五月-2022
 Purpose:   弹出窗口显示当前图纸中仪器标签和数据标签，取消勾选的隐藏
 History:
-----------------------------------------------------------------------------}

unit ufrmDataItemsList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.CheckLst,
  ufraDataLayout, SimpleGraph, uhwSGEx, uhwSGEx.DataMapClasses, Vcl.ExtCtrls;

type
  TfrmDataItemsList = class(TForm)
    lstItems: TCheckListBox;
    btnSelectAll: TSpeedButton;
    btnSelectNone: TSpeedButton;
    btnInvert: TSpeedButton;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    radgrpOperation: TRadioGroup;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnSelectNoneClick(Sender: TObject);
    procedure btnInvertClick(Sender: TObject);
  private
    { Private declarations }
    FSG: TSimpleGraph;
    procedure SetGraph(AGraph: TSimpleGraph);
  public
    { Public declarations }

    property SGraph: TSimpleGraph read FSG write SetGraph;
  end;

var
  frmDataItemsList: TfrmDataItemsList;

implementation

{$R *.dfm}


procedure TfrmDataItemsList.btnInvertClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lstItems.Count - 1 do lstItems.Checked[i] := not lstItems.Checked[i];
end;

procedure TfrmDataItemsList.btnSelectAllClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lstItems.Count - 1 do lstItems.Checked[i] := True;
end;

procedure TfrmDataItemsList.btnSelectNoneClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lstItems.Count - 1 do lstItems.Checked[i] := False;
end;

procedure TfrmDataItemsList.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  for i := 0 to lstItems.Count - 1 do
      TGraphObject(lstItems.Items.Objects[i]).Visible := lstItems.Checked[i];
end;

procedure TfrmDataItemsList.SetGraph(AGraph: TSimpleGraph);
var
  i  : Integer;
  Obj: TGraphObject;
  procedure _AddItem(AText: String);
  begin
    lstItems.AddItem(AText, Obj);
    lstItems.Checked[lstItems.Count - 1] := Obj.Visible;
  end;

begin
  FSG := AGraph;
  lstItems.Clear;

  for i := 0 to FSG.ObjectsCount - 1 do
  begin
    Obj := FSG.Objects.Items[i];
    if Obj is TdmcDataItem then
      with Obj as TdmcDataItem do
          _AddItem('数据项: ' + DesignName + '(' + DataName + ')')
    else if Obj is TGPTextNode then
      with Obj as TGPTextNode do
          _AddItem('文本标签: ' + Text)
    else if Obj is TGPGraphicLink then
      with Obj as TGPGraphicLink do
          _AddItem('连接线: ' + Text)
    else if Obj is TdmcMeterLabel then
      with Obj as TdmcMeterLabel do
          _AddItem('仪器编号: ' + Text)
    else if Obj is TdmcDeformationDirection then
      with Obj as TdmcDeformationDirection do
          _AddItem('表观变形: ' + Text);
    // lstItems.AddItem(FSG.Objects.Items[i].ClassName, FSG.Objects.Items[i]);
    // lstItems.Checked[i] := True;
  end;
end;

end.
