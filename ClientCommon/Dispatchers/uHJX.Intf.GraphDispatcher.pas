{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Intf.GraphDispatcher
 Author:    ��ΰ
 Date:      14-����-2018
 Purpose:   ͼ�δ��������
    ͼ�ι��ܵ������򱾳����ṩ��һϵ��ͼ�δ���ķ�����������ߡ�ʸ��ͼ��λ��ͼ��
    �ֲ�ͼ�ȵȣ��Լ�������չ����������������ṩ��ͼ�ι��ܵĵ��ýӿڡ�
    ��Щ���ܵ�ʵ�����򱾽ӿ�ע����صĹ�����ڣ�������ͨ���ӿڽ��е��ã����ӿ�
    ����������ת���������ṩ�ߣ����ؽ������������
 History:   2018-06-14 ������
    2018-07-17 ��ԭuFuncDataGraph��Ԫ�еĹ���Ǩ�������ӿ���
----------------------------------------------------------------------------- }

unit uHJX.Intf.GraphDispatcher;

interface

uses
    System.Classes;

type
    TDrawFunc = function (ADesignName: string; AOwner:TComponent):TComponent;

    { ����ͼ�ε��ļ��������壬������ʽĬ��ΪJPEG����Ҫ����Webҳ���ͼ�����ӡ��������DTStart��DTEnd
      ��Ϊ0�������������ȫ���۲����ݣ�DTStart=0���ӵ�һ�����ݿ�ʼ��DTEnd=0����Ϊ����ʱ���졣 }
    TExportChartToFileFunc = function(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
        AWidth, AHeight: Integer): string;
    { ����ͼ�ε�Stream�������壬����HTMLViewer����ͼ�� }
    TExportChartToStreamFunc = function(ADesignName: string; DTStart, DTEnd: TDateTime;
        var AStream: TStream; AWidth, AHeight: Integer): Boolean;

    IGraphDispatcher = interface(IInterface)
        ['{50C43445-00A5-4B90-883D-A248F79196D5}']
        procedure PopupDataGraph(ADesignName:String; AContainer:TComponent = nil);
        procedure ShowDataGraph(ADesignName:string; AContainer:TComponent = nil);
        function ExportChartToFile(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
            AWidth, AHeight: Integer): string;
        function SaveChartToStream(ADesignName: string; DTStart, DTEnd: TDateTime; AStream: TStream;
            AWidth, AHeight: Integer): Boolean;

        procedure RegistDrawFuncs(AMeterType:string; AFunc: TDrawFunc);
        procedure RegistExportFunc(AMeterType:String; AFunc: TExportChartToFileFunc);
        procedure RegistSaveStreamFunc(AMeterType: string; AFunc: TExportChartToStreamFunc);
    end;

implementation

end.
