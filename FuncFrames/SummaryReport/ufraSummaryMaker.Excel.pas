{ -----------------------------------------------------------------------------
  Unit Name: ufraSummaryMaker.Excel
  Author:    ��ΰ
  Date:      05-����-2017
  Purpose:   ���ܱ�����
  ��Frame���ڸ����û�Ԥ����Ļ��ܱ�����4�����͵Ļ��ܱ���Frame������Excel��
  �ܱ��䶨��Ҳ��Excel������������Ԫʹ��NativeExcel����Excel�ļ���

  ע�⣺
  ����Ԫ���ʵĻ��ܱ���Excel���͵ģ����ǻ�ȡ���ݵ�;����������Excel������
  ��Ԫ��ȡ������ͨ��IClientDatas��IClientFuncs�ӿڣ���Դ������Excel��Ҳ��
  ������������Դ����SQLite��
  History:
  ----------------------------------------------------------------------------- }
{ TODO:������Ԫ��������ݷ��ʴ�����뿪��������Ԫ������������Դ����ȡ��ʽ�� }
{ todo:�������屣��һ��TList�У������Ǵ�TListItem��ȡ }
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
        FDTOpts     : Integer; // 0-�������ݣ�1-��ӽ�ָ�����ڣ�2-ָ������֮ǰ
        // FSumBook    : IXLSWorkBook;
        procedure LoadDefine;
        { �������������У���һ���ڱ���Ԫֱ�ӷ���Excel�����ļ�������ĳ���ܱ��ʱ870ms���ڶ�������
          ͨ��IClientFuncs.GetLastPDDatas������ȡ���ݣ�������ͬ�Ļ��ܱ��ʱ3880ms }
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

    { �Զ��徲̬��������ṹ�� }
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
  Description: �ֽ��ֶζ��壬һ����ʽΪ{M01YBP.PD1.NAME }
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
    // ȥ��������
    i := Pos('}', S);
    if i > 0 then
        S := leftstr(S, Length(S) - 1);
    S := RightStr(S, Length(S) - 1);
    // �ֽ����.��
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
                { todo:���Ӷ�����ֵ���жϣ���EV���EV.MAX, EV.MAXDATE, EV.YEARMAX�ȵ� }
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
        else { todo:��������ʹ���������������PD�Ĺ��� }
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
    i := FDefineBook.WorkSheets.Index['���ܱ�����'];

    if i = -1 then
    begin
        ShowMessage('û���ҵ������ܱ����á�������������Ч�Ļ��ܱ��幤����');
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
    // �Ȳ��Ի�����̬��
    i := FDefineBook.WorkSheets.Index[lvwDefine.Selected.Caption];
    if i = -1 then
        exit;
    defSht := FDefineBook.WorkSheets.Entries[i];
    // ���洴��һ���¹���������defsht�������¹�������
    newBook := TXLSWorkbook.Create;
    newSht := newBook.WorkSheets.Add;
    newSht.Name := defSht.Name + '����������';

    if dlgSave.Execute then
        newBook.SaveAs(dlgSave.FileName)
    else
        newBook.SaveAs('e:\testout.xls');

    // ע�⣺����Ĵ����У���������Ҫ+1 ��������
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
                // ShowMessage(Format('��ʱ%d����', [System.DateUtils.MilliSecondsBetween(t2, t1)]));
                newBook.Save;
                newBook.Close; // ����ر��˻��ܱ�

                // �����򿪻��ܱ�
                if MessageDlg('���ܱ�������ϣ��Ƿ�򿪻��ܱ�', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
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

                if MessageDlg('���ܱ�������ϣ��Ƿ�򿪻��ܱ�', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
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
        if S = '�Զ��徲̬��' then
            LItem.SumType := stCustomStatic
        else if S = '�������ܱ�' then
            LItem.SumType := stBaseStatic
        else if S = '��̬�б�' then
            LItem.SumType := stDynRow
        else if S = '��̬�б�' then
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

        // ������
        LItem.DTCol := _GetIntValue(iRow, 8);
        // �Ƿ��ע����
        S := Trim(VarToStr(FDefineSheet.Cells[iRow, 9].Value));
        if S = '��' then
            LItem.ShowDate := True
        else
            LItem.ShowDate := False;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : MakeBaseStaticSummary
  Description: ���Դ���һ��������̬������ɹ�����ת�Ƶ�һ��ר�ŵĵ�Ԫȥ��
  ����
  ����������̬���Ѿ��ɹ�������������ת�Ƶ�ר�ŵĵ�Ԫȥ���������Ƹ��ּ�顢
  ֧��ѡ�����ڵȵȹ�����
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
        // UsedRange.LastRow+1��UsedRange�����һ�С�
        for i := datSht.UsedRange.LastRow + 3 downto AMeter.DataSheetStru.DTStartRow do
        begin
            S := Trim(VarToStr(datSht.Cells[i, 1].Value));
            // ���𣬿�ֵ�ͼ���
            if S = '' then
                Continue;
            // �ǿգ�����
            DTScale := VarToDateTime(datSht.Cells[i, 1].Value);
            // ȡ��ȫ����PDֵ
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
        DTScaleCol := DTCol; // ������
        bShowDT := ShowDate; // ��̬���ܱ����Ƿ�Ҫ��ʾ����
    end;

    datBook := TmyWorkbook.Create;
    try
        // ����ȡ���ܱ��е��������
        { todo:Ӧ�ð�ȡ�������ݵĴ�����뵽ר�ŵĵ�Ԫ���д����������������д���ܱ���ȡ���ݵ�
          ����Ӧ�úͱ���Ԫ�������Ӧ������ͬ������Դ�� }
        for iRow := dRow to SumSht.UsedRange.LastRow + 1 do
        begin
            ID := Trim(VarToStr(SumSht.Cells[iRow, 1].Value));

            if ID = '' then
                Continue;
            AMeter := ExcelMeters.Meter[ID];
            if AMeter = nil then
                Continue;

            // ȡ�����������ļ���������
            if datBook.FullName <> AMeter.DataBook then
            begin
                datBook.Close;
                datBook.Open(AMeter.DataBook);
            end;

            datSht := datBook.SheetByName(AMeter.DataSheet);
            if datSht = nil then
                Continue;

            // ��ȡ���һ�ι۲�����
            if GetData then
            begin
                for iCol := 0 to AMeter.DataSheetStru.PDs.Count - 1 do
                begin
                    if sValue[iCol] <> '' then
                        SumSht.Cells[iRow, iCol + dCol].Value := StrToFloat(sValue[iCol]);
                end;
            end;

            // �����Ҫ����������
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
    VarRecord : TDoubleDynArray; // ʹ��IClientFuncs.GetLastPDDatas����Ĳ���
begin
    with lvwDefine.Selected as TsdItem do
    begin
        dRow := DataStartRow;
        dCol := DataStartCol;
        DTScaleCol := DTCol; // ������
        bShowDT := ShowDate; // ��̬���ܱ����Ƿ�Ҫ��ʾ����
    end;

    IHJXClientFuncs.SessionBegin; // ����Session���Լ��ٴ򿪹ر�Excel�������Ĵ���
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
                    // �ж��Ƿ��ѯ���۲����ݣ�����������VarRecord[0]=0
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
                        // �ж��Ƿ��Ǻϲ�����������
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
  Description: �����Զ��徲̬��������
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
        // ����������һ������
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
    // �����ռ���Ҫ����ĵ�Ԫ�񣬷ֽ��������ݶ���
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
        // �����ѯ���ݣ�������

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
