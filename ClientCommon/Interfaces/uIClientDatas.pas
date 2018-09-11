{-----------------------------------------------------------------------------
 Unit Name: uIClientDatas
 Author:    Administrator
 Date:      08-ʮ����-2012
 Purpose:   ����һ���ӿڲ��ԣ������ܸ�ʲô
 History:
-----------------------------------------------------------------------------}

unit uIClientDatas;

interface
uses
    SysUtils, Classes, DB, DBClient{, uBaseTypes};
type
    IClientDatas = interface(IInterface)
        ['{A0B0E8C6-BC5F-4F6F-A33C-D325A7DA5AFE}']
        { �Ƿ��¼ }
        function AlreadyLogged: Boolean;
        { �Ƿ����ӵ������� }
        function Connected: Boolean;
        { ��¼�û� }
        //function LoggedInUser: PSysUser;
        { ���ز�ѯ����� }
        function RequestCDS(ASQL: string;
            DestroyWhenClose: Boolean = True; RetriveRecNum: Integer = 1000;
            Editable: Boolean = False): TClientDataSet;
        { ����һ�����ӵ�Table��ClientDataSet }
        function RequestTableCDS(ATableName: string): TClientDataSet;
        { �ͷ�һ���ǹرռ��ͷ��͵�ClientDataSet }
        procedure DestroyCDS(Acds: TDataSet);
        { ִ��һ����ѯ������ִ�е�ΪUpdate, Insert, Delete }
        function DoQuery(ASQL: string): Integer;
        { ����һ��Provider }
        function RequestProvider(Editable: Boolean = False): string;
        { �ͷ�һ��Provider }
        procedure ReleaseProvider(ADSPName: string);
        { ���ط������˵Ĵ�����Ϣ��ͨ����ʹ��Table��DoQuery������ }
        function ServerLastErr: string;
    end;



    {-----------------------------------------------------------------------------
      Class:        TSQLInsertSentenceMaker
                 ���ڸ����û����ٴ���INSERT INTO��ѯ�Ĺ���
      Usage:
            1: SQLInsertMaker.TableName := 'SignalDatas';
            2: with SQLInsertMaker do
               begin
                    AddStringField('DTScale', FormatDateTime('yyyy-mm-dd hh:nn', dt));
                    AddNumberField('SensorID', IntToStr(FSSID));
                    AddNumberField('SubID', IntToStr(FSubID));
                    AddNumberField('SD1', FloatToStr(d));
               end;
            3: sqlStr := SQLInsertMaker.GetSQL;
    -----------------------------------------------------------------------------}
    TSQLInsertSentenceMaker = class
    private
        FTableName, FFields, FValues: string;
    public
        procedure New;
        procedure AddStringField(AFieldName, AValue: string);
        procedure AddNumberField(AFieldName, AValue: string); overload;
        procedure AddNumberField(AFieldName: string; AValue: Integer); overload;
        procedure AddNumberField(AFieldName: string; AValue: Double); overload;
        procedure AddDTField(AFieldName: string; AValue: string); overload;
        procedure AddDTField(AFieldName: string; AValue: Double); overload;
        function GetSQL: string;
        property TableName: string read FTableName write FTableName;
    end;
    {-----------------------------------------------------------------------------
      Calss:        TSQLUpdateSentenceMaker
                    �����û����ٴ���UPDATE��ѯ�Ĺ���
      Usage:
            1:  with SQLUpdateMaker do
                begin
                    TableName := 'PhysicalDatas';
                    AddStringField('[Note]', strNote);
                    AddNumberField('PD1', FloatToStr(d1));
                    AddNumberField('PD3', FloatToStr(d3));
                    WhereStr := '(DTScale=''' + FormatDateTime('yyyy-mm-dd hh:nn', dt) + ''') AND (SensorID='
                              + IntToStr(FSSID) + ') AND (SubID=' + IntToStr(FSubID) + ')';
                end;
            2:  sqlStr := SQLUpdateMaker.GetSQL;
    -----------------------------------------------------------------------------}
    TSQLUpdateSentenceMaker = class
    private
        FTableName: string;
        FSets: string;
        FWheres: string;
    public
        procedure New;
        procedure AddStringField(AFieldName, AValue: string);
        procedure AddNumberField(AFieldName, AValue: string); overload;
        procedure AddNumberField(AFieldName: string; AValue: Integer); overload;
        procedure AddNumberField(AFieldName: string; AValue: Double); overload;
        procedure AddDTField(AFieldName: string; AValue: string); overload;
        procedure AddDTField(AFieldName: string; AValue: Double); overload;
        function GetSQL: string;
        property TableName: string read FTableName write FTableName;
        property WhereStr: string read FWheres write FWheres;
    end;

var
    SQLInsertMaker: TSQLInsertSentenceMaker;
    SQLUpdateMaker: TSQLUpdateSentenceMaker;

implementation

{-----------------------------------------------------------------------------
  Class:        TSQLInsertSentenceMaker
             ���ڸ����û����ٴ���INSERT INTO��ѯ�Ĺ���
  Usage:
        1: SQLInsertMaker.TableName := 'SignalDatas';
        2: with SQLInsertMaker do
           begin
                AddStringField('DTScale', FormatDateTime('yyyy-mm-dd hh:nn', dt));
                AddNumberField('SensorID', IntToStr(FSSID));
                AddNumberField('SubID', IntToStr(FSubID));
                AddNumberField('SD1', FloatToStr(d));
           end;
        3: sqlStr := SQLInsertMaker.GetSQL;
-----------------------------------------------------------------------------}
procedure TSQLInsertSentenceMaker.New;
begin
    Self.FTableName := '';
    FFields := '';
    FValues := '';
end;
{-----------------------------------------------------------------------------
  Procedure:    TSQLInsertSentenceMaker.AddStringField
  Description:
-----------------------------------------------------------------------------}

procedure TSQLInsertSentenceMaker.AddStringField(AFieldName, AValue: string);
begin
    { ���ַ�'�滻Ϊ''��������SQL���ʽ��Ҫ�� }
    AValue := stringreplace(AValue, '''', '''''', [rfReplaceAll]);

    if FFields = '' then
    begin
        FFields := AFieldName;
        FValues := '''' + AValue + '''';
    end
    else
    begin
        FFields := FFields + ',' + AFieldName;
        FValues := FValues + ',''' + AValue + '''';
    end;
end;
{-----------------------------------------------------------------------------
  Procedure:    TSQLInsertSentenceMaker.AddNumberField
  Description:
-----------------------------------------------------------------------------}

procedure TSQLInsertSentenceMaker.AddNumberField(AFieldName, AValue: string);
var
    S     : string;
begin
    if Trim(AValue) = '' then
        S := 'NULL'
    else
        S := AValue;

    if FFields = '' then
    begin
        FFields := AFieldName;
        FValues := S;
    end
    else
    begin
        FFields := FFields + ',' + AFieldName;
        FValues := FValues + ',' + S;
    end;
end;
{-----------------------------------------------------------------------------}
procedure TSQLInsertSentenceMaker.AddNumberField(AFieldName: string; AValue:
    Integer);
begin
    AddNumberField(AFieldName, IntToStr(AValue));
end;
{-----------------------------------------------------------------------------}
procedure TSQLInsertSentenceMaker.AddNumberField(AFieldName: string; AValue:
    Double);
begin
    AddNumberField(AFieldName, floatTostr(AValue));
end;
{-----------------------------------------------------------------------------}
procedure TSQLInsertSentenceMaker.AddDTField(AFieldName, AValue: string);
begin
    if Trim(AValue) = '' then
        AddNumberField(AFieldName, 0)
    else
        AddStringField(AFieldName, AValue);
end;
{-----------------------------------------------------------------------------}
procedure TSQLInsertSentenceMaker.AddDTField(AFieldName: string; AValue: Double);
begin
    if AValue = 0 then
        AddNumberField(AFieldName, 0)
    else
        AddStringField(AFieldName, FormatDateTime('yyyy-mm-dd hh:mm', AValue));
end;
{-----------------------------------------------------------------------------
  Procedure:    TSQLInsertSentenceMaker.GetSQL
  Description:
-----------------------------------------------------------------------------}

function TSQLInsertSentenceMaker.GetSQL: string;
begin
    Result := 'INSERT INTO '#13#10 + FTableName
        + #13#10' (' + FFields + ') '
        + #13#10' VALUES '
        + #13#10' (' + FValues + ')';

    FTableName := '';
    FFields := '';
    FValues := '';
end;
{-----------------------------------------------------------------------------
  Calss:        TSQLUpdateSentenceMaker
                �����û����ٴ���UPDATE��ѯ�Ĺ���
  Usage:
        1:  with SQLUpdateMaker do
            begin
                TableName := 'PhysicalDatas';
                AddStringField('[Note]', strNote);
                AddNumberField('PD1', FloatToStr(d1));
                AddNumberField('PD3', FloatToStr(d3));
                WhereStr := '(DTScale=''' + FormatDateTime('yyyy-mm-dd hh:nn', dt) + ''') AND (SensorID='
                          + IntToStr(FSSID) + ') AND (SubID=' + IntToStr(FSubID) + ')';
            end;
        2:  sqlStr := SQLUpdateMaker.GetSQL;
-----------------------------------------------------------------------------}
procedure TSQLUpdateSentenceMaker.New;
begin
    FTableName := '';
    FSets := '';
    FWheres := '';
end;
{-----------------------------------------------------------------------------
  Procedure:    TSQLUpdateSentenceMaker.AddStringField
  Description:
-----------------------------------------------------------------------------}

procedure TSQLUpdateSentenceMaker.AddStringField(AFieldName, AValue: string);
begin
    { DONE:�����ַ����ĺϷ��Լ�飬�������SQL����Ҫ�� }
    { ������'�ַ��滻Ϊ'' }
    AValue := stringreplace(AValue, '''', '''''', [rfReplaceAll]);
    if FSets = '' then
        FSets := AFieldName + '=''' + Trim(AValue) + ''''
    else
        FSets := FSets + ',' + AFieldName + '=''' + Trim(AValue) + '''';
end;
{-----------------------------------------------------------------------------
  Procedure:    TSQLUpdateSentenceMaker.AddNumberField
  Description:
-----------------------------------------------------------------------------}

procedure TSQLUpdateSentenceMaker.AddNumberField(AFieldName, AValue: string);
var
    S     : string;
begin
    if Trim(AValue) = '' then
        S := 'NULL'
    else
        S := AValue;
    if FSets = '' then
        FSets := AFieldName + '=' + S
    else
        FSets := FSets + ',' + AFieldName + '=' + S;
end;
{-----------------------------------------------------------------------------}
procedure TSQLUpdateSentenceMaker.AddNumberField(AFieldName: string; AValue:
    Integer);
begin
    AddNumberField(AFieldName, IntToStr(AValue));
end;
{-----------------------------------------------------------------------------}
procedure TSQLUpdateSentenceMaker.AddNumberField(AFieldName: string; AValue:
    Double);
begin
    AddNumberField(AFieldName, floatTostr(AValue));
end;
{-----------------------------------------------------------------------------}
procedure TSQLUpdateSentenceMaker.AddDTField(AFieldName, AValue: string);
begin
    if Trim(AValue) = '' then
        AddNumberField(AFieldName, 0)
    else
        AddStringField(AFieldName, AValue);
end;
{-----------------------------------------------------------------------------}
procedure TSQLUpdateSentenceMaker.AddDTField(AFieldName: string; AValue: Double);
begin
    if AValue = 0 then
        AddNumberField(AFieldName, 0)
    else
        AddStringField(AFieldName, FormatDateTime('yyyy-mm-dd hh:mm', AValue));
end;
{-----------------------------------------------------------------------------
  Procedure:    TSQLUpdateSentenceMaker.GetSQL
  Description:
-----------------------------------------------------------------------------}

function TSQLUpdateSentenceMaker.GetSQL: string;
begin
    Result := 'UPDATE ' + FTableName
        + #13#10' SET '#13#10 + FSets
        + #13#10' WHERE '#13#10 + FWheres;

    FTableName := '';
    FSets := '';
    FWheres := '';
end;

initialization
    SQLInsertMaker := TSQLInsertSentenceMaker.Create;
    SQLUpdateMaker := TSQLUpdateSentenceMaker.Create;

finalization
    SQLInsertMaker.Free;
    SQLUpdateMaker.Free;

end.

