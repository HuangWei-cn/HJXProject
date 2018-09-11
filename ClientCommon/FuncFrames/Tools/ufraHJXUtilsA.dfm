object fraHJXUtilsA: TfraHJXUtilsA
  Left = 0
  Top = 0
  Width = 771
  Height = 510
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 510
    Align = alLeft
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 2
    Padding.Bottom = 2
    TabOrder = 0
    ExplicitLeft = -3
    object grpDataCount: TGroupBox
      Left = 3
      Top = 3
      Width = 179
      Height = 122
      Align = alTop
      Caption = #35266#27979#39057#27425#32479#35745
      TabOrder = 0
      object btnDataCount: TButton
        Left = 8
        Top = 20
        Width = 85
        Height = 25
        Caption = #35266#27979#28857#27425
        TabOrder = 0
      end
      object optDataCountByYear: TRadioButton
        Left = 8
        Top = 51
        Width = 77
        Height = 17
        Caption = #24180#24230#32479#35745
        Checked = True
        TabOrder = 1
        TabStop = True
      end
      object optDataCountByPeriod: TRadioButton
        Left = 8
        Top = 68
        Width = 113
        Height = 17
        Caption = #25351#23450#26102#27573
        TabOrder = 2
      end
    end
    object GroupBox1: TGroupBox
      Left = 3
      Top = 125
      Width = 179
      Height = 105
      Align = alTop
      Caption = #19979#27425#35266#27979#26085#26399
      TabOrder = 1
      ExplicitLeft = 36
      ExplicitTop = 160
      ExplicitWidth = 185
      object btnGetDataSchadule: TButton
        Left = 8
        Top = 20
        Width = 85
        Height = 25
        Caption = #35266#27979#26102#38388#34920
        TabOrder = 0
      end
    end
  end
  object Panel2: TPanel
    Left = 185
    Top = 0
    Width = 586
    Height = 510
    Align = alClient
    Caption = 'Panel2'
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 2
    Padding.Bottom = 2
    TabOrder = 1
    ExplicitLeft = 268
    ExplicitTop = 180
    ExplicitWidth = 185
    ExplicitHeight = 41
    object HtmlViewer: THtmlViewer
      Left = 3
      Top = 3
      Width = 580
      Height = 504
      BorderStyle = htFocused
      HistoryMaxCount = 0
      NoSelect = False
      PrintMarginBottom = 2.000000000000000000
      PrintMarginLeft = 2.000000000000000000
      PrintMarginRight = 2.000000000000000000
      PrintMarginTop = 2.000000000000000000
      PrintScale = 1.000000000000000000
      Align = alClient
      TabOrder = 0
      Touch.InteractiveGestures = [igPan]
      Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia]
      ExplicitLeft = 116
      ExplicitTop = 128
      ExplicitWidth = 150
      ExplicitHeight = 150
    end
  end
  object cdsDatas: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 104
    Top = 268
  end
end
