{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Template.WebGrid
 Author:    黄伟
 Date:      10-八月-2018
 Purpose:   解析WebGrid表格定义，分解为标题、表头、数据行三部分。当某仪器观测
            数据需要套用表格模板时，则由另一个单元进行匹配套用。

            目前表格模板不支持表格外观定义，仅能处理内容。外观定义需要TWebCrossView
            对象支持后才能支持，而该对象目前的外观是定死的，无法改变。

            对本模板类的处理由Functions的uHJX.Template.WebGridProc.pas单元完成，
            该单元中的GenWebGrid方法根据本模板对象中的表格定义创建表格，并填入
            数据。
 History:
----------------------------------------------------------------------------- }

unit uHJX.Template.WebGrid;

interface

uses
    System.Classes, System.Types, System.SysUtils, System.Variants,
    System.Generics.Collections {, System.RegularExpressions} , uHJX.Classes.Templates;

type
    { 2018-08-14暂不采用，将处理部分转移到处理单元中进行，使本单元适应性最大化
      若在此对单元格内容进行模式匹配处理，将限制模板定义的格式，如只能拥有一个占位符、符号级别只能
      有两级等。若不涉及对模板内容的处理，则模板适应性可最大化。
      单元格内容定义, 目前每个单元格仅支持一个占位符表示的待替换内容，不支持多个 }
    TCellRec = record
        Text: string;  // 原定义内容，其中可能包含了占位符%xxx%。将来处理时用实际内容替换掉
        Code: string;  // 即%xxx%的内容，若不包含此项，则为空
        Param: string; // 即%xxx%中百分号里面的xxx的部分(%xxx.yyy%的xxx.yyy部分)。
        Item1: string; // 即xxx.yyy中xxx部分，非此格式则等于Param
        Item2: string; // xxx.yyy中的yyy部分，若无则空
    end;

    { 表格行结构，表头和数据行使用此结构。数组Cols是每个行结构各个单元格内容，其实就是Cells }
    /// <summary>WebGrid模板表格行结构。WebGrid表格只能是动态行类型的表格，且目前只支持单行动态。
    /// 表头行和数据行具有相同的列数，本结构保存模板中行定义各列的内容（模板内容）。
    /// 对这些内容的处理由表格生成程序完成。
    /// </summary>
    TGridTemplateRow = record
        Cols: TArray<string>;
        // Cells: TArray<TCellRec>;
    end;

    { 表格模板对象 }
    /// <summary>本类继承自<see cref="ThjxTemplate"/>，用于WebGrid表格。
    /// 表格模板由标题行定义、表头行定义、数据行定义组成。本类将模板分解为上述
    /// 三个部分，其中表头行和数据行进一步分解为单元格。
    /// </summary>
    TWebGridTemplate = class(ThjxTemplate)
    private
        FTemplateStr: string;
        // FName        : string;
        FApplyToGroup: Boolean;
        // FMeterType   : String; // 目前只能针对一种类型，对于组无效。应考虑适应多种类型
    protected
        procedure SetTemplateStr(AStr: string); virtual;
        function GetHeadCell(ARow, ACol: Integer): string;
        function GetDataCell(ACol: Integer): string;
        function GetHeadRowCount: Integer;
    public
        Titles  : TStrings;
        Heads   : TArray<TGridTemplateRow>;
        DataRows: TArray<TGridTemplateRow>;
        ColCount: Integer;
        constructor Create; override;
        destructor Destroy; override;
        // property Name: string read FName write FName;
        property TemplateStr: string read FTemplateStr write SetTemplateStr;
        property HeadCell[ARow, ACol: Integer]: string read GetHeadCell;
        property DataCell[ACol: Integer]: string read GetDataCell;
        property HeadRowCount: Integer read GetHeadRowCount;
        // property MeterType: string read FMeterType;
        property ApplyToGroup: Boolean read FApplyToGroup;
    end;

implementation

const
    { 下面的正则表达式没用，真正用于模板匹配的参见uHJX.Template.ProcSpecifiers单元中的正则表达式 }
    RegExStr = '%(([a-zA-Z0-9]*)[\.]?([a-zA-Z0-9]*))%';

{ var
    RegEx: TRegEx; }

constructor TWebGridTemplate.Create;
begin
    inherited;
    Titles := TStringList.Create;

end;

destructor TWebGridTemplate.Destroy;
var
    i: Integer;
begin
    Titles.free;
    if Length(Heads) > 0 then
        for i := 0 to high(Heads) do SetLength(Heads[i].Cols, 0);
    SetLength(Heads, 0);

    if Length(DataRows) > 0 then
        for i := 0 to high(DataRows) do SetLength(DataRows[i].Cols, 0);
    SetLength(DataRows, 0);

    inherited;
end;

procedure TWebGridTemplate.SetTemplateStr(AStr: string);
var
    Rows       : TArray<string>;
    i, j, k    : Integer;
    id, content: string;
    Cols       : TArray<string>;
begin
    // 先清除#13#10等字符
    AStr := Trim(AStr);
    AStr := StringReplace(AStr, #13, '', [rfReplaceAll]);
    AStr := StringReplace(AStr, #10, '', [rfReplaceAll]);
    Rows := AStr.Split([';']);
    // 检查每一行，根据冒号前的标识符判断当前行为哪一类
    { todo: 需要增加足够的错误检查，并将检查结果作为消息传递出去 }
    for i := 0 to high(Rows) do
    begin
        j := pos(':', Rows[i]);
        if j = 0 then continue;
        id := Trim(copy(Rows[i], 1, j - 1));
        content := Trim(copy(Rows[i], j + 1, Length(Rows[i]) - j));
        if SameText(id, 'Name') then TemplateName := content
        else if SameText(id, 'MeterType') then MeterType := content
        else if SameText(id, 'ApplyTo') then
        begin
            if SameText(content, 'single') then FApplyToGroup := False
            else if SameText(content, 'Group') then FApplyToGroup := True;
        end
        else if SameText(id, 'Title') then Titles.add(content)
        else if SameText(id, 'Head') then
        begin
            Cols := content.Split(['|']);
            { todo: 检查Cols是否为空、数量是否与前面的保持一致 }
            // 去掉前后空格
            if Length(Cols) > 0 then
                for k := 0 to high(Cols) do Cols[k] := Trim(Cols[k]);
            SetLength(Heads, Length(Heads) + 1);
            SetLength(Heads[high(Heads)].Cols, high(Cols));
            Heads[high(Heads)].Cols := Cols;
        end
        else if SameText(id, 'DataRow') then
        begin
            Cols := content.Split(['|']);
            // 去掉前后空格
            if Length(Cols) > 0 then
                for k := 0 to high(Cols) do Cols[k] := Trim(Cols[k]);
            SetLength(DataRows, Length(DataRows) + 1);
            DataRows[high(DataRows)].Cols := Cols;
            ColCount := high(Cols) - low(Cols) + 1;
        end;
    end;
    SetLength(Rows, 0);
    SetLength(Cols, 0);
end;

function TWebGridTemplate.GetHeadRowCount: Integer;
begin
    if Length(Heads) = 0 then Result := 0
    else Result := high(Self.Heads) + 1;
end;

function TWebGridTemplate.GetDataCell(ACol: Integer): string;
begin
    Result := '';

    if Length(DataRows) > 0 then
        if Length(DataRows[0].Cols) > 0 then
            if (ACol >= 0) and (ACol <= high(DataRows[0].Cols)) then
                    Result := DataRows[0].Cols[ACol];
end;

function TWebGridTemplate.GetHeadCell(ARow: Integer; ACol: Integer): string;
begin
    Result := '';
    // 前两级if判断行有效；后两级if判断列有效
    if Length(Heads) > 0 then
        if (ARow >= 0) and (ARow <= high(Heads)) then
            if Length(Heads[ARow].Cols) > 0 then
                if (ACol >= 0) and (ACol <= high(Heads[ARow].Cols)) then
                        Result := Heads[ARow].Cols[ACol];
end;

end.
