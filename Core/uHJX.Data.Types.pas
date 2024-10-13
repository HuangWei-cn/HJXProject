{ -----------------------------------------------------------------------------
  Unit Name: uHJX.Data.Types
  Author:    ��ΰ
  Date:      12-����-2017
  Purpose:   �������Ͷ���
  History:
  ----------------------------------------------------------------------------- }

unit uHJX.Data.Types;

interface

uses
  System.Classes, System.Types, System.Variants;

type
  TVariantDynArray = array of Variant;

  { ����ֵ���ݽṹ�����������ݲ��� }
  TEVDataEntry = record
    MaxValue: Double;
    MaxDate: TDateTime;
    MinValue: Double;
    MinDate: TDateTime;
    Increment: Double; // 2018-09-18 ������ĩ��ֵ-��ʼֵ
    Amplitude: Double; // 2018-09-18 ��������ֵ-��Сֵ
    procedure Init;
    procedure CompareData(DT: TDateTime; Value: Double);
  end;

  TEVDataStru = record
    ID: String;            // DesignName
    PDIndex: Integer;      // ���������
    LifeEV: TEVDataEntry;  // �԰�װ��������ֵ
    YearEV: TEVDataEntry;  // ������ֵ
    MonthEV: TEVDataEntry; // ������ֵ
    CurValue: Double;      // ��ǰֵ
    CurDate: TDateTime;    // ��ǰֵ����
    procedure Init;
  end;

  PEVDataStru = ^TEVDataStru;
  PEVDataArray = array of PEVDataStru;

  /// <summary>��������Record�������ӹ����߷������ݣ����˹����ι������ݻ������ݱ�
  { �������ݼ�¼��ÿ���ɹ۲����ڡ�1��������� }
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
  else if Value = MaxValue then // ������ֵ��ȣ�����ȡ���ֵ
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
