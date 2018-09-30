object fraEigenvalueGrid: TfraEigenvalueGrid
  Left = 0
  Top = 0
  Width = 589
  Height = 395
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 449
    Top = 0
    Height = 390
    Align = alRight
    ExplicitLeft = 336
    ExplicitTop = 236
    ExplicitHeight = 100
  end
  object Panel1: TPanel
    Left = 452
    Top = 0
    Width = 137
    Height = 390
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
      ItemIndex = 0
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
  end
  object grdEV: TDBGridEh
    Left = 0
    Top = 0
    Width = 449
    Height = 390
    Align = alClient
    AllowedOperations = []
    ColumnDefValues.Title.TitleButton = True
    DataGrouping.Active = True
    DataGrouping.GroupPanelVisible = True
    DataSource = dsEV
    DynProps = <>
    Flat = True
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    OptionsEh = [dghFixed3D, dghResizeWholeRightPart, dghHighlightFocus, dghClearSelection, dghAutoSortMarking, dghMultiSortMarking, dghTraceColSizing, dghIncSearch, dghDblClickOptimizeColWidth, dghDialogFind, dghColumnResize, dghColumnMove, dghExtendVertLines]
    PopupMenu = popEV
    ReadOnly = True
    SearchPanel.Enabled = True
    SearchPanel.FilterOnTyping = True
    SortLocal = True
    STFilter.Local = True
    STFilter.Visible = True
    TabOrder = 1
    TitleParams.SortMarkerStyle = smst3DFrameEh
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object prgBar: TProgressBar
    Left = 0
    Top = 390
    Width = 589
    Height = 5
    Align = alBottom
    TabOrder = 2
    Visible = False
  end
  object mtEV: TMemTableEh
    FetchAllOnOpen = True
    Params = <>
    DataDriver = dsdEV
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
      OnClick = piCopyAsHTMLClick
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
  end
end
