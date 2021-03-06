object fraRptDataHTMLGrid: TfraRptDataHTMLGrid
  Left = 0
  Top = 0
  Width = 807
  Height = 609
  Padding.Left = 2
  Padding.Top = 2
  Padding.Right = 2
  Padding.Bottom = 2
  TabOrder = 0
  OnResize = FrameResize
  object wbReport: TWebBrowser
    Left = 2
    Top = 181
    Width = 803
    Height = 426
    Align = alClient
    TabOrder = 4
    ExplicitLeft = 316
    ExplicitTop = 340
    ExplicitWidth = 300
    ExplicitHeight = 150
    ControlData = {
      4C000000FE520000072C00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object hvReport: THtmlViewer
    Left = 2
    Top = 181
    Width = 803
    Height = 426
    BorderStyle = htFocused
    CharSet = GB2312_CHARSET
    DefBackground = clWhite
    DefFontName = 'Verdana'
    DefFontSize = 10
    DefPreFontName = 'Consolas'
    HistoryMaxCount = 0
    HtOptions = [htOverLinksActive, htPrintTableBackground, htPrintMonochromeBlack]
    NoSelect = False
    PrintMarginBottom = 2.000000000000000000
    PrintMarginLeft = 2.000000000000000000
    PrintMarginRight = 2.000000000000000000
    PrintMarginTop = 2.000000000000000000
    PrintScale = 1.000000000000000000
    OnImageRequest = hvReportImageRequest
    Align = alClient
    PopupMenu = PopupMenu1
    TabOrder = 2
    Visible = False
    Touch.InteractiveGestures = [igPan]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia]
  end
  object Panel1: TPanel
    Left = 2
    Top = 2
    Width = 803
    Height = 59
    Align = alTop
    BevelOuter = bvLowered
    Padding.Left = 3
    Padding.Top = 3
    Padding.Right = 3
    Padding.Bottom = 3
    TabOrder = 0
    DesignSize = (
      803
      59)
    object btnShowSetupPanel: TSpeedButton
      Left = 762
      Top = 27
      Width = 37
      Height = 22
      Anchors = [akTop, akRight]
      Caption = #35774#32622
      Flat = True
      OnClick = btnShowSetupPanelClick
    end
    object btnCreateReport: TButton
      Left = 12
      Top = 8
      Width = 126
      Height = 41
      Caption = #29983#25104#25968#25454#34920
      Style = bsCommandLink
      TabOrder = 0
      StyleElements = [seClient, seBorder]
      OnClick = btnCreateReportClick
    end
  end
  object pnlProgress: TPanel
    Left = 153
    Top = 224
    Width = 296
    Height = 81
    BevelKind = bkTile
    TabOrder = 1
    Visible = False
    object lblProgress: TLabel
      Left = 20
      Top = 16
      Width = 253
      Height = 13
      AutoSize = False
      Caption = #36827#24230#26465
    end
    object lblMeterName: TLabel
      Left = 20
      Top = 58
      Width = 65
      Height = 13
      Caption = 'lblMeterName'
    end
    object lblBreak: TLabel
      Left = 252
      Top = 58
      Width = 24
      Height = 13
      Cursor = crHandPoint
      Caption = #20013#26029
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = lblBreakClick
    end
    object Progress: TProgressBar
      Left = 20
      Top = 35
      Width = 253
      Height = 17
      Step = 1
      TabOrder = 0
    end
  end
  object pnlSetup: TPanel
    Left = 2
    Top = 61
    Width = 803
    Height = 120
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    Visible = False
    DesignSize = (
      803
      120)
    object pnlCloseSetupPanel: TSpeedButton
      Left = 776
      Top = 6
      Width = 23
      Height = 22
      Anchors = [akTop, akRight]
      Caption = 'r'
      Flat = True
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      OnClick = pnlCloseSetupPanelClick
    end
    object GroupBox1: TGroupBox
      Left = 167
      Top = 6
      Width = 365
      Height = 51
      Caption = #26085#26399#33539#22260#36873#39033
      TabOrder = 0
      object rbAllDatas: TRadioButton
        Left = 12
        Top = 20
        Width = 69
        Height = 17
        Caption = #20840#37096#25968#25454
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object rdDataRange: TRadioButton
        Left = 87
        Top = 20
        Width = 69
        Height = 17
        Caption = #25351#23450#33539#22260
        TabOrder = 1
      end
      object dtpStart: TDateTimePicker
        Left = 155
        Top = 18
        Width = 96
        Height = 21
        Date = 43249.477369722220000000
        Time = 43249.477369722220000000
        TabOrder = 2
        OnClick = dtpStartClick
      end
      object dtpEnd: TDateTimePicker
        Left = 257
        Top = 18
        Width = 96
        Height = 21
        Date = 43249.477899884260000000
        Time = 43249.477899884260000000
        TabOrder = 3
        OnClick = dtpStartClick
      end
    end
    object rdgMeterOption: TRadioGroup
      Left = 167
      Top = 63
      Width = 90
      Height = 51
      Caption = #20202#22120#36873#39033
      ItemIndex = 0
      Items.Strings = (
        #20840#37096#20202#22120
        #37096#20998#20202#22120)
      TabOrder = 1
    end
    object rdgDTRangeOption: TRadioGroup
      Left = 254
      Top = 63
      Width = 123
      Height = 51
      Caption = #32472#22270#26102#27573#36873#39033
      ItemIndex = 0
      Items.Strings = (
        #20840#26102#27573#36807#31243#32447
        #25351#23450#26102#27573#36807#31243#32447)
      TabOrder = 2
    end
    object GroupBox3: TGroupBox
      Left = 5
      Top = 6
      Width = 156
      Height = 107
      Caption = #20869#23481#36873#39033
      TabOrder = 3
      object optSheetAndChart: TRadioButton
        Left = 8
        Top = 16
        Width = 113
        Height = 17
        Caption = #25968#25454#34920#21644#36807#31243#32447
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object optSheetOnly: TRadioButton
        Left = 8
        Top = 32
        Width = 113
        Height = 17
        Caption = #20165#25968#25454#34920
        TabOrder = 1
      end
      object optChartOnly: TRadioButton
        Left = 8
        Top = 48
        Width = 73
        Height = 17
        Caption = #20165#36807#31243#32447
        TabOrder = 2
      end
      object chkIDTitle: TCheckBox
        Left = 24
        Top = 83
        Width = 101
        Height = 17
        Caption = #20202#22120#21517#65288#26631#39064#65289
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object chkExportChart: TCheckBox
        Left = 24
        Top = 66
        Width = 97
        Height = 17
        Caption = #23548#20986'Chart'
        Checked = True
        Enabled = False
        State = cbChecked
        TabOrder = 3
      end
    end
    object GroupBox2: TGroupBox
      Left = 383
      Top = 63
      Width = 149
      Height = 51
      Caption = #32472#22270#23610#23544#36873#39033
      TabOrder = 4
      object Label1: TLabel
        Left = 3
        Top = 24
        Width = 12
        Height = 13
        Caption = #38271
      end
      object Label2: TLabel
        Left = 72
        Top = 23
        Width = 12
        Height = 13
        Caption = #39640
      end
      object Edit1: TEdit
        Left = 16
        Top = 20
        Width = 35
        Height = 21
        TabOrder = 0
        Text = '600'
      end
      object Edit2: TEdit
        Left = 86
        Top = 20
        Width = 34
        Height = 21
        TabOrder = 1
        Text = '300'
      end
      object udChartWidth: TUpDown
        Left = 51
        Top = 20
        Width = 16
        Height = 21
        Associate = Edit1
        Min = 300
        Max = 2048
        Position = 600
        TabOrder = 2
      end
      object udChartHeight: TUpDown
        Left = 120
        Top = 20
        Width = 16
        Height = 21
        Associate = Edit2
        Min = 100
        Max = 1080
        Position = 300
        TabOrder = 3
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 368
    Top = 349
    object miCopyAll: TMenuItem
      Caption = #25335#36125#20840#37096
      OnClick = miCopyAllClick
    end
    object miCopySelected: TMenuItem
      Caption = #25335#36125#36873#20013#20869#23481
      OnClick = miCopySelectedClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miPrint: TMenuItem
      Caption = #25171#21360
      OnClick = miPrintClick
    end
    object miPrintPreview: TMenuItem
      Caption = #25171#21360#39044#35272
      OnClick = miPrintPreviewClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miSave: TMenuItem
      Caption = #20445#23384#32467#26524
      OnClick = miSaveClick
    end
  end
  object dlgPrint: TPrintDialog
    MaxPage = 1
    Options = [poPrintToFile, poPageNums, poSelection]
    Left = 300
    Top = 348
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'htm'
    Filter = 'HTML'#25991#20214'|*.htm'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = #20445#23384#32467#26524
    Left = 220
    Top = 348
  end
end
