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
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 810
    Height = 89
    Align = alTop
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object btnFindNew: TButton
      Left = 12
      Top = 12
      Width = 161
      Height = 65
      Caption = #26597#25214#26032#22686#24037#20316#34920
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      WordWrap = True
      OnClick = btnFindNewClick
    end
  end
  object mmoResult: TMemo
    Left = 0
    Top = 89
    Width = 810
    Height = 492
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Courier Prime'
    Font.Style = []
    Lines.Strings = (
      'mmoResult')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
