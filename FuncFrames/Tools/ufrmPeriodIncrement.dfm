object frmPeriodIncrement: TfrmPeriodIncrement
  Left = 0
  Top = 0
  Caption = #21608#26399#22686#37327#26597#35810
  ClientHeight = 584
  ClientWidth = 878
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
  object pnlFunc: TPanel
    Left = 0
    Top = 0
    Width = 878
    Height = 85
    Align = alTop
    TabOrder = 0
    object GroupBox1: TGroupBox
      Left = 1
      Top = 1
      Width = 204
      Height = 83
      Align = alLeft
      Caption = #26597#35810#26102#38388#27573
      TabOrder = 0
      object Label1: TLabel
        Left = 24
        Top = 24
        Width = 48
        Height = 13
        Caption = #36215#22987#26085#26399
      end
      object Label2: TLabel
        Left = 24
        Top = 52
        Width = 48
        Height = 13
        Caption = #25130#27490#26085#26399
      end
      object dtpStartDate: TDateTimePicker
        Left = 78
        Top = 20
        Width = 113
        Height = 21
        Date = 42444.000000000000000000
        Time = 42444.000000000000000000
        TabOrder = 0
      end
      object dtpEndDate: TDateTimePicker
        Left = 78
        Top = 52
        Width = 113
        Height = 21
        Date = 44103.916666666660000000
        Time = 44103.916666666660000000
        TabOrder = 1
      end
    end
    object GroupBox2: TGroupBox
      Left = 205
      Top = 1
      Width = 200
      Height = 83
      Align = alLeft
      Caption = #26597#35810#21608#26399
      TabOrder = 1
      object Label3: TLabel
        Left = 17
        Top = 46
        Width = 60
        Height = 13
        Caption = #21608#26399#36215#22987#26085
      end
      object edtStartDay: TEdit
        Left = 83
        Top = 43
        Width = 39
        Height = 21
        NumbersOnly = True
        TabOrder = 0
        Text = '20'
      end
      object updStartDay: TUpDown
        Left = 122
        Top = 43
        Width = 16
        Height = 21
        Associate = edtStartDay
        Max = 30
        Position = 20
        TabOrder = 1
      end
      object radMonth: TRadioButton
        Left = 12
        Top = 20
        Width = 69
        Height = 17
        Caption = #26376#22686#37327
        Checked = True
        TabOrder = 2
        TabStop = True
      end
      object radYear: TRadioButton
        Left = 87
        Top = 20
        Width = 69
        Height = 17
        Caption = #24180#22686#37327
        TabOrder = 3
      end
    end
    object btnQuery: TButton
      Left = 531
      Top = 8
      Width = 114
      Height = 66
      Caption = #26597#35810
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnQueryClick
    end
    object GroupBox3: TGroupBox
      Left = 405
      Top = 1
      Width = 120
      Height = 83
      Align = alLeft
      Caption = #34920#26684#26679#24335
      TabOrder = 3
      object radHGrid: TRadioButton
        Left = 16
        Top = 20
        Width = 113
        Height = 17
        Caption = #27178#21521#34920#26684
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object radVGrid: TRadioButton
        Left = 16
        Top = 45
        Width = 113
        Height = 17
        Caption = #32437#21521#34920#26684
        TabOrder = 1
      end
    end
  end
  object WB: TWebBrowser
    Left = 0
    Top = 85
    Width = 878
    Height = 499
    Align = alClient
    TabOrder = 1
    OnBeforeNavigate2 = WBBeforeNavigate2
    ExplicitLeft = 1
    ExplicitTop = 98
    ExplicitHeight = 487
    ControlData = {
      4C000000BE5A0000933300000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
end
