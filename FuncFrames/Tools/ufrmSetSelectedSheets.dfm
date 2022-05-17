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
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  DesignSize = (
    697
    377)
  PixelsPerInch = 96
  TextHeight = 13
  object lvwSheets: TacListView
    Left = 8
    Top = 8
    Width = 567
    Height = 361
    Groups = <
      item
        Caption = #29992#25143#36873#23450#24037#20316#34920
        Expanded = True
        Selected = False
      end>
    Columns = <
      item
        Caption = #35774#35745#32534#21495
      end
      item
        Caption = #20202#22120#31867#22411
      end
      item
        Caption = #23433#35013#37096#20301
        Width = 120
      end
      item
        Caption = #24037#20316#34920
      end
      item
        Caption = #24037#20316#31807
        Width = 200
      end>
    Items = <
      item
        Caption = 'R01DB10'
        ShowProgress = True
        SubItems.Strings = (
          #38050#31563#35745
          #34920#23380#22365#27573#38392#22697
          'R10BD10'
          #24046#38459#24335#38050#31563#35745#35745#31639#34920'.XLSX')
        GroupIndex = 0
      end
      item
        Caption = 'R02BD13'
        ShowProgress = True
        SubItems.Strings = (
          #38050#31563#35745
          #24213#23380#22365#27573
          'R02BD13'
          #38050#31563#35745#35745#31639#34920)
        GroupIndex = 0
      end>
    SkinData.SkinSection = 'EDIT'
    BoundLabel.EnabledAlways = True
    BoundLabel.AllowClick = True
    BoundLabel.Caption = #36873#20013#24037#20316#34920
    BoundLabel.Layout = sclTopLeft
    GroupSkin = 'MENUITEM'
    ColumnSkin = 'COLHEADER'
    ItemSkin = 'MENUITEM'
    GroupFont.Charset = DEFAULT_CHARSET
    GroupFont.Color = clWindowText
    GroupFont.Height = -11
    GroupFont.Name = 'Tahoma'
    GroupFont.Style = []
    ColumnFont.Charset = DEFAULT_CHARSET
    ColumnFont.Color = clWindowText
    ColumnFont.Height = -11
    ColumnFont.Name = 'Tahoma'
    ColumnFont.Style = []
    ItemFont.Charset = DEFAULT_CHARSET
    ItemFont.Color = clWindowText
    ItemFont.Height = -11
    ItemFont.Name = 'Tahoma'
    ItemFont.Style = []
    CaptionOnEmpty = 'List is empty now'
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWhite
    ParentFont = False
    TabOrder = 0
    TabStop = False
  end
  object btnCancel: TsButton
    Left = 581
    Top = 8
    Width = 108
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 1
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
    TabOrder = 3
  end
end
