{ -----------------------------------------------------------------------------
  Unit Name: uhwDataType.DSM.Inclinometer
  Author:    黄伟
  Date:      16-二月-2017
  Purpose:   安全监测数据处理程序数据类型定义-测斜仪
  测斜仪数据处理和数据提取等模块引用本单元。
  History:
  ----------------------------------------------------------------------------- }

unit uhwDataType.DSM.Inclinometer;

interface

uses
    System.Classes, System.SysUtils;

type
    // 测斜孔信息
    TdtInclineHoleInfo = record
        DesignID: string; // 设计编号
        Position: string; // 部位
        StakeNo: string; // 桩号
        Elevation: Single; // 高程
        BottomEL: Single; // 孔底高程
        Section: string; // 监测断面
        BaseDate: TDateTime; // 初值日期
    end;

    // 单点原始数据、计算结果、偏差值
    TdtIncLevelData = record
        Level: Single;
        A1, A2, B1, B2: integer;
        A, B, DA, DB: Single;
    end;

    // 单点累积变化量数据，(∑ΔA, ∑ΔB)
    TdtIncLevelsgmData = record
        Level: Single;
        sgmDA, sgmDB: Single; // 累积偏移值∑ΔA, ∑ΔB
    end;

    PdtIncLevelsgmData = ^TdtIncLevelsgmData;

    // 测斜仪单次数据
    TdtInclinometerDatas = record
        // HoleID: string;
        DTScale: TDateTime;
        Datas: array of PdtIncLevelsgmData;
        procedure ReleaseDatas;
        procedure AddData(ALevel, ADA, ADB: Single);
    end;

    PdtInclinometerDatas = ^TdtInclinometerDatas;

    // 测斜仪观测历史观测数据，即保存的是多次观测数据
    TdtInHistoryDatas = record
        HoleID: string;
        HisDatas: array of PdtInclinometerDatas;
        function NewData: PdtInclinometerDatas;
        procedure ReleaseDatas;
    end;

    PdtInHistoryDatas = ^TdtInHistoryDatas;

implementation

{ 释放指针数组 }
procedure TdtInclinometerDatas.ReleaseDatas;
var
    i: integer;
begin
    if Length(Datas) > 0 then
        for i := Low(Datas) to High(Datas) do
            Dispose(Datas[i]);
    SetLength(Datas, 0);
end;

procedure TdtInclinometerDatas.AddData(ALevel: Single; ADA: Single; ADB: Single);
var
    i: integer;
begin
    i := Length(Datas);
    SetLength(Datas, i + 1);
    i := High(Datas);
    New(Datas[i]);
    Datas[i].Level := ALevel;
    Datas[i].sgmDA := ADA;
    Datas[i].sgmDB := ADB;
end;

procedure TdtInHistoryDatas.ReleaseDatas;
var
    i: integer;
begin
    if Length(HisDatas) > 0 then
        for i := Low(HisDatas) to High(HisDatas) do
        begin
            HisDatas[i].ReleaseDatas;
            Dispose(HisDatas[i]);
        end;
    SetLength(HisDatas, 0);
end;

function TdtInHistoryDatas.NewData: PdtInclinometerDatas;
var
    i: integer;
begin
    Result := nil;
    SetLength(HisDatas, Length(HisDatas) + 1);
    i := High(HisDatas);
    New(HisDatas[i]);
    Result := HisDatas[i];
end;

end.
