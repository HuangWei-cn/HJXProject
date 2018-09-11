object fraXLSSummaryMeker: TfraXLSSummaryMeker
  Left = 0
  Top = 0
  Width = 619
  Height = 343
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  DesignSize = (
    619
    343)
  object Label1: TLabel
    Left = 8
    Top = 9
    Width = 84
    Height = 17
    Caption = #39044#23450#20041#27719#24635#34920
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lvwDefine: TListView
    Left = 8
    Top = 32
    Width = 601
    Height = 265
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        AutoSize = True
        Caption = #34920#26126
      end
      item
        AutoSize = True
        Caption = #31867#22411
      end
      item
        AutoSize = True
        Caption = #25968#25454#36215#22987#34892
      end
      item
        AutoSize = True
        Caption = #25968#25454#36215#22987#21015
      end
      item
        AutoSize = True
        Caption = #20202#22120#32534#21495#34892
      end
      item
        AutoSize = True
        Caption = #26085#26399#34892
      end>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'Tahoma'
    Font.Style = []
    GridLines = True
    Groups = <
      item
        Header = #27719#24635#34920#23450#20041
        GroupID = 0
        State = [lgsNormal]
        HeaderAlign = taLeftJustify
        FooterAlign = taLeftJustify
        TitleImage = -1
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 0
    ViewStyle = vsReport
    OnCreateItemClass = lvwDefineCreateItemClass
  end
  object btnMakeIt: TButton
    Left = 534
    Top = 306
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #29983#25104
    TabOrder = 1
    OnClick = btnMakeItClick
  end
  object memDebug: TMemo
    Left = 8
    Top = 312
    Width = 425
    Height = 173
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'Consolas'
    Font.Style = []
    Lines.Strings = (
      'memDebug')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 2
    Visible = False
    WordWrap = False
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'xls'
    Filter = 'Excel'#25991#20214'|*.xls'
    Options = [ofReadOnly, ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofCreatePrompt, ofEnableSizing]
    Title = #20445#23384#27719#24635#34920#25991#20214
    Left = 144
    Top = 360
  end
end
