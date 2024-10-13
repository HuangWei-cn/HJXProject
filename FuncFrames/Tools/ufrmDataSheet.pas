unit ufrmDataSheet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Types,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Tabs, Vcl.Grids, Vcl.StdCtrls, Vcl.ExtCtrls,
  uHJX.Intf.AppServices, uHJX.Intf.FunctionDispatcher, uHJX.Classes.Meters, XBookComponent2,
  XLSBook2, XLSSheetData5, XLSReadWriteII5, XLSGrid5;

type
  TfrmDataSheet = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    lblBookName: TLabel;
    btnRefresh: TButton;
    lstSheets: TListBox;
    XLSGrid: TXLSGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRefreshClick(Sender: TObject);
    procedure lstSheetsDblClick(Sender: TObject);
  private
    { Private declarations }
    Fstupid: Integer;
    FBook  : String;
    FSheet : String;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    procedure ShowMeterSheet(ABk, ASht: String); overload;
    procedure ShowMeterSheet(ADesignName: String); overload;
  end;

var
  frmDataSheet: TfrmDataSheet;

// procedure ShowWorkSheetWithoutExcel(ABookName, ASheetName:String);
procedure ShowMeterSheetWithoutExcel(ADesignName: String);

implementation

{$R *.dfm}

procedure TfrmDataSheet.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := 0;
end;

procedure TfrmDataSheet.ShowMeterSheet(ABk: string; ASht: string);
var
  i: Integer;
begin
  try
    FBook := ABk;
    FSheet := ASht;
    lstSheets.Clear;

    // XLSSS.XLS.Clear(1);
    XLSGrid.XLS.LoadFromFile(ABk);
    XLSGrid.XLS.SelectedTab := XLSGrid.XLS.SheetByName(ASht).Index;
    XLSGrid.XLSChanged(True);
    for i := 0 to XLSGrid.XLS.Count - 1 do
        lstSheets.Items.Add(XLSGrid.XLS.Sheets[i].Name);
    lblBookName.Caption := ABk;
  finally
  end;
end;

procedure TfrmDataSheet.btnRefreshClick(Sender: TObject);
begin
  //Self.Close;
  // XLSSS.SetSheet(XLSSS.XLS.SheetByName(FSheet).Index);
  //XLSGrid.Invalidate;
  //XLSGrid.Repaint;
  //xlsgrid.Repaint;
end;

procedure TfrmDataSheet.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmDataSheet := nil; { todo:这是非常不合规的做法，下不为例 }
end;

procedure TfrmDataSheet.lstSheetsDblClick(Sender: TObject);
begin
  if lstSheets.ItemIndex = -1 then      Exit;
  XLSGrid.XLS.SelectedTab := lstSheets.ItemIndex;
  XLSGrid.XLSChanged(True);
  Self.Caption := XLSGrid.Sheet.Name + '观测数据表';
end;

procedure TfrmDataSheet.ShowMeterSheet(ADesignName: string);
var
  Mt: TMeterDefine;
begin
  Self.Caption := ADesignName + '观测数据表';
  Mt := ExcelMeters.Meter[ADesignName];
  if Mt <> nil then
      ShowMeterSheet(Mt.DataBook, Mt.DataSheet);
end;

procedure ShowMeterSheetWithoutExcel(ADesignName: String);
begin
  if frmDataSheet = nil then
  begin
    frmDataSheet := TfrmDataSheet.Create(IAppServices.Application as TApplication);
    // frmDataSheet.parent := IAppServices.Host as TForm
  end;
  frmDataSheet.ShowMeterSheet(ADesignName);
  frmDataSheet.Show;
end;

procedure RegisterProc;
begin
  frmDataSheet := nil;
  (IAppServices.FuncDispatcher as IFunctionDispatcher).RegisterProc('ShowMeterSheetWithoutExcel',
    ShowMeterSheetWithoutExcel);
end;

initialization

RegisterProc;

end.
