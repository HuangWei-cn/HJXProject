{   本单元的XLGrid模板处理方法采用了class helper方式，提供了GenGrid方法，该方法根据模板创建XLS表格。
    要使用本单元，需要调用者引用。
}
unit uHJX.Template.XLGridHelper;

interface

uses
    System.Classes, System.Types, System.SysUtils, System.Variants, System.Generics.Collections,
    nExcel,
    uHJX.Template.XLGrid;

type
    { Gengrid方法完成根据模板创建数据表的工作，整个工作：从获取模板工作表，到创建工作表、填写数据
      等系列任务。对于调用者来说，只需要用T.GenGrid(BookName, DesignName)即可，返回值是创建的工作
      表名。BookName是成果工作簿名称，若存在则打开否则新建。
 }
    TXLGridTemplateHelper = class helper for TXLGridTemplate
    private
        // 处理标题和表头单元格，用真实信息替换占位符
        function ProcHeadCell(AValue: Variant): Variant;
        // 处理数据单元格，主要解析占位符
        function ProcDataCell(AValue: Variant): string;
        // 处理标题区
        procedure ProcTitleRange(Sht: IXLSWorksheet; AMeter: string);
        // 处理表头区
        procedure ProcHeadRange(Sht: IXLSWorksheet; AMeter: string);
        // 处理数据区单元格占位符，使之与字段联系起来
        procedure ProcDataRange(Sht: IXLSWorksheet; AMeter: string);
    public
        function GenGrid(NewBookName, ADsnName: string): string; overload;
        function GenGrid(NewBook: IXLSWorkbook; ADsnName: string): string; overload;
    end;

    { Test }
var
    TmpBookName: string; // this variable for test.
    TmpBook: IXLSWorkbook;

implementation

uses
    System.RegularExpressions;

const
    { 标题和表头占位符正则表达式，详细内容参考uHJX.Template.WGProc中的正则表达式注释 }
    RegExStr =
        '%([a-zA-Z]*|((Meter)([1-9][0-9]*)\.)?(DesignName|(PD|MD)([1-9][0-9]*)\.(Name|Alias|DataUnit)))%';

    { 数据单元占位符正则表达式，参见uhjx.template.wggrid中DataRowExStr的注释 }
    DataRegEStr = '%(DTScale|Annotation|((Meter)(n|[1-9][0-9]*)\.)?(PD|MD)([1-9][0-9]*))%';

type
    TXLDataCell = record
        Row, Col: Integer;
        OffsetStep: Integer;
        TempStr: string;
        Specifier: string;
        Field: TObject;
        GridType: TXLGridType;
        // Offset偏移数据单元格，如果是单行或单列，则偏移1行或1列，若是n行则偏移n行，这样可以实现
        // 多行或多列的动态。
        procedure Offset;
        function GetValue: Variant;
        procedure SetCellValue(Sht: IXLSWorksheet);
    end;

var
    RegEx: TRegEx;
    RegExData: TRegEx;
    MyColl: TMatchCollection;
    MyGrps: TGroupCollection;
    DataRange: TArray<TXLDataCell>;

function __GetSheet(ABook: IXLSWorkbook; SheetName: string): IXLSWorksheet;
var
    i: Integer;
begin
    Result := nil;
    i := ABook.WorkSheets.Index[SheetName];
    if i > 0 then Result := ABook.WorkSheets.Entries[i];
end;

function __HasSheet(ABook: IXLSWorkbook; AName: string): Boolean;
begin
    Result := False;
    if ABook.WorkSheets.Index[AName] > 0 then Result := True;
end;

// 返回可用的名称，如果AName存在，则自动添加序号，再查，直到没有为止
function __GetAltName(ABook: IXLSWorkbook; AName: string): string;
var
    i: Integer;
begin
    Result := AName;
    i := 0;
    repeat
        if __HasSheet(ABook, Result) then
        begin
            inc(i);
            Result := AName + IntToStr(i);
        end
        else Break;
    until False;
end;

function __DupWorksheet(SrcSheet: IXLSWorksheet; DesBook: IXLSWorkbook; NewSheetName: string)
    : IXLSWorksheet;
begin
    Result := nil;
    if (SrcSheet = nil) or (DesBook = nil) then Exit;

    Result := DesBook.WorkSheets.Add;

    // 检查是否存在重名工作表，若存在，则自动增加序号
    Result.Name := __GetAltName(DesBook, NewSheetName);

    // 从原表拷贝usedrange到新表
    with SrcSheet.UsedRange do
    begin
        Copy(Result.RCRange[FirstRow, FirstCol, LastRow + 1, LastCol + 1], xlPasteAll);
        Result.RCRange[FirstRow, FirstCol, LastRow + 1, LastCol + 1].Formula := Formula;
    end;
end;

{ 这个方法需要考虑到多行或多列偏移的问题 }
procedure TXLDataCell.Offset;
begin
    case GridType of
        xlgDynRow: inc(Row, OffsetStep);
        xlgStatic:;
        xlgDynCol: inc(Col, OffsetStep);
    end;
end;

{ 从字段中取回数据，填入单元格中，单元格的格式保持与模板的一致 }
function TXLDataCell.GetValue: Variant;
begin
    // Result := Null;
    Result := 'Test';
end;

procedure TXLDataCell.SetCellValue(Sht: IXLSWorksheet);
begin
    Sht.Cells[Self.Row, Self.Col].Value := GetValue;
end;

{ ================================================================================================ }
{ 解析Head和title单元格占位符，找到对应的Meter参数，返回该值 }
function __ProcHeadCell(AValue: Variant; AMeter: string): Variant;
var
    S: string;
    i: Integer;
begin
    Result := AValue;
    S := VarToStr(AValue);
    if S = '' then Exit;
    MyColl := RegEx.Matches(S);
    for i := 0 to MyColl.Count - 1 do
    begin
        MyGrps := MyColl.Item[i].Groups;
        case MyGrps.Count of
            2:
                begin
                    // 临时代码
                    if SameText(MyGrps.Item[1].Value, 'GroupName') then
                            Result := StringReplace(S, MyColl.Item[i].Value, 'GroupName',
                            [rfReplaceall])
                    else
                    begin
                        Result := StringReplace(S, MyColl.Item[i].Value, MyGrps.Item[1].Value,
                            [rfReplaceall]);
                    end;
                end;

            6: // 对应形式为%Meter1.DesignName%，特对应于仪器组
                begin
                    // 临时代码
                    Result := StringReplace(S, MyColl.Item[i].Value, MyGrps.Item[1].Value,
                        [rfReplaceall]);
                end;

            9:
                begin
                    // 临时代码
                    if MyGrps.Item[2].Value = '' then
                            Result := StringReplace(S, MyColl.Item[i].Value, MyGrps.Item[5].Value,
                            [rfReplaceall])
                    else Result := StringReplace(S, MyColl.Item[i].Value, MyGrps.Item[1].Value,
                            [rfReplaceall]);
                end;

        end;
    end;
end;

{ 解析数据区单元格占位符，填写到DataCell结构中对应的项：若有对应数据字段设置字段对象，若无则源内容
  为字符串，可以不用管，在填写数据方法中会将源区域拷贝到新位置 }
procedure __ProcDataCell(AValue: Variant; ACell: TXLDataCell);
var
    S: string;
begin
    S := VarToStr(AValue);
    ACell.TempStr := S;

    if S = '' then Exit;
    MyColl := RegEx.Matches(S);
    if MyColl.Count > 0 then
    begin
        ACell.Specifier := MyColl.Item[0].Value;
        // 这里假定每个单元格定义只包含一个占位符，且只包含一个字段。尽管实际上正则表达式可解析出多个
        // 占位符，但是为处理简单起见，规定只能包含一个字段，且整个单元格内容就是这个字段的数据。
        // 更复杂的处理以后再说，这种复杂性有多少用处？
        MyGrps := MyColl.Item[0].Groups;
        case MyGrps.Count of
            2:
                begin
                    ACell.Specifier := MyGrps.Item[1].Value;
                end;
            7:
                begin
                    ACell.Specifier := MyGrps.Item[1].Value;
                end;
        end;
    end;
end;

function TXLGridTemplateHelper.ProcHeadCell(AValue: Variant): Variant;
begin

end;

function TXLGridTemplateHelper.ProcDataCell(AValue: Variant): string;
begin

end;

procedure TXLGridTemplateHelper.ProcTitleRange(Sht: IXLSWorksheet; AMeter: string);
var
    iRow, iCol: Integer;
    S, Str: string;
begin
    for iCol := TitleRect.Left to TitleRect.Right do
        for iRow := TitleRect.top to TitleRect.Bottom do
            // Sht.Cells[iRow, iCol].Value := ProcHeadCell(Sht.Cells[iRow, iCol].Value);
                Sht.Cells[iRow, iCol].Value := __ProcHeadCell(Sht.Cells[iRow, iCol].Value, AMeter);
end;

procedure TXLGridTemplateHelper.ProcHeadRange(Sht: IXLSWorksheet; AMeter: string);
var
    iRow, iCol: Integer;
begin
    for iCol := HeadRect.Left to HeadRect.Right do
        for iRow := HeadRect.top to HeadRect.Bottom do
            // Sht.Cells[iRow, iCol].Value := ProcHeadCell(Sht.Cells[iRow, iCol].Value);
                Sht.Cells[iRow, iCol].Value := __ProcHeadCell(Sht.Cells[iRow, iCol].Value, AMeter);
end;

{ 处理数据区，本方法并不填写数据。本方法完成的工作是解析数据区各个单元格的占位符，将单元格和字段联系
  起来，需要填写数据时将字段数据填入即可。填写数据的方法是另外一个 }
procedure TXLGridTemplateHelper.ProcDataRange(Sht: IXLSWorksheet; AMeter: string);
var
    iRow, iCol: Integer;
    i, n: Integer;
    Offrow, Offcol: Integer;
    newRect: trect;
    SrcRange: IXLSRange;
    S: string;
    procedure CopyNewRange;
    begin
        newRect.top := newRect.top + Offrow;
        newRect.Left := newRect.Left + Offcol;
        newRect.Right := newRect.Right + Offcol;
        newRect.Bottom := newRect.Bottom + Offrow;
        SrcRange.Copy(Sht.RCRange[newRect.top, newRect.Left, newRect.Bottom, newRect.Right]);
    end;

begin
    SetLength(DataRange, 0);
    SetLength(DataRange, (DataRect.Width + 1) * (DataRect.Height + 1));
    // 处理占位符
    i := 0;
    for iCol := DataRect.Left to DataRect.Right do
        for iRow := DataRect.top to DataRect.Bottom do
        begin
            DataRange[i].Row := iRow;
            DataRange[i].Col := iCol;
            DataRange[i].TempStr := trim(VarToStr(Sht.Cells[iRow, iCol].Value));
            DataRange[i].Field := nil;
            DataRange[i].GridType := Self.GridType;

            case Self.GridType of
                xlgDynRow: DataRange[i].OffsetStep := DataRect.Bottom - DataRect.top + 1;
                xlgStatic: DataRange[i].OffsetStep := 0;
                xlgDynCol: DataRange[i].OffsetStep := DataRect.Right - DataRect.Left + 1;
            end;
            // 返回字段名
            // S := ProcDataCell(Sht.Cells[iRow, iCol].Value);
            __ProcDataCell(Sht.Cells[iRow, iCol].Value, DataRange[i]);
            if S <> '' then
            begin
                // datarange[i].Field := DS.FindField(s);
                DataRange[i].Specifier := 'Field: ' + S;
            end;
            inc(i);
        end;

    // 填入数据，直到完成任务
    SrcRange := Sht.RCRange[DataRect.top, DataRect.Left, DataRect.Bottom, DataRect.Right];
    Offrow := 0;
    Offcol := 0;
    newRect := DataRect;
    { newRect.Left := DataRect.Left;
      newRect.top := DataRect.top;
      newRect.Right := DataRect.Right;
      newRect.Bottom := DataRect.Bottom; }
    case GridType of
        xlgDynRow: Offrow := DataRect.Bottom - DataRect.top + 1;
        xlgDynCol: Offcol := DataRect.Right - DataRect.Left + 1;
    end;
    { srcrange := sht.rcrange[DataRect.Left, DataRect.Top, DataRect.Right, DataRect.Bottom];
      offrow := 0; offcol := 0;
      newrect.left := datarect.left;newrect.top:=datarect.top;newrect.right := datarect.right;
      newrect.bottom := datarect.bottom;
      case gridtype of
      xlgdynrow: offrow := datarect.bottom - datarect.top + 1;
      xlgdyncol: offcol := datarect.right -datarect.left + 1;
      end;
      if ds.recordcount > 0 then
      begin
      ds.first;
      repeat
      for i := 0 to High(DataRange) do
      begin
      Datarange[i].SetCellValue(sht);
      DataRange[i].Offset;
      end;
      ds.Next;

      if not ds.next then
      begin
      newrect.left := newrect + offcol;
      newrect.top ::= newrect.top + offrow;
      newrect.right := newrect.right + Offcol;
      newrect.bottom := newrect.bottom + offrow
      srcrange.copy(sht.rcrange[newrect.left,newrect.top,newrect.right,newrect.bottom]);
      end;
      until ds.eof;
      end;
 }
    for n := 0 to 5 do
    begin
        // copy source range to new position

        // fill datas
        for i := 0 to high(DataRange) do
        begin
            DataRange[i].SetCellValue(Sht);
            DataRange[i].Offset;
        end;
        // 从原数据区域拷贝格式和内容到新位置
        SrcRange.Copy(Sht.RCRange[newRect.top, newRect.Left, newRect.Bottom, newRect.Right]);
        newRect.Offset(Offcol, Offrow);
    end;
end;

// 根据模板创建数据表。 返回值为创建的工作表名称，即返回结果。
function TXLGridTemplateHelper.GenGrid(NewBookName, ADsnName: string): string;
var
    Book: IXLSWorkbook;
begin
    Result := '';
    Book := TXLSWorkbook.Create;

    if FileExists(NewBookName) then Book.Open(NewBookName)
    else Book.SaveAs(NewBookName);

    Result := GenGrid(Book, ADsnName);

    Book.Close;
    Book := nil;
end;

function TXLGridTemplateHelper.GenGrid(NewBook: IXLSWorkbook; ADsnName: string): string;
var
    tmpSheet, resSheet: IXLSWorksheet; // 模板工作表，成果工作表
begin
    Result := '';
    tmpSheet := __GetSheet(TmpBook, Self.TemplateSheet);
    if tmpSheet = nil then Exit;

    // 将模板工作表复制到新工作簿中，同时判断是否存在同名工作表
    resSheet := __DupWorksheet(tmpSheet, NewBook, ADsnName);
    if resSheet = nil then Exit;
    Result := resSheet.Name;

    // 处理标题、表头等静态部分，用各种参数替换占位符
    ProcTitleRange(resSheet, ADsnName);
    ProcHeadRange(resSheet, ADsnName);

    // 处理数据区
    // 先取数据，再填入
    ProcDataRange(resSheet, ADsnName);

    NewBook.Save;
    NewBook.Close;

end;

initialization

RegEx := TRegEx.Create(RegExStr);
RegExData := TRegEx.Create(DataRegEStr);

finalization

SetLength(DataRange, 0);

end.

