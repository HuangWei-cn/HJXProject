object frmInputLayoutData: TfrmInputLayoutData
  Left = 0
  Top = 0
  Caption = #35266#27979#25968#25454
  ClientHeight = 421
  ClientWidth = 702
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    702
    421)
  PixelsPerInch = 96
  TextHeight = 13
  object lblModifiedFlag: TLabel
    Left = 650
    Top = 405
    Width = 33
    Height = 13
    Alignment = taRightJustify
    Anchors = [akRight, akBottom]
    Caption = '           '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clSilver
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object grdItemDatas: TStringGrid
    Left = 20
    Top = 64
    Width = 663
    Height = 341
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvLowered
    BevelOuter = bvNone
    DefaultColWidth = 100
    FixedCols = 2
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goDrawFocusSelected, goColSizing, goEditing, goTabs, goAlwaysShowEditor]
    ParentFont = False
    TabOrder = 0
    OnSetEditText = grdItemDatasSetEditText
    ExplicitWidth = 534
    ExplicitHeight = 272
    ColWidths = (
      100
      100
      100
      100
      100)
    RowHeights = (
      24
      24
      24
      24
      24)
  end
  object btnOK: TButton
    Left = 20
    Top = 8
    Width = 121
    Height = 41
    Caption = #30830#23450
    Style = bsCommandLink
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 573
    Top = 8
    Width = 110
    Height = 41
    Anchors = [akTop, akRight]
    Caption = #21462#28040
    Style = bsCommandLink
    TabOrder = 2
    OnClick = btnCancelClick
    ExplicitLeft = 444
  end
end
