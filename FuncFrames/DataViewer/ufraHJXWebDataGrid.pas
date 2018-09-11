{ -----------------------------------------------------------------------------
 Unit Name: ufraHJXWebDataGrid
 Author:    ��ΰ
 Date:      23-����-2017
 Purpose:   ������fraHJXDataGrid������ͬ����֮ͬ�����ڱ���Ԫ���ɵ�Web���ݱ�
            ��ֱ�ӿ���ճ���������н������ã���ȱ��fraHJXDataGrid�Ĺ��ˡ�����
            �ȹ��ܡ�
            ע������Ԫʹ��THTMLViewer��Ϊhtml��ʾ��������Ǳ�׼���WebBrowser
            �����
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
    { ---------����һ������WebCrossView��񣬲���ʾ------------- }
    //htmlViewer.LoadFromString(GetDataHTMLCode);
    { ---------��������ʹ��DataSet2HTML������ʾ----------------- }
    htmlViewer.LoadFromString(DataSet2HTML(cdsMeterDatas, AName+'�۲����ݱ�'));
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
