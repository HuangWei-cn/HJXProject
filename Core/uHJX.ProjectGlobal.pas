unit uHJX.ProjectGlobal;

interface
uses
    System.Classes;

var
    { 仪器类型列表 }
    PG_MeterTypes: TStrings;
    { 工程部位列表 }
    PG_Locations: TStrings;
implementation

initialization
    PG_MeterTypes := TStringList.Create;
    PG_Locations := TStringList.Create;

finalization
    PG_MeterTypes.Free;
    PG_Locations.Free;
end.
