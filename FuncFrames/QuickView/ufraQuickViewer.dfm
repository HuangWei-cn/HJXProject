object fraQuickViewer: TfraQuickViewer
  Left = 0
  Top = 0
  Width = 571
  Height = 511
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 571
    Height = 53
    Align = alTop
    TabOrder = 0
    object btnCreateQuickView: TButton
      Left = 8
      Top = 6
      Width = 113
      Height = 41
      Caption = #21019#24314#36895#35272
      Style = bsCommandLink
      TabOrder = 0
      OnClick = btnCreateQuickViewClick
    end
    object btnShowIncrement: TButton
      Left = 127
      Top = 6
      Width = 174
      Height = 41
      Caption = #26174#31034#26368#26032#25968#25454#22686#37327
      Style = bsCommandLink
      TabOrder = 1
      OnClick = btnShowIncrementClick
    end
    object chkUseFilter: TCheckBox
      Left = 460
      Top = 20
      Width = 97
      Height = 17
      Caption = #24573#30053#24494#23567#21464#21270
      TabOrder = 2
    end
  end
  object HtmlViewer: THtmlViewer
    Left = 0
    Top = 53
    Width = 571
    Height = 458
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
    Left = 72
    Top = 196
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
    Left = 328
    Top = 372
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
    Top = 372
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'htm'
    Filter = 'HTML'#25991#20214'(*.htm)|*.htm'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = #20445#23384#32467#26524
    Left = 164
    Top = 372
  end
end
