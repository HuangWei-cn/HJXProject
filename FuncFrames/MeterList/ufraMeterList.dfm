object fraMeterList: TfraMeterList
  Left = 0
  Top = 0
  Width = 227
  Height = 357
  Padding.Left = 2
  Padding.Top = 2
  Padding.Right = 2
  Padding.Bottom = 2
  TabOrder = 0
  DesignSize = (
    227
    357)
  object tvwMeters: TTreeView
    Left = 5
    Top = 5
    Width = 217
    Height = 321
    Anchors = [akLeft, akTop, akRight, akBottom]
    HideSelection = False
    Indent = 19
    PopupMenu = popMeterOp
    ReadOnly = True
    TabOrder = 0
    OnContextPopup = tvwMetersContextPopup
    OnCreateNodeClass = tvwMetersCreateNodeClass
    OnCustomDrawItem = tvwMetersCustomDrawItem
    OnDblClick = tvwMetersDblClick
  end
  object edtSearch: TEdit
    Left = 5
    Top = 332
    Width = 217
    Height = 23
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 1
    OnChange = edtSearchChange
  end
  object popMeterOp: TPopupMenu
    Left = 128
    Top = 228
    object piShowMeterDatas: TMenuItem
      Action = actShowMeterDatas
    end
    object actShowTrendLine1: TMenuItem
      Action = actShowTrendLine
      Caption = #26174#31034#36807#31243#32447
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object piPopTrendLine: TMenuItem
      Action = actPopTrendLine
    end
    object piPopDatas: TMenuItem
      Action = actPopDatas
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Action = actViewDataSheet
    end
    object N2: TMenuItem
      Action = actOpenDataBook
    end
  end
  object actlstMeterOp: TActionList
    Left = 136
    Top = 164
    object actShowMeterDatas: TAction
      Caption = #26174#31034#25968#25454
      OnExecute = actShowMeterDatasExecute
    end
    object actShowTrendLine: TAction
      Caption = 'actShowTrendLine'
      OnExecute = actShowTrendLineExecute
    end
    object actOpenDataBook: TAction
      Caption = #25171#24320#35266#27979#25968#25454#35745#31639#34920'(Excel)'
      OnExecute = actOpenDataBookExecute
    end
    object actViewDataSheet: TAction
      Caption = #26597#30475#21407#22987#25968#25454
      OnExecute = actViewDataSheetExecute
    end
    object actPopTrendLine: TAction
      Caption = #24377#20986#36807#31243#32447
      OnExecute = actPopTrendLineExecute
    end
    object actPopDatas: TAction
      Caption = #24377#20986#35266#27979#25968#25454
      OnExecute = actPopDatasExecute
    end
  end
end
