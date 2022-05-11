{ -----------------------------------------------------------------------------
 Unit Name: uWebGridCross
 Author:    Administrator
 Date:      17-ʮ����-2012
 Purpose:   ����Ԫ�ṩ����frxCrossView�Ĺ��ܣ�Ҳ�������Ƶ�ʹ�÷���������һ��
            ���ݱ��HTML���룬��������д��WebBrowser����ʾ֮��
            ����frxCrossView�����Ϊ�������֣�ColumnHeader, RowHeader, DataArea,
            ÿ���������ɶ�Ӧ��RowHeadֵ��ColHeadֵ��λ���������кŶ�λ�����
            ��ͬ�ĵ�Ԫ�񽫱��ϲ����ϲ�����˳�������к��С�

 History:   2020-1-17 ����ֱ����CrossView��Cell����д�����ˣ��������ȶ���һ��
            Variant���飬����AddRow��ʽ����������ݡ����������һ�����У�Ȼ��
            ����дCell��
            �����ʽ�ĸı䣺
            1������Margin��Ϊ0px������������Word�󣬱�����ݵĶ������ԵĶ�ǰ
               �κ�Ϊ0�����������ˣ�
            2��TH��TD��Padding��Ϊ1px��������word�еı��paddingΪ0.03mm���Ե�
               ���ն��ˣ�
            3�������û������ͷ��������������������С��������ɫ��������ɫ��
            4�������û�����������ɫ��
            5�������û�ֱ��ָ��ĳ����Ԫ���������ɫ��������ɫ�������С������
----------------------------------------------------------------------------- }
{ TODO: ���������ã��������ÿһ�����ö��롢��ʽ���Ƿ����������ںϡ������ںϵ� }
{ TODO: ĳЩ�������ں�����Ӧ����һ�ж�Ӧ����۲�����Ӧ��������Ŷ�Ӧ }
{ DONE: �������Caption Row�����к����ں���ͬ�ĵ�Ԫ�񣬺������ں����� }
{ TODO: �ɿ��ǽ�������Ϊ��ͷ�̶������ݿɹ��� }
{ TODO: �ɿ����ṩ���п��۵�div�ı����� }
{ DONE: ���Ӷ����ں͸������ݵĸ�ʽ���ַ��������ɹ������Զ�����֮ }
{ DONE: ���Ӹı��ض���Ԫ���������塢��ɫ�Ĺ��� }
{ todo: ���ӵ�Ԫ������Ϊ�����ӵĹ��� }
unit uWebGridCross;

interface

uses
  SysUtils, Classes, Variants, System.UITypes, System.UIConsts, Vcl.Graphics;

type
  TWebCrossHeader = class;
  TWebCrossView   = class;

  // ��ʽ����ṹ����ʱ������Padding���á�����ߵȸ�ϸ�µ�����
  // ͬʱ���ڱ������й涨����Ԫ�����ɫ���������0����FormatStyle�е�Color=0�������������á���Ϊ
  // ȱʡ��ɫΪ0�����������á�BGColor��ȱʡ��ɫΪ��ɫ����#FFFFFF��
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

  // CrossHeader����ʵ����������ȷ��ĳһ�е�ĳЩ��ͬ����
  TWebCrossHeader = class
    Align: TAlignment;
    FormatStr: string;
    AllowColSpan: Boolean;
    AllowRowSpan: Boolean;
    ColumnFormat: PWGFormatStyle; // 2020-1-20
    constructor Create;
    destructor Destroy; override;
  end;

  // CrossRow����Ŀǰ����������ʶĳһ���Ƿ��Ǳ����л���Ľ��У���ʱû��������;
  PWebCrossRow = ^TWebCrossRow;

  TWebCrossRow = record
    IsCaptionRow: Boolean;
    IsHeader: Boolean;
    IsFooter: Boolean;
    function IsBody: Boolean;
  end;

    { ���ݾ��� }
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
    { Ԥ����Ԫ�����ݣ���Ҫ�Ǻϲ���Ԫ��֮��Ķ��� }
    procedure PreProcCells;
    procedure ResetCells;
    function GetColHeader(ACol: Integer): TWebCrossHeader;
    function GetCells(ACol, ARow: Integer): TWebCrossCell;
  public
    constructor Create(Owner: TWebCrossView; AColumnCount: Integer);
    destructor Destroy; override;

    procedure AddRow(ValueArray: array of Variant); overload; // ��Matrixβ�����һ��
    procedure AddRow; overload; { 2019-12-21 }
    procedure AddCaptionRow(CaptionArray: array of Variant); overload; // ����м������
    procedure AddCaptionRow; overload; // 2019-12-21

    function HTMLCode: string;
        { 2013-06-19 �����ر����룬������ҳ }
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
    FTitleRowCount: Integer;         // ��������
    FTitleColCount: Integer;         // ����������ָ��0�С�FTitleColCount-1Ϊ��������
    FMatrix       : TWebCrossMatrix; // ����ȫ�����ݵľ���
    // 2020-1-20
    FHeadFmtSty: PWGFormatStyle; // �����и�ʽ
    FBodyFmtSty: PWGFormatStyle; // ������ݸ�ʽ
    FFootFmtSty: PWGFormatStyle; // ���и�ʽ
    // 2020-5-18
    FBorderColor: TColor;
    function getRowCount: Integer;
    procedure CreateMatrix;
    function GetMatrixColHeader(ACol: Integer): TWebCrossHeader;
    function GetMatrixCells(ACol, ARow: Integer): TWebCrossCell;
    procedure SetTitleRowCount(ACount: Integer);
    procedure SetTitleColCount(ACount: Integer);
  protected
    // ΪMatrix׼��Pageҳ����룬��Ҫ����Ҫ����FormatStyle�������е����塢��ɫ������
    function PrePageHTML: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    procedure AddRow(const ValueArray: array of Variant); overload;
    procedure AddRow; overload;
    procedure AddCaptionRow(CaptionArray: array of Variant); overload;
    procedure AddCaptionRow; overload;
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
    { ע�������CSS����ʹ�ñ�����ϸ�߱߿� }
    { ��Ա��ı�ͷ����Ԫ��ʹ����CSS���� }
  htmPageCode2 = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10 + '<html>'#13#10 +
    '<head>'#13#10 + '<meta http-equiv="Content-Type" content="text/html; charset=GB2312" />'#13#10
    + '@PageTitle@'#13#10 + '<style type="text/css">'#13#10 +
    '.DataGrid {border:1px solid #000099;border-width:1px 1px 1px 1px;margin:1px 1px 1px 1px;border-collapse:collapse}'#13#10
    + '.thStyle {font-size: 8pt; font-family: Tahoma; color: #000000; padding:3px;border:1px solid #000099}'#13#10
    + '.tdStyle {font-size: 8pt; font-family: Tahoma; color: #000000; background-color:#FFFFFF;empty-cells:show;'
    // #F7F7F7
    + '          border:1px solid #000099; padding:3px}'#13#10 +
    '.CaptionStyle {font-family:����;font-size: 9pt;color: #000000; padding:3px;border:1px solid #000099; background-color:#FFFF99}'#13#10
    + '</style>'#13#10 + '</head>'#13#10 + '<body>'#13#10 + '@PageContent@'#13#10 + '</body>'#13#10
    + '</html>';

  { �µ�ҳ����룬�����û��������ñ����ʽ�������塢�����С��������ɫ���߿���ɫ�� }
  htmPageCode3 = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10 + '<html>'#13#10 +
    '<head>'#13#10 + '<meta http-equiv="Content-Type" content="text/html; charset=GB2312" />'#13#10
    + '@PageTitle@'#13#10 + '<style type="text/css">'#13#10 +
    '.DataGrid {border:1px solid @bordercolor@;border-width:1px 1px 1px 1px;margin:0px 0px 0px 0px;border-collapse:collapse}'#13#10
    + '.thStyle {font-size: @headfontsize@; font-family: @headfontname@; color: @headfontcolor@; background-color:@headbkcolor@;padding:1px;border:1px solid @bordercolor@}'#13#10
    + '.tdStyle {font-size: @cellfontsize@; font-family: @cellfontname@; color: @cellfontcolor@; background-color:@cellbkcolor@;empty-cells:show;'
    + '          border:1px solid @bordercolor@; padding:1px}'#13#10 +
    '.CaptionStyle {font-family:����;font-size: 9pt;color: #000000; padding:0px;border:1px solid #000099; background-color:#FFFF99}'#13#10
    + '</style>'#13#10 + '</head>'#13#10 + '<body>'#13#10 + '@PageContent@'#13#10 + '</body>'#13#10
    + '</html>';

    { ������ }
  htmTableCode =
    '<table BORDER=0 CELLSPACING=0 CELLPADDING=0 class="DataGrid">'#13#10 { BGCOLOR=#ADD8E6 }
    + '@Caption@' + '@Rows@' + '</table>';

    { ��Ԫ����� }
  htmTDCode = '<TD %clsname% %Align% %Width% %BGCOLOR%>' +
    '<FONT STYLE="font-family: Tahoma; font-size: 8pt; color: #000000">' + '@Value@' +
    '</FONT></TD>';

    { ʹ��CSS�ĵ�Ԫ����룬ע����������Ԫ��������չ }
  htmTDCode2 = '<td %class% %Align% %Width% %BGCOLOR% %RowSpan% %ColSpan%>' + '@Value@' +
    '<td>'#13#10;

    { �д��� }
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
  if IsNull then Result := '��'
  else
  begin
    case VarType(FValue) of //
      varEmpty, varNull: Result := '��';
      varSmallInt, varInteger, varShortInt, varByte, varWord, varLongWord, varInt64:
        Result := IntToStr(FValue);
      varSingle, varDouble, varCurrency: if ColHeader.FormatStr <> '' then
            Result := FormatFloat(ColHeader.FormatStr, FValue)
        else Result := FormatFloat('0.00', FValue);
      varDate: if ColHeader.FormatStr <> '' then
            Result := FormatDateTime(ColHeader.FormatStr, FValue)
        else Result := FormatDateTime('yyyy-mm-dd hh:mm:ss', FValue);
      varBoolean: Result := Booltostr(FValue);
      varString, varOLEStr: if Trim(FValue) = '' then Result := '��'
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
  for iCol := low(FCellMatrix[iRow]) to high(FCellMatrix[iRow]) do
  begin
    FCellMatrix[iRow][iCol] := TWebCrossCell.Create;
    FCellMatrix[iRow][iCol].ColHeader := Self.ColHeader[iCol];
    FCellMatrix[iRow][iCol].Alignment := Self.ColHeader[iCol].Align;
  end;
    // if Varisarray(ValueArray) then
  for iCol := low(ValueArray) to high(ValueArray) do
      FCellMatrix[iRow][iCol].Value := ValueArray[iCol];

  { �������������� }
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
  Description:  ����һ��Caption�С�Caption��ͨ���Ǻ���ϲ���
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

    { ���CaptionArray��������ColCount����matrix������ֵ����CaptionArray�����һ�� }
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
  // �����±곬�޼��
  if ARow < 0 then raise Exception.Create('��������С����');
  if ARow > FRowCount - 1 then raise Exception.Create('��������');
  if ACol < 0 then raise Exception.Create('�в���С����');
  if ACol > FColCount - 1 then raise Exception.Create('��������');
  Result := FCellMatrix[ARow][ACol];
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
        if iCol = (FColCount - 1) then FCellMatrix[iRow][iMCStart].FColSpan := iMC;
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
      if ((iRow > FTitleRows - 1) and (not FColHeaders[iCol].AllowColSpan)) or
        (FRows[iRow].IsCaptionRow) then
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
                { ��������һ�У���������� }
        if iRow = (FRowCount - 1) then FCellMatrix[iMCStart][iCol].FRowSpan := iMC;

        { ��������У����кϲ���Χ���ܳ�������������ϲ���Χ�����Ա�����û������ }
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
  Description:  �����������ر�����
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
        // ���class����
        if cell.CSSClass <> '' then sTD := sTD + ' class="' + cell.CSSClass + '"'
        else if iRow <= (FTitleRows - 1) then sTD := sTD + ' class="thStyle"'
        else if FRows[iRow].IsCaptionRow then sTD := sTD + ' class="CaptionStyle"'
        else sTD := sTD + ' class="tdStyle"';

        // ���Align����
        if (cell.Alignment = taCenter) or (cell.ColSpan > 1) or (iRow <= (FTitleRows - 1)) then
            s := ' align="center"'
        else if cell.Alignment = taRightJustify then s := ' align="right"'
        else s := '';
        sTD := sTD + s;

        // �кϲ����кϲ�
        if cell.RowSpan > 1 then sTD := sTD + Format(' rowspan="%d"', [cell.RowSpan]);

        if cell.ColSpan > 1 then sTD := sTD + Format(' colspan="%d"', [cell.ColSpan]);

        // ������ɫ
        s := '';
        if cell.FFormatStyle.BGColor <> clWhite then // ����������ã���
            s := ' BGCOLOR=' + cell.FFormatStyle.Color2HTML(cell.FFormatStyle.BGColor)
        else if FRows[iRow].IsHeader then // ����Ǳ����У���
        begin
          // ���������û�е������ã����Ѿ��ڳ�ʼ�׶���class�����ù��ˡ�
          s := '';
        end
        else if FRows[iRow].IsBody then
        begin
          with cell.ColHeader.ColumnFormat^ do
            if BGColor <> clWhite then s := ' BGCOLOR=' + Color2HTML(BGColor);
        end;
        sTD := sTD + s;

        // ������ʽ������Ԫ�������ã��򰴵�Ԫ�������������������ã����зǱ�ͷ��Ԫ�������ã���������������
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
        // �������壬���ϲ�����
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
    { todo:Ӧ���Ǳ���@Caption@�� }
    // sTable := htmTableCode;
  sTable := StringReplace(htmTableCode, '@Caption@', '', []);
  sTable := StringReplace(sTable, '@Rows@', sRows, []);
  Result := sTable;
end;

{ -----------------------------------------------------------------------------
  Procedure:    TWebCrossMatrix.HTMLCode
  Description:	����������HTML����
----------------------------------------------------------------------------- }
function TWebCrossMatrix.HTMLCode: string;
var
  sTable: string;
  sPage : string;
begin
  Result := '';
  { 2020-1-21 ҳ�������CrossView�ṩ���������û�Ԥ����ĸ�ʽ��ģ��������һ����ʽ���� }
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
  // ���ñ�ͷ��ʽ
  _ReplaceFontName('@headfontname@', FHeadFmtSty^);
  _ReplaceFontSize('@headfontsize@', FHeadFmtSty^);
  _ReplaceFontColor('@headfontcolor@', FHeadFmtSty^);
  _ReplaceBGColor('@headbkcolor@', FHeadFmtSty^);
  // ���ñ�����ʽ
  _ReplaceFontName('@cellfontname@', FBodyFmtSty^);
  _ReplaceFontSize('@cellfontsize@', FBodyFmtSty^);
  _ReplaceFontColor('@cellfontcolor@', FBodyFmtSty^);
  _ReplaceBGColor('@cellbkcolor@', FBodyFmtSty^);
  // ���ñ���ߵ���ɫ
  Result := StringReplace(Result, '@bordercolor@', ColorToHTML(FBorderColor), [rfReplaceAll]);

end;

end.
