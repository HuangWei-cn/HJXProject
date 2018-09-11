object frmSumRptGenOpts: TfrmSumRptGenOpts
  Left = 0
  Top = 0
  AutoSize = True
  BorderStyle = bsDialog
  Caption = #27719#24635#34920#29983#25104#36873#39033
  ClientHeight = 217
  ClientWidth = 232
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 14
  object rdgDTOpts: TRadioGroup
    Left = 0
    Top = 0
    Width = 232
    Height = 89
    Align = alTop
    Caption = #26085#26399#36873#39033
    ItemIndex = 0
    Items.Strings = (
      #26368#26032#25968#25454
      #26368#25509#36817#25351#23450#26085#26399
      #25351#23450#26085#26399#20043#21069)
    TabOrder = 0
    ExplicitWidth = 285
  end
  object gbxDateSelect: TGroupBox
    Left = 0
    Top = 89
    Width = 232
    Height = 85
    Align = alTop
    Caption = #26085#26399#36873#25321
    TabOrder = 1
    ExplicitTop = 340
    ExplicitWidth = 285
    object lblStartDate: TLabel
      Left = 8
      Top = 25
      Width = 48
      Height = 14
      Caption = #25351#23450#26085#26399
    end
    object lblEndDate: TLabel
      Left = 8
      Top = 52
      Width = 48
      Height = 14
      Caption = #25130#27490#26085#26399
    end
    object dtpDate: TDateTimePicker
      Left = 62
      Top = 23
      Width = 151
      Height = 22
      Date = 42837.547416319440000000
      Time = 42837.547416319440000000
      TabOrder = 0
    end
    object dtpEndDate: TDateTimePicker
      Left = 62
      Top = 51
      Width = 151
      Height = 22
      Date = 42837.819509421290000000
      Time = 42837.819509421290000000
      TabOrder = 1
    end
  end
  object pnlCmd: TPanel
    Left = 0
    Top = 174
    Width = 232
    Height = 43
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitWidth = 285
    object btnCancel: TButton
      Left = 138
      Top = 6
      Width = 75
      Height = 25
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 1
    end
    object btnOK: TButton
      Left = 57
      Top = 6
      Width = 75
      Height = 25
      Caption = #30830#23450
      ModalResult = 1
      TabOrder = 0
    end
  end
end
