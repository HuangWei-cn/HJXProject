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
  uHJX.Classes.Templates, uHJX.Template.ChartTemplate, uMyTeeAxisScrollTool;

{ 本方法绘制过程线 }
procedure DrawMeterSeries(AChart: TChart; ChtTmpl: TChartTemplate; ADsnName: string;
  DTStart, DTEnd: TDateTime); overload;

procedure DrawMeterSeries(AChart: TChart; ADsnName: string; DTStart, DTEnd: TDateTime); overload;

implementation

procedure ResetChart(AChart: TChart);
var
  i: Integer;
begin
  AChart.FreeAllSeries;
  for i := AChart.LeftAxis.SubAxes.count - 1 downto 0 do AChart.LeftAxis.SubAxes[i].Free;
  AChart.LeftAxis.SubAxes.Clear;

  for i := AChart.RightAxis.SubAxes.count - 1 downto 0 do AChart.RightAxis.SubAxes[i].Free;
  AChart.RightAxis.SubAxes.Clear;

  for i := AChart.CustomAxes.count - 1 downto 0 do AChart.CustomAxes[i].Free;
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
    myAxisTool.Active := true;

    chtAx.Visible := true;
    if ChtTmpl.ChartType = cttTrendLine then chtAx.DateTimeFormat := ax.Format
    else chtAx.AxisValuesFormat := ax.Format;

    chtAx.Automatic := true;
    if ax.BottomSide then
    begin
      chtAx.SubAxes[0].Visible := false;
      chtAx.SubAxes[1].Visible := false;
      if ax.SubAxis1.Visible then
      begin
        chtAx.SubAxes[0].Visible := true;
        chtAx.SubAxes[0].DateTimeFormat := ax.Format;
      end;
      if ax.SubAxis2.Visible then
      begin
        chtAx.SubAxes[1].Visible := true;
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
      chtAx.Automatic := true;
      chtAx.Horizontal := false;
      chtAx.OtherSide := not ax.LeftSide;
      chtAx.AxisValuesFormat := ax.Format;
      chtAx.Title.Caption := ax.Title;
      ax.ChartAxis := chtAx;

      myAxisTool := ThwTeeAxisScrollTool.Create(AChart.Parent);
      myAxisTool.Axis := chtAx;
      myAxisTool.Active := true;
    end
    else // 其他的就是左轴和右轴了
    begin
      if ax.LeftSide then chtAx := AChart.LeftAxis
      else chtAx := AChart.RightAxis;
      chtAx.Title.Caption := ax.Title;
      chtAx.AxisValuesFormat := ax.Format;
      chtAx.Automatic := true;
      ax.ChartAxis := chtAx;

      myAxisTool := ThwTeeAxisScrollTool.Create(AChart.Parent);
      myAxisTool.Axis := chtAx;
      myAxisTool.Active := true;
    end;
  end;

  for i := 0 to AChart.Axes.count - 1 do AChart.Axes.Items[i].PositionUnits := muPixels;
end;

procedure ReplaceAxes(AChart: TChart);
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
begin
  NextXLeft := 0;
  NextXRight := 0;
  MargLeft := 20;
  MargRight := 20;
    { todo:为保险起见，这里最好再设置一遍Chart和各个坐标轴的PositionUnit }
  CAList := TList.Create;
  try
    for i := 0 to AChart.SeriesList.count - 1 do
      if AChart[i].Active then
        case AChart[i].VertAxis of
          aLeftAxis:
            begin
              if CAList.IndexOf(AChart.LeftAxis) = -1 then
              begin
                CAList.Add(AChart.LeftAxis);
                            // 下面的循环中，计入了主LeftAxis的Margin，故这里先行剔除，后面不再判断
                MargLeft := MargLeft - extraMargin;
              end;
            end;
          aRightAxis:
            begin
              if CAList.IndexOf(AChart.RightAxis) = -1 then
              begin
                CAList.Add(AChart.RightAxis);
                MargRight := MargRight - extraMargin;
              end;
            end;
          aCustomVertAxis:
            begin
              if AChart[i].CustomVertAxis <> nil then
                if CAList.IndexOf(AChart[i].CustomVertAxis) = -1 then
                    CAList.Add(AChart[i].CustomVertAxis);
            end;
        end;

    for i := 0 to CAList.count - 1 do
    begin
      CA := TChartAxis(CAList[i]);
      if CA.OtherSide then
      begin
        CA.PositionPercent := NextXRight;
        NextXRight := NextXRight - CA.MaxLabelsWidth - CA.TickLength - extraPos;
        MargRight := MargRight + extraMargin;
      end
      else
      begin
        CA.PositionPercent := NextXLeft;
        NextXLeft := NextXLeft - CA.MaxLabelsWidth - CA.TickLength - extraPos;
        MargLeft := MargLeft + extraMargin;
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
    NewLine := TLineSeries.Create(AChart);
    NewLine.Title := ATLSeries.Title;
    // 设置横轴
    NewLine.HorizAxis := aBottomAxis;
    NewLine.XValues.DateTime := true;
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
        NewLine.Pointer.Visible := false
    else
    begin
      // 这里暂时不处理Auto的情况，权当都是Always类型
      { TODO -oCharmer -cChartTemplateProc : 编写处理sptAuto类型的代码 }
      NewLine.Pointer.Visible := true;
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
        GetData := IAppServices.ClientDatas.GetAllPDDatas(DsnName, DS)
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
                  NewLine.AddNullXY(DS.Fields[0].AsDateTime, -10)
                end;
                DS.next;
              until DS.Eof;

              NewLine.TreatNulls := tnDontPaint;

              AChart.AddSeries(NewLine);

              NewLine.Pointer.Style := TSeriesPointerStyle(AChart.SeriesCount - 1);
              if AChart.SeriesCount = 1 then NewLine.Pointer.Size := 2
              else NewLine.Pointer.Size := 3;

              Break;
            end;

        end;
  end;

begin
  SetupChart(AChart, ChtTmpl);

  mt := ExcelMeters.Meter[ADsnName];
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
        for iMT := 0 to Grp.count - 1 do SetMeterLines(Grp.Items[iMT], iMT + 1);
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

end.
