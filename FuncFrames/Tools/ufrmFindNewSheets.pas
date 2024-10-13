{ -----------------------------------------------------------------------------
 Unit Name: ufrmFindNewSheets
 Author:    黄伟
 Date:      14-十月-2019
 Purpose:   本单元用于查找新增仪器计算表，从已知的工作簿中。但无法从未知的新
            工作簿中查找。
 History:
            2022-05-16 不显示隐藏的工作表以及Sheet1、Sheet2之类的表
----------------------------------------------------------------------------- }
{ todo: 增加将查找到的监测仪器工作表添加到仪器文件列表中的功能 }
unit ufrmFindNewSheets;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, uHJX.Classes.Meters,
  Vcl.ComCtrls, System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.WinXCtrls;

type
  TfrmFindNewSheets = class(TForm)
    Panel1: TPanel;
    btnFindNew: TButton;
    lvwNewSheets: TListView;
    popOp: TPopupMenu;
    piAppendNewSheet: TMenuItem;
    ActionList1: TActionList;
    actAppendNewSheet: TAction;
    ActivityIndicator1: TActivityIndicator;
    procedure btnFindNewClick(Sender: TObject);
    procedure actAppendNewSheetExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure FindNewSheets;
    procedure AppendNewSheet;
    procedure ShowSetSheetForm;
  public
    { Public declarations }
  end;

implementation

uses nExcel, uHJX.Excel.IO, ufrmSetNewSheetParams, uHJX.Excel.InitParams, ufrmSetSelectedSheets;
{$R *.dfm}


procedure TfrmFindNewSheets.actAppendNewSheetExecute(Sender: TObject);
var
  lvwItem: TListItem;
begin
  ShowSetSheetForm;
  (*
  if lvwNewSheets.Items.Count = 0 then Exit;
  if lvwNewSheets.Selected = nil then Exit;
  lvwItem := lvwNewSheets.Selected;

  frmSetNewSheetParam.ShowSetForm(lvwItem.Caption, lvwItem.SubItems[0]);
  if frmSetNewSheetParam.ModalResult = mrCancel then Exit;

  // 检查用户是否输入了仪器类型和安装部位，若没有输入则提醒用户没法添加
  if (frmSetNewSheetParam.MeterType = '') or (frmSetNewSheetParam.Position = '') then
  begin
    ShowMessage('没有输入仪器类型或安装部位，信息不完整，不建议添加到文件列表中');
    Exit;
  end;

  // 添加到仪器文件列表中
  AppendNewSheet;
 *)
end;

procedure TfrmFindNewSheets.btnFindNewClick(Sender: TObject);
begin
  FindNewSheets;
end;

{ -----------------------------------------------------------------------------
  Procedure  : FindNewSheets
  Description: 从现有监测仪器所在的工作簿中查找新工作表，通常一个工作表对应1~n
  个监测仪器。本方法不会去查找新工作簿。
  工作方式：1、从现有有效监测仪器中得到所有在用的工作簿和工作表；
            2、逐一打开这些工作簿，核对是否存在未被登记的工作表，若有则列出
----------------------------------------------------------------------------- }
procedure TfrmFindNewSheets.FindNewSheets;
var
  i, j: Integer;
  wbks: TStrings;
  nBK : IXLSWorkBook;
  nit : TListItem;
begin
  lvwNewSheets.Clear;
  wbks := TStringList.Create;
  Self.ActivityIndicator1.Visible := True;
  activityIndicator1.Animate := True;
  screen.Cursor := crHourGlass;
  try
    // 首先将现有仪器过一遍，找出现有工作簿及其对应的工作表：
    for i := 0 to ExcelMeters.Count - 1 do
    begin
      if ExcelMeters.Items[i].DataBook = '' then Continue;
      if ExcelMeters.Items[i].DataSheet = '' then Continue;

      j := wbks.IndexOf(ExcelMeters.Items[i].DataBook);
      if j = -1 then // 如果工作簿没添加，则添加工作簿及仪器的工作表
      begin
        wbks.Add(ExcelMeters.Items[i].DataBook);
        wbks.Objects[wbks.Count - 1] := TStringList.Create;
        TStrings(wbks.Objects[wbks.Count - 1]).Add(ExcelMeters.Items[i].DataSheet);
      end
      else // 如果有工作簿，检查工作表是否存在，不存在则添加之
      begin
        if (wbks.Objects[j] as TStrings).IndexOf(ExcelMeters.Items[i].DataSheet) = -1 then
          (wbks.Objects[j] as TStrings).Add(ExcelMeters.Items[i].DataSheet);
      end;
    end;

    // 逐一打开工作簿，枚举所有工作表，核对是否在已知表中，不在则列出
    for i := 0 to wbks.Count - 1 do
    begin
      if Trim(wbks[i]) = '' then Continue;

      ExcelIO.OpenWorkbook(nBK, wbks.Strings[i]);
      for j := 1 to nBK.WorkSheets.Count do
      begin
        // 2022-05-16 不考虑隐藏工作表
        // 注：nExcel中，WorkSheet的Visible属性不是Boolean而是Varaint，其值的含义如下
        // xlSheetVisible     = $0000000;
        // xlSheetHidden      = $0000001;
        // xlSheetVeryHidden  = $0000002;
        // 因此，隐藏的工作表Visible属性不为0。
        if nBK.WorkSheets[j].Visible <> 0 then Continue; // 2022-05-16

        if (wbks.Objects[i] as TStrings).IndexOf(nBK.WorkSheets[j].Name) = -1 then
        begin
          // mmoResult.Lines.Add(wbks.Strings[i] + ':' + nBK.WorkSheets[j].Name);
          nit := lvwNewSheets.Items.Add;
          nit.Caption := nBK.WorkSheets[j].Name;
          nit.SubItems.Add(wbks.Strings[i]);
          Application.ProcessMessages;
          // lvwNewSheets.Invalidate;
        end;
      end;
    end;
    ShowMessage('新工作表查找完毕');

  finally
    for i := 0 to wbks.Count - 1 do wbks.Objects[i].Free;
    wbks.Free;
    Self.ActivityIndicator1.Visible := False;
    activityIndicator1.Animate := False;
    screen.Cursor := crDefault;
  end;
end;

procedure TfrmFindNewSheets.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    frmSetNewSheetParam.Release;
    frmSetNewSheetParam := nil;
  finally
  end;
end;

procedure TfrmFindNewSheets.FormCreate(Sender: TObject);
begin
  frmSetNewSheetParam := TfrmSetNewSheetParam.Create(Self);
end;

/// <summary>
/// 将用户选择的工作表添加到仪器数据文件列表中。
/// 目前暂时在本方法中直接向列表工作簿中添加，更理想的方法是通过一个专用的修改参数表的单元完成这些
/// 工作。
/// </summary>
procedure TfrmFindNewSheets.AppendNewSheet;
var
  Ret     : Integer;
  i, n    : Integer;
  S, sName: string;
begin
  with frmSetNewSheetParam do
  begin
    // 这里仅仅添加了弹出菜单的那个仪器
    (*
    Ret := uHJX.Excel.InitParams.AppendDataSheet(DesignName, sheetname, bookname, MeterType,
      Position);
    if Ret = 1 then
    begin
      ShowMessage('保存成功，已将' + MeterType + DesignName + '的工作表添加到数据文件列表中了。');
      lvwNewSheets.Selected.Delete;
    end;
 *)
    { 下面的代码将选中的所有仪器都添加进去 }
    n := 0;
    S := '';
    for i := Self.lvwNewSheets.Items.Count - 1 downto 0 do
      if lvwNewSheets.Items[i].Checked then
      begin
        sName := lvwNewSheets.Items[i].Caption;
        Ret := uHJX.Excel.InitParams.AppendDataSheet(sName, { SheetName } sName,
          { BookName } lvwNewSheets.Items[i].SubItems[0], MeterType, Position);
        if Ret = 1 then
        begin
          inc(n);
          lvwNewSheets.Items.Delete(i);
          S := S + '已将' + sName + '添加到数据文件列表' + #13#10;
        end
        else
            S := S + '未能将' + sName + '添加到数据文件列表' + #13#10;
      end;
    if n > 0 then
        ShowMessage(S)
    else
        ShowMessage('未能将仪器添加进数据文件列表，请检查原因。');
  end;
end;

procedure TfrmFindNewSheets.ShowSetSheetForm;
var
  i, n: Integer;
  frm : TfrmSetSelectedSheets;
begin
  frm := TfrmSetSelectedSheets.Create(Self);
  frm.FindForm := Self;
  n := 0;
  for i := 0 to lvwNewSheets.Items.Count - 1 do
    if lvwNewSheets.Items[i].Checked then
    begin
      frm.AddSheet(lvwNewSheets.Items[i].Caption, lvwNewSheets.Items[i].SubItems[0]);
      inc(n);
    end;
  if n > 0 then frm.ShowModal;
  frm.Release;
end;

end.
