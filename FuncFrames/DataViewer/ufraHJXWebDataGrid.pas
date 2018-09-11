{ -----------------------------------------------------------------------------
 Unit Name: ufraHJXWebDataGrid
 Author:    黄伟
 Date:      23-五月-2017
 Purpose:   功能与fraHJXDataGrid基本相同，不同之处在于本单元生成的Web数据表
            可直接拷贝粘贴到报告中进行引用，但缺少fraHJXDataGrid的过滤、排序
            等功能。
            注：本单元使用THTMLViewer作为html显示组件，而非标准库的WebBrowser
            组件。
 History:
----------------------------------------------------------------------------- }

unit ufraHJXWebDataGrid;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, MidasLib,
    Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient, HTMLUn2,
    HtmlView;

type
    TfraWebDataGrid = class(TFrame)
        htmlViewer: THtmlViewer;
        dlgSave: TSaveDialog;
        cdsMeterDatas: TClientDataSet;
    private
        { Private declarations }
        FDesignName: string;
        function GetDataHTMLCode: string;
    public
        { Public declarations }
        procedure ShowMeterDatas(AName: string);
    end;

implementation

uses
    uHJX.Intf.Datas, uWebGridCross, uWeb_DataSet2HTML, {uHJX.Excel.Meters}uHJX.Classes.Meters;
{$R *.dfm}


procedure TfraWebDataGrid.ShowMeterDatas(AName: string);
var
    i: Integer;
begin
    FDesignName := AName;
    if IHJXClientFuncs = nil then
        exit;
    if cdsMeterDatas.Active then
        cdsMeterDatas.Close;

    IHJXClientFuncs.GetAllPDDatas(AName, cdsMeterDatas);
    cdsMeterDatas.Open;
    { ---------方法一：填入WebCrossView表格，并显示------------- }
    //htmlViewer.LoadFromString(GetDataHTMLCode);
    { ---------方法二：使用DataSet2HTML，并显示----------------- }
    htmlViewer.LoadFromString(DataSet2HTML(cdsMeterDatas, AName+'观测数据表'));
end;

function TfraWebDataGrid.GetDataHTMLCode: string;
var
    wcv: TWebCrossView;
    mt : TMeterDefine;
    V  : array of Variant;
    procedure SetGrid;
    begin
        wcv.TitleRows := 3;
        wcv.TitleCols := 5;
        wcv.ColCount := 10;
    end;

begin
    Result := '';
    mt := ExcelMeters.Meter[FDesignName];
    if mt = nil then
        exit;

    wcv := TWebCrossView.Create;
    try
        SetGrid;
        Result := wcv.CrossPage;
    finally
        wcv.Free;
    end;
end;

end.
