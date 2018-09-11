object fraMeterListGrid: TfraMeterListGrid
  Left = 0
  Top = 0
  Width = 560
  Height = 384
  TabOrder = 0
  object dbgMeters: TDBGridEh
    Left = 0
    Top = 0
    Width = 560
    Height = 384
    Align = alClient
    AllowedOperations = []
    Border.ExtendedDraw = False
    DataSource = dsMeters
    DrawMemoText = True
    DynProps = <>
    EvenRowColor = clMoneyGreen
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    IndicatorParams.FillStyle = cfstThemedEh
    OddRowColor = clSkyBlue
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDblClickOptimizeColWidth, dghDialogFind, dghColumnResize, dghColumnMove, dghExtendVertLines]
    ParentFont = False
    ReadOnly = True
    SortLocal = True
    STFilter.Local = True
    STFilter.Visible = True
    TabOrder = 0
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object dsMeters: TDataSource
    DataSet = mtMeters
    Left = 404
    Top = 264
  end
  object cdsMeters: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 456
    Top = 264
  end
  object mtMeters: TMemTableEh
    FetchAllOnOpen = True
    Params = <>
    DataDriver = dsdMeters
    Left = 352
    Top = 264
  end
  object dsdMeters: TDataSetDriverEh
    ProviderDataSet = cdsMeters
    Left = 292
    Top = 264
  end
end
