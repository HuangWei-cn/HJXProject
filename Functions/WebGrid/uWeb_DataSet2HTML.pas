{-----------------------------------------------------------------------------
 Unit Name: uWeb_DataSet2HTML
 Author:    Administrator
 Date:      04-ʮһ��-2012
 Purpose:   ����Ԫ��Ҫ����������HTML����
 History:
-----------------------------------------------------------------------------}
{ TODO:�ɶ��Ƶı�ͷ���Զ�����ϲ��ĵ�Ԫ�񣬿ɺϲ��к��� }
{ TODO:�Զ��ϲ�����������ͬ�����ڵĵ�Ԫ�� }
{ TODO:�ɶ����е�Ԫ���ɫ�����ݵ������� }
unit uWeb_DataSet2HTML;

interface
uses
    Classes, SysUtils, DateUtils, StrUtils, DB;
const
    { HTMLҳ����룬���ڵ���Ҫ������ҳ����ʱʹ�� }
    htmPageCode = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10
        + '<html>'#13#10
        + '<head>'#13#10
        + '<title>'#13#10
        + '@PageTitle@'#13#10
        + '</title>'#13#10
        + '</head>'#13#10
        + '<body>'#13#10
        + '@PageContent@'#13#10
        + '</body>'#13#10
        + '</html>';

    { ��Ա��ı�ͷ����Ԫ��ʹ����CSS���� }
    htmPageCode2 = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10
        + '<html>'#13#10
        + '<head>'#13#10
        + '@PageTitle@'#13#10
        + '<style type="text/css">'#13#10
        + '.DataGrid {border:1px solid #000099;border-width:1px 1px 1px 1px;margin:1px 1px 1px 1px;border-collapse:collapse}'#13#10
        + '.thStyle {font-size: 8pt; font-family: Tahoma; color: #000000; padding:3px;border:1px solid #000099}'#13#10
        + '.tdStyle {font-size: 8pt; font-family: Tahoma; color: #000000; background-color:#FFFFFF;empty-cells:show;'     //#F7F7F7
        + '          border:1px solid #000099; padding:3px}'#13#10
        + '.CaptionStyle {font-family:����;font-size: 9pt;color: #000000; padding:3px;border:1px solid #000099; background-color:#FFFF99}'#13#10
        + '</style>'#13#10
        + '</head>'#13#10
        + '<body>'#13#10
        + '@PageContent@'#13#10
        + '</body>'#13#10
        + '</html>';

    { ������ }
    htmTableCode = '<table BORDER=1 CELLSPACING=0 CELLPADDING=3 BGCOLOR=#ECE9D8>'#13#10
        + '@Caption@'
        + '@Rows@'
        + '</table>';

    { ��Ԫ����� }
    htmTDCode = '<TD %Align% %Width% %BGCOLOR%>'
        + '<FONT STYLE="font-family: Tahoma; font-size: 8pt; color: #000000">'
        + '@Value@'
        + '</FONT></TD>';

    { ʹ��CSS�ĵ�Ԫ����룬ע����������Ԫ��������չ }
    htmTDCode2 = '<td class="tdStyle" %Align% %Width% %BGCOLOR% %RowSpan% %ColSpan%>'
        + '@Value@' + '<td>'#13#10;

    { �д��� }
    htmTRCode = '<TR>'#13#10 + '@Cells@'#13#10 + '</TR>'#13#10;

{ ��ʹ�������ʽ������Datasetԭ��ת��ΪHTML Table }
function DataSet2HTML(ADS: TDataSet;    { Ҫ�����DataSet }
    ATitle: string = '';                { ���� }
    bPageCode: Boolean = True;          { ��������ҳ����� }
    HeadHR: Boolean = False;            { ͷ������ }
    TailHR: Boolean = False             { β������ }
    ): string;

implementation


{-----------------------------------------------------------------------------
  Procedure:    DataSet2HTML
  Description:  ���ݸ�����Dataset����HTML������
-----------------------------------------------------------------------------}
function DataSet2HTML(ADS: TDataSet; ATitle: string = ''; bPageCode: Boolean =
    True;
    HeadHR: Boolean = False; TailHR: Boolean = False): string;
var
    sHd   : string;
    i, iFld, fldCount: Integer;
    sTD, sTR, sTDLine: string;
    sTable, sRows: string;
    aFld  : TField;

    { �����ֶ����� }
    function _ValueStr(fld: TField): string;
    begin
        if fld.IsNull then
            Result := '��'
        else
            case fld.DataType of        //
                ftFloat: Result := FormatFloat('0.0000', fld.Value);
                ftDateTime: Result := FormatDateTime('yyyy-mm-dd hh:mm',
                        fld.Value);
                ftDate: Result := FormatDateTime('yyyy-mm-dd', fld.Value);
                ftTime: Result := FormatDateTime('hh:mm:ss', fld.Value);
            else
                Result := fld.DisplayText;
            end;                        // case
    end;
    { ��Ԫ����룬�������� }
    function _GetAlign(fld: TField): string;
    begin
        Result := '';
        case fld.DataType of            //
            ftFloat, ftInteger, ftSmallInt, ftWord: Result := 'ALIGN="RIGHT"';
        else
            Result := '';
        end;                            // case
    end;
begin
    Result := '';

    sTable := htmTableCode;
    sRows := '';
    { ���DataSet�Ƿ�nil���Ƿ�Ϊ�� }
    if ADS = nil then
    begin
        if bPageCode then
            Result := htmPageCode
        else
            Result := sTable;
        Exit;
    end;

    { ���ɱ�ͷ }
    fldCount := ADS.FieldCount;
    sHd := htmTRCode;
    sTDLine := '';
    for i := 0 to fldCount - 1 do
    begin
        sTD := htmTDCode;
        sTD := StringReplace(sTD, '%Align%', 'ALIGN="CENTER"', [rfReplaceAll]);
        sTD := StringReplace(sTD, '%Width%', '', [rfReplaceAll]);
        sTD := StringReplace(sTD, '%BGCOLOR%', '', []);
        sTD := StringReplace(sTD, '@Value@', ADS.Fields[i].DisplayName,
            [rfReplaceAll]);
        sTDLine := sTDLine + sTD + #13#10;
    end;
    sHd := StringReplace(sHd, '@Cells@', sTDLine, [rfReplaceAll]);
    sRows := sHd + #13#10;

    { �������� }
    if ADS.RecordCount > 0 then
    begin
        ADS.First;
        repeat
            sTR := htmTRCode;
            sTDLine := '';
            for i := 0 to fldCount - 1 do
            begin
                aFld := ADS.Fields[i];
                sTD := htmTDCode;
                sTD := StringReplace(sTD, '%Align%', _GetAlign(aFld),
                    [rfReplaceAll]);
                sTD := StringReplace(sTD, '%Width%', '', [rfReplaceAll]);
                sTD := StringReplace(sTD, '%BGCOLOR%', 'BGCOLOR="#F7F7F7"', []);
                sTD := StringReplace(sTD, '@Value@', _ValueStr(ADS.Fields[i]),  {ADS.Fields[i].DisplayText}
                    [rfReplaceAll]);
                sTDLine := sTDLine + sTD + #13#10;
            end;
            sTR := StringReplace(sTR, '@Cells@', sTDLine, [rfReplaceAll]);

            sRows := sRows + sTR + #13#10;
            ADS.Next;
        until ADS.Eof;
    end;
    { ���ɱ����� }
    sTable := StringReplace(sTable, '@Rows@', sRows, []);

    { �������ս�� }
    Result := StringReplace(Result, '@PageTitle@', ATitle, []);

    { �Ƿ���Ҫ���� }
    if Trim(ATitle) <> '' then
        sTable := '<h4>' + ATitle + '</h4>'#13#10 + sTable;

    { �Ƿ�ͷ������ }
    if HeadHR then
        sTable := '<hr>'#13#10 + sTable;

    { �Ƿ�β������ }
    if TailHR then
        sTable := sTable + '<hr>'#13#10;

    if bPageCode then
        Result := StringReplace(htmPageCode, '@PageContent@', sTable, [])
    else
        Result := sTable;
end;

//{-----------------------------------------------------------------------------}
//function _ValueStr(fld: TField): string;
//begin
//    if fld.IsNull then
//        Result := '��'
//    else
//        case fld.DataType of            //
//            ftFloat: Result := FormatFloat('0.0000', fld.Value);
//            ftDateTime: Result := FormatDateTime('yyyy-mm-dd hh:mm',
//                    fld.Value);
//            ftDate: Result := FormatDateTime('yyyy-mm-dd', fld.Value);
//            ftTime: Result := FormatDateTime('hh:mm:ss', fld.Value);
//        else
//            Result := fld.DisplayText;
//        end;                            // case
//end;
{-----------------------------------------------------------------------------}
function _CombineGrid(AHD, ADataRows, ATitle, ACaption: string; TableOnly: Boolean
    = True; TailHR: Boolean = False): string;
var sTable: string;
begin
    sTable := htmTableCode;
    { ������ }
    if (ACaption = 'N/A') or (ACaption = '') then
        sTable := StringReplace(sTable, '@Caption@', '', [])
    else
        sTable := StringReplace(sTable, '@Caption@',
            '<caption class="CaptionStyle">' + ACaption + '</caption>', []);
    { �ϲ������� }
    sTable := StringReplace(sTable, '@Rows@', AHD + ADataRows, []);

    { ���ߣ� }
    if TailHR then
        sTable := sTable + '<br><br><hr>'#13#10;

    { ���⣿ }
    if ATitle <> 'N/A' then
        sTable := '<h4>' + ATitle + '</h4>'#13#10 + sTable;

    if TableOnly then
        Result := sTable
    else
    begin
        Result := htmPageCode2;
        if ATitle = 'N/A' then
            ATitle := '';
        Result := StringReplace(Result, '@PageTitle@', ATitle, []);
        Result := StringReplace(Result, '@PageContent@', sTable, []);
    end;
end;


end.

