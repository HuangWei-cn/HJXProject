object fraIncGraph: TfraIncGraph
  Left = 0
  Top = 0
  Width = 819
  Height = 383
  TabOrder = 0
  object chtBar: TChart
    Left = 0
    Top = 0
    Width = 819
    Height = 383
    BackWall.Brush.Gradient.Direction = gdBottomTop
    BackWall.Brush.Gradient.EndColor = clWhite
    BackWall.Brush.Gradient.StartColor = 15395562
    BackWall.Color = clWhite
    BackWall.Transparent = False
    Border.Visible = True
    Foot.Font.Color = clBlue
    Foot.Font.Name = 'Verdana'
    Gradient.Direction = gdBottomTop
    Gradient.EndColor = clWhite
    Gradient.MidColor = 15395562
    Gradient.StartColor = 15395562
    LeftWall.Color = 14745599
    Legend.Font.Name = 'Verdana'
    Legend.LegendStyle = lsSeries
    Legend.Shadow.Transparency = 0
    Legend.TextStyle = ltsPlain
    RightWall.Color = 14745599
    ScrollMouseButton = mbMiddle
    Title.Font.Color = clBlack
    Title.Font.Height = -17
    Title.Font.Name = #40657#20307
    Title.Text.Strings = (
      #22810#28857#20301#31227#35745'2019'#24180#26376#22686#37327#22270)
    BottomAxis.Axis.Color = 4210752
    BottomAxis.Grid.Color = 11119017
    BottomAxis.Grid.Style = psDot
    BottomAxis.LabelsFormat.Font.Name = 'Verdana'
    BottomAxis.TicksInner.Color = 11119017
    BottomAxis.Title.Caption = #26102#38388
    BottomAxis.Title.Font.Height = -15
    BottomAxis.Title.Font.Name = #23435#20307
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
    LeftAxis.TicksInner.Color = 11119017
    LeftAxis.Title.Caption = #22686#37327
    LeftAxis.Title.Font.Height = -15
    LeftAxis.Title.Font.Name = #23435#20307
    Panning.MouseWheel = pmwNone
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
    Zoom.MouseWheel = pmwNormal
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentShowHint = False
    PopupMenu = popIncBar
    AutoSize = True
    ShowHint = True
    TabOrder = 0
    OnMouseMove = chtBarMouseMove
    DefaultCanvas = 'TGDIPlusCanvas'
    ColorPaletteIndex = 13
    object srsBar1: TBarSeries
      Marks.Visible = False
      SeriesColor = 7585268
      Title = #22686#37327#22270'1'
      Sides = 25
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = #38271#26465
      YValues.Order = loNone
      Data = {
        040A0000000000000000687F40FF0300000031D4C20000000000388340FF0300
        000032D4C20000000000248340FF0300000033D4C20000000000B88540FF0300
        000034D4C20000000000D48240FF0300000035D4C20000000000548540FF0300
        000036D4C20000000000108340FF0300000037D4C20000000000188540FF0300
        000038D4C20000000000308140FF0300000039D4C20000000000407F40FF0400
        00003130D4C2}
      Detail = {0000000000}
    end
    object ChartTool1: TAxisScrollTool
      AxisID = 0
    end
  end
  object TeeGDIPlus1: TTeeGDIPlus
    Active = True
    AntiAliasText = gpfBest
    TeePanel = chtBar
  end
  object popIncBar: TPopupMenu
    Left = 748
    Top = 280
    object piCopyAsBitmap: TMenuItem
      Caption = #25335#36125
      OnClick = piCopyAsBitmapClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object piSetup: TMenuItem
      Caption = #35774#32622
      OnClick = piSetupClick
    end
  end
end
