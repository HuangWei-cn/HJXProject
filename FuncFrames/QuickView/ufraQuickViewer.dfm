object fraQuickViewer: TfraQuickViewer
  Left = 0
  Top = 0
  Width = 843
  Height = 522
  TabOrder = 0
  object wbViewer: TWebBrowser
    Left = 23
    Top = 0
    Width = 300
    Height = 66
    TabOrder = 3
    OnBeforeNavigate2 = wbViewerBeforeNavigate2
    ControlData = {
      4C000000021F0000D20600000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 843
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
      Width = 93
      Height = 41
      Caption = #26597#35810
      Style = bsCommandLink
      TabOrder = 0
      OnClick = btnCreateQuickViewClick
    end
    object btnShowIncrement: TButton
      Left = 115
      Top = 6
      Width = 110
      Height = 41
      Caption = #26368#26032#22686#37327
      Style = bsCommandLink
      TabOrder = 1
      Visible = False
      OnClick = btnShowIncrementClick
    end
    object GroupBox1: TGroupBox
      Left = 604
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
        Checked = True
        State = cbChecked
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
        TabOrder = 3
      end
    end
    object btnSpecificDates: TButton
      Left = 148
      Top = 6
      Width = 141
      Height = 41
      Caption = #25351#23450#26085#26399#22686#37327
      Style = bsCommandLink
      TabOrder = 3
      Visible = False
      OnClick = btnSpecificDatesClick
    end
    object rdgQueryType: TRadioGroup
      Left = 440
      Top = 3
      Width = 164
      Height = 63
      Align = alRight
      Caption = #26597#35810#31867#22411
      Columns = 2
      ItemIndex = 1
      Items.Strings = (
        #36880#25903#36895#35272
        #26368#26032#22686#37327
        #38388#38548#22686#37327
        #26368#26032#25968#25454)
      TabOrder = 4
    end
    object rdgPresentType: TRadioGroup
      Left = 368
      Top = 3
      Width = 72
      Height = 63
      Align = alRight
      Caption = #34920#29616#26041#24335
      ItemIndex = 0
      Items.Strings = (
        'WebGrid'
        'EhGrid')
      TabOrder = 5
    end
  end
  object HtmlViewer: THtmlViewer
    Left = 23
    Top = 97
    Width = 341
    Height = 238
    BorderStyle = htFocused
    CharSet = GB2312_CHARSET
    DefFontName = 'Courier New'
    DefFontSize = 10
    HistoryMaxCount = 0
    NoSelect = False
    PrintMarginBottom = 2.000000000000000000
    PrintMarginLeft = 2.000000000000000000
    PrintMarginRight = 2.000000000000000000
    PrintMarginTop = 2.000000000000000000
    PrintScale = 1.000000000000000000
    OnHotSpotClick = HtmlViewerHotSpotClick
    PopupMenu = PopupMenu1
    TabOrder = 1
    Visible = False
    Touch.InteractiveGestures = [igPan]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia]
  end
  object DBGridEh1: TDBGridEh
    Left = 112
    Top = 183
    Width = 389
    Height = 296
    AllowedOperations = []
    Border.ExtendedDraw = False
    ColumnDefValues.Title.TitleButton = True
    DataGrouping.GroupPanelVisible = True
    DataSource = dsDatas
    DynProps = <>
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    IndicatorTitle.ShowDropDownSign = True
    IndicatorTitle.TitleButton = True
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghAutoSortMarking, dghMultiSortMarking, dghDblClickOptimizeColWidth, dghDialogFind, dghColumnResize, dghColumnMove, dghExtendVertLines]
    ParentFont = False
    PopupMenu = popGrid
    SearchPanel.Enabled = True
    SearchPanel.FilterOnTyping = True
    SortLocal = True
    STFilter.Local = True
    STFilter.Visible = True
    TabOrder = 5
    TitleParams.MultiTitle = True
    Visible = False
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object pnlDateSelector: TPanel
    Left = 200
    Top = 240
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
  object PopupMenu1: TPopupMenu
    Left = 628
    Top = 132
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
    Left = 624
    Top = 184
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'htm'
    Filter = 'HTML'#25991#20214'(*.htm)|*.htm'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = #20445#23384#32467#26524
    Left = 568
    Top = 184
  end
  object MemTableEh1: TMemTableEh
    FetchAllOnOpen = True
    Params = <>
    DataDriver = DataSetDriverEh1
    Left = 696
    Top = 365
  end
  object dsDatas: TDataSource
    DataSet = MemTableEh1
    Left = 696
    Top = 417
  end
  object cdsDatas: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 772
    Top = 417
  end
  object DataSetDriverEh1: TDataSetDriverEh
    ProviderDataSet = cdsDatas
    Left = 772
    Top = 353
  end
  object popGrid: TPopupMenu
    OnPopup = popGridPopup
    Left = 568
    Top = 132
    object piShowTrendLine: TMenuItem
      Action = actShowTrendLine
    end
    object piShowDataGrid: TMenuItem
      Action = actShowDatas
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object piOpenDataSheet: TMenuItem
      Action = actOpenDataSheet
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object N5: TMenuItem
      Action = actCopytoClipboard
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object piSetFont: TMenuItem
      Action = actSetGridFont
    end
    object piIncFontSize: TMenuItem
      Action = actIncFontSize
    end
    object piDecFontSize: TMenuItem
      Action = actDecFontSize
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object piCollapse: TMenuItem
      Caption = #25910#36215
      object piCollapseThisLevel: TMenuItem
        Caption = #25910#36215#26412#32423
        OnClick = piCollapseThisLevelClick
      end
      object piCollapseSubLevels: TMenuItem
        Caption = #25910#36215#23376#32423
        OnClick = piCollapseSubLevelsClick
      end
      object piCollapseAllLevel: TMenuItem
        Caption = #20840#37096#25910#36215
        OnClick = piCollapseAllLevelClick
      end
    end
  end
  object ActionList1: TActionList
    Left = 692
    Top = 132
    object actShowTrendLine: TAction
      Caption = #26174#31034#36807#31243#32447
      OnExecute = actShowTrendLineExecute
    end
    object actShowDatas: TAction
      Caption = #26174#31034#35266#27979#25968#25454#34920
      OnExecute = actShowDatasExecute
    end
    object actSetGridFont: TAction
      Category = 'Font'
      Caption = #35774#32622#23383#20307
      OnExecute = actSetGridFontExecute
    end
    object actIncFontSize: TAction
      Category = 'Font'
      Caption = #22686#22823#23383#21495
      OnExecute = actIncFontSizeExecute
    end
    object actDecFontSize: TAction
      Category = 'Font'
      Caption = #20943#23567#23383#21495
      OnExecute = actDecFontSizeExecute
    end
    object actOpenDataSheet: TAction
      Caption = #25171#24320#21407#22987#35745#31639#34920
      OnExecute = actOpenDataSheetExecute
    end
    object actCopytoClipboard: TAction
      Caption = #25335#36125#34920#26684
      OnExecute = actCopytoClipboardExecute
    end
  end
  object dlgFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 688
    Top = 188
  end
end
