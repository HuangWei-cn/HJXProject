object fraQuickViewer: TfraQuickViewer
  Left = 0
  Top = 0
  Width = 723
  Height = 511
  TabOrder = 0
  object wbViewer: TWebBrowser
    Left = 0
    Top = 69
    Width = 723
    Height = 442
    Align = alClient
    TabOrder = 3
    OnBeforeNavigate2 = wbViewerBeforeNavigate2
    ExplicitLeft = 72
    ExplicitTop = 248
    ExplicitWidth = 300
    ExplicitHeight = 150
    ControlData = {
      4C000000B94A0000AF2D00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 723
    Height = 69
    Align = alTop
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 5
    Padding.Bottom = 2
    TabOrder = 0
    object btnCreateQuickView: TButton
      Left = 8
      Top = 6
      Width = 77
      Height = 41
      Caption = #36895#35272
      Style = bsCommandLink
      TabOrder = 0
      OnClick = btnCreateQuickViewClick
    end
    object btnShowIncrement: TButton
      Left = 91
      Top = 6
      Width = 110
      Height = 41
      Caption = #26368#26032#22686#37327
      Style = bsCommandLink
      TabOrder = 1
      OnClick = btnShowIncrementClick
    end
    object GroupBox1: TGroupBox
      Left = 484
      Top = 3
      Width = 233
      Height = 63
      Align = alRight
      Caption = #36873#39033
      TabOrder = 2
      object chkTableByType: TCheckBox
        Left = 12
        Top = 17
        Width = 109
        Height = 17
        Caption = #25353#20202#22120#31867#22411#20998#34920
        TabOrder = 0
      end
      object chkUseIE: TCheckBox
        Left = 12
        Top = 36
        Width = 97
        Height = 17
        Caption = #20351#29992'IE'#32452#20214
        TabOrder = 1
      end
      object chkUseFilter: TCheckBox
        Left = 127
        Top = 17
        Width = 97
        Height = 17
        Caption = #24573#30053#24494#23567#21464#21270
        TabOrder = 2
      end
      object chkAllMeters: TCheckBox
        Left = 127
        Top = 36
        Width = 97
        Height = 17
        Caption = #20840#37096#20202#22120
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
    end
    object btnSpecificDates: TButton
      Left = 204
      Top = 6
      Width = 106
      Height = 41
      Caption = #25351#23450#26085#26399
      Style = bsCommandLink
      TabOrder = 3
      OnClick = btnSpecificDatesClick
    end
  end
  object HtmlViewer: THtmlViewer
    Left = 0
    Top = 69
    Width = 723
    Height = 442
    BorderStyle = htFocused
    CharSet = GB2312_CHARSET
    DefFontName = 'Verdana'
    DefFontSize = 10
    HistoryMaxCount = 0
    NoSelect = False
    PrintMarginBottom = 2.000000000000000000
    PrintMarginLeft = 2.000000000000000000
    PrintMarginRight = 2.000000000000000000
    PrintMarginTop = 2.000000000000000000
    PrintScale = 1.000000000000000000
    OnHotSpotClick = HtmlViewerHotSpotClick
    Align = alClient
    PopupMenu = PopupMenu1
    TabOrder = 1
    Touch.InteractiveGestures = [igPan]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia]
  end
  object pnlProgress: TPanel
    Left = 80
    Top = 84
    Width = 405
    Height = 89
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    Visible = False
    object Label1: TLabel
      Left = 16
      Top = 13
      Width = 75
      Height = 16
      Caption = #27491#22312#26816#26597#65306
    end
    object lblDesignName: TLabel
      Left = 91
      Top = 13
      Width = 4
      Height = 16
    end
    object lblProgress: TLabel
      Left = 16
      Top = 63
      Width = 373
      Height = 16
      Alignment = taCenter
      AutoSize = False
    end
    object ProgressBar: TProgressBar
      Left = 16
      Top = 40
      Width = 373
      Height = 17
      Step = 1
      TabOrder = 0
    end
  end
  object pnlDateSelector: TPanel
    Left = 80
    Top = 196
    Width = 461
    Height = 141
    TabOrder = 4
    Visible = False
    object GroupBox2: TGroupBox
      Left = 16
      Top = 12
      Width = 350
      Height = 53
      Caption = #26085#26399'1'
      TabOrder = 0
      object dtp1: TDateTimePicker
        Left = 5
        Top = 20
        Width = 96
        Height = 21
        Date = 43418.000000000000000000
        Time = 43418.000000000000000000
        ImeMode = imDisable
        TabOrder = 0
      end
      object cmbDate1Opt: TComboBox
        Left = 188
        Top = 20
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemIndex = 1
        TabOrder = 1
        Text = #19981#26202#20110#25351#23450#26085#26399
        Items.Strings = (
          #26368#25509#36817#25351#23450#26085#26399
          #19981#26202#20110#25351#23450#26085#26399
          #19981#26089#20110#25351#23450#26085#26399
          #31561#20110#25351#23450#26085#26399)
      end
      object DateTimePicker1: TDateTimePicker
        Left = 107
        Top = 20
        Width = 71
        Height = 21
        Date = 43419.000000000000000000
        Time = 43419.000000000000000000
        Kind = dtkTime
        TabOrder = 2
      end
    end
    object GroupBox3: TGroupBox
      Left = 11
      Top = 71
      Width = 355
      Height = 54
      Caption = #26085#26399'2'
      TabOrder = 1
      object dtp2: TDateTimePicker
        Left = 10
        Top = 20
        Width = 96
        Height = 21
        Date = 43419.000000000000000000
        Time = 43419.000000000000000000
        ImeMode = imDisable
        TabOrder = 0
      end
      object cmbDate2Opt: TComboBox
        Left = 193
        Top = 20
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 1
        Text = #26368#25509#36817#25351#23450#26085#26399
        Items.Strings = (
          #26368#25509#36817#25351#23450#26085#26399
          #19981#26202#20110#25351#23450#26085#26399
          #19981#26089#20110#25351#23450#26085#26399
          #31561#20110#25351#23450#26085#26399)
      end
      object DateTimePicker2: TDateTimePicker
        Left = 112
        Top = 20
        Width = 71
        Height = 21
        Date = 43419.000000000000000000
        Time = 43419.000000000000000000
        Kind = dtkTime
        TabOrder = 2
      end
    end
    object btnDateSelected: TButton
      Left = 372
      Top = 16
      Width = 75
      Height = 25
      Caption = #30830#23450
      TabOrder = 2
      OnClick = btnDateSelectedClick
    end
    object chkSimpleSDGrid: TCheckBox
      Left = 372
      Top = 60
      Width = 65
      Height = 17
      Hint = #31616#21333#27169#24335#30340#34920#26684#65292#21462#28040#20102#26085#26399#21015#12289#38388#38548#22825#25968#12289#21464#21270#36895#29575#21015
      Caption = #31616#21333#34920
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 328
    Top = 452
    object miCopy: TMenuItem
      Caption = #25335#36125
      OnClick = miCopyClick
    end
    object miPrint: TMenuItem
      Caption = #25171#21360
      OnClick = miPrintClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miSave: TMenuItem
      Caption = #20445#23384
      OnClick = miSaveClick
    end
  end
  object dlgPrint: TPrintDialog
    MaxPage = 1
    Options = [poPrintToFile, poPageNums, poSelection]
    Left = 244
    Top = 452
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'htm'
    Filter = 'HTML'#25991#20214'(*.htm)|*.htm'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = #20445#23384#32467#26524
    Left = 164
    Top = 452
  end
end
