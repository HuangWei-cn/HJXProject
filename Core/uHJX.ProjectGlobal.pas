unit uHJX.ProjectGlobal;

interface
uses
    System.Classes;

var
    { ���������б� }
    PG_MeterTypes: TStrings;
    { ���̲�λ�б� }
    PG_Locations: TStrings;
implementation

initialization
    PG_MeterTypes := TStringList.Create;
    PG_Locations := TStringList.Create;

finalization
    PG_MeterTypes.Free;
    PG_Locations.Free;
end.
