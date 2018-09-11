object frmMultDates: TfrmMultDates
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #26085#26399#36873#25321#31383
  ClientHeight = 275
  ClientWidth = 310
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    310
    275)
  PixelsPerInch = 96
  TextHeight = 13
  object clstDates: TCheckListBox
    Left = 8
    Top = 12
    Width = 185
    Height = 255
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    TabOrder = 0
  end
  object Button1: TButton
    Left = 199
    Top = 12
    Width = 102
    Height = 33
    Caption = #30830#23450
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 199
    Top = 51
    Width = 102
    Height = 33
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 2
  end
end
