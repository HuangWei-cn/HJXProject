{-----------------------------------------------------------------------------
 Unit Name: uFuncDrawTLByStyle
 Author:    ��ΰ
 Date:      26-����-2018
 Purpose:   ����Ԫ������ݹ�����ģ���ͼ
            ֻҪ����ģ�塢Chart����Ʊ�ţ��Ϳ��Ի����������������۵�֧���ǳ�
            ��Կɡ�����Ԫ�����ǣ�
            DrawMeterSeries���̡�
            ����Ԫ����Ҫ���ƹ����ߵļһ���á�
 History:
-----------------------------------------------------------------------------}

unit uFuncDrawTLByStyle;

interface

uses
    System.Classes, System.SysUtils, System.Generics.Collections, System.Types,
    VCLTee.Chart, VCLTee.Series, VCLTee.TeEngine, VCLTee.TeeProcs,
    Data.DB, Datasnap.DBClient,
    uHJX.Intf.AppServices, uHJX.Intf.Datas, uHJX.Classes.Meters, uTLDefineProc;

procedure DrawMeterSeries(AChart: TChart; PreDef: TTrendlinePreDefine; ADsnName: string;
    DTStart, DTEnd: TDateTime);

implementation

procedure ResetChart(AChart: TChart);
var
    i: Integer;
begin
    AChart.FreeAllSeries;
    for i := AChart.LeftAxis.SubAxes.count - 1 downto 0 do
        AChart.LeftAxis.SubAxes[i].Free;
    AChart.LeftAxis.SubAxes.Clear;

    for i := AChart.RightAxis.SubAxes.count - 1 downto 0 do
        AChart.RightAxis.SubAxes[i].Free;
    AChart.RightAxis.SubAxes.Clear;

    for i := AChart.CustomAxes.count - 1 downto 0 do
        AChart.CustomAxes[i].Free;
    AChart.CustomAxes.Clear;
end;

procedure SetupChart(AChart: TChart; TLD: TTrendlinePreDefine);
var
    i    : Integer;
    ax   : TTLAxis;
    chtAx: TChartAxis;
begin
    ResetChart(AChart);

    AChart.MarginUnits := muPixels;

    { ������Ҫ����һ��ChartTitle�а�����ռλ�� }
    AChart.Title.Caption := TLD.ChartTitle;

    // ���ú���
    AChart.BottomAxis.DateTimeFormat := TLD.HoriAxis.Format;
    AChart.BottomAxis.Automatic := True;
    AChart.BottomAxis.SubAxes[0].Visible := false;
    AChart.BottomAxis.SubAxes[1].Visible := false;
    if TLD.HoriAxis.SubAxis1.Visible then
    begin
        AChart.BottomAxis.SubAxes[0].Visible := True;
        AChart.BottomAxis.SubAxes[0].DateTimeFormat := TLD.HoriAxis.SubAxis1.Format;
    end;
    if TLD.HoriAxis.SubAxis2.Visible then
    begin
        AChart.BottomAxis.SubAxes[1].Visible := True;
        AChart.BottomAxis.SubAxes[1].DateTimeFormat := TLD.HoriAxis.SubAxis2.Format;
    end;
    // ���ú���title: sub[0]�������棬�м���sub��1������������bottomaxis
    if AChart.BottomAxis.SubAxes[0].Visible then
    begin
        AChart.BottomAxis.SubAxes[0].Title.Caption := TLD.HoriAxis.Title;
        AChart.BottomAxis.SubAxes[1].Title.Caption := '';
        AChart.BottomAxis.Title.Caption := '';
    end
    else if AChart.BottomAxis.SubAxes[1].Visible then
    begin
        AChart.BottomAxis.Title.Caption := '';
        AChart.BottomAxis.SubAxes[1].Title.Caption := TLD.HoriAxis.Title;
    end
    else
        AChart.BottomAxis.Title.Caption := TLD.HoriAxis.Title;

    // ��������
    for ax in TLD.VertAxis.Values do
    begin
        ax.ChartAxis := nil;
        // CustomAxis��Ҫ����
        if ax.AxisType = axCustom then
        begin
            chtAx := AChart.CustomAxes.Add;
            chtAx.Automatic := True;
            chtAx.Horizontal := false;
            chtAx.OtherSide := not ax.LeftSide;
            chtAx.AxisValuesFormat := ax.Format;
            chtAx.Title.Caption := ax.Title;
            ax.ChartAxis := chtAx;
        end
        else // �����ľ��������������
        begin
            if ax.LeftSide then
                chtAx := AChart.LeftAxis
            else
                chtAx := AChart.RightAxis;
            chtAx.Title.Caption := ax.Title;
            chtAx.AxisValuesFormat := ax.Format;
            chtAx.Automatic := True;
            ax.ChartAxis := chtAx;
        end;
    end;

    for i := 0 to AChart.Axes.count - 1 do
        AChart.Axes.Items[i].PositionUnits := muPixels;
end;

procedure ReplaceAxes(AChart:TChart);
const
    extraPos = 30; // �������֮��ļ��
const
    extraMargin = 80; // ÿ������ռ�ݵĿ�ȣ�ÿ����һ�����ᣬChartLeft��ChartRight��С���ֵ��
var
    CAList               : TList;
    i                    : integer;
    CA                   : TChartAxis;
    NextXLeft, NextXRight: integer;
    MargLeft, MargRight  : integer;
begin
    NextXLeft := 0;
    NextXRight := 0;
    MargLeft := 20;
    MargRight := 20;
    { todo:Ϊ����������������������һ��Chart�͸����������PositionUnit }
    CAList := TList.Create;
    try
        for i := 0 to AChart.SeriesList.Count - 1 do
            if AChart[i].Active then
                case AChart[i].VertAxis of
                    aLeftAxis:
                        begin
                            if CAList.IndexOf(AChart.LeftAxis) = -1 then
                            begin
                                CAList.Add(AChart.LeftAxis);
                            // �����ѭ���У���������LeftAxis��Margin�������������޳������治���ж�
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

        for i := 0 to CAList.Count - 1 do
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

procedure DrawMeterSeries(AChart: TChart; PreDef: TTrendlinePreDefine; ADsnName: string;
    DTStart, DTEnd: TDateTime);
var
    mt     : TMeterDefine;
    NewLine: TLineSeries;
    DS     : TClientDataSet;
    S      : string;
    iMT    : Integer;
    Grp    : TMeterGroupItem;
    { �����µ�LineSeries�������ݶ����������ʽ������ }
    procedure AddNewLine(ATLSeries: TTLSeries);
    begin
        NewLine := TLineSeries.Create(AChart);
        NewLine.Title := ATLSeries.Title;
        // ���ú���
        NewLine.HorizAxis := aBottomAxis;
        NewLine.XValues.DateTime := True;
        NewLine.Color := AChart.GetFreeSeriesColor;
        NewLine.DrawStyle := dsCurve;
        // ��������
        if ATLSeries.VertAxis.AxisType = axLeft then
            NewLine.VertAxis := aLeftAxis
        else if ATLSeries.VertAxis.AxisType = axRight then
            NewLine.VertAxis := aRightAxis
        else
        begin
            NewLine.VertAxis := aCustomVertAxis;
            NewLine.CustomVertAxis := ATLSeries.VertAxis.ChartAxis as TChartAxis;
        end;
    end;
    { ������DsnName�����ݸ��ݶ�����ӹ����ߡ�IndexΪ���������е���ţ�����1����֧Ϊ1 }
    procedure SetMeterLines(DsnName: string; Index: Integer = 1);
    var
        tls    : TTLSeries;
        Fld    : TField;
        GetData: Boolean;
    begin
        if (DTStart = 0) and (DTEnd = 0) then
            GetData := IAppServices.ClientDatas.GetAllPDDatas(DsnName, DS)
        else
            GetData := IAppServices.ClientDatas.GetPDDatasInPeriod(DsnName, DTStart, DTEnd, DS);

        if GetData then
            if DS.RecordCount > 0 then
                for tls in PreDef.Series do
                begin
                    if tls.SourceType = pdsEnv then
                        Continue;
                    // �����ָ����Ʊ�ţ��������ڵ�ǰ������ţ�����һ����������ʱ�����Ǵ�Ԥ������
                    // ����ָ����ŵļ������
                    if tls.SourceName <> '*' then
                        if tls.SourceName <> ADsnName then
                            Continue;
                    // ���MeterIndex�Ȳ�������������������0��Ҳ���Ǳ����������Index�����ܻ�ͼ
                    if tls.MeterIndex <> 0 then
                        if tls.MeterIndex <> index then
                            Continue;

                    // ���ڿ���PDIndex���⡣
                    S := 'PD' + IntToStr(tls.PDIndex);
                    for Fld in DS.Fields do
                        if Fld.FieldName = S then
                        begin
                            // �����߶���
                            AddNewLine(tls);
                            // ����Series.Title
                            if Pos('%name%', NewLine.Title) > 0 then
                                NewLine.Title := NewLine.Title.Replace('%name%', Fld.DisplayLabel)
                            else if Pos('%MeterName%', NewLine.Title) > 0 then
                                NewLine.Title := NewLine.Title.Replace('%MeterName%',
                                    DsnName);
                            // ������д����
                            DS.First;
                            repeat
                                NewLine.AddXY(DS.Fields[0].AsDateTime, Fld.AsFloat);
                                DS.next;
                            until DS.Eof;

                            AChart.AddSeries(NewLine);
                            NewLine.Pointer.Visible := True;
                            NewLine.Pointer.Style := TSeriesPointerStyle(AChart.SeriesCount - 1);
                            if AChart.SeriesCount = 1 then
                                NewLine.Pointer.Size := 2
                            else
                                NewLine.Pointer.Size := 3;

                            Break;
                        end;

                end;
    end;

begin
    SetupChart(AChart, PreDef);

    mt := ExcelMeters.Meter[ADsnName];
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
        if mt.PrjParams.GroupID = '' then
            SetMeterLines(ADsnName, 1)
        else if PreDef.ApplyToGroup then
        begin
            Grp := MeterGroup.ItemByName[mt.PrjParams.GroupID];
            if Grp = nil then
                SetMeterLines(ADsnName, 1)
            else
                for iMT := 0 to Grp.count - 1 do
                    SetMeterLines(Grp.Items[iMT], iMT + 1);
        end
        else
            SetMeterLines(ADsnName, 1);
    finally
        DS.Free;
    end;

    AChart.Draw;
    ReplaceAxes(AChart);
end;

end.
