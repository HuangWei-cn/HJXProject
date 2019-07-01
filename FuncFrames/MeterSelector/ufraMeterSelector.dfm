object fraMeterSelector: TfraMeterSelector
  Left = 0
  Top = 0
  Width = 270
  Height = 276
  Padding.Left = 3
  Padding.Top = 3
  Padding.Right = 3
  Padding.Bottom = 3
  TabOrder = 0
  object tvwMeters: TTreeView
    Left = 3
    Top = 3
    Width = 264
    Height = 270
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    HideSelection = False
    Indent = 19
    MultiSelect = True
    MultiSelectStyle = []
    ParentFont = False
    PopupMenu = PopupMenu1
    ReadOnly = True
    TabOrder = 0
    OnClick = tvwMetersClick
    OnCreateNodeClass = tvwMetersCreateNodeClass
    OnCustomDrawItem = tvwMetersCustomDrawItem
  end
  object PopupMenu1: TPopupMenu
    Left = 144
    Top = 96
    object piUnSelectAll: TMenuItem
      Caption = #20840#37096#21462#28040
      OnClick = piUnSelectAllClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object piSelectAll: TMenuItem
      Caption = #20840#36873
      OnClick = piSelectAllClick
    end
  end
end
