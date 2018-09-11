object fraHJXDataGrid: TfraHJXDataGrid
  Left = 0
  Top = 0
  Width = 512
  Height = 376
  Padding.Left = 3
  Padding.Top = 3
  Padding.Right = 3
  Padding.Bottom = 3
  TabOrder = 0
  object DBGridEh1: TDBGridEh
    Left = 3
    Top = 3
    Width = 506
    Height = 370
    Align = alClient
    AllowedOperations = []
    DataSource = DataSource1
    DynProps = <>
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    FooterRowCount = 2
    FooterParams.FillStyle = cfstGradientEh
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghAutoSortMarking, dghMultiSortMarking, dghDblClickOptimizeColWidth, dghDialogFind, dghColumnResize, dghColumnMove, dghExtendVertLines]
    ParentFont = False
    PopupMenu = popDataGrid
    ReadOnly = True
    SortLocal = True
    STFilter.Local = True
    STFilter.Visible = True
    TabOrder = 0
    TitleParams.FillStyle = cfstThemedEh
    TitleParams.MultiTitle = True
    TitleParams.SortMarkerStyle = smstThemeDefinedEh
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object cdsMeterDatas: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 424
    Top = 288
  end
  object MemTableEh1: TMemTableEh
    FetchAllOnOpen = True
    Params = <>
    DataDriver = DataSetDriverEh1
    Left = 252
    Top = 288
  end
  object DataSetDriverEh1: TDataSetDriverEh
    ProviderDataSet = cdsMeterDatas
    Left = 340
    Top = 288
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 172
    Top = 288
  end
  object popDataGrid: TPopupMenu
    Left = 392
    Top = 232
    object N1: TMenuItem
      Caption = #25335#36125#20026#8230#8230
      object piCopyToCliboardAsHTML: TMenuItem
        Caption = #25335#36125#25968#25454#34920#20026'HTML'#26684#24335
        OnClick = piCopyToCliboardAsHTMLClick
      end
      object piCopyToClipboard: TMenuItem
        Caption = #25335#36125#20026#20854#20182#26684#24335
        OnClick = piCopyToClipboardClick
      end
    end
    object N3: TMenuItem
      Caption = #21478#23384#20026#8230#8230
      object piSaveAsHTML: TMenuItem
        Caption = 'HTML'#26684#24335
        OnClick = piSaveAsHTMLClick
      end
      object piSaveAsTEXT: TMenuItem
        Caption = #25991#26412#26684#24335
        OnClick = piSaveAsTEXTClick
      end
      object piSaveAsRTF: TMenuItem
        Caption = 'RTF'#26684#24335
        OnClick = piSaveAsRTFClick
      end
      object piSaveAsXLSX: TMenuItem
        Caption = 'Excel 2007~2010'#26684#24335
        OnClick = piSaveAsXLSXClick
      end
      object piSaveAsXLS: TMenuItem
        Caption = 'Excel97~2003'#26684#24335
        OnClick = piSaveAsXLSClick
      end
    end
  end
  object dlgSave: TSaveDialog
    Left = 336
    Top = 232
  end
end
