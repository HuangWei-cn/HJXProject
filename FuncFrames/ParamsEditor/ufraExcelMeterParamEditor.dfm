object fraXLSParamEditor: TfraXLSParamEditor
  Left = 0
  Top = 0
  Width = 365
  Height = 753
  TabOrder = 0
  PixelsPerInch = 96
  object CategoryPanelGroup1: TCategoryPanelGroup
    Left = 0
    Top = 101
    Width = 365
    Height = 652
    VertScrollBar.Tracking = True
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -12
    HeaderFont.Name = 'Tahoma'
    HeaderFont.Style = []
    ParentFont = False
    TabOrder = 0
    object CategoryPanel5: TCategoryPanel
      Top = 832
      Caption = #22270#34920#39044#23450#20041
      TabOrder = 0
      object Label1: TLabel
        Left = 4
        Top = 12
        Width = 72
        Height = 14
        Caption = #36807#31243#32447#39044#23450#20041
      end
      object Label2: TLabel
        Left = 4
        Top = 60
        Width = 60
        Height = 14
        Caption = #25968#25454#34920#23450#20041
      end
      object Label3: TLabel
        Left = 4
        Top = 112
        Width = 136
        Height = 14
        Caption = 'Excel'#23548#20986#24037#20316#34920#26684#24335#23450#20041
      end
      object cmbGraphDefine: TComboBox
        Left = 4
        Top = 32
        Width = 329
        Height = 22
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
      object cmbGridFormat: TComboBox
        Left = 4
        Top = 80
        Width = 329
        Height = 22
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
      object cmbXLSFormat: TComboBox
        Left = 4
        Top = 132
        Width = 329
        Height = 22
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
      end
    end
    object CategoryPanel4: TCategoryPanel
      Top = 632
      Caption = #33258#23450#20041#32467#26500
      TabOrder = 1
      object vleDataStru: TValueListEditor
        Left = 0
        Top = 0
        Width = 342
        Height = 174
        Align = alClient
        Font.Charset = GB2312_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        Strings.Strings = (
          #35266#27979#37327#21517#31216'='
          #29289#29702#37327#21517#31216'='
          #26085#26399#36215#22987#34892'='
          #26085#26399#36215#22987#21015'='
          #21021#20540#34892'='
          #35266#27979#20540#21015'='
          #29289#29702#37327#21015'='
          #22791#27880#21015'='
          #29305#24449#20540#39033'=')
        TabOrder = 0
        TitleCaptions.Strings = (
          #23646#24615#39033
          #23646#24615#20540)
        OnStringsChange = vleDataStruStringsChange
        ColWidths = (
          133
          186)
      end
    end
    object CategoryPanel3: TCategoryPanel
      Top = 479
      Height = 153
      Caption = #39044#23450#20041#25968#25454#32467#26500
      TabOrder = 2
      object cmbPreDefineDataStruc: TComboBox
        Left = 10
        Top = 12
        Width = 272
        Height = 22
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
      object memPreDDSContent: TMemo
        Left = 10
        Top = 40
        Width = 272
        Height = 77
        Anchors = [akLeft, akTop, akRight]
        Lines.Strings = (
          #39044#23450#20041#25968#25454#32467#26500#22914#19979#65306)
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
    object CategoryPanel2: TCategoryPanel
      Top = 285
      Height = 194
      Caption = #24037#31243#23646#24615
      TabOrder = 3
      object vlePrjParams: TValueListEditor
        Left = 0
        Top = 0
        Width = 342
        Height = 168
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        Strings.Strings = (
          #21333#20301#24037#31243#21517'='
          #24037#31243#37096#20301'='
          #39640#31243'='
          #26729#21495'='
          #26029#38754'='
          #23433#35013#28145#24230'='
          #22791#27880'=')
        TabOrder = 0
        TitleCaptions.Strings = (
          #23646#24615#39033
          #23646#24615#20540)
        OnStringsChange = vlePrjParamsStringsChange
        ColWidths = (
          135
          184)
      end
    end
    object CategoryPanel1: TCategoryPanel
      Top = 0
      Height = 285
      Caption = #20202#22120'/'#20256#24863#22120#23646#24615
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      object vleMeterParams: TValueListEditor
        Left = 0
        Top = 0
        Width = 342
        Height = 259
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        Strings.Strings = (
          #20202#22120#31867#22411'='
          #22411#21495'='
          #20986#21378#32534#21495'='
          #24037#20316#26041#24335'='
          #37327#31243#19979#38480'='
          #37327#31243#19978#38480'='
          #20256#24863#22120#25968#37327'='
          #23433#35013#26085#26399'='
          #21021#20540#26085#26399'='
          #35266#27979#25968#25454#25968#37327'='
          #29289#29702#37327#25968#37327'='
          #22791#27880'=')
        TabOrder = 0
        TitleCaptions.Strings = (
          #23646#24615#39033
          #23646#24615#20540)
        OnGetEditMask = vleMeterParamsGetEditMask
        OnGetEditText = vleMeterParamsGetEditText
        OnSetEditText = vleMeterParamsSetEditText
        OnStringsChange = vleMeterParamsStringsChange
        ColWidths = (
          134
          185)
      end
      object dtpDateEdit: TDateTimePicker
        Left = 136
        Top = 172
        Width = 201
        Height = 21
        BevelInner = bvNone
        BevelOuter = bvNone
        Date = 42866.000000000000000000
        Time = 0.109564039346878400
        Font.Charset = GB2312_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        Visible = False
        OnChange = dtpDateEditChange
        OnKeyPress = dtpDateEditKeyPress
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 365
    Height = 101
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      365
      101)
    object lblSelectDatafile: TLabel
      Left = 12
      Top = 44
      Width = 84
      Height = 14
      Hint = #21452#20987#21487#32534#36753#20202#22120#30340#25968#25454#23450#20041
      Caption = #24037#20316#31807#21450#24037#20316#34920
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnDblClick = lblSelectDatafileDblClick
    end
    object lblWorkBook: TLabel
      Left = 12
      Top = 64
      Width = 341
      Height = 31
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Color = clSilver
      ParentColor = False
      Transparent = False
      WordWrap = True
    end
    object lblWorkSheet: TLabel
      Left = 102
      Top = 44
      Width = 167
      Height = 14
      AutoSize = False
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
    end
    object edtDesignID: TLabeledEdit
      Left = 76
      Top = 12
      Width = 193
      Height = 24
      EditLabel.Width = 64
      EditLabel.Height = 16
      EditLabel.Caption = #35774#35745#32534#21495
      EditLabel.Font.Charset = ANSI_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -16
      EditLabel.Font.Name = #26032#23435#20307
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      EditLabel.Layout = tlCenter
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = #26032#23435#20307
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 0
      Text = ''
      OnChange = edtDesignIDChange
    end
    object Button1: TButton
      Left = 284
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Button1'
      TabOrder = 1
    end
    object Button2: TButton
      Left = 284
      Top = 32
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Button2'
      TabOrder = 2
    end
  end
  object dlgOpen: TOpenDialog
    FileName = 'E:\Work\'#24037#31185#38498'\'#40644#37329#23777'\'#35266#27979#25968#25454'\'#38170#32034#27979#21147#35745#35745#31639#34920'.xlsx'
    Filter = 'Excel'#24037#20316#31807'|*.xls;*.xlsx'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 224
    Top = 200
  end
end
