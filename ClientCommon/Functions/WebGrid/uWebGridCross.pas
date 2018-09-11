{ -----------------------------------------------------------------------------
 Unit Name: uWebGridCross
 Author:    Administrator
 Date:      17-ʮ����-2012
 Purpose:   ����Ԫ�ṩ����frxCrossView�Ĺ��ܣ�Ҳ�������Ƶ�ʹ�÷���������һ��
            ���ݱ��HTML���룬��������д��WebBrowser����ʾ֮��
            ����frxCrossView�����Ϊ�������֣�ColumnHeader, RowHeader, DataArea,
            ÿ���������ɶ�Ӧ��RowHeadֵ��ColHeadֵ��λ���������кŶ�λ�����
            ��ͬ�ĵ�Ԫ�񽫱��ϲ����ϲ�����˳�������к��С�

 History:
----------------------------------------------------------------------------- }
{ TODO: ���������ã��������ÿһ�����ö��롢��ʽ���Ƿ����������ںϡ������ںϵ� }
{ TODO: ĳЩ�������ں�����Ӧ����һ�ж�Ӧ����۲�����Ӧ��������Ŷ�Ӧ }
{ DONE: �������Caption Row�����к����ں���ͬ�ĵ�Ԫ�񣬺������ں����� }
{ TODO: �ɿ��ǽ�������Ϊ��ͷ�̶������ݿɹ��� }
{ TODO: �ɿ����ṩ���п��۵�div�ı����� }
{ DONE: ���Ӷ����ں͸������ݵĸ�ʽ���ַ��������ɹ������Զ�����֮ }
{ todo: ϣ�����ӵĸ��Ի����ԣ��������ɫ����ϸ����ͷ��ɫ����������ɫ����һ��Ԫ��
���塢��С�����塢б�塢��ɫ����һ��Ԫ���ɫ����Ե�Ԫ��Ķ��룻��������Padding;
��Ԫ�����С��� }
{ todo: ������TStringGrid��������Cell��ʽ���ʡ�������һ��Ԫ������Ժ�ֵ }
unit uWebGridCross;

interface

uses
    SysUtils, Classes, Variants;

type
    TWebCrossHeader = class;

    { ��Ԫ�������Matrix����ɲ��� }
    TWebCrossCell = class
    private
        FVisible  : Boolean;
        FColSpan  : Integer;
        FRowSpan  : Integer;
        FValue    : Variant;
        FcssClass : string;
        FAlign    : TAlignment;
        FColHeader: TWebCrossHeader;
        { todo:��Cell���������������С����ɫ�����塢б�塢����ɫ�ȼ������� }
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

    { ���ݾ��� }
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
        { Ԥ����Ԫ�����ݣ���Ҫ�Ǻϲ���Ԫ��֮��Ķ��� }
        procedure PreProcCells;
        procedure ResetCells;
        function GetColHeader(ACol: Integer): TWebCrossHeader;
    public
        constructor Create(AColumnCount: Integer);
        destructor Destroy; override;
        procedure AddRow(ValueArray: array of Variant); // ��Matrixβ�����һ��
        procedure AddCaptionRow(CaptionArray: array of Variant);
        function HTMLCode: string;
        { 2013-06-19 �����ر����룬������ҳ }
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
        FTitleRowCount: Integer;         // ��������
        FTitleColCount: Integer;         // ����������ָ��0�С�FTitleColCount-1Ϊ��������
        FMatrix       : TWebCrossMatrix; // ����ȫ�����ݵľ���
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
        { CrossGrid�������ر����룬������HTMLҳ��ı�ͷ����ʽ������Ȳ��� }
        function CrossGrid: string;
        { CrossPage��������������ҳ�档 }
        function CrossPage: string;
        { ���ؿյ�ҳ����룬�����������ϳɶ����������Ҫ�滻�������У�
          @PageTitle@��@PageContent@�����ַ�������ʵ�������滻���� }
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
    { ע�������CSS����ʹ�ñ�����ϸ�߱߿� }
    { ��Ա��ı�ͷ����Ԫ��ʹ����CSS���� }
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
        + '.CaptionStyle {font-family:����;font-size: 9pt;color: #000000; padding:3px;border:1px solid #000099; background-color:#FFFF99}'#13#10
        + '</style>'#13#10
        + '</head>'#13#10
        + '<body>'#13#10
        + '@PageContent@'#13#10
        + '</body>'#13#10
        + '</html>';

    { ������ }
    htmTableCode =
        '<table BORDER=0 CELLSPACING=0 CELLPADDING=0 BGCOLOR=#ADD8E6 class="DataGrid">'#13#10
    // BGCOLOR=#ECE9D8
        + '@Caption@'
        + '@Rows@'
        + '</table>';

    { ��Ԫ����� }
    htmTDCode = '<TD %Align% %Width% %BGCOLOR%>'
        + '<FONT STYLE="font-family: Tahoma; font-size: 8pt; color: #000000">'
        + '@Value@'
        + '</FONT></TD>';

    { ʹ��CSS�ĵ�Ԫ����룬ע����������Ԫ��������չ }
    htmTDCode2 = '<td %class% %Align% %Width% %BGCOLOR% %RowSpan% %ColSpan%>'
        + '@Value@' + '</td>'#13#10;

    { �д��� }
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
        Result := '��'
    else
    begin
        case VarType(FValue) of //
            varEmpty, varNull:
                Result := '��';
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
                    Result := '��'
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
  Description:	���һ�����ݡ�������û�ж�������������ж�λ��������������
  ��matrix��β�����Ұ�����˳����������ֵ��
----------------------------------------------------------------------------- }
procedure TWebCrossMatrix.AddRow(ValueArray: array of Variant);
var
    iRow, iCol: Integer;
begin
    Inc(FRowCount);
    { �������ݾ��� }
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

    { �������������� }
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
  Description:  ����һ��Caption�С�Caption��ͨ���Ǻ���ϲ���
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

    { ���CaptionArray��������ColCount����matrix������ֵ����CaptionArray�����һ�� }
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
  Description:  ��������������֮ǰ�Ծ������Ԥ������Ҫ�����úϲ����
  Ŀǰ��ֻ����Ԫ��Ҫô����(�кϲ�)��Ҫô����(�кϲ�)��������ͬʱ���кͿ���
  (��Ҫ��Ŀǰ��û���ҵ���ʱ���㷨);
----------------------------------------------------------------------------- }
procedure TWebCrossMatrix.PreProcCells;
var
    iRow, iCol, iLeftCol: Integer;
    iMCStart, iMC       : Integer;
    sValue, sCurValue   : string;
begin
    { �ȼ��ÿ���и��У����������Ƿ���ڿ��Ժϲ��ĵ�Ԫ�� }
    for iRow := 0 to FRowCount - 1 do
    begin
        sValue := '';
        iMCStart := -1;
        iMC := 1;
        for iCol := 0 to FColCount - 1 do
        begin
            { ������в��������ϲ�������֮ǰ�ĺϲ������Ǳ����в������� }
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
                { ��������һ�У�����ɱ��ּ�� }
                if iCol = (FColCount - 1) then
                    FCellMatrix[iRow][iMCStart].FColSpan := iMC;
            end;
        end;
    end;

    { �������У���������ͬ�ĵ�Ԫ������Ϊ�ϲ� }
    for iCol := 0 to FColCount - 1 do
    begin
        sValue := '';
        iMCStart := -1;
        iMC := 1;
        for iRow := 0 to FRowCount - 1 do
        begin
            { ����в���������ϲ�������Ϊ�����С�CaptionRow��next }
            if ((iRow > FTitleRows - 1) and (not FColHeaders[iCol].AllowColSpan))
                or (FRows[iRow].IsCaptionRow) then
            begin
                { �ϲ�֮ǰ�� }
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
                { ��������һ�У���������� }
                if iRow = (FRowCount - 1) then
                    FCellMatrix[iMCStart][iCol].FRowSpan := iMC;

                { ��������У����кϲ���Χ���ܳ�������������ϲ���Χ }
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
  Description:  �����������ر�����
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
    { todo:Ӧ���Ǳ���@Caption@�� }
    // sTable := htmTableCode;
    sTable := Stringreplace(htmTableCode, '@Caption@', '', []);
    sTable := Stringreplace(sTable, '@Rows@', sRows, []);
    Result := sTable;
end;

{ -----------------------------------------------------------------------------
  Procedure:    TWebCrossMatrix.HTMLCode
  Description:	����������HTML����
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
