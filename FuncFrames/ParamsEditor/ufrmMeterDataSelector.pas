{ -----------------------------------------------------------------------------
 Unit Name: ufrmMeterDataSelector
 Author:    ��ΰ
 Date:      20-����-2017
 Purpose:   ����Ԫ����/�༭���������ݽṹ
            ���û�Ϊ�������ָ�������ݹ��������ñ���Ԫѡ�������Ĺ���������
            �����Ĺ۲�����������������ֵ�������ʼ���С���ʼֵ�С���ע�еȡ�

            ����Ԫʹ����TMSSoftware�����TAdvListEditor��Ϊ���������Ҫ�༭
            ��������������ۼ�������ʽ���ִ��С�

            ���û��༭���֮���²�����д�봫�ݽ�����AMeter�У����ڱ�Form
            ������ChangedParams�����б�����Щ���������˱仯���ڱ���Ԫ�����仯
            �Ĳ���������mepcDatafile, mepcDataStru���ࡣ

            �ڱ���Ԫ�У���Ӧֱ�Ӹı䴫�ݽ�����Meter�Ĳ�������Ϊ�Ƿ���Ҫ�޸�
            ������Ӧ���������༭�������û�ȷ���������ڴˡ�
 History:
----------------------------------------------------------------------------- }
{ todo:������CheckIntValue���������Ծ����Ż�CheckChange������ }
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
        aleMItems: TAdvListEditor; // �۲������б�
        alePItems: TAdvListEditor; // ���������б�
        aleEItems: TAdvListEditor; // ����ֵ���б�
        edtDTRow: TLabeledEdit; // ������ʼ��
        edtDTCol: TLabeledEdit; // ������ʼ��
        edtIVRow: TLabeledEdit;
        edtAnCol: TLabeledEdit; // ��ע��
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
        { ����ɱ༭֮�󣬸���ChangedParams�ж��û�������Щ�ı䣬�ݴ˱�����������ݽ�����Meter����
          �ڱ���Ԫ����ʱ���Ѿ��ı��� }
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
        ShowMessage('�������������');
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
    HintStr := '����ֵ: ' + Value.DisplayText + #13#10'������: ' + Value.Value;
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
    HintStr := '�۲���: ' + Value.DisplayText + #13#10'������: ' + Value.Value;
end;

procedure TfrmMeterDataFileSelection.alePItemsValueHint(Sender: TObject; Value: TAdvListValue;
    var HintStr: string);
begin
    HintStr := '������: ' + Value.DisplayText + #13#10'������: ' + Value.Value;
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
            S := S + '������' + alePItems.Values.Items[i].DisplayText + '���к���Ч��'#13#10;
        end;
    for i := 0 to aleMItems.Values.Count - 1 do
        if TryStrToInt(aleMItems.Values.Items[i].Value, ii) = false then
        begin
            Result := false;
            S := S + '�۲���' + aleMItems.Values.Items[i].DisplayText + '���к���Ч��'#13#10;
        end;
    for i := 0 to aleEItems.Values.Count - 1 do
        if TryStrToInt(aleEItems.Values.Items[i].Value, ii) = false then
        begin
            Result := false;
            S := S + '����ֵ' + aleEItems.Values.Items[i].DisplayText + '���к���Ч��'#13#10;
        end;
    if TryStrToInt(edtDTRow.Text, ii) = false then
    begin
        S := S + '��Ч��������ʼ��;'#13#10;
        Result := false;
    end;
    if TryStrToInt(edtDTCol.Text, ii) = false then
    begin
        S := S + '��Ч��������ʼ��;'#13#10;
        Result := false;
    end;
    if TryStrToInt(edtIVRow.Text, ii) = false then
    begin
        Result := false;
        S := S + '��Ч�ĳ�ʼֵ�У�'#13#10;
    end;
    if TryStrToInt(edtAnCol.Text, ii) = false then
    begin
        Result := false;
        S := S + '��Ч�ı�ע�У�'#13#10;
    end;
    if not Result then
        ShowMessage(S);
end;

procedure TfrmMeterDataFileSelection.CheckChange;
var
    Msg: string;
    // ��������False�����û����õ�ֵ���л��У�����Чֵ���޷�ת��Ϊ����
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
        // ����������кźϲ�Ϊ�ַ������бȽ�
        S := '';
        S1 := '';
        // �۲����ַ���
        for i := 0 to aleMItems.Values.Count - 1 do
        begin
            S := S + aleMItems.Values.Items[i].DisplayText + '|';
            S1 := S1 + aleMItems.Values.Items[i].Value + '|';
        end;
        // �������ַ���
        for i := 0 to alePItems.Values.Count - 1 do
        begin
            S := S + alePItems.Values.Items[i].DisplayText + '|';
            S1 := S1 + alePItems.Values.Items[i].Value + '|';
        end;
        // ����ֵ���ַ���
        for i := 0 to aleEItems.Values.Count - 1 do
            S1 := S1 + aleEItems.Values.Items[i].Value + '|';

        // ����������������ַ���
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
                // ע����������ֵ��ʱ���û��ڱ༭����������������������кţ���������������������ֵ
                // �ֶα�ʾ������������ţ�����ڴ���Ҫ����ת��
                for i := 0 to alePItems.Values.Count - 1 do
                begin
                    NewDT := PDs.AddNew;
                    NewDT.Name := alePItems.Values.Items[i].DisplayText;
                    NewDT.Column := StrToInt(alePItems.Values.Items[i].Value);
                    // ����Ƿ�������ֵ�������к��Ƿ���ͬ�����ж�
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
    // 1.DataSheet�Ƿ�ı�
    if lstWorksheets.Items[lstWorksheets.ItemIndex] <> FMeter.DataSheet then
    begin
        Include(FChangedSet, mepcDataFile);
        FMeter.DataSheet := lstWorksheets.Items[lstWorksheets.ItemIndex];
    end;

    _CheckDataItem;

    // 2.DataStru�Ƿ�ı�
    if _CheckIntParam(edtDTRow.Text, FMeter.DataSheetStru.DTStartRow) = false then
        Msg := Msg + '��Ч��������ʼ��'#13#10;

    if _CheckIntParam(edtDTCol.Text, FMeter.DataSheetStru.DTStartCol) = false then
        Msg := Msg + '��Ч��������ʼ��'#13#10;

    if _CheckIntParam(edtIVRow.Text, FMeter.DataSheetStru.BaseLine) = false then
        Msg := Msg + '��Ч�ĳ�ʼֵ��'#13#10;

    if _CheckIntParam(edtAnCol.Text, FMeter.DataSheetStru.AnnoCol) = false then
        Msg := Msg + '��Ч�ı�ע��'#13#10;
end;

procedure TfrmMeterDataFileSelection.btnCancelClick(Sender: TObject);
begin
    FChangedSet := [];
end;

procedure TfrmMeterDataFileSelection.btnOKClick(Sender: TObject);
begin
    // ����С��к����ã�������������˳�������
    if CheckIntValue = false then
        exit;
    // �����ֱ仯���ã���ʵ�����ò���ֵ�������øı�Ĳ������ͱ��
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
        // �������к�
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
  Description: �༭���������������ݽṹ����
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
    // �������ݽṹ
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

    // ����ע�⣺��Meter��DataBook������Ϊ��ʱ��ABookName=��������֮ABookName<>''��
    // ����ABookName<>''�ǣ���ζ��Meterû�����������ļ�����˵�ABookName<>''ʱ������ִ�е�����
    // �Ϳ����˳��ˡ�����һ������£�����Meterʵ�����Ѿ����ù�DataStru��DataBook��������ָ����
    // Abookname�����������ΪҪ��������Meter��DataStru����������ִ�е���Ҳ�����˳��ˡ�
    if ABookName <> '' then
    begin
        FChangedSet := [mepcDataFile];
        exit;
    end;

    // ������ʾmeter�����ݱ�����ݶ���
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
