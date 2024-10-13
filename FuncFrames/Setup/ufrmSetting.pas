unit ufrmSetting;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TfrmSetting = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    dtpStartDate: TDateTimePicker;
    dtpEndDate: TDateTimePicker;
    btnOK: TButton;
    btnCancel: TButton;
    optUseDateSetting: TRadioButton;
    optDisableDateSetting: TRadioButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure dtpStartDateChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSetting: TfrmSetting;

implementation

uses uHJX.ProjectGlobal;

{$R *.dfm}


procedure TfrmSetting.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSetting.btnOKClick(Sender: TObject);
begin
  if optDisableDateSetting.Checked then
  begin
    TrendLineSetting.DTStart := 0;
    TrendLineSetting.DTEnd := 0;
  end
  else
  begin
    TrendLineSetting.DTStart := dtpStartDate.Date;
    TrendLineSetting.DTEnd := dtpEndDate.Date;
  end;
end;

procedure TfrmSetting.dtpStartDateChange(Sender: TObject);
begin
  optUseDateSetting.Checked := True;
end;

procedure TfrmSetting.FormCreate(Sender: TObject);
begin
  if (TrendLineSetting.DTStart <> 0) or (TrendLineSetting.DTEnd <> 0) then
  begin
    optUseDateSetting.Checked := True;
    if TrendLineSetting.DTStart <> 0 then
        dtpStartDate.Date := TrendLineSetting.DTStart;
    if TrendLineSetting.DTEnd <> 0 then
        dtpEndDate.Date := TrendLineSetting.DTEnd
    else
        dtpEndDate.Date := Now;
  end;
end;

end.
