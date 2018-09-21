unit uHJX.Template.XLGrid;

interface

uses
    System.Classes, System.Types, System.SysUtils, System.Variants,
    System.Generics.Collections, uHJX.Classes.Templates;

type
    { Ŀǰ֧�ֵ��������ͣ���̬�У���̬����̬��
      ��̬�б�Ŀǰ��֧�ֵ������·���չ���ṹ�̶����䣻
      ��̬��  �̶����еı������ռλ����д���ݣ�
      ��̬�б��������ҷ���չ���ṹ���䣻
      ���ڶ�̬����ͷ��ʽ�̶���������ʽ�����ӵı�����ģ�岻֧�֣�δ��Ҳ������֧�֡���Щ������
      ����ʹ�������ı������ʵ�֡�
 }
    TxlGridType = (xlgDynRow, xlgStatic, xlgDynCol);

    { Excel���ݱ�ģ�壬ֻ��¼���⡢��ͷ�������е�λ�÷�Χ�ȣ����岿�ֱ�����Excel worksheet�ĵ�Ԫ��
      �С�ʵ�ʴ�������һ����Ԫ�ṩ�� }
    TXLGridTemplate = class(ThjxTemplate)
    private
        // FTemplateName: string;  // template name
        FTempSheet    : string;      // template worksheet name
        FGridType     : TxlGridType; // grid type
        //FApplyToGroup : Boolean; 2018-09-21
        FTitleRect    : TRect;  // title range rect
        FHeadRect     : TRect;  // grid head range rect
        FDataRect     : TRect;  // data row rect
        FTitleRangeRef: string; // like ��A1:F1��
        FHeadRangeRef : string; // like "A2:F4"
        FDataRangeRef : string; // like "A5:F5"
        procedure SetTitleRange(ARef: string);
        procedure SetHeadRange(ARef: string);
        procedure SetDataRange(ARef: string);
    public
        // property TemplateName: string read FTemplateName write FTemplateName;
        constructor Create; override;
    published
        property TemplateSheet: string read FTempSheet write FTempSheet;
        property GridType     : TxlGridType read FGridType write FGridType;
        property TitleRect    : TRect read FTitleRect write FTitleRect;
        property HeadRect     : TRect read FHeadRect write FHeadRect;
        property DataRect     : TRect read FDataRect write FDataRect;
        property TitleRangeRef: string read FTitleRangeRef write SetTitleRange;
        property HeadRangeRef : string read FHeadRangeRef write SetHeadRange;
        property DataRangeRef : string read FDataRangeRef write SetDataRange;
        property ApplyGroup;// : Boolean;// read FApplyToGroup write FApplyToGroup;
    end;

implementation

{ �����ﵽEncodeCellRange��������nExcel��Ԫ����Ҫ������Excel���ø�ʽ�������ʽ֮��ת�� }
const
    XLSMaxRow: Word = 65535;
    XLSMaxCol: Byte = 255;
    XLSStrMax: Byte = 255;

    XLSXMaxRow: integer = $FFFFF;
    XLSXMaxCol: integer = $3FFF;

// cellref 'A1' cell address
// row, col -  zero-based indexes
function GetCellRef(cellref: string; var row: integer; var col: integer): integer;
var
    i, cnt    : integer;
    lrow, lcol: integer;
    ch        : char;
begin
    Result := 1;
    lcol := 0;
    lrow := 0;
    cnt := Length(cellref);
    i := 1;
  // Check length of cellref
    if cnt < 2 then Result := -1;

  // column index
    if Result = 1 then
    begin
     // skip $
        if cellref[i] = '$' then Inc(i);

        while i <= cnt do
        begin
            ch := cellref[i];
            if (ch >= 'A') and (ch <= 'Z') then
            begin
                lcol := lcol * 26 + Ord(ch) - Ord('A') + 1;
            end
            else if (ch >= 'a') and (ch <= 'z') then
            begin
                lcol := lcol * 26 + Ord(ch) - Ord('a') + 1;
            end
            else
            begin
                break;
            end;
            Inc(i);
        end;
        if lcol <= 0 then Result := -2
        else Dec(lcol);
    end;

    if Result = 1 then
    begin
     // skip $
        if cellref[i] = '$' then Inc(i);
        if i > cnt then Result := -3;
    end;

  // row index
    if Result = 1 then
    begin
        while i <= cnt do
        begin
            ch := cellref[i];
            if (ch >= '0') and (ch <= '9') then
            begin
                lrow := lrow * 10 + Ord(ch) - Ord('0');
            end
            else
            begin
                Result := -4;
                break;
            end;
            Inc(i);
        end;
        Dec(lrow);
    end;

    if Result = 1 then
    begin
     // Check row number
        if (lrow < 0) or (lrow > XLSXMaxRow) then Result := -5;
        if (lcol < 0) or (lcol > XLSXMaxCol) then Result := -6;
    end;

    if Result = 1 then
    begin
     // return the row and col numbers
        row := lrow;
        col := lcol;
    end;

end;

// Index - one-based index of column
// Result A-style column index
function ColIndexToColName(Index: integer): string;
begin
    Dec(index);
    if (index >= 0) and (index <= (XLSXMaxCol)) then
    begin
        Result := '' + chr((index mod 26) + Ord('A'));
        while index > 25 do
        begin
            index := (index div 26) - 1;
            Result := chr((index mod 26) + Ord('A')) + Result;
        end;
    end
    else
    begin
        Result := '';
    end;
end;

// name - A-style column index
// result - one-based column index
function ColNameToColIndex(Name: string): integer;
var
    i, cnt: integer;
    lcol  : integer;
    ch    : char;
begin
    lcol := 0;
    cnt := Length(name);
    i := 1;

  // column index
    if cnt >= 1 then
    begin
     // skip $
        if name[i] = '$' then Inc(i);
        while i <= cnt do
        begin
            ch := name[i];
            if (ch >= 'A') and (ch <= 'Z') then
            begin
                lcol := lcol * 26 + Ord(ch) - Ord('A') + 1;
            end
            else if (ch >= 'a') and (ch <= 'z') then
            begin
                lcol := lcol * 26 + Ord(ch) - Ord('a') + 1;
            end
            else
            begin
                lcol := -1;
                break;
            end;
            Inc(i);
        end;
    end;

    if (lcol > 0) and (lcol <= (XLSXMaxCol + 1)) then
    begin
        Result := lcol;
    end
    else
    begin
        Result := -1;
    end;

end;

// row, col - zero based indexes of row and column
function EncodeCellRef(row, col: integer): string;
begin
    Result := ColIndexToColName(col + 1);
    Result := Result + inttostr(row + 1);
end;

// value 'A1:A1' range
// r1, c1, r2, c2 -  zero-based indexes
function GetCellRange(Value: string; var r1, c1, r2, c2: integer): integer;
var
    cell1, cell2: string;
    i           : integer;
begin
    i := Pos(':', Value);
    if i > 0 then
    begin
        cell1 := Copy(Value, 1, i - 1);
        cell2 := Copy(Value, i + 1, Length(Value) - i);
        Result := GetCellRef(cell1, r1, c1);
        if Result = 1 then Result := GetCellRef(cell2, r2, c2);
    end
    else
    begin
        Result := GetCellRef(Value, r1, c1);
        if Result = 1 then
        begin
            r2 := r1;
            c2 := c1;
        end;
    end;
end;

// r1, c1, r2, c2: zero-based row/col indexes
function EncodeCellRange(r1, c1, r2, c2: integer): string;
var
    t: integer;
begin
    if (r1 < 0) or (r2 < 0) or (c1 < 0) or (c2 < 0) or (r1 > XLSXMaxRow) or (r2 > XLSXMaxRow) or
        (c1 > XLSXMaxCol) or (c2 > XLSXMaxCol) then
    begin
        Result := '';
    end
    else
    begin
        if r2 < r1 then
        begin
            t := r2;
            r2 := r1;
            r1 := t;
        end;
        if c2 < c1 then
        begin
            t := c2;
            c2 := c1;
            c1 := t;
        end;
        if (r1 = r2) and (c1 = c2) then
        begin
            Result := EncodeCellRef(r1, c1);
        end
        else
        begin
            Result := EncodeCellRef(r1, c1) + ':' + EncodeCellRef(r2, c2);
        end;
    end;
end;

constructor TXLGridTemplate.Create;
begin
    Self.Category := tplXLGrid;
    inherited;
end;

procedure TXLGridTemplate.SetTitleRange(ARef: string);
begin
    FTitleRangeRef := ARef;
    GetCellRange(ARef, FTitleRect.Top, FTitleRect.Left, FTitleRect.Bottom, FTitleRect.Right);
    // ע�⣺��ʱ�õ���TitleRect������ֵ����0Ϊ��㣬��Ҫ����ƫ��1
    FTitleRect.Offset(1, 1);
end;

procedure TXLGridTemplate.SetHeadRange(ARef: string);
begin
    FHeadRangeRef := ARef;
    GetCellRange(ARef, FHeadRect.Top, FHeadRect.Left, FHeadRect.Bottom, FHeadRect.Right);
    FHeadRect.Offset(1, 1)
end;

procedure TXLGridTemplate.SetDataRange(ARef: string);
begin
    FDataRangeRef := ARef;
    GetCellRange(ARef, FDataRect.Top, FDataRect.Left, FDataRect.Bottom, FDataRect.Right);
    FDataRect.Offset(1, 1);
end;

end.
