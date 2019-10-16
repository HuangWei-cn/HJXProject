{ -----------------------------------------------------------------------------
 Unit Name: ufrmFindNewSheets
 Author:    黄伟
 Date:      14-十月-2019
 Purpose:   本单元用于查找新增仪器计算表，从已知的工作簿中。但无法从未知的新
            工作簿中查找。
 History:
----------------------------------------------------------------------------- }

unit ufrmFindNewSheets;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, uHJX.Classes.Meters;

type
  TfrmFindNewSheets = class(TForm)
    Panel1: TPanel;
    btnFindNew: TButton;
    mmoResult: TMemo;
    procedure btnFindNewClick(Sender: TObject);
  private
    { Private declarations }
    procedure FindNewSheets;
  public
    { Public declarations }
  end;

var
  frmFindNewSheets: TfrmFindNewSheets;

implementation
uses nExcel, uHJX.Excel.IO;
{$R *.dfm}

procedure TfrmFindNewSheets.btnFindNewClick(Sender: TObject);
begin
  FindNewSheets;
end;

procedure TfrmFindNewSheets.FindNewSheets;
var
  i, j: Integer;
  wbks: TStrings;
  nBK:IXLSWorkBook;
begin
  mmoResult.Clear;
  wbks := TStringList.Create;
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

    //逐一打开工作簿，枚举所有工作表，核对是否在已知表中，不在则列出
    for i := 0 to wbks.Count -1 do
    begin
      if Trim(wbks[i])='' then Continue;

      ExcelIO.OpenWorkbook(nBK, wbks.Strings[i]);
      for j := 1 to nbk.WorkSheets.Count do
        if (wbks.Objects[i] as TStrings).IndexOf(nbk.WorkSheets[j].Name)=-1 then
          mmoResult.Lines.Add(wbks.Strings[i]+':'+nbk.WorkSheets[j].Name);
    end;

  finally
    for i := 0 to wbks.Count - 1 do wbks.Objects[i].Free;
    wbks.Free;
  end;
end;

end.
