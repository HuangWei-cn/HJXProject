{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Template.WebGridProc
 Author:    ��ΰ
 Date:      2018-09-02
 Purpose:   WebGridģ�崦��Ԫ
 ����Ԫ���������������õ�ָ��ģ���ϣ�����һ��WebGrid��HTML���롣����Ԫ��Ҫ����
 ģ�嵥Ԫ��Meters��Ԫ�����ݷ��ʶ���ȡ���ռλ���Ĵ����Ѿ���ֲ��һ�������ĵ�Ԫ��
 �ɣ�uHJX.Template.ProcSpecifiers.pas.

 ����Ԫ�Ĵ���ʽ������ֲ��Excel���ݱ�Ĵ�����Զ�̬�б�Ӧ���㹻�ˣ������ڣ�
 �����ñ�ģ���ʽ����ʾEhGrid�ı�ͷ��������ʾ��

 History:  2018-08-15 �����ɹ�������ʾê���������������ݲ�֧��������
            2018-08-16 ���Դ����������ˣ�ͬʱ��ģ��֧�ֵ��������ͽ��������ú�
            ��飬ģ��ֻ֧����ȷ���������͡�
----------------------------------------------------------------------------- }
{ done: ������ݸ�ʽ���Զ��ж������ǲ������ڻ�������ʱ�䣻���ݲ����Ҷ��� }
{ todo: ���������飬Ӧ֧�ֲ�ͬ�����ĸ�����������ǽ�����Meter1.DesignName }
{ todo: ֧������ʱ��� }
{ todo: GenGrid����ֵ�У�TitleӦ�ÿ�ѡ }
unit uHJX.Template.WebGridProc;

interface

uses
    System.Classes, System.SysUtils, System.DateUtils,

    uHJX.Intf.AppServices, uHJX.Intf.Datas, uHJX.Classes.Meters, uHJX.Classes.Templates,
    uHJX.Template.WebGrid;

{ ����ģ������ָ�����������ݱ�,WebGrid���� }
{ todo:����WebGrid���ݱ�Ӧ��ָ��ʱ��� }
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
        TempStr: string;   // ģ�嵥Ԫ������
        Specifier: string; // ռλ��
        Field: TField;     // ��Ӧ�ֶ�
        function GetValue: Variant;
    end;

function TWGDataCell.GetValue: Variant;
begin
    { todo:��Field���������ͣ���Ӧ�ж��Ƿ���Ҫ��ʾʱ�䡣����Ӧ����ʾ���ڡ� }
    if Field = nil then
        Result := TempStr
    else if Field.DataType = ftDateTime then
    begin
        // ���ֻ�����ڲ��֣����ʽΪyyyy-mm-dd��������ʱ�䲿�֣������ʱ��
        if DateOf(Field.AsDateTime) = Field.AsDateTime then
            Result := FormatDateTime('yyyy-mm-dd', Field.AsDateTime)
        else
            Result := FormatDateTime('yyyy-mm-dd hh:mm', Field.AsDateTime);
    end
    else
        Result := Field.Value;
end;

{ �������и�����Ԫ�����ݼ��ֶ���ϵ������Ϊ��һ����д������׼�� }
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
  Description: ���ݱ��ģ��ͼ�������������ɸ������Ĺ۲����ݱ�
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
    bGroup    : Boolean; // �ж��Ƿ��鴦��
    bGetData  : Boolean; // �ж��Ƿ�ɹ�ȡ������

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
    // ������������Ƿ��Ӧ
    if grdTemp.MeterType <> '' then
        if grdTemp.MeterType <> AMeter.Params.MeterType then
            raise Exception.CreateFmt('"%s"��֧��%s���������͡�ģ����������Ϊ%s����ǰ��������Ϊ%s',
                [grdTemp.TemplateName, AMeter.DesignName, grdTemp.MeterType,
                AMeter.Params.MeterType]);

    // ���ģ��֧�������飬������������ĳ���飬������鴦��
    if grdTemp.ApplyGroup and (AMeter.PrjParams.GroupID <> '') then
        bGroup := True;

    // ����Title, �����ǽ�ÿ���е�ռλ���滻Ϊ��Ӧ���������ԣ�����ռλ����ԭ�����
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
        // �����ͷ: ����ģ���ͷ��Ԫ�����ݣ��ò����滻ռλ��������������ӵ�WebCrossView��
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

        // ����������:
        // ȡ�ع۲����ݼ�
        DS := TClientDataSet.Create(nil);
        if bGroup then
            bGetData := IAppServices.ClientDatas.GetGroupAllPDDatas
                (AMeter.PrjParams.GroupID, DS)
        else
            bGetData := IAppServices.ClientDatas.GetAllPDDatas(AMeter.DesignName, DS);

        if bGetData then
        begin
            // ��������������
            SetLength(DR, grdTemp.ColCount);
            // ����ģ�壬���������е�Ԫ��
            __WGProcDataRow(grdTemp, AMeter, DR, DS, bGroup);
            // ����DR���ֶε��������������ж���
            SetColumnAlignment;
            // �������
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
    bGroup    : Boolean; // �ж��Ƿ��鴦��
    bGetData  : Boolean; // �ж��Ƿ�ɹ�ȡ������

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
    // ������������Ƿ��Ӧ
    if grdTemp.MeterType <> '' then
        if grdTemp.MeterType <> AMeter.Params.MeterType then
            raise Exception.CreateFmt('"%s"��֧��%s���������͡�ģ����������Ϊ%s����ǰ��������Ϊ%s',
                [grdTemp.TemplateName, AMeter.DesignName, grdTemp.MeterType,
                AMeter.Params.MeterType]);

    // ���ģ��֧�������飬������������ĳ���飬������鴦��
    if grdTemp.ApplyGroup and (AMeter.PrjParams.GroupID <> '') then
        bGroup := True;

    // ����Title, �����ǽ�ÿ���е�ռλ���滻Ϊ��Ӧ���������ԣ�����ռλ����ԭ�����
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
        // �����ͷ: ����ģ���ͷ��Ԫ�����ݣ��ò����滻ռλ��������������ӵ�WebCrossView��
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

        // ����������:
        // ȡ�ع۲����ݼ�
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
            // ��������������
            SetLength(DR, grdTemp.ColCount);
            // ����ģ�壬���������е�Ԫ��
            __WGProcDataRow(grdTemp, AMeter, DR, DS, bGroup);
            // ����DR���ֶε��������������ж���
            SetColumnAlignment;
            // �������
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
