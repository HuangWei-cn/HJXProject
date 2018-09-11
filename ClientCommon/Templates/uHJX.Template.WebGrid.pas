{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Template.WebGrid
 Author:    ��ΰ
 Date:      10-����-2018
 Purpose:   ����WebGrid����壬�ֽ�Ϊ���⡢��ͷ�������������֡���ĳ�����۲�
            ������Ҫ���ñ��ģ��ʱ��������һ����Ԫ����ƥ�����á�

            Ŀǰ���ģ�岻֧�ֱ����۶��壬���ܴ������ݡ���۶�����ҪTWebCrossView
            ����֧�ֺ����֧�֣����ö���Ŀǰ������Ƕ����ģ��޷��ı䡣

            �Ա�ģ����Ĵ�����Functions��uHJX.Template.WebGridProc.pas��Ԫ��ɣ�
            �õ�Ԫ�е�GenWebGrid�������ݱ�ģ������еı���崴����񣬲�����
            ���ݡ�
 History:
----------------------------------------------------------------------------- }

unit uHJX.Template.WebGrid;

interface

uses
    System.Classes, System.Types, System.SysUtils, System.Variants,
    System.Generics.Collections {, System.RegularExpressions} , uHJX.Classes.Templates;

type
    { 2018-08-14�ݲ����ã���������ת�Ƶ�����Ԫ�н��У�ʹ����Ԫ��Ӧ�����
      ���ڴ˶Ե�Ԫ�����ݽ���ģʽƥ�䴦��������ģ�嶨��ĸ�ʽ����ֻ��ӵ��һ��ռλ�������ż���ֻ��
      �������ȡ������漰��ģ�����ݵĴ�����ģ����Ӧ�Կ���󻯡�
      ��Ԫ�����ݶ���, Ŀǰÿ����Ԫ���֧��һ��ռλ����ʾ�Ĵ��滻���ݣ���֧�ֶ�� }
    TCellRec = record
        Text: string;  // ԭ�������ݣ����п��ܰ�����ռλ��%xxx%����������ʱ��ʵ�������滻��
        Code: string;  // ��%xxx%�����ݣ��������������Ϊ��
        Param: string; // ��%xxx%�аٷֺ������xxx�Ĳ���(%xxx.yyy%��xxx.yyy����)��
        Item1: string; // ��xxx.yyy��xxx���֣��Ǵ˸�ʽ�����Param
        Item2: string; // xxx.yyy�е�yyy���֣��������
    end;

    { ����нṹ����ͷ��������ʹ�ô˽ṹ������Cols��ÿ���нṹ������Ԫ�����ݣ���ʵ����Cells }
    /// <summary>WebGridģ�����нṹ��WebGrid���ֻ���Ƕ�̬�����͵ı����Ŀǰֻ֧�ֵ��ж�̬��
    /// ��ͷ�к������о�����ͬ�����������ṹ����ģ�����ж�����е����ݣ�ģ�����ݣ���
    /// ����Щ���ݵĴ����ɱ�����ɳ�����ɡ�
    /// </summary>
    TGridTemplateRow = record
        Cols: TArray<string>;
        // Cells: TArray<TCellRec>;
    end;

    { ���ģ����� }
    /// <summary>����̳���<see cref="ThjxTemplate"/>������WebGrid���
    /// ���ģ���ɱ����ж��塢��ͷ�ж��塢�����ж�����ɡ����ཫģ��ֽ�Ϊ����
    /// �������֣����б�ͷ�к������н�һ���ֽ�Ϊ��Ԫ��
    /// </summary>
    TWebGridTemplate = class(ThjxTemplate)
    private
        FTemplateStr: string;
        // FName        : string;
        FApplyToGroup: Boolean;
        // FMeterType   : String; // Ŀǰֻ�����һ�����ͣ���������Ч��Ӧ������Ӧ��������
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
    { �����������ʽû�ã���������ģ��ƥ��Ĳμ�uHJX.Template.ProcSpecifiers��Ԫ�е�������ʽ }
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
    // �����#13#10���ַ�
    AStr := Trim(AStr);
    AStr := StringReplace(AStr, #13, '', [rfReplaceAll]);
    AStr := StringReplace(AStr, #10, '', [rfReplaceAll]);
    Rows := AStr.Split([';']);
    // ���ÿһ�У�����ð��ǰ�ı�ʶ���жϵ�ǰ��Ϊ��һ��
    { todo: ��Ҫ�����㹻�Ĵ����飬�����������Ϊ��Ϣ���ݳ�ȥ }
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
            { todo: ���Cols�Ƿ�Ϊ�ա������Ƿ���ǰ��ı���һ�� }
            // ȥ��ǰ��ո�
            if Length(Cols) > 0 then
                for k := 0 to high(Cols) do Cols[k] := Trim(Cols[k]);
            SetLength(Heads, Length(Heads) + 1);
            SetLength(Heads[high(Heads)].Cols, high(Cols));
            Heads[high(Heads)].Cols := Cols;
        end
        else if SameText(id, 'DataRow') then
        begin
            Cols := content.Split(['|']);
            // ȥ��ǰ��ո�
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
    // ǰ����if�ж�����Ч��������if�ж�����Ч
    if Length(Heads) > 0 then
        if (ARow >= 0) and (ARow <= high(Heads)) then
            if Length(Heads[ARow].Cols) > 0 then
                if (ACol >= 0) and (ACol <= high(Heads[ARow].Cols)) then
                        Result := Heads[ARow].Cols[ACol];
end;

end.
