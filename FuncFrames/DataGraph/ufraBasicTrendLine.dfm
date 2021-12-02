object fraBasicTrendLine: TfraBasicTrendLine
  Left = 0
  Top = 0
  Width = 800
  Height = 350
  TabOrder = 0
  object chtLine: TChart
    Left = 0
    Top = 0
    Width = 800
    Height = 350
    BackWall.Color = clWhite
    Border.Visible = True
    Legend.Alignment = laTop
    Legend.CheckBoxes = True
    Legend.DrawBehind = True
    Legend.LegendStyle = lsSeries
    Legend.TextStyle = ltsPlain
    MarginLeft = 20
    MarginRight = 20
    MarginUnits = muPixels
    PrintProportional = False
    Title.Font.Color = clBlack
    Title.Font.Height = -17
    Title.Font.Name = #40657#20307
    Title.Text.Strings = (
      'TChart')
    OnClickSeries = chtLineClickSeries
    BottomAxis.DateTimeFormat = 'yyyy-mm-dd'
    BottomAxis.Grid.Color = 13750737
    BottomAxis.Grid.Style = psDot
    BottomAxis.Grid.Width = 0
    BottomAxis.Increment = 1.000000000000000000
    BottomAxis.LabelsFormat.Margins.Units = maPercentSize
    BottomAxis.LabelsMultiLine = True
    BottomAxis.LabelsSize = 20
    BottomAxis.MinorGrid.Color = 15263976
    BottomAxis.MinorGrid.Style = psDot
    BottomAxis.MinorGrid.Width = 0
    BottomAxis.MinorGrid.Visible = True
    BottomAxis.SubAxes = <
      item
        Grid.Visible = False
        Horizontal = True
        OtherSide = False
        Visible = False
      end
      item
        Grid.Visible = False
        Horizontal = True
        OtherSide = False
        Visible = False
      end>
    BottomAxis.Title.Caption = #35266#27979#26085#26399
    BottomAxis.Title.Font.Name = #40657#20307
    BottomAxis.Title.Font.Quality = fqNormal
    LeftAxis.AxisValuesFormat = '#,##0.00#'
    LeftAxis.Grid.Color = 14671839
    LeftAxis.Grid.Style = psDot
    LeftAxis.Grid.Width = 0
    LeftAxis.Title.Caption = #24038#36724
    LeftAxis.Title.Font.Name = #40657#20307
    Panning.MouseWheel = pmwNone
    RightAxis.Grid.Visible = False
    RightAxis.Title.Caption = #21491#36724
    RightAxis.Title.Font.Name = #40657#20307
    Shadow.Visible = False
    View3D = False
    Zoom.MouseWheel = pmwNormal
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentShowHint = False
    PopupMenu = popTL
    ShowHint = True
    TabOrder = 0
    OnClick = chtLineClick
    OnDblClick = chtLineDblClick
    OnMouseMove = chtLineMouseMove
    DefaultCanvas = 'TGDIPlusCanvas'
    PrintMargins = (
      2
      5
      3
      6)
    ColorPaletteIndex = 19
    object Series1: TLineSeries
      Shadow.SmoothBlur = 43
      Brush.BackColor = clDefault
      DrawStyle = dsCurve
      LinePen.Color = clDefault
      Pointer.Brush.Style = bsClear
      Pointer.HorizSize = 2
      Pointer.InflateMargins = True
      Pointer.Pen.Color = clDefault
      Pointer.Style = psRectangle
      Pointer.VertSize = 2
      Pointer.Visible = True
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series2: TLineSeries
      Shadow.SmoothBlur = 75
      Brush.BackColor = clDefault
      LinePen.Color = clDefault
      Pointer.Brush.Style = bsClear
      Pointer.HorizSize = 3
      Pointer.InflateMargins = True
      Pointer.Pen.Color = clDefault
      Pointer.Style = psCircle
      Pointer.VertSize = 3
      Pointer.Visible = True
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object ctScrollLeft: TAxisScrollTool
      Active = False
      AxisID = 2
    end
    object ctScrollBottom: TAxisScrollTool
      Active = False
      AxisID = 0
    end
    object ctScrollRight: TAxisScrollTool
      Active = False
      AxisID = 0
    end
  end
  object TeeGDIPlus1: TTeeGDIPlus
    Active = True
    AntiAliasText = gpfBest
    TeePanel = chtLine
    Left = 28
    Top = 4
  end
  object popTL: TPopupMenu
    Left = 368
    Top = 100
    object piCopyAsBitmap: TMenuItem
      Caption = #25335#36125#20026#20301#22270
      OnClick = piCopyAsBitmapClick
    end
    object piCopyAsEMF: TMenuItem
      Caption = #25335#36125#20026#22270#24418
      OnClick = piCopyAsEMFClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object piSaveAsBitmap: TMenuItem
      Caption = #21478#23384#20026#20301#22270
      OnClick = piSaveAsBitmapClick
    end
    object piSaveAsEMF: TMenuItem
      Caption = #21478#23384#20026#22270#24418
      OnClick = piSaveAsEMFClick
    end
    object piSaveAsTeeChart: TMenuItem
      Caption = #21478#23384#20026'Tee'#26684#24335
      OnClick = piSaveAsTeeChartClick
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object piSetupChart: TMenuItem
      Caption = #35774#32622
      OnClick = piSetupChartClick
    end
    object piSetupSeries: TMenuItem
      Caption = #26354#32447#35774#32622
      OnClick = piSetupSeriesClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object piMinimalism: TMenuItem
      Caption = #26497#31616
      OnClick = piMinimalismClick
    end
  end
end
