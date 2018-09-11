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
        procedure Init;
        procedure CompareData(DT: TDateTime; Value: Double);
    end;

    TEVDataStru = record
        ID: String; // DesignName
        PDIndex: Integer; // 物理量序号
        LifeEV: TEVDataEntry; // 自安装以来特征值
        YearEV: TEVDataEntry; // 年特征值
        MonthEV: TEVDataEntry; // 月特征值
        CurValue: Double; // 当前值
        CurDate: TDateTime; // 当前值日期
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
    else if Value = MaxValue then // 如果最大值相等，日期取最近值
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
