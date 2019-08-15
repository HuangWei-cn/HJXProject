object frmShowDeformPoints: TfrmShowDeformPoints
  Left = 0
  Top = 0
  Caption = #24179#38754#21464#24418#27979#28857#20998#24067#22270
  ClientHeight = 457
  ClientWidth = 695
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 548
    Top = 0
    Width = 147
    Height = 457
    Align = alRight
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object btnShowLastData: TButton
      Left = 12
      Top = 12
      Width = 117
      Height = 25
      Caption = #26174#31034#26368#26032#21464#24418
      TabOrder = 0
      OnClick = btnShowLastDataClick
    end
    object btnShowTrace: TButton
      Left = 12
      Top = 48
      Width = 117
      Height = 25
      Caption = #26174#31034#21464#24418#36712#36857
      TabOrder = 1
      OnClick = btnShowTraceClick
    end
    object GroupBox1: TGroupBox
      Left = 12
      Top = 136
      Width = 117
      Height = 133
      Caption = #26085#26399#36873#25321
      TabOrder = 2
      object Label1: TLabel
        Left = 8
        Top = 24
        Width = 48
        Height = 13
        Caption = #36215#22987#26085#26399
      end
      object Label2: TLabel
        Left = 8
        Top = 78
        Width = 48
        Height = 13
        Caption = #25130#27490#26085#26399
      end
      object dtpStart: TDateTimePicker
        Left = 8
        Top = 43
        Width = 98
        Height = 21
        Date = 43485.014422187500000000
        Time = 43485.014422187500000000
        TabOrder = 0
      end
      object dtpEnd: TDateTimePicker
        Left = 8
        Top = 97
        Width = 97
        Height = 21
        Date = 43691.014724386570000000
        Time = 43691.014724386570000000
        TabOrder = 1
      end
    end
    object btnPeriodDeform: TButton
      Left = 12
      Top = 105
      Width = 117
      Height = 25
      Caption = #26399#38388#21464#24418
      TabOrder = 3
      OnClick = btnPeriodDeformClick
    end
  end
end
