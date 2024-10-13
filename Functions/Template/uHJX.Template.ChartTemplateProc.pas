{ -----------------------------------------------------------------------------
 Unit Name: uHJX.Template.ChartTemplateProc
 Author:    黄伟
 Date:      2018-09-03
 Purpose:   本单元修改自uFuncDrawTLByStyle.pas
 原单元处理过程线预定义（TTrendlinePredefine），现在改为TChartTemplate。
 修改后的模板，由AppServices.Templates集合管理。每个仪器的DataSheetStru结构
 中有ChartTemplate名，使用时从Templates集合中找到对应的模板对象，用本单元的
 方法画出Chart。

 History: 2018-09-03    目前移植完毕，可以适应新的TChartTemplate类了。但是
                        还不支持矢量图和位移图。
----------------------------------------------------------------------------- }
{ todo:增加对矢量图和位移图的处理 }
{ todo:横轴的SubAxis的处理还存在问题，1-似乎无法正确显示日期和月份；2-年份显示在中间那个SubAxis；
3-年份的Label一直在重复，这个应该只重复一次就够了，不应该每个tick都显示2018，2018，2018。。。 }
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
  { 扩展一下LineSeries，绘制过程线时保留仪器的相关信息 }
  TMeterLine = class(TLineSeries)
  private
    FMeter    : TMeterDefine;
    FDataIndex: Integer; // 是PDIndex, 起始数为1。在访问MeterDefine中的DataSheetStructure.PDs时，注意要减1
  public
    property Meter    : TMeterDefine read FMeter write FMeter;
    property DataIndex: Integer read FDataIndex write FDataIndex;
  end;

{ 本方法绘制过程线 }
procedure DrawMeterSeries(AChart: TChart; ChtTmpl: TChartTemplate; ADsnName: string;
  DTStart, DTEnd: TDateTime); overload;

procedure DrawMeterSeries(AChart: TChart; ADsnName: string; DTStart, DTEnd: TDateTime); overload;

/// <summary>
/// 绘制一组给定的仪器过程线，每支仪器的设置基于各自的过程线定义模板，只绘制第一个物理量。
/// 不同于预定义的仪器组，这个方法主要用于临时选定的一组仪器，可能同类型，也可能不同类型，将他们的
/// 过程线绘制到同一个Chart中。如果某个仪器没有指定的模板，该仪器将无法绘制，原因是无法得知该仪器
/// 的坐标轴情况。出于特例，对于水平位移测点等，会专门特定设置，待以后每个仪器支持多个不同类型模板
/// 后再修改为完全模板模式
/// </summary>
procedure DrawGroupLines(AChart: TChart; AMeters: TStrings);

implementation

{ 增加十二种预定义的颜色 }
const
  // 用于设置线的颜色
  SSColors: array [0 .. 11] of TColor = (clWebDarkBlue, clwebdarkgreen, clWebDarkViolet,
    clWebMidnightBlue,
    clWebDarkOliveGreen, clWebIndigo, clWebDarkMagenta, clWebPurple, clWebDeepPink,
    clWebDodgerBlue, clWebTeal, clWebSienna);

  // 用于设置轴颜色，设置成比较鲜艳的颜色，就10种颜色吧
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

    { 这里需要处理一下ChartTitle中包含的占位符 }
  AChart.Title.Caption := ChtTmpl.ChartTitle;

    // 设置横轴
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
            // 设置横轴title: sub[0]在最下面，中间是sub【1】，最上面是bottomaxis
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

    // 设置竖轴
  for ax in ChtTmpl.VertAxises.Values do
  begin
    ax.ChartAxis := nil;
        // CustomAxis需要创建
    if ax.AxisType = axCustom then
    begin
      chtAx := AChart.CustomAxes.Add;
      chtAx.Automatic := True;
      chtAx.Horizontal := False;
      chtAx.OtherSide := not ax.LeftSide;
      chtAx.AxisValuesFormat := ax.Format;
      chtAx.Title.Caption := ax.Title;
      chtAx.Grid.Visible := False; // Custom轴就不显示Grid了，否则太乱
      ax.ChartAxis := chtAx;

      myAxisTool := ThwTeeAxisScrollTool.Create(AChart.Parent);
      myAxisTool.Axis := chtAx;
      myAxisTool.Active := True;
    end
    else // 其他的就是左轴和右轴了
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
/// 每个Axis都有一个Shape，这个Shape是轴+标签的范围，但不包括Title，可以通过Shape来确定轴的宽度，
/// 但是，这个Shape必须是Visible才行，所以可以设置Axis的Shape.Visible := True; Shape.Transparent := True
/// 来隐藏这个Shape的外形。
/// 为了确定Title的大小，可以用Title的Width和Height来确定。对于竖轴，如果文字转90°，则应该用Height
/// 来确定高度。
const
  extraPos = 30; // 多个竖轴之间的间距
const
  extraMargin = 80; // 每个竖轴占据的宽度，每增加一个竖轴，ChartLeft或ChartRight减小这个值。
var
  CAList               : TList;
  i                    : Integer;
  CA                   : TChartAxis;
  NextXLeft, NextXRight: Integer;
  MargLeft, MargRight  : Integer;
  preUnit              : TTeeUnits;
  L1st, R1st           : Boolean; // 是否是第一个左轴、第一个右轴，用于确定Margin是否增加10个pixels
begin
  NextXLeft := 0;
  NextXRight := 0;
  MargLeft := 20;
  MargRight := 20;
    { todo:为保险起见，这里最好再设置一遍Chart和各个坐标轴的PositionUnit }
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
                            // 下面的循环中，计入了主LeftAxis的Margin，故这里先行剔除，后面不再判断
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
                  // 右侧的Axis，其Shape的width居然是负值……所以要Abs一下
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
        if R1st then { 注意，右侧轴的Shape.Width居然是负的！！ }
            MargRight := MargRight + Abs(CA.Shape.Width) + CA.Title.Height + 10
        else
        begin
          if CA.Shape.Width < 0 then
              MargRight := MargRight + Abs(CA.Shape.Width) + CA.Title.Height
          else
              MargRight := MargRight + CA.Title.Height;
          // 如果是第一个轴，不用加，避免在仅有一个轴的情况下多Margin了10个像素
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
    { 创建新的LineSeries，并根据定义设置其格式等属性 }
  procedure AddNewLine(ATLSeries: TchtSeries);
  begin
    // 2022-10-25
    // NewLine := TLineSeries.Create(AChart);
    NewLine := TMeterLine.Create(AChart);
    TMeterLine(NewLine).Meter := mt; // 本句对单支仪器正确，对仪器组不正确

    NewLine.Title := ATLSeries.Title;
    // 设置横轴
    NewLine.HorizAxis := aBottomAxis;
    NewLine.XValues.DateTime := True;
    NewLine.Color := AChart.GetFreeSeriesColor;
    // 只有使用Segments类型才能正确中断Null点处的连线
    NewLine.DrawStyle := { dsCurve } dsSegments;
    // 设置纵轴
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
      // 这里暂时不处理Auto的情况，权当都是Always类型
      { TODO -oCharmer -cChartTemplateProc : 编写处理sptAuto类型的代码 }
      NewLine.Pointer.Visible := True;
      { 2022-02-22 设置Pointer的样式，无填充，边框颜色与曲线颜色一致，但略深 }
      with NewLine.Pointer do
      begin
        Brush.Style := bsClear;
        DarkPen := 80;
      end;
    end;

    // 2019-10-11 设置线型
    case ATLSeries.LineStyle of
      slsSolid: NewLine.Pen.Style := psSolid;
      slsDash: NewLine.Pen.Style := psDash;
      slsDot: NewLine.Pen.Style := psDot;
      slsDashDot: NewLine.Pen.Style := psDashDot;
      slsDashDotDot: NewLine.Pen.Style := psDashDotDot;
    end;

  end;
    { 将仪器DsnName的数据根据定义添加过程线。Index为仪器在组中的序号，基数1，单支为1 }
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
          // 如果是指定设计编号，但不等于当前仪器编号，则下一个，这里暂时不考虑从预定义中
          // 绘制指定编号的监测仪器
          if tls.SourceName <> '*' then
            if tls.SourceName <> ADsnName then Continue;
          // 如果MeterIndex既不是适用于所有仪器的0，也不是本仪器的序号Index，则不能绘图
          if tls.MeterIndex <> 0 then
            if tls.MeterIndex <> index then Continue;

          // 现在考虑PDIndex问题。
          S := 'PD' + IntToStr(tls.PDIndex);
          for Fld in DS.Fields do
            if Fld.FieldName = S then
            begin
              // 创建线对象
              AddNewLine(tls);
              // 2022-10-25
              // 在AddNewLine方法中设置的Meter是过程全局的，会将仪器组所有仪器设置为相同的Meter
              // 所以在这里重新更正一下
              (NewLine as TMeterLine).Meter := Excelmeters.Meter[DsnName];
              (NewLine as TMeterLine).DataIndex := tls.PDIndex;

              // 处理Series.Title
              if Pos('%name%', NewLine.Title) > 0 then
                  NewLine.Title := NewLine.Title.Replace('%name%',
                  Fld.DisplayLabel)
              else if Pos('%MeterName%', NewLine.Title) > 0 then
                  NewLine.Title := NewLine.Title.Replace('%MeterName%', DsnName);
              // 下面填写数据
              DS.First;
              repeat
                // newline.add
                { if not Fld.IsNull then
                    NewLine.AddXY(DS.Fields[0].AsDateTime, Fld.AsFloat);
 }
                if not Fld.IsNull then
                    NewLine.AddXY(DS.Fields[0].AsDateTime, Fld.Value)
                else // 2022-05-11 允许显示Null
                begin
                  { i := NewLine.AddXY(DS.Fields[0].AsDateTime, -1);
                  NewLine.SetNull(i); }
                  // 如果指定了不绘制Null点，表明曲线设置中希望出现断点，否则就应该跳过
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

    // 对于单支仪器，只要定义中有Meter，就可以用了
    // 先处理ChartTitle
  if Pos('%Name%', AChart.Title.Caption) > 0 then
      AChart.Title.Caption := StringReplace(AChart.Title.Caption, '%Name%', ADsnName,
      [rfReplaceAll])
  else if Pos('%GroupName%', AChart.Title.Caption) > 0 then
    if mt.PrjParams.GroupID <> '' then
        AChart.Title.Caption := StringReplace(AChart.Title.Caption, '%GroupName%',
        mt.PrjParams.GroupID, [rfReplaceAll]);
    // 提取仪器数据到DataSet中，然后再根据预定义进行处理
  DS := TClientDataSet.Create(nil);
  try
        // 判断是否仪器组，若是，则判断给定的预定义是否支持仪器组。如锚杆应力计有组设置，若定义是针对仪器组
        // 的，则进行组处理；若定义是针对单支仪器的，则仅处理本仪器即可
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
  Description: 绘制一组给定仪器的过程线，本方法被ufraTrendLineShell调用
  本方法基本上是DrawMeterSeries的改写。
  传入的参数，可以是DesignName，也可以是DesignName|PDName
----------------------------------------------------------------------------- }
procedure DrawGroupLines(AChart: TChart; AMeters: TStrings);
var
  mt      : TMeterDefine;
  sMt, sPD: string; // 为了应对本方法参数太少，采用了变通方法，将仪器名和数据项名合在一起传递
  PDIndex : Integer;

  DS     : TClientDataSet;
  iMT    : Integer;
  NewLine: TLineSeries;

  // 将字符串分解为设计编号、物理量名，并查找到物理量的PDIndex
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
      PDIndex := 1; // 如果没有指定物理量，则默认是第一个
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
        NewLine.Title := mt.DesignName + '：' + ATLSeries.Title
    else
        NewLine.Title := mt.DesignName + '：' + mt.PDName(PDIndex - 1);
    // 设置横轴
    NewLine.HorizAxis := aBottomAxis;
    NewLine.XValues.DateTime := True;
    if AChart.SeriesCount < 12 then
        NewLine.Color := SSColors[AChart.SeriesCount]
    else
        NewLine.Color := AChart.GetFreeSeriesColor;
    NewLine.DrawStyle := dsSegments;

    // 下面查找是否存在可用坐标轴
    if ATLSeries <> nil then ssTitle := ATLSeries.VertAxis.Title
    else ssTitle := mt.PDName(PDIndex - 1);
    CA := nil;
    // 如果左轴没人用，则优先用左轴
    if AChart.LeftAxis.Title.Text = '左轴' then
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
// else // 如果遇到没有定义的……
// begin
// // 首先检查左轴是否没人用
// if AChart.LeftAxis.Title.Text = '左轴' then
// begin
// b := True;
// CA := AChart.LeftAxis;
// // 没人用的左轴的标题用物理量名称
// AChart.LeftAxis.Title.Text := mt.PDName(PDIndex - 1);
// end
// else // 否则检查是否有CustomAxis
// for ii := 0 to AChart.Axes.Count - 1 do
// if AChart.Axes.Items[ii].Title.Text = mt.PDName(PDIndex - 1) then
// begin
// b := True;
// CA := AChart.Axes.Items[ii];
// Break;
// end
// end;

    if not b then // 如果没有找到，则创建一个CustomAxis
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
      // 设置CustomAxis颜色
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
    else // 如果找到了，则判断是否是左右轴，还是CustomAxis，然后设置
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
    Tmpl   : TChartTemplate; // 仪器的模板定义
    tls    : TchtSeries;     // 模板定义中的仪器定义
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
        // 这里存在问题，可能tls=nil
        { todo:处理 tls = nil的问题 }
        tls := nil;
        for ii := 0 to Tmpl.Series.Count - 1 do
          if Tmpl.Series.Items[ii].PDIndex = AIndex then
          begin
            tls := Tmpl.Series.Items[ii];
            Break;
          end;

        /// 这里需要考虑如果处理某个物理量没有针对性的过程线预定义的问题
        if tls <> nil then
        begin
          // 如果是环境量，跳过
          if tls.SourceType = pdsEnv then Exit;
          // 如果是指定仪器类型，且不是本仪器，跳过。这个是针对定义为仪器组的
          if tls.SourceName <> '*' then
            if tls.SourceName <> DsnName then Exit;
        end;
          // 如果本仪器的模板是组绘图模板，则需要知道自己是该组中第几只，因为支持组定义的模板里
          // 会指定第几只绘制那个物理量、用什么坐标轴。这里为快速，假定自己就是第一个仪器、选用
          // 第一个物理量。下一步计划用指定物理量的名字或index方式挑选数据
          // 如果MeterIndex既不是适用于所有仪器的0，也不是本仪器的序号Index，则不能绘图
          { if tls.MeterIndex <> 0 then
            if tls.MeterIndex <> index then Continue; }
        S := 'PD' + IntToStr( { tls.PDIndex } AIndex);
        for Fld in DS.Fields do
          if Fld.FieldName = S then
          begin
            AddNewLine(tls);
            // NewLine.Title已经在AddNewLine方法中赋值了，用的是模板中的名称。但是模板中的名称可能
            // 包含%符号，比如“%name%”，所以遇到这种情况就直接用物理量名称重新命名
            if Pos('%', NewLine.Title) > 0 then
                NewLine.Title := DsnName + '：' + Fld.DisplayLabel;

            DS.First;
            repeat
              if not Fld.IsNull then
                  NewLine.AddXY(DS.Fields[0].AsDateTime, Fld.Value)
              else
              begin
                // 处理Null数据：如果定义了曲线模板，且模板中要求有Null断点，则添加Null数据
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
            // 需要注意的是，线的数量不能太多，否则会溢出
            { todo:处理一下Pointer的设置问题，别溢出了。可以考虑有区别的重复使用 }
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
    // 使用了多少竖轴，如果只使用了左右各一个，颜色各异，否则统一轴的颜色
    cLeft, cRight, cCustom: Integer;

    CA: TChartAxis; // 上一个Custom

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
    // 设置各个不同的颜色
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

    if cCustom = 0 then __SetDiffColors // 没有CustomAxis，只有左右轴
    else if (cLeft = 0) and (cCustom = 1) then __SetDiffColors // 没有左轴，只有一个Custom
    else __SetSeriesUseAxisColor; // 其他情况，用轴颜色




    // 如果没有CustomAxis，则在创建NewLine的时候颜色就已经各异了。如果有customaxis, 则Series颜色必须
    // 和轴颜色一致

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
  { 根据第一个仪器重置Chart的坐标啥的 }
  _SplitMeterName(AMeters[0]);

  if mt = nil then
      Exit;
  SetupChart(AChart, (mt.ChartPreDef as TChartTemplate));
  // 设置标题
  AChart.Title.Caption := '仪器组过程线:' + AMeters[0] + ' ~ ' + AMeters.Strings[AMeters.Count - 1];
  DS := TClientDataSet.Create(nil);
  try
    for iMT := 0 to AMeters.Count - 1 do
    begin
      if iMT > 11 then Break; // 不能超过12支仪器，否则颜色就超出范围了

      _SplitMeterName(AMeters[iMT]);
      // mt := Excelmeters.Meter[AMeters.Strings[iMT]];
      if mt = nil then Continue;
      AddMeterLine(sMt, PDIndex);
    end
  finally
    DS.Free;
  end;

  // 当存在CustomAxis时，重新设置颜色
  _ResetSeriesColor;
  AChart.Legend.Alignment := laRight; // Legend靠右侧
  AChart.Draw;
  ReplaceAxes(AChart);
end;

end.
