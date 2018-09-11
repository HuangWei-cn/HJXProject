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
  object hvReport: THtmlViewer
    Left = 2
    Top = 185
    Width = 803
    Height = 422
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
    Height = 124
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    Visible = False
    DesignSize = (
      803
      124)
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
      Left = 4
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
      Left = 375
      Top = 6
      Width = 104
      Height = 51
      Caption = #20202#22120#36873#39033
      ItemIndex = 0
      Items.Strings = (
        #20840#37096#20202#22120
        #37096#20998#20202#22120)
      TabOrder = 1
    end
    object GroupBox2: TGroupBox
      Left = 485
      Top = 6
      Width = 156
      Height = 51
      Caption = #22270#34920#36873#39033
      TabOrder = 2
      object chkCreateChart: TCheckBox
        Left = 9
        Top = 12
        Width = 173
        Height = 17
        Caption = #29983#25104#25968#25454#22270'('#36807#31243#32447#31561')'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = chkCreateChartClick
      end
      object chkExportChart: TCheckBox
        Left = 9
        Top = 30
        Width = 125
        Height = 17
        Caption = #23548#20986#25968#25454#22270#25991#20214
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
    end
    object rdgDTRangeOption: TRadioGroup
      Left = 4
      Top = 58
      Width = 134
      Height = 55
      Caption = #32472#22270#36873#39033
      ItemIndex = 0
      Items.Strings = (
        #20840#26102#27573#36807#31243#32447
        #25351#23450#26102#27573#36807#31243#32447)
      TabOrder = 3
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
