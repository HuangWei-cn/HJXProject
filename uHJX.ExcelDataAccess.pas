unit uHJX.ExcelDataAccess;

interface
uses
    uHJX.Excel.DataQuery, uHJX.Excel.InitParams, uHJX.Excel.IO, uHJX.Excel.Meters;

procedure OpenConfig(Afile:string);
implementation

procedure OpenConfig(AFile:string);
begin
    LoadProjectConfig(Afile);
end;

end.
