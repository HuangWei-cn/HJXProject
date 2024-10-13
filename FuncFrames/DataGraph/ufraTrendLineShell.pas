{ -----------------------------------------------------------------------------
  Unit Name: Unit1
  Author:    ��ΰ
  Date:      04-����-2018
  Purpose:   fraBaseTrendLine�Ŀǣ�������ø�Frame������ԪΪ���װ��
  ��Ҫ���ƹ����ߵĹ��ܿ�����ñ�Frame��
  TfraTrendLineShell���һ���������Ϊ���������ʵ���������û�����
  ����ʾ��������Ϊ�û������е�һ���֣���һ���棬����Ԫ��ͼ�ε�����
  �ṩ��DrawMeterGraph������ʵ��ִ���ߡ�
  History:   2018-07-26 ���Ӹ���Ԥ����Template��ͼ�Ĺ���
  2018-09-21 ��Frame���С��450��߶�С��210ʱ���Զ�ת��Ϊ����ģʽ

  2022-10-27 ������DrawMultiLine������֧�ֻ��Ƹ�����һ������������
  ע�᷽����DrawGroupLine������TfraTrendLineShell��DrawMultiLine
  ������
  DrawMultiLine�����ChartTemplateProc.DrawGroupLines������ɻ���
  ���̡�
  Ϊ�ܽ�ƽ����β��Ĺ�����Ҳ���Ƴ�������Ԥ����ģ���ж�����ƽ��
  ��㣬���ڱ�����û����GraphDispatcher��ע������͵Ĺ����ߣ����
  �ڻ���ƽ���ʱ����Ȼ�ǻ�����ʸ��ͼ��ֻ���ڻ����������ʱ�Ż��
  ��ƽ���Ĺ����ߡ�����ƽ���Ĺ��������������Ļ��Ʒ������Ѿ�����
  ----------------------------------------------------------------------------- }

unit ufraTrendLineShell;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  uHJX.Intf.Datas, uHJX.Intf.AppServices, uHJX.Intf.GraphDispatcher, uHJX.ProjectGlobal,
  ufraBasicTrendLine {, uFuncDataGraph};

type
  TfraTrendLineShell = class(TFrame)
    procedure FrameResize(Sender: TObject);
  private
    { Private declarations }
    FMeterName      : String;
    FDTStart, FDTEnd: TDateTime;
    FfraTL          : TfraBasicTrendLine;
    // �������������������������,������Ϊ��ʱ����
    procedure SetAxisTitles(AMeterType: string);
    { ����ͨ�����������ߣ���㡢ê��֮��� }
    procedure _DrawNormalLine(ADsnName: string; DTStart, DTEnd: TDateTime);
    { ����ê��������� }
    procedure _DrawMGGroupLine(AGrpName: string; DTStart, DTEnd: TDateTime);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { -------------- }
    { ����Ʊ�ţ���ʾȫ�����ݵĹ����ߡ�Ŀǰ�����ǹ�������ʽ֮��Ķ��� }
    procedure DrawLine(ADsnName: string); overload; // 2018-06-05 ������Ӧ��ΪDrawDatas����ͳһ����ͼ��
    { ֮��������DrawLine��������Ϊ�˲��ı��������롣��Ȼ�����������������϶�Ϊһ }
    procedure DrawLine(ADsnName: string; DTStart, DTEnd: TDateTime); overload;
    { ���ƶ������Ĺ�������һ��Chart�� }
    procedure DrawMutiLine(AMeters: TStrings);
  end;

implementation

uses
  {uHJX.Excel.Meters} uHJX.Classes.Meters, uHJX.Classes.Templates,
  {
    uTLDefineProc, uFuncDrawTLByStyle, //2018-07-26���Ӹ���Style��ͼ��صĵ�Ԫ
    2018-09-13 ��������Ԫ��ChartTemplate��ChartTemplateProc��Ԫȡ��
  }
  uHJX.Template.ChartTemplate, uHJX.Template.ChartTemplateProc, // 2018-09-13 �»�ͼģ���༰�䴦��
  VCLTee.TeeJPEG, VCLTee.TeePNG, VCLTee.TeeHTML5Canvas;
{$R *.dfm}

var
  fraTLTool: TfraTrendLineShell; // ����Ԫ��ʼ��ʱ����һ��ʵ�������ڵ���������
  JpgFmt   : TJPEGExportFormat;

constructor TfraTrendLineShell.Create(AOwner: TComponent);
begin
  inherited;
  FfraTL := TfraBasicTrendLine.Create(Self);
  FfraTL.Parent := Self;
  FfraTL.Align := alClient;
end;

destructor TfraTrendLineShell.Destroy;
begin
  FfraTL.Free;
  inherited;
end;

{ -----------------------------------------------------------------------------
  Procedure  : DrawLine
  Description: ������Ʊ�ţ���ʾ�������Ĳ�ֵ������
  ----------------------------------------------------------------------------- }
procedure TfraTrendLineShell.DrawLine(ADsnName: string);
var
  mt: TMeterDefine;
begin
  FMeterName := ADsnName;
  FDTStart := 0;
  FDTEnd := 0;
  FfraTL.ReleaseTrendLines;
  // FfraTL.ClearDatas(FfraTL.Series1);
  if IHJXClientFuncs = nil then
    Exit;

  mt := ExcelMeters.Meter[ADsnName];
  { 2018-07-26 �ù����߶����ͼ }
  if mt.ChartPreDef <> nil then
    DrawMeterSeries(FfraTL.chtLine, mt.ChartPreDef as TChartTemplate { TTrendlinePreDefine } ,
      ADsnName, 0, 0)
  else
  begin
    if (mt.Params.MeterType = 'ê��Ӧ����') and (mt.PrjParams.GroupID <> '') then
      _DrawMGGroupLine(mt.PrjParams.GroupID, 0, 0)
    else
      _DrawNormalLine(mt.DesignName, 0, 0);
  end;
  // ���Դ��룬��ͼ��ϣ�����
  // FfraTL.chtLine.SaveToMetafileEnh('e:\test_'+adsnname+'.emf');
end;

procedure TfraTrendLineShell.DrawLine(ADsnName: string; DTStart: TDateTime; DTEnd: TDateTime);
var
  mt: TMeterDefine;
begin
  if (DTStart = 0) and (DTEnd = 0) then
    DrawLine(ADsnName)
  else
  begin
    FMeterName := ADsnName;
    FDTStart := DTStart;
    FDTEnd := DTEnd;
    FfraTL.ReleaseTrendLines;
    if IHJXClientFuncs = nil then
      Exit;
    mt := ExcelMeters.Meter[ADsnName];
    { 2018-07-26 �ù�����Ԥ�����ͼ }
    if mt.ChartPreDef <> nil then
      DrawMeterSeries(FfraTL.chtLine, mt.ChartPreDef as TChartTemplate { TTrendlinePreDefine } ,
        ADsnName, DTStart, DTEnd)
    else
    begin
      if (mt.Params.MeterType = 'ê��Ӧ����') and (mt.PrjParams.GroupID <> '') then
        _DrawMGGroupLine(mt.PrjParams.GroupID, DTStart, DTEnd)
      else
        _DrawNormalLine(mt.DesignName, DTStart, DTEnd);
    end;
  end;
end;

procedure TfraTrendLineShell.FrameResize(Sender: TObject);
begin
  if (Width <= 450) or (Height <= 210) then
    FfraTL.Minimalism := True
  else
    FfraTL.Minimalism := False;
end;

{ -----------------------------------------------------------------------------
  Procedure  : _DrawNormalLine
  Description: ������ͨ�����Ĺ�����
  ----------------------------------------------------------------------------- }
procedure TfraTrendLineShell._DrawNormalLine(ADsnName: string; DTStart, DTEnd: TDateTime);
var
  DS  : TClientDataSet;
  Flds: TList;
  NewL: Integer;
  i   : Integer;
  mt  : TMeterDefine;
  // ê�������ƹ�����
  procedure _SetMSLines;
  begin
    FfraTL.NewLine(DS.Fields[1].DisplayName);        // ������ԤӦ��
    FfraTL.NewLine(DS.Fields[2].DisplayName, False); // �¶�
    DS.First;
    repeat
      FfraTL.AddData(0, DS.Fields[0].AsDateTime, DS.Fields[1].Value { .AsFloat } );
      FfraTL.AddData(1, DS.Fields[0].AsDateTime, DS.Fields[2].Value { .AsFloat } );
      DS.Next;
    until DS.Eof;
  end;

begin
  mt := ExcelMeters.Meter[ADsnName];
  SetAxisTitles(mt.Params.MeterType);
  DS := TClientDataSet.Create(Self);
  Flds := TList.Create;
  try
    if (DTStart = 0) and (DTEnd = 0) then
    begin
      if (TrendLineSetting.DTStart = 0) and (TrendLineSetting.DTEnd = 0) then
        IHJXClientFuncs.GetAllPDDatas(ADsnName, DS)
      else
        IHJXClientFuncs.GetPDDatasInPeriod(ADsnName, TrendLineSetting.DTStart,
          TrendLineSetting.DTEnd, DS);
    end
    else
    begin
      if DTEnd = 0 then
        DTEnd := Now;
      IHJXClientFuncs.GetPDDatasInPeriod(ADsnName, DTStart, DTEnd, DS);
    end;

    FfraTL.SetChartTitle(mt.Params.MeterType + ADsnName + '��ʱ������ͼ');
    // FfraTL.Series1.Title := ds.Fields[1].DisplayName;
    // �ж��Ƿ�ȡ������
    if DS.RecordCount <> 0 then
    begin
      // ��ÿ������������һ��Line
      if mt.Params.MeterType = 'ê��������' then
        _SetMSLines
      else
      begin
        for i := 1 to DS.FieldCount - 1 do
          if DS.Fields[i].DataType = ftFloat then
          begin
            if Pos('�¶�', DS.Fields[i].DisplayName) = 0 then
              NewL := FfraTL.NewLine(DS.Fields[i].DisplayName)
            else
              NewL := FfraTL.NewLine(DS.Fields[i].DisplayName, False);

            // �������еĸ����ֶζ�����һ���ߣ���˽�Serials��ź��ֶζ�Ӧ����
            // Flds�����е�Index��Ӧ��FFraTL��Serials����ţ�Item��Ӧ�������ֶ�
            Flds.Add(DS.Fields[i]);
          end;

        DS.First;
        repeat
          // fields[0]Ϊ�۲�����
          // for i := 1 to DS.FieldCount - 1 do
          // FfraTL.DrawLine(i - 1, DS.Fields[0].AsDateTime, DS.Fields[i].AsFloat);
          for i := 0 to Flds.Count - 1 do
            FfraTL.AddData(i, DS.Fields[0].AsDateTime, TField(Flds.Items[i]).Value);
          (* 2022-05-11 ԭ����ܿ���Null�㣬�����¹����߲�����ʵ�ʣ�������ѹ��ˮλ����
            if not TField(Flds.Items[i]).IsNull then
            FfraTL.AddData(i, DS.Fields[0].AsDateTime, TField(Flds.Items[i]).AsFloat);
          *)
          DS.Next;
        until DS.Eof;
      end;
    end;
  finally
    DS.Free;
    Flds.Free;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : _DrawMGGroupLine
  Description: ����ê���������
  ----------------------------------------------------------------------------- }
procedure TfraTrendLineShell._DrawMGGroupLine(AGrpName: string; DTStart, DTEnd: TDateTime);
var
  DS  : TClientDataSet;
  NewL: Integer;
  iMT : Integer;
  mt  : TMeterDefine;
  grp : TMeterGroupItem;
begin
  grp := MeterGroup.ItemByName[AGrpName];
  if grp = nil then
    Exit;
  DS := TClientDataSet.Create(Self);
  mt := ExcelMeters.Meter[grp.Items[0]];
  FfraTL.SetChartTitle(mt.Params.MeterType + '��' + AGrpName + '��ʱ������ͼ');
  SetAxisTitles(mt.Params.MeterType);

  // ��ȡ���������ݣ�
  try
    for iMT := 0 to grp.Count - 1 do
    begin
      mt := ExcelMeters.Meter[grp.Items[iMT]];
      if mt = nil then
        Continue;

      // ȡ����֧����������
      if (DTStart = 0) and (DTEnd = 0) then
        IHJXClientFuncs.GetAllPDDatas(mt.DesignName, DS)
      else
      begin
        if DTEnd = 0 then
          DTEnd := Now;
        IHJXClientFuncs.GetPDDatasInPeriod(mt.DesignName, DTStart, DTEnd, DS);
      end;
      if DS.RecordCount > 0 then
      begin
        NewL := FfraTL.NewLine(mt.DesignName + mt.PDName(0));
        DS.First;
        repeat
          FfraTL.AddData(NewL, DS.Fields[0].AsDateTime, DS.Fields[1].Value);
          { 2022-05-11 ԭ����ܿ���Null�㣬�����¹����߲�����ʵ��
            if not DS.Fields[1].IsNull then
            FfraTL.AddData(NewL, DS.Fields[0].AsDateTime, DS.Fields[1].AsFloat);
          }
          DS.Next;
        until DS.Eof;
      end;
    end;

  finally
    DS.Free;
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : SetAxisTitles
  Description: �������������
  ----------------------------------------------------------------------------- }
procedure TfraTrendLineShell.SetAxisTitles(AMeterType: string);
begin
  if AMeterType = '���λ�Ƽ�' then
  begin
    FfraTL.chtLine.LeftAxis.Title.Caption := 'λ��(mm)';
  end
  else if AMeterType = 'ê��������' then
  begin
    FfraTL.chtLine.LeftAxis.Title.Caption := 'ԤӦ��(kN)';
    FfraTL.chtLine.RightAxis.Title.Caption := '�¶�(��)';
  end
  else if AMeterType = 'ê��Ӧ����' then
  begin
    FfraTL.chtLine.LeftAxis.Title.Caption := '����(kN)';
    FfraTL.chtLine.RightAxis.Title.Caption := '�¶�(��)';
  end;
end;

{ -----------------------------------------------------------------------------
  Procedure  : DrawMutiLine
  Description: 2022-10-27����һ�������Ĺ�������һ��Chart��
  ----------------------------------------------------------------------------- }
procedure TfraTrendLineShell.DrawMutiLine(AMeters: TStrings);
begin
  // ShowMessage('Ŷ����Ҫһ��������� :) ������' + IntToStr(AMeters.Count));
  DrawGroupLines(FfraTL.chtLine, AMeters);
end;

{ -----------------------------------------------------------------------------
  Procedure  : DrawTrendLine
  Description: ע��Ļ�ͼ����
  ----------------------------------------------------------------------------- }
function DrawTrendLine(ADesignName: String; AOwner: TComponent): TComponent; // TFrame;
begin
  Result := TfraTrendLineShell.Create(AOwner);
  (Result as TfraTrendLineShell).DrawLine(ADesignName);
end;

{ -----------------------------------------------------------------------------
  Procedure  : DrawGroupLine
  Description: ����ע��Ļ����������һ�����������ߵķ���
  ----------------------------------------------------------------------------- }
function DrawGroupLine(AMeters: TStrings; AOwner: TComponent): TComponent;
begin
  Result := TfraTrendLineShell.Create(AOwner);
  (Result as TfraTrendLineShell).DrawMutiLine(AMeters);
end;

{ -----------------------------------------------------------------------------
  Procedure  : ExportGraphToFile
  Description: ע��ĵ���ͼ�ε�JPEG��ʽ����������ֵΪPath+ADesignName+'.jpg'
  ----------------------------------------------------------------------------- }
function ExportGraphToFile(ADesignName: string; DTStart, DTEnd: TDateTime; APath: string;
  AWidth, AHeight: Integer): string;
var
  S      : string;
  TmpPath: array [0 .. 255] of Char;
begin
  if not Assigned(fraTLTool) then
    fraTLTool := TfraTrendLineShell.Create(nil);
  fraTLTool.Width := AWidth;
  fraTLTool.Height := AHeight;
  fraTLTool.DrawLine(ADesignName, DTStart, DTEnd);
  if (APath = '') or not DirectoryExists(APath) then
  begin
    Winapi.Windows.GetTempPath(255, @TmpPath);
    APath := StrPas(TmpPath);
  end;

  S := APath + ADesignName + '.jpg';
  fraTLTool.FfraTL.chtLine.Legend.CheckBoxes := False;
  TeeSaveToJPEG(fraTLTool.FfraTL.chtLine, S, AWidth, AHeight);
  Result := S;
end;

{ -----------------------------------------------------------------------------
  Procedure  : ExportGraphToStream
  Description: ע��ĵ���ͼ�ε�Stream����
  ----------------------------------------------------------------------------- }
function ExportGraphToStream(ADesignName: string; DTStart, DTEnd: TDateTime; var AStream: TStream;
  AWidth, AHeight: Integer): Boolean;
begin
  if not Assigned(fraTLTool) then
    fraTLTool := TfraTrendLineShell.Create(nil);
  fraTLTool.Width := AWidth;
  fraTLTool.Height := AHeight;

  if not Assigned(JpgFmt) then
    JpgFmt := TJPEGExportFormat.Create;

  JpgFmt.Panel := fraTLTool.FfraTL.chtLine;
  fraTLTool.DrawLine(ADesignName);
  fraTLTool.FfraTL.chtLine.Legend.CheckBoxes := False;
  JpgFmt.SaveToStream(AStream);
  Result := True;
end;

procedure RegistSelf;
var
  IGD: IGraphDispatcher;
  //TS : TTemplates;
  //CT : TChartTemplate;
  //i  : Integer;
begin
  if Assigned(IAppServices) then
    if IAppServices.GetDispatcher('GraphDispatcher') <> nil then
      if Supports(IAppServices.GetDispatcher('GraphDispatcher'), IGraphDispatcher, IGD) then
      begin
        //TS := IAppServices.Templates as TTemplates;
        /// ���й����߾��ñ�ģ���ͼ
        IGD.RegistDrawFuncs('������', DrawTrendLine);
        IGD.RegistExportFunc('������', ExportGraphToFile);
        IGD.RegistSaveStreamFunc('������', ExportGraphToStream);
        {
          for i := 0 to ts.ChartTemplateCount  -1 do
          begin
          ct := ts.ChartTemplate[i] as Tcharttemplate;
          if ct.ChartType = cttTrendLine then
          begin
          ///���ﳢ����ģ���������������ͣ����ͬʱӦ�ø���GraphDispatcher�е��ȷ����������Ǹ���
          ///  ע��ṹ������ģ���ע��ṹ�����������͡���
          ///  ��ϧ����������Ǵ���ġ�������Ԫע��ʱ��������û�м��أ�ģ��������0����
          IGD.RegistDrawFuncs(ct.TemplateName , DrawTrendLine);
          IGD.RegistExportFunc(ct.TemplateName, ExportGraphToFile);
          IGD.RegistSaveStreamFunc(ct.TemplateName, ExportGraphToStream);
          end;
          end;
        }
        { 2018-07-26 ���ھ߱��˸���Ԥ�����Style��ͼ�Ĺ��ܣ������Ͻ���ֻҪһ�������ж�Ӧ��
          Style���������������Ͷ����Ի�ͼ�����ָ����������ͽ��л�ͼע��ķ�ʽ�Ѿ������ʱ��
          �ˣ���Ҫ�Ľ� }
        { DONE -ohw -cDrawGraph : ע�᷽��Ӧ�øĽ�������ģ�����������ͺ�ͼ������ע�ᣬ���Ǵ�����д�� }
        /// ����ע���������͵�ԭ���ǣ���һ֧������ChartTemplateΪ�գ�������������ͻ�ͼ�������ͷ���
        ///  ע�����ͣ��Ϳ����ô˹��ܡ�
        IGD.RegistDrawFuncs('���λ�Ƽ�', DrawTrendLine);
        IGD.RegistDrawFuncs('ê��������', DrawTrendLine);
        IGD.RegistDrawFuncs('ê��Ӧ����', DrawTrendLine);
        IGD.RegistDrawFuncs('Ӧ���', DrawTrendLine);
        IGD.RegistDrawFuncs('��Ӧ����', DrawTrendLine);
        IGD.RegistDrawFuncs('���ұ��μ�', DrawTrendLine);
        IGD.RegistDrawFuncs('��ѹ��', DrawTrendLine);
        IGD.RegistDrawFuncs('��ѹ��', DrawTrendLine);
        IGD.RegistDrawFuncs('ˮλ��', DrawTrendLine);
        IGD.RegistDrawFuncs('����', DrawTrendLine);
        IGD.RegistDrawFuncs('�ѷ��', DrawTrendLine);
        IGD.RegistDrawFuncs('λ���', DrawTrendLine);
        IGD.RegistDrawFuncs('�ֽ��', DrawTrendLine);
        IGD.RegistDrawFuncs('�ְ��', DrawTrendLine);
        IGD.RegistDrawFuncs('�¶ȼ�', DrawTrendLine);
        IGD.RegistDrawFuncs('ˮλ', DrawTrendLine);
        IGD.RegistDrawFuncs('��ˮ��', DrawTrendLine);
        IGD.RegistDrawFuncs('ˮλ�۲��', DrawTrendLine);
        IGD.RegistDrawFuncs('������', DrawTrendLine);
        IGD.RegistDrawFuncs('����ˮ׼', DrawTrendLine);
        IGD.RegistDrawFuncs('������', DrawTrendLine);
        IGD.RegistDrawFuncs('˫������', DrawTrendLine);

        IGD.RegistExportFunc('���λ�Ƽ�', ExportGraphToFile);
        IGD.RegistExportFunc('ê��������', ExportGraphToFile);
        IGD.RegistExportFunc('ê��Ӧ����', ExportGraphToFile);
        IGD.RegistExportFunc('Ӧ���', ExportGraphToFile);
        IGD.RegistExportFunc('��Ӧ����', ExportGraphToFile);
        IGD.RegistExportFunc('���ұ��μ�', ExportGraphToFile);
        IGD.RegistExportFunc('��ѹ��', ExportGraphToFile);
        IGD.RegistExportFunc('��ѹ��', ExportGraphToFile);
        IGD.RegistExportFunc('ˮλ��', ExportGraphToFile);
        IGD.RegistExportFunc('����', ExportGraphToFile);
        IGD.RegistExportFunc('�ѷ��', ExportGraphToFile);
        IGD.RegistExportFunc('λ���', ExportGraphToFile);
        IGD.RegistExportFunc('�ֽ��', ExportGraphToFile);
        IGD.RegistExportFunc('�ְ��', ExportGraphToFile);
        IGD.RegistExportFunc('�¶ȼ�', ExportGraphToFile);
        IGD.RegistExportFunc('ˮλ', ExportGraphToFile);
        IGD.RegistExportFunc('��ˮ��', ExportGraphToFile);
        IGD.RegistExportFunc('ˮλ�۲��', ExportGraphToFile);
        IGD.RegistExportFunc('������', ExportGraphToFile);
        IGD.RegistExportFunc('����ˮ׼', ExportGraphToFile);
        IGD.RegistExportFunc('������', ExportGraphToFile);
        IGD.RegistExportFunc('˫������', ExportGraphToFile);

        IGD.RegistSaveStreamFunc('���λ�Ƽ�', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('ê��������', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('ê��Ӧ����', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('���ұ��μ�', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('��ѹ��', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('��ѹ��', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('ˮλ��', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('����', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('�ѷ��', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('λ���', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('�ֽ��', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('�ְ��', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('�¶ȼ�', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('Ӧ���', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('��Ӧ����', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('ˮλ', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('��ˮ��', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('ˮλ�۲��', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('������', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('����ˮ׼', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('������', ExportGraphToStream);
        IGD.RegistSaveStreamFunc('˫������', ExportGraphToStream);

        IGD.RegistDrawGroupGraphFunc(ggtTrendLine, DrawGroupLine);
      end;

  // uFuncDataGraph.RegistDrawFuncs('���λ�Ƽ�', DrawTrendLine);
  // uFuncDataGraph.RegistDrawFuncs('ê��������', DrawTrendLine);
  // uFuncDataGraph.RegistDrawFuncs('ê��Ӧ����', DrawTrendLine);
  // uFuncDataGraph.RegistExportChartToFileFuncs('���λ�Ƽ�', ExportGraphToFile);
  // uFuncDataGraph.RegistExportChartToFileFuncs('ê��������', ExportGraphToFile);
  // uFuncDataGraph.RegistExportChartToFileFuncs('ê��Ӧ����', ExportGraphToFile);
  // uFuncDataGraph.RegistSaveChartToStreamFuncs('���λ�Ƽ�', ExportGraphToStream);
  // uFuncDataGraph.RegistSaveChartToStreamFuncs('ê��������', ExportGraphToStream);
  // uFuncDataGraph.RegistSaveChartToStreamFuncs('ê��Ӧ����', ExportGraphToStream);
end;

initialization

RegistSelf;

finalization

if Assigned(fraTLTool) then
  FreeAndNil(fraTLTool);
if Assigned(JpgFmt) then
  JpgFmt.Free;

end.
