object frmDataSheet: TfrmDataSheet
  Left = 0
  Top = 0
  Caption = #24037#20316#34920
  ClientHeight = 497
  ClientWidth = 746
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 576
    Top = 0
    Width = 170
    Height = 497
    Align = alRight
    Color = clAppWorkSpace
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      170
      497)
    object btnRefresh: TButton
      Left = 12
      Top = 12
      Width = 149
      Height = 37
      Caption = 'Refresh'
      TabOrder = 0
      OnClick = btnRefreshClick
    end
    object lstSheets: TListBox
      Left = 12
      Top = 64
      Width = 149
      Height = 421
      Anchors = [akLeft, akTop, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 14
      ParentFont = False
      TabOrder = 1
      OnDblClick = lstSheetsDblClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 576
    Height = 497
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 1
    object lblBookName: TLabel
      Left = 0
      Top = 0
      Width = 576
      Height = 33
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'lblBookName'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitWidth = 556
    end
    object XLSGrid: TXLSGrid
      Left = 0
      Top = 33
      Width = 576
      Height = 443
      HeaderColor = 16248036
      GridlineColor = 15062992
      Align = alClient
      ColCount = 32
      DefaultColWidth = 68
      DefaultRowHeight = 20
      RowCount = 255
      Options = [goFixedVertLine, goFixedHorzLine, goRangeSelect, goRowSizing, goColSizing, goTabs]
      TabOrder = 0
      ColWidths = (
        21
        63
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68
        68)
      RowHeights = (
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20)
    end
  end
end
