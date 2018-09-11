{ -----------------------------------------------------------------------------
 Unit Name: uWebGridCross
 Author:    Administrator
 Date:      17-十二月-2012
 Purpose:   本单元提供类似frxCrossView的功能，也采用类似的使用方法，产生一个
            数据表的HTML代码，供调用者写入WebBrowser以显示之。
            类似frxCrossView，表分为三个部分：ColumnHeader, RowHeader, DataArea,
            每个数据项由对应的RowHead值和ColHead值定位，或由行列号定位。最后，
            相同的单元格将被合并，合并优先顺序是先行后列。

 History:
----------------------------------------------------------------------------- }
{ TODO: 增加列设置，可以针对每一列设置对齐、格式、是否允许纵向融合、横向融合等 }
{ TODO: 某些列纵向融合设置应与另一列对应，如观测日期应和仪器编号对应 }
{ DONE: 允许插入Caption Row，该行横向融合相同的单元格，忽略列融合设置 }
{ TODO: 可考虑将表格调整为表头固定，内容可滚动 }
{ TODO: 可考虑提供带有可折叠div的表格代码 }
{ DONE: 增加对日期和浮点数据的格式化字符串，生成过程中自动设置之 }
{ todo: 希望增加的个性化属性：表格线颜色、粗细；表头底色，数据区底色，任一单元格
字体、大小、粗体、斜体、颜色；任一单元格底色；针对单元格的对齐；调整表格的Padding;
单元格的最小宽度 }
{ todo: 允许像TStringGrid那样，用Cell方式访问、设置任一单元格的属性和值 }
unit uWebGridCross;

interface

uses
    SysUtils, Classes, Variants;

type
    TWebCrossHeader = class;

    { 单元格对象，是Matrix的组成部分 }
    TWebCrossCell = class
    private
        FVisible  : Boolean;
        FColSpan  : Integer;
        FRowSpan  : Integer;
        FValue    : Variant;
        FcssClass : string;
        FAlign    : TAlignment;
        FColHeader: TWebCrossHeader;
        { todo:在Cell对象中增加字体大小、颜色、粗体、斜体、背景色等几种属性 }
        function IsNull: Boolean;
        function GetStrValue: string;
    public
        constructor Create;
        property Value: Variant read FValue write FValue;
        property StrValue: string read GetStrValue;
        property Visible: Boolean read FVisible write FVisible;
        property ColSpan: Integer read FColSpan write FColSpan;
        property RowSpan: Integer read FRowSpan write FRowSpan;
        property Alignment: TAlignment read FAlign write FAlign;
        property CSSClass: string read FcssClass write FcssClass;
        property ColHeader: TWebCrossHeader read FColHeader write FColHeader;
    end;

    TWebCrossHeader = class
        Align: TAlignment;
        FormatStr: string;
        AllowColSpan: Boolean;
        AllowRowSpan: Boolean;
    end;

    PWebCrossRow = ^TWebCrossRow;

    TWebCrossRow = record
        IsCaptionRow: Boolean;
        IsHeader: Boolean;
        IsFooter: Boolean;
    end;

    { 数据矩阵 }
    TWebCrossMatrix = class
    private
        FColCount  : Integer;
        FRowCount  : Integer;
        FTitleRows : Integer;
        FTitleCols : Integer;
        FMergeSame : Boolean;
        FColHeaders: array of TWebCrossHeader;
        FCellMatrix: array of array of TWebCrossCell;
        FRows      : array of PWebCrossRow;
        { 预处理单元格数据，主要是合并单元格之类的东东 }
        procedure PreProcCells;
        procedure ResetCells;
        function GetColHeader(ACol: Integer): TWebCrossHeader;
    public
        constructor Create(AColumnCount: Integer);
        destructor Destroy; override;
        procedure AddRow(ValueArray: array of Variant); // 向Matrix尾部添加一行
        procedure AddCaptionRow(CaptionArray: array of Variant);
        function HTMLCode: string;
        { 2013-06-19 仅返回表格代码，而非整页 }
        function TableCode: string;

        property RowCount: Integer read FRowCount;
        property ColCount: Integer read FColCount;
        property TitleRows: Integer read FTitleRows write FTitleRows;
        property TitleCols: Integer read FTitleCols write FTitleCols;
        property ColHeader[ACol: Integer]: TWebCrossHeader read GetColHeader;
    end;

    TWebCrossView = class
    private
        FColCount     : Integer;
        FRowCount     : Integer;
        FTitleRowCount: Integer;         // 标题行数
        FTitleColCount: Integer;         // 标题列数：指从0列～FTitleColCount-1为标题列数
        FMatrix       : TWebCrossMatrix; // 保存全部内容的矩阵
        function getRowCount: Integer;
        procedure CreateMatrix;
        function GetMatrixColHeader(ACol: Integer): TWebCrossHeader;
        procedure SetTitleRowCount(ACount: Integer);
        procedure SetTitleColCount(ACount: Integer);
    public
        constructor Create;
        destructor Destroy; override;
        procedure Reset;
        procedure AddRow(const ValueArray: array of Variant);
        procedure AddCaptionRow(CaptionArray: array of Variant);
        { CrossGrid方法返回表格代码，不包括HTML页面的表头、样式表、表体等部分 }
        function CrossGrid: string;
        { CrossPage方法返回完整的页面。 }
        function CrossPage: string;
        { 返回空的页面代码，调用者用来合成多表。调用者需要替换的内容有：
          @PageTitle@，@PageContent@两个字符串，用实际内容替换即可 }
        function BlankPage: string;

        property ColCount: Integer read FColCount write FColCount;
        property RowCount: Integer read getRowCount;
        property TitleRows: Integer read FTitleRowCount write SetTitleRowCount; // FTitleRowCount;
        property TitleCols: Integer read FTitleColCount write SetTitleColCount; // FTitleColCount;
        property ColHeader[ACol: Integer]: TWebCrossHeader read
            GetMatrixColHeader;
    end;

implementation

const
    { 注：这里的CSS设置使得表格呈现细线边框 }
    { 针对表格的表头、单元格使用了CSS定义 }
    htmPageCode2 = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10
        + '<html>'#13#10
        + '<head>'#13#10
        + '@PageTitle@'#13#10
        + '<style type="text/css">'#13#10
        + '.DataGrid {border:1px solid #000099;border-width:1px 1px 1px 1px;margin:1px 1px 1px 1px;border-collapse:collapse}'#13#10
        + '.thStyle {font-size: 8pt; font-family: Tahoma; color: #000000; padding:3px;border:1px solid #000099}'#13#10
        + '.tdStyle {font-size: 8pt; font-family: Tahoma; color: #000000; background-color:#FFFFFF;empty-cells:show;'
    // #F7F7F7
        + '          border:1px solid #000099; padding:3px}'#13#10
        + '.CaptionStyle {font-family:黑体;font-size: 9pt;color: #000000; padding:3px;border:1px solid #000099; background-color:#FFFF99}'#13#10
        + '</style>'#13#10
        + '</head>'#13#10
        + '<body>'#13#10
        + '@PageContent@'#13#10
        + '</body>'#13#10
        + '</html>';

    { 表格代码 }
    htmTableCode =
        '<table BORDER=0 CELLSPACING=0 CELLPADDING=0 BGCOLOR=#ADD8E6 class="DataGrid">'#13#10
    // BGCOLOR=#ECE9D8
        + '@Caption@'
        + '@Rows@'
        + '</table>';

    { 单元格代码 }
    htmTDCode = '<TD %Align% %Width% %BGCOLOR%>'
        + '<FONT STYLE="font-family: Tahoma; font-size: 8pt; color: #000000">'
        + '@Value@'
        + '</FONT></TD>';

    { 使用CSS的单元格代码，注意这里允许单元格行列扩展 }
    htmTDCode2 = '<td %class% %Align% %Width% %BGCOLOR% %RowSpan% %ColSpan%>'
        + '@Value@' + '</td>'#13#10;

    { 行代码 }
    htmTRCode = '<TR>'#13#10 + '@Cells@'#13#10 + '</TR>'#13#10;

    htmHeadClass = 'class="thStyle"';
    htmTDClass   = 'class="tdStyle"';

{ ==============================================================================
                    <<<<<<<<<<<<<   TWebCrossCell   >>>>>>>>>>>>>>>
      ClassName:    TWebCrossCell
      Comment:
=============================================================================== }
constructor TWebCrossCell.Create;
begin
    inherited;
    FValue := Null;
    FVisible := True;
    FColSpan := 1;
    FRowSpan := 1;
    FAlign := taLeftJustify;
    FcssClass := '';
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossCell.IsNull: Boolean;
begin
    Result := VarIsNull(FValue);
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossCell.GetStrValue: string;
begin
    if IsNull then
        Result := '　'
    else
    begin
        case VarType(FValue) of //
            varEmpty, varNull:
                Result := '　';
            varSmallInt, varInteger, varShortInt, varByte, varWord, varLongWord,
                varInt64:
                Result := IntToStr(FValue);
            varSingle, varDouble, varCurrency:
                Result := FormatFloat('0.00',
                    FValue);
            varDate:
                Result := FormatDateTime('yyyy-mm-dd hh:mm:ss', FValue);
            varBoolean:
                Result := Booltostr(FValue);
            varString, varOLEStr:
                if Trim(FValue) = '' then
                    Result := '　'
                else
                    Result := FValue;
        else
            Result := VartoStr(FValue);
        end; // case
    end;
end;

{ ==============================================================================
                <<<<<<<<<<<<<   TWebCrossMatrix   >>>>>>>>>>>>>>>
  ClassName:    TWebCrossMatrix
  Comment:
 =============================================================================== }
constructor TWebCrossMatrix.Create(AColumnCount: Integer);
var
    i: Integer;
begin
    inherited Create;
    FColCount := AColumnCount;
    FRowCount := 0;

    SetLength(FColHeaders, AColumnCount);
    for i := 0 to AColumnCount - 1 do
    begin
        FColHeaders[i] := TWebCrossHeader.Create;
        with FColHeaders[i] do
        begin
            Align := taLeftJustify;
            FormatStr := '';
            AllowColSpan := False;
            AllowRowSpan := False;
        end;
    end;
end;

{ ----------------------------------------------------------------------------- }
destructor TWebCrossMatrix.Destroy;
var
    i, j: Integer;
begin
    if Length(FCellMatrix) > 0 then
        for i := Low(FCellMatrix) to High(FCellMatrix) do
        begin
            for j := Low(FCellMatrix[i]) to High(FCellMatrix[i]) do
                FCellMatrix[i][j].Free;
            SetLength(FCellMatrix[i], 0);
        end;

    SetLength(FCellMatrix, 0);

    if Length(FColHeaders) > 0 then
        for i := Low(FColHeaders) to High(FColHeaders) do
            FColHeaders[i].Free;
    SetLength(FColHeaders, 0);

    if Length(FRows) > 0 then
        for i := Low(FRows) to High(FRows) do
            Dispose(FRows[i]);
    SetLength(FRows, 0);
    inherited;
end;

{ -----------------------------------------------------------------------------
  Procedure:    TWebCrossMatrix.AddRow
  Description:	添加一行数据。本方法没有对数据项进行行列定位，因此数据是添加
  到matrix的尾部，且按照列顺序依次设置值。
----------------------------------------------------------------------------- }
procedure TWebCrossMatrix.AddRow(ValueArray: array of Variant);
var
    iRow, iCol: Integer;
begin
    Inc(FRowCount);
    { 设置内容矩阵 }
    SetLength(FCellMatrix, FRowCount);

    iRow := FRowCount - 1;
    SetLength(FCellMatrix[iRow], FColCount);
    for iCol := Low(FCellMatrix[iRow]) to High(FCellMatrix[iRow]) do
    begin
        FCellMatrix[iRow][iCol] := TWebCrossCell.Create;
        FCellMatrix[iRow][iCol].ColHeader := Self.ColHeader[iCol];
        FCellMatrix[iRow][iCol].Alignment := Self.ColHeader[iCol].Align;
    end;
    // if Varisarray(ValueArray) then
    for iCol := Low(ValueArray) to High(ValueArray) do
        FCellMatrix[iRow][iCol].Value := ValueArray[iCol];

    { 设置行属性数组 }
    SetLength(FRows, FRowCount);
    New(FRows[FRowCount - 1]);
    with FRows[FRowCount - 1]^ do
    begin
        IsCaptionRow := False;
        IsFooter := False;
        if FRowCount <= FTitleRows then
            IsHeader := True;
    end; // with
end;

{ -----------------------------------------------------------------------------
  Procedure:    TWebCrossMatrix.AddCaptionRow
  Description:  增加一个Caption行。Caption行通常是横向合并的
----------------------------------------------------------------------------- }
procedure TWebCrossMatrix.AddCaptionRow(CaptionArray: array of Variant);
var
    iRow, iCol, i: Integer;
    n1, n2       : Integer;
begin
    Inc(FRowCount);
    SetLength(FCellMatrix, FRowCount);
    iRow := FRowCount - 1;
    SetLength(FCellMatrix[iRow], FColCount);
    for iCol := 0 to FColCount - 1 do
        FCellMatrix[iRow][iCol] := TWebCrossCell.Create;

    { 如果CaptionArray数量少于ColCount，则matrix其余数值等于CaptionArray的最后一项 }
    if High(CaptionArray) < FColCount - 1 then
        n1 := High(CaptionArray)
    else
        n1 := FColCount - 1;

    for iCol := 0 to n1 do
        FCellMatrix[iRow][iCol].Value := CaptionArray[iCol];

    for iCol := n1 + 1 to FColCount - 1 do
        FCellMatrix[iRow][iCol].Value := CaptionArray[n1];

    SetLength(FRows, FRowCount);
    New(FRows[iRow]);
    FRows[iRow].IsCaptionRow := True;
    FRows[iRow].IsHeader := False;
    FRows[iRow].IsFooter := False;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossMatrix.ResetCells;
var
    iRow, iCol: Integer;
begin
    if (FRowCount > 0) and (FColCount > 0) then
        for iRow := 0 to FRowCount - 1 do
            for iCol := 0 to FColCount - 1 do
            begin
                FCellMatrix[iRow][iCol].Visible := True;
                FCellMatrix[iRow][iCol].ColSpan := 1;
                FCellMatrix[iRow][iCol].RowSpan := 1;
            end;
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossMatrix.GetColHeader(ACol: Integer): TWebCrossHeader;
begin
    Result := nil;
    if Length(FColHeaders) > 0 then
        if ACol <= High(FColHeaders) then
            Result := FColHeaders[ACol];
end;

{ -----------------------------------------------------------------------------
  Procedure:    TWebCrossMatrix.PreProcCells
  Description:  本方法在输出结果之前对矩阵进行预处理，主要是设置合并项等
  目前，只允许单元格要么跨行(行合并)，要么跨列(列合并)，不允许同时跨行和跨列
  (主要是目前还没有找到何时的算法);
----------------------------------------------------------------------------- }
procedure TWebCrossMatrix.PreProcCells;
var
    iRow, iCol, iLeftCol: Integer;
    iMCStart, iMC       : Integer;
    sValue, sCurValue   : string;
begin
    { 先检查每行中各列，看看行中是否存在可以合并的单元格 }
    for iRow := 0 to FRowCount - 1 do
    begin
        sValue := '';
        iMCStart := -1;
        iMC := 1;
        for iCol := 0 to FColCount - 1 do
        begin
            { 如果本列不允许横向合并，则处理之前的合并，但是标题行不受限制 }
            if (iRow > FTitleRows - 1) and (not ColHeader[iCol].AllowRowSpan) and
                (not FRows[iRow].IsCaptionRow) then
            begin
                if iMCStart <> -1 then
                begin
                    FCellMatrix[iRow][iMCStart].FColSpan := iMC;
                end;

                sValue := '';
                iMCStart := -1;
                iMC := 1;
                Continue;
            end;

            sCurValue := FCellMatrix[iRow][iCol].StrValue;
            if sValue <> sCurValue then
            begin
                if iMCStart <> -1 then
                begin
                    FCellMatrix[iRow][iMCStart].FColSpan := iMC;
                end;

                sValue := sCurValue;
                iMCStart := iCol;
                iMC := 1;
            end
            else
            begin
                Inc(iMC);
                FCellMatrix[iRow][iCol].Visible := False;
                { 如果是最后一列，则完成本轮检查 }
                if iCol = (FColCount - 1) then
                    FCellMatrix[iRow][iMCStart].FColSpan := iMC;
            end;
        end;
    end;

    { 检查各个列，将列中相同的单元格设置为合并 }
    for iCol := 0 to FColCount - 1 do
    begin
        sValue := '';
        iMCStart := -1;
        iMC := 1;
        for iRow := 0 to FRowCount - 1 do
        begin
            { 如果列不允许纵向合并，或本行为标题行、CaptionRow则next }
            if ((iRow > FTitleRows - 1) and (not FColHeaders[iCol].AllowColSpan))
                or (FRows[iRow].IsCaptionRow) then
            begin
                { 合并之前的 }
                if iMCStart <> -1 then
                begin
                    FCellMatrix[iMCStart][iCol].FRowSpan := iMC;
                end;

                sValue := sCurValue;
                iMCStart := iRow;
                iMC := 1;

                Continue;
            end;

            if FCellMatrix[iRow][iCol].ColSpan > 1 then
                Continue;

            sCurValue := FCellMatrix[iRow][iCol].StrValue;
            if sValue <> sCurValue then
            begin
                if iMCStart <> -1 then
                begin
                    FCellMatrix[iMCStart][iCol].FRowSpan := iMC;
                end;

                sValue := sCurValue;
                iMCStart := iRow;
                iMC := 1;
            end
            else
            begin
                Inc(iMC);
                FCellMatrix[iRow][iCol].Visible := False;
                { 如果是最后一行，则完成设置 }
                if iRow = (FRowCount - 1) then
                    FCellMatrix[iMCStart][iCol].FRowSpan := iMC;

                { 检查左侧的列，本列合并范围不能超过左侧各列纵向合并范围 }
                if iCol > 0 then
                    for iLeftCol := 0 to iCol - 1 do
                        if ColHeader[iLeftCol].AllowColSpan then
                        begin
                            if (FCellMatrix[iRow][iLeftCol].Visible) { and
                            (FCellMatrix[iRow][iLeftCol].FRowSpan = 1) } then
                            begin
                                FCellMatrix[iMCStart][iCol].FRowSpan := iMC - 1;
                                FCellMatrix[iRow][iCol].Visible := True;
                                iMC := 1;
                                // sValue := '';
                                iMCStart := iRow;
                            end;
                        end;
            end;

        end;
    end;
end;

{ -----------------------------------------------------------------------------
  Procedure:    TWebCrossMatrix.TableCode
  Description:  本方法仅返回表格代码
----------------------------------------------------------------------------- }
function TWebCrossMatrix.TableCode: string;
const
    TDCode = '<td @cls @colspan @rowspan @align>@var</td>'#13#10;
var
    sTR, sTD, sTable, sCaption, sRows, s: string;
    iRow, iCol                          : Integer;
    cell                                : TWebCrossCell;
begin
    Result := '';
    ResetCells;
    PreProcCells;
    sRows := '';
    sTable := '';
    for iRow := 0 to FRowCount - 1 do
    begin
        sTR := '';
        for iCol := 0 to FColCount - 1 do
        begin
            sTD := '';
            cell := FCellMatrix[iRow][iCol];
            if cell.Visible then
            begin
                sTD := '<td';
                if cell.CSSClass <> '' then
                    sTD := sTD + ' class="' + cell.CSSClass + '"'
                else if iRow <= (FTitleRows - 1) then
                    sTD := sTD + ' class="thStyle"'
                else if FRows[iRow].IsCaptionRow then
                    sTD := sTD + ' class="CaptionStyle"'
                else
                    sTD := sTD + ' class="tdStyle"';

                if (cell.Alignment = taCenter) or (cell.ColSpan > 1)
                    or (iRow <= (FTitleRows - 1)) then
                    s := ' align="center"'
                else if cell.Alignment = taRightJustify then
                    s := ' align="right"'
                else
                    s := '';
                sTD := sTD + s;

                if cell.RowSpan > 1 then
                    sTD := sTD + Format(' rowspan="%d"', [cell.RowSpan]);

                if cell.ColSpan > 1 then
                    sTD := sTD + Format(' colspan="%d"', [cell.ColSpan]);

                sTD := sTD + '>' + cell.GetStrValue + '</td>'#13#10;
                sTR := sTR + sTD;
            end;
        end;
        if sTR <> '' then
        begin
            sTR := '<tr>'#13#10 + sTR + '</tr>'#13#10;
            sRows := sRows + sTR;
        end;
    end;
    { todo:应考虑保留@Caption@项 }
    // sTable := htmTableCode;
    sTable := Stringreplace(htmTableCode, '@Caption@', '', []);
    sTable := Stringreplace(sTable, '@Rows@', sRows, []);
    Result := sTable;
end;

{ -----------------------------------------------------------------------------
  Procedure:    TWebCrossMatrix.HTMLCode
  Description:	本方法生成HTML代码
----------------------------------------------------------------------------- }
function TWebCrossMatrix.HTMLCode: string;
// const
// TDCode = '<td @cls @colspan @rowspan @align>@var</td>'#13#10;
var
    sTable: string;
// sTR, sTD, sTable, sCaption, sRows, s: string;
// iRow, iCol: Integer;
// cell  : TWebCrossCell;
begin
    Result := '';
// ResetCells;
// PreProcCells;
// sRows := '';
// sTable := '';
// for iRow := 0 to FRowCount - 1 do
// begin
// sTR := '';
// for iCol := 0 to FColCount - 1 do
// begin
// sTD := '';
// cell := FCellMatrix[iRow][iCol];
// if cell.Visible then
// begin
// sTD := '<td';
// if cell.CSSClass <> '' then
// sTD := sTD + ' class="' + cell.CSSClass + '"'
// else if iRow <= (FTitleRows - 1) then
// sTD := sTD + ' class="thStyle"'
// else if FRows[iRow].IsCaptionRow then
// sTD := sTD + ' class="CaptionStyle"'
// else
// sTD := sTD + ' class="tdStyle"';
//
// if (cell.Alignment = taCenter) or (cell.ColSpan > 1) then
// s := ' align="center"'
// else if cell.Alignment = taRightJustify then
// s := ' align="right"'
// else
// s := '';
// sTD := sTD + s;
//
// if cell.RowSpan > 1 then
// sTD := sTD + Format(' rowspan="%d"', [cell.RowSpan]);
//
// if cell.ColSpan > 1 then
// sTD := sTD + Format(' colspan="%d"', [cell.ColSpan]);
//
// sTD := sTD + '>' + cell.GetStrValue + '</td>'#13#10;
// sTR := sTR + sTD;
// end;
// end;
// if sTR <> '' then
// begin
// sTR := '<tr>'#13#10 + sTR + '</tr>'#13#10;
// sRows := sRows + sTR;
// end;
// end;
// sTable := Stringreplace(htmTableCode, '@Caption@', '', []);
// sTable := Stringreplace(sTable, '@Rows@', sRows, []);
    sTable := TableCode;
    // Result := htmpagecode2;
    Result := Stringreplace(htmPageCode2, '@PageTitle@', '', []);
    Result := Stringreplace(Result, '@PageContent@', sTable, []);
end;

{ ==============================================================================
                <<<<<<<<<<<<<   TWebCrossView   >>>>>>>>>>>>>>>
  ClassName:    TWebCrossView
  Comment:
 =============================================================================== }
constructor TWebCrossView.Create;
begin
    inherited;
    FMatrix := nil;
    FColCount := 0;
    FRowCount := 0;
    FTitleRowCount := 1;
    FTitleColCount := -1;
end;

{ ----------------------------------------------------------------------------- }
destructor TWebCrossView.Destroy;
begin
    if Assigned(FMatrix) then
        FMatrix.Free;
    inherited;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossView.Reset;
begin
    FreeAndNil(FMatrix);
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossView.getRowCount: Integer;
begin
    Result := 0;
    if Assigned(FMatrix) then
        Result := FMatrix.RowCount;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossView.CreateMatrix;
begin
    FMatrix := TWebCrossMatrix.Create(FColCount);
    FMatrix.TitleCols := FTitleColCount;
    FMatrix.TitleRows := FTitleRowCount;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossView.AddRow(const ValueArray: array of Variant);
begin
    if not Assigned(FMatrix) then
        CreateMatrix;

    FMatrix.AddRow(ValueArray);
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossView.AddCaptionRow(CaptionArray: array of Variant);
begin
    if not Assigned(FMatrix) then
        CreateMatrix;
    FMatrix.AddCaptionRow(CaptionArray);
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossView.GetMatrixColHeader(ACol: Integer): TWebCrossHeader;
begin
    Result := nil;
    if not Assigned(FMatrix) then
        CreateMatrix;
        // FMatrix := TWebCrossMatrix.Create(FColCount);
    Result := FMatrix.ColHeader[ACol];
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossView.CrossGrid: string;
begin
    Result := '';
    if Assigned(FMatrix) then
        Result := FMatrix.TableCode;
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossView.CrossPage: string;
begin
    Result := '';
    if Assigned(FMatrix) then
        Result := FMatrix.HTMLCode;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossView.SetTitleRowCount(ACount: Integer);
begin
    FTitleRowCount := ACount;
    if Assigned(FMatrix) then
        FMatrix.TitleRows := ACount;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossView.SetTitleColCount(ACount: Integer);
begin
    FTitleColCount := ACount;
    if Assigned(FMatrix) then
        FMatrix.TitleCols := ACount;
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossView.BlankPage: string;
begin
    Result := htmPageCode2;
end;

end.
