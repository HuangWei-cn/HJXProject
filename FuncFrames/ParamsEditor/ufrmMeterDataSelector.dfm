object frmMeterDataFileSelection: TfrmMeterDataFileSelection
  Left = 0
  Top = 0
  Caption = #30417#27979#20202#22120#25968#25454#25991#20214
  ClientHeight = 605
  ClientWidth = 796
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 796
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    Color = clMaroon
    ParentBackground = False
    TabOrder = 0
    object lblWorkbook: TLabel
      Left = 17
      Top = 16
      Width = 517
      Height = 35
      AutoSize = False
      Caption = 'Workbook filename'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -14
      Font.Name = #26032#23435#20307
      Font.Style = []
      GlowSize = 3
      ParentFont = False
      WordWrap = True
    end
    object btnOK: TButton
      Left = 540
      Top = 7
      Width = 113
      Height = 45
      Caption = #30830#23450
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -14
      Font.Name = #26032#23435#20307
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 664
      Top = 7
      Width = 113
      Height = 45
      Caption = #21462#28040
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -14
      Font.Name = #26032#23435#20307
      Font.Style = []
      ModalResult = 2
      ParentFont = False
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 57
    Width = 229
    Height = 548
    Align = alLeft
    BevelOuter = bvNone
    Color = 22704
    ParentBackground = False
    TabOrder = 1
    object Label1: TLabel
      Left = 7
      Top = 169
      Width = 36
      Height = 13
      Caption = #35266#27979#37327
    end
    object Label2: TLabel
      Left = 7
      Top = 235
      Width = 36
      Height = 13
      Caption = #29289#29702#37327
    end
    object Label3: TLabel
      Left = 7
      Top = 301
      Width = 48
      Height = 13
      Caption = #29305#24449#20540#39033
    end
    object GroupBox2: TGroupBox
      Left = 0
      Top = 0
      Width = 229
      Height = 155
      Align = alTop
      Caption = #24037#20316#34920'(Worksheet)'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -14
      Font.Name = #26032#23435#20307
      Font.Style = []
      Padding.Left = 5
      Padding.Top = 5
      Padding.Right = 5
      Padding.Bottom = 5
      ParentFont = False
      TabOrder = 0
      object lstWorksheets: TListBox
        Left = 7
        Top = 21
        Width = 215
        Height = 127
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -14
        Font.Name = #26032#23435#20307
        Font.Style = []
        ItemHeight = 14
        ParentFont = False
        TabOrder = 0
        OnClick = lstWorksheetsClick
        OnDblClick = lstWorksheetsDblClick
      end
    end
    object aleMItems: TAdvListEditor
      Left = 7
      Top = 188
      Width = 210
      Height = 22
      AllowMoving = True
      Appearance.Normal.ColorFrom = 16312028
      Appearance.Normal.ColorTo = 15847357
      Appearance.Normal.BorderColor = 14124408
      Appearance.Selected.ColorFrom = 15115123
      Appearance.Selected.ColorTo = 14183971
      Appearance.Selected.BorderColor = 14183971
      Appearance.Selected.TextColor = clWhite
      Caption = #35266#27979#20540#39033#21015#34920
      Color = clWhite
      EditOffset = -2
      Lookup = <>
      LookupPopup.Font.Charset = DEFAULT_CHARSET
      LookupPopup.Font.Color = clWindowText
      LookupPopup.Font.Height = -11
      LookupPopup.Font.Name = 'Arial'
      LookupPopup.Font.Style = []
      Separator = ';'
      ShowHint = True
      TabOrder = 1
      Values = <
        item
          DisplayText = #27169#25968
          Value = '5'
        end
        item
          DisplayText = #28201#24230
          Value = '6'
        end>
      Version = '1.4.0.1'
      OnValueEditStart = aleMItemsValueEditStart
      OnValueEditDone = aleMItemsValueEditDone
      OnValueHint = aleMItemsValueHint
    end
    object alePItems: TAdvListEditor
      Left = 7
      Top = 254
      Width = 210
      Height = 22
      Appearance.Normal.ColorFrom = 16312028
      Appearance.Normal.ColorTo = 15847357
      Appearance.Normal.BorderColor = 14124408
      Appearance.Selected.ColorFrom = 15115123
      Appearance.Selected.ColorTo = 14183971
      Appearance.Selected.BorderColor = 14183971
      Appearance.Selected.TextColor = clWhite
      Caption = ''
      Color = clWhite
      EditOffset = -2
      Lookup = <>
      LookupPopup.Font.Charset = DEFAULT_CHARSET
      LookupPopup.Font.Color = clWindowText
      LookupPopup.Font.Height = -11
      LookupPopup.Font.Name = 'Arial'
      LookupPopup.Font.Style = []
      Separator = ';'
      ShowHint = True
      TabOrder = 2
      Values = <
        item
          DisplayText = #25289#21147'(kN)'
          Value = '7'
        end
        item
          DisplayText = #28201#24230'('#8451')'
          Value = '6'
        end>
      Version = '1.4.0.1'
      OnValueEditStart = aleMItemsValueEditStart
      OnValueEditDone = aleMItemsValueEditDone
      OnValueHint = alePItemsValueHint
    end
    object aleEItems: TAdvListEditor
      Left = 7
      Top = 320
      Width = 210
      Height = 22
      Appearance.Normal.ColorFrom = 16312028
      Appearance.Normal.ColorTo = 15847357
      Appearance.Normal.BorderColor = 14124408
      Appearance.Selected.ColorFrom = 15115123
      Appearance.Selected.ColorTo = 14183971
      Appearance.Selected.BorderColor = 14183971
      Appearance.Selected.TextColor = clWhite
      Caption = ''
      Color = clWhite
      EditOffset = -2
      Lookup = <>
      LookupPopup.Font.Charset = DEFAULT_CHARSET
      LookupPopup.Font.Color = clWindowText
      LookupPopup.Font.Height = -11
      LookupPopup.Font.Name = 'Arial'
      LookupPopup.Font.Style = []
      Separator = ';'
      ShowHint = True
      TabOrder = 3
      Values = <
        item
          DisplayText = #25289#21147
          Value = '7'
        end>
      Version = '1.4.0.1'
      OnValueEditStart = aleMItemsValueEditStart
      OnValueEditDone = aleMItemsValueEditDone
      OnValueHint = aleEItemsValueHint
    end
    object edtDTRow: TLabeledEdit
      Left = 7
      Top = 384
      Width = 50
      Height = 21
      EditLabel.Width = 36
      EditLabel.Height = 13
      EditLabel.Caption = #26085#26399#34892
      TabOrder = 4
      Text = ''
    end
    object edtDTCol: TLabeledEdit
      Left = 71
      Top = 384
      Width = 50
      Height = 21
      EditLabel.Width = 60
      EditLabel.Height = 13
      EditLabel.Caption = #26085#26399#36215#22987#21015
      TabOrder = 5
      Text = ''
    end
    object edtIVRow: TLabeledEdit
      Left = 7
      Top = 428
      Width = 50
      Height = 21
      EditLabel.Width = 36
      EditLabel.Height = 13
      EditLabel.Caption = #21021#20540#34892
      TabOrder = 6
      Text = ''
    end
    object edtAnCol: TLabeledEdit
      Left = 71
      Top = 428
      Width = 50
      Height = 21
      EditLabel.Width = 36
      EditLabel.Height = 13
      EditLabel.Caption = #22791#27880#21015
      TabOrder = 7
      Text = ''
    end
    object AdvListEditor1: TAdvListEditor
      Left = 7
      Top = 480
      Width = 250
      Height = 22
      Appearance.Normal.ColorFrom = 16312028
      Appearance.Normal.ColorTo = 15847357
      Appearance.Normal.BorderColor = 14124408
      Appearance.Selected.ColorFrom = 15115123
      Appearance.Selected.ColorTo = 14183971
      Appearance.Selected.BorderColor = 14183971
      Appearance.Selected.TextColor = clWhite
      Caption = ''
      Color = clWhite
      EditOffset = -2
      Lookup = <>
      LookupPopup.Font.Charset = DEFAULT_CHARSET
      LookupPopup.Font.Color = clWindowText
      LookupPopup.Font.Height = -11
      LookupPopup.Font.Name = 'Arial'
      LookupPopup.Font.Style = []
      Separator = ';'
      TabOrder = 8
      Values = <
        item
          DisplayText = 'Value 1'
        end>
      Version = '1.4.0.1'
    end
  end
  object Panel3: TPanel
    Left = 229
    Top = 57
    Width = 567
    Height = 548
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel3'
    TabOrder = 2
    object grdSheet: TStringGrid
      Left = 0
      Top = 33
      Width = 567
      Height = 515
      Align = alClient
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #23435#20307
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goFixedColClick, goFixedRowClick]
      ParentColor = True
      ParentFont = False
      PopupMenu = pmSetDS
      TabOrder = 0
      ColWidths = (
        64
        64
        64
        64
        64)
      RowHeights = (
        24
        24
        24
        24
        24)
    end
    object pnlSheetName: TPanel
      Left = 0
      Top = 0
      Width = 567
      Height = 33
      Align = alTop
      Caption = 'Worksheet Name: XXX'
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = #40657#20307
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object pmSetDS: TPopupMenu
    Left = 436
    Top = 300
    object piAddMD: TMenuItem
      Action = actAddMD
    end
    object piAddPD: TMenuItem
      Action = actAddPD
    end
    object piAddED: TMenuItem
      Action = actAddED
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object piSetDTRowCol: TMenuItem
      Action = actSetDTRowCol
    end
    object piSetIVRow: TMenuItem
      Action = actSetIVRow
    end
    object piSetAnCol: TMenuItem
      Action = actSetAnCol
    end
  end
  object ActionList1: TActionList
    Left = 561
    Top = 321
    object actAddMD: TAction
      Caption = #28155#21152#35266#27979#37327
      OnExecute = actAddMDExecute
    end
    object actAddPD: TAction
      Caption = #28155#21152#29289#29702#37327
      OnExecute = actAddPDExecute
    end
    object actAddED: TAction
      Caption = #28155#21152#29305#24449#20540#39033
      OnExecute = actAddEDExecute
    end
    object actSetDTRowCol: TAction
      Caption = #35774#32622#20026#26085#26399#36215#22987#34892#21015
      OnExecute = actSetDTRowColExecute
    end
    object actSetIVRow: TAction
      Caption = #35774#32622#21021#20540#34892
      OnExecute = actSetIVRowExecute
    end
    object actSetAnCol: TAction
      Caption = #35774#32622#22791#27880#21015
      OnExecute = actSetAnColExecute
    end
  end
end
