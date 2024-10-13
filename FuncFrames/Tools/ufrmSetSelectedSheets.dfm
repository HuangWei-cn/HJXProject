object frmSetSelectedSheets: TfrmSetSelectedSheets
  Left = 0
  Top = 0
  Caption = #29992#25143#36873#23450#24037#20316#34920
  ClientHeight = 377
  ClientWidth = 697
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  DesignSize = (
    697
    377)
  TextHeight = 13
  object btnCancel: TsButton
    Left = 581
    Top = 8
    Width = 108
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 0
  end
  object btnAppendMeter: TsButton
    Left = 581
    Top = 39
    Width = 108
    Height = 25
    Hint = #23558#20449#24687#23436#25972#30340#39033#30446#28155#21152#21040#30417#27979#20202#22120#13#10#25991#20214#21015#34920#20013#65292#33258#21160#21076#38500#21547#8220#26410#30693#8221#13#10#39033#30340#26465#30446#12290
    Anchors = [akTop, akRight]
    Caption = #28155#21152#21040#21015#34920
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnClick = btnAppendMeterClick
  end
  object sCheckBox1: TsCheckBox
    Left = 581
    Top = 76
    Width = 111
    Height = 17
    Caption = #33258#21160#21076#38500#26410#30693#39033
    Anchors = [akTop, akRight]
    Checked = True
    Enabled = False
    State = cbChecked
    TabOrder = 1
  end
  object lvwSheets: TListView
    Left = 8
    Top = 8
    Width = 567
    Height = 361
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        AutoSize = True
        Caption = #35774#35745#32534#21495
      end
      item
        AutoSize = True
        Caption = #20202#22120#31867#22411
      end
      item
        AutoSize = True
        Caption = #23433#35013#37096#20301
      end
      item
        AutoSize = True
        Caption = #24037#20316#34920
      end
      item
        AutoSize = True
        Caption = #24037#20316#31807
      end>
    TabOrder = 3
    ViewStyle = vsReport
  end
end
