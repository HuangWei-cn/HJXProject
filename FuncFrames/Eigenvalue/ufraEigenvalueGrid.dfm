object fraEigenvalueGrid: TfraEigenvalueGrid
  Left = 0
  Top = 0
  Width = 613
  Height = 755
  TabOrder = 0
  DesignSize = (
    613
    755)
  object Splitter1: TSplitter
    Left = 473
    Top = 0
    Height = 750
    Align = alRight
    ExplicitLeft = 336
    ExplicitTop = 236
    ExplicitHeight = 100
  end
  object ieBrowser: TWebBrowser
    Left = 56
    Top = 376
    Width = 361
    Height = 161
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
    ControlData = {
      4C0000004F250000A41000000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Panel1: TPanel
    Left = 476
    Top = 0
    Width = 137
    Height = 750
    Align = alRight
    BevelOuter = bvLowered
    TabOrder = 0
    object btnQuery: TButton
      Left = 6
      Top = 12
      Width = 119
      Height = 33
      Caption = #26597#35426#29305#24449#20540
      TabOrder = 0
      OnClick = btnQueryClick
    end
    object rdgMeterOption: TRadioGroup
      Left = 3
      Top = 179
      Width = 127
      Height = 58
      Caption = #20202#22120#36873#39033
      ItemIndex = 1
      Items.Strings = (
        #20840#37096#20202#22120
        #37096#20998#20202#22120)
      TabOrder = 1
    end
    object GroupBox1: TGroupBox
      Left = 3
      Top = 59
      Width = 127
      Height = 118
      Caption = #26102#38388#36873#39033
      TabOrder = 2
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
        OnChange = dtpEndChange
      end
      object dtpEnd: TDateTimePicker
        Left = 12
        Top = 86
        Width = 105
        Height = 21
        Date = 43360.000000000000000000
        Time = 0.961305289361916900
        TabOrder = 3
        OnChange = dtpEndChange
      end
    end
    object btnDrawEVGraph: TButton
      Left = 6
      Top = 243
      Width = 119
      Height = 34
      Caption = #29305#24449#26354#32447
      TabOrder = 3
      OnClick = btnDrawEVGraphClick
    end
    object grpEVItemSelect: TGroupBox
      Left = 3
      Top = 288
      Width = 127
      Height = 65
      Caption = #29305#24449#36873#39033
      TabOrder = 4
      object chkHistoryEV: TCheckBox
        Left = 12
        Top = 20
        Width = 97
        Height = 17
        Caption = #21382#21490#29305#24449#20540
        Checked = True
        Enabled = False
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
    end
    object grpDataSelect: TGroupBox
      Left = 3
      Top = 359
      Width = 127
      Height = 98
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
      Top = 463
      Width = 123
      Height = 105
      Caption = #29305#24449#26354#32447#36873#39033
      TabOrder = 6
      object chkGroupByPos: TCheckBox
        Left = 12
        Top = 24
        Width = 97
        Height = 17
        Caption = #25353#37096#20301#32858#21512
        Checked = True
        State = cbChecked
        TabOrder = 0
        WordWrap = True
      end
    end
  end
  object grdEV: TDBGridEh
    Left = 0
    Top = 0
    Width = 473
    Height = 750
    Align = alClient
    AllowedOperations = []
    ColumnDefValues.AlwaysShowEditButton = True
    ColumnDefValues.Title.TitleButton = True
    DataGrouping.Active = True
    DataGrouping.GroupPanelVisible = True
    DataSource = dsEV
    DynProps = <>
    EditActions = [geaCutEh, geaCopyEh, geaPasteEh, geaDeleteEh, geaSelectAllEh]
    Flat = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Consolas'
    Font.Style = []
    IndicatorParams.FillStyle = cfstGradientEh
    IndicatorParams.HorzLineColor = clBlue
    IndicatorParams.VertLineColor = clBlue
    IndicatorTitle.ShowDropDownSign = True
    IndicatorTitle.TitleButton = True
    OptionsEh = [dghFixed3D, dghResizeWholeRightPart, dghHighlightFocus, dghClearSelection, dghAutoSortMarking, dghMultiSortMarking, dghTraceColSizing, dghIncSearch, dghDblClickOptimizeColWidth, dghDialogFind, dghColumnResize, dghColumnMove, dghExtendVertLines]
    ParentFont = False
    PopupMenu = popEV
    SearchPanel.Enabled = True
    SearchPanel.FilterOnTyping = True
    EditButtonsShowOptions = [sebShowOnlyForCurCellEh, sebShowOnlyWhenDataEditingEh]
    SortLocal = True
    STFilter.Local = True
    STFilter.Visible = True
    TabOrder = 1
    TitleParams.MultiTitle = True
    TitleParams.SortMarkerStyle = smst3DFrameEh
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object prgBar: TProgressBar
    Left = 0
    Top = 750
    Width = 613
    Height = 5
    Align = alBottom
    TabOrder = 2
    Visible = False
  end
  object mtEV: TMemTableEh
    FetchAllOnOpen = True
    Params = <>
    DataDriver = dsdEV
    BeforeEdit = mtEVBeforeEdit
    Left = 164
    Top = 204
  end
  object dsEV: TDataSource
    DataSet = mtEV
    Left = 164
    Top = 156
  end
  object cdsEV: TClientDataSet
    Aggregates = <>
    Params = <>
    AfterEdit = cdsEVAfterEdit
    AfterPost = cdsEVAfterPost
    AfterApplyUpdates = cdsEVAfterApplyUpdates
    Left = 164
    Top = 304
  end
  object dsdEV: TDataSetDriverEh
    ProviderDataSet = cdsEV
    Left = 164
    Top = 252
  end
  object popEV: TPopupMenu
    Left = 280
    Top = 240
    object piCopyToClipBoard: TMenuItem
      Caption = #25335#35997#21040#21098#36028#26495
      OnClick = piCopyToClipBoardClick
    end
    object piCopyAsHTML: TMenuItem
      Caption = #25335#35997#28858#32178#38913#26684#24335
      Visible = False
      OnClick = piCopyAsHTMLClick
    end
    object piCopyUseWebGrid: TMenuItem
      Caption = #29992'WebGrid'#25335#36125
      OnClick = piCopyUseWebGridClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object piSaveAsHTML: TMenuItem
      Caption = #21478#23384#28858'HTML'#26684#24335
      OnClick = piSaveAsHTMLClick
    end
    object piSaveAsRTF: TMenuItem
      Caption = #21478#23384#28858'RTF'#26684#24335
      OnClick = piSaveAsRTFClick
    end
    object piSaveAsXLS: TMenuItem
      Caption = #21478#23384#28858'XLS'#26684#24335
      OnClick = piSaveAsXLSClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object piSaveDatas: TMenuItem
      Caption = 'SaveDatas'
      OnClick = piSaveDatasClick
    end
    object piLoadDatas: TMenuItem
      Caption = 'LoadDatas'
      OnClick = piLoadDatasClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object piPopupTreandLine: TMenuItem
      Caption = #27979#28857#36807#31243#32447
      OnClick = piPopupTreandLineClick
    end
    object piPopupDatas: TMenuItem
      Caption = #27979#28857#35266#27979#25968#25454
      OnClick = piPopupDatasClick
    end
    object piOpenExcelData: TMenuItem
      Caption = #27979#28857#21407#22987#25968#25454#65288'Excel'#65289
      OnClick = piOpenExcelDataClick
    end
    object piUpdateMeterData: TMenuItem
      Caption = #26356#26032#24403#21069#27979#28857#25968#25454
      Enabled = False
      OnClick = piUpdateMeterDataClick
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object piAllowEdit: TMenuItem
      Caption = #20801#35768#32534#36753
      OnClick = piAllowEditClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object piUpdateWordTables: TMenuItem
      Caption = #26356#26032'Word'#25253#21578
      Enabled = False
      OnClick = piUpdateWordTablesClick
    end
  end
  object dlgSave: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = #20445#23384#25968#25454#34920
    Left = 288
    Top = 164
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 376
    Top = 312
  end
  object dlgOpen: TOpenDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 360
    Top = 168
  end
end
