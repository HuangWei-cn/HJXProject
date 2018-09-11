unit ufrmSumRptGenOpts;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type
    TfrmSumRptGenOpts = class(TForm)
        rdgDTOpts: TRadioGroup;
        lblStartDate: TLabel;
        dtpDate: TDateTimePicker;
        btnOK: TButton;
        btnCancel: TButton;
        gbxDateSelect: TGroupBox;
        lblEndDate: TLabel;
        dtpEndDate: TDateTimePicker;
        pnlCmd: TPanel;
    private
        { Private declarations }
        FRptType: Integer;
        procedure SetReportType(AType: Integer);
    public
        { Public declarations }
        DateOpts        : Integer;
        property RptType: Integer read FRptType write SetReportType;
    end;

var
    frmSumRptGenOpts: TfrmSumRptGenOpts;

implementation

{$R *.dfm}

procedure TfrmSumRptGenOpts.SetReportType(AType: Integer);
begin
    FRptType := AType;
    case FRptType of
        0, 1:
            begin
                lblStartDate.Caption := '指定日期';
                lblEndDate.Visible   := false;
                dtpEndDate.Visible   := false;
                rdgDTOpts.Visible    := True;
            end;
        2, 3:
            begin
                lblStartDate.Caption := '起始日期';
                lblEndDate.Visible := True;
                dtpEndDate.Visible := True;
                rdgDTOpts.Visible := False;
            end;
    else

    end;
end;

end.
