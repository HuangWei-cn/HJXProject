unit uHJX.ProjectGlobal;

interface

uses
  System.Classes;

type
  TTrendLineSetup = record
    DTStart: TDateTime;
    DTEnd: TDateTime;
  end;

var
    { 仪器类型列表 }
  PG_MeterTypes: TStrings;
    { 工程部位列表 }
  PG_Locations: TStrings;

  TrendLineSetting: TTrendLineSetup;

implementation

initialization

PG_MeterTypes := TStringList.Create;
PG_Locations := TStringList.Create;
TrendLineSetting.DTStart := 0;
TrendLineSetting.DTEnd := 0;

finalization

PG_MeterTypes.Free;
PG_Locations.Free;

end.
