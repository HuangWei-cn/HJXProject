{-----------------------------------------------------------------------------
 Unit Name: uWeb_DataSet2HTML
 Author:    Administrator
 Date:      04-十一月-2012
 Purpose:   本单元主要负责处理、生成HTML代码
 History:
-----------------------------------------------------------------------------}
{ TODO:可定制的表头，自动处理合并的单元格，可合并行和列 }
{ TODO:自动合并数据项中相同并相邻的单元格 }
{ TODO:可定制列单元格底色、内容的字体风格 }
unit uWeb_DataSet2HTML;

interface
uses
    Classes, SysUtils, DateUtils, StrUtils, DB;
const
    { HTML页面代码，用于当需要返回整页代码时使用 }
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

    { 针对表格的表头、单元格使用了CSS定义 }
    htmPageCode2 = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10
        + '<html>'#13#10
        + '<head>'#13#10
        + '@PageTitle@'#13#10
        + '<style type="text/css">'#13#10
        + '.DataGrid {border:1px solid #000099;border-width:1px 1px 1px 1px;margin:1px 1px 1px 1px;border-collapse:collapse}'#13#10
        + '.thStyle {font-size: 8pt; font-family: Tahoma; color: #000000; padding:3px;border:1px solid #000099}'#13#10
        + '.tdStyle {font-size: 8pt; font-family: Tahoma; color: #000000; background-color:#FFFFFF;empty-cells:show;'     //#F7F7F7
        + '          border:1px solid #000099; padding:3px}'#13#10
        + '.CaptionStyle {font-family:黑体;font-size: 9pt;color: #000000; padding:3px;border:1px solid #000099; background-color:#FFFF99}'#13#10
        + '</style>'#13#10
        + '</head>'#13#10
        + '<body>'#13#10
        + '@PageContent@'#13#10
        + '</body>'#13#10
        + '</html>';

    { 表格代码 }
    htmTableCode = '<table BORDER=1 CELLSPACING=0 CELLPADDING=3 BGCOLOR=#ECE9D8>'#13#10
        + '@Caption@'
        + '@Rows@'
        + '</table>';

    { 单元格代码 }
    htmTDCode = '<TD %Align% %Width% %BGCOLOR%>'
        + '<FONT STYLE="font-family: Tahoma; font-size: 8pt; color: #000000">'
        + '@Value@'
        + '</FONT></TD>';

    { 使用CSS的单元格代码，注意这里允许单元格行列扩展 }
    htmTDCode2 = '<td class="tdStyle" %Align% %Width% %BGCOLOR% %RowSpan% %ColSpan%>'
        + '@Value@' + '<td>'#13#10;

    { 行代码 }
    htmTRCode = '<TR>'#13#10 + '@Cells@'#13#10 + '</TR>'#13#10;

{ 不使用特殊格式，仅将Dataset原样转换为HTML Table }
function DataSet2HTML(ADS: TDataSet;    { 要处理的DataSet }
    ATitle: string = '';                { 标题 }
    bPageCode: Boolean = True;          { 生成完整页面代码 }
    HeadHR: Boolean = False;            { 头部横线 }
    TailHR: Boolean = False             { 尾部横线 }
    ): string;

implementation


{-----------------------------------------------------------------------------
  Procedure:    DataSet2HTML
  Description:  根据给定的Dataset生成HTML表格代码
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

    { 返回字段数据 }
    function _ValueStr(fld: TField): string;
    begin
        if fld.IsNull then
            Result := '　'
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
    { 单元格对齐，根据内容 }
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
    { 检查DataSet是否nil，是否为空 }
    if ADS = nil then
    begin
        if bPageCode then
            Result := htmPageCode
        else
            Result := sTable;
        Exit;
    end;

    { 生成表头 }
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

    { 生成内容 }
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
    { 生成表内容 }
    sTable := StringReplace(sTable, '@Rows@', sRows, []);

    { 生成最终结果 }
    Result := StringReplace(Result, '@PageTitle@', ATitle, []);

    { 是否需要标题 }
    if Trim(ATitle) <> '' then
        sTable := '<h4>' + ATitle + '</h4>'#13#10 + sTable;

    { 是否头部横线 }
    if HeadHR then
        sTable := '<hr>'#13#10 + sTable;

    { 是否尾部横线 }
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
//        Result := '　'
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
    { 表格标题 }
    if (ACaption = 'N/A') or (ACaption = '') then
        sTable := StringReplace(sTable, '@Caption@', '', [])
    else
        sTable := StringReplace(sTable, '@Caption@',
            '<caption class="CaptionStyle">' + ACaption + '</caption>', []);
    { 合并表格代码 }
    sTable := StringReplace(sTable, '@Rows@', AHD + ADataRows, []);

    { 横线？ }
    if TailHR then
        sTable := sTable + '<br><br><hr>'#13#10;

    { 标题？ }
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

