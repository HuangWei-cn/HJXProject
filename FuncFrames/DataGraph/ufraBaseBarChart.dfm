object fraBaseBarChart: TfraBaseBarChart
  Left = 0
  Top = 0
  Width = 790
  Height = 284
  TabOrder = 0
  object chtBar: TChart
    Left = 0
    Top = 0
    Width = 790
    Height = 284
    BackWall.Brush.Gradient.Direction = gdBottomTop
    BackWall.Brush.Gradient.EndColor = clWhite
    BackWall.Brush.Gradient.StartColor = 15395562
    BackWall.Brush.Gradient.Visible = True
    BackWall.Color = clWhite
    Foot.Font.Color = clBlue
    Foot.Font.Name = 'Verdana'
    Gradient.Direction = gdBottomTop
    Gradient.EndColor = clWhite
    Gradient.MidColor = 15395562
    Gradient.StartColor = 15395562
    LeftWall.Color = 14745599
    Legend.Font.Name = 'Verdana'
    Legend.Shadow.Transparency = 0
    Legend.Symbol.Gradient.EndColor = 10708548
    RightWall.Color = 14745599
    Title.Font.Color = clBlack
    Title.Font.Height = -15
    Title.Font.Name = 'Verdana'
    Title.Font.Quality = fqBest
    Title.Font.Shadow.HorizSize = 2
    Title.Font.Shadow.SmoothBlur = 4
    Title.Font.Shadow.VertSize = 2
    Title.Text.Strings = (
      '**'#26029#38754#35266#27979#25968#25454#21450#22686#37327)
    BottomAxis.Axis.Color = 4210752
    BottomAxis.Grid.Color = 11119017
    BottomAxis.GridCentered = True
    BottomAxis.LabelsAngle = 90
    BottomAxis.LabelsFormat.Font.Name = 'Verdana'
    BottomAxis.LabelsFormat.Font.Quality = fqBest
    BottomAxis.TicksInner.Color = 11119017
    BottomAxis.Title.Caption = #30417#27979#20202#22120
    BottomAxis.Title.Font.Height = -12
    BottomAxis.Title.Font.Name = 'Verdana'
    BottomAxis.Title.Font.Quality = fqBest
    DepthAxis.Axis.Color = 4210752
    DepthAxis.Grid.Color = 11119017
    DepthAxis.LabelsFormat.Font.Name = 'Verdana'
    DepthAxis.TicksInner.Color = 11119017
    DepthAxis.Title.Font.Name = 'Verdana'
    DepthTopAxis.Axis.Color = 4210752
    DepthTopAxis.Grid.Color = 11119017
    DepthTopAxis.LabelsFormat.Font.Name = 'Verdana'
    DepthTopAxis.TicksInner.Color = 11119017
    DepthTopAxis.Title.Font.Name = 'Verdana'
    LeftAxis.Axis.Color = 4210752
    LeftAxis.AxisValuesFormat = '0.00'
    LeftAxis.Grid.Color = 11119017
    LeftAxis.Grid.Style = psDot
    LeftAxis.LabelsFormat.Font.Name = 'Verdana'
    LeftAxis.LabelsFormat.Font.Quality = fqBest
    LeftAxis.LabelStyle = talValue
    LeftAxis.TicksInner.Color = 11119017
    LeftAxis.Title.Caption = #25968#25454
    LeftAxis.Title.Font.Height = -12
    LeftAxis.Title.Font.Name = 'Verdana'
    LeftAxis.Title.Font.Quality = fqBest
    RightAxis.Axis.Color = 4210752
    RightAxis.Grid.Color = 11119017
    RightAxis.LabelsFormat.Font.Name = 'Verdana'
    RightAxis.TicksInner.Color = 11119017
    RightAxis.Title.Font.Name = 'Verdana'
    TopAxis.Axis.Color = 4210752
    TopAxis.Grid.Color = 11119017
    TopAxis.LabelsFormat.Font.Name = 'Verdana'
    TopAxis.TicksInner.Color = 11119017
    TopAxis.Title.Font.Name = 'Verdana'
    View3D = False
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 20
    ExplicitTop = 48
    ExplicitWidth = 553
    ExplicitHeight = 250
    DefaultCanvas = 'TGDIPlusCanvas'
    ColorPaletteIndex = 13
    object ssMeterData: TBarSeries
      BarBrush.Color = 16744448
      BarBrush.Style = bsBDiagonal
      BarBrush.Gradient.EndColor = 10708548
      BarBrush.Gradient.Visible = True
      Marks.Frame.Visible = False
      Marks.Margins.Left = 12
      Marks.Margins.Right = 3
      Marks.Style = smsValue
      Marks.Callout.ArrowHead = ahSolid
      Marks.Callout.Length = 13
      Title = #24403#21069#27979#20540
      Gradient.EndColor = 10708548
      Gradient.Visible = True
      Shadow.Clip = True
      Shadow.Color = 6447714
      Shadow.HorizSize = 4
      Shadow.SmoothBlur = 7
      Shadow.VertSize = 4
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = #38271#26465
      YValues.Order = loNone
    end
    object ssDelta: TBarSeries
      BarBrush.Style = bsFDiagonal
      Marks.Style = smsValue
      Marks.Callout.ArrowHead = ahSolid
      SeriesColor = 8388863
      Title = #26399#38388#22686#37327
      Shadow.Clip = True
      Shadow.HorizSize = 4
      Shadow.SmoothBlur = 5
      Shadow.VertSize = 4
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = #38271#26465
      YValues.Order = loNone
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 648
    Top = 208
  end
end
