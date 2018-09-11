object frmDataCount: TfrmDataCount
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'frmDataCount'
  ClientHeight = 385
  ClientWidth = 578
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 17
  object Label1: TLabel
    Left = 16
    Top = 20
    Width = 56
    Height = 17
    Caption = #36215#22987#26085#26399
  end
  object Label2: TLabel
    Left = 216
    Top = 20
    Width = 56
    Height = 17
    Caption = #25130#27490#26085#26399
  end
  object dtp1: TDateTimePicker
    Left = 84
    Top = 16
    Width = 117
    Height = 25
    Date = 42935.553416446760000000
    Time = 42935.553416446760000000
    TabOrder = 0
  end
  object dtp2: TDateTimePicker
    Left = 278
    Top = 16
    Width = 123
    Height = 25
    Date = 42935.553491041670000000
    Time = 42935.553491041670000000
    TabOrder = 1
  end
  object memDataCount: TMemo
    Left = 8
    Top = 52
    Width = 433
    Height = 325
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'memDataCount')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object Button1: TButton
    Left = 452
    Top = 17
    Width = 108
    Height = 25
    Caption = #26597#35810
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 452
    Top = 52
    Width = 108
    Height = 25
    Caption = #20851#38381
    ModalResult = 1
    TabOrder = 4
    OnClick = Button2Click
  end
end
