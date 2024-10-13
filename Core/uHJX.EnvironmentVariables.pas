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
    { 环境变量 }
  ENV_ConfigPath : String = ''; // 配置文件路径
  ENV_ExePath    : string = ''; // 本程序路径
  ENV_DataRoot   : string = ''; // 数据根目录
  ENV_SchemePath : string = ''; // 分布图目录
  ENV_TempPath   : string = ''; // 临时目录
  ENV_CXDataPath : String = ''; // 测斜孔数据目录
  ENV_ExportPath : string = ''; // 导出文件目录
  ENV_XLTemplBook: string = ''; // XLS数据报表模板文件
  ENV_InitFile   : String = ''; // 配置文件
  ENV_EventsFile : string = ''; // 监测事件文件

  TrendLineSetting: TTrendLineSetup;
implementation

initialization
  TrendLineSetting.DTStart := 0;
  TrendLineSetting.DTEnd := 0;

end.
