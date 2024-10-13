{ -----------------------------------------------------------------------------
  Unit Name: uHJX.Data.Types
  Author:    黄伟
  Date:      12-四月-2017
  Purpose:   数据类型定义
  History:
  ----------------------------------------------------------------------------- }

unit uHJX.Data.Types;

interface

uses
  System.Classes, System.Types, System.Variants;

type
  TVariantDynArray = array of Variant;

  { 特征值数据结构，仅包含数据部分 }
  TEVDataEntry = record
    MaxValue: Double;
    MaxDate: TDateTime;
    MinValue: Double;
    MinDate: TDateTime;
    Increment: Double; // 2018-09-18 增量，末日值-起始值
    Amplitude: Double; // 2018-09-18 振幅，最大值-最小值
    procedure Init;
    procedure CompareData(DT: TDateTime; Value: Double);
  end;

  TEVDataStru = record
    ID: String;            // DesignName
    PDIndex: Integer;      // 物理量序号
    LifeEV: TEVDataEntry;  // 自安装以来特征值
    YearEV: TEVDataEntry;  // 年特征值
    MonthEV: TEVDataEntry; // 月特征值
    CurValue: Double;      // 当前值
    CurDate: TDateTime;    // 当前值日期
    procedure Init;
  end;

  PEVDataStru = ^TEVDataStru;
  PEVDataArray = array of PEVDataStru;

  /// <summary>下面两个Record仅用来从过程线返回数据，用人工修饰过的数据回填数据表
  { 仪器数据记录，每条由观测日期、1个数据组成 }
  TmtDataRec = record
    DT: TDateTime;
    Data:Variant;
  end;

  PmtDataRec = ^TmtDataRec;

  TmtDatas = record
    DesignName: string;
    PDIndex: Integer;
    Datas: array of PmtDataRec;
    //procedure Init;
    procedure ReleaseData;
    procedure AddData(DTScale:TDateTime; AData:Variant);
  end;

  PmtDatas = ^TmtDatas;

  TmtEvent = record
    EventDate: TDateTime;
    LogDate:TDateTime;
    Event: string;
  end;
  PmtEvent = ^TmtEvent;

  TmtEvents = record
    DesignName:string;
    Events: array of PmtEvent;
    procedure Clear;
    function Count:Integer;
    procedure AddEvent(AEventDate,ALogDate:TDateTime; AEvent:string);
  end;
  PmtEvents = ^TmtEvents;

implementation

procedure TEVDataEntry.Init;
begin
  MaxValue := -999999;
  MaxDate := 0;
  MinValue := 999999;
  MinDate := 0;
end;

procedure TEVDataEntry.CompareData(DT: TDateTime; Value: Double);
begin
  if Value > MaxValue then
  begin
    MaxValue := Value;
    MaxDate := DT;
  end
  else if Value = MaxValue then // 如果最大值相等，日期取最近值
  begin
    if MaxDate < DT then
      MaxDate := DT;
  end;

  if Value < MinValue then
  begin
    MinValue := Value;
    MinDate := DT;
  end
  else if Value = MinValue then
  begin
    if MinDate < DT then
      MinDate := DT;
  end;
end;

procedure TEVDataStru.Init;
begin
  ID := '';
  LifeEV.Init;
  YearEV.Init;
  MonthEV.Init;
  CurValue := 0;
  CurDate := 0;
end;

procedure TmtDatas.ReleaseData;
var i:Integer;
begin
  for i := Low(Datas) to High(Datas) do
    Dispose(Datas[i]);
  SetLength(Datas,0);
end;

procedure TmtDatas.AddData(DTScale: TDateTime; AData: Variant);
begin
  SetLength(Datas, Length(Datas)+1);
  New(Datas[High(Datas)]);
  with Datas[High(Datas)]^ do
  begin
    DT := DTScale;
    Data := AData;
  end;
end;

procedure TmtEvents.Clear;
var i:Integer;
begin
  if Count = 0 then
  Exit;
  for i := Low(Events) to High(Events) do
    Dispose(Events[i]);
  SetLength(Events,0);
end;

function TmtEvents.Count: Integer;
begin
  Result := Length(Events);
end;

procedure TmtEvents.AddEvent(AEventDate: TDateTime; ALogDate: TDateTime; AEvent: string);
var i:Integer;
begin
  SetLength(Events, Length(Events)+1);
  i := High(Events);
  New(Events[i]);
  Events[i].EventDate :=AEventDate;
  Events[i].LogDate := ALogDate;
  Events[i].Event := AEvent;
end;

end.
