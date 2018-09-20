object fraEigenvalueWeb: TfraEigenvalueWeb
  Left = 0
  Top = 0
  Width = 530
  Height = 416
  Padding.Left = 3
  Padding.Top = 3
  Padding.Bottom = 3
  TabOrder = 0
  object Panel1: TPanel
    Left = 392
    Top = 3
    Width = 138
    Height = 410
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object btnGetEVData: TButton
      Left = 8
      Top = 12
      Width = 121
      Height = 25
      Caption = #25552#21462#29305#24449#20540
      TabOrder = 0
      OnClick = btnGetEVDataClick
    end
    object GroupBox1: TGroupBox
      Left = 6
      Top = 43
      Width = 127
      Height = 118
      Caption = #26102#38388#36873#39033
      TabOrder = 1
      object optLast: TRadioButton
        Left = 11
        Top = 20
        Width = 98
        Height = 17
        Caption = #26368#26032#29305#24449#20540
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object optSpecialDate: TRadioButton
        Left = 11
        Top = 36
        Width = 86
        Height = 17
        Caption = #25351#23450#24180#26376
        TabOrder = 1
      end
      object dtpStart: TDateTimePicker
        Left = 12
        Top = 59
        Width = 105
        Height = 21
        Date = 42430.000000000000000000
        Time = 42430.000000000000000000
        TabOrder = 2
      end
      object dtpEnd: TDateTimePicker
        Left = 12
        Top = 86
        Width = 105
        Height = 21
        Date = 43360.961305289360000000
        Time = 43360.961305289360000000
        TabOrder = 3
      end
    end
    object rdgMeterOption: TRadioGroup
      Left = 6
      Top = 163
      Width = 127
      Height = 58
      Caption = #20202#22120#36873#39033
      ItemIndex = 0
      Items.Strings = (
        #20840#37096#20202#22120
        #37096#20998#20202#22120)
      TabOrder = 2
    end
    object ProgressBar1: TProgressBar
      Left = 0
      Top = 393
      Width = 138
      Height = 17
      Align = alBottom
      Smooth = True
      Step = 1
      TabOrder = 3
      Visible = False
    end
  end
  object wbEVPage: TWebBrowser
    Left = 3
    Top = 3
    Width = 389
    Height = 410
    Align = alClient
    TabOrder = 1
    OnBeforeNavigate2 = wbEVPageBeforeNavigate2
    ExplicitLeft = 6
    ExplicitTop = 6
    ExplicitWidth = 386
    ExplicitHeight = 263
    ControlData = {
      4C00000034280000602A00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
end
