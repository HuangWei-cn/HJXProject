{-----------------------------------------------------------------------------
 Unit Name: uIClientDatas
 Author:    Administrator
 Date:      08-十二月-2012
 Purpose:   这是一个接口测试，看看能干什么
 History:
-----------------------------------------------------------------------------}

unit uIClientDatas;

interface
uses
    SysUtils, Classes, DB, DBClient{, uBaseTypes};
type
    IClientDatas = interface(IInterface)
        ['{A0B0E8C6-BC5F-4F6F-A33C-D325A7DA5AFE}']
        { 是否登录 }
        function AlreadyLogged: Boolean;
        { 是否连接到服务器 }
        function Connected: Boolean;
        { 登录用户 }
        //function LoggedInUser: PSysUser;
        { 返回查询结果集 }
        function RequestCDS(ASQL: string;
            DestroyWhenClose: Boolean = True; RetriveRecNum: Integer = 1000;
            Editable: Boolean = False): TClientDataSet;
        { 返回一个连接到Table的ClientDataSet }
        function RequestTableCDS(ATableName: string): TClientDataSet;
        { 释放一个非关闭即释放型的ClientDataSet }
        procedure DestroyCDS(Acds: TDataSet);
        { 执行一条查询，允许执行的为Update, Insert, Delete }
        function DoQuery(ASQL: string): Integer;
        { 请求一个Provider }
        function RequestProvider(Editable: Boolean = False): string;
        { 释放一个Provider }
        procedure ReleaseProvider(ADSPName: string);
        { 返回服务器端的错误信息，通常是使用Table或DoQuery产生的 }
        function ServerLastErr: string;
    end;



    {-----------------------------------------------------------------------------
      Class:        TSQLInsertSentenceMaker
                 用于辅助用户快速创建INSERT INTO查询的工具
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
                    辅助用户快速创建UPDATE查询的工具
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
             用于辅助用户快速创建INSERT INTO查询的工具
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
    { 将字符'替换为''，以满足SQL表达式的要求 }
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
                辅助用户快速创建UPDATE查询的工具
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
    { DONE:增加字符串的合法性检查，必须符合SQL语句的要求 }
    { 将所有'字符替换为'' }
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

