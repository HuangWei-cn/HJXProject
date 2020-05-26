unit ufrmSetNewSheetParams;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  uHJX.Intf.AppServices, uHJX.Classes.Meters, uHJX.ProjectGlobal;

type
  TfrmSetNewSheetParam = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lblNewSheet: TLabel;
    lblWorkbook: TLabel;
    btnOpenSheet: TButton;
    Button2: TButton;
    edtDesignName: TLabeledEdit;
    Label5: TLabel;
    cbxMeterTypes: TComboBox;
    Label6: TLabel;
    cbxPositions: TComboBox;
    Button1: TButton;
    lblNotice: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FSheet, FBook: String;
    procedure InitMeterTypes;
    procedure InitPositions;
    function GetDsnName: string;
    function GetMeterType: string;
    function GetPosition: String;
    function GetSheetName: string;
    function GetBookName: String;
  public
    { Public declarations }
    procedure ShowSetForm(ASheet, ABook: String);
    property DesignName: string read GetDsnName;
    property MeterType: string read GetMeterType;
    property Position: string read GetPosition;
    property SheetName: string read GetSheetName;
    property BookName: string read GetBookName;
  end;

var
  frmSetNewSheetParam: TfrmSetNewSheetParam;

implementation

{$R *.dfm}


procedure TfrmSetNewSheetParam.FormCreate(Sender: TObject);
begin
  InitMeterTypes;
  InitPositions;
end;

procedure TfrmSetNewSheetParam.InitMeterTypes;
var
  i: Integer;
begin
  cbxMeterTypes.Clear;
  for i := 0 to PG_MeterTypes.Count - 1 do
      cbxMeterTypes.Items.AddStrings(PG_MeterTypes);
end;

procedure TfrmSetNewSheetParam.InitPositions;
var
  i: Integer;
  S: String;
begin
  cbxPositions.Clear;
  for i := 0 to ExcelMeters.Count - 1 do
  begin
    S := ExcelMeters.Items[i].PrjParams.Position;
    if cbxPositions.Items.IndexOf(S) = -1 then cbxPositions.Items.Add(S);
  end;
end;

procedure TfrmSetNewSheetParam.ShowSetForm(ASheet: string; ABook: string);
begin
  lblNotice.Caption := '';
  edtDesignName.Text := Trim(ASheet);
  lblNewSheet.Caption := Trim(ASheet);
  lblWorkbook.Caption := ABook;
  cbxMeterTypes.Text := '';
  cbxPositions.Text := '';
  // 检查工作表名是否包含空格
  if ASheet <> Trim(ASheet) then
  begin
    lblNotice.Caption := '工作表名尾部有空格，请务必删除。本程序保存记录时自动去掉了空格。'
  end;
  Self.ShowModal;
end;

function TfrmSetNewSheetParam.GetDsnName: string;
begin
  Result := edtDesignName.Text;
end;

function TfrmSetNewSheetParam.GetMeterType: string;
begin
  Result := cbxMeterTypes.Text;
end;

function TfrmSetNewSheetParam.GetPosition: string;
begin
  Result := cbxPositions.Text;
end;

function TfrmSetNewSheetParam.GetSheetName: string;
begin
  Result := lblNewSheet.Caption;
end;

function TfrmSetNewSheetParam.GetBookName: string;
begin
  Result := lblWorkbook.Caption;
end;

end.
