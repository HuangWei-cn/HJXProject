{ -----------------------------------------------------------------------------
 Unit Name: ufrmSetSelectedSheets
 Author:    黄伟
 Date:      16-五月-2022
 Purpose:   计划将本单元完善成为集设置新工作表、对应监测仪器、同时可以保存等
            功能为一身的较为完善的功能界面。
            但是……现在没有弄完，还有一些工作量。
 History:
----------------------------------------------------------------------------- }

unit ufrmSetSelectedSheets;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, aceListView, Vcl.ComCtrls, sListView, Vcl.StdCtrls, sButton,
  sCheckBox, ufrmFindNewSheets {用于删除保存后的项目};

type
  TfrmSetSelectedSheets = class(TForm)
    lvwSheets: TacListView;
    btnCancel: TsButton;
    btnAppendMeter: TsButton;
    sCheckBox1: TsCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnAppendMeterClick(Sender: TObject);
  private
    { Private declarations }
    FFindForm: TfrmFindNewSheets;
    // 保存合适的项目
    procedure SaveMeterSheetToList;
    // 从调用界面frmFindNewSheets中删除已保存的项目
    procedure DeleteItemFromFinder(ASheetName, ABookName: String);
  public
    { Public declarations }
    procedure AddSheet(ASheetName, ABookName: String);
    property FindForm: TfrmFindNewSheets read FFindForm write FFindForm;
  end;

var
  frmSetSelectedSheets: TfrmSetSelectedSheets;

implementation

uses
  uHJX.Classes.Meters, uHJX.Excel.InitParams;
{$R *.dfm}


procedure TfrmSetSelectedSheets.FormCreate(Sender: TObject);
begin
  lvwSheets.Items.Clear;
  // FOwnerForm := Sender as TfrmFindNewSheets;
end;

procedure TfrmSetSelectedSheets.btnAppendMeterClick(Sender: TObject);
begin
  SaveMeterSheetToList;
end;

{ -----------------------------------------------------------------------------
  Procedure  : AddSheet
  Description: 添加工作表及工作簿
  添加的同时，根据工作表名查找是否存在与该表同名的监测仪器，若有则显示该仪器
  的类型和安装部位；若未查到则显示未知仪器
----------------------------------------------------------------------------- }
procedure TfrmSetSelectedSheets.AddSheet(ASheetName: string; ABookName: string);
var
  i    : Integer;
  sName: String;
  Meter: TMeterDefine;
  Li   : TacListItem;
begin
  sName := Trim(ASheetName);
  if (sName = '') or (Trim(ABookName) = '') then Exit;
  /// 根据是sName查找是否存在同名监测仪器
  Meter := ExcelMeters.Meter[sName];
  Li := lvwSheets.Items.Add('');
  Li.GroupIndex := 0;
  if Meter = nil then
  begin
    Li.Caption := '未知';
    Li.SubItems.Text := '未知'#13#10'未知'#13#10 + ASheetName + #13#10 + ABookName;
  end
  else
  begin
    Li.Caption := Meter.DesignName;
    Li.SubItems.Add(Meter.Params.MeterType);
    Li.SubItems.Add(Meter.PrjParams.Position);
    Li.SubItems.Add(ASheetName);
    Li.SubItems.Add(ABookName);
  end;
end;

procedure TfrmSetSelectedSheets.SaveMeterSheetToList;
var
  i : Integer;
  Li: TacListItem;
begin
  for i := 0 to lvwSheets.Items.Count - 1 do
  begin
    Li := lvwSheets.Items[i];
    // 如果包含有未知项目，则跳过
    if (Li.Caption = '未知') or (Pos('未知', Li.SubItems.Text) > 0) then Continue;
    // 保存
    uHJX.Excel.InitParams.AppendDataSheet(Li.Caption, Li.SubItems[2], Li.SubItems[3],
      Li.SubItems[0], Li.SubItems[1]);
    // 从调用界面中删除保存后的项目
    DeleteItemFromFinder(Li.SubItems[2], Li.SubItems[3]);
  end;
  ShowMessage('保存完毕');
  btnAppendMeter.Enabled := False;
  btnCancel.Caption := '退出';
end;

procedure TfrmSetSelectedSheets.DeleteItemFromFinder(ASheetName: string; ABookName: string);
var
  i : Integer;
  Li: TListItem;
begin
  if FindForm = nil then Exit;
  for i := 0 to FindForm.lvwNewSheets.Items.Count - 1 do
  begin
    Li := FindForm.lvwNewSheets.Items[i];
    // 能到本界面的Item都是被勾选的，未被勾选的跳过
    if not Li.Checked then Continue;
    if (Li.Caption = ASheetName) and (Li.SubItems[0] = ABookName) then
    begin
        FindForm.lvwNewSheets.Items.Delete(i);
        Exit;
    end;
  end;
end;

end.
