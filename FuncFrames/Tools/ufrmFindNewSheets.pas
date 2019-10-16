{ -----------------------------------------------------------------------------
 Unit Name: ufrmFindNewSheets
 Author:    ��ΰ
 Date:      14-ʮ��-2019
 Purpose:   ����Ԫ���ڲ��������������������֪�Ĺ������С����޷���δ֪����
            �������в��ҡ�
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

    //��һ�򿪹�������ö�����й������˶��Ƿ�����֪���У��������г�
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
