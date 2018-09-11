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
        procedure Init;
        procedure CompareData(DT: TDateTime; Value: Double);
    end;

    TEVDataStru = record
        ID: String; // DesignName
        PDIndex: Integer; // ���������
        LifeEV: TEVDataEntry; // �԰�װ��������ֵ
        YearEV: TEVDataEntry; // ������ֵ
        MonthEV: TEVDataEntry; // ������ֵ
        CurValue: Double; // ��ǰֵ
        CurDate: TDateTime; // ��ǰֵ����
        procedure Init;
    end;

    PEVDataStru  = ^TEVDataStru;
    PEVDataArray = array of PEVDataStru;

implementation

procedure TEVDataEntry.Init;
begin
    MaxValue := -999999;
    MaxDate  := 0;
    MinValue := 999999;
    MinDate  := 0;
end;

procedure TEVDataEntry.CompareData(DT: TDateTime; Value: Double);
begin
    if Value > MaxValue then
    begin
        MaxValue := Value;
        MaxDate  := DT;
    end
    else if Value = MaxValue then // ������ֵ��ȣ�����ȡ���ֵ
    begin
        if MaxDate < DT then
            MaxDate := DT;
    end;

    if Value < MinValue then
    begin
        MinValue := Value;
        MinDate  := DT;
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
    CurDate  := 0;
end;

end.
