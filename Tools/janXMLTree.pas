unit janXMLTree;

{  Created by Jan Verhoeven - 10 June 2000
   jan1.verhoeven@wxs.nl
   http://jansfreeware.com

   This code may be freely used in any freeware application
   provided you keep this text in the source code.
   When you want to use this code in a commercial application
   you must obtain approval from the author.}
{ DONE: 需要解决<?xml ... ?>的问题 }
{ DONE: 需要解决xml代码输出不美观的问题 }
{ DONE: 需要解决注释代码的问题 }
{ DONE: 需要解决程序代码块的问题 }
{ HW修：1. 改进了document方法中对Value的判断
        2. 改进了对标准XML文件<?xml ?>的处理，当文件首行为此标准行时，使输出正
           确。
        3. tag层级缩进改为4空格，符合咱的习惯。
        4. 修正了CloneNode方法中没有设置子Clone节点的Parent为空的bug；
        5. 修正了CloneNode方法中Clone节点的没有设置ValueType的错误。
        6. 增加了新的节点类型：注释节点 xvtComment;
}
interface

uses
    Windows, SysUtils, Classes, Dialogs, Variants;

type
    TjanXMLValueType = (xvtString, xvtCDATA, xvtComment);
    TjanXMLFilterOperator = (xfoNOP, xfoEQ, xfoIEQ, xfoNE, xfoINE, xfoGE,
        xfoIGE, xfoLE, xfoILE, xfoGT, xfoIGT, xfoLT, xfoILT);

    TjanXMLTree = class;

    TjanXMLFilterAtom = class(TObject)
    private
        FValue: string;
        FName: string;
        FOperator: TjanXMLFilterOperator;
        FAttributeFilter: boolean;
        procedure SetName(const Value: string);
        procedure SetOperator(const Value: TjanXMLFilterOperator);
        procedure SetValue(const Value: string);
        procedure SetAttributeFilter(const Value: boolean);
    public
        property Name: string read FName write SetName;
        property Operator: TjanXMLFilterOperator read FOperator write
            SetOperator;
        property Value: string read FValue write SetValue;
        property AttributeFilter: boolean read FAttributeFilter write
            SetAttributeFilter;
    end;

    TjanXMLFilter = class(TObject)
    private
        FName: string;
        FFilters: TList;
        procedure SetName(const Value: string);
        procedure SetFilters(const Value: TList);
    public
        constructor Create(FilterStr: string);
        destructor Destroy; override;
        property Name: string read FName write SetName;
        property Filters: TList read FFilters write SetFilters;
    end;

    TjanXMLAttribute = class(TObject)
    private
        FName: string;
        FValue: variant;
        procedure SetName(const Value: string);
        procedure SetValue(const Value: variant);
    public
        constructor Create(aName: string; aValue: variant);
        function document: string;
        property Name: string read FName write SetName;
        property Value: variant read FValue write SetValue;
    end;

    TjanXMLNode = class(TObject)
    private
        FName: string;
        FValue: variant;
        FNodes: TList;
        FAttributes: TList;
        FParentNode: TjanXMLNode;
        FValueType: TjanXMLValueType;
        FObject: TObject;   { 2012-06-09增加的属性 }
        procedure SetName(const Value: string);
        procedure SetValue(const Value: variant);
        procedure SetNodes(const Value: TList);
        procedure SetAttributes(const Value: TList);
        procedure SetParentNode(const Value: TjanXMLNode);
        procedure SetValueType(const Value: TjanXMLValueType);
    public
        constructor Create(aName: string; aValue: variant; aParent:
            TjanXMLNode);
        destructor Destroy; override;
        function AddNode(aName: string; aValue: variant): TjanXMLNode;
        function AddNodeEx(aName: string; aValue: variant): TjanXMLNode;
        procedure DeleteNode(index: integer);
        procedure ClearNodes;
        function AddAttribute(aName: string; aValue: variant): TjanXMLAttribute;
        procedure DeleteAttribute(index: integer);
        procedure ClearAttributes;
        function document(aLevel: integer): string; virtual; //charmer add: virtual;
        function getNodePath: string;
        function getNamedNode(aName: string): TjanXMLNode;
        function SelectSingleNode(pattern: string): TjanXMLNode;
        procedure selectNodes(pattern: string; aList: TList);
        function transformNode(stylesheet: TjanXMLNode): string;
        function process(aLevel: integer; node: TjanXMLNode): string;
        function findNamedNode(aName: string): TjanXMLNode;
        procedure findNamedNodes(aName: string; aList: TList);
        procedure getAllNodes(aList: TList);
        function getNamedAttribute(aName: string): TjanXMLAttribute;
        procedure findNamedAttributes(aName: string; aList: TList);
        function matchFilter(objFilter: TjanXMLFilter): boolean;
        procedure matchPattern(aPattern: string; aList: TList);
        procedure getNodeNames(aList: TStringList);
        procedure getAttributeNames(aList: TStringList);
        function getNameSpace: string;
        function hasChildNodes: boolean;
        function cloneNode: TjanXMLNode;
        function firstChild: TjanXMLNode;
        function lastChild: TjanXMLNode;
        function previousSibling: TjanXMLNode;
        function nextSibling: TjanXMLNode;
        function moveAddNode(Dest: TjanXMLNode): TjanXMLNode;
        function moveInsertNode(Dest: TjanXMLNode): TjanXMLNode;
        function removeChildNode(aNode: TjanXMLNode): TjanXMLNode;
        function CDataValue: string;    //2012-07-02 Add by Charmer
        property Name: string read FName write SetName;
        property Value: variant read FValue write SetValue;
        property ValueType: TjanXMLValueType read FValueType write SetValueType;
        property Nodes: TList read FNodes write SetNodes;
        property parentNode: TjanXMLNode read FParentNode write SetParentNode;
        property Attributes: TList read FAttributes write SetAttributes;
        { AObject属性用来将Node和外部的什么东西绑定起来 }
        property AObject: TObject read FObject write FObject; { 添加的属性 }
    end;

    TjanXMLTree = class(TjanXMLNode)
    private
        FLines: TStringList;
        FNodeCount: integer;
        procedure SetLines(const Value: TStringList);
        function getText: string;
        procedure setText(const Value: string);
        { Private declarations }
    protected
        { Protected declarations }
    public
        { Public declarations }
        constructor Create(aName: string; aValue: variant; aParent:
            TjanXMLNode);
        destructor Destroy; override;
        procedure ParseXML;
        procedure LoadFromFile(fn: string);
        procedure LoadFromStream(Stream: TStream);
        procedure SaveToFile(aFile: string);
        procedure SaveToStream(Stream: TStream);
        function asText: string;
        property Lines: TStringList read FLines write SetLines;
        property NodeCount: integer read FNodeCount;
        property Text: string read getText write setText;
    published
        { Published declarations }
    end;

procedure PreProcessXML(aList: TStringList);

implementation

const
    cr = chr(13) + chr(10);
    tab = chr(9);

    ToUpperChars: array[0..255] of Char =
    (#$00, #$01, #$02, #$03, #$04, #$05, #$06, #$07, #$08, #$09, #$0A, #$0B,
        #$0C, #$0D, #$0E, #$0F,
        #$10, #$11, #$12, #$13, #$14, #$15, #$16, #$17, #$18, #$19, #$1A, #$1B,
            #$1C, #$1D, #$1E, #$1F,
        #$20, #$21, #$22, #$23, #$24, #$25, #$26, #$27, #$28, #$29, #$2A, #$2B,
            #$2C, #$2D, #$2E, #$2F,
        #$30, #$31, #$32, #$33, #$34, #$35, #$36, #$37, #$38, #$39, #$3A, #$3B,
            #$3C, #$3D, #$3E, #$3F,
        #$40, #$41, #$42, #$43, #$44, #$45, #$46, #$47, #$48, #$49, #$4A, #$4B,
            #$4C, #$4D, #$4E, #$4F,
        #$50, #$51, #$52, #$53, #$54, #$55, #$56, #$57, #$58, #$59, #$5A, #$5B,
            #$5C, #$5D, #$5E, #$5F,
        #$60, #$41, #$42, #$43, #$44, #$45, #$46, #$47, #$48, #$49, #$4A, #$4B,
            #$4C, #$4D, #$4E, #$4F,
        #$50, #$51, #$52, #$53, #$54, #$55, #$56, #$57, #$58, #$59, #$5A, #$7B,
            #$7C, #$7D, #$7E, #$7F,
        #$80, #$81, #$82, #$81, #$84, #$85, #$86, #$87, #$88, #$89, #$8A, #$8B,
            #$8C, #$8D, #$8E, #$8F,
        #$80, #$91, #$92, #$93, #$94, #$95, #$96, #$97, #$98, #$99, #$8A, #$9B,
            #$8C, #$8D, #$8E, #$8F,
        #$A0, #$A1, #$A1, #$A3, #$A4, #$A5, #$A6, #$A7, #$A8, #$A9, #$AA, #$AB,
            #$AC, #$AD, #$AE, #$AF,
        #$B0, #$B1, #$B2, #$B2, #$A5, #$B5, #$B6, #$B7, #$A8, #$B9, #$AA, #$BB,
            #$A3, #$BD, #$BD, #$AF,
        #$C0, #$C1, #$C2, #$C3, #$C4, #$C5, #$C6, #$C7, #$C8, #$C9, #$CA, #$CB,
            #$CC, #$CD, #$CE, #$CF,
        #$D0, #$D1, #$D2, #$D3, #$D4, #$D5, #$D6, #$D7, #$D8, #$D9, #$DA, #$DB,
            #$DC, #$DD, #$DE, #$DF,
        #$C0, #$C1, #$C2, #$C3, #$C4, #$C5, #$C6, #$C7, #$C8, #$C9, #$CA, #$CB,
            #$CC, #$CD, #$CE, #$CF,
        #$D0, #$D1, #$D2, #$D3, #$D4, #$D5, #$D6, #$D7, #$D8, #$D9, #$DA, #$DB,
            #$DC, #$DD, #$DE, #$DF);

    ToLowerChars: array[0..255] of Char =
    (#$00, #$01, #$02, #$03, #$04, #$05, #$06, #$07, #$08, #$09, #$0A, #$0B,
        #$0C, #$0D, #$0E, #$0F,
        #$10, #$11, #$12, #$13, #$14, #$15, #$16, #$17, #$18, #$19, #$1A, #$1B,
            #$1C, #$1D, #$1E, #$1F,
        #$20, #$21, #$22, #$23, #$24, #$25, #$26, #$27, #$28, #$29, #$2A, #$2B,
            #$2C, #$2D, #$2E, #$2F,
        #$30, #$31, #$32, #$33, #$34, #$35, #$36, #$37, #$38, #$39, #$3A, #$3B,
            #$3C, #$3D, #$3E, #$3F,
        #$40, #$61, #$62, #$63, #$64, #$65, #$66, #$67, #$68, #$69, #$6A, #$6B,
            #$6C, #$6D, #$6E, #$6F,
        #$70, #$71, #$72, #$73, #$74, #$75, #$76, #$77, #$78, #$79, #$7A, #$5B,
            #$5C, #$5D, #$5E, #$5F,
        #$60, #$61, #$62, #$63, #$64, #$65, #$66, #$67, #$68, #$69, #$6A, #$6B,
            #$6C, #$6D, #$6E, #$6F,
        #$70, #$71, #$72, #$73, #$74, #$75, #$76, #$77, #$78, #$79, #$7A, #$7B,
            #$7C, #$7D, #$7E, #$7F,
        #$90, #$83, #$82, #$83, #$84, #$85, #$86, #$87, #$88, #$89, #$9A, #$8B,
            #$9C, #$9D, #$9E, #$9F,
        #$90, #$91, #$92, #$93, #$94, #$95, #$96, #$97, #$98, #$99, #$9A, #$9B,
            #$9C, #$9D, #$9E, #$9F,
        #$A0, #$A2, #$A2, #$BC, #$A4, #$B4, #$A6, #$A7, #$B8, #$A9, #$BA, #$AB,
            #$AC, #$AD, #$AE, #$BF,
        #$B0, #$B1, #$B3, #$B3, #$B4, #$B5, #$B6, #$B7, #$B8, #$B9, #$BA, #$BB,
            #$BC, #$BE, #$BE, #$BF,
        #$E0, #$E1, #$E2, #$E3, #$E4, #$E5, #$E6, #$E7, #$E8, #$E9, #$EA, #$EB,
            #$EC, #$ED, #$EE, #$EF,
        #$F0, #$F1, #$F2, #$F3, #$F4, #$F5, #$F6, #$F7, #$F8, #$F9, #$FA, #$FB,
            #$FC, #$FD, #$FE, #$FF,
        #$E0, #$E1, #$E2, #$E3, #$E4, #$E5, #$E6, #$E7, #$E8, #$E9, #$EA, #$EB,
            #$EC, #$ED, #$EE, #$EF,
        #$F0, #$F1, #$F2, #$F3, #$F4, #$F5, #$F6, #$F7, #$F8, #$F9, #$FA, #$FB,
            #$FC, #$FD, #$FE, #$FF);

function Q_PosStr(const FindString, SourceString: string; StartPos: integer):
    integer;
asm
        PUSH    ESI
        PUSH    EDI
        PUSH    EBX
        PUSH    EDX
        TEST    EAX,EAX
        JE      @@qt
        TEST    EDX,EDX
        JE      @@qt0
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EAX,[EAX-4]
        MOV     EDX,[EDX-4]
        DEC     EAX
        SUB     EDX,EAX
        DEC     ECX
        SUB     EDX,ECX
        JNG     @@qt0
        MOV     EBX,EAX
        XCHG    EAX,EDX
        NOP
        ADD     EDI,ECX
        MOV     ECX,EAX
        MOV     AL,BYTE PTR [ESI]
@@lp1:  CMP     AL,BYTE PTR [EDI]
        JE      @@uu
@@fr:   INC     EDI
        DEC     ECX
        JNZ     @@lp1
@@qt0:  XOR     EAX,EAX
        JMP     @@qt
@@ms:   MOV     AL,BYTE PTR [ESI]
        MOV     EBX,EDX
        JMP     @@fr
@@uu:   TEST    EDX,EDX
        JE      @@fd
@@lp2:  MOV     AL,BYTE PTR [ESI+EBX]
        XOR     AL,BYTE PTR [EDI+EBX]
        JNE     @@ms
        DEC     EBX
        JNE     @@lp2
@@fd:   LEA     EAX,[EDI+1]
        SUB     EAX,[ESP]
@@qt:   POP     ECX
        POP     EBX
        POP     EDI
        POP     ESI
end;

function Q_PosText(const FindString, SourceString: string; StartPos: integer):
    integer;
asm
        PUSH    ESI
        PUSH    EDI
        PUSH    EBX
        NOP
        TEST    EAX,EAX
        JE      @@qt
        TEST    EDX,EDX
        JE      @@qt0
        MOV     ESI,EAX
        MOV     EDI,EDX
        PUSH    EDX
        MOV     EAX,[EAX-4]
        MOV     EDX,[EDX-4]
        DEC     EAX
        SUB     EDX,EAX
        DEC     ECX
        PUSH    EAX
        SUB     EDX,ECX
        JNG     @@qtx
        ADD     EDI,ECX
        MOV     ECX,EDX
        MOV     EDX,EAX
        MOVZX   EBX,BYTE PTR [ESI]
        MOV     AL,BYTE PTR [EBX+ToUpperChars]
@@lp1:  MOVZX   EBX,BYTE PTR [EDI]
        CMP     AL,BYTE PTR [EBX+ToUpperChars]
        JE      @@uu
@@fr:   INC     EDI
        DEC     ECX
        JNE     @@lp1
@@qtx:  ADD     ESP,$08
@@qt0:  XOR     EAX,EAX
        JMP     @@qt
@@ms:   MOVZX   EBX,BYTE PTR [ESI]
        MOV     AL,BYTE PTR [EBX+ToUpperChars]
        MOV     EDX,[ESP]
        JMP     @@fr
        NOP
@@uu:   TEST    EDX,EDX
        JE      @@fd
@@lp2:  MOV     BL,BYTE PTR [ESI+EDX]
        MOV     AH,BYTE PTR [EDI+EDX]
        CMP     BL,AH
        JE      @@eq
        MOV     AL,BYTE PTR [EBX+ToUpperChars]
        MOVZX   EBX,AH
        XOR     AL,BYTE PTR [EBX+ToUpperChars]
        JNE     @@ms
@@eq:   DEC     EDX
        JNZ     @@lp2
@@fd:   LEA     EAX,[EDI+1]
        POP     ECX
        SUB     EAX,[ESP]
        POP     ECX
@@qt:   POP     EBX
        POP     EDI
        POP     ESI
end;

procedure PreProcessXML(aList: TStringList);
const
    crlf = chr(13) + chr(10);
    tab = chr(9);
var
    oList: TStringList;
    s, xTag, xText, xData: string;
    p1, p2, c: integer;
    aLevel: integer;

    function clean(aText: string): string;
    begin
        result := stringreplace(aText, crlf, ' ', [rfreplaceall]);
        result := stringreplace(result, tab, ' ', [rfreplaceall]);
        result := trim(result);
    end;

    function cleanCDATA(aText: string): string;
    begin
        result := stringreplace(aText, crlf, '\n ', [rfreplaceall]);
        result := stringreplace(result, tab, '\t ', [rfreplaceall]);
    end;

    function spc: string;
    begin
        if aLevel < 1 then
            result := ''
        else
            result := stringofchar(' ', 4 * aLevel); //2 * aLevel);
    end;
begin
    oList := TStringList.Create;
    s := aList.Text;
    xText := '';
    xTag := '';
    p1 := 1;
    c := length(s);
    aLevel := 0;
    repeat
        p2 := Q_PosStr('<', s, p1);
        if p2 > 0 then
        begin
            xText := trim(copy(s, p1, p2 - p1));
            if xText <> '' then
            begin
                oList.Append('TX:' + clean(xText));
            end;
            p1 := p2;
            // check for CDATA
            if uppercase(copy(s, p1, 9)) = '<![CDATA[' then
            begin
                p2 := Q_PosStr(']]>', s, p1);
                xData := copy(s, p1 + 9, p2 - p1 - 9);
                oList.Append('CD:' + cleanCDATA(xData));
                p1 := p2 + 2;
            end
            else if uppercase(Copy(s,p1,4)) = '<!--' then { 处理注释 }
            begin
                p2 := Q_PosStr('-->', s, p1);
                xData := Copy(s, p1 + 4, p2 - p1 - 4);
                oList.Append('CM:' + cleanCDATA(xData));
                p1 := p2 + 2;
            end
            else
            begin
                p2 := Q_PosStr('>', s, p1);
                if p2 > 0 then
                begin
                    xTag := copy(s, p1 + 1, p2 - p1 - 1);
                    p1 := p2;
                    if xTag[1] = '/' then   //如果Tag的第一个字符是/，则CT:Close tag
                    begin
                        delete(xTag, 1, 1);
                        oList.Append('CT:' + clean(xTag));
                        dec(aLevel);
                    end
                    else if xTag[length(xTag)] = '/' then
                    begin
                        oList.Append('ET:' + clean(xTag));  //Empty Tag
                    end
                    else
                    begin
                        inc(aLevel);
                        oList.Append('OT:' + clean(xTag));  //Open Tag
                    end
                end
            end
        end
        else
        begin
            xText := trim(copy(s, p1, length(s)));
            if xText <> '' then
            begin
                oList.Append('TX:' + clean(xText));
            end;
            p1 := c;
        end;
        inc(p1);
    until p1 > c;
    aList.assign(oList);
    oList.free;
end;

procedure SaveString(aFile, aText: string);
begin
    with TFileStream.Create(aFile, fmCreate) do
    try
        writeBuffer(aText[1], length(aText));
    finally free;
    end;
end;

{ TjanXMLNode }

function TjanXMLNode.AddAttribute(aName: string;
    aValue: variant): TjanXMLAttribute;
var
    n: TjanXMLAttribute;
begin
    n := TjanXMLAttribute.Create(aName, aValue);
    Attributes.Add(n);
    result := n;
end;

function TjanXMLNode.AddNode(aName: string; aValue: variant): TjanXMLNode;
var
    n: TjanXMLNode;
begin
    n := TjanXMLNode.Create(aName, aValue, self);
    self.Nodes.Add(n);
    result := n
end;

// adds node and parses any attributes;

function TjanXMLNode.AddNodeEx(aName: string; aValue: variant): TjanXMLNode;
var
    n: TjanXMLNode;
    s, sn, sv: string;
    c, p1, p2: integer;
begin
    n := TjanXMLNode.Create(aName, aValue, self);
    self.Nodes.Add(n);
    result := n;
    c := length(aName);
    //first parse name
    p1 := Q_PosStr(' ', aName, 1);
    if p1 = 0 then exit;
    s := copy(aName, 1, p1 - 1);
    n.Name := s;
    repeat
        // find '='
        p2 := Q_PosStr('=', aName, p1);
        if p2 = 0 then exit;
        sn := trim(copy(aName, p1, p2 - p1));
        p1 := p2;
        // find begin of value
        p1 := Q_PosStr('"', aName, p1);
        if p1 = 0 then exit;
        p2 := Q_PosStr('"', aName, p1 + 1);
        if p2 = 0 then exit;
        sv := copy(aName, p1 + 1, p2 - p1 - 1);
        n.AddAttribute(sn, sv);
        p1 := p2 + 1;
    until p1 > c;
end;

function TjanXMLNode.getNamedAttribute(aName: string): TjanXMLAttribute;
var
    i: integer;
    n: TjanXMLAttribute;
begin
    result := nil;
    if Attributes.Count = 0 then exit;
    for i := 0 to Attributes.Count - 1 do
    begin
        n := TjanXMLAttribute(Attributes[i]);
        if n.Name = aName then
        begin
            result := n;
            exit;
        end;
    end;
end;

procedure TjanXMLNode.ClearAttributes;
var
    i: integer;
begin
    if Attributes.Count <> 0 then
    begin
        for i := 0 to Attributes.Count - 1 do
            TjanXMLAttribute(Attributes[i]).free;
        Attributes.clear;
    end;
end;

procedure TjanXMLNode.ClearNodes;
var
    i: integer;
begin
    i := Nodes.Count;
    if i <> 0 then
    begin
        for i := 0 to Nodes.Count - 1 do
            TjanXMLNode(Nodes[i]).free;
        Nodes.clear;
    end;
end;

constructor TjanXMLNode.Create(aName: string; aValue: variant; aParent:
    TjanXMLNode);
begin
    FNodes := TList.Create;
    FName := aName;
    FValue := aValue;
    FValueType := xvtString;
    FParentNode := aParent;
    FAttributes := TList.Create;
    { 添加的 }
    FObject := nil;
end;

procedure TjanXMLNode.DeleteAttribute(index: integer);
begin
    TjanXMLAttribute(Attributes[index]).free;
end;

procedure TjanXMLNode.DeleteNode(index: integer);
begin
    TjanXMLNode(Nodes[index]).free;
end;

destructor TjanXMLNode.Destroy;
begin
    ClearNodes;
    FNodes.free;
    ClearAttributes;
    FAttributes.free;
    inherited;
end;

function TjanXMLNode.document(aLevel: integer): string;
const
    cr = chr(13) + chr(10);
    tab = chr(9);

var                                     //s:string;
    i: integer;
    spc: string;
    bHasValue: boolean;
    bxmlSybm: Boolean;

    function ExpandCDATA(aValue: string): string;
    begin
        result := stringreplace(aValue, '\n ', cr, [rfreplaceall]);
        result := stringreplace(result, '\t ', tab, [rfreplaceall]);
    end;
begin
    bHasValue := False;
    bxmlSybm := Pos('?xml', Name) <> 0;

    if (aLevel=0) and (bxmlSybm) then //处理<?xml .... ?>
    begin
        Result := '<?xml version="1.0" encoding="GB2312" ?>' + cr;
    end
    else
    begin
        if (aLevel > 0) and (Self.parentNode.Name <> '?xml') then
            spc := stringofchar(' ', aLevel * 4) //spc:=StringOfChar(' ',aLevel*2)
        else
            spc := '';

        if ValueType <> xvtComment then
        begin
            result := spc + '<' + Name;

            if Attributes.Count > 0 then
                for i := 0 to Attributes.Count - 1 do
                    result := result + TjanXMLAttribute(Attributes[i]).document;
            if (Nodes.Count = 0) and (VarToStr(Value) = '') then
            begin
                result := result + ' />' + cr;
                exit;
            end
            else
            if Nodes.Count = 0 then
                result := result + '>'
            else
                result := result + '>' + cr;
        end;
    end;
    { charmer modified: 增加了对Value是否为空等判断，并用VartoStr转换Value值 }
    //if Value<>'' then
    if (not VarIsNull(Value))
        or (not VarIsEmpty(Value))
        or (VarToStr(Value) <> '') then
    begin
        bHasValue := True;
        if ValueType = xvtString then
            result := result + VarToStr(Value)  //result:=result+spc+VarToStr(Value) //+cr
        else if ValueType = xvtCDATA then
        begin
            result := result + spc + '    ' + '<![CDATA[' + ExpandCDATA(Value) +
                ']]>' + cr;
        end
        else if ValueType = xvtComment then
        begin
            Result := Result + '<!--' + ExpandCDATA(Value) + '-->' + cr;
        end;
    end;
    if Nodes.Count <> 0 then
    begin
        //Result := Result + cr;
        for i := 0 to Nodes.Count - 1 do
            result := result + TjanXMLNode(Nodes[i]).document(aLevel + 1);
    end;

    if not (bxmlSybm or (ValueType = xvtComment)) then //xmlSybm: "?xml"
    begin
        if Nodes.Count = 0 then
            result := result + '</' + Name + '>' + cr
        else
            result := result + spc + '</' + Name + '>' + cr;
    end;
end;

function TjanXMLNode.CDataValue: string;
begin
    Result := Value;
    result := stringreplace(result, '\n ', #13#10, [rfreplaceall]);
    result := stringreplace(result, '\t ', #9, [rfreplaceall]);
end;

// duplicates a node recursively

function TjanXMLNode.cloneNode: TjanXMLNode;
var
    i: integer;
    n: TjanXMLNode;
begin
    result := TjanXMLNode.Create(Name, Value, nil);
    result.Name := Name;
    result.Value := Value;
    if Attributes.Count > 0 then
    begin
        for i := 0 to Attributes.Count - 1 do
        begin
            result.AddAttribute(TjanXMLAttribute(Attributes[i]).Name,
                TjanXMLAttribute(Attributes[i]).Value);
        end;
    end;
    if Nodes.Count > 0 then
    begin
        for i := 0 to Nodes.Count - 1 do
        begin
            n := TjanXMLNode(Nodes[i]).cloneNode;
            n.ValueType := TjanXMLNode(Nodes[i]).ValueType;
            n.parentNode := Result;
            result.Nodes.Add(n);
        end;
    end;
end;

function TjanXMLNode.getNamedNode(aName: string): TjanXMLNode;
var
    i: integer;
    n: TjanXMLNode;
begin
    result := nil;
    if Nodes.Count = 0 then exit;
    for i := 0 to Nodes.Count - 1 do
    begin
        n := TjanXMLNode(Nodes[i]);
        if n.Name = aName then
        begin
            result := n;
            exit;
        end;
    end;
end;

procedure TjanXMLNode.SetAttributes(const Value: TList);
begin
    FAttributes := Value;
end;

procedure TjanXMLNode.SetName(const Value: string);
begin
    FName := Value;
end;

procedure TjanXMLNode.SetNodes(const Value: TList);
begin
    FNodes := Value;
end;

procedure TjanXMLNode.SetParentNode(const Value: TjanXMLNode);
begin
    FParentNode := Value;
end;

procedure TjanXMLNode.SetValue(const Value: variant);
begin
    FValue := Value;
end;

function TjanXMLNode.firstChild: TjanXMLNode;
begin
    if Nodes.Count > 0 then
        result := TjanXMLNode(Nodes[0])
    else
        result := nil;
end;

function TjanXMLNode.lastChild: TjanXMLNode;
begin
    if Nodes.Count > 0 then
        result := TjanXMLNode(Nodes[Nodes.Count - 1])
    else
        result := nil;
end;

function TjanXMLNode.nextSibling: TjanXMLNode;
var
    index: integer;
begin
    result := nil;
    if parentNode = nil then exit;
    index := parentNode.Nodes.IndexOf(self);
    if index = -1 then exit;
    if index < parentNode.Nodes.Count - 1 then
        result := TjanXMLNode(parentNode.Nodes[index + 1]);
end;

function TjanXMLNode.previousSibling: TjanXMLNode;
var
    index: integer;
begin
    result := nil;
    if parentNode = nil then exit;
    index := parentNode.Nodes.IndexOf(self);
    if index = -1 then exit;
    if index > 0 then
        result := TjanXMLNode(parentNode.Nodes[index - 1]);
end;
// moves a node to a new location

function TjanXMLNode.moveInsertNode(Dest: TjanXMLNode): TjanXMLNode;
var
    index1, index2: integer;
begin
    result := nil;
    if Dest.parentNode = nil then exit; // can not move to root
    index1 := self.parentNode.Nodes.IndexOf(self);
    if index1 = -1 then exit;
    index2 := Dest.parentNode.Nodes.IndexOf(Dest);
    if index2 = -1 then exit;
    Dest.parentNode.Nodes.Insert(index2, self);
    self.parentNode.Nodes.delete(index1);
    self.parentNode := Dest.parentNode;
    result := self;
end;

function TjanXMLNode.moveAddNode(Dest: TjanXMLNode): TjanXMLNode;
var
    index: integer;
begin
    result := nil;
    if Dest = nil then exit;            // can not move to root
    index := self.parentNode.Nodes.IndexOf(self);
    if index = -1 then exit;
    Dest.Nodes.Add(self);
    self.parentNode.Nodes.delete(index);
    self.parentNode := Dest;
    result := self;
end;

// removes and frees the childnode recursively.
// returns self when done, or nil in case of error

function TjanXMLNode.removeChildNode(aNode: TjanXMLNode): TjanXMLNode;
var
    index: integer;
begin
    result := nil;
    index := Nodes.IndexOf(aNode);
    if index = -1 then exit;
    Nodes.delete(index);
    aNode.free;
    result := self;
end;

function TjanXMLNode.hasChildNodes: boolean;
begin
    result := Nodes.Count > 0;
end;

procedure TjanXMLNode.getAttributeNames(aList: TStringList);
var
    i, c: integer;
begin
    aList.clear;
    c := Attributes.Count;
    if c = 0 then exit;
    for i := 0 to c - 1 do
        aList.Append(TjanXMLAttribute(Attributes[i]).Name);
end;

procedure TjanXMLNode.getNodeNames(aList: TStringList);
var
    i, c: integer;
begin
    aList.clear;
    c := Nodes.Count;
    if c = 0 then exit;
    for i := 0 to c - 1 do
        aList.Append(TjanXMLNode(Nodes[i]).Name);
end;

function TjanXMLNode.getNodePath: string;
var
    n: TjanXMLNode;
begin
    n := self;
    result := Name;
    while n.parentNode <> nil do
    begin
        n := n.parentNode;
        result := n.Name + '/' + result;
    end;
end;

// search recursively for a named node

function TjanXMLNode.findNamedNode(aName: string): TjanXMLNode;
var
    i: integer;
    n: TjanXMLNode;
begin
    result := nil;
    if Nodes.Count = 0 then exit;
    for i := 0 to Nodes.Count - 1 do
    begin
        n := TjanXMLNode(Nodes[i]);
        if n.Name = aName then
        begin
            result := n;
            exit;
        end
        else
        begin                           // recurse
            result := n.findNamedNode(aName);
            if result <> nil then exit;
        end;
    end;
end;

// add all found named nodes to aList

procedure TjanXMLNode.findNamedNodes(aName: string; aList: TList);
var
    i: integer;
    n: TjanXMLNode;
begin
    if Nodes.Count = 0 then exit;
    for i := 0 to Nodes.Count - 1 do
    begin
        n := TjanXMLNode(Nodes[i]);
        if n.Name = aName then
            aList.Add(n);
        // recurse
        n.findNamedNodes(aName, aList);
    end;
end;

// add recursively all nodes to aList
// the list only contains pointers to the nodes
// typecast to use, e.g. n:=TjanXMLNode(aList[0]);

procedure TjanXMLNode.getAllNodes(aList: TList);
var
    i: integer;
    n: TjanXMLNode;
begin
    if Nodes.Count = 0 then exit;
    for i := 0 to Nodes.Count - 1 do
    begin
        n := TjanXMLNode(Nodes[i]);
        aList.Add(n);
        // recurse
        n.getAllNodes(aList);
    end;
end;

// add recursively all nodes with matching named attribute to aList
// the list only contains pointers to the nodes
// typecast to use, e.g. n:=TjanXMLNode(aList[0]);

procedure TjanXMLNode.findNamedAttributes(aName: string; aList: TList);
var
    i, c: integer;
    n: TjanXMLNode;
begin
    c := Attributes.Count;
    if c > 0 then
        for i := 0 to c - 1 do
        begin
            if TjanXMLAttribute(Attributes[i]).Name = aName then
            begin
                aList.Add(self);
                break;
            end;
        end;
    if Nodes.Count = 0 then exit;
    for i := 0 to Nodes.Count - 1 do
    begin
        n := TjanXMLNode(Nodes[i]);
        n.findNamedAttributes(aName, aList);
    end;
end;

{
this procedure adds the node to aList when it matches the pattern
this will be the key procedure for XSL implementation
only basic matching is provided in the first release
path operators
 /  child path
 // recursive descent
 .  curren context or node
 @  attribute
 *  wildcar
some examples
 /  the root node only
 book/author  <author> elements that are children of <book> elements
 // the root node and all nodes below
 //*  all element nodes below the root node
 book//author  <author> elements that are descendants of <book> elements
 .//author  <author elements that are descendants of the current element
 *  non-root elements, irrespective of the element name
 book/*  elements that are children of <book> elements
 book//* elements that are descendants of <book> elements
 book/*/author  <author> elements that are grandchildren of <book> elements
 book/@print_date print_date attributes that are attached to <book> elements
 */@print_date print_date atrtributes that are attached to any elements

index can be used to specify a particular node within a matching set
 /booklist/book[0]  First <book> node in root <booklist> element
 /booklist/book[2]  Third <book> node in root <booklist> element
 /booklist/book[end()] Last <book> node in root <booklist> element
}

procedure TjanXMLNode.matchPattern(aPattern: string; aList: TList);
begin
    // to be implemented
end;

procedure TjanXMLNode.SetValueType(const Value: TjanXMLValueType);
begin
    FValueType := Value;
end;

{select a node based on path info
 e.g. booklist/book/category will find the first
 <category> that is a child of <book> that is a child of <booklist>
 }

function TjanXMLNode.SelectSingleNode(pattern: string): TjanXMLNode;
var                                     {aName,}
    npattern, aFilter: string;
    p, i, c: integer;
    n: TjanXMLNode;
    objFilter: TjanXMLFilter;
begin
    result := nil;
    c := Nodes.Count;
    if c = 0 then exit;
    p := pos('/', pattern);
    if p = 0 then
    begin
        objFilter := TjanXMLFilter.Create(pattern);
        for i := 0 to c - 1 do
        begin
            n := TjanXMLNode(Nodes[i]);
            if n.matchFilter(objFilter) then
            begin
                result := n;
                objFilter.free;
                exit;
            end;
        end;
        objFilter.free;
        exit;                           // not found;
    end
    else
    begin
        aFilter := copy(pattern, 1, p - 1);
        npattern := copy(pattern, p + 1, length(pattern));
        objFilter := TjanXMLFilter.Create(aFilter);
        for i := 0 to c - 1 do
        begin
            n := TjanXMLNode(Nodes[i]);
            if n.matchFilter(objFilter) then
            begin
                result := n.SelectSingleNode(npattern);
                if result <> nil then
                begin
                    objFilter.free;
                    exit
                end;
            end;
        end;
        objFilter.free;
    end;
end;

// filter contains name + any filters between []

function TjanXMLNode.matchFilter(objFilter: TjanXMLFilter): boolean;
var
    i, j: integer;
    attName {,attValue}: string;
    a: TjanXMLAttribute;
    n: TjanXMLNode;
    atom: TjanXMLFilterAtom;
    attResult: boolean;

    function evalAtom(aValue: string): boolean;
    begin
        result := False;
        case atom.Operator of
            xfoNOP: result := True;
            xfoEQ: result := aValue = atom.Value;
            xfoIEQ: result := comparetext(aValue, atom.Value) = 0;
            xfoNE: result := aValue <> atom.Value;
            xfoINE: result := comparetext(aValue, atom.Value) <> 0;
            xfoGT:
                try
                    result := Strtofloat(aValue) > Strtofloat(atom.Value);
                except
                end;
            xfoIGT: result := comparetext(aValue, atom.Value) > 0;
            xfoLT:
                try
                    result := Strtofloat(aValue) < Strtofloat(atom.Value);
                except
                end;
            xfoILT: result := comparetext(aValue, atom.Value) < 0;
            xfoGE:
                try
                    result := Strtofloat(aValue) >= Strtofloat(atom.Value);
                except
                end;
            xfoIGE: result := comparetext(aValue, atom.Value) >= 0;
            xfoLE:
                try
                    result := Strtofloat(aValue) <= Strtofloat(atom.Value);
                except
                end;
            xfoILE: result := comparetext(aValue, atom.Value) <= 0;
        end;

    end;
begin
    result := False;
    attResult := False;
    if objFilter.Filters.Count = 0 then
    begin                               // just filter on name
        result := objFilter.Name = Name;
        exit;
    end;
    for i := 0 to objFilter.Filters.Count - 1 do
    begin
        atom := TjanXMLFilterAtom(objFilter.Filters[i]);
        if atom.AttributeFilter then
        begin
            attName := atom.Name;
            if attName = '*' then
            begin                       // match any attribute
                if Attributes.Count = 0 then exit;
                for j := 0 to Attributes.Count - 1 do
                begin
                    a := TjanXMLAttribute(Attributes[j]);
                    attResult := evalAtom(a.Value);
                    if attResult then break;
                end;
                if not attResult then exit;
            end
            else
            begin
                a := getNamedAttribute(attName);
                if a = nil then exit;
                if not evalAtom(a.Value) then exit;
            end;
        end
        else
        begin
            attName := atom.Name;
            n := getNamedNode(attName);
            if n = nil then exit;
            if not evalAtom(n.Value) then exit;
        end;
    end;
    result := True;
end;

procedure TjanXMLNode.selectNodes(pattern: string; aList: TList);
var                                     {aName,}
    npattern: string;
    p, i, c: integer;
    n: TjanXMLNode;
    aFilter: string;
    objFilter: TjanXMLFilter;
    recurse: boolean;
begin
    c := Nodes.Count;
    if c = 0 then exit;
    if copy(pattern, 1, 2) = '//' then
    begin                               //recursive
        delete(pattern, 1, 2);
        recurse := True;
    end
    else
        recurse := False;
    p := pos('/', pattern);
    if p = 0 then
    begin
        aFilter := pattern;
        objFilter := TjanXMLFilter.Create(aFilter);
        for i := 0 to c - 1 do
        begin
            n := TjanXMLNode(Nodes[i]);
            if n.matchFilter(objFilter) then
                aList.Add(n)
            else
            begin
                if recurse then
                    n.selectNodes('//' + pattern, aList);
            end;
        end;
        objFilter.free;
    end
    else
    begin
        aFilter := copy(pattern, 1, p - 1);
        if copy(pattern, p, 2) = '//' then
            npattern := copy(pattern, p, length(pattern))
        else
            npattern := copy(pattern, p + 1, length(pattern));
        objFilter := TjanXMLFilter.Create(aFilter);
        for i := 0 to c - 1 do
        begin
            n := TjanXMLNode(Nodes[i]);
            if n.matchFilter(objFilter) then
                n.selectNodes(npattern, aList)
            else
            begin
                if recurse then
                    n.selectNodes('//' + pattern, aList);
            end;
        end;
        objFilter.free;
    end;
end;

// the XSL implementation
// although this function returns a string, the string itself can be parsed to create a DOM

function TjanXMLNode.transformNode(stylesheet: TjanXMLNode): string;
begin
    // to be implemented;
    result := stylesheet.process(0, self);
end;

// used in conjunction with the transformNode function.
// basically works like the document function except for nodes with processing instructions

function TjanXMLNode.process(aLevel: integer; node: TjanXMLNode): string;
const
    cr = chr(13) + chr(10);
    tab = chr(9);

var                                     //s:string;
    i: integer;
    spc: string;

    function ExpandCDATA(aValue: string): string;
    begin
        result := stringreplace(aValue, '\n ', cr, [rfreplaceall]);
        result := stringreplace(result, '\t ', tab, [rfreplaceall]);
    end;
begin
    if parentNode = nil then
    begin
        if Nodes.Count <> 0 then
            for i := 0 to Nodes.Count - 1 do
                result := result + TjanXMLNode(Nodes[i]).process(aLevel + 1,
                    node);
        exit;
    end;
    if aLevel > 0 then
        spc := stringofchar(' ', aLevel * 2)
    else
        spc := '';
    result := spc + '<' + Name;
    if Attributes.Count > 0 then
        for i := 0 to Attributes.Count - 1 do
            result := result + TjanXMLAttribute(Attributes[i]).document;
    if (Nodes.Count = 0) and (Value = '') then
    begin
        result := result + ' />' + cr;
        exit;
    end
    else
        result := result + '>' + cr;
    if Value <> '' then
    begin
        if ValueType = xvtString then
            result := result + spc + '  ' + Value + cr
        else if ValueType = xvtCDATA then
        begin
            result := result + spc + '  ' + '<![CDATA[' + ExpandCDATA(Value) +
                ']]>' + cr;
        end
    end;
    if Nodes.Count <> 0 then
        for i := 0 to Nodes.Count - 1 do
            result := result + TjanXMLNode(Nodes[i]).process(aLevel + 1, node);
    result := result + spc + '</' + Name + '>' + cr;
end;

function TjanXMLNode.getNameSpace: string;
var
    p: integer;
begin
    p := pos(':', FName);
    if p > 0 then
        result := copy(FName, 1, p - 1)
    else
        result := '';
end;

{ TjanXMLTree }

constructor TjanXMLTree.Create(aName: string; aValue: variant; aParent:
    TjanXMLNode);
begin
    inherited Create(aName, aValue, aParent);
    FLines := TStringList.Create;
end;

destructor TjanXMLTree.Destroy;
begin
    FLines.free;
    inherited Destroy;
end;

function TjanXMLTree.asText: string;
var
    i, c: integer;
begin
    c := Nodes.Count;
    if c = 0 then exit;
    result := '<' + Name;
    if Attributes.Count > 0 then
        for i := 0 to Attributes.Count - 1 do
            result := result + TjanXMLAttribute(Attributes[i]).document;
    result := result + '>' + cr;
    for i := 0 to c - 1 do
        result := result + TjanXMLNode(Nodes[i]).document(1);
    result := result + '</' + Name + '>' + cr;
end;

procedure TjanXMLTree.SaveToFile(aFile: string);
begin
    Lines.Text := Text;
    Lines.SaveToFile(aFile)
end;

procedure TjanXMLTree.SetLines(const Value: TStringList);
begin
    FLines.assign(Value);
end;

procedure TjanXMLTree.LoadFromStream(Stream: TStream);
begin
    ClearNodes;
    ClearAttributes;
    Lines.LoadFromStream(Stream);
    PreProcessXML(FLines);
    ParseXML;
end;

procedure TjanXMLTree.SaveToStream(Stream: TStream);
begin
    Lines.Text := asText;
    Lines.SaveToStream(Stream);
end;

function TjanXMLTree.getText: string;
var
    i, c: integer;
begin
    c := Nodes.Count;
    if c = 0 then exit;
    //  result:='<'+Name;
    //  if Attributes.Count>0 then
    //  for i:=0 to Attributes.count-1 do
    //    result:=result+TjanXMLAttribute(Attributes[i]).document;
    //  result:=result+'>'+cr;
    result := '';
    for i := 0 to c - 1 do
        result := result + TjanXMLNode(Nodes[i]).document(0);
    //  result:=result+'</'+Name+'>'+cr;
end;

procedure TjanXMLTree.setText(const Value: string);
begin
    ClearNodes;
    ClearAttributes;
    Lines.Text := Value;
    PreProcessXML(FLines);
    ParseXML;
end;

{ TjanXMLAttribute }

constructor TjanXMLAttribute.Create(aName: string; aValue: variant);
begin
    FName := aName;
    FValue := aValue;
end;

function TjanXMLAttribute.document: string;
var
    s: string;
begin
    s := VarToStr(Value);
    result := ' ' + Name + '="' + s + '"';
end;

procedure TjanXMLAttribute.SetName(const Value: string);
begin
    FName := Value;
end;

procedure TjanXMLAttribute.SetValue(const Value: variant);
begin
    FValue := Value;
end;

{ TjanXMLTree }

procedure TjanXMLTree.ParseXML;
var
    i, c {,Index}: integer;
    s, token, aName: string;
    n,nCmt: TjanXMLNode;
begin
    i := 0;
    FNodeCount := 0;
    ClearNodes;
    ClearAttributes;
    Name := 'root';
    n := self;
    c := Lines.Count - 1;
    repeat
        s := Lines[i];
        token := copy(s, 1, 3);
        aName := copy(s, 4, length(s));
        if token = 'OT:' then
        begin
            n := n.AddNodeEx(aName, '');
            inc(FNodeCount);
        end
        else if token = 'CT:' then
        begin
            n := n.parentNode;
        end
        else if token = 'ET:' then
        begin
            n.AddNodeEx(aName, '');
        end
        else if token = 'TX:' then
        begin
            n.Value := aName;
            n.ValueType := xvtString;
        end
        else if token = 'CD:' then
        begin
            n.Value := aName;
            n.ValueType := xvtCDATA;
        end
        else if token = 'CM:' then
        begin
            nCmt := n.AddNodeEx('!--',aName);
            nCmt.ValueType := xvtComment;
            Inc(FNodeCount);
        end;
        inc(i);
    until i > c;
end;

procedure TjanXMLTree.LoadFromFile(fn: string);
begin
    ClearNodes;
    ClearAttributes;
    Lines.LoadFromFile(fn);
    PreProcessXML(FLines);
    ParseXML;
end;

{ TjanXMLFilter }

constructor TjanXMLFilter.Create(FilterStr: string);
var {aName,}                            {aFilter,}
    theFilter {,nextFilter}: string;
    p1, p2: integer;
    attName, attValue: string;
    attOperator: TjanXMLFilterOperator;
    atom: TjanXMLFilterAtom;
    //a:TjanXMLAttribute;
    //n:TjanXMLNode;

    function trimquotes(s: string): string;
    var
        cc: integer;
    begin
        result := trim(s);
        if s = '' then exit;
        if (s[1] = '"') or (s[1] = '''') then delete(result, 1, 1);
        if s = '' then exit;
        cc := length(result);
        if (result[cc] = '"') or (result[cc] = '''') then delete(result, cc, 1);
    end;

    function splitNameValue(s: string): boolean;
    var
        pp: integer;
    begin
        result := False;
        pp := Q_PosStr(' $ne$ ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoNE;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 6, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        pp := Q_PosStr(' $ine$ ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoINE;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 7, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        pp := Q_PosStr(' $ge$ ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoGE;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 6, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        pp := Q_PosStr(' $ige$ ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoIGE;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 7, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        pp := Q_PosStr(' $gt$ ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoGT;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 6, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        pp := Q_PosStr(' $igt$ ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoIGT;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 7, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        pp := Q_PosStr(' $le$ ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoLE;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 6, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        pp := Q_PosStr(' $ile$ ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoILE;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 7, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        pp := Q_PosStr(' $lt$ ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoLT;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 6, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        pp := Q_PosStr(' $ilt$ ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoILT;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 7, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        pp := Q_PosStr(' $eq$ ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoEQ;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 6, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        pp := Q_PosStr(' $ieq$ ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoIEQ;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 7, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        pp := Q_PosStr(' = ', s, 1);
        if pp > 0 then
        begin
            attOperator := xfoEQ;
            attName := trim(copy(s, 1, pp - 1));
            attValue := trimquotes(copy(s, pp + 3, length(s)));
            result := (attName <> '') and (attValue <> '');
            exit;
        end;
        attOperator := xfoNOP;
        attName := s;
        attValue := '';
        result := True;
        exit;
    end;

begin
    Filters := TList.Create;
    p1 := Q_PosStr('[', FilterStr, 1);
    if p1 = 0 then
    begin                               // just a name filter on name
        Name := FilterStr;
        exit;
    end
    else
    begin
        Name := copy(FilterStr, 1, p1 - 1);
        delete(FilterStr, 1, p1 - 1);
    end;
    repeat
        FilterStr := trim(FilterStr);
        p1 := Q_PosStr('[', FilterStr, 1);
        if p1 = 0 then exit;
        p2 := Q_PosStr(']', FilterStr, p1 + 1);
        if p2 = 0 then exit;
        theFilter := copy(FilterStr, p1 + 1, p2 - p1 - 1);
        delete(FilterStr, 1, p2);
        if theFilter = '' then exit;
        // check for attribute filter
        if theFilter[1] = '@' then
        begin
            if not splitNameValue(copy(theFilter, 2, length(theFilter))) then
                exit;
            atom := TjanXMLFilterAtom.Create;
            atom.Name := attName;
            atom.Operator := attOperator;
            atom.Value := attValue;
            atom.AttributeFilter := True;
            Filters.Add(atom);
        end
        else
        begin                           // childfilter
            if not splitNameValue(theFilter) then exit;
            atom := TjanXMLFilterAtom.Create;
            atom.Name := attName;
            atom.Operator := attOperator;
            atom.Value := attValue;
            atom.AttributeFilter := False;
            Filters.Add(atom);
        end;
    until FilterStr = '';
end;

destructor TjanXMLFilter.Destroy;
var
    i: integer;
begin
    if Filters.Count > 0 then
        for i := 0 to Filters.Count - 1 do
            TjanXMLFilterAtom(Filters[i]).free;
    Filters.free;
    inherited Destroy;
end;

procedure TjanXMLFilter.SetFilters(const Value: TList);
begin
    FFilters := Value;
end;

procedure TjanXMLFilter.SetName(const Value: string);
begin
    FName := Value;
end;

{ TjanXMLFilterAtom }

procedure TjanXMLFilterAtom.SetAttributeFilter(const Value: boolean);
begin
    FAttributeFilter := Value;
end;

procedure TjanXMLFilterAtom.SetName(const Value: string);
begin
    FName := Value;
end;

procedure TjanXMLFilterAtom.SetOperator(
    const Value: TjanXMLFilterOperator);
begin
    FOperator := Value;
end;

procedure TjanXMLFilterAtom.SetValue(const Value: string);
begin
    FValue := Value;
end;

end.

