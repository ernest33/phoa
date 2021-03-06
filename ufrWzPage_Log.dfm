inherited frWzPage_Log: TfrWzPage_Log
  object tvMain: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 576
    Height = 252
    Align = alClient
    Header.AutoSizeIndex = 1
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'MS Shell Dlg 2'
    Header.Font.Style = []
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs]
    Header.ParentFont = True
    Images = fMain.ilActionsSmall
    PopupMenu = pmMain
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoTristateTracking, toAutoDeleteMovedNodes, toDisableAutoscrollOnFocus]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect]
    OnBeforeItemErase = tvMainBeforeItemErase
    OnGetText = tvMainGetText
    OnGetImageIndex = tvMainGetImageIndex
    Columns = <
      item
        Alignment = taRightJustify
        Color = 16250871
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coResizable, coShowDropMark, coVisible]
        Position = 0
      end
      item
        Position = 1
        Width = 522
      end>
  end
  object pBottom: TTntPanel
    Left = 0
    Top = 252
    Width = 576
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      576
      32)
    object lInfo: TTntLabel
      Left = 200
      Top = 4
      Width = 221
      Height = 24
      Alignment = taCenter
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      Caption = '...'
      Layout = tlCenter
    end
    object cbErrorsOnly: TTntCheckBox
      Left = 8
      Top = 8
      Width = 181
      Height = 17
      Action = aDisplayErrorsOnly
      TabOrder = 0
    end
    object bSaveToFile: TTntButton
      Left = 426
      Top = 4
      Width = 143
      Height = 23
      Action = aSaveToFile
      Anchors = [akTop, akRight]
      TabOrder = 1
    end
  end
  object pmMain: TTBXPopupMenu
    Images = fMain.ilActionsSmall
    Left = 48
    Top = 8
    object ipmCopy: TTBXItem
      Action = aCopy
    end
    object ipmSep: TTBXSeparatorItem
    end
    object ipmDisplayErrorsOnly: TTBXItem
      Action = aDisplayErrorsOnly
    end
    object ipmSep2: TTBXSeparatorItem
    end
    object ipmSaveToFile: TTBXItem
      Action = aSaveToFile
    end
    object ipmFind: TTBXItem
      Action = aFind
    end
  end
  object alMain: TTntActionList
    Images = fMain.ilActionsSmall
    Left = 8
    Top = 8
    object aCopy: TTntAction
      Caption = '&Copy'
      Hint = 'Copy|Copy current record to clipboard'
      ImageIndex = 21
      ShortCut = 16451
      OnExecute = aaCopy
    end
    object aFind: TTntAction
      Caption = '&Find...'
      Hint = 'Find...|Show Find Text dialog'
      ImageIndex = 9
      ShortCut = 114
      OnExecute = aaFind
    end
    object aSaveToFile: TTntAction
      Caption = '&Save to file...'
      Hint = 'Save to file...|Save the log to a selected file'
      ImageIndex = 3
      ShortCut = 16467
      OnExecute = aaSaveToFile
    end
    object aDisplayErrorsOnly: TTntAction
      AutoCheck = True
      Caption = '&Display errors only'
      Hint = 'Display errors only|Hide successfully added picture entries'
      OnExecute = aaDisplayErrorsOnly
    end
  end
  object fdMain: TFindDialog
    Options = [frDown, frHideWholeWord]
    OnFind = fdMainFind
    Left = 88
    Top = 8
  end
  object dklcMain: TDKLanguageController
    IgnoreList.Strings = (
      '*.Font.Name'
      '*.SecondaryShortCuts'
      'lInfo.Caption')
    Left = 128
    Top = 8
    LangData = {
      0C006672577A506167655F4C6F670001120000000600616C4D61696E00000500
      61436F707901020000007A000000070043617074696F6E7C000000040048696E
      740005006146696E640102000000A6000000070043617074696F6EA800000004
      0048696E7400060074764D61696E0000070070426F74746F6D000005006C496E
      666F00000C0063624572726F72734F6E6C7900000B006253617665546F46696C
      6500000600706D4D61696E0000070069706D436F70790000060069706D536570
      0000140069706D446973706C61794572726F72734F6E6C790000070069706D53
      65703200000D0069706D53617665546F46696C650000070069706D46696E6400
      000B006153617665546F46696C650102000000B7000000070043617074696F6E
      B9000000040048696E7400120061446973706C61794572726F72734F6E6C7901
      02000000BB000000070043617074696F6EBD000000040048696E740006006664
      4D61696E0000}
  end
end
