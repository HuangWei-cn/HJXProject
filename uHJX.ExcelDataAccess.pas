unit uHJX.ExcelDataAccess;

interface

uses
    uHJX.Excel.DataQuery,  // IClientFunction接口的实例
    uHJX.Excel.InitParams, // 加载参数表、各种初始化
    uHJX.Excel.IO,         // Excel访问功能
    uHJX.Excel.Meters;     // 对TMeterDefine和TMeters的具象化

procedure OpenConfig(Afile: string);

implementation

procedure OpenConfig(Afile: string);
begin
    // call LoadProjectConfig@uHJX.Excel.InitParams.pas
    LoadProjectConfig(Afile);
end;

end.
