unit uHJX.EnvironmentVariables;

interface

uses
  System.Classes, System.Variants;

type
  TTrendLineSetup = record
    DTStart: TDateTime;
    DTEnd: TDateTime;
  end;

var
    { �������� }
  ENV_ConfigPath : String = ''; // �����ļ�·��
  ENV_ExePath    : string = ''; // ������·��
  ENV_DataRoot   : string = ''; // ���ݸ�Ŀ¼
  ENV_SchemePath : string = ''; // �ֲ�ͼĿ¼
  ENV_TempPath   : string = ''; // ��ʱĿ¼
  ENV_CXDataPath : String = ''; // ��б������Ŀ¼
  ENV_ExportPath : string = ''; // �����ļ�Ŀ¼
  ENV_XLTemplBook: string = ''; // XLS���ݱ���ģ���ļ�
  ENV_InitFile   : String = ''; // �����ļ�
  ENV_EventsFile : string = ''; // ����¼��ļ�

  TrendLineSetting: TTrendLineSetup;
implementation

initialization
  TrendLineSetting.DTStart := 0;
  TrendLineSetting.DTEnd := 0;

end.
