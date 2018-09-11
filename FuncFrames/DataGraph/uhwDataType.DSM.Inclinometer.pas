{ -----------------------------------------------------------------------------
  Unit Name: uhwDataType.DSM.Inclinometer
  Author:    ��ΰ
  Date:      16-����-2017
  Purpose:   ��ȫ������ݴ�������������Ͷ���-��б��
  ��б�����ݴ����������ȡ��ģ�����ñ���Ԫ��
  History:
  ----------------------------------------------------------------------------- }

unit uhwDataType.DSM.Inclinometer;

interface

uses
    System.Classes, System.SysUtils;

type
    // ��б����Ϣ
    TdtInclineHoleInfo = record
        DesignID: string; // ��Ʊ��
        Position: string; // ��λ
        StakeNo: string; // ׮��
        Elevation: Single; // �߳�
        BottomEL: Single; // �׵׸߳�
        Section: string; // ������
        BaseDate: TDateTime; // ��ֵ����
    end;

    // ����ԭʼ���ݡ���������ƫ��ֵ
    TdtIncLevelData = record
        Level: Single;
        A1, A2, B1, B2: integer;
        A, B, DA, DB: Single;
    end;

    // �����ۻ��仯�����ݣ�(�Ʀ�A, �Ʀ�B)
    TdtIncLevelsgmData = record
        Level: Single;
        sgmDA, sgmDB: Single; // �ۻ�ƫ��ֵ�Ʀ�A, �Ʀ�B
    end;

    PdtIncLevelsgmData = ^TdtIncLevelsgmData;

    // ��б�ǵ�������
    TdtInclinometerDatas = record
        // HoleID: string;
        DTScale: TDateTime;
        Datas: array of PdtIncLevelsgmData;
        procedure ReleaseDatas;
        procedure AddData(ALevel, ADA, ADB: Single);
    end;

    PdtInclinometerDatas = ^TdtInclinometerDatas;

    // ��б�ǹ۲���ʷ�۲����ݣ���������Ƕ�ι۲�����
    TdtInHistoryDatas = record
        HoleID: string;
        HisDatas: array of PdtInclinometerDatas;
        function NewData: PdtInclinometerDatas;
        procedure ReleaseDatas;
    end;

    PdtInHistoryDatas = ^TdtInHistoryDatas;

implementation

{ �ͷ�ָ������ }
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
