{ -----------------------------------------------------------------------------
 Unit Name: ufrmSetSelectedSheets
 Author:    ��ΰ
 Date:      16-����-2022
 Purpose:   �ƻ�������Ԫ���Ƴ�Ϊ�������¹�������Ӧ���������ͬʱ���Ա����
            ����Ϊһ��Ľ�Ϊ���ƵĹ��ܽ��档
            ���ǡ�������û��Ū�꣬����һЩ��������
 History:
----------------------------------------------------------------------------- }

unit ufrmSetSelectedSheets;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, aceListView, Vcl.ComCtrls, sListView, Vcl.StdCtrls, sButton,
  sCheckBox, ufrmFindNewSheets {����ɾ����������Ŀ};

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
    // ������ʵ���Ŀ
    procedure SaveMeterSheetToList;
    // �ӵ��ý���frmFindNewSheets��ɾ���ѱ������Ŀ
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
  Description: ��ӹ�����������
  ��ӵ�ͬʱ�����ݹ������������Ƿ������ñ�ͬ���ļ����������������ʾ������
  �����ͺͰ�װ��λ����δ�鵽����ʾδ֪����
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
  /// ������sName�����Ƿ����ͬ���������
  Meter := ExcelMeters.Meter[sName];
  Li := lvwSheets.Items.Add('');
  Li.GroupIndex := 0;
  if Meter = nil then
  begin
    Li.Caption := 'δ֪';
    Li.SubItems.Text := 'δ֪'#13#10'δ֪'#13#10 + ASheetName + #13#10 + ABookName;
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
    // ���������δ֪��Ŀ��������
    if (Li.Caption = 'δ֪') or (Pos('δ֪', Li.SubItems.Text) > 0) then Continue;
    // ����
    uHJX.Excel.InitParams.AppendDataSheet(Li.Caption, Li.SubItems[2], Li.SubItems[3],
      Li.SubItems[0], Li.SubItems[1]);
    // �ӵ��ý�����ɾ����������Ŀ
    DeleteItemFromFinder(Li.SubItems[2], Li.SubItems[3]);
  end;
  ShowMessage('�������');
  btnAppendMeter.Enabled := False;
  btnCancel.Caption := '�˳�';
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
    // �ܵ��������Item���Ǳ���ѡ�ģ�δ����ѡ������
    if not Li.Checked then Continue;
    if (Li.Caption = ASheetName) and (Li.SubItems[0] = ABookName) then
    begin
        FindForm.lvwNewSheets.Items.Delete(i);
        Exit;
    end;
  end;
end;

end.
