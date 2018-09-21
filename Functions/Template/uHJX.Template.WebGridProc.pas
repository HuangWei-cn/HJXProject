{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Template.WebGridProc
 Author:    黄伟
 Date:      2018-09-02
 Purpose:   WebGrid模板处理单元
 本单元将仪器、数据套用到指定模板上，返回一个WebGrid的HTML代码。本单元需要引用
 模板单元、Meters单元、数据访问对象等。对占位符的处理已经移植到一个单独的单元完
 成：uHJX.Template.ProcSpecifiers.pas.

 本单元的处理方式可以移植到Excel数据表的处理，针对动态行表，应该足够了；甚至于，
 可以用本模板格式化显示EhGrid的表头和数据显示。

 History:  2018-08-15 初步成功，可显示锚索、多点等仪器，暂不支持仪器组
            2018-08-16 可以处理仪器组了，同时对模板支持的仪器类型进行了设置和
            检查，模板只支持正确的仪器类型。
----------------------------------------------------------------------------- }
{ done: 表格数据格式：自动判断日期是采用日期还是日期时间；数据部分右对齐 }
{ todo: 对于仪器组，应支持不同仪器的各项参数，而非仅仅是Meter1.DesignName }
{ todo: 支持数据时间段 }
{ todo: GenGrid返回值中，Title应该可选 }
unit uHJX.Template.WebGridProc;

interface

uses
    System.Classes, System.SysUtils, System.DateUtils,

    uHJX.Intf.AppServices, uHJX.Intf.Datas, uHJX.Classes.Meters, uHJX.Classes.Templates,
    uHJX.Template.WebGrid;

{ 依照模板生成指定仪器的数据表,WebGrid类型 }
{ todo:创建WebGrid数据表应可指定时间段 }
function GenWebGrid(grdTemp: TWebGridTemplate; AMeter: TMeterDefine): string; overload;
function GenWebGrid(grdTemp: TWebGridTemplate; AMeter: TMeterDefine; DT1, DT2: TDateTime)
    : string; overload;
function GenWebGrid(ADsnName: string): string; overload;
function GenWebGrid(ADsnName: string; DT1, DT2: TDateTime): string; overload;

implementation

uses
    uHJX.Template.ProcSpecifiers, uWebGridCross, Data.DB,
    Datasnap.DBClient;

type
    TWGDataCell = record
        TempStr: string;   // 模板单元格内容
        Specifier: string; // 占位符
        Field: TField;     // 对应字段
        function GetValue: Variant;
    end;

function TWGDataCell.GetValue: Variant;
begin
    { todo:若Field是日期类型，则应判断是否需要显示时间。否则应仅显示日期。 }
    if Field = nil then
        Result := TempStr
    else if Field.DataType = ftDateTime then
    begin
        // 如果只有日期部分，则格式为yyyy-mm-dd；若包含时间部分，则加上时间
        if DateOf(Field.AsDateTime) = Field.AsDateTime then
            Result := FormatDateTime('yyyy-mm-dd', Field.AsDateTime)
        else
            Result := FormatDateTime('yyyy-mm-dd hh:mm', Field.AsDateTime);
    end
    else
        Result := Field.Value;
end;

{ 将数据行各个单元与数据集字段联系起来，为下一步填写数据做准备 }
procedure __WGProcDataRow(grdTemp: TWebGridTemplate; AMeter: TMeterDefine;
    var DataRow: TArray<TWGDataCell>; DS: TClientDataSet; AsGroup: Boolean = False);
var
    iCol: Integer;
    S   : string;
begin
    for iCol := 0 to grdTemp.ColCount - 1 do
    begin
        S := grdTemp.DataCell[iCol];

        DataRow[iCol].TempStr := S;
        DataRow[iCol].Specifier := ProcDataSpecifiers(S, AMeter, AsGroup);
        DataRow[iCol].Field := DS.FindField(DataRow[iCol].Specifier);
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GenGrid
  Description: 根据表格模板和监测仪器对象，生成该仪器的观测数据表
----------------------------------------------------------------------------- }
function GenWebGrid(grdTemp: TWebGridTemplate; AMeter: TMeterDefine): string;
var
    i         : Integer;
    iRow, iCol: Integer;
    S         : string;
    wcv       : TWebCrossView;
    v         : array of Variant;
    DR        : TArray<TWGDataCell>;
    DS        : TClientDataSet;
    bGroup    : Boolean; // 判断是否按组处理
    bGetData  : Boolean; // 判断是否成功取回数据

    procedure SetColumnAlignment;
    var
        ii: Integer;
    begin
        for ii := 0 to grdTemp.ColCount - 1 do
            if DR[ii].Field <> nil then
                case DR[ii].Field.DataType of
                    ftFloat:
                        wcv.ColHeader[ii].Align := taRightJustify;
                end;
    end;

begin
    Result := '';
    bGroup := False;
    // 检查仪器类型是否对应
    if grdTemp.MeterType <> '' then
        if grdTemp.MeterType <> AMeter.Params.MeterType then
            raise Exception.CreateFmt('"%s"不支持%s的仪器类型。模板仪器类型为%s，当前仪器类型为%s',
                [grdTemp.TemplateName, AMeter.DesignName, grdTemp.MeterType,
                AMeter.Params.MeterType]);

    // 如果模板支持仪器组，且仪器归属于某个组，则进行组处理
    if grdTemp.ApplyGroup and (AMeter.PrjParams.GroupID <> '') then
        bGroup := True;

    // 处理Title, 方法是将每行中的占位符替换为相应的仪器属性，若无占位符则原文输出
    for i := 0 to grdTemp.Titles.Count - 1 do
    begin
        // S := ReplaceSpecifiers(grdTemp.Titles[i], AMeter, bGroup);
        S := ProcParamSpecifiers(grdTemp.Titles[i], AMeter, bGroup);
        Result := Result + S + #13#10;
    end;

    wcv := TWebCrossView.Create;
    try
        wcv.TitleRows := grdTemp.HeadRowCount;
        wcv.TitleCols := grdTemp.ColCount;
        wcv.ColCount := grdTemp.ColCount;
        SetLength(v, grdTemp.ColCount);
        // 处理表头: 解析模板表头单元格内容，用参数替换占位符，将行内容添加到WebCrossView中
        for iRow := 0 to high(grdTemp.Heads) do
        begin
            for iCol := 0 to high(grdTemp.Heads[iRow].Cols) do
            begin
                // S := ReplaceSpecifiers(grdTemp.Heads[iRow].Cols[iCol], AMeter, bGroup);
                S := ProcParamSpecifiers(grdTemp.Heads[iRow].Cols[iCol], AMeter, bGroup);
                // Result := Result + S + #9;
                v[iCol] := S;
            end;
            // Result := Result + #13#10;
            wcv.AddRow(v);
        end;

        // 处理数据行:
        // 取回观测数据集
        DS := TClientDataSet.Create(nil);
        if bGroup then
            bGetData := IAppServices.ClientDatas.GetGroupAllPDDatas
                (AMeter.PrjParams.GroupID, DS)
        else
            bGetData := IAppServices.ClientDatas.GetAllPDDatas(AMeter.DesignName, DS);

        if bGetData then
        begin
            // 设置数据行数组
            SetLength(DR, grdTemp.ColCount);
            // 解析模板，设置数据行单元格
            __WGProcDataRow(grdTemp, AMeter, DR, DS, bGroup);
            // 根据DR中字段的数据类型设置列对齐
            SetColumnAlignment;
            // 添加数据
            DS.First;
            repeat
                for iCol := 0 to grdTemp.ColCount - 1 do
                    v[iCol] := DR[iCol].GetValue;
                wcv.AddRow(v);
                DS.Next;
            until DS.Eof;
        end;
        Result := wcv.CrossPage;
    finally
        wcv.Free;
        SetLength(v, 0);
        SetLength(DR, 0);
        DS.Free;
    end;
end;

function GenWebGrid(grdTemp: TWebGridTemplate; AMeter: TMeterDefine; DT1, DT2: TDateTime): string;
var
    i         : Integer;
    iRow, iCol: Integer;
    S         : string;
    wcv       : TWebCrossView;
    v         : array of Variant;
    DR        : TArray<TWGDataCell>;
    DS        : TClientDataSet;
    bGroup    : Boolean; // 判断是否按组处理
    bGetData  : Boolean; // 判断是否成功取回数据

    procedure SetColumnAlignment;
    var
        ii: Integer;
    begin
        for ii := 0 to grdTemp.ColCount - 1 do
            if DR[ii].Field <> nil then
                case DR[ii].Field.DataType of
                    ftFloat:
                        wcv.ColHeader[ii].Align := taRightJustify;
                end;
    end;

begin
    Result := '';
    bGroup := False;
    // 检查仪器类型是否对应
    if grdTemp.MeterType <> '' then
        if grdTemp.MeterType <> AMeter.Params.MeterType then
            raise Exception.CreateFmt('"%s"不支持%s的仪器类型。模板仪器类型为%s，当前仪器类型为%s',
                [grdTemp.TemplateName, AMeter.DesignName, grdTemp.MeterType,
                AMeter.Params.MeterType]);

    // 如果模板支持仪器组，且仪器归属于某个组，则进行组处理
    if grdTemp.ApplyGroup and (AMeter.PrjParams.GroupID <> '') then
        bGroup := True;

    // 处理Title, 方法是将每行中的占位符替换为相应的仪器属性，若无占位符则原文输出
    for i := 0 to grdTemp.Titles.Count - 1 do
    begin
        // S := ReplaceSpecifiers(grdTemp.Titles[i], AMeter, bGroup);
        S := ProcParamSpecifiers(grdTemp.Titles[i], AMeter, bGroup);
        Result := Result + S + #13#10;
    end;

    wcv := TWebCrossView.Create;
    try
        wcv.TitleRows := grdTemp.HeadRowCount;
        wcv.TitleCols := grdTemp.ColCount;
        wcv.ColCount := grdTemp.ColCount;
        SetLength(v, grdTemp.ColCount);
        // 处理表头: 解析模板表头单元格内容，用参数替换占位符，将行内容添加到WebCrossView中
        for iRow := 0 to high(grdTemp.Heads) do
        begin
            for iCol := 0 to high(grdTemp.Heads[iRow].Cols) do
            begin
                // S := ReplaceSpecifiers(grdTemp.Heads[iRow].Cols[iCol], AMeter, bGroup);
                S := ProcParamSpecifiers(grdTemp.Heads[iRow].Cols[iCol], AMeter, bGroup);
                // Result := Result + S + #9;
                v[iCol] := S;
            end;
            // Result := Result + #13#10;
            wcv.AddRow(v);
        end;

        // 处理数据行:
        // 取回观测数据集
        DS := TClientDataSet.Create(nil);

        if (DT1 = 0) and (DT2 = 0) then
        begin
            if bGroup then
                bGetData := IAppServices.ClientDatas.GetGroupAllPDDatas
                    (AMeter.PrjParams.GroupID, DS)
            else
                bGetData := IAppServices.ClientDatas.GetAllPDDatas(AMeter.DesignName, DS);
        end
        else
        begin
            if bGroup then
                bGetData := IAppServices.ClientDatas.GetGroupPDDatasInPeriod
                    (AMeter.PrjParams.GroupID, DT1, DT2, DS)
            else
                bGetData := IAppServices.ClientDatas.GetPDDatasInPeriod(AMeter.DesignName,
                    DT1, DT2, DS);
        end;

        if bGetData then
        begin
            // 设置数据行数组
            SetLength(DR, grdTemp.ColCount);
            // 解析模板，设置数据行单元格
            __WGProcDataRow(grdTemp, AMeter, DR, DS, bGroup);
            // 根据DR中字段的数据类型设置列对齐
            SetColumnAlignment;
            // 添加数据
            DS.First;
            repeat
                for iCol := 0 to grdTemp.ColCount - 1 do
                    v[iCol] := DR[iCol].GetValue;
                wcv.AddRow(v);
                DS.Next;
            until DS.Eof;
        end;
        Result := wcv.CrossPage;
    finally
        wcv.Free;
        SetLength(v, 0);
        SetLength(DR, 0);
        DS.Free;
    end;
end;

function GenWebGrid(ADsnName: string): string;
var
    Meter: TMeterDefine;
    Tmpl : ThjxTemplate;
    S    : string;
begin
    Result := '';
    Meter := (IAppServices.Meters as TMeterDefines).Meter[ADsnName];
    if Meter = nil then
        exit;

    S := Meter.DataSheetStru.WGTemplate;
    Tmpl := (IAppServices.Templates as TTemplates).ItemByName[S];
    if Tmpl = nil then
        exit;

    Result := GenWebGrid(Tmpl as TWebGridTemplate, Meter);
end;

function GenWebGrid(ADsnName: string; DT1, DT2: TDateTime): string;
var
    Meter: TMeterDefine;
    Tmpl : ThjxTemplate;
    S    : string;
begin
    Result := '';
    Meter := (IAppServices.Meters as TMeterDefines).Meter[ADsnName];
    if Meter = nil then
        exit;

    S := Meter.DataSheetStru.WGTemplate;
    Tmpl := (IAppServices.Templates as TTemplates).ItemByName[S];
    if Tmpl = nil then
        exit;

    Result := GenWebGrid(Tmpl as TWebGridTemplate, Meter, DT1, DT2);
end;

end.
