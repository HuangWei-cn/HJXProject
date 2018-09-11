object fraWebDataGrid: TfraWebDataGrid
  Left = 0
  Top = 0
  Width = 474
  Height = 333
  Padding.Left = 2
  Padding.Top = 2
  Padding.Right = 2
  Padding.Bottom = 2
  TabOrder = 0
  object htmlViewer: THtmlViewer
    Left = 2
    Top = 2
    Width = 470
    Height = 329
    BorderStyle = htFocused
    CharSet = GB2312_CHARSET
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
    ExplicitLeft = 72
    ExplicitTop = 100
    ExplicitWidth = 150
    ExplicitHeight = 150
  end
  object dlgSave: TSaveDialog
    Filter = 'HTML'#25991#20214'|*.htm;*.html'
    Left = 312
    Top = 276
  end
  object cdsMeterDatas: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 408
    Top = 276
  end
end
