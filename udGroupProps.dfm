inherited dGroupProps: TdGroupProps
  ActiveControl = eText
  Caption = 'Properties: Picture group'
  PixelsPerInch = 96
  TextHeight = 13
  object lID: TLabel [1]
    Left = 12
    Top = 12
    Width = 15
    Height = 13
    Caption = '&ID:'
    FocusControl = eID
  end
  object lText: TLabel [2]
    Left = 76
    Top = 12
    Width = 26
    Height = 13
    Caption = '&Text:'
    FocusControl = eText
  end
  object lDesc: TLabel [3]
    Left = 12
    Top = 52
    Width = 57
    Height = 13
    Caption = '&Description:'
    FocusControl = mDescription
  end
  inherited pButtonsBottom: TPanel
    TabOrder = 3
    inherited bCancel: TButton
      TabOrder = 1
    end
    inherited bOK: TButton
      TabOrder = 0
    end
  end
  object eID: TEdit
    Left = 12
    Top = 28
    Width = 61
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 0
  end
  object eText: TEdit
    Left = 76
    Top = 28
    Width = 542
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    OnChange = DlgDataChange
  end
  object mDescription: TMemo
    Left = 12
    Top = 68
    Width = 606
    Height = 315
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 2
    OnChange = DlgDataChange
  end
  object dklcMain: TDKLanguageController
    IgnoreList.Strings = (
      '*.Font.Name'
      '*.SecondaryShortCuts')
    Left = 4
    Top = 404
    LangData = {
      0B006447726F757050726F7073010100000003000000070043617074696F6E01
      0B00000008006276426F74746F6D00000E0070427574746F6E73426F74746F6D
      000007006243616E63656C01010000000C000000070043617074696F6E000300
      624F4B01010000000F000000070043617074696F6E0005006248656C70010100
      000012000000070043617074696F6E0003006C49440101000000150000000700
      43617074696F6E0005006C54657874010100000018000000070043617074696F
      6E0005006C4465736301010000001B000000070043617074696F6E0003006549
      4400000500655465787400000C006D4465736372697074696F6E0000}
  end
end
