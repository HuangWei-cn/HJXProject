{ -----------------------------------------------------------------------------
 Unit Name: ufrmMeterDataSelector
 Author:    黄伟
 Date:      20-九月-2017
 Purpose:   本单元设置/编辑仪器的数据结构
            当用户为监测仪器指定了数据工作簿后，用本单元选择仪器的工作表、定义
            仪器的观测量、物理量、特征值项、日期起始行列、初始值列、备注列等。

            本单元使用了TMSSoftware的组件TAdvListEditor作为数据项的主要编辑
            组件，该组件的外观及操作方式有现代感。

            当用户编辑完成之后，新参数将写入传递进来的AMeter中，并在本Form
            的属性ChangedParams集合中表明那些参数发生了变化，在本单元发生变化
            的参数类型是mepcDatafile, mepcDataStru两类。

            在本单元中，不应直接改变传递进来的Meter的参数，因为是否需要修改
            参数，应该是由主编辑界面由用户确定，而非在此。
 History:
----------------------------------------------------------------------------- }
{ todo:由于有CheckIntValue方法，可以精简优化CheckChange方法了 }
unit ufrmMeterDataSelector;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.ExtCtrls,
    Vcl.Menus, System.Actions, Vcl.ActnList,
    {uHJX.Excel.Meters}uHJX.Classes.Meters, uHJX.Excel.InitParams, Vcl.Mask, AdvListEditor;

type
    TfrmMeterDataFileSelection = class(TForm)
        lblWorkbook: TLabel;
        GroupBox2: TGroupBox;
        lstWorksheets: TListBox;
        btnOK: TButton;
        btnCancel: TButton;
        Panel1: TPanel;
        Panel2: TPanel;
        grdSheet: TStringGrid;
        aleMItems: TAdvListEditor; // 观测量项列表
        alePItems: TAdvListEditor; // 物理量项列表
        aleEItems: TAdvListEditor; // 特征值项列表
        edtDTRow: TLabeledEdit; // 日期起始行
        edtDTCol: TLabeledEdit; // 日期起始列
        edtIVRow: TLabeledEdit;
        edtAnCol: TLabeledEdit; // 备注列
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        Panel3: TPanel;
        pnlSheetName: TPanel;
        pmSetDS: TPopupMenu;
        piAddMD: TMenuItem;
        piAddPD: TMenuItem;
        piAddED: TMenuItem;
        N4: TMenuItem;
        piSetDTRowCol: TMenuItem;
        piSetIVRow: TMenuItem;
        piSetAnCol: TMenuItem;
        ActionList1: TActionList;
        actAddMD: TAction;
        actAddPD: TAction;
        actAddED: TAction;
        actSetDTRowCol: TAction;
        actSetIVRow: TAction;
        actSetAnCol: TAction;
    AdvListEditor1: TAdvListEditor;
        procedure lstWorksheetsClick(Sender: TObject);
        procedure lstWorksheetsDblClick(Sender: TObject);
        procedure actSetDTRowColExecute(Sender: TObject);
        procedure actSetIVRowExecute(Sender: TObject);
        procedure actSetAnColExecute(Sender: TObject);
        procedure actAddMDExecute(Sender: TObject);
        procedure actAddPDExecute(Sender: TObject);
        procedure actAddEDExecute(Sender: TObject);
        procedure aleMItemsValueHint(Sender: TObject; Value: TAdvListValue; var HintStr: string);
        procedure alePItemsValueHint(Sender: TObject; Value: TAdvListValue; var HintStr: string);
        procedure aleEItemsValueHint(Sender: TObject; Value: TAdvListValue; var HintStr: string);
        procedure aleMItemsValueEditDone(Sender: TObject; Value: TAdvListValue;
            var EditText: string);
        procedure aleMItemsValueEditStart(Sender: TObject; Value: TAdvListValue;
            var EditText: string);
        procedure btnOKClick(Sender: TObject);
        procedure btnCancelClick(Sender: TObject);
    private
        { Private declarations }
        FMeter       : TMeterDefine;
        FWorkbook    : string;
        FUserSelected: string;
        FEditValueStr: String;
        FChangedSet  : TMeterExcelParamchangedSet;
        procedure ShowSheetContent(ASheetName: string);
        procedure CheckChange;
        function CheckIntValue: boolean;
    public
        { Public declarations }
        procedure LoadWorkbook(ABookName, ASheetName: string);
        procedure EditMeter(AMeter: TMeterDefine; ABookName: string = '');
        property WorkSheet: string read FUserSelected;
        { 在完成编辑之后，根据ChangedParams判断用户做了哪些改变，据此保存参数。传递进来的Meter参数
          在本单元结束时，已经改变了 }
        property ChangedParams: TMeterExcelParamchangedSet read FChangedSet;
    end;

implementation

uses
    nExcel, uHJX.Excel.IO;
{$R *.dfm}


procedure TfrmMeterDataFileSelection.actAddEDExecute(Sender: TObject);
begin
    with grdSheet do
        aleEItems.Values.AddPair(cells[Col, Row], IntToStr(Col));
end;

procedure TfrmMeterDataFileSelection.actAddMDExecute(Sender: TObject);
begin
    with grdSheet do
        aleMItems.Values.AddPair(cells[Col, Row], IntToStr(Col));
end;

procedure TfrmMeterDataFileSelection.actAddPDExecute(Sender: TObject);
begin
    with grdSheet do
        alePItems.Values.AddPair(cells[Col, Row], IntToStr(Col));
end;

procedure TfrmMeterDataFileSelection.actSetAnColExecute(Sender: TObject);
begin
    edtAnCol.Text := IntToStr(grdSheet.Col);
end;

procedure TfrmMeterDataFileSelection.actSetDTRowColExecute(Sender: TObject);
begin
    if (grdSheet.Row < 1) or (grdSheet.Col < 1) then
    begin
        ShowMessage('错误的日期行列');
        exit;
    end;
    edtDTRow.Text := IntToStr(grdSheet.Row);
    edtDTCol.Text := IntToStr(grdSheet.Col);
end;

procedure TfrmMeterDataFileSelection.actSetIVRowExecute(Sender: TObject);
begin
    edtIVRow.Text := IntToStr(grdSheet.Row);
end;

procedure TfrmMeterDataFileSelection.aleEItemsValueHint(Sender: TObject; Value: TAdvListValue;
    var HintStr: string);
begin
    HintStr := '特征值: ' + Value.DisplayText + #13#10'所在列: ' + Value.Value;
end;

procedure TfrmMeterDataFileSelection.aleMItemsValueEditDone(Sender: TObject; Value: TAdvListValue;
    var EditText: string);
begin
    Value.Value := FEditValueStr;
end;

procedure TfrmMeterDataFileSelection.aleMItemsValueEditStart(Sender: TObject; Value: TAdvListValue;
    var EditText: string);
begin
    FEditValueStr := Value.Value;
end;

procedure TfrmMeterDataFileSelection.aleMItemsValueHint(Sender: TObject; Value: TAdvListValue;
    var HintStr: string);
begin
    HintStr := '观测量: ' + Value.DisplayText + #13#10'所在列: ' + Value.Value;
end;

procedure TfrmMeterDataFileSelection.alePItemsValueHint(Sender: TObject; Value: TAdvListValue;
    var HintStr: string);
begin
    HintStr := '物理量: ' + Value.DisplayText + #13#10'所在列: ' + Value.Value;
end;

function TfrmMeterDataFileSelection.CheckIntValue: boolean;
var
    i, ii: Integer;
    S    : string;
begin
    Result := True;
    S := '';
    for i := 0 to alePItems.Values.Count - 1 do
        if TryStrToInt(alePItems.Values.Items[i].Value, ii) = false then
        begin
            Result := false;
            S := S + '物理量' + alePItems.Values.Items[i].DisplayText + '的列号无效；'#13#10;
        end;
    for i := 0 to aleMItems.Values.Count - 1 do
        if TryStrToInt(aleMItems.Values.Items[i].Value, ii) = false then
        begin
            Result := false;
            S := S + '观测量' + aleMItems.Values.Items[i].DisplayText + '的列号无效；'#13#10;
        end;
    for i := 0 to aleEItems.Values.Count - 1 do
        if TryStrToInt(aleEItems.Values.Items[i].Value, ii) = false then
        begin
            Result := false;
            S := S + '特征值' + aleEItems.Values.Items[i].DisplayText + '的列号无效；'#13#10;
        end;
    if TryStrToInt(edtDTRow.Text, ii) = false then
    begin
        S := S + '无效的日期起始行;'#13#10;
        Result := false;
    end;
    if TryStrToInt(edtDTCol.Text, ii) = false then
    begin
        S := S + '无效的日期起始列;'#13#10;
        Result := false;
    end;
    if TryStrToInt(edtIVRow.Text, ii) = false then
    begin
        Result := false;
        S := S + '无效的初始值行；'#13#10;
    end;
    if TryStrToInt(edtAnCol.Text, ii) = false then
    begin
        Result := false;
        S := S + '无效的备注列；'#13#10;
    end;
    if not Result then
        ShowMessage(S);
end;

procedure TfrmMeterDataFileSelection.CheckChange;
var
    Msg: string;
    // 函数返回False表明用户设置的值（行或列）是无效值，无法转换为整数
    function _CheckIntParam(AText: string; var Param: Integer): boolean;
    var
        v: Integer;
    begin
        Result := True;
        AText := Trim(AText);
        if TryStrToInt(AText, v) then
        begin
            if v <> Param then
            begin
                Param := v;
                Include(FChangedSet, mepcDataStru);
            end;
        end
        else if AText = '' then
            Param := 0
        else
            Result := false;
    end;

    function _CheckDataItem: boolean;
    var
        i, j    : Integer;
        S, S1   : String;
        S2, S3  : string;
        bChanged: boolean;
        NewDT   : PDataDefine;
    begin
        Result := false;
        bChanged := false;
        // 将数据项及其列号合并为字符串进行比较
        S := '';
        S1 := '';
        // 观测量字符串
        for i := 0 to aleMItems.Values.Count - 1 do
        begin
            S := S + aleMItems.Values.Items[i].DisplayText + '|';
            S1 := S1 + aleMItems.Values.Items[i].Value + '|';
        end;
        // 物理量字符串
        for i := 0 to alePItems.Values.Count - 1 do
        begin
            S := S + alePItems.Values.Items[i].DisplayText + '|';
            S1 := S1 + alePItems.Values.Items[i].Value + '|';
        end;
        // 特征值列字符串
        for i := 0 to aleEItems.Values.Count - 1 do
            S1 := S1 + aleEItems.Values.Items[i].Value + '|';

        // 监测仪器的数据项字符串
        S2 := '';
        S3 := '';
        for i := 0 to FMeter.DataSheetStru.MDs.Count - 1 do
        begin
            S2 := S2 + FMeter.DataSheetStru.MDs.Items[i].Name + '|';
            S3 := S3 + IntToStr(FMeter.DataSheetStru.MDs.Items[i].Column) + '|';
        end;
        for i := 0 to FMeter.DataSheetStru.PDs.Count - 1 do
        begin
            S2 := S2 + FMeter.DataSheetStru.PDs.Items[i].Name + '|';
            S3 := S3 + IntToStr(FMeter.DataSheetStru.PDs.Items[i].Column) + '|';
        end;

        for i := 0 to FMeter.DataSheetStru.PDs.Count - 1 do
            with FMeter.DataSheetStru do
                if PDs.Items[i].HasEV then
                    S3 := S3 + IntToStr(PDs.Items[i].Column) + '|';

        if (S <> S2) or (S1 <> S3) then
            bChanged := True
        else
        begin
            Result := True;
            exit;
        end;

        if bChanged then
        begin
            with FMeter.DataSheetStru do
            begin
                MDs.Clear;
                PDs.Clear;
                for i := 0 to aleMItems.Values.Count - 1 do
                begin
                    NewDT := MDs.AddNew;
                    NewDT.Name := aleMItems.Values.Items[i].DisplayText;
                    NewDT.Column := StrToInt(aleMItems.Values.Items[i].Value);
                end;
                // 注：设置特征值项时，用户在编辑界面输入的是物理量及其列号，但在仪器参数表中特征值
                // 字段表示的是物理量序号，因此在此需要进行转换
                for i := 0 to alePItems.Values.Count - 1 do
                begin
                    NewDT := PDs.AddNew;
                    NewDT.Name := alePItems.Values.Items[i].DisplayText;
                    NewDT.Column := StrToInt(alePItems.Values.Items[i].Value);
                    // 检查是否是特征值，根据列号是否相同进行判断
                    for j := 0 to aleEItems.Values.Count - 1 do
                        if StrToInt(aleEItems.Values.Items[j].Value) = NewDT.Column then
                        begin
                            NewDT.HasEV := True;
                            Break;
                        end;
                end;
            end;
            Include(FChangedSet, mepcDataStru);
        end;
        Result := True;
    end;

begin
    // 1.DataSheet是否改变
    if lstWorksheets.Items[lstWorksheets.ItemIndex] <> FMeter.DataSheet then
    begin
        Include(FChangedSet, mepcDataFile);
        FMeter.DataSheet := lstWorksheets.Items[lstWorksheets.ItemIndex];
    end;

    _CheckDataItem;

    // 2.DataStru是否改变
    if _CheckIntParam(edtDTRow.Text, FMeter.DataSheetStru.DTStartRow) = false then
        Msg := Msg + '无效的日期起始行'#13#10;

    if _CheckIntParam(edtDTCol.Text, FMeter.DataSheetStru.DTStartCol) = false then
        Msg := Msg + '无效的日期起始列'#13#10;

    if _CheckIntParam(edtIVRow.Text, FMeter.DataSheetStru.BaseLine) = false then
        Msg := Msg + '无效的初始值行'#13#10;

    if _CheckIntParam(edtAnCol.Text, FMeter.DataSheetStru.AnnoCol) = false then
        Msg := Msg + '无效的备注列'#13#10;
end;

procedure TfrmMeterDataFileSelection.btnCancelClick(Sender: TObject);
begin
    FChangedSet := [];
end;

procedure TfrmMeterDataFileSelection.btnOKClick(Sender: TObject);
begin
    // 检查行、列好设置，如果有问题则退出本方法
    if CheckIntValue = false then
        exit;
    // 检查各种变化设置，其实是设置参数值，并设置改变的参数类型标记
    CheckChange;
    Self.ModalResult := mrOk;
end;

procedure TfrmMeterDataFileSelection.LoadWorkbook(ABookName, ASheetName: string);
var
    Wbk: IXLSWorkBook;
    i  : Integer;
begin
    lstWorksheets.Clear;
    lblWorkbook.Caption := ABookName;
    FWorkbook := ABookName;
    // Wbk := TXLSWorkbook.Create;
    if ExcelIO.OpenWorkbook(Wbk, ABookName) = True then
    begin
        for i := 1 to Wbk.WorkSheets.Count do
            lstWorksheets.Items.Add(Wbk.WorkSheets[i].Name);
    end;
    FUserSelected := '';
    if lstWorksheets.Count > 0 then
        if ASheetName <> '' then
            lstWorksheets.ItemIndex := lstWorksheets.Items.IndexOf(ASheetName)
        else
            lstWorksheets.ItemIndex := 0;
    FUserSelected := lstWorksheets.Items[lstWorksheets.ItemIndex];
end;

procedure TfrmMeterDataFileSelection.lstWorksheetsClick(Sender: TObject);
begin
    FUserSelected := lstWorksheets.Items[lstWorksheets.ItemIndex];
end;

procedure TfrmMeterDataFileSelection.lstWorksheetsDblClick(Sender: TObject);
begin
    if lstWorksheets.ItemIndex = -1 then
        exit;
    // pnlSheetName.Caption := lstWorksheets.Items[lstWorksheets.ItemIndex];
    grdSheet.RowCount := 2;
    grdSheet.ColCount := 2;
    ShowSheetContent(pnlSheetName.Caption);
end;

procedure TfrmMeterDataFileSelection.ShowSheetContent(ASheetName: string);
var
    Wbk       : IXLSWorkBook;
    Sht       : IXLSWorksheet;
    iRow, iCol: Integer;
    S         : String;
begin
    pnlSheetName.Caption := ASheetName;
    Wbk := TXLSWorkbook.Create;
    try
        Wbk.Open(FWorkbook);
        Sht := Wbk.WorkSheets[Wbk.WorkSheets.Index[ASheetName]];
        grdSheet.RowCount := Sht.UsedRange.LastRow + 1;
        grdSheet.ColCount := Sht.UsedRange.LastCol + 1;
        // 设置行列号
        for iRow := 1 to grdSheet.RowCount - 1 do
            grdSheet.cells[0, iRow] := IntToStr(iRow);
        for iCol := 1 to grdSheet.ColCount - 1 do
            grdSheet.cells[iCol, 0] := IntToStr(iCol);
        for iRow := 1 to grdSheet.RowCount - 1 do
            for iCol := 1 to grdSheet.ColCount - 1 do
                grdSheet.cells[iCol, iRow] := VarToStr(Sht.cells[iRow, iCol].Value);
    finally
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : EditMeter
  Description: 编辑给定的仪器的数据结构定义
----------------------------------------------------------------------------- }
procedure TfrmMeterDataFileSelection.EditMeter(AMeter: TMeterDefine; ABookName: string = '');
var
    i: Integer;
begin
    if AMeter = nil then
        exit;
    if ABookName = '' then
        LoadWorkbook(AMeter.DataBook, AMeter.DataSheet)
    else
        LoadWorkbook(ABookName, '');
    // 设置数据结构
    aleMItems.Values.Clear;
    alePItems.Values.Clear;
    aleEItems.Values.Clear;
    edtDTRow.Text := '';
    edtDTCol.Text := '';
    edtIVRow.Text := '';
    edtAnCol.Text := '';
    edtDTRow.Text := IntToStr(AMeter.DataSheetStru.DTStartRow);
    edtDTCol.Text := IntToStr(AMeter.DataSheetStru.DTStartCol);
    edtIVRow.Text := IntToStr(AMeter.DataSheetStru.BaseLine);
    edtAnCol.Text := IntToStr(AMeter.DataSheetStru.AnnoCol);

    // 这里注意：当Meter的DataBook参数不为空时，ABookName=‘’，反之ABookName<>''。
    // 即当ABookName<>''是，意味着Meter没有设置数据文件，因此当ABookName<>''时，程序执行到这里
    // 就可以退出了。在另一种情况下，比如Meter实际上已经设置过DataStru和DataBook，但这里指定了
    // Abookname参数，这可认为要重新设置Meter的DataStru，这样程序执行到此也可以退出了。
    if ABookName <> '' then
    begin
        FChangedSet := [mepcDataFile];
        exit;
    end;

    // 下面显示meter的数据表和数据定义
    ShowSheetContent(AMeter.DataSheet);
    for i := 0 to AMeter.DataSheetStru.MDs.Count - 1 do
        with AMeter.DataSheetStru.MDs do
            aleMItems.Values.AddPair(Items[i].Name, IntToStr(Items[i].Column));
    for i := 0 to AMeter.DataSheetStru.PDs.Count - 1 do
        with AMeter.DataSheetStru.PDs do
        begin
            alePItems.Values.AddPair(Items[i].Name, IntToStr(Items[i].Column));
            if Items[i].HasEV then
                aleEItems.Values.AddPair(Items[i].Name, IntToStr(Items[i].Column));
        end;
    FChangedSet := [];
    FMeter := AMeter;
end;

end.
