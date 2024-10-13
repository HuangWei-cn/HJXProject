object frmDataCount2: TfrmDataCount2
  Left = 0
  Top = 0
  Caption = #35266#27979#27425#25968#32479#35745#26041#27861'2'
  ClientHeight = 479
  ClientWidth = 813
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 660
    Top = 0
    Width = 153
    Height = 468
    Align = alRight
    TabOrder = 0
    object Label1: TLabel
      Left = 12
      Top = 120
      Width = 48
      Height = 13
      Caption = #25130#27490#26085#26399
    end
    object Label2: TLabel
      Left = 16
      Top = 68
      Width = 48
      Height = 13
      Caption = #36215#22987#26085#26399
    end
    object btnCountNow: TButton
      Left = 8
      Top = 12
      Width = 133
      Height = 33
      Caption = #32479#35745#35266#27979#27425#25968
      TabOrder = 0
      OnClick = btnCountNowClick
    end
    object dtpStart: TDateTimePicker
      Left = 12
      Top = 84
      Width = 129
      Height = 21
      Date = 42430.000000000000000000
      Time = 42430.000000000000000000
      TabOrder = 1
    end
    object dtpEnd: TDateTimePicker
      Left = 12
      Top = 136
      Width = 129
      Height = 21
      Date = 44855.277332719910000000
      Time = 44855.277332719910000000
      TabOrder = 2
    end
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 468
    Width = 813
    Height = 11
    Align = alBottom
    TabOrder = 1
    Visible = False
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 660
    Height = 468
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = #24635#27979#27425#32479#35745
      object HtmlViewer1: THtmlViewer
        Left = 0
        Top = 0
        Width = 652
        Height = 440
        BorderStyle = htFocused
        HistoryMaxCount = 0
        NoSelect = False
        PrintMarginBottom = 2.000000000000000000
        PrintMarginLeft = 2.000000000000000000
        PrintMarginRight = 2.000000000000000000
        PrintMarginTop = 2.000000000000000000
        PrintScale = 1.000000000000000000
        Align = alClient
        PopupMenu = PopupMenu1
        TabOrder = 0
        Touch.InteractiveGestures = [igPan]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia]
      end
    end
    object TabSheet2: TTabSheet
      Caption = #35814#24773
      ImageIndex = 1
      object HtmlViewer2: THtmlViewer
        Left = 0
        Top = 0
        Width = 652
        Height = 440
        BorderStyle = htFocused
        HistoryMaxCount = 0
        NoSelect = False
        PrintMarginBottom = 2.000000000000000000
        PrintMarginLeft = 2.000000000000000000
        PrintMarginRight = 2.000000000000000000
        PrintMarginTop = 2.000000000000000000
        PrintScale = 1.000000000000000000
        Align = alClient
        PopupMenu = PopupMenu1
        TabOrder = 0
        Touch.InteractiveGestures = [igPan]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia]
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 358
    Top = 150
    object piCopyToClipboard: TMenuItem
      Caption = #22797#21046#20869#23481
      OnClick = piCopyToClipboardClick
    end
  end
end
