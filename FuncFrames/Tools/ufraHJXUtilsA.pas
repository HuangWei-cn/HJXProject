{ -----------------------------------------------------------------------------
 Unit Name: ufraHJXUtilsA
 Author:    黄伟
 Date:      25-五月-2017
 Purpose:   辅助小工具
 History:
----------------------------------------------------------------------------- }
unit ufraHJXUtilsA;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, HTMLUn2, HtmlView, Vcl.ExtCtrls,
    Vcl.StdCtrls, Data.DB, Datasnap.DBClient, MidasLib;

type
    TfraHJXUtilsA = class(TFrame)
        Panel1: TPanel;
        Panel2: TPanel;
        HtmlViewer: THtmlViewer;
        grpDataCount: TGroupBox;
        btnDataCount: TButton;
        optDataCountByYear: TRadioButton;
        optDataCountByPeriod: TRadioButton;
        GroupBox1: TGroupBox;
        btnGetDataSchadule: TButton;
        cdsDatas: TClientDataSet;
    private
        { Private declarations }
        procedure ShowDataCount;
    public
        { Public declarations }
    end;

implementation

uses
    uHJX.Intf.Datas, {uHJX.Excel.Meters}uHJX.Classes.Meters, uWebGridCross;
{$R *.dfm}


{ -----------------------------------------------------------------------------
  Procedure  : ShowDataCount
  Description: 需要统计的内容有：总观测点次，各个年度观测点次，指定时段观测点次
----------------------------------------------------------------------------- }
procedure TfraHJXUtilsA.ShowDataCount;
begin
    HtmlViewer.Clear;
    if ExcelMeters.Count = 0 then
        exit;
    if IHJXClientFuncs = nil then
        exit;
end;

end.
