object fraEigenvalueWeb: TfraEigenvalueWeb
  Left = 0
  Top = 0
  Width = 625
  Height = 598
  Padding.Left = 3
  Padding.Top = 3
  Padding.Bottom = 3
  TabOrder = 0
  object Panel1: TPanel
    Left = 484
    Top = 3
    Width = 141
    Height = 592
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
        Date = 43360.000000000000000000
        Time = 0.961305289361916900
        TabOrder = 3
      end
    end
    object rdgMeterOption: TRadioGroup
      Left = 6
      Top = 163
      Width = 127
      Height = 58
      Caption = #20202#22120#36873#39033
      ItemIndex = 1
      Items.Strings = (
        #20840#37096#20202#22120
        #37096#20998#20202#22120)
      TabOrder = 2
    end
    object ProgressBar1: TProgressBar
      Left = 0
      Top = 575
      Width = 141
      Height = 17
      Align = alBottom
      Smooth = True
      Step = 1
      TabOrder = 3
      Visible = False
    end
    object grpEVItemSelect: TGroupBox
      Left = 6
      Top = 224
      Width = 127
      Height = 121
      Caption = #29305#24449#36873#39033
      TabOrder = 4
      object chkHistoryEV: TCheckBox
        Left = 12
        Top = 20
        Width = 97
        Height = 17
        Caption = #21382#21490#29305#24449#20540
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object chkYearEV: TCheckBox
        Left = 12
        Top = 43
        Width = 97
        Height = 17
        Caption = #24180#29305#24449#20540
        TabOrder = 1
      end
      object chkMonthEV: TCheckBox
        Left = 12
        Top = 66
        Width = 97
        Height = 17
        Caption = #26376#29305#24449#20540
        TabOrder = 2
      end
      object chkLastData: TCheckBox
        Left = 12
        Top = 89
        Width = 97
        Height = 17
        Caption = #24403#21069#27979#20540
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
    end
    object grpDataSelect: TGroupBox
      Left = 6
      Top = 349
      Width = 127
      Height = 105
      Caption = #25968#25454#36873#39033
      TabOrder = 5
      object chkMinData: TCheckBox
        Left = 12
        Top = 20
        Width = 97
        Height = 17
        Caption = #26368#23567#20540
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object chkIncData: TCheckBox
        Left = 12
        Top = 43
        Width = 97
        Height = 17
        Caption = #22686#37327
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
      object chkAmplitude: TCheckBox
        Left = 12
        Top = 66
        Width = 97
        Height = 17
        Caption = #21464#24133
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
    end
    object GroupBox2: TGroupBox
      Left = 6
      Top = 456
      Width = 127
      Height = 73
      Caption = #20854#20182#36873#39033
      TabOrder = 6
      object chkSeqNum: TCheckBox
        Left = 12
        Top = 24
        Width = 97
        Height = 17
        Caption = #24207#21495#21015
        TabOrder = 0
      end
      object chk3TitleRows: TCheckBox
        Left = 12
        Top = 40
        Width = 97
        Height = 17
        Caption = '3'#34892#26631#39064#26679#24335
        TabOrder = 1
      end
    end
  end
  object wbEVPage: TWebBrowser
    Left = 3
    Top = 3
    Width = 481
    Height = 592
    Align = alClient
    TabOrder = 1
    OnBeforeNavigate2 = wbEVPageBeforeNavigate2
    ExplicitLeft = 6
    ExplicitTop = 6
    ExplicitWidth = 386
    ExplicitHeight = 263
    ControlData = {
      4C000000B63100002F3D00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
end
