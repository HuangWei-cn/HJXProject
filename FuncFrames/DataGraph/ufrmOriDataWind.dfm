object frmOriDataWindow: TfrmOriDataWindow
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = #27979#26012#23380#21407#22987#35266#27979#25968#25454
  ClientHeight = 533
  ClientWidth = 390
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblPath: TLabel
    Left = 8
    Top = 8
    Width = 301
    Height = 34
    AutoSize = False
    WordWrap = True
  end
  object mmoData: TMemo
    Left = 4
    Top = 48
    Width = 378
    Height = 477
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object btnClose: TButton
    Left = 315
    Top = 8
    Width = 67
    Height = 25
    Caption = #20851#38381
    ModalResult = 1
    TabOrder = 1
  end
end
