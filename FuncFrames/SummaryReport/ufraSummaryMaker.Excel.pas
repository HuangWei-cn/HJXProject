{ -----------------------------------------------------------------------------
  Unit Name: ufraSummaryMaker.Excel
  Author:    黄伟
  Date:      05-四月-2017
  Purpose:   汇总表创建器
  本Frame用于根据用户预定义的汇总表，生成4中类型的汇总表。本Frame仅创建Excel汇
  总表，其定义也是Excel工作簿。本单元使用NativeExcel访问Excel文件。

  注意：
  本单元访问的汇总表是Excel类型的，但是获取数据的途径并不限于Excel，即本
  单元获取数据是通过IClientDatas、IClientFuncs接口，来源可以是Excel，也可
  以是其他数据源，如SQLite。
  History:
  ----------------------------------------------------------------------------- }
{ TODO:将本单元代码和数据访问代码隔离开，即本单元不关心数据来源、获取方式。 }
{ todo:将报表定义保存一个TList中，而不是从TListItem中取 }
unit ufraSummaryMaker.Excel;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
    Winapi.ShellAPI, Vcl.Controls, Vcl.ComCtrls, Vcl.Graphics, Vcl.Forms, Vcl.Dialogs, nExcel,
    Vcl.StdCtrls, System.StrUtils, System.Types, System.DateUtils, System.UITypes,
    uHJX.Intf.Datas;

type
    TfraXLSSummaryMeker = class(TFrame)
        lvwDefine: TListView;
        Label1: TLabel;
        btnMakeIt: TButton;
        dlgSave: TSaveDialog;
        memDebug: TMemo;
        procedure lvwDefineCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
        procedure btnMakeItClick(Sender: TObject);
    private
        { Private declarations }
        FDefineBook : IXLSWorkBook;
        FDefineSheet: IXLSWorkSheet;
        FDT1, FDT2  : Tdatetime;
        FDTOpts     : Integer; // 0-最新数据；1-最接近指定日期；2-指定日期之前
        // FSumBook    : IXLSWorkBook;
        procedure LoadDefine;
        { 下面两个方法中，第一个在本单元直接访问Excel数据文件，创建某汇总表耗时870ms，第二个方法
          通过IClientFuncs.GetLastPDDatas方法获取数据，创建相同的汇总表耗时3880ms }
        procedure MakeBaseStaticSummary(SumSht: IXLSWorkSheet);
        procedure MakeBaseStaticSummary2(SumSht: IXLSWorkSheet);

        procedure TestCustomStaticSummary(SumSht: IXLSWorkSheet);
    public
        { Public declarations }
        procedure SetSummaryDefine(ADefineBook: string);
    end;

implementation

uses
    {uHJX.Excel.Meters}uHJX.Classes.Meters, ufrmSumRptGenOpts;
{$R *.dfm}


type
    TSumType = (stBaseStatic, stCustomStatic, stDynRow, stDynCol, stUnDefine);

    TsdItem = class(TListItem)
    public
        SumName     : string;
        SumType     : TSumType;
        DataStartRow: Integer;
        DataStartCol: Integer;
        IDRow       : Integer;
        IDCol       : Integer;
        DTRow       : Integer;
        DTCol       : Integer;
        ShowDate    : Boolean;
    end;

    TmyWorkbook = class(TXLSWorkbook)
    public
        FullName: string;
        function Open(FileName: WideString): Integer;
        function SheetByName(AName: WideString): IXLSWorkSheet;
    end;

    { 自定义静态表数据项结构体 }
    TSumDataDefine = record
        DefStr: String;
        DesignName: String;
        DataType: Integer; // 0-PD,1-PDName,2-MD, 3-MDName, 4-Param
        ParamName: String;
        PDIndex: Integer;
        MDIndex: Integer;
        Row: Integer;
        Col: Integer;
        procedure ExtractDefineString;
    end;

    PSumDataDefine = ^TSumDataDefine;

function TmyWorkbook.Open(FileName: WideString): Integer;
begin
    FullName := FileName;
    result := inherited Open(FileName);
end;

function TmyWorkbook.SheetByName(AName: WideString): IXLSWorkSheet;
var
    i: Integer;
begin
    result := nil;
    i := Self.Sheets.Index[AName];
    if i <> -1 then
        result := Self.Sheets.Entries[Self.Sheets.Index[AName]];
end;

{ -----------------------------------------------------------------------------
  Procedure  : ExtractDefineString
  Description: 分解字段定义，一般形式为{M01YBP.PD1.NAME }
{ ----------------------------------------------------------------------------- }
procedure TSumDataDefine.ExtractDefineString;
var
    S    : String;
    i    : Integer;
    items: TStringdynarray;
begin
    DesignName := '';
    DataType := 0;
    ParamName := '';
    PDIndex := -1;
    MDIndex := -1;

    S := Trim(DefStr);
    // 去掉花括号
    i := Pos('}', S);
    if i > 0 then
        S := leftstr(S, Length(S) - 1);
    S := RightStr(S, Length(S) - 1);
    // 分解出“.”
    items := SplitString(S, '.');
    if Length(items) > 0 then
    begin
        DesignName := items[0];
        S := items[1];
        if Pos('PD', S) > 0 then
        begin
            S := Copy(S, 3, Length(S) - 2);
            TryStrToInt(S, PDIndex);
            if PDIndex <> -1 then
                PDIndex := PDIndex - 1;

            if Length(items) > 2 then
            begin
                S := items[2];
                { todo:增加对特征值的判断，即EV项，如EV.MAX, EV.MAXDATE, EV.YEARMAX等等 }
                if UpperCase(S) = 'NAME' then
                    DataType := 1;
            end
            else
                DataType := 0;
        end
        else if Pos('MD', S) > 0 then
        begin
            S := Copy(S, 3, Length(S) - 2);
            TryStrToInt(S, MDIndex);
            if MDIndex <> -1 then
                MDIndex := MDIndex - 1;

            if Length(items) > 2 then
            begin
                S := items[2];
                if UpperCase(S) = 'NAME' then
                    DataType := 4;
            end
            else
                DataType := 3;
        end
        else { todo:增加允许使用物理量名称替代PD的功能 }
        begin
            DataType := 4;
            ParamName := S;
        end;
    end;
    SetLength(items, 0);
end;

procedure TfraXLSSummaryMeker.lvwDefineCreateItemClass(Sender: TCustomListView;
    var ItemClass: TListItemClass);
begin
    ItemClass := TsdItem;
end;

procedure TfraXLSSummaryMeker.SetSummaryDefine(ADefineBook: string);
var
    i: Integer;
begin
    FDefineBook := TXLSWorkbook.Create;
    FDefineBook.Open(ADefineBook);
    i := FDefineBook.WorkSheets.Index['汇总表设置'];

    if i = -1 then
    begin
        ShowMessage('没有找到“汇总表设置”工作表，不是有效的汇总表定义工作簿');
        FDefineBook.Close;
    end
    else
    begin
        FDefineSheet := FDefineBook.WorkSheets.Entries[i];
        LoadDefine;
    end;
end;

procedure TfraXLSSummaryMeker.btnMakeItClick(Sender: TObject);
var
    defSht : IXLSWorkSheet;
    i      : Integer;
    newBook: IXLSWorkBook;
    newSht : IXLSWorkSheet;
    t1, t2 : Tdatetime;
    frm    : TfrmSumRptGenOpts;
begin
    if lvwDefine.Selected = nil then
        exit;
    // 先测试基本静态表
    i := FDefineBook.WorkSheets.Index[lvwDefine.Selected.Caption];
    if i = -1 then
        exit;
    defSht := FDefineBook.WorkSheets.Entries[i];
    // 下面创建一个新工作簿，将defsht拷贝到新工作簿中
    newBook := TXLSWorkbook.Create;
    newSht := newBook.WorkSheets.Add;
    newSht.Name := defSht.Name + '：最新数据';

    if dlgSave.Execute then
        newBook.SaveAs(dlgSave.FileName)
    else
        newBook.SaveAs('e:\testout.xls');

    // 注意：下面的代码中，最后的行列要+1 ！！！！
    with defSht.UsedRange do
        Copy(newSht.RCRange[FirstRow, FirstCol, LastRow + 1, LastCol + 1]);

    if TsdItem(lvwDefine.Selected).SumType = stBaseStatic then
    begin
        frm := TfrmSumRptGenOpts.Create(Self);
        try
            frm.RptType := 0;
            frm.ShowModal;
            if frm.ModalResult = mrOk then
            begin
                FDTOpts := frm.rdgDTOpts.ItemIndex;
                FDT1 := frm.dtpDate.Date;
                t1 := now;
                MakeBaseStaticSummary2(newSht);
                t2 := now;
                // ShowMessage(Format('耗时%d毫秒', [System.DateUtils.MilliSecondsBetween(t2, t1)]));
                newBook.Save;
                newBook.Close; // 这里关闭了汇总表

                // 主动打开汇总表
                if MessageDlg('汇总表生成完毕，是否打开汇总表？', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
                    ShellExecute(0, 'open', pchar(dlgSave.FileName), nil, nil, SW_SHOWNORMAL);
            end;
        finally
            frm.Release;
        end;
    end
    else if TsdItem(lvwDefine.Selected).SumType = stCustomStatic then
    begin
        frm := TfrmSumRptGenOpts.Create(Self);
        try
            frm.RptType := 1;
            frm.ShowModal;
            if frm.ModalResult = mrOk then
            begin
                FDTOpts := frm.rdgDTOpts.ItemIndex;
                FDT1 := frm.dtpDate.Date;
                TestCustomStaticSummary(newSht);
                newBook.Save;
                newBook.Close;

                if MessageDlg('汇总表生成完毕，是否打开汇总表？', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
                    ShellExecute(0, 'open', pchar(dlgSave.FileName), nil, nil, SW_SHOWNORMAL);
            end;
        finally
            frm.Release;
        end;
    end;
end;

procedure TfraXLSSummaryMeker.LoadDefine;
var
    iRow : Integer;
    S    : string;
    LItem: TsdItem;
    function _GetIntValue(ARow, ACol: Integer): Integer;
    begin
        result := -1;
        S := Trim(VarToStr(FDefineSheet.Cells[ARow, ACol].Value));
        if S = '' then
            exit;
        TryStrToInt(S, result);
    end;

begin
    lvwDefine.items.Clear;
    for iRow := 3 to 1000 do
    begin
        S := Trim(VarToStr(FDefineSheet.Cells[iRow, 2].Value));
        if S = '' then
            exit;
        LItem := lvwDefine.items.Add as TsdItem;
        LItem.Caption := S;
        LItem.SumName := S;
        S := Trim(VarToStr(FDefineSheet.Cells[iRow, 3].Value));
        LItem.SubItems.Add(S);
        if S = '自定义静态表' then
            LItem.SumType := stCustomStatic
        else if S = '基本汇总表' then
            LItem.SumType := stBaseStatic
        else if S = '动态行表' then
            LItem.SumType := stDynRow
        else if S = '动态列表' then
            LItem.SumType := stDynCol
        else
            LItem.SumType := stUnDefine;
        LItem.DataStartRow := _GetIntValue(iRow, 4);
        if LItem.DataStartRow <> -1 then
            LItem.SubItems.Add(IntToStr(LItem.DataStartRow))
        else
            LItem.SubItems.Add('');

        LItem.DataStartCol := _GetIntValue(iRow, 5);
        if LItem.DataStartCol <> -1 then
            LItem.SubItems.Add(IntToStr(LItem.DataStartCol))
        else
            LItem.SubItems.Add('');

        LItem.IDRow := _GetIntValue(iRow, 6);
        if LItem.IDRow <> -1 then
            LItem.SubItems.Add(IntToStr(LItem.IDRow))
        else
            LItem.SubItems.Add('');

        LItem.IDCol := -1;
        LItem.DTRow := _GetIntValue(iRow, 7);
        if LItem.DTRow <> -1 then
            LItem.SubItems.Add(IntToStr(LItem.DTRow))
        else
            LItem.SubItems.Add('');

        // 日期列
        LItem.DTCol := _GetIntValue(iRow, 8);
        // 是否标注日期
        S := Trim(VarToStr(FDefineSheet.Cells[iRow, 9].Value));
        if S = '是' then
            LItem.ShowDate := True
        else
            LItem.ShowDate := False;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : MakeBaseStaticSummary
  Description: 测试创建一个基本静态表，如果成功，则转移到一个专门的单元去干
  这个活。
  创建基本静态表已经成功，后续工作是转移到专门的单元去处理，并完善各种检查、
  支持选择日期等等工作。
  ----------------------------------------------------------------------------- }
procedure TfraXLSSummaryMeker.MakeBaseStaticSummary(SumSht: IXLSWorkSheet);
var
    datBook   : TmyWorkbook;
    datSht    : IXLSWorkSheet;
    iRow, iCol: Integer;
    dRow, dCol: Integer;
    DTScaleCol: Integer;
    bShowDT   : Boolean;
    S, ID     : string;
    sValue    : array of string;
    D         : Double;
    DTScale   : TDate;
    AMeter    : TMeterDefine;
    function GetData: Boolean;
    var
        i, j: Integer;
    begin
        result := False;
        SetLength(sValue, AMeter.DataSheetStru.PDs.Count);
        // UsedRange.LastRow+1是UsedRange的最后一行。
        for i := datSht.UsedRange.LastRow + 3 downto AMeter.DataSheetStru.DTStartRow do
        begin
            S := Trim(VarToStr(datSht.Cells[i, 1].Value));
            // 倒叙，空值就继续
            if S = '' then
                Continue;
            // 非空，可以
            DTScale := VarToDateTime(datSht.Cells[i, 1].Value);
            // 取回全部的PD值
            for j := 0 to AMeter.DataSheetStru.PDs.Count - 1 do
            begin
                sValue[j] := '';
                sValue[j] :=
                    VarToStr(datSht.Cells[i, AMeter.DataSheetStru.PDs.items[j].Column].Value);
                if TryStrToFloat(sValue[j], D) then
                begin
                    sValue[j] := FormatFloat('0.00', D);
                end;
            end;
            result := True;
            Break;
        end;
    end;

begin
    with lvwDefine.Selected as TsdItem do
    begin
        dRow := DataStartRow;
        dCol := DataStartCol;
        DTScaleCol := DTCol; // 日期列
        bShowDT := ShowDate; // 静态汇总表中是否要显示日期
    end;

    datBook := TmyWorkbook.Create;
    try
        // 逐行取汇总表中的仪器编号
        { todo:应该把取仪器数据的代码放入到专门的单元进行处理，即这里仅仅是填写汇总表，获取数据的
          工作应该和本单元解耦，以适应将来不同的数据源。 }
        for iRow := dRow to SumSht.UsedRange.LastRow + 1 do
        begin
            ID := Trim(VarToStr(SumSht.Cells[iRow, 1].Value));

            if ID = '' then
                Continue;
            AMeter := ExcelMeters.Meter[ID];
            if AMeter = nil then
                Continue;

            // 取仪器的数据文件及工作表
            if datBook.FullName <> AMeter.DataBook then
            begin
                datBook.Close;
                datBook.Open(AMeter.DataBook);
            end;

            datSht := datBook.SheetByName(AMeter.DataSheet);
            if datSht = nil then
                Continue;

            // 读取最后一次观测数据
            if GetData then
            begin
                for iCol := 0 to AMeter.DataSheetStru.PDs.Count - 1 do
                begin
                    if sValue[iCol] <> '' then
                        SumSht.Cells[iRow, iCol + dCol].Value := StrToFloat(sValue[iCol]);
                end;
            end;

            // 如果需要，填入日期
            if bShowDT and (DTScaleCol <> -1) then
                SumSht.Cells[iRow, DTScaleCol].Value := DTScale;
        end;

    finally
        datBook.Free;
    end;
end;

procedure TfraXLSSummaryMeker.MakeBaseStaticSummary2(SumSht: IXLSWorkSheet);
var
    iRow, iCol: Integer;
    dRow, dCol: Integer;
    DTScaleCol: Integer;
    bShowDT   : Boolean;
    ID        : string;
    AMeter    : TMeterDefine;
    rst       : Boolean;
    VarRecord : TDoubleDynArray; // 使用IClientFuncs.GetLastPDDatas所需的参数
begin
    with lvwDefine.Selected as TsdItem do
    begin
        dRow := DataStartRow;
        dCol := DataStartCol;
        DTScaleCol := DTCol; // 日期列
        bShowDT := ShowDate; // 静态汇总表中是否要显示日期
    end;

    IHJXClientFuncs.SessionBegin; // 启用Session可以减少打开关闭Excel工作簿的次数
    try
        for iRow := dRow to SumSht.UsedRange.LastRow + 1 do
        begin
            ID := Trim(VarToStr(SumSht.Cells[iRow, 1].Value));

            if ID = '' then
                Continue;
            AMeter := ExcelMeters.Meter[ID];
            if AMeter = nil then
                Continue;
            if FDTOpts = 0 then
                rst := IHJXClientFuncs.GetLastPDDatas(ID, VarRecord)
            else if FDTOpts = 1 then
                rst := IHJXClientFuncs.GetNearestPDDatas(ID, FDT1, VarRecord)
            else if FDTOpts = 2 then
                rst := IHJXClientFuncs.GetLastPDDatasBeforeDate(ID, FDT1, VarRecord);

            if rst then
                if Length(VarRecord) > 0 then
                begin
                    // 判断是否查询到观测数据，若无数据则VarRecord[0]=0
                    if VarRecord[0] = 0 then
                    begin
                        if bShowDT and (DTScaleCol <> -1) then
                            SumSht.Cells[iRow, DTScaleCol].Value := '/';
                        for iCol := 0 to AMeter.PDDefines.Count - 1 do
                            SumSht.Cells[iRow, iCol + dCol].Value := '/';
                        Continue;
                    end;

                    for iCol := 0 to AMeter.PDDefines.Count - 1 do
                        SumSht.Cells[iRow, iCol + dCol].Value := VarRecord[iCol + 1];
                    if bShowDT and (DTScaleCol <> -1) then
                    begin
                        // 判断是否是合并区，若是则
                        if SumSht.Cells[iRow, DTScaleCol].MergeCells then
                            SumSht.Cells[iRow, DTScaleCol].MergeArea.Value := VarRecord[0]
                        else
                            SumSht.Cells[iRow, DTScaleCol].Value := VarRecord[0];
                    end;
                end;
        end;

    finally
        IHJXClientFuncs.SessionEnd;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : TestCustomStaticSummary
  Description: 测试自定义静态表创建过程
  ----------------------------------------------------------------------------- }
procedure TfraXLSSummaryMeker.TestCustomStaticSummary(SumSht: IXLSWorkSheet);
var
    iRow, iCol: Integer;
    S         : string;
    DataField : PSumDataDefine;
    dfList    : TList;
    Meter     : TMeterDefine;
    bk        : TmyWorkbook;
    sht       : IXLSWorkSheet;

    function GetData: string;
    var
        D : Double;
        ii: Integer;
    begin
        result := '';
        if bk.FullName <> Meter.DataBook then
            bk.Open(Meter.DataBook);
        sht := bk.SheetByName(Meter.DataSheet);
        if sht = nil then
            exit;
        // 倒序查找最后一次数据
        for ii := sht.UsedRange.LastRow + 2 downto Meter.DataSheetStru.DTStartRow do
        begin
            S := Trim(VarToStr(sht.Cells[ii, 1].Value));
            if S = '' then
                Continue;

            S := Trim(VarToStr(sht.Cells[ii, Meter.DataSheetStru.PDs.items[DataField.PDIndex]
                .Column].Value));
            if S <> '' then
                if TryStrToFloat(S, D) then
                    result := FormatFloat('0.00', D);
            Break;
        end;
    end;

begin
    // 首先收集需要填入的单元格，分解其中数据定义
    memDebug.Lines.Clear;
    dfList := TList.Create;
    bk := TmyWorkbook.Create;
    try
        for iRow := SumSht.UsedRange.FirstRow + 1 to SumSht.UsedRange.LastRow + 1 do
            for iCol := SumSht.UsedRange.FirstCol + 1 to SumSht.UsedRange.LastCol + 1 do
            begin
                S := Trim(VarToStr(SumSht.Cells[iRow, iCol].Value));
                if S <> '' then
                    if Pos('{', S) > 0 then
                    begin
                        memDebug.Lines.Add(Format('%s @Row:%d, Col:%d', [S, iRow, iCol]));
                        New(DataField);
                        dfList.Add(DataField);
                        DataField.DefStr := S;
                        DataField.Row := iRow;
                        DataField.Col := iCol;
                        DataField.ExtractDefineString;

                        Meter := ExcelMeters.Meter[DataField.DesignName];
                        if Meter = nil then
                            Continue;

                        if DataField.DataType = 4 then
                            SumSht.Cells[DataField.Row, DataField.Col].Value :=
                                Meter.ParamValue(DataField.ParamName)
                        else if DataField.DataType = 1 then
                            SumSht.Cells[DataField.Row, DataField.Col].Value :=
                                Meter.DataSheetStru.PDs.items[DataField.PDIndex].Name
                        else if DataField.DataType = 0 then
                        begin
                            S := GetData;
                            if S <> '' then
                                SumSht.Cells[DataField.Row, DataField.Col].Value :=
                                    StrToFloat(S);
                        end;
                        // with DataField do
                        // memDebug.Lines.Add
                        // (Format('%s; datatype:%d; ParamName: %s; PDIndex:%d; MDIndex:%d; Row:%d; Col:%d',
                        // [DesignName, DataType, ParamName, PDIndex, MDIndex, Row, Col]));
                    end;
            end;
        // 逐个查询数据，并填入

    finally
        while dfList.Count > 0 do
        begin
            Dispose(dfList.items[0]);
            dfList.Delete(0);
        end;
        dfList.Free;
        bk.Free;
    end;
end;

end.
