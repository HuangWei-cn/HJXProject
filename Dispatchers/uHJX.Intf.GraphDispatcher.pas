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
  TGroupGraphType = (ggtTrendLine { ������ } , ggtBar { ��ͼ } , ggtMeterLine { �ֲ�ͼ } );

    { todo:TDrawFuncû��Ҫ��StartDate��EndDate���޷������������������ }
    /// <summary>
    /// ��ͼ��������ɶ�ĳ�����Ļ�ͼ�󣬷���һ������TeeChart�����Componentʵ����
    /// ��ʵ����parent��Owner���ǲ���AOwner���ҷ��ص�Component.Align = alClient��
    /// ��AOwner = nil���򵯳�һ��form����ͼ����ڴ�form�С�
    /// </summary>
    /// <remarks>�������Ŀǰû���ṩStartDate��EndDate��ֻ�ܴ�ͷ����β��</remarks>
  TDrawFunc = function(ADesignName: string; AOwner: TComponent): TComponent;

    /// <summary>
    /// �������������߷�����
    /// </summary>
    /// <remarks></remarks>
  TDrawGroupGraphFunc = function(AMeters: TStrings; AOwner: TComponent): TComponent;

    { ����ͼ�ε��ļ��������壬������ʽĬ��ΪJPEG����Ҫ����Webҳ���ͼ�����ӡ��������DTStart��DTEnd
      ��Ϊ0�������������ȫ���۲����ݣ�DTStart=0���ӵ�һ�����ݿ�ʼ��DTEnd=0����Ϊ����ʱ���졣 }
  TExportChartToFileFunc = function(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
    AWidth, AHeight: Integer): string;
    { ����ͼ�ε�Stream�������壬����HTMLViewer����ͼ�� }
  TExportChartToStreamFunc = function(ADesignName: string; DTStart, DTEnd: TDateTime;
    var AStream: TStream; AWidth, AHeight: Integer): Boolean;

    /// <summary>
    /// ��ͼ���ܵ��������������ܵ�����IFunctionDispatcher���Ѿ�����DrawGraph�������ڻ��Ƽ������
    /// �����ߣ�һ��������Ѿ������ˡ����ǣ��Ǹ��ӿڵĹ���Ѿ�������Ҫ��չ����Ҫʹ��ͨ�÷�������ʽ
    /// ע���ͼ������ʹ�������Ƚ��鷳��������������ͼ�ι��ܵ���������������Ŀǰ�ṩ��4������
    /// ������������ע�᷽�������ڻ�ͼ�������ע�ᡣ
    /// </summary>
  IGraphDispatcher = interface(IInterface)
    ['{50C43445-00A5-4B90-883D-A248F79196D5}']
        /// <summary>
        /// ����������ͼ����Ĵ��ڡ����������ShowDataGraph����������AContainer = nil����
        /// ShowDataGraph�Ĳ���AContainer = nilʱ�������ͬ�ڵ��ñ������������Ĵ���Form��Onwer��
        /// Host����form.OnCloseEvent = Host.OnClose��Host.OnClose�¼��е�Action = caClose������
        /// ��Form�ر�ʱ�����ͷ����������������
        /// <para>������ִ��ʱ������AContainer = nil����˱�����������һ��Form��ΪContainer��Ȼ��
        /// ����ShowDataGraph����������form��ΪContainer���ݸ�����
        /// </para>
        /// </summary>
    procedure PopupDataGraph(ADesignName: String; AContainer: TComponent = nil);
        /// <summary>
        /// ��ͼ������ͨ�����ڻ��ƹ۲�����ߡ�ʸ��ͼ��λ��ͼ�ȡ�������ִ�к󣬻�ͼ�ṩ�߻ᴴ��
        /// һ��������ͼ�����Frame����Frame��������AContainer�У�����󻯣���Frame.Parent =
        /// AContainer, Frame.Align = alClient����AContainer = nilʱ����������ͬ��PopupDataGraph��
        /// </summary>
    procedure ShowDataGraph(ADesignName: string; AContainer: TComponent = nil);
        /// <summary>
        /// 2022-10-27
        /// ����һ�����������߷�������ShowDataGraph��ͬ���ڣ�������ֻ���ƹ����ߣ�ShowDataGraph��
        /// ����ע��ķ���ʵ��������λ�ͼ�������ǹ����ߣ�Ҳ�����Ǽ�ͷͼ��ɢ��ͼ�ȡ�
        /// </summary>
    procedure ShowGroupGraph(AGraphType: TGroupGraphType; AMeters: TStrings;
      AContainer: TComponent = nil);
    procedure PopupGroupGraph(AGraphType: TGroupGraphType; AMeters: TStrings;
      AContainer: TComponent = nil);
        /// <summary>
        /// ��������ͼ�ε��ļ���ͨ������ǵ���Ϊjpg��ʽ������AWidth, AHeight�ǵ���ͼ�εĳ���
        /// </summary>
    function ExportChartToFile(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
      AWidth, AHeight: Integer): string;
        /// <summary>
        /// ����Chart��Stream��������������ڲ������ļ������������Ƕ�����(HTMLViewer)����ʾͼ�Σ�
        /// ���Ǹ�ר�ŵ���;��
        /// </summary>
    function SaveChartToStream(ADesignName: string; DTStart, DTEnd: TDateTime; AStream: TStream;
      AWidth, AHeight: Integer): Boolean;

    { ������������ע���ͼ������������������ΪStream���� }
    procedure RegistDrawFuncs(AMeterType: string; AFunc: TDrawFunc);
    procedure RegistExportFunc(AMeterType: String; AFunc: TExportChartToFileFunc);
    procedure RegistSaveStreamFunc(AMeterType: string; AFunc: TExportChartToStreamFunc);
    /// <summary>
    /// ע�����������߷���
    /// </summary>
    procedure RegistDrawGroupGraphFunc(AGraphType: TGroupGraphType; AFunc: TDrawGroupGraphFunc);
  end;

implementation

end.
