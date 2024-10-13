object frmFindNewSheets: TfrmFindNewSheets
  Left = 0
  Top = 0
  Caption = #20202#22120#35745#31639#34920#26597#26032
  ClientHeight = 581
  ClientWidth = 810
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 810
    Height = 73
    Align = alTop
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object btnFindNew: TButton
      Left = 12
      Top = 10
      Width = 217
      Height = 47
      Caption = #26597#25214#26032#22686#24037#20316#34920
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Style = bsCommandLink
      TabOrder = 0
      WordWrap = True
      OnClick = btnFindNewClick
    end
  end
  object lvwNewSheets: TListView
    Left = 0
    Top = 73
    Width = 810
    Height = 508
    Align = alClient
    Checkboxes = True
    Columns = <
      item
        Caption = #24037#20316#34920
        Width = 180
      end
      item
        AutoSize = True
        Caption = #24037#20316#31807
      end>
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    PopupMenu = popOp
    TabOrder = 1
    ViewStyle = vsReport
  end
  object ActivityIndicator1: TActivityIndicator
    Left = 392
    Top = 264
    IndicatorSize = aisLarge
  end
  object popOp: TPopupMenu
    Left = 396
    Top = 184
    object piAppendNewSheet: TMenuItem
      Action = actAppendNewSheet
    end
  end
  object ActionList1: TActionList
    Left = 508
    Top = 60
    object actAppendNewSheet: TAction
      Caption = #28155#21152#24037#20316#34920#21040#20202#22120#25991#20214#21015#34920
      OnExecute = actAppendNewSheetExecute
    end
  end
end
