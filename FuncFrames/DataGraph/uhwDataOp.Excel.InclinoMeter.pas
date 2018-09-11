{ -----------------------------------------------------------------------------
  Unit Name: uhwDataOp.Excel.InclinoMeter
  Author:    黄伟
  Date:      17-二月-2017
  Purpose:   测斜仪数据查询单元，本单元处理Excel文件数据，提供对xls、xlsx格式
  文件的访问，提取其中的测斜仪数据。
  由于每次打开Excel文件都需要耗费很多时间，因此如果需要取多次数据，应
  尽可能一次性取回全部数据。
  History:
  ----------------------------------------------------------------------------- }

unit uhwDataOp.Excel.InclinoMeter;

interface

uses
    System.Classes, System.SysUtils, System.Variants, nExcel, System.DateUtils,
    {--------------} uhwDataType.DSM.InclinoMeter {--------------};

// 打开Excel数据文件，返回测斜孔数据基本信息、包含的数据日期列
function OpenInDatafile(AFile: string; var AInfo: TdtInclineHoleInfo; DateList: TStrings): Integer;

{ 打开数据文件，返回指定日期的数据 }
function GetInclineDataFromXLS(AFile: string; ADate: TDateTime; AData: PdtInclinometerDatas)
    : Integer; overload;
function GetInclineDataFromXLS(ABook: IXLSWorkBook; ADate: TDateTime; AData: PdtInclinometerDatas)
    : Integer; overload;

{ 打开数据文件，返回全部测斜孔观测数据 }
procedure GetInclineAllDatasFromXLS(AFile: string; ADatas: PdtInHistoryDatas);

{ 打开数据文件，返回用户所选的多个日期的观测数据。参数MultDTs是字符串变量，内容是用户所选择的
  多个日期，每个日期用回车换行符隔开，故可以赋值给TStrings.Text，然后逐一取出日期来。 }
procedure GetInclineMultDatasFromXLS(AFile: string; MultDTs: string; ADatas: PdtInHistoryDatas);

implementation

{ 从给定的workbook中返回指定日期的数据。按照黄金峡测斜孔数据文件格式，每次观测数据单独存放在一张
  工作表中，工作表的名字就是观测日期。 }
function GetDataByDate(ABook: IXLSWorkBook; ADate: TDateTime;
    TheData: PdtInclinometerDatas): Boolean;
var
    s  : string;
    i  : Integer;
    dt : TDateTime;
    sht: IXLSWorksheet;
    { -----------从给定工作簿读取数据，本方法也可以单独存在。---------------- }
    function GetData(ASheet: IXLSWorksheet; Data: PdtInclinometerDatas): Boolean;
    var
        iRow, iCol, iStartRow, i: Integer;
        s                       : string;
        d, a, b                 : Single;
    begin
        Result := false;
        if ASheet = nil then
            exit;
        // 在第一列找"FLevel"，最多找到第10行。
        iStartRow := 0;
        for iRow := 1 to 10 do
        begin
            s := VarToStr(ASheet.Cells.Item[iRow, 1].Value);
            if s <> 'FLevel' then
            begin
                iStartRow := iRow + 1;
                Break;
            end;
        end;

        if iStartRow = 0 then
            exit;

        // 开始读取数据，测斜孔点数不会超过100，因为孔深不会超过50米（间隔0.5米一个测点）
        for iRow := iStartRow to 100 do
        begin
            s := VarToStr(ASheet.Cells.Item[iRow, 1].Value);
            if s = '' then // 第一列是孔深，若该单位为空表，表明已经读完全部数据行了。
                Break;
            // 尝试将s转换为单精度数
            if TryStrToFloat(s, d) then
            begin
                s := VarToStr(ASheet.Cells.Item[iRow, 10].Value);
                if TryStrToFloat(s, a) = false then
                    a := 0;

                s := VarToStr(ASheet.Cells.Item[iRow, 11].Value);
                if TryStrToFloat(s, b) = false then
                    b := 0;

                // 扩展数组，填入数据
                Data.AddData(d, a, b);
                // SetLength(Data.Datas, Length(Data.Datas) + 1);
                // i := High(Data.Datas);
                // New(Data.Datas[i]);
                // Data.Datas[i].Level := d;
                // Data.Datas[i].sgmDA := a;
                // Data.Datas[i].sgmDB := b;
            end;
        end;
        Result := True;
    end;

begin
    Result := false;
    if ABook = nil then
        exit;
    if TheData = nil then
        exit;
    for i := 1 to ABook.Sheets.Count do
    begin
        sht := ABook.Sheets[i];
        s := sht.Name;
        // 测试s是否可以转变为日期，若是，则和给定日期进行比较，成功则取数据
        if TryStrToDate(s, dt) then
            if dt = ADate then
            begin
                TheData.DTScale := ADate;
                Result := GetData(sht, TheData);
                { ----- 可以退出循环，并返回了 }
                // Result := true;
                Break;
            end;
    end;
end;

{ 打开给定的测斜孔数据文件，检查文件格式，返回测斜孔信息和观测日期列表 }
function OpenInDatafile(AFile: string; var AInfo: TdtInclineHoleInfo; DateList: TStrings): Integer;
var
    i    : Integer;
    book : IXLSWorkBook;
    sheet: IXLSWorksheet;
    dt   : TDateTime;
begin
    book := TXLSWorkbook.Create;
    { todo:加入打开Excel文件时的错误处理 }
    // IXLSWorkbook.Open打开成功返回1，无法打开文件返回-1，-3000、-3001、-3002为
    // 不正确的文件格式，其中-3001为html，-3002为xml格式。
    Result := book.Open(AFile);
    if Result <> 1 then
        exit;

    if DateList <> nil then
        DateList.Clear;

    // 找到“Info”工作表，提取其中的信息。注：nExcel都用接口，没法使用for in do语句
    for i := 1 to book.Sheets.Count do
    begin
        sheet := book.Sheets[i];
        if sheet.Name = 'Info' then
        begin
            AInfo.DesignID := VarToStr(sheet.Cells[3, 2].Value);
            AInfo.Position := VarToStr(sheet.Cells[4, 2].Value);
            AInfo.StakeNo := VarToStr(sheet.Cells[5, 2].Value);
            if not VarIsNull(sheet.Cells.Item[6, 2].Value) then
                AInfo.Elevation := sheet.Cells[6, 2].Value;
            if not VarIsNull(sheet.Cells.Item[7, 2].Value) then
                AInfo.BottomEL := sheet.Cells[7, 2].Value;
            AInfo.BaseDate := VarToDateTime(sheet.Cells[12, 2].Value);
            // Break;
        end;

        // 判断是否是观测数据表，即判断工作表名称是否是日期
        if DateList <> nil then
        begin
            if TryStrToDate(sheet.Name, dt) then
                DateList.Add(DateToStr(dt));
        end;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetInclineDataFromXLS
  Description: 从指定的Excel工作簿文件中提取制定日期的测斜孔观测数据。返回值
  -1：无法打开文件；＜-1：非Excel文件格式；0：没有取回数据；1：取回数据。
  ----------------------------------------------------------------------------- }
function GetInclineDataFromXLS(AFile: string; ADate: TDateTime;
    AData: PdtInclinometerDatas): Integer;
var
    book: IXLSWorkBook;
begin
    // 首先，要能打开文件------------------------------------------------------
    Result := 0;
    if AData = nil then
        exit;

    book := TXLSWorkbook.Create;
    Result := book.Open(AFile);
    if Result <> 1 then
        exit;
    // 其次，调用GetDataByDate函数---------------------------------------------
    Result := GetInclineDataFromXLS(book, ADate, AData);
end;

function GetInclineDataFromXLS(ABook: IXLSWorkBook; ADate: TDateTime;
    AData: PdtInclinometerDatas): Integer;
begin
    if ABook = nil then
        exit;
    Result := 1;
    // 其次，调用GetDataByDate函数---------------------------------------------
    if GetDataByDate(ABook, ADate, AData) = false then
        Result := 0;
end;

procedure GetInclineAllDatasFromXLS(AFile: string; ADatas: PdtInHistoryDatas);
var
    pdt     : PdtInclinometerDatas;
    WBook   : IXLSWorkBook;
    HoleInfo: TdtInclineHoleInfo;
    dtList  : TStringList;
    i       : Integer;
begin
    if AFile = '' then
        exit;
    WBook := TXLSWorkbook.Create;
    if WBook.Open(AFile) <> 1 then
        exit;

    if ADatas = nil then
        exit;
    ADatas.ReleaseDatas;
    ADatas.HoleID := '';

    dtList := TStringList.Create;
    try
        OpenInDatafile(AFile, HoleInfo, dtList);
        ADatas.HoleID := HoleInfo.DesignID;
        dtList.Sorted := True;

        if dtList.Count > 0 then
            for i := 0 to dtList.Count - 1 do
            begin
                pdt := ADatas.NewData;
                GetInclineDataFromXLS(WBook, StrToDate(dtList[i]), pdt);
            end;
    finally
        dtList.Free;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetInclineMultDatasFromXLS
  Description: 打开指定数据文件，并返回用户选择的多个日期的观测数据
----------------------------------------------------------------------------- }
procedure GetInclineMultDatasFromXLS(AFile: string; MultDTs: string; ADatas: PdtInHistoryDatas);
var
    pdt    : PdtInclinometerDatas;
    WBook  : IXLSWorkBook;
    strsDTs: TStrings;
    i      : Integer;
begin
    if AFile = '' then
        exit;
    if MultDTs = '' then
        exit;
    WBook := TXLSWorkbook.Create;
    if WBook.Open(AFile) <> 1 then
        exit;

    if ADatas = nil then
        exit;
    ADatas.ReleaseDatas;
    strsDTs := TStringList.Create;
    try
        strsDTs.Text := MultDTs;
        if strsDTs.Count > 0 then
            for i := 0 to strsDTs.Count - 1 do
            begin
                pdt := ADatas.NewData;
                GetInclineDataFromXLS(WBook, StrToDate(strsDTs.Strings[i]), pdt);
            end;
    finally
        strsDTs.Free;
    end;

end;

end.
