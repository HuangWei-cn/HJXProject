{ -----------------------------------------------------------------------------
 Unit Name: ufrmFindNewSheets
 Author:    ��ΰ
 Date:      14-ʮ��-2019
 Purpose:   ����Ԫ���ڲ��������������������֪�Ĺ������С����޷���δ֪����
            �������в��ҡ�
 History:
----------------------------------------------------------------------------- }
{ todo: ���ӽ����ҵ��ļ��������������ӵ������ļ��б��еĹ��� }
unit ufrmFindNewSheets;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, uHJX.Classes.Meters,
  Vcl.ComCtrls, System.Actions, Vcl.ActnList, Vcl.Menus;

type
  TfrmFindNewSheets = class(TForm)
    Panel1: TPanel;
    btnFindNew: TButton;
    lvwNewSheets: TListView;
    popOp: TPopupMenu;
    piAppendNewSheet: TMenuItem;
    ActionList1: TActionList;
    actAppendNewSheet: TAction;
    procedure btnFindNewClick(Sender: TObject);
    procedure actAppendNewSheetExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure FindNewSheets;
    procedure AppendNewSheet;
  public
    { Public declarations }
  end;

var
  frmFindNewSheets: TfrmFindNewSheets;

implementation

uses nExcel, uHJX.Excel.IO, ufrmSetNewSheetParams, uHJX.Excel.InitParams;
{$R *.dfm}


procedure TfrmFindNewSheets.actAppendNewSheetExecute(Sender: TObject);
var
  lvwItem: TListItem;
begin
  if lvwNewSheets.Items.Count = 0 then Exit;
  if lvwNewSheets.Selected = nil then Exit;
  lvwItem := lvwNewSheets.Selected;
  frmSetNewSheetParam.ShowSetForm(lvwItem.Caption, lvwItem.SubItems[0]);
  if frmSetNewSheetParam.ModalResult = mrCancel then Exit;

  // ����û��Ƿ��������������ͺͰ�װ��λ����û�������������û�û�����
  if (frmSetNewSheetParam.MeterType = '') or (frmSetNewSheetParam.Position = '') then
  begin
    ShowMessage('û�������������ͻ�װ��λ����Ϣ����������������ӵ��ļ��б���');
    Exit;
  end;

  // ��ӵ������ļ��б���
  AppendNewSheet;
end;

procedure TfrmFindNewSheets.btnFindNewClick(Sender: TObject);
begin
  FindNewSheets;
end;

procedure TfrmFindNewSheets.FindNewSheets;
var
  i, j: Integer;
  wbks: TStrings;
  nBK : IXLSWorkBook;
  nit : TListItem;
begin
  lvwNewSheets.Clear;
  wbks := TStringList.Create;
  try
    // ���Ƚ�����������һ�飬�ҳ����й����������Ӧ�Ĺ�����
    for i := 0 to ExcelMeters.Count - 1 do
    begin
      if ExcelMeters.Items[i].DataBook = '' then Continue;
      if ExcelMeters.Items[i].DataSheet = '' then Continue;

      j := wbks.IndexOf(ExcelMeters.Items[i].DataBook);
      if j = -1 then // ���������û��ӣ�����ӹ������������Ĺ�����
      begin
        wbks.Add(ExcelMeters.Items[i].DataBook);
        wbks.Objects[wbks.Count - 1] := TStringList.Create;
        TStrings(wbks.Objects[wbks.Count - 1]).Add(ExcelMeters.Items[i].DataSheet);
      end
      else // ����й���������鹤�����Ƿ���ڣ������������֮
      begin
        if (wbks.Objects[j] as TStrings).IndexOf(ExcelMeters.Items[i].DataSheet) = -1 then
          (wbks.Objects[j] as TStrings).Add(ExcelMeters.Items[i].DataSheet);
      end;
    end;

    // ��һ�򿪹�������ö�����й������˶��Ƿ�����֪���У��������г�
    for i := 0 to wbks.Count - 1 do
    begin
      if Trim(wbks[i]) = '' then Continue;

      ExcelIO.OpenWorkbook(nBK, wbks.Strings[i]);
      for j := 1 to nBK.WorkSheets.Count do
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

  finally
    for i := 0 to wbks.Count - 1 do wbks.Objects[i].Free;
    wbks.Free;
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
/// ���û�ѡ��Ĺ�������ӵ����������ļ��б��С�
/// Ŀǰ��ʱ�ڱ�������ֱ�����б���������ӣ�������ķ�����ͨ��һ��ר�õ��޸Ĳ�����ĵ�Ԫ�����Щ
/// ������
/// </summary>
procedure TfrmFindNewSheets.AppendNewSheet;
var
  Ret     : Integer;
  i, n    : Integer;
  S, sName: string;
begin
  with frmSetNewSheetParam do
  begin
    // �����������˵����˵����Ǹ�����
    (*
    Ret := uHJX.Excel.InitParams.AppendDataSheet(DesignName, sheetname, bookname, MeterType,
      Position);
    if Ret = 1 then
    begin
      ShowMessage('����ɹ����ѽ�' + MeterType + DesignName + '�Ĺ�������ӵ������ļ��б����ˡ�');
      lvwNewSheets.Selected.Delete;
    end;
 *)
    { ����Ĵ��뽫ѡ�е�������������ӽ�ȥ }
    n := 0;
    S := '';
    for i := Self.lvwNewSheets.Items.Count - 1 downto 0 do
      if lvwNewSheets.Items[i].Checked then
      begin
        sName := lvwNewSheets.Items[i].Caption;
        Ret := uHJX.Excel.InitParams.AppendDataSheet(sName, SheetName, BookName, MeterType,
          Position);
        if Ret = 1 then
        begin
          inc(n);
          lvwNewSheets.Items.Delete(i);
          S := S + '�ѽ�' + sName + '��ӵ������ļ��б�' + #13#10;
        end
        else
            S := S + 'δ�ܽ�' + sName + '��ӵ������ļ��б�' + #13#10;
      end;
    if n > 0 then
        ShowMessage(S)
    else
        ShowMessage('δ�ܽ�������ӽ������ļ��б�����ԭ��');
  end;
end;

end.
