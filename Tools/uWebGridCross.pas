{ -----------------------------------------------------------------------------
 Unit Name: uWebGridCross
 Author:    Administrator
 Date:      17-十二月-2012
 Purpose:   本单元提供类似frxCrossView的功能，也采用类似的使用方法，产生一个
            数据表的HTML代码，供调用者写入WebBrowser以显示之。
            类似frxCrossView，表分为三个部分：ColumnHeader, RowHeader, DataArea,
            每个数据项由对应的RowHead值和ColHead值定位，或由行列号定位。最后，
            相同的单元格将被合并，合并优先顺序是先行后列。

 History:   2020-1-17 可以直接向CrossView的Cell中填写数据了，而不必先定义一个
            Variant数组，再用AddRow方式逐行添加数据。允许先添加一个空行，然后
            再填写Cell。
            表格样式的改变：
            1、表格的Margin改为0px，这样拷贝到Word后，表格内容的段落属性的段前
               段后为0，总算正常了；
            2、TH，TD的Padding改为1px，这样在word中的表格padding为0.03mm，显得
               紧凑多了；
            3、允许用户定义表头、表体的字体名、字体大小、字体颜色、背景颜色；
            4、允许用户定义表格线颜色；
            5、允许用户直接指定某个单元格的字体颜色、背景颜色、字体大小等属性
----------------------------------------------------------------------------- }
{ TODO: 增加列设置，可以针对每一列设置对齐、格式、是否允许纵向融合、横向融合等 }
{ TODO: 某些列纵向融合设置应与另一列对应，如观测日期应和仪器编号对应 }
{ DONE: 允许插入Caption Row，该行横向融合相同的单元格，忽略列融合设置 }
{ TODO: 可考虑将表格调整为表头固定，内容可滚动 }
{ TODO: 可考虑提供带有可折叠div的表格代码 }
{ DONE: 增加对日期和浮点数据的格式化字符串，生成过程中自动设置之 }
{ DONE: 增加改变特定单元格内容字体、颜色的功能 }
{ todo: 增加单元格内容为超链接的功能 }
unit uWebGridCross;

interface

uses
  SysUtils, Classes, Variants, System.UITypes, System.UIConsts, Vcl.Graphics;

type
  TWebCrossHeader = class;
  TWebCrossView   = class;

  // 格式定义结构，暂时不包含Padding设置、表格线等更细致的内容
  // 同时，在本程序中规定，单元格等颜色不允许出现0，若FormatStyle中的Color=0，则忽略这个设置。因为
  // 缺省颜色为0，无需再设置。BGColor的缺省颜色为白色，即#FFFFFF。
  TWGFormatStyle = record
    FontName: string;
    FontSize: Integer;
    FontColor: TColor;
    FontStyle: TFontStyles;
    BGColor: TColor;
    procedure Init;
    function RGB2Color(R, G, B: Byte): TColor;
    function Color2HTML(Color: TColor): string;
    function FontSettedup: Boolean;
  end;

  PWGFormatStyle = ^TWGFormatStyle;

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
    // --- 2019-12-21 ----
    FHyperLink : string;
    FFontColor : LongInt;
    FFontStyles: TFontStyles;
    FFontSize  : Integer;
    FFontName  : string;
    FBackColor : LongInt;

    FFormatStyle: PWGFormatStyle;
    // -------------------
    function IsNull: Boolean;
    function GetStrValue: string;
  public
    constructor Create;
    destructor Destroy; override;
    property Value: Variant read FValue write FValue;
    property StrValue: string read GetStrValue;
    property Visible: Boolean read FVisible write FVisible;
    property ColSpan: Integer read FColSpan write FColSpan;
    property RowSpan: Integer read FRowSpan write FRowSpan;
    property Alignment: TAlignment read FAlign write FAlign;
    property CSSClass: string read FcssClass write FcssClass;
    property ColHeader: TWebCrossHeader read FColHeader write FColHeader;
    property FormatStyle: PWGFormatStyle read FFormatStyle write FFormatStyle;
  end;

  // CrossHeader对象实际上是用来确定某一列的某些共同属性
  TWebCrossHeader = class
    Align: TAlignment;
    FormatStr: string;
    AllowColSpan: Boolean;
    AllowRowSpan: Boolean;
    ColumnFormat: PWGFormatStyle; // 2020-1-20
    constructor Create;
    destructor Destroy; override;
  end;

  // CrossRow对象目前仅仅用来标识某一行是否是标题行或表格的脚行，暂时没有其他用途
  PWebCrossRow = ^TWebCrossRow;

  TWebCrossRow = record
    IsCaptionRow: Boolean;
    IsHeader: Boolean;
    IsFooter: Boolean;
    function IsBody: Boolean;
  end;

    { 数据矩阵 }
  TWebCrossMatrix = class
  private
    FCrossView : TWebCrossView;
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
    function GetCells(ACol, ARow: Integer): TWebCrossCell;
  public
    constructor Create(Owner: TWebCrossView; AColumnCount: Integer);
    destructor Destroy; override;

    procedure AddRow(ValueArray: array of Variant); overload; // 向Matrix尾部添加一行
    procedure AddRow; overload; { 2019-12-21 }
    procedure AddCaptionRow(CaptionArray: array of Variant); overload; // 添加中间标题行
    procedure AddCaptionRow; overload; // 2019-12-21

    function HTMLCode: string;
        { 2013-06-19 仅返回表格代码，而非整页 }
    function TableCode: string;

    property CrossView: TWebCrossView read FCrossView write FCrossView;
    property RowCount: Integer read FRowCount;
    property ColCount: Integer read FColCount;
    property TitleRows: Integer read FTitleRows write FTitleRows;
    property TitleCols: Integer read FTitleCols write FTitleCols;
    property ColHeader[ACol: Integer]: TWebCrossHeader read GetColHeader;

    { 2019-12-21 }
    property Cells[ACol, ARow: Integer]: TWebCrossCell read GetCells;
  end;

  TWebCrossView = class
  private
    FColCount     : Integer;
    FRowCount     : Integer;
    FTitleRowCount: Integer;         // 标题行数
    FTitleColCount: Integer;         // 标题列数：指从0列～FTitleColCount-1为标题列数
    FMatrix       : TWebCrossMatrix; // 保存全部内容的矩阵
    // 2020-1-20
    FHeadFmtSty: PWGFormatStyle; // 标题行格式
    FBodyFmtSty: PWGFormatStyle; // 表格内容格式
    FFootFmtSty: PWGFormatStyle; // 底行格式
    // 2020-5-18
    FBorderColor: TColor;
    function getRowCount: Integer;
    procedure CreateMatrix;
    function GetMatrixColHeader(ACol: Integer): TWebCrossHeader;
    function GetMatrixCells(ACol, ARow: Integer): TWebCrossCell;
    procedure SetTitleRowCount(ACount: Integer);
    procedure SetTitleColCount(ACount: Integer);
  protected
    // 为Matrix准备Page页面代码，主要是需要根据FormatStyle设置其中的字体、颜色等内容
    function PrePageHTML: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    procedure AddRow(const ValueArray: array of Variant); overload;
    procedure AddRow; overload;
    procedure AddCaptionRow(CaptionArray: array of Variant); overload;
    procedure AddCaptionRow; overload;
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
    property ColHeader[ACol: Integer]: TWebCrossHeader read GetMatrixColHeader;
    property Cells[ACol, ARow: Integer]: TWebCrossCell read GetMatrixCells;
     // 2020-1-20
    property HeadFormat: PWGFormatStyle read FHeadFmtSty write FHeadFmtSty;
    property BodyFormat: PWGFormatStyle read FBodyFmtSty write FBodyFmtSty;
    property FootFormat: PWGFormatStyle read FFootFmtSty write FFootFmtSty;

    property BorderColor: TColor read FBorderColor write FBorderColor;
  end;

implementation

const
    { 注：这里的CSS设置使得表格呈现细线边框 }
    { 针对表格的表头、单元格使用了CSS定义 }
  htmPageCode2 = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10 + '<html>'#13#10 +
    '<head>'#13#10 + '<meta http-equiv="Content-Type" content="text/html; charset=GB2312" />'#13#10
    + '@PageTitle@'#13#10 + '<style type="text/css">'#13#10 +
    '.DataGrid {border:1px solid #000099;border-width:1px 1px 1px 1px;margin:1px 1px 1px 1px;border-collapse:collapse}'#13#10
    + '.thStyle {font-size: 8pt; font-family: Tahoma; color: #000000; padding:3px;border:1px solid #000099}'#13#10
    + '.tdStyle {font-size: 8pt; font-family: Tahoma; color: #000000; background-color:#FFFFFF;empty-cells:show;'
    // #F7F7F7
    + '          border:1px solid #000099; padding:3px}'#13#10 +
    '.CaptionStyle {font-family:黑体;font-size: 9pt;color: #000000; padding:3px;border:1px solid #000099; background-color:#FFFF99}'#13#10
    + '</style>'#13#10 + '</head>'#13#10 + '<body>'#13#10 + '@PageContent@'#13#10 + '</body>'#13#10
    + '</html>';

  { 新的页面代码，允许用户自行设置表格样式，如字体、字体大小、背景颜色、线框颜色等 }
  htmPageCode3 = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10 + '<html>'#13#10 +
    '<head>'#13#10 + '<meta http-equiv="Content-Type" content="text/html; charset=GB2312" />'#13#10
    + '@PageTitle@'#13#10 + '<style type="text/css">'#13#10 +
    '.DataGrid {border:1px solid @bordercolor@;border-width:1px 1px 1px 1px;margin:0px 0px 0px 0px;border-collapse:collapse}'#13#10
    + '.thStyle {font-size: @headfontsize@; font-family: @headfontname@; color: @headfontcolor@; background-color:@headbkcolor@;padding:1px;border:1px solid @bordercolor@}'#13#10
    + '.tdStyle {font-size: @cellfontsize@; font-family: @cellfontname@; color: @cellfontcolor@; background-color:@cellbkcolor@;empty-cells:show;'
    + '          border:1px solid @bordercolor@; padding:1px}'#13#10 +
    '.CaptionStyle {font-family:黑体;font-size: 9pt;color: #000000; padding:0px;border:1px solid #000099; background-color:#FFFF99}'#13#10
    + '</style>'#13#10 + '</head>'#13#10 + '<body>'#13#10 + '@PageContent@'#13#10 + '</body>'#13#10
    + '</html>';

    { 表格代码 }
  htmTableCode =
    '<table BORDER=0 CELLSPACING=0 CELLPADDING=0 class="DataGrid">'#13#10 { BGCOLOR=#ADD8E6 }
    + '@Caption@' + '@Rows@' + '</table>';

    { 单元格代码 }
  htmTDCode = '<TD %clsname% %Align% %Width% %BGCOLOR%>' +
    '<FONT STYLE="font-family: Tahoma; font-size: 8pt; color: #000000">' + '@Value@' +
    '</FONT></TD>';

    { 使用CSS的单元格代码，注意这里允许单元格行列扩展 }
  htmTDCode2 = '<td %class% %Align% %Width% %BGCOLOR% %RowSpan% %ColSpan%>' + '@Value@' +
    '<td>'#13#10;

    { 行代码 }
  htmTRCode = '<TR>'#13#10 + '@Cells@'#13#10 + '</TR>'#13#10;

  htmHeadClass = 'class="thStyle"';
  htmTDClass   = 'class="tdStyle"';

function ColorToHTML(Color: TColor): string;
var
  R, G, B: Byte;
  rgb    : LongInt;
begin
  rgb := ColorToRGB(Color);
  R := rgb and $FF;
  G := (rgb shr 8) and $FF;
  B := (rgb shr 16) and $FF;
  Result := Format('#%.2x%.2x%.2x', [R, G, B]);
end;

procedure TWGFormatStyle.Init;
begin
  FontColor := clBlack;
  BGColor := clWhite;
  FontName := '';
  FontSize := 0;
  FontStyle := [];
end;

function TWGFormatStyle.RGB2Color(R: Byte; G: Byte; B: Byte): TColor;
begin
  Result := R + G shl 8 + B shl 16;
end;

function TWGFormatStyle.Color2HTML(Color: TColor): string;
begin
  Result := ColorToHTML(Color);
end;

function TWGFormatStyle.FontSettedup: Boolean;
begin
  Result := False;
  if FontName <> '' then Result := True
  else if FontSize <> 0 then Result := True
  else if FontColor <> clBlack then Result := True;
end;

function TWebCrossRow.IsBody: Boolean;
begin
  Result := not(IsHeader or IsCaptionRow or IsFooter);
end;

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
  New(FFormatStyle);
  FFormatStyle.Init;
end;

destructor TWebCrossCell.Destroy;
begin
  Dispose(FFormatStyle);
  inherited;
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossCell.IsNull: Boolean;
begin
  Result := VarIsNull(FValue);
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossCell.GetStrValue: string;
begin
  if IsNull then Result := '　'
  else
  begin
    case VarType(FValue) of //
      varEmpty, varNull: Result := '　';
      varSmallInt, varInteger, varShortInt, varByte, varWord, varLongWord, varInt64:
        Result := IntToStr(FValue);
      varSingle, varDouble, varCurrency: if ColHeader.FormatStr <> '' then
            Result := FormatFloat(ColHeader.FormatStr, FValue)
        else Result := FormatFloat('0.00', FValue);
      varDate: if ColHeader.FormatStr <> '' then
            Result := FormatDateTime(ColHeader.FormatStr, FValue)
        else Result := FormatDateTime('yyyy-mm-dd hh:mm:ss', FValue);
      varBoolean: Result := Booltostr(FValue);
      varString, varOLEStr: if Trim(FValue) = '' then Result := '　'
        else Result := FValue;
      varUnknown: Result := ' ';
    else Result := VartoStr(FValue);
    end; // case
  end;
end;

constructor TWebCrossHeader.Create;
begin
  inherited;
  New(ColumnFormat);
end;

destructor TWebCrossHeader.Destroy;
begin
  Dispose(ColumnFormat);
  inherited;
end;

{ ==============================================================================
                <<<<<<<<<<<<<   TWebCrossMatrix   >>>>>>>>>>>>>>>
  ClassName:    TWebCrossMatrix
  Comment:
 =============================================================================== }
constructor TWebCrossMatrix.Create(Owner: TWebCrossView; AColumnCount: Integer);
var
  i: Integer;
begin
  inherited Create;
  FCrossView := Owner;
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
      ColumnFormat.Init;
    end;
  end;
end;

{ ----------------------------------------------------------------------------- }
destructor TWebCrossMatrix.Destroy;
var
  i, j: Integer;
begin
  if Length(FCellMatrix) > 0 then
    for i := low(FCellMatrix) to high(FCellMatrix) do
    begin
      for j := low(FCellMatrix[i]) to high(FCellMatrix[i]) do FCellMatrix[i][j].Free;
      SetLength(FCellMatrix[i], 0);
    end;

  SetLength(FCellMatrix, 0);

  if Length(FColHeaders) > 0 then
    for i := low(FColHeaders) to high(FColHeaders) do FColHeaders[i].Free;
  SetLength(FColHeaders, 0);

  if Length(FRows) > 0 then
    for i := low(FRows) to high(FRows) do Dispose(FRows[i]);
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
  for iCol := low(FCellMatrix[iRow]) to high(FCellMatrix[iRow]) do
  begin
    FCellMatrix[iRow][iCol] := TWebCrossCell.Create;
    FCellMatrix[iRow][iCol].ColHeader := Self.ColHeader[iCol];
    FCellMatrix[iRow][iCol].Alignment := Self.ColHeader[iCol].Align;
  end;
    // if Varisarray(ValueArray) then
  for iCol := low(ValueArray) to high(ValueArray) do
      FCellMatrix[iRow][iCol].Value := ValueArray[iCol];

  { 设置行属性数组 }
  SetLength(FRows, FRowCount);
  New(FRows[FRowCount - 1]);
  with FRows[FRowCount - 1]^ do
  begin
    IsCaptionRow := False;
    IsFooter := False;
    if FRowCount <= FTitleRows then IsHeader := True;
  end; // with
end;

procedure TWebCrossMatrix.AddRow;
var
  iRow, iCol: Integer;
begin
  Inc(FRowCount);
  SetLength(FCellMatrix, FRowCount);
  iRow := FRowCount - 1;
  SetLength(FCellMatrix[iRow], FColCount);
  for iCol := low(FCellMatrix[iRow]) to high(FCellMatrix[iRow]) do
  begin
    FCellMatrix[iRow][iCol] := TWebCrossCell.Create;
    FCellMatrix[iRow][iCol].ColHeader := Self.ColHeader[iCol];
    FCellMatrix[iRow][iCol].Alignment := Self.ColHeader[iCol].Align;
  end;
  SetLength(FRows, FRowCount);
  New(FRows[FRowCount - 1]);
  with FRows[FRowCount - 1]^ do
  begin
    IsCaptionRow := False;
    IsFooter := False;
    if FRowCount <= FTitleRows then IsHeader := True;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure:    TWebCrossMatrix.AddCaptionRow
  Description:  增加一个Caption行。Caption行通常是横向合并的
----------------------------------------------------------------------------- }
procedure TWebCrossMatrix.AddCaptionRow(CaptionArray: array of Variant);
var
  iRow, iCol: Integer;
  n1        : Integer;
begin
  Inc(FRowCount);
  SetLength(FCellMatrix, FRowCount);
  iRow := FRowCount - 1;
  SetLength(FCellMatrix[iRow], FColCount);
  for iCol := 0 to FColCount - 1 do FCellMatrix[iRow][iCol] := TWebCrossCell.Create;

    { 如果CaptionArray数量少于ColCount，则matrix其余数值等于CaptionArray的最后一项 }
  if high(CaptionArray) < FColCount - 1 then n1 := high(CaptionArray)
  else n1 := FColCount - 1;

  for iCol := 0 to n1 do FCellMatrix[iRow][iCol].Value := CaptionArray[iCol];

  for iCol := n1 + 1 to FColCount - 1 do FCellMatrix[iRow][iCol].Value := CaptionArray[n1];

  SetLength(FRows, FRowCount);
  New(FRows[iRow]);
  FRows[iRow].IsCaptionRow := True;
  FRows[iRow].IsHeader := False;
  FRows[iRow].IsFooter := False;
end;

procedure TWebCrossMatrix.AddCaptionRow;
var
  iRow, iCol: Integer;
begin
  Inc(FRowCount);
  SetLength(FCellMatrix, FRowCount);
  iRow := FRowCount - 1;
  SetLength(FCellMatrix[iRow], FColCount);
  for iCol := 0 to FColCount - 1 do FCellMatrix[iRow][iCol] := TWebCrossCell.Create;
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
    if ACol <= high(FColHeaders) then Result := FColHeaders[ACol];
end;

function TWebCrossMatrix.GetCells(ACol: Integer; ARow: Integer): TWebCrossCell;
begin
  Result := nil;
  if Length(FCellMatrix) = 0 then Exit;
  // 数组下标超限检查
  if ARow < 0 then raise Exception.Create('行数不能小于零');
  if ARow > FRowCount - 1 then raise Exception.Create('行数超限');
  if ACol < 0 then raise Exception.Create('列不能小于零');
  if ACol > FColCount - 1 then raise Exception.Create('列数超限');
  Result := FCellMatrix[ARow][ACol];
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
        if iCol = (FColCount - 1) then FCellMatrix[iRow][iMCStart].FColSpan := iMC;
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
      if ((iRow > FTitleRows - 1) and (not FColHeaders[iCol].AllowColSpan)) or
        (FRows[iRow].IsCaptionRow) then
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

      if FCellMatrix[iRow][iCol].ColSpan > 1 then Continue;

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
        if iRow = (FRowCount - 1) then FCellMatrix[iMCStart][iCol].FRowSpan := iMC;

        { 检查左侧的列，本列合并范围不能超过左侧各列纵向合并范围，但对标题行没有限制 }
        if iRow > FTitleRows - 1 then
          if iCol > 0 then
            for iLeftCol := 0 to iCol - 1 do
              if ColHeader[iLeftCol].AllowColSpan then
              begin
                if (FCellMatrix[iRow][iLeftCol].Visible) { and
                            (FCellMatrix[iRow][iLeftCol].FRowSpan = 1) } then
                begin
                  if iMCStart <> -1 then FCellMatrix[iMCStart][iCol].FRowSpan := iMC - 1;
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
// TDCode = '<td @cls @colspan @rowspan @align>@var</td>'#13#10;
  fntSty  = '<font STYLE="font-family:@fontname@; font-size:@fontsize@pt; color:@fontcolor@">';
  fntSty2 = '<font STYLE="@fontfamily@@fontsize@@fontcolor@">';
var
  sTR, sTD, sTable, sRows, s: string;
  iRow, iCol                : Integer;
  cell                      : TWebCrossCell;
  bSetFontStyle             : Boolean;
  function __GetFontStyleLabel(AStyle: TWGFormatStyle): string;
  var
    _s: string;
  begin
    Result := fntSty2;
    if AStyle.FontName = '' then Result := StringReplace(Result, '@fontfamily@', '', [])
    else
    begin
      _s := 'font-family:' + AStyle.FontName + ';';
      Result := StringReplace(Result, '@fontfamily@', _s, []);
    end;
    if AStyle.FontSize = 0 then Result := StringReplace(Result, '@fontsize@', '', [])
    else
    begin
      _s := 'font-size:' + IntToStr(AStyle.FontSize) + 'pt;';
      Result := StringReplace(Result, '@fontsize@', _s, []);
    end;
    if AStyle.FontColor = clBlack then Result := StringReplace(Result, '@fontcolor@', '', [])
    else
    begin
      _s := 'color:' + AStyle.Color2HTML(AStyle.FontColor) + ';';
      Result := StringReplace(Result, '@fontcolor@', _s, []);
    end;
  end;

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
        // 添加class属性
        if cell.CSSClass <> '' then sTD := sTD + ' class="' + cell.CSSClass + '"'
        else if iRow <= (FTitleRows - 1) then sTD := sTD + ' class="thStyle"'
        else if FRows[iRow].IsCaptionRow then sTD := sTD + ' class="CaptionStyle"'
        else sTD := sTD + ' class="tdStyle"';

        // 添加Align属性
        if (cell.Alignment = taCenter) or (cell.ColSpan > 1) or (iRow <= (FTitleRows - 1)) then
            s := ' align="center"'
        else if cell.Alignment = taRightJustify then s := ' align="right"'
        else s := '';
        sTD := sTD + s;

        // 行合并或列合并
        if cell.RowSpan > 1 then sTD := sTD + Format(' rowspan="%d"', [cell.RowSpan]);

        if cell.ColSpan > 1 then sTD := sTD + Format(' colspan="%d"', [cell.ColSpan]);

        // 背景颜色
        s := '';
        if cell.FFormatStyle.BGColor <> clWhite then // 如果单独设置，则
            s := ' BGCOLOR=' + cell.FFormatStyle.Color2HTML(cell.FFormatStyle.BGColor)
        else if FRows[iRow].IsHeader then // 如果是标题行，则
        begin
          // 标题行如果没有单独设置，则已经在初始阶段在class中设置过了。
          s := '';
        end
        else if FRows[iRow].IsBody then
        begin
          with cell.ColHeader.ColumnFormat^ do
            if BGColor <> clWhite then s := ' BGCOLOR=' + Color2HTML(BGColor);
        end;
        sTD := sTD + s;

        // 字体样式：若单元格有设置，则按单元格设置来；若列有设置，所有非表头单元格按列设置；其他按整表设置
        bSetFontStyle := False;
        s := '';
        if cell.FFormatStyle^.FontSettedup then
        begin
          bSetFontStyle := True;
          s := __GetFontStyleLabel(cell.FFormatStyle^);
        end
        else if FRows[iRow].IsBody and cell.ColHeader.ColumnFormat.FontSettedup then
        begin
          bSetFontStyle := True;
          s := __GetFontStyleLabel(cell.ColHeader.ColumnFormat^);
        end;
        // 结束定义，并合并数据
        if bSetFontStyle then sTD := sTD + '>' + s + cell.GetStrValue + '</font></td>'#13#10
        else sTD := sTD + '>' + cell.GetStrValue + '</td>'#13#10;
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
  sTable := StringReplace(htmTableCode, '@Caption@', '', []);
  sTable := StringReplace(sTable, '@Rows@', sRows, []);
  Result := sTable;
end;

{ -----------------------------------------------------------------------------
  Procedure:    TWebCrossMatrix.HTMLCode
  Description:	本方法生成HTML代码
----------------------------------------------------------------------------- }
function TWebCrossMatrix.HTMLCode: string;
var
  sTable: string;
  sPage : string;
begin
  Result := '';
  { 2020-1-21 页面代码由CrossView提供，它根据用户预定义的格式从模板中生成一般样式定义 }
  sPage := FCrossView.PrePageHTML;
  sTable := TableCode;
  Result := StringReplace(sPage, '@PageTitle@', '', []);
  Result := StringReplace(Result, '@PageContent@', sTable, []);
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
  New(FHeadFmtSty);
  New(FBodyFmtSty);
  New(FFootFmtSty);
  FHeadFmtSty.Init;
  FBodyFmtSty.Init;
  FFootFmtSty.Init;
  FBorderColor := clBlack;
end;

{ ----------------------------------------------------------------------------- }
destructor TWebCrossView.Destroy;
begin
  if Assigned(FMatrix) then FMatrix.Free;
  Dispose(FHeadFmtSty);
  Dispose(FBodyFmtSty);
  Dispose(FFootFmtSty);
  inherited;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossView.Reset;
begin
  FreeAndNil(FMatrix);
  FColCount := 0;
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossView.getRowCount: Integer;
begin
  Result := 0;
  if Assigned(FMatrix) then Result := FMatrix.RowCount;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossView.CreateMatrix;
begin
  FMatrix := TWebCrossMatrix.Create(Self, FColCount);
  FMatrix.TitleCols := FTitleColCount;
  FMatrix.TitleRows := FTitleRowCount;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossView.AddRow(const ValueArray: array of Variant);
begin
  if not Assigned(FMatrix) then CreateMatrix;

  FMatrix.AddRow(ValueArray);
end;

procedure TWebCrossView.AddRow;
begin
  if not Assigned(FMatrix) then CreateMatrix;
  FMatrix.AddRow;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossView.AddCaptionRow(CaptionArray: array of Variant);
begin
  if not Assigned(FMatrix) then CreateMatrix;
  FMatrix.AddCaptionRow(CaptionArray);
end;

procedure TWebCrossView.AddCaptionRow;
begin
  if not Assigned(FMatrix) then CreateMatrix;
  FMatrix.AddCaptionRow;
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossView.GetMatrixColHeader(ACol: Integer): TWebCrossHeader;
begin
  Result := nil;
  if not Assigned(FMatrix) then CreateMatrix;
  // FMatrix := TWebCrossMatrix.Create(FColCount);
  Result := FMatrix.ColHeader[ACol];
end;

function TWebCrossView.GetMatrixCells(ACol: Integer; ARow: Integer): TWebCrossCell;
begin
  Result := nil;
  if not Assigned(FMatrix) then CreateMatrix;
  Result := FMatrix.Cells[ACol, ARow];
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossView.CrossGrid: string;
begin
  Result := '';
  if Assigned(FMatrix) then Result := FMatrix.TableCode;
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossView.CrossPage: string;
begin
  Result := '';
  if Assigned(FMatrix) then Result := FMatrix.HTMLCode;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossView.SetTitleRowCount(ACount: Integer);
begin
  FTitleRowCount := ACount;
  if Assigned(FMatrix) then FMatrix.TitleRows := ACount;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebCrossView.SetTitleColCount(ACount: Integer);
begin
  FTitleColCount := ACount;
  if Assigned(FMatrix) then FMatrix.TitleCols := ACount;
end;

{ ----------------------------------------------------------------------------- }
function TWebCrossView.BlankPage: string;
begin
  Result := htmPageCode2;
end;

function TWebCrossView.PrePageHTML: string;
  procedure _ReplaceFontName(ARep: string; AStyle: TWGFormatStyle);
  begin
    if AStyle.FontName = '' then Result := StringReplace(Result, ARep, 'Verdana', [])
    else Result := StringReplace(Result, ARep, AStyle.FontName, []);
  end;
  procedure _ReplaceFontSize(ARep: string; AStyle: TWGFormatStyle);
  begin
    if AStyle.FontSize = 0 then Result := StringReplace(Result, ARep, '9pt', [])
    else Result := StringReplace(Result, ARep, IntToStr(AStyle.FontSize), []);
  end;
  procedure _ReplaceFontColor(ARep: string; AStyle: TWGFormatStyle);
  begin
    if AStyle.FontColor = clBlack then Result := StringReplace(Result, ARep, '#000000', [])
    else Result := StringReplace(Result, ARep, AStyle.Color2HTML(AStyle.FontColor), []);
  end;
  procedure _ReplaceBGColor(ARep: string; AStyle: TWGFormatStyle);
  begin
    if AStyle.BGColor = clBlack then Result := StringReplace(Result, ARep, '#FFFFFF', [])
    else Result := StringReplace(Result, ARep, AStyle.Color2HTML(AStyle.BGColor), [])
  end;

begin
  Result := htmPageCode3;
  // 设置表头样式
  _ReplaceFontName('@headfontname@', FHeadFmtSty^);
  _ReplaceFontSize('@headfontsize@', FHeadFmtSty^);
  _ReplaceFontColor('@headfontcolor@', FHeadFmtSty^);
  _ReplaceBGColor('@headbkcolor@', FHeadFmtSty^);
  // 设置表体样式
  _ReplaceFontName('@cellfontname@', FBodyFmtSty^);
  _ReplaceFontSize('@cellfontsize@', FBodyFmtSty^);
  _ReplaceFontColor('@cellfontcolor@', FBodyFmtSty^);
  _ReplaceBGColor('@cellbkcolor@', FBodyFmtSty^);
  // 设置表格线的颜色
  Result := StringReplace(Result, '@bordercolor@', ColorToHTML(FBorderColor), [rfReplaceAll]);

end;

end.
