{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Template.ChartTemplateProc
 Author:    ��ΰ
 Date:      2018-09-03
 Purpose:   ����Ԫ�޸���uFuncDrawTLByStyle.pas
 ԭ��Ԫ���������Ԥ���壨TTrendlinePredefine�������ڸ�ΪTChartTemplate��
 �޸ĺ��ģ�壬��AppServices.Templates���Ϲ���ÿ��������DataSheetStru�ṹ
 ����ChartTemplate����ʹ��ʱ��Templates�������ҵ���Ӧ��ģ������ñ���Ԫ��
 ��������Chart��

 History: 2018-09-03    Ŀǰ��ֲ��ϣ�������Ӧ�µ�TChartTemplate���ˡ�����
                        ����֧��ʸ��ͼ��λ��ͼ��
----------------------------------------------------------------------------- }
{ todo:���Ӷ�ʸ��ͼ��λ��ͼ�Ĵ��� }
{ todo:�����SubAxis�Ĵ����������⣬1-�ƺ��޷���ȷ��ʾ���ں��·ݣ�2-�����ʾ���м��Ǹ�SubAxis��
3-��ݵ�Labelһֱ���ظ������Ӧ��ֻ�ظ�һ�ξ͹��ˣ���Ӧ��ÿ��tick����ʾ2018��2018��2018������ }
unit uHJX.Template.ChartTemplateProc;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Types, Vcl.Graphics,
  VCLTee.Chart, VCLTee.Series, VCLTee.TeEngine, VCLTee.TeeProcs,
  Data.DB, Datasnap.DBClient,
  uHJX.Intf.AppServices, uHJX.Intf.Datas, uHJX.Classes.Meters, {uTLDefineProc}
  uHJX.Classes.Templates, uHJX.Template.ChartTemplate, uHJX.ProjectGlobal,
  uMyTeeAxisScrollTool;

type
  { ��չһ��LineSeries�����ƹ�����ʱ���������������Ϣ }
  TMeterLine = class(TLineSeries)
  private
    FMeter    : TMeterDefine;
    FDataIndex: Integer; // ��PDIndex, ��ʼ��Ϊ1���ڷ���MeterDefine�е�DataSheetStructure.PDsʱ��ע��Ҫ��1
  public
    property Meter    : TMeterDefine read FMeter write FMeter;
    property DataIndex: Integer read FDataIndex write FDataIndex;
  end;

{ ���������ƹ����� }
procedure DrawMeterSeries(AChart: TChart; ChtTmpl: TChartTemplate; ADsnName: string;
  DTStart, DTEnd: TDateTime); overload;

procedure DrawMeterSeries(AChart: TChart; ADsnName: string; DTStart, DTEnd: TDateTime); overload;

/// <summary>
/// ����һ����������������ߣ�ÿ֧���������û��ڸ��ԵĹ����߶���ģ�壬ֻ���Ƶ�һ����������
/// ��ͬ��Ԥ����������飬���������Ҫ������ʱѡ����һ������������ͬ���ͣ�Ҳ���ܲ�ͬ���ͣ������ǵ�
/// �����߻��Ƶ�ͬһ��Chart�С����ĳ������û��ָ����ģ�壬���������޷����ƣ�ԭ�����޷���֪������
/// ���������������������������ˮƽλ�Ʋ��ȣ���ר���ض����ã����Ժ�ÿ������֧�ֶ����ͬ����ģ��
/// �����޸�Ϊ��ȫģ��ģʽ
/// </summary>
procedure DrawGroupLines(AChart: TChart; AMeters: TStrings);

implementation

{ ����ʮ����Ԥ�������ɫ }
const
  // ���������ߵ���ɫ
  SSColors: array [0 .. 11] of TColor = (clWebDarkBlue, clwebdarkgreen, clWebDarkViolet,
    clWebMidnightBlue,
    clWebDarkOliveGreen, clWebIndigo, clWebDarkMagenta, clWebPurple, clWebDeepPink,
    clWebDodgerBlue, clWebTeal, clWebSienna);

  // ������������ɫ�����óɱȽ����޵���ɫ����10����ɫ��
  AxisColors: array [0 .. 9] of TColor = (clBlue, clGreen, clMaroon, clPurple, clTeal, clRed,
    clWebForestGreen, clWebSaddleBrown, clWebCornFlowerBlue, clWebDarkOrchid);

procedure ResetChart(AChart: TChart);
var
  i: Integer;
begin
  AChart.FreeAllSeries;
  for i := AChart.LeftAxis.SubAxes.Count - 1 downto 0 do AChart.LeftAxis.SubAxes[i].Free;
  AChart.LeftAxis.SubAxes.Clear;

  for i := AChart.RightAxis.SubAxes.Count - 1 downto 0 do AChart.RightAxis.SubAxes[i].Free;
  AChart.RightAxis.SubAxes.Clear;

  for i := AChart.CustomAxes.Count - 1 downto 0 do AChart.CustomAxes[i].Free;
  AChart.CustomAxes.Clear;
end;

procedure SetupChart(AChart: TChart; ChtTmpl: TChartTemplate);
var
  i         : Integer;
  ax        : TchtAxis;
  chtAx     : TChartAxis;
  myAxisTool: ThwTeeAxisScrollTool;
begin
  ResetChart(AChart);

  AChart.MarginUnits := muPixels;

    { ������Ҫ����һ��ChartTitle�а�����ռλ�� }
  AChart.Title.Caption := ChtTmpl.ChartTitle;

    // ���ú���
  for ax in ChtTmpl.HoriAxises.Values do
  begin
    if ax.BottomSide then chtAx := AChart.BottomAxis
    else chtAx := AChart.TopAxis;

    myAxisTool := ThwTeeAxisScrollTool.Create(AChart.Parent);
    myAxisTool.Axis := chtAx;
    myAxisTool.Active := True;

    chtAx.Visible := True;
    if ChtTmpl.ChartType = cttTrendLine then chtAx.DateTimeFormat := ax.Format
    else chtAx.AxisValuesFormat := ax.Format;

    chtAx.Automatic := True;
    if ax.BottomSide then
    begin
      chtAx.SubAxes[0].Visible := False;
      chtAx.SubAxes[1].Visible := False;
      if ax.SubAxis1.Visible then
      begin
        chtAx.SubAxes[0].Visible := True;
        chtAx.SubAxes[0].DateTimeFormat := ax.Format;
      end;
      if ax.SubAxis2.Visible then
      begin
        chtAx.SubAxes[1].Visible := True;
        chtAx.SubAxes[1].DateTimeFormat := ax.SubAxis2.Format;
      end;
            // ���ú���title: sub[0]�������棬�м���sub��1������������bottomaxis
      if chtAx.SubAxes[0].Visible then
      begin
        chtAx.SubAxes[0].Title.Caption := ax.Title;
        chtAx.SubAxes[1].Title.Caption := '';
        chtAx.Title.Caption := '';
      end
      else if chtAx.SubAxes[1].Visible then
      begin
        chtAx.Title.Caption := '';
        chtAx.SubAxes[1].Title.Caption := ax.Title;
      end
      else chtAx.Title.Caption := ax.Title;
    end
    else chtAx.Title.Caption := ax.Title;
  end;

    // ��������
  for ax in ChtTmpl.VertAxises.Values do
  begin
    ax.ChartAxis := nil;
        // CustomAxis��Ҫ����
    if ax.AxisType = axCustom then
    begin
      chtAx := AChart.CustomAxes.Add;
      chtAx.Automatic := True;
      chtAx.Horizontal := False;
      chtAx.OtherSide := not ax.LeftSide;
      chtAx.AxisValuesFormat := ax.Format;
      chtAx.Title.Caption := ax.Title;
      chtAx.Grid.Visible := False; // Custom��Ͳ���ʾGrid�ˣ�����̫��
      ax.ChartAxis := chtAx;

      myAxisTool := ThwTeeAxisScrollTool.Create(AChart.Parent);
      myAxisTool.Axis := chtAx;
      myAxisTool.Active := True;
    end
    else // �����ľ��������������
    begin
      if ax.LeftSide then chtAx := AChart.LeftAxis
      else chtAx := AChart.RightAxis;
      chtAx.Title.Caption := ax.Title;
      chtAx.AxisValuesFormat := ax.Format;
      chtAx.Automatic := True;
      ax.ChartAxis := chtAx;

      myAxisTool := ThwTeeAxisScrollTool.Create(AChart.Parent);
      myAxisTool.Axis := chtAx;
      myAxisTool.Active := True;
    end;
  end;

  for i := 0 to AChart.Axes.Count - 1 do AChart.Axes.Items[i].PositionUnits := muPixels;
end;

procedure ReplaceAxes(AChart: TChart);
/// ÿ��Axis����һ��Shape�����Shape����+��ǩ�ķ�Χ����������Title������ͨ��Shape��ȷ����Ŀ�ȣ�
/// ���ǣ����Shape������Visible���У����Կ�������Axis��Shape.Visible := True; Shape.Transparent := True
/// ���������Shape�����Ρ�
/// Ϊ��ȷ��Title�Ĵ�С��������Title��Width��Height��ȷ�����������ᣬ�������ת90�㣬��Ӧ����Height
/// ��ȷ���߶ȡ�
const
  extraPos = 30; // �������֮��ļ��
const
  extraMargin = 80; // ÿ������ռ�ݵĿ�ȣ�ÿ����һ�����ᣬChartLeft��ChartRight��С���ֵ��
var
  CAList               : TList;
  i                    : Integer;
  CA                   : TChartAxis;
  NextXLeft, NextXRight: Integer;
  MargLeft, MargRight  : Integer;
  preUnit              : TTeeUnits;
  L1st, R1st           : Boolean; // �Ƿ��ǵ�һ�����ᡢ��һ�����ᣬ����ȷ��Margin�Ƿ�����10��pixels
begin
  NextXLeft := 0;
  NextXRight := 0;
  MargLeft := 20;
  MargRight := 20;
    { todo:Ϊ����������������������һ��Chart�͸����������PositionUnit }
  preUnit := AChart.MarginUnits;
  AChart.MarginUnits := muPixels;
  AChart.LeftAxis.PositionUnits := muPixels;
  AChart.RightAxis.PositionUnits := muPixels;
  AChart.LeftAxis.Shape.Transparent := True;
  AChart.LeftAxis.Shape.Visible := True;
  AChart.RightAxis.Shape.Transparent := True;
  AChart.RightAxis.Shape.Visible := True;
  for i := 0 to AChart.CustomAxes.Count - 1 do
    if not AChart.CustomAxes[i].Horizontal then
    begin
      AChart.CustomAxes[i].PositionUnits := muPixels;
      AChart.CustomAxes[i].Shape.Transparent := True;
      AChart.CustomAxes[i].Shape.Visible := True;
    end;

  CAList := TList.Create;
  try
    for i := 0 to AChart.SeriesList.Count - 1 do
      if AChart[i].Active then
        case AChart[i].VertAxis of
          aLeftAxis:
            begin
              if CAList.IndexOf(AChart.LeftAxis) = -1 then
                if AChart.LeftAxis.Visible then
                begin
                  CAList.Add(AChart.LeftAxis);
                            // �����ѭ���У���������LeftAxis��Margin�������������޳������治���ж�
                // MargLeft := MargLeft - extraMargin;
                  MargLeft := MargLeft - AChart.LeftAxis.Shape.Width - AChart.LeftAxis.Title.Height;
                end;
            end;
          aRightAxis:
            begin
              if CAList.IndexOf(AChart.RightAxis) = -1 then
                if AChart.RightAxis.Visible then
                begin
                  CAList.Add(AChart.RightAxis);
                  // MargRight := MargRight - extraMargin;
                  // �Ҳ��Axis����Shape��width��Ȼ�Ǹ�ֵ��������ҪAbsһ��
                  MargRight := MargRight - Abs(AChart.RightAxis.Shape.Width) -
                    AChart.RightAxis.Title.Height;
                end;
            end;
          aCustomVertAxis:
            begin
              if AChart[i].CustomVertAxis <> nil then
                if CAList.IndexOf(AChart[i].CustomVertAxis) = -1 then
                    CAList.Add(AChart[i].CustomVertAxis);
            end;
        end;

    L1st := False;
    R1st := False;
    for i := 0 to CAList.Count - 1 do
    begin
      CA := TChartAxis(CAList[i]);
      if CA.OtherSide then
      begin
        CA.PositionPercent := NextXRight;
        // NextXRight := NextXRight - CA.MaxLabelsWidth - CA.TickLength - extraPos;
        // MargRight := MargRight + extraMargin;
        NextXRight := NextXRight - Abs(CA.Shape.Width) - CA.Title.Height;
        if (CA.Shape.Width <> 0) or (CA.Title.Height <> 0) then NextXRight := NextXRight - 10;
        if R1st then { ע�⣬�Ҳ����Shape.Width��Ȼ�Ǹ��ģ��� }
            MargRight := MargRight + Abs(CA.Shape.Width) + CA.Title.Height + 10
        else
        begin
          if CA.Shape.Width < 0 then
              MargRight := MargRight + Abs(CA.Shape.Width) + CA.Title.Height
          else
              MargRight := MargRight + CA.Title.Height;
          // ����ǵ�һ���ᣬ���üӣ������ڽ���һ���������¶�Margin��10������
          R1st := True;
        end;
      end
      else
      begin
        CA.PositionPercent := NextXLeft;
        NextXLeft := NextXLeft - CA.Shape.Width - CA.Title.Height - 10;
        // NextXLeft := NextXLeft - CA.MaxLabelsWidth - CA.TickLength - extraPos;
        if not L1st then
        begin
          MargLeft := MargLeft + CA.Shape.Width + CA.Title.Height;
          L1st := True;
        end
        else
            MargLeft := MargLeft + CA.Shape.Width + CA.Title.Height + 10;
      end;
    end;

    AChart.MarginLeft := MargLeft;
    AChart.MarginRight := MargRight;
  finally
    CAList.Free;
  end;
end;

procedure DrawMeterSeries(AChart: TChart; ChtTmpl: TChartTemplate; ADsnName: string;
  DTStart, DTEnd: TDateTime);
var
  mt     : TMeterDefine;
  NewLine: TLineSeries;
  DS     : TClientDataSet;
  S      : string;
  iMT    : Integer;
  Grp    : TMeterGroupItem;
    { �����µ�LineSeries�������ݶ����������ʽ������ }
  procedure AddNewLine(ATLSeries: TchtSeries);
  begin
    // 2022-10-25
    // NewLine := TLineSeries.Create(AChart);
    NewLine := TMeterLine.Create(AChart);
    TMeterLine(NewLine).Meter := mt; // ����Ե�֧������ȷ���������鲻��ȷ

    NewLine.Title := ATLSeries.Title;
    // ���ú���
    NewLine.HorizAxis := aBottomAxis;
    NewLine.XValues.DateTime := True;
    NewLine.Color := AChart.GetFreeSeriesColor;
    // ֻ��ʹ��Segments���Ͳ�����ȷ�ж�Null�㴦������
    NewLine.DrawStyle := { dsCurve } dsSegments;
    // ��������
    if ATLSeries.VertAxis.AxisType = axLeft then NewLine.VertAxis := aLeftAxis
    else if ATLSeries.VertAxis.AxisType = axRight then NewLine.VertAxis := aRightAxis
    else
    begin
      NewLine.VertAxis := aCustomVertAxis;
      NewLine.CustomVertAxis := ATLSeries.VertAxis.ChartAxis as TChartAxis;
    end;

    // 2019-10-11
    if ATLSeries.PointerType = sptNone then
        NewLine.Pointer.Visible := False
    else
    begin
      // ������ʱ������Auto�������Ȩ������Always����
      { TODO -oCharmer -cChartTemplateProc : ��д����sptAuto���͵Ĵ��� }
      NewLine.Pointer.Visible := True;
      { 2022-02-22 ����Pointer����ʽ������䣬�߿���ɫ��������ɫһ�£������� }
      with NewLine.Pointer do
      begin
        Brush.Style := bsClear;
        DarkPen := 80;
      end;
    end;

    // 2019-10-11 ��������
    case ATLSeries.LineStyle of
      slsSolid: NewLine.Pen.Style := psSolid;
      slsDash: NewLine.Pen.Style := psDash;
      slsDot: NewLine.Pen.Style := psDot;
      slsDashDot: NewLine.Pen.Style := psDashDot;
      slsDashDotDot: NewLine.Pen.Style := psDashDotDot;
    end;

  end;
    { ������DsnName�����ݸ��ݶ�����ӹ����ߡ�IndexΪ���������е���ţ�����1����֧Ϊ1 }
  procedure SetMeterLines(DsnName: string; Index: Integer = 1);
  var
    tls    : TchtSeries;
    Fld    : TField;
    GetData: Boolean;
    i      : Integer;
  begin
    if (DTStart = 0) and (DTEnd = 0) then
    begin
      if (TrendLineSetting.DTStart = 0) and (TrendLineSetting.DTEnd = 0) then
          GetData := IAppServices.ClientDatas.GetAllPDDatas(DsnName, DS)
      else
          GetData := IAppServices.ClientDatas.GetPDDatasInPeriod(DsnName, TrendLineSetting.DTStart,
          TrendLineSetting.DTEnd, DS)
    end
    else GetData := IAppServices.ClientDatas.GetPDDatasInPeriod(DsnName, DTStart, DTEnd, DS);

    if GetData then
      if DS.RecordCount > 0 then
        for tls in ChtTmpl.Series do
        begin
          if tls.SourceType = pdsEnv then Continue;
          // �����ָ����Ʊ�ţ��������ڵ�ǰ������ţ�����һ����������ʱ�����Ǵ�Ԥ������
          // ����ָ����ŵļ������
          if tls.SourceName <> '*' then
            if tls.SourceName <> ADsnName then Continue;
          // ���MeterIndex�Ȳ�������������������0��Ҳ���Ǳ����������Index�����ܻ�ͼ
          if tls.MeterIndex <> 0 then
            if tls.MeterIndex <> index then Continue;

          // ���ڿ���PDIndex���⡣
          S := 'PD' + IntToStr(tls.PDIndex);
          for Fld in DS.Fields do
            if Fld.FieldName = S then
            begin
              // �����߶���
              AddNewLine(tls);
              // 2022-10-25
              // ��AddNewLine���������õ�Meter�ǹ���ȫ�ֵģ��Ὣ������������������Ϊ��ͬ��Meter
              // �������������¸���һ��
              (NewLine as TMeterLine).Meter := Excelmeters.Meter[DsnName];
              (NewLine as TMeterLine).DataIndex := tls.PDIndex;

              // ����Series.Title
              if Pos('%name%', NewLine.Title) > 0 then
                  NewLine.Title := NewLine.Title.Replace('%name%',
                  Fld.DisplayLabel)
              else if Pos('%MeterName%', NewLine.Title) > 0 then
                  NewLine.Title := NewLine.Title.Replace('%MeterName%', DsnName);
              // ������д����
              DS.First;
              repeat
                // newline.add
                { if not Fld.IsNull then
                    NewLine.AddXY(DS.Fields[0].AsDateTime, Fld.AsFloat);
 }
                if not Fld.IsNull then
                    NewLine.AddXY(DS.Fields[0].AsDateTime, Fld.Value)
                else // 2022-05-11 ������ʾNull
                begin
                  { i := NewLine.AddXY(DS.Fields[0].AsDateTime, -1);
                  NewLine.SetNull(i); }
                  // ���ָ���˲�����Null�㣬��������������ϣ�����ֶϵ㣬�����Ӧ������
                  if tls.DontPaintNull then
                      NewLine.AddNullXY(DS.Fields[0].AsDateTime, -10)
                end;
                DS.next;
              until DS.Eof;

              if tls.DontPaintNull then
                  NewLine.TreatNulls := tnDontPaint
              else NewLine.TreatNulls := tnSkip;

              AChart.AddSeries(NewLine);
              NewLine.Visible := tls.Visible;
              // AChart.Series[AChart.SeriesCount - 1].Active := tls.Visible;

              NewLine.Pointer.Style := TSeriesPointerStyle(AChart.SeriesCount - 1);
              if AChart.SeriesCount = 1 then NewLine.Pointer.Size := 2
              else NewLine.Pointer.Size := 3;

              Break;
            end;

        end;
  end;

begin
  SetupChart(AChart, ChtTmpl);

  mt := Excelmeters.Meter[ADsnName];
  if mt = nil then
  begin
    Exit;
  end;

    // ���ڵ�֧������ֻҪ��������Meter���Ϳ�������
    // �ȴ���ChartTitle
  if Pos('%Name%', AChart.Title.Caption) > 0 then
      AChart.Title.Caption := StringReplace(AChart.Title.Caption, '%Name%', ADsnName,
      [rfReplaceAll])
  else if Pos('%GroupName%', AChart.Title.Caption) > 0 then
    if mt.PrjParams.GroupID <> '' then
        AChart.Title.Caption := StringReplace(AChart.Title.Caption, '%GroupName%',
        mt.PrjParams.GroupID, [rfReplaceAll]);
    // ��ȡ�������ݵ�DataSet�У�Ȼ���ٸ���Ԥ������д���
  DS := TClientDataSet.Create(nil);
  try
        // �ж��Ƿ������飬���ǣ����жϸ�����Ԥ�����Ƿ�֧�������顣��ê��Ӧ�����������ã������������������
        // �ģ�������鴦������������Ե�֧�����ģ����������������
    if mt.PrjParams.GroupID = '' then SetMeterLines(ADsnName, 1)
    else if ChtTmpl.ApplyGroup then
    begin
      Grp := MeterGroup.ItemByName[mt.PrjParams.GroupID];
      if Grp = nil then SetMeterLines(ADsnName, 1)
      else
        for iMT := 0 to Grp.Count - 1 do SetMeterLines(Grp.Items[iMT], iMT + 1);
    end
    else SetMeterLines(ADsnName, 1);
  finally
    DS.Free;
  end;

  AChart.Draw;
  ReplaceAxes(AChart);
end;

procedure DrawMeterSeries(AChart: TChart; ADsnName: string; DTStart, DTEnd: TDateTime);
var
  Meter: TMeterDefine;
  TS   : TTemplates;
  CT   : TChartTemplate;
begin
  Meter := (IAppServices.Meters as tmeterdefines).Meter[ADsnName];
  if Meter = nil then Exit;
  TS := IAppServices.Templates as TTemplates;
  CT := TS.ItemByName[Meter.DataSheetStru.ChartTemplate] as TChartTemplate;
  if CT <> nil then DrawMeterSeries(AChart, CT, ADsnName, DTStart, DTEnd);
end;

{ -----------------------------------------------------------------------------
  Procedure  : DrawGroupLines
  Description: ����һ����������Ĺ����ߣ���������ufraTrendLineShell����
  ��������������DrawMeterSeries�ĸ�д��
  ����Ĳ�����������DesignName��Ҳ������DesignName|PDName
----------------------------------------------------------------------------- }
procedure DrawGroupLines(AChart: TChart; AMeters: TStrings);
var
  mt      : TMeterDefine;
  sMt, sPD: string; // Ϊ��Ӧ�Ա���������̫�٣������˱�ͨ����������������������������һ�𴫵�
  PDIndex : Integer;

  DS     : TClientDataSet;
  iMT    : Integer;
  NewLine: TLineSeries;

  // ���ַ����ֽ�Ϊ��Ʊ�š����������������ҵ���������PDIndex
  function _SplitMeterName(AStr: string): String;
  var
    ii: Integer;
  begin
    sMt := '';
    sPD := '';
    PDIndex := 0;
    if AStr = '' then Exit;
    ii := Pos('|', AStr);
    if ii = 0 then
    begin
      sMt := AStr;
      result := AStr;
      sPD := '';
      PDIndex := 1; // ���û��ָ������������Ĭ���ǵ�һ��
    end
    else
    begin
      sMt := copy(AStr, 1, ii - 1);
      sPD := copy(AStr, ii + 1, Length(AStr));
    end;
    mt := Excelmeters.Meter[sMt];
    if ii > 0 then
      for ii := 0 to mt.PDDefines.Count - 1 do
        if mt.PDDefine[ii].Name = sPD then
        begin
          PDIndex := ii + 1;
          Break;
        end;
  end;

  procedure AddNewLine(ATLSeries: TchtSeries);
  var
    ii          : Integer;
    b           : Boolean;
    CA          : TChartAxis;
    j           : Integer;
    FindAxisType: TVertAxis;
    FindAxis    : TChartAxis;
    ssTitle     : String;
    myAxisTool  : ThwTeeAxisScrollTool;
  begin
    NewLine := TMeterLine.Create(AChart);
    TMeterLine(NewLine).Meter := mt;
    TMeterLine(NewLine).DataIndex := 1;
    if ATLSeries <> nil then
        NewLine.Title := mt.DesignName + '��' + ATLSeries.Title
    else
        NewLine.Title := mt.DesignName + '��' + mt.PDName(PDIndex - 1);
    // ���ú���
    NewLine.HorizAxis := aBottomAxis;
    NewLine.XValues.DateTime := True;
    if AChart.SeriesCount < 12 then
        NewLine.Color := SSColors[AChart.SeriesCount]
    else
        NewLine.Color := AChart.GetFreeSeriesColor;
    NewLine.DrawStyle := dsSegments;

    // ��������Ƿ���ڿ���������
    if ATLSeries <> nil then ssTitle := ATLSeries.VertAxis.Title
    else ssTitle := mt.PDName(PDIndex - 1);
    CA := nil;
    // �������û���ã�������������
    if AChart.LeftAxis.Title.Text = '����' then
    begin
      b := True;
      AChart.LeftAxis.Title.Text := ssTitle;
      FindAxisType := aLeftAxis;
      CA := AChart.LeftAxis;
    end
    else if AChart.LeftAxis.Title.Text = ssTitle then
    begin
      b := True;
      FindAxisType := aLeftAxis;
      CA := AChart.LeftAxis;
    end
    else if AChart.RightAxis.Title.Text = ssTitle then
    begin
      b := True;
      FindAxisType := aRightAxis;
      CA := AChart.RightAxis;
    end
    else
    begin
      for ii := 0 to AChart.CustomAxes.Count - 1 do
      begin
        CA := AChart.CustomAxes.Items[ii];
        if CA.Horizontal = False then
          if CA.Title.Text = ssTitle then
          begin
            b := True;
            FindAxisType := aCustomVertAxis;
            Break;
          end;
      end;
      if not b then CA := nil;
    end;

// if ATLSeries <> nil then
// begin
// for ii := 0 to AChart.Axes.Count - 1 do
// if AChart.Axes.Items[ii].Title.Text = ATLSeries.VertAxis.Title then
// begin
// b := True;
// CA := AChart.Axes.Items[ii];
// Break;
// end
// end
// else // �������û�ж���ġ���
// begin
// // ���ȼ�������Ƿ�û����
// if AChart.LeftAxis.Title.Text = '����' then
// begin
// b := True;
// CA := AChart.LeftAxis;
// // û���õ�����ı���������������
// AChart.LeftAxis.Title.Text := mt.PDName(PDIndex - 1);
// end
// else // �������Ƿ���CustomAxis
// for ii := 0 to AChart.Axes.Count - 1 do
// if AChart.Axes.Items[ii].Title.Text = mt.PDName(PDIndex - 1) then
// begin
// b := True;
// CA := AChart.Axes.Items[ii];
// Break;
// end
// end;

    if not b then // ���û���ҵ����򴴽�һ��CustomAxis
    begin
      CA := AChart.CustomAxes.Add;
      myAxisTool := ThwTeeAxisScrollTool.Create(AChart.Parent);
      myAxisTool.Axis := CA;
      myAxisTool.Active := True;
      // AChart.Tools.Add(myAxisTool);
      if ATLSeries <> nil then
          CA.Title.Text := ATLSeries.VertAxis.Title
      else
          CA.Title.Text := mt.PDName(PDIndex - 1);
      CA.Horizontal := False;
      CA.PositionUnits := muPixels;
      CA.Grid.Visible := False;
      // ����CustomAxis��ɫ
      j := 0;
      for ii := 0 to AChart.Axes.Count - 1 do
      begin
        if AChart.Axes[ii].Horizontal then Continue;
        AChart.Axes[ii].Axis.Color := AxisColors[j];
        AChart.Axes[ii].LabelsFont.Color := AxisColors[j];
        AChart.Axes[ii].Ticks.Color := AxisColors[j];
        AChart.Axes[ii].Title.Font.Color := AxisColors[j];
        Inc(j);
      end;
      NewLine.VertAxis := aCustomVertAxis;
      NewLine.CustomVertAxis := CA;
      NewLine.Color := CA.Axis.Color;
    end
    else // ����ҵ��ˣ����ж��Ƿ��������ᣬ����CustomAxis��Ȼ������
    begin
      NewLine.VertAxis := FindAxisType;
      if FindAxisType = aCustomVertAxis then
          NewLine.CustomVertAxis := CA;
// if AChart.LeftAxis.Title.Text = ATLSeries.VertAxis.Title then
// NewLine.VertAxis := aLeftAxis
// else if AChart.RightAxis.Title.Text = ATLSeries.VertAxis.Title then
// NewLine.VertAxis := aRightAxis
// else
// begin
// NewLine.VertAxis := aCustomVertAxis;
// for ii := 0 to AChart.CustomAxes.Count - 1 do
// begin
// if AChart.CustomAxes[ii].Title.Text = ATLSeries.VertAxis.Title then
// begin
// NewLine.CustomVertAxis := AChart.CustomAxes[ii];
// NewLine.Color := NewLine.CustomVertAxis.Axis.Color;
// end;
// end;
// end;
    end;
  end;

  procedure AddMeterLine(DsnName: String; AIndex: Integer);
  var
    Fld    : TField;
    GetData: Boolean;
    Tmpl   : TChartTemplate; // ������ģ�嶨��
    tls    : TchtSeries;     // ģ�嶨���е���������
    S      : String;
    ii     : Integer;
  begin
    Tmpl := mt.ChartPreDef as TChartTemplate;
    with TrendLineSetting do
    begin
      if (DTStart = 0) and (DTEnd = 0) then
          GetData := IAppServices.ClientDatas.GetAllPDDatas(DsnName, DS)
      else
          GetData := IAppServices.ClientDatas.GetPDDatasInPeriod(DsnName, DTStart, DTEnd, DS);
    end;
    // tmpl.VertAxises.
    if GetData then
      if DS.RecordCount > 0 then
      begin
        // ����������⣬����tls=nil
        { todo:���� tls = nil������ }
        tls := nil;
        for ii := 0 to Tmpl.Series.Count - 1 do
          if Tmpl.Series.Items[ii].PDIndex = AIndex then
          begin
            tls := Tmpl.Series.Items[ii];
            Break;
          end;

        /// ������Ҫ�����������ĳ��������û������ԵĹ�����Ԥ���������
        if tls <> nil then
        begin
          // ����ǻ�����������
          if tls.SourceType = pdsEnv then Exit;
          // �����ָ���������ͣ��Ҳ��Ǳ��������������������Զ���Ϊ�������
          if tls.SourceName <> '*' then
            if tls.SourceName <> DsnName then Exit;
        end;
          // �����������ģ�������ͼģ�壬����Ҫ֪���Լ��Ǹ����еڼ�ֻ����Ϊ֧���鶨���ģ����
          // ��ָ���ڼ�ֻ�����Ǹ�����������ʲô�����ᡣ����Ϊ���٣��ٶ��Լ����ǵ�һ��������ѡ��
          // ��һ������������һ���ƻ���ָ�������������ֻ�index��ʽ��ѡ����
          // ���MeterIndex�Ȳ�������������������0��Ҳ���Ǳ����������Index�����ܻ�ͼ
          { if tls.MeterIndex <> 0 then
            if tls.MeterIndex <> index then Continue; }
        S := 'PD' + IntToStr( { tls.PDIndex } AIndex);
        for Fld in DS.Fields do
          if Fld.FieldName = S then
          begin
            AddNewLine(tls);
            // NewLine.Title�Ѿ���AddNewLine�����и�ֵ�ˣ��õ���ģ���е����ơ�����ģ���е����ƿ���
            // ����%���ţ����硰%name%���������������������ֱ����������������������
            if Pos('%', NewLine.Title) > 0 then
                NewLine.Title := DsnName + '��' + Fld.DisplayLabel;

            DS.First;
            repeat
              if not Fld.IsNull then
                  NewLine.AddXY(DS.Fields[0].AsDateTime, Fld.Value)
              else
              begin
                // ����Null���ݣ��������������ģ�壬��ģ����Ҫ����Null�ϵ㣬�����Null����
                if tls <> nil then
                  if tls.DontPaintNull then
                      NewLine.AddNullXY(DS.Fields[0].AsDateTime, -10)
              end;
              DS.next;
            until DS.Eof;
            NewLine.TreatNulls := tnSkip;
            if tls <> nil then
              if tls.DontPaintNull then
                  NewLine.TreatNulls := tnDontPaint;
            AChart.AddSeries(NewLine);
            // ��Ҫע����ǣ��ߵ���������̫�࣬��������
            { todo:����һ��Pointer���������⣬������ˡ����Կ�����������ظ�ʹ�� }
            NewLine.Pointer.Style := TSeriesPointerStyle(AChart.SeriesCount - 1);
            if AChart.SeriesCount = 1 then NewLine.Pointer.Size := 2
            else NewLine.Pointer.Size := 3;
            NewLine.Pointer.Color := NewLine.Color;
            NewLine.Pointer.Pen.Color := NewLine.Color;
            NewLine.Pointer.Brush.Color := NewLine.Color;
            NewLine.Pointer.Brush.Style := bsClear;
            NewLine.Pointer.Transparency := 25;
            NewLine.Pointer.Visible := True;
          end;
      end;
  end;

  procedure _ResetSeriesColor;
  var
    ii: Integer;
    // ss: TLineSeries;
    // ʹ���˶������ᣬ���ֻʹ�������Ҹ�һ������ɫ���죬����ͳһ�����ɫ
    cLeft, cRight, cCustom: Integer;

    CA: TChartAxis; // ��һ��Custom

    procedure __SetSeriesColor(ASeries: TLineSeries; AColor: TColor);
    begin
      ASeries.Color := AColor;
      ASeries.Pointer.Color := AColor;
      ASeries.Pointer.Pen.Color := AColor;
      ASeries.Pointer.Brush.Color := AColor;
      ASeries.Pointer.Brush.Style := bsClear;
      ASeries.Pointer.Transparency := 25;
      ASeries.Pointer.Visible := True;
    end;
    // ���ø�����ͬ����ɫ
    procedure __SetDiffColors;
    var
      iii: Integer;
    begin
      for iii := 0 to AChart.SeriesCount - 1 do
        if iii < 12 then
            __SetSeriesColor(AChart.Series[iii] as TLineSeries, SSColors[iii])
        else
            __SetSeriesColor(AChart.Series[iii] as TLineSeries, AChart.GetFreeSeriesColor(True));
    end;

    procedure __SetSeriesUseAxisColor;
    var
      iii: Integer;
      ss : TLineSeries;
    begin
      for iii := 0 to AChart.SeriesCount - 1 do
      begin
        ss := AChart.Series[iii] as TLineSeries;
        case ss.VertAxis of
          aLeftAxis:
            __SetSeriesColor(ss, AChart.LeftAxis.Axis.Color);
          aRightAxis:
            __SetSeriesColor(ss, AChart.RightAxis.Axis.Color);
          aCustomVertAxis:
            __SetSeriesColor(ss, ss.CustomVertAxis.Axis.Color);
        end;
      end;
    end;

  begin
    cLeft := 0;
    cRight := 0;
    cCustom := 0;
    CA := nil;
    for ii := 0 to AChart.SeriesCount - 1 do
      if AChart.Series[ii].Active then
      begin
        case AChart.Series[ii].VertAxis of
          aLeftAxis: Inc(cLeft);
          aRightAxis: Inc(cRight);
          aCustomVertAxis:
            begin
              if CA <> AChart.Series[ii].CustomVertAxis then
              begin
                CA := AChart.Series[ii].CustomVertAxis;
                Inc(cCustom);
              end;
            end;
        end;
      end;

    if cCustom = 0 then __SetDiffColors // û��CustomAxis��ֻ��������
    else if (cLeft = 0) and (cCustom = 1) then __SetDiffColors // û�����ᣬֻ��һ��Custom
    else __SetSeriesUseAxisColor; // ���������������ɫ




    // ���û��CustomAxis�����ڴ���NewLine��ʱ����ɫ���Ѿ������ˡ������customaxis, ��Series��ɫ����
    // ������ɫһ��

// if AChart.CustomAxes.Count = 0 then Exit;
// for ii := 0 to AChart.SeriesCount - 1 do
// begin
// ss := AChart.Series[ii] as TLineSeries;
// if ss.VertAxis = aLeftAxis then
// ss.Color := AChart.LeftAxis.Axis.Color
// else if ss.VertAxis = aRightAxis then
// ss.Color := AChart.RightAxis.Axis.Color
// else if ss.VertAxis = aCustomVertAxis then
// ss.Color := ss.CustomVertAxis.Axis.Color;
// ss.Pointer.Color := ss.Color;
// ss.Pointer.Pen.Color := ss.Color;
// ss.Pointer.Brush.Color := ss.Color;
// ss.Pointer.Brush.Style := bsClear;
// ss.Pointer.Transparency := 25;
// ss.Pointer.Visible := True;
// end;
  end;

begin
  if AChart = nil then
      Exit;
  if AMeters.Count = 0 then
      Exit;
  { ���ݵ�һ����������Chart������ɶ�� }
  _SplitMeterName(AMeters[0]);

  if mt = nil then
      Exit;
  SetupChart(AChart, (mt.ChartPreDef as TChartTemplate));
  // ���ñ���
  AChart.Title.Caption := '�����������:' + AMeters[0] + ' ~ ' + AMeters.Strings[AMeters.Count - 1];
  DS := TClientDataSet.Create(nil);
  try
    for iMT := 0 to AMeters.Count - 1 do
    begin
      if iMT > 11 then Break; // ���ܳ���12֧������������ɫ�ͳ�����Χ��

      _SplitMeterName(AMeters[iMT]);
      // mt := Excelmeters.Meter[AMeters.Strings[iMT]];
      if mt = nil then Continue;
      AddMeterLine(sMt, PDIndex);
    end
  finally
    DS.Free;
  end;

  // ������CustomAxisʱ������������ɫ
  _ResetSeriesColor;
  AChart.Legend.Alignment := laRight; // Legend���Ҳ�
  AChart.Draw;
  ReplaceAxes(AChart);
end;

end.
