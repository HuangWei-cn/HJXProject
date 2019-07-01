{ -----------------------------------------------------------------------------
  Unit Name: uHJX.Excel.DataQuery
  Author:    ��ΰ
  Date:      06-����-2017
  Purpose:   ���ݲ�ѯ��Ԫ-���Excel����Դ
  History:  2018-05-29~29
            ���Ӵ����������������ȡ���ܣ�Ŀǰ������ê���顣Ҫ����Ӧ������������
            ��ȡ����Ҫ��һ������

            2018-05-31
            1.���ӡ���ע���ֶε���ȡ��
            2.Ϊƽ��λ�Ʋ�������˹۲����ݱ��ͷ����(DBGridEh��ͷ)��
            3.�Ľ����ҵ�����¼�ķ�������_LocateDTRow�������ٲ���ָ���������ڵ��У�
            4.������ͼ�������ʾָ�����ڹ۲����ݵİ�ť�ͷ�����

            2018-06-14
            �����˲�ѯ���������������������Ĺ���
            2018-09-18
            ����ֵ��ѯ�������ʱ���������ֵ��ѯ���ܣ�����ֵ�������ˡ��������͡������
            ���
  ----------------------------------------------------------------------------- }

unit uHJX.Excel.DataQuery;

{ todo:GetLastPDDatas������û�з��ر�ע�ֶε����ݣ���ʱ��ע����ʮ����Ҫ }
{ todo:Ӧ������SessionBeginʱ����WorkBook Pool�����򿪹��ı�����������һ��ʹ��ʱֱ�ӵ��ã����ٴ��� }
{ todo:ע������ݿⷽ�����������Ӽ�ע���¼� }
{ todo:ע�������б���ظ����¼� }
{ todo:ע�������������¼����¼� }
interface

uses
  System.Classes, System.Types, System.SysUtils, System.Variants, System.StrUtils, Data.DB,
  Datasnap.DBClient, System.DateUtils, {MidasLib,}
  uHJX.Intf.Datas, uHJX.Excel.IO, uHJX.Data.Types, uHJX.Intf.AppServices;

type
    { �ƽ�Ͽ���ݲ�ѯ���� }
  ThjxDataQuery = class(TInterfacedObject, IClientFuncs)
  private
    FUseSession: Boolean;
  public
    destructor Destroy; override;
        { �����Ự }
        { todo:ʵ�������Ự�󴴽��򿪵Ĺ������أ�����Ҫ�򿪹�����ʱ�ȼ���Ƿ��Ѿ��򿪣�������
          û�У��Ŵ��������¹��������������ض��ھ�̬�����ͽ�Ϊ���ã����Դ����������ȡ���ݵ�ʱ�䡣 }
    procedure SessionBegin;
    procedure SessionEnd;
        { ȡ��ָ��������������һ�μ������ }
    function GetLastPDDatas(ADsnName: string; var Values: TDoubleDynArray): Boolean; overload;
    function GetLastPDDatas(ADsnName: string; var Values: TVariantDynArray): Boolean; overload;
        { ȡ��ָ��ʱ���ڼ�����������һ������ }
    function GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
      var Values: TDoubleDynArray): Boolean; overload;
    function GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
      var Values: TVariantDynArray): Boolean; overload;
        { ȡ����ӽ�ָ�����ڵĹ۲����� }
    function GetNearestPDDatas(ADsnName: String; DT: TDateTime; var Values: TDoubleDynArray;
      DTDelta: Integer = 0): Boolean; overload;
    function GetNearestPDDatas(ADsnName: String; DT: TDateTime; var Values: TVariantDynArray;
      DTDelta: Integer = 0): Boolean; overload;
        { ȡ��ָ��ʱ���ڼ���������й۲����� }
    function GetPDDatasInPeriod(ADsnName: string; DT1, DT2: TDateTime; DS: TDataSet): Boolean;
        { ȡ��ȫ���۲����� }
    function GetAllPDDatas(ADsnName: string; DS: TDataSet): Boolean;
        { ȡ��������ȫ���۲����ݣ�ע�����������ݼ����ֶ�����ʽ: ��Ʊ��.�������� }
    function GetGroupAllPDDatas(AGrpName: string; DS: TDataSet): Boolean;
        { ȡ��������ָ��ʱ���ڵĹ۲����� }
    function GetGroupPDDatasInPeriod(AGrpName: string; DT1, DT2: TDateTime;
      DS: TDataSet): Boolean;
        { ȡ�ص�ǰ����ֵ�������������� }
    function GetEVData(ADsnName: String; EVData: PEVDataStru): Boolean; overload;
    function GetEVData(ADsnName: string; var EVDatas: TDoubleDynArray): Boolean; overload;
        { ȡ����������������������ֵ }
    function GetEVDatas(ADsnName: String; var EVDatas: PEVDataArray): Boolean;
        { ȡ��ָ��ʱ���ڵ�����ֵ }
    function GetEVDataInPeriod(ADsnName: string; DT1, DT2: TDateTime;
      var EVDatas: PEVDataArray): Boolean;
        { ȡ��ָ��ʱ���ڵĹ۲��� }
    function GetDataCount(ADsnName: string; DT1, DT2: TDateTime): Integer;
        { ����DataSet�ֶα���������Excel���������������Ӧ��洢��Excel�����ļ��У���ʼ������ʱ
          �Ѽ��ص�uHJX.Excel.Meters��Ԫ��DSNames������ }
    procedure SetFieldDisplayName(DS: TDataSet);
        { ���������������� }
    function GetMeterTypeName(ADsnName: string): string;
        { ����������������(��������б������)����������μ�������������������ֵValues�������μ��ӿ�
          ������ע�� }
    function GetDataIncrement(ADsnName: string; DT: TDateTime;
      var Values: TVariantDynArray): Boolean;
  end;

procedure RegistClientDatas;

implementation

uses
    {uHJX.Excel.Meters} uHJX.Classes.Meters, nExcel;

type
  TDateLocateOption = (dloEqual, dloBefore, dloAfter, dloClosest); // ���ڲ�ѯ��λѡ����ڣ�֮ǰ��֮����ӽ�

var
  SSWorkBook: IXLSWorkBook; // �Ự�ڼ�ʹ�õ�Workbook

{ -----------------------------------------------------------------------------
  Procedure  : _GetFloatOrNull
  Description: ���ظ���������NULL
----------------------------------------------------------------------------- }
function _GetFloatOrNull(ASht: IXLSWorksheet; ARow, ACol: Integer): Variant;
begin
  Result := Null;
  if VarIsFloat(ASht.Cells[ARow, ACol].Value) then
      Result := ASht.Cells[ARow, ACol].Value;
end;

{ ���������Ĺ���������������� }
function _GetMeterSheet(ADsnName: string; var AWBK: IXLSWorkBook; var ASht: IXLSWorksheet;
  UseSession: Boolean = True): Boolean;
var
  Meter: TMeterDefine;
begin
  Result := False;
    // AWBK := nil;
    // ASHT := nil;
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;
  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;
    { todo:���������жϣ����AWBK���������Ĺ��������������پ����򿪵Ĳ����� }
  if UseSession then
      AWBK := SSWorkBook
  else if not Assigned(AWBK) then
      AWBK := TmyWorkbook.Create;

  if TmyWorkbook(AWBK).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(AWBK, Meter.DataBook) then
        Exit;

  ASht := ExcelIO.GetSheet(AWBK, Meter.DataSheet);
  if ASht = nil then
      Exit;

    { �ߵ�������Է���True�� }
  Result := True;
end;

{ ���ٶ�λָ���������ڵ��У�����ӽ������������У�����ֵΪ������
    ������
    StartRow:       ����������ʼ�У�Ҳ�ǲ��ҵ���ʼ�У�
    LacateOption:   0:������ڸ����ڣ�1:�����ڵ�ǰһ����2:��ӽ������ڣ�����ǰ��
}
function _LocateDTRow(Sheet: IXLSWorksheet; DT: TDateTime; DTStartRow: Integer;
  LocateOption: TDateLocateOption = dloEqual): Integer;
var
  DT1, DT2    : TDateTime;
  d1, d2      : Integer;
  iRow        : Integer;
  iStart, iEnd: Integer;
// Delta       : Integer;
  S: string;
    { �ݹ��ѯ }
  function _Locate(StartRow, EndRow: Integer): Integer;
  begin
    IAppServices.ProcessMessages;
    Result := -1;
        // ����StartRow=EndRow, EndRow-StartRow=1�����
        // ��ֹ�������ڣ�����û�ҵ�����ѡ��ӽ���
    if EndRow - StartRow <= 1 then
    begin
      DT1 := ExcelIO.GetDateTimeValue(Sheet, StartRow, 1);
      DT2 := ExcelIO.GetDateTimeValue(Sheet, EndRow, 1);
            // ����Optionѡ�����
            // ���뾫ȷ��ȣ���û���ҵ�
      case LocateOption of
        dloEqual:
          Exit;
        dloBefore:
          begin
            Result := StartRow;
            Exit;
          end;
        dloAfter:
          begin
            Result := EndRow;
            Exit;
          end;
        dloClosest:
          begin
                        // ��ӽ�ָ�����ڵ�����
                        // ���ֵ
            d1 := DaysBetween(DT1, DT);
            d2 := DaysBetween(DT, DT2);
            if d1 < d2 then
                Result := StartRow
            else
                Result := EndRow;
          end;
      end;
      Exit;
    end;

        // ��StartRow��EndRowѡ�м���
    iRow := (StartRow + EndRow) div 2;
    DT1 := ExcelIO.GetDateTimeValue(Sheet, iRow, 1);
    if DT1 = DT then
    begin
      Result := iRow;
      Exit;
    end;

        // �Ƚ�DT1��DT����������StartRow��EndRow,����
    if DT1 < DT then
        StartRow := iRow
    else
        EndRow := iRow;
        // �ݹ飬����
    Result := _Locate(StartRow, EndRow);
  end;

begin
  Result := -1;
  if Sheet = nil then
      Exit;
  iStart := DTStartRow;
  iEnd := Sheet.UsedRange.LastRow + 2;

    // �ж�5���������:û���ݣ���ʼ��Ϊ�������ֹ��Ϊ���, ������ʼ�У����ڽ�ֹ��
    // 1. û����
  if iEnd < iStart then
      Exit;

    // 2. ��ʼ�е��ڸ����ڣ�����ʼ������Ϊ�����˳�����ͬ��û����
  S := trim(ExcelIO.GetStrValue(Sheet, iStart, 1));
  if S = '' then
      Exit;

  DT1 := StrToDateTime(S);
  if DT1 = DT then
  begin
    Result := iStart;
    Exit;
  end;

    // 3. ������ʼ�У�������֮�������ӽ�������ʼ�У������˳�
  if DT1 > DT then
    if LocateOption in [dloAfter, dloClosest] then
    begin
      Result := iStart;
      Exit;
    end
    else
        Exit;

    // 4. ��ֹ�е��ڸ�������
    // ���������У��ҵ����һ�����ݣ�ȡ���������
  for iRow := iEnd downto iStart do
  begin
    IAppServices.ProcessMessages;
    S := trim(ExcelIO.GetStrValue(Sheet, iRow, 1));
    if S = '' then
        Continue
    else
        Break;
  end;
  DT2 := StrToDateTime(S);
  if DT2 = DT then
  begin
    Result := iRow;
    Exit;
  end;

    // 5. ���ڽ�ֹ��
  if DT > DT2 then
    if LocateOption in [dloBefore, dloClosest] then // ����ǰ��ӽ�
    begin
      Result := iRow;
      Exit;
    end
    else
        Exit;
    // ����5����������ڣ�������ʵʵ�ز��Ұɣ�
  if iEnd <> iRow then
      iEnd := iRow;
  Result := _Locate(iStart, iEnd);
end;

// �������������崴���ֶα�
procedure _CreateFieldsFromPDDefines(DS: TDataSet; APDDefines: TDataDefines);
var
  i : Integer;
  DF: TFieldDef;
begin
  TClientDataSet(DS).FieldDefs.Clear;
  TClientDataSet(DS).IndexDefs.Clear;

    // �۲������ֶ�
  DF := DS.FieldDefs.AddFieldDef;
  DF.Name := 'DTScale';
  DF.DataType := ftDateTime;
  DF.DisplayName := '�۲�����';
    // �������ֶ�
  for i := 0 to APDDefines.Count - 1 do
  begin
    DF := DS.FieldDefs.AddFieldDef;
    DF.Name := 'PD' + IntToStr(i + 1);
    DF.DisplayName := APDDefines.Items[i].Name;
    DF.DataType := ftFloat;
  end;
    // ��ע�ֶ�
  DF := DS.FieldDefs.AddFieldDef;
  DF.Name := 'Annotation';
  DF.DisplayName := '��ע';
  DF.DataType := ftWideString;

  TClientDataSet(DS).IndexDefs.Add('IndexDT', 'DTScale', []);
end;

// �����ֶ�displaylabel
procedure _SetFieldsDisplayName(DS: TDataSet; APDDefines: TDataDefines);
var
  i: Integer;
begin
  with DS as TClientDataSet do
  begin
    Fields[0].DisplayLabel := '�۲�����';
    for i := 0 to APDDefines.Count - 1 do
    begin
      Fields[i + 1].DisplayLabel := APDDefines.Items[i].Name;
      if Fields[i + 1].DataType = ftFloat then
        (Fields[i + 1] as TNumericField).DisplayFormat := '0.00';
    end;
        // ������һ���ֶ���ΪAnnotation����Ϊ��ע�ֶ�
    with Fields[Fields.Count - 1] do
      if Name = 'Annotation' then
          DisplayLabel := '��ע';
  end;
end;

// ���������鶨�崴�����ݼ��ֶ�
procedure _CreateFieldsFromGroup(DS: TDataSet; AGroup: TMeterGroupItem);
var
  i, j: Integer;
  DF  : TFieldDef;
  MT  : TMeterDefine;
begin
  TClientDataSet(DS).FieldDefs.Clear;
  TClientDataSet(DS).IndexDefs.Clear;

  DF := DS.FieldDefs.AddFieldDef;
  DF.Name := 'DTScale';
  DF.DataType := ftDateTime;
  DF.DisplayName := '�۲�����';
  for i := 0 to AGroup.Count - 1 do
  begin
    MT := ExcelMeters.Meter[AGroup.Items[i]];
    for j := 0 to MT.DataSheetStru.PDs.Count - 1 do
    begin
      DF := DS.FieldDefs.AddFieldDef;
      DF.Name := Format('%s.PD%d', [MT.DesignName, j + 1]);
      DF.DataType := ftFloat;
    end;
  end;
    { DONE:���ӱ�ע�ֶ� }
  DF := DS.FieldDefs.AddFieldDef;
  DF.Name := 'Annotation';
  DF.DataType := ftString;
  DF.DisplayName := '��ע';
    // ���������ֶ�
  TClientDataSet(DS).IndexDefs.Add('IndexDT', 'DTScale', []);
end;

procedure _SetGroupFieldsDisplayName(DS: TDataSet; AGroup: TMeterGroupItem);
var
  i, j, n: Integer;
// fld    : TField;
  MT: TMeterDefine;
begin
  with DS as TClientDataSet do
  begin
    Fields[0].DisplayLabel := '�۲�����';
    Fields[Fields.Count - 1].DisplayLabel := '��ע';
    n := 1;
    for i := 0 to AGroup.Count - 1 do
    begin
      MT := ExcelMeters.Meter[AGroup.Items[i]];
      for j := 0 to MT.DataSheetStru.PDs.Count - 1 do
      begin
        Fields[n].DisplayLabel :=
          Format('%s|%s', [MT.DesignName, MT.DataSheetStru.PDs.Items[j].Name]);
        if Fields[n].DataType = ftFloat then
          (Fields[n] as TNumericField).DisplayFormat := '0.00';
        inc(n);
      end;
    end;
  end;
end;

destructor ThjxDataQuery.Destroy;
begin
  inherited;
end;

procedure ThjxDataQuery.SessionBegin;
begin
  FUseSession := True;
  SSWorkBook := TmyWorkbook.Create;
end;

procedure ThjxDataQuery.SessionEnd;
begin
  SSWorkBook := nil;
  FUseSession := False;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetLastPDDatas
  Description: ȡ�����һ�ι۲����ݣ��������������ؽ������Ϊ�����ڡ�������
  ���飬����������˫���ȱ�ʾ
  ----------------------------------------------------------------------------- }
function ThjxDataQuery.GetLastPDDatas(ADsnName: string; var Values: TDoubleDynArray): Boolean;
var
  Meter    : TMeterDefine;
  wbk      : IXLSWorkBook;
  sht      : IXLSWorksheet;
  iCount, i: Integer;
  iRow     : Integer;
  S        : String;
begin
  Result := False;
  SetLength(Values, 0);
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then Exit;

  if FUseSession then wbk := SSWorkBook
  else wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then Exit;

  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then Exit;

  iCount := Meter.PDDefines.Count + 1; // ������+�۲�����
  SetLength(Values, iCount);
  Values[0] := 0; // �۲���������Ϊ0����û�����ݣ������룬������ͨ���۲������Ƿ�Ϊ0�ж��Ƿ��й۲����ݡ�

    // ���濪ʼ�����������
  for iRow := sht.UsedRange.LastRow + 5 downto Meter.DataSheetStru.DTStartRow do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then Continue;
        // �۲�����
    Values[0] := ExcelIO.GetDateTimeValue(sht, iRow, 1);

        // ��ע ����Values��Double�������飬�޷����뱸ע
        { with Meter.DataSheetStru do
            if AnnoCol > 0 then
                Values[iCount - 1] := ExcelIO.GetStrValue(sht, iRow, Meter.DataSheetStru.AnnoCol); }

        // ����������
    for i := 0 to Meter.PDDefines.Count - 1 do
        Values[i + 1] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
    Break;
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetLastPDDatas
  Description: �������һ�ι۲����ݣ���ʽΪ������+���������顱����������ΪVariant��
  �����ݺϷ���Ϊ˫������ֵ������ΪNULL��
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetLastPDDatas(ADsnName: string; var Values: TVariantDynArray): Boolean;
var
  Meter    : TMeterDefine;
  wbk      : IXLSWorkBook;
  sht      : IXLSWorksheet;
  iCount, i: Integer;
  iRow     : Integer;
  S        : String;
begin
  Result := False;
  for i := Low(Values) to High(Values) do VarClear(Values[i]);
  SetLength(Values, 0);

  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then Exit;

  if FUseSession then wbk := SSWorkBook
  else wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then Exit;

  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then Exit;

  iCount := Meter.PDDefines.Count + 1; // ������+�۲�����
  SetLength(Values, iCount);
  Values[0] := 0; // �۲���������Ϊ0����û�����ݣ������룬������ͨ���۲������Ƿ�Ϊ0�ж��Ƿ��й۲����ݡ�

    // ���濪ʼ�����������
  for iRow := sht.UsedRange.LastRow + 5 downto Meter.DataSheetStru.DTStartRow do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then Continue;
        // �۲�����
    Values[0] := ExcelIO.GetDateTimeValue(sht, iRow, 1);

        // ��ע ����Values��Double�������飬�޷����뱸ע
        { with Meter.DataSheetStru do
            if AnnoCol > 0 then
                Values[iCount - 1] := ExcelIO.GetStrValue(sht, iRow, Meter.DataSheetStru.AnnoCol); }

        // ����������
    for i := 0 to Meter.PDDefines.Count - 1 do
        Values[i + 1] := _GetFloatOrNull(sht, iRow, Meter.PDColumn(i));
        // Values[i + 1] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
    Break;
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetLastPDDatasInPeriod
  Description: ȡ��ָ��ʱ�������һ�ι۲�����
  ----------------------------------------------------------------------------- }
function ThjxDataQuery.GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
  var Values: TDoubleDynArray): Boolean;
var
  Meter    : TMeterDefine;
  wbk      : IXLSWorkBook;
  sht      : IXLSWorksheet;
  iCount, i: Integer;
  iRow     : Integer;
// S        : String;
// DT1      : TDateTime;
begin
  Result := False;
  SetLength(Values, 0);
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;

  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;

  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

  iCount := Meter.PDDefines.Count + 1; // ������+�۲�����+��ע
  SetLength(Values, iCount);
  Values[0] := 0; // �۲���������Ϊ0����û�����ݣ������룬������ͨ���۲������Ƿ�Ϊ0�ж��Ƿ��й۲����ݡ�
  iRow := _LocateDTRow(sht, DT, Meter.DataSheetStru.DTStartRow, dloBefore);
  if (iRow <> -1) and (iRow > Meter.DataSheetStru.DTStartRow) then
  begin
    Dec(iRow); // ��һ��
    Values[0] := ExcelIO.GetDateTimeValue(sht, iRow, 1);
    for i := 0 to Meter.PDDefines.Count - 1 do
        Values[i + 1] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
  end
  else
      Exit;

// for iRow := sht.UsedRange.LastRow + 1 downto Meter.DataSheetStru.DTStartRow do
// begin
// S := Trim(VarToStr(sht.Cells[iRow, 1].value));
// if S = '' then
// Continue;
//
// if TryStrToDateTime(S, DT1) = False then
// Continue; // ���ʱ���ַ�����Ч������������¼
//
// if DT1 > DT then
// Continue;
//
// Values[0] := ExcelIO.GetDateTimeValue(sht, iRow, 1); // �۲�����
// { with Meter.DataSheetStru do
// if AnnoCol > 0 then
// Values[iCount - 1] := ExcelIO.GetStrValue(sht, iRow, Meter.DataSheetStru.AnnoCol); }
//
// for i := 0 to Meter.PDDefines.Count - 1 do
// Values[i + 1] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
// Break;
//
// end;

  Result := True;
end;

function ThjxDataQuery.GetLastPDDatasBeforeDate(ADsnName: string; DT: TDateTime;
  var Values: TVariantDynArray): Boolean;
var
  Meter    : TMeterDefine;
  wbk      : IXLSWorkBook;
  sht      : IXLSWorksheet;
  iCount, i: Integer;
  iRow     : Integer;
// S        : String;
// DT1      : TDateTime;
begin
  Result := False;
  for i := Low(Values) to High(Values) do VarClear(Values[i]);
  SetLength(Values, 0);
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;

  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;

  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

  iCount := Meter.PDDefines.Count + 1; // ������+�۲�����+��ע
  SetLength(Values, iCount);
  Values[0] := 0; // �۲���������Ϊ0����û�����ݣ������룬������ͨ���۲������Ƿ�Ϊ0�ж��Ƿ��й۲����ݡ�
  iRow := _LocateDTRow(sht, DT, Meter.DataSheetStru.DTStartRow, dloBefore);
  if (iRow <> -1) and (iRow > Meter.DataSheetStru.DTStartRow) then
  begin
    Dec(iRow); // ��һ��
    Values[0] := ExcelIO.GetDateTimeValue(sht, iRow, 1);
    for i := 0 to Meter.PDDefines.Count - 1 do
        Values[i + 1] := _GetFloatOrNull(sht, iRow, Meter.PDColumn(i));
        // Values[i + 1] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
  end
  else
      Exit;

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetNearestPDDatas
  Description: ȡ����ӽ�ָ�����ڵĹ۲����ݣ�ʱ���ǰ�ɺ�
  ----------------------------------------------------------------------------- }
{ DONE:Ӧ���ø�������ݲ��ҷ�ʽ�����Ǵӵ�һ��һֱ�ҵ���� }
function ThjxDataQuery.GetNearestPDDatas(ADsnName: string; DT: TDateTime;
  var Values: TDoubleDynArray;
  DTDelta: Integer = 0): Boolean;
var
  Meter      : TMeterDefine;
  wbk        : IXLSWorkBook;
  sht        : IXLSWorksheet;
  iCount     : Integer;
  iRow, iLRow: Integer;
// S           : String;
  DT1         : TDateTime;
  dLast, dThis: double;

  procedure SetData(ARow: Integer);
  var
    ii: Integer;
  begin
    Values[0] := ExcelIO.GetDateTimeValue(sht, ARow, 1);
        { with Meter.DataSheetStru do
            if AnnoCol > 0 then
                Values[iCount - 1] := ExcelIO.GetStrValue(sht, ARow, AnnoCol); }

    for ii := 0 to Meter.PDDefines.Count - 1 do
        Values[ii + 1] := ExcelIO.GetFloatValue(sht, ARow, Meter.PDColumn(ii));
  end;

begin
  Result := False;
  SetLength(Values, 0);
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;

  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;

  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

  iCount := Meter.PDDefines.Count + 1; // ������+�۲�����+��ע
  SetLength(Values, iCount);
  Values[0] := 0; // �۲���������Ϊ0����û�����ݣ������룬������ͨ���۲������Ƿ�Ϊ0�ж��Ƿ��й۲����ݡ�
    // �������
  dLast := -10000;
  dThis := 10000;
  iLRow := 0;

  iRow := _LocateDTRow(sht, DT, Meter.DataSheetStru.DTStartRow, dloClosest);
  if iRow = -1 then
      Exit;

  DT1 := ExcelIO.GetDateTimeValue(sht, iRow, 1);
  if DTDelta <> 0 then // ������޲�ҳ��ޣ����˳�
  begin
    dLast := Abs(DaysBetween(DT1, DT));
    if dLast > DTDelta then
        Exit;
  end;

  SetData(iRow);

  Result := True;
end;

function ThjxDataQuery.GetNearestPDDatas(ADsnName: string; DT: TDateTime;
  var Values: TVariantDynArray; DTDelta: Integer = 0): Boolean;
var
  Meter      : TMeterDefine;
  wbk        : IXLSWorkBook;
  sht        : IXLSWorksheet;
  iCount, i  : Integer;
  iRow, iLRow: Integer;
// S           : String;
  DT1         : TDateTime;
  dLast, dThis: double;

  procedure SetData(ARow: Integer);
  var
    ii: Integer;
  begin
    Values[0] := ExcelIO.GetDateTimeValue(sht, ARow, 1);
        { with Meter.DataSheetStru do
            if AnnoCol > 0 then
                Values[iCount - 1] := ExcelIO.GetStrValue(sht, ARow, AnnoCol); }

    for ii := 0 to Meter.PDDefines.Count - 1 do
        Values[ii + 1] := { ExcelIO.GetFloatValue } _GetFloatOrNull(sht, ARow, Meter.PDColumn(ii));
  end;

begin
  Result := False;
  for i := low(Values) to high(Values) do VarClear(Values[i]);
  SetLength(Values, 0);
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;

  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;

  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

  iCount := Meter.PDDefines.Count + 1; // ������+�۲�����+��ע
  SetLength(Values, iCount);
  Values[0] := 0; // �۲���������Ϊ0����û�����ݣ������룬������ͨ���۲������Ƿ�Ϊ0�ж��Ƿ��й۲����ݡ�
    // �������
  dLast := -10000;
  dThis := 10000;
  iLRow := 0;

  iRow := _LocateDTRow(sht, DT, Meter.DataSheetStru.DTStartRow, dloClosest);
  if iRow = -1 then
      Exit;

  DT1 := ExcelIO.GetDateTimeValue(sht, iRow, 1);
  if DTDelta <> 0 then // ������޲�ҳ��ޣ����˳�
  begin
    dLast := Abs(DaysBetween(DT1, DT));
    if dLast > DTDelta then
        Exit;
  end;

  SetData(iRow);

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetPDDatasInPeriod
  Description: ȡ��ָ��ʱ���ڵĹ۲�����
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetPDDatasInPeriod(ADsnName: string; DT1: TDateTime; DT2: TDateTime;
  DS: TDataSet): Boolean;
var
  wbk    : IXLSWorkBook;
  sht    : IXLSWorksheet;
  Meter  : TMeterDefine;
  S      : string;
  iRow, i: Integer;
  DT     : TDateTime;
  AnnoCol: Integer;
begin
  Result := False;
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;
  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;

  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if ExcelIO.OpenWorkbook(wbk, Meter.DataBook) = False then
      Exit;
  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;
    // ���е�������Գ��Դ���DataSet����ȡ������
    // ���DSΪ�գ��򴴽�֮
  if DS = nil then
      DS := TClientDataSet.Create(nil)
  else
  begin
    if DS.Active then
        DS.Close;
    DS.FieldDefs.Clear;
  end;
    // ��DS������ֶ�
  _CreateFieldsFromPDDefines(DS, Meter.PDDefines);
    { ����Ҫע�⣬����ʹ��TClientDataset������ }
  TClientDataSet(DS).CreateDataSet;
  _SetFieldsDisplayName(DS, Meter.PDDefines);

  if Meter.DataSheetStru.AnnoCol > 0 then
      AnnoCol := Meter.DataSheetStru.AnnoCol
  else AnnoCol := 0;

  for iRow := Meter.DataSheetStru.DTStartRow to sht.UsedRange.LastRow + 1 do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
    if TryStrToDateTime(S, DT) = False then
        Continue;

    if DT > DT2 then
        Break;

    if DT >= DT1 then
    begin
            // ---------------------
      DS.Append;
            // �۲�����
      DS.Fields[0].Value := StrToDateTime(S);
            // ��ע
      if AnnoCol > 0 then
          DS.Fields[DS.Fields.Count - 1].Value := ExcelIO.GetStrValue(sht, iRow, AnnoCol);
            // ������
      for i := 0 to Meter.PDDefines.Count - 1 do
          DS.Fields[i + 1].Value := _GetFloatOrNull(sht, iRow, Meter.PDColumn(i));
          // DS.Fields[i + 1].Value := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
      DS.Post;
    end;
  end;
  Result := True;
end;

function ThjxDataQuery.GetAllPDDatas(ADsnName: string; DS: TDataSet): Boolean;
var
  wbk    : IXLSWorkBook;
  sht    : IXLSWorksheet;
  Meter  : TMeterDefine;
  S      : string;
  iRow, i: Integer;
  AnnoCol: Integer;
  function __GetFloatValue(iRow, iCol: Integer): Variant;
  var
    sVar: String;
    d   : double;
  begin
    Result := Null;
      // sht.Cells[irow,icol].Value
    if VarIsFloat(sht.Cells[iRow, iCol].Value) then Result := sht.Cells[iRow, iCol].Value;
  end;

begin
  Result := False;
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;
  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;

  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if ExcelIO.OpenWorkbook(wbk, Meter.DataBook) = False then
      Exit;
  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;
    // ���е�������Գ��Դ���DataSet����ȡ������
    // ���DSΪ�գ��򴴽�֮
  if DS = nil then
      DS := TClientDataSet.Create(nil)
  else
  begin
    if DS.Active then
        DS.Close;
    DS.FieldDefs.Clear;
  end;
    // ��DS������ֶ�
  _CreateFieldsFromPDDefines(DS, Meter.PDDefines);
    { ����Ҫע�⣬����ʹ��TClientDataset������ }
  TClientDataSet(DS).CreateDataSet;
  _SetFieldsDisplayName(DS, Meter.PDDefines);

  if Meter.DataSheetStru.AnnoCol > 0 then
      AnnoCol := Meter.DataSheetStru.AnnoCol
  else AnnoCol := 0;

    // ��ѯ���������
  for iRow := Meter.DataSheetStru.DTStartRow to sht.UsedRange.LastRow + 2 do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
        // ---------------------
    DS.Append;
    DS.Fields[0].Value := StrToDateTime(S);
    if AnnoCol > 0 then
        DS.Fields[DS.Fields.Count - 1].Value := ExcelIO.GetStrValue(sht, iRow, AnnoCol);

    for i := 0 to Meter.PDDefines.Count - 1 do
        DS.Fields[i + 1].Value := __GetFloatValue(iRow, Meter.PDColumn(i));
          // { todo:BUG!!����Ԫ��û��ֵ������ֵʱ���˺���������0�������ǿ�ֵ }
          // DS.Fields[i + 1].value := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i));
    DS.Post;
  end;
  Result := True;
end;

type
  TevCheckDate = record
    theYear, theMon: Integer;
    dtYear1, dtYear2: TDateTime;
    dtMon1, dtMon2: TDateTime;
  end;

    { -----------------------------------------------------------------------------
      Procedure  : GetEVData   ���������ã���Ϊֻ���ص�һ��������������ֵ��
      Description: ���ҵ�ǰ����ֵ��ʱ��Ϊ���һ�ι۲�ʱ�䣬Ŀǰֻ�ܲ�ѯPD1������ֵ
      ���ڶ��λ�Ƽ�Ҳ����ˡ�
      ----------------------------------------------------------------------------- }
function ThjxDataQuery.GetEVData(ADsnName: string; EVData: PEVDataStru): Boolean;
var
  Meter  : TMeterDefine;
  wbk    : IXLSWorkBook;
  sht    : IXLSWorksheet;
  chkDate: TevCheckDate;
  iRow   : Integer;
  S      : String;
  PD1    : double;
  dtScale: TDateTime;

  procedure SetDate(DT: TDateTime);
  begin
    chkDate.theYear := YearOf(DT);
    chkDate.theMon := MonthOf(DT);
    chkDate.dtYear1 := EncodeDate(chkDate.theYear, 1, 1);
    chkDate.dtYear2 := EndOfAYear(chkDate.theYear);
    chkDate.dtMon1 := EncodeDate(chkDate.theYear, chkDate.theMon, 1);
    chkDate.dtMon2 := EndOfAMonth(chkDate.theYear, chkDate.theMon);
  end;

begin
  Result := False;
  EVData.Init;
  chkDate.dtYear1 := 0;
  chkDate.dtMon1 := 0;
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;
  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;
  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;
  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

    { set date for check }
  EVData.ID := Meter.DesignName;
  for iRow := sht.UsedRange.LastRow + 2 downto Meter.DataSheetStru.DTStartRow do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
    if TryStrToDateTime(S, dtScale) = False then
        Continue;

    PD1 := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(0));

        { �ж��Ƿ�������CheckDate������������֮����ʱ�������һ����¼ }
    if chkDate.dtMon1 = 0 then
    begin
      SetDate(dtScale);
            { ��ǰֵ }
      EVData.CurValue := PD1;
      EVData.CurDate := dtScale;
    end;

        { LeftEV }
    EVData.LifeEV.CompareData(dtScale, PD1);

        { YearEV }
    if YearOf(dtScale) = chkDate.theYear then
    begin
      EVData.YearEV.CompareData(dtScale, PD1);
            { MonthEV }
      if MonthOf(dtScale) = chkDate.theMon then
          EVData.MonthEV.CompareData(dtScale, PD1);
    end;
  end;

  Result := True;
end;

{ ���������� }
function ThjxDataQuery.GetEVData(ADsnName: string; var EVDatas: TDoubleDynArray): Boolean;
var
  EVData: PEVDataStru;
begin
  Result := False;
  SetLength(EVDatas, 0);
  New(EVData);
  try
    Result := GetEVData(ADsnName, EVData);
    if Result then
    begin
      SetLength(EVDatas, 14);
      with EVData.LifeEV do
      begin
        EVDatas[0] := MaxValue;
        EVDatas[1] := MaxDate;
        EVDatas[2] := MinValue;
        EVDatas[3] := MinDate;
      end;
      with EVData.YearEV do
      begin
        EVDatas[4] := MaxValue;
        EVDatas[5] := MaxDate;
        EVDatas[6] := MinValue;
        EVDatas[7] := MinDate;
      end;
      with EVData.MonthEV do
      begin
        EVDatas[8] := MaxValue;
        EVDatas[9] := MaxDate;
        EVDatas[10] := MinValue;
        EVDatas[11] := MinDate;
      end;
      EVDatas[12] := EVData.CurValue;
      EVDatas[13] := EVData.CurDate;
    end;
  finally
    Dispose(EVData);
  end;
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetEVDatas
  Description: �����������������о�������ֵ��������������ֵ
  ��GetEVData��ͬ��GetEVData�����ص�һ��������������ֵ������������������ֵ��
  ������������ֵ����Щ�����ж����������������λ�Ƽƣ�ÿ����㶼��Ҫ������
  ��ֵ��������һ���Խ���Щ��������ֵȫ��ȡ�ء�
  ----------------------------------------------------------------------------- }
function ThjxDataQuery.GetEVDatas(ADsnName: string; var EVDatas: PEVDataArray): Boolean;
var
  Meter  : TMeterDefine;
  i, n   : Integer;
  wbk    : IXLSWorkBook;
  sht    : IXLSWorksheet;
  chkDate: TevCheckDate;
  iRow   : Integer;
  S      : String;
  dtScale: TDateTime;
    // �ͷŵ������ṩ��evdatasռ�õ��ڴ棬��ͬ����������ֵ������ͬ
  procedure ReleaseEVDatas;
  var
    ii: Integer;
  begin
    if Length(EVDatas) > 0 then
      for ii := Low(EVDatas) to High(EVDatas) do
        try
          Dispose(EVDatas[ii]);
        except
        end;
    SetLength(EVDatas, 0);
  end;
  procedure SetDate(DT: TDateTime);
  begin
    chkDate.theYear := YearOf(DT);
    chkDate.theMon := MonthOf(DT);
    chkDate.dtYear1 := EncodeDate(chkDate.theYear, 1, 1);
    chkDate.dtYear2 := EndOfAYear(chkDate.theYear);
    chkDate.dtMon1 := EncodeDate(chkDate.theYear, chkDate.theMon, 1);
    chkDate.dtMon2 := EndOfAMonth(chkDate.theYear, chkDate.theMon);
  end;
  procedure FindEVData(iev: Integer);
  var
    d   : double;
    iCol: Integer;
  begin
    iCol := Meter.PDColumn(EVDatas[iev].PDIndex);
    d := ExcelIO.GetFloatValue(sht, iRow, iCol);

    EVDatas[iev].LifeEV.CompareData(dtScale, d);
    EVDatas[iev].LifeEV.Increment := EVDatas[iev].CurValue - d; // 2018-09-18 ����������

    if YearOf(dtScale) = chkDate.theYear then
    begin
      EVDatas[iev].YearEV.CompareData(dtScale, d);
      EVDatas[iev].YearEV.Increment := EVDatas[iev].CurValue - d; // 2018-09-18 ������
      if MonthOf(dtScale) = chkDate.theMon then
      begin
        EVDatas[iev].MonthEV.CompareData(dtScale, d);
        EVDatas[iev].MonthEV.Increment := EVDatas[iev].CurValue - d; // ������
      end;
    end;
  end;

begin
  Result := False;
  chkDate.theYear := 0;
  chkDate.theMon := 0;
    // ��Ҫ�ļ��ͳ�ʼ��
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;
  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;
  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

    // ��EVDatas�����ʼ�����ͷŶ�����ڴ�
  ReleaseEVDatas;
    // ����Meter��������ֵ��������������ʼ��EVDatas����
  n := 0;
  for i := 0 to Meter.PDDefines.Count - 1 do
    if Meter.PDDefine[i].HasEV then
    begin
      inc(n);
      SetLength(EVDatas, n);
      New(EVDatas[n - 1]);
      EVDatas[n - 1].Init;
      EVDatas[n - 1].PDIndex := i;
      EVDatas[n - 1].ID := ADsnName;
    end;

  for iRow := sht.UsedRange.LastRow + 1 downto Meter.DataSheetStru.DTStartRow do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
    if TryStrToDateTime(S, dtScale) = False then
        Continue;
        // ���û������ʱ�䣬���������ã��������һ����¼��ʱ����Ϊ������������ֵͳ��ʱ��
    if chkDate.theYear = 0 then
    begin
      SetDate(dtScale); // ��ʼ��ʱ������
            // ���õ�ǰֵ
      for i := 0 to High(EVDatas) do
      begin
        EVDatas[i].CurDate := dtScale;
        { todo:��ֵ�Ϸ����ж� }
        EVDatas[i].CurValue := ExcelIO.GetFloatValue(sht, iRow,
          Meter.PDColumn(EVDatas[i].PDIndex));
      end;
    end;
        //
    for i := 0 to High(EVDatas) do
        FindEVData(i);
  end;

    // 2018-09-18���
  for i := 0 to High(EVDatas) do
    with EVDatas[i]^ do
    begin
      LifeEV.Amplitude := LifeEV.MaxValue - LifeEV.MinValue;
      YearEV.Amplitude := YearEV.MaxValue - YearEV.MinValue;
      MonthEV.Amplitude := MonthEV.MaxValue - MonthEV.MinValue;
    end;

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetEVDataInPeriod
  Description: ����ָ��ʱ���ڵ�����ֵ
  2018-09-17 �����ճ�GetEVDatas������ֻ�Ǹı��˲�ѯ��Χ���Ӳ�ѯȫ����Ϊֻ��ѯ
  ʱ���ڡ���һ�������������ϲ�Ϊһ����GetEVDatas���ñ��������ȫ�����ݲ�ѯ
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetEVDataInPeriod(ADsnName: string; DT1: TDateTime; DT2: TDateTime;
  var EVDatas: PEVDataArray): Boolean;
var
  Meter     : TMeterDefine;
  i, n      : Integer;
  wbk       : IXLSWorkBook;
  sht       : IXLSWorksheet;
  chkDate   : TevCheckDate;
  iRow      : Integer;
  Row1, Row2: Integer; // ָ��������ֹ��
  S         : String;
  dtScale   : TDateTime;
    // �ͷŵ������ṩ��evdatasռ�õ��ڴ棬��ͬ����������ֵ������ͬ
  procedure ReleaseEVDatas;
  var
    ii: Integer;
  begin
    if Length(EVDatas) > 0 then
      for ii := Low(EVDatas) to High(EVDatas) do
        try
          Dispose(EVDatas[ii]);
        except
        end;
    SetLength(EVDatas, 0);
  end;
  procedure SetDate(DT: TDateTime);
  begin
    chkDate.theYear := YearOf(DT);
    chkDate.theMon := MonthOf(DT);
    chkDate.dtYear1 := EncodeDate(chkDate.theYear, 1, 1);
    chkDate.dtYear2 := EndOfAYear(chkDate.theYear);
    chkDate.dtMon1 := EncodeDate(chkDate.theYear, chkDate.theMon, 1);
    chkDate.dtMon2 := EndOfAMonth(chkDate.theYear, chkDate.theMon);
  end;
  procedure FindEVData(iev: Integer);
  var
    d   : double;
    iCol: Integer;
  begin
    iCol := Meter.PDColumn(EVDatas[iev].PDIndex);
    d := ExcelIO.GetFloatValue(sht, iRow, iCol);
    with EVDatas[iev]^ do
    begin
      LifeEV.CompareData(dtScale, d);
      LifeEV.Increment := CurValue - d;
      if YearOf(dtScale) = chkDate.theYear then
      begin
        YearEV.CompareData(dtScale, d);
        YearEV.Increment := CurValue - d;
        if MonthOf(dtScale) = chkDate.theMon then
        begin
          MonthEV.CompareData(dtScale, d);
          MonthEV.Increment := CurValue - d;
        end;
      end;
    end;
  end;

begin
  Result := False;
  chkDate.theYear := 0;
  chkDate.theMon := 0;
    // ��Ҫ�ļ��ͳ�ʼ��
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;

    { ������Ҫ�������������ֵ���ڱ�DT2�����Ͳ����� }
  if Meter.Params.BaseDate > DT2 then
      Exit;

  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;
  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;
  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;

    // ��EVDatas�����ʼ�����ͷŶ�����ڴ�
  ReleaseEVDatas;
    // ����Meter��������ֵ��������������ʼ��EVDatas����
  n := 0;
  for i := 0 to Meter.PDDefines.Count - 1 do
    if Meter.PDDefine[i].HasEV then
    begin
      inc(n);
      SetLength(EVDatas, n);
      New(EVDatas[n - 1]);
      EVDatas[n - 1].Init;
      EVDatas[n - 1].PDIndex := i;
      EVDatas[n - 1].ID := ADsnName;
    end;

    { ��GetEVDatas��ͬ�ĵط������ }
  Row1 := _LocateDTRow(sht, DT1, Meter.DataSheetStru.DTStartRow, dloClosest);
  Row2 := _LocateDTRow(sht, DT2, Meter.DataSheetStru.DTStartRow, dloBefore);
    // for iRow := sht.UsedRange.LastRow + 1 downto Meter.DataSheetStru.DTStartRow do
  for iRow := Row2 downto Row1 do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
    if TryStrToDateTime(S, dtScale) = False then
        Continue;
        // ���û������ʱ�䣬���������ã��������һ����¼��ʱ����Ϊ������������ֵͳ��ʱ��
    if chkDate.theYear = 0 then
    begin
      SetDate(dtScale); // ��ʼ��ʱ������
            // ���õ�ǰֵ
      for i := 0 to High(EVDatas) do
      begin
        EVDatas[i].CurDate := dtScale;
        { todo:�˴�Ӧ���ж����ݺϷ��� }
        EVDatas[i].CurValue := ExcelIO.GetFloatValue(sht, iRow,
          Meter.PDColumn(EVDatas[i].PDIndex));
      end;
    end;
        //
    for i := 0 to High(EVDatas) do
        FindEVData(i);
  end;

    // �������
  for i := 0 to high(EVDatas) do
    with EVDatas[i]^ do
    begin
      LifeEV.Amplitude := LifeEV.MaxValue - LifeEV.MinValue;
      YearEV.Amplitude := YearEV.MaxValue - YearEV.MinValue;
      MonthEV.Amplitude := MonthEV.MaxValue - MonthEV.MinValue;
    end;

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : SetFieldDisplayName
  Description: ������������Excel��������Ԥ������ֶ����������Ӧ�����DataSet
  �е��ֶ�DisplayLabel���ڱ���Ԫ�У������Ӧ��ȡ��Excel�����Զ��幤�����е��ֶ�
  �����ñ��ڼ��ز���ʱ�����أ����洢��uhjx.excel.meters��Ԫ�е�DSNames�����У�
  �ö�����һ��DispName�������ɸ����ֶ������ض�Ӧ��DisplayLabel��
  2018-05-31 �о��������û�ã�һ�����ɵ�ʱ���ֶ�������PD1,PD2..�ȵȣ�Ҫ�滻Ϊ
  �������ֶ�������Ҫ�����������е��ֶ���ȥ�滻
----------------------------------------------------------------------------- }
procedure ThjxDataQuery.SetFieldDisplayName(DS: TDataSet);
var
  i: Integer;
  S: string;
begin
  for i := 0 to DS.Fields.Count - 1 do
  begin
    S := DSNames.DispName(DS.Fields[i].FieldName);
    if S <> '' then
        DS.Fields[i].DisplayLabel := S;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetDataCount
  Description: ȡ��ָ��������ָ��ʱ����ڵĹ۲����ݵ��
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetDataCount(ADsnName: string; DT1: TDateTime; DT2: TDateTime): Integer;
var
  Meter  : TMeterDefine;
  wbk    : IXLSWorkBook;
  sht    : IXLSWorksheet;
  iRow   : Integer;
  S      : String;
  dtScale: TDateTime;
begin
  Result := 0;
  Meter := ExcelMeters.Meter[ADsnName];
    // ǰ��׼������-----------------------------
  if Meter = nil then
      Exit;
  if (Meter.DataBook = '') or (Meter.DataSheet = '') then
      Exit;
  if FUseSession then
      wbk := SSWorkBook
  else
      wbk := TmyWorkbook.Create;

  if TmyWorkbook(wbk).FullName <> Meter.DataBook then
    if not ExcelIO.OpenWorkbook(wbk, Meter.DataBook) then
        Exit;
  sht := ExcelIO.GetSheet(wbk, Meter.DataSheet);
  if sht = nil then
      Exit;
    // -------------------------------------------
  for iRow := Meter.DataSheetStru.DTStartRow to sht.UsedRange.LastRow + 1 do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(sht.Cells[iRow, Meter.DataSheetStru.DTStartCol].Value));
    if S = '' then
        Continue;
    if TryStrToDate(S, dtScale) then
      if (dtScale >= DT1) and (dtScale <= DT2) then
          inc(Result);
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetMeterTypeName
  Description: ���ؼ�������������ƣ��硰���λ�Ƽơ�����ê�������ơ�, etc.
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetMeterTypeName(ADsnName: string): string;
var
  Meter: TMeterDefine;
begin
  Result := '';
  Meter := ExcelMeters.Meter[ADsnName];
  if Meter = nil then
      Exit;
  Result := Meter.Params.MeterType;
end;

type
    // ���ṹ����ָ���������ڸ������Ĺ������͹�����
  TGroupMeterSheet = record
    DsnName: string;
    Meter: TMeterDefine;
    WbkBook: IXLSWorkBook;
    Sheet: IXLSWorksheet;
  end;

  PGroupMeterSheet = ^TGroupMeterSheet;
  PGroupSheets     = array of PGroupMeterSheet;

{ -----------------------------------------------------------------------------
  Procedure  : _PrepareGroupDataSet
  Description: Ԥ��������Ϊ��ȡ������׼��
  Ԥ�����ݣ�1������һ���ṹ���鱣��������������Ӧ�Ĺ������͹�����2����
  �������ݶ�Ӧ�Ĺ����������ع������͹��������3�����������ݼ��������ֶεȣ�
----------------------------------------------------------------------------- }
procedure _PrepareGroupDataSet(AGroup: TMeterGroupItem; var AGrpSheets: PGroupSheets;
  ADataSet: TDataSet);
var
  Meter: TMeterDefine;
  bwbk : Boolean;
  i, j : Integer;
begin
    // ��ÿ�������Ĺ������͹�����
  SetLength(AGrpSheets, AGroup.Count);
  for i := 0 to AGroup.Count - 1 do
  begin
    New(AGrpSheets[i]);
    AGrpSheets[i].DsnName := AGroup.Items[i];
    Meter := ExcelMeters.Meter[AGroup.Items[i]];
    AGrpSheets[i].Meter := Meter;
    if Meter = nil then
        Continue;
    bwbk := False;
        // ���ڵ�һ֧�������򿪹������͹�����
    if i = 0 then
    begin
      AGrpSheets[0].WbkBook := TmyWorkbook.Create;
      ExcelIO.OpenWorkbook(AGrpSheets[0].WbkBook, Meter.DataBook);
      AGrpSheets[0].Sheet := ExcelIO.GetSheet(AGrpSheets[0].WbkBook, Meter.DataSheet);
    end
    else // �����������������ͬ�������Ĺ������Ƿ���ͬ���������Ƿ���ͬ�������ͬ�����÷����
    begin
      for j := 0 to i do
      begin
        IAppServices.ProcessMessages;
        if TmyWorkbook(AGrpSheets[j].WbkBook).FullName = Meter.DataBook then
        begin
          AGrpSheets[i].WbkBook := AGrpSheets[j].WbkBook;
          bwbk := True; // ���й�����
          Break;
        end;
      end;
      if not bwbk then
      begin
        AGrpSheets[i].WbkBook := TmyWorkbook.Create;
        ExcelIO.OpenWorkbook(AGrpSheets[i].WbkBook, Meter.DataBook);
      end;
      AGrpSheets[i].Sheet := ExcelIO.GetSheet(AGrpSheets[i].WbkBook, Meter.DataSheet);
    end;
  end;

    // �������Ѿ�����ϣ��������ݼ�
  if ADataSet = nil then
      ADataSet := TClientDataSet.Create(nil)
  else
  begin
    if ADataSet.Active then
        ADataSet.Close;
    ADataSet.FieldDefs.Clear;
  end;

    // �������ݼ��ֶζ���
  _CreateFieldsFromGroup(ADataSet, AGroup);
  TClientDataSet(ADataSet).CreateDataSet;
  _SetGroupFieldsDisplayName(ADataSet, AGroup);
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetGroupAllPDDatas
  Description: ����������ȫ���۲�����
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetGroupAllPDDatas(AGrpName: string; DS: TDataSet): Boolean;
var
  GroupSheets: PGroupSheets;
  Group      : TMeterGroupItem;
  i, j, iRow : Integer;
  k, n       : Integer;
  S          : String;
begin
  Result := False;
  Group := MeterGroup.ItemByName[AGrpName];
  if Group = nil then
      Exit;
    // ׼�����������������������ݼ����������ݼ��ֶεȵ�׼������
  _PrepareGroupDataSet(Group, GroupSheets, DS);

    // ������ݼ�¼
    { todo:����������ͬ��������ͬ���������۲����ڿ����в������� }
    // 2018-05-29 Ϊ�ӿ쵼���۲����ݱ�Ĺ��ܣ�Ŀǰ���������������ȫ��������ͬ�Ĺ������У�
    // ��������ͬ�Ĺ۲����ڡ��������ʽĿǰ���ê��Ӧ��������Ч
  for iRow := GroupSheets[0].Meter.DataSheetStru.DTStartRow to GroupSheets[0]
    .Sheet.UsedRange.LastRow + 2 do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(GroupSheets[0].Sheet.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
    DS.Append;
    DS.Fields[0].Value := StrToDateTime(S); // DTScale������û���ж�S����ת������

        // ��ӵ�һ֧�����ı�ע
        { todo:����д�����鱸ע�ֶ�ʱ������������˵�һ֧�����ı�ע��û�п������������ı�ע�ֶ� }
    DS.Fields[DS.Fields.Count - 1].Value := ExcelIO.GetStrValue(GroupSheets[0].Sheet, iRow,
      GroupSheets[0].Meter.DataSheetStru.AnnoCol);

        // ��ӵ�һ֧�����۲�����
    for i := 0 to GroupSheets[0].Meter.PDDefines.Count - 1 do
        DS.Fields[i + 1].Value := _GetFloatOrNull(GroupSheets[0].Sheet, iRow,
        GroupSheets[0].Meter.PDColumn(i));
        // DS.Fields[i + 1].Value := ExcelIO.GetFloatValue(GroupSheets[0].Sheet, iRow,
        // GroupSheets[0].Meter.PDColumn(i));
    n := GroupSheets[0].Meter.PDDefines.Count + 1;
        // ������������۲����ݣ��������۲��¼����ͬһ�У���ʹ����ͬһ�Ź�����
    for j := 1 to High(GroupSheets) do
      for k := 0 to GroupSheets[j].Meter.PDDefines.Count - 1 do
      begin
        IAppServices.ProcessMessages;
        DS.Fields[n].Value := _GetFloatOrNull(GroupSheets[j].Sheet, iRow,
          GroupSheets[j].Meter.PDColumn(k));
        // DS.Fields[n].Value := ExcelIO.GetFloatValue(GroupSheets[j].Sheet, iRow,
        // GroupSheets[j].Meter.PDColumn(k));
        inc(n);
      end;
        // ȷ��
    DS.Post;
  end;

    // ��β����
  for i := 0 to High(GroupSheets) do
      Dispose(GroupSheets[i]);
  SetLength(GroupSheets, 0);
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetGroupPDDatasInPeriod
  Description: ������������ָ��ʱ���ڵĹ۲�����
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetGroupPDDatasInPeriod(AGrpName: string; DT1: TDateTime; DT2: TDateTime;
  DS: TDataSet): Boolean;
var
  GroupSheets: PGroupSheets;
  Group      : TMeterGroupItem;
  i, n, iMT  : Integer;
  iRow       : Integer;
  S          : string;
  DT         : TDateTime;
begin
  Result := False;
  Group := MeterGroup.ItemByName[AGrpName];
  if Group = nil then
      Exit;

    // ������׼������
  _PrepareGroupDataSet(Group, GroupSheets, DS);

    // �������
    // 2018-05-29 Ϊ�ӿ쵼���۲����ݱ�Ĺ��ܣ�Ŀǰ���������������ȫ��������ͬ�Ĺ������У�
    // ��������ͬ�Ĺ۲�����
    { todo:�迼�ǲ�ͬ����������ͬ���������� }
  for iRow := GroupSheets[0].Meter.DataSheetStru.DTStartRow to GroupSheets[0]
    .Sheet.UsedRange.LastRow + 2 do
  begin
    IAppServices.ProcessMessages;
    S := trim(VarToStr(GroupSheets[0].Sheet.Cells[iRow, 1].Value));
    if S = '' then
        Continue;
    if TryStrToDateTime(S, DT) = False then
        Continue;
    if DT >= DT2 then
        Break;
    if DT >= DT1 then
    begin
      DS.Append;
      DS.Fields[0].Value := StrToDateTime(S);

            // ��ӵ�һ֧�����ı�ע
            { todo:����д�����鱸ע�ֶ�ʱ������������˵�һ֧�����ı�ע��û�п������������ı�ע�ֶ� }
      DS.Fields[DS.Fields.Count - 1].Value := ExcelIO.GetStrValue(GroupSheets[0].Sheet, iRow,
        GroupSheets[0].Meter.DataSheetStru.AnnoCol);

            // ��Ӹ�����������
      n := 1;
      for iMT := 0 to High(GroupSheets) do // ����ѭ��
      begin
        IAppServices.ProcessMessages;
        for i := 0 to GroupSheets[iMT].Meter.PDDefines.Count - 1 do // �ֶ�ѭ��
        begin
          DS.Fields[n].Value := _GetFloatOrNull(GroupSheets[iMT].Sheet, iRow,
            GroupSheets[iMT].Meter.PDColumn(i));
          // DS.Fields[n].Value := ExcelIO.GetFloatValue(GroupSheets[iMT].Sheet, iRow,
          // GroupSheets[iMT].Meter.PDColumn(i));
          inc(n);
        end;
      end;
            // ȷ��
      DS.Post;
    end;
  end;
    // ��β����
  for i := 0 to High(GroupSheets) do
      Dispose(GroupSheets[i]);
  SetLength(GroupSheets, 0);
  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : GetDataIncrement
  Description: ��ѯָ��������ָ��ʱ�����������
  ������������ָ��ʱ���ֵ����һ�β�ֵ���������������������ݣ��������ݸ�ʽΪ
        ��������|�۲�����|�������|DTʱ�䵱ǰֵ|���������ֵ|������ֵ
  ����Values��Variant���Ͷ�̬���飬������Ϊê���ȵ�����������ʱ��ValuesΪ1��
  Ԫ�أ�������Ϊ����ƽ��λ�Ƶ�ʱ��Values��4������Ԫ�ء�ÿ��Ԫ����һ��
  VariantArray���ͣ�6Ԫ�أ���ʽΪ������������ݸ�ʽ��
----------------------------------------------------------------------------- }
function ThjxDataQuery.GetDataIncrement(ADsnName: string; DT: TDateTime;
  var Values: TVariantDynArray): Boolean;
var
  wbk        : IXLSWorkBook;
  sht        : IXLSWorksheet;
  Meter      : TMeterDefine;
  i, iDTStart: Integer;
  iRow, iDays: Integer; // �кţ��������
  iMonRow    : Integer; // �ϸ�������������
// S, pdName  : String;
  sType     : string;    // ��������
  d, d2, d30: double;    // ��ǰֵ��������������
  procedure ClearValues; // ������ʼ�������Values����
  var
    ii: Integer;
  begin
    if Length(Values) > 0 then
      for ii := Low(Values) to High(Values) do
          VarClear(Values[ii]);
    SetLength(Values, 0);
  end;

begin
  Result := False;
  ClearValues;                         // ����Values
  sType := GetMeterTypeName(ADsnName); // ��ȡ��������
  Meter := ExcelMeters.Meter[ADsnName];
  iDTStart := Meter.DataSheetStru.DTStartRow;

  if _GetMeterSheet(ADsnName, wbk, sht) = False then // �������������ݱ�
      Exit;

  iRow := _LocateDTRow(sht, DT, iDTStart, dloClosest); // �ҵ�ָ�����ڣ�����ӽ����������ڵ���
  if iRow = -1 then
      Exit;

  iMonRow := _LocateDTRow(sht, IncDay(DT, -30), iDTStart, dloClosest); // һ����ǰ����������

    // ���濪ʼȡ������
  if (sType = 'ê��������') or (sType = 'ê��Ӧ����') or (stype='��ѹ��') or (stype='���ұ��μ�') then
  begin
    SetLength(Values, 1);
    Values[0] := VarArrayCreate([0, 5], varVariant);
    Values[0][0] := Meter.pdName(0); // ��������
    Values[0][1] := ExcelIO.GetDateTimeValue(sht, iRow, 1); // �۲�����
    { TODO -oCharmer -c���ݲ�ѯ : �˴�Ӧ���ж����ݺϷ��� }
    Values[0][3] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(0)); // ��ǰֵ
    if iRow > iDTStart then // ����ǰ�в������У���������ϴμ���ֵ
    begin
      iDays := DaysBetween(ExcelIO.GetDateTimeValue(sht, iRow, 1),
        ExcelIO.GetDateTimeValue(sht, iRow - 1, 1));
      { todo:�˴�Ӧ���ж����ݺϷ��� }
      d := ExcelIO.GetFloatValue(sht, iRow - 1, Meter.PDColumn(0));
      d2 := Values[0][3] - d;
      d30 := Values[0][3] - ExcelIO.GetFloatValue(sht, iMonRow, Meter.PDColumn(0));
      Values[0][2] := iDays;
      Values[0][4] := d2;
      Values[0][5] := d30;
    end
    else
    begin
      Values[0][2] := 0;
      Values[0][4] := Null;
      Values[0][5] := Null;
    end;
  end
  else if (sType = '���λ�Ƽ�') then // Ŀǰֻ����4��ʽ���λ�Ƽ�
  begin
    SetLength(Values, 4);
    for i := 0 to 3 do
    begin
      Values[i] := VarArrayCreate([0, 5], varVariant);
      Values[i][0] := Meter.pdName(i);
      Values[i][1] := ExcelIO.GetDateTimeValue(sht, iRow, 1);
      { todo:�˴�������Ӧ���ж����ݺϷ��� }
      Values[i][3] := ExcelIO.GetFloatValue(sht, iRow, Meter.PDColumn(i)); // ��ǰֵ
      if iRow > iDTStart then
      begin
        iDays := DaysBetween(ExcelIO.GetDateTimeValue(sht, iRow, 1),
          ExcelIO.GetDateTimeValue(sht, iRow - 1, 1));
        d := ExcelIO.GetFloatValue(sht, iRow - 1, Meter.PDColumn(i));
        d2 := Values[i][3] - d;
        d30 := Values[i][3] - ExcelIO.GetFloatValue(sht, iMonRow, Meter.PDColumn(i));
        Values[i][2] := iDays;
        Values[i][4] := d2;
        Values[i][5] := d30;
      end
      else
      begin
        Values[i][2] := 0;
        Values[i][4] := Null;
        Values[i][5] := Null;
      end;
    end;
  end;

  Result := True;
end;

{ -----------------------------------------------------------------------------
  Procedure  : RegistClientDatas
  Description: ע�᱾���ݷ��ʶ���
----------------------------------------------------------------------------- }
procedure RegistClientDatas;
begin
  IAppServices.RegisterClientDatas(ThjxDataQuery.Create);
  IHJXClientFuncs := IAppServices.ClientDatas;
end;

initialization

RegistClientDatas;

end.
