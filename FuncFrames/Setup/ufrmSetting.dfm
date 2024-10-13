object frmSetting: TfrmSetting
  Left = 0
  Top = 0
  Caption = #35774#32622
  ClientHeight = 337
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 173
    Height = 113
    Caption = #36807#31243#32447#36215#27490#26085#26399#35774#32622
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 20
      Width = 48
      Height = 13
      Caption = #36215#22987#26085#26399
    end
    object Label2: TLabel
      Left = 16
      Top = 44
      Width = 48
      Height = 13
      Caption = #25130#27490#26085#26399
    end
    object dtpStartDate: TDateTimePicker
      Left = 70
      Top = 17
      Width = 90
      Height = 21
      Date = 42430.000000000000000000
      Time = 42430.000000000000000000
      TabOrder = 0
      OnChange = dtpStartDateChange
    end
    object dtpEndDate: TDateTimePicker
      Left = 70
      Top = 41
      Width = 90
      Height = 21
      Date = 44883.000000000000000000
      Time = 44883.000000000000000000
      TabOrder = 1
      OnChange = dtpStartDateChange
    end
    object optUseDateSetting: TRadioButton
      Left = 12
      Top = 68
      Width = 121
      Height = 17
      Caption = #35774#23450#36215#27490#26085#26399
      TabOrder = 2
    end
    object optDisableDateSetting: TRadioButton
      Left = 12
      Top = 84
      Width = 117
      Height = 17
      Caption = #19981#35774#23450
      Checked = True
      TabOrder = 3
      TabStop = True
    end
  end
  object btnOK: TButton
    Left = 552
    Top = 8
    Width = 75
    Height = 25
    Caption = #30830#23450
    ModalResult = 1
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 552
    Top = 39
    Width = 75
    Height = 25
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 2
    OnClick = btnCancelClick
  end
end
