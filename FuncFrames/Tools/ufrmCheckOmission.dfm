object frmCheckOmission: TfrmCheckOmission
  Left = 0
  Top = 0
  Caption = #28431#27979#26816#26597
  ClientHeight = 546
  ClientWidth = 793
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 793
    Height = 69
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 4
    Padding.Top = 5
    Padding.Right = 4
    Padding.Bottom = 4
    TabOrder = 0
    object grpCheckSetup: TGroupBox
      Left = 4
      Top = 5
      Width = 149
      Height = 60
      Align = alLeft
      Caption = #26816#26597#35774#32622
      TabOrder = 0
      object edtPeriod: TLabeledEdit
        Left = 84
        Top = 23
        Width = 41
        Height = 21
        Alignment = taCenter
        EditLabel.Width = 68
        EditLabel.Height = 13
        EditLabel.Caption = #35266#27979#21608#26399'('#22825')'
        ImeMode = imDisable
        LabelPosition = lpLeft
        NumbersOnly = True
        TabOrder = 0
        Text = '7'
      end
    end
  end
  object Panel2: TPanel
    Left = 657
    Top = 69
    Width = 136
    Height = 460
    Align = alRight
    BevelOuter = bvLowered
    TabOrder = 1
    object btnDoCheck: TButton
      Left = 16
      Top = 12
      Width = 109
      Height = 25
      Caption = #26816#26597
      TabOrder = 0
      OnClick = btnDoCheckClick
    end
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 529
    Width = 793
    Height = 17
    Align = alBottom
    TabOrder = 2
    Visible = False
  end
  object dbgOmission: TDBGridEh
    Left = 0
    Top = 69
    Width = 657
    Height = 460
    Align = alClient
    AllowedOperations = [alopInsertEh, alopUpdateEh, alopAppendEh]
    AutoFitColWidths = True
    ColumnDefValues.Title.TitleButton = True
    DataGrouping.GroupLevels = <
      item
      end
      item
      end>
    DataGrouping.GroupPanelVisible = True
    DataSource = DataSource1
    DynProps = <>
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    IndicatorOptions = [gioShowRowIndicatorEh, gioShowRecNoEh]
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghAutoSortMarking, dghMultiSortMarking, dghRowHighlight, dghDialogFind, dghShowRecNo, dghColumnResize, dghColumnMove, dghHotTrack, dghExtendVertLines]
    ParentFont = False
    PopupMenu = popOmission
    SortLocal = True
    STFilter.Local = True
    STFilter.Visible = True
    TabOrder = 3
    TitleParams.SortMarkerStyle = smstDefaultEh
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object MemTableEh1: TMemTableEh
    Params = <>
    DataDriver = DataSetDriverEh1
    Left = 392
    Top = 280
  end
  object DataSetDriverEh1: TDataSetDriverEh
    ProviderDataSet = cdsOmission
    Left = 392
    Top = 340
  end
  object DataSource1: TDataSource
    DataSet = MemTableEh1
    Left = 476
    Top = 280
  end
  object cdsOmission: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 476
    Top = 340
    object cdsOmissionDesignName: TStringField
      DisplayLabel = #35774#35745#32534#21495
      FieldName = 'DesignName'
    end
    object cdsOmissionMeterType: TStringField
      DisplayLabel = #20202#22120#31867#22411
      FieldName = 'MeterType'
    end
    object cdsOmissionPosition: TStringField
      DisplayLabel = #24037#31243#37096#20301
      FieldName = 'Position'
    end
    object cdsOmissionOmissionDays: TIntegerField
      DisplayLabel = #28431#27979#22825#25968
      FieldName = 'OmissionDays'
    end
    object cdsOmissionLastDT: TDateField
      DisplayLabel = #26368#21518#35266#27979#26085#26399
      FieldName = 'LastDT'
    end
  end
  object popOmission: TPopupMenu
    Left = 340
    Top = 212
    object piPopupGraph: TMenuItem
      Caption = #26174#31034#36807#31243#32447
      OnClick = piPopupGraphClick
    end
    object piPopupDataGrid: TMenuItem
      Caption = #26174#31034#25968#25454#34920
      OnClick = piPopupDataGridClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object piCopy: TMenuItem
      Caption = #25335#36125#26597#35810#32467#26524
      OnClick = piCopyClick
    end
  end
end
