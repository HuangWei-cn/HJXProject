object frmMeterSelector: TfrmMeterSelector
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = #36873#25321#30417#27979#20202#22120
  ClientHeight = 379
  ClientWidth = 290
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  PopupMode = pmAuto
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object lblSelNum: TLabel
    Left = 8
    Top = 352
    Width = 6
    Height = 12
  end
  inline fraMS: TfraMeterSelector
    Left = 0
    Top = 0
    Width = 290
    Height = 341
    Align = alTop
    Padding.Left = 3
    Padding.Top = 3
    Padding.Right = 3
    Padding.Bottom = 3
    TabOrder = 0
    ExplicitWidth = 290
    ExplicitHeight = 341
    inherited tvwMeters: TTreeView
      Width = 284
      Height = 335
      ExplicitWidth = 284
      ExplicitHeight = 335
    end
  end
  object Button1: TButton
    Left = 121
    Top = 347
    Width = 75
    Height = 25
    Caption = #30830#23450
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 202
    Top = 347
    Width = 75
    Height = 25
    Cancel = True
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 2
  end
end
