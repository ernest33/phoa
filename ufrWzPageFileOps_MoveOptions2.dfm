inherited frWzPageFileOps_MoveOptions2: TfrWzPageFileOps_MoveOptions2
  DesignSize = (
    576
    284)
  object lOverwriteMode: TLabel
    Left = 4
    Top = 92
    Width = 151
    Height = 13
    Caption = 'If the target file already e&xists:'
    FocusControl = cbOverwriteMode
  end
  object lNoOriginalFileMode: TLabel
    Left = 4
    Top = 4
    Width = 156
    Height = 13
    Caption = 'If the &original file does not exist:'
    FocusControl = cbNoOriginalFileMode
  end
  object cbDeleteOriginal: TCheckBox
    Left = 4
    Top = 48
    Width = 567
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = '&Delete original files'
    TabOrder = 1
    OnClick = AdjustOptionsNotify
  end
  object cbDeleteToRecycleBin: TCheckBox
    Left = 24
    Top = 68
    Width = 547
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Delete to the rec&ycle bin'
    TabOrder = 2
    OnClick = PageDataChange
  end
  object cbUseCDOptions: TCheckBox
    Left = 4
    Top = 264
    Width = 567
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Set up &CD/DVD creation options as well'
    TabOrder = 4
    OnClick = PageDataChange
  end
  object cbOverwriteMode: TComboBox
    Left = 4
    Top = 108
    Width = 567
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 3
    Items.Strings = (
      'Skip the current picture'
      'Prompt to overwrite the file'
      'Always overwrite the file')
  end
  object cbNoOriginalFileMode: TComboBox
    Left = 4
    Top = 20
    Width = 567
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    Items.Strings = (
      'Treat as an error'
      'Update the link only if the target file exists'
      'Update the link anyway')
  end
  object dtlsMain: TDTLanguageSwitcher
    Language = 1033
    Left = 540
    Top = 140
    LangData = {
      1C006672577A5061676546696C654F70735F4D6F76654F7074696F6E73320200
      00000B0048656C704B6579776F7264020000000904000019040000040048696E
      7402000000090400001904000000000000080000001000636244656C6574654F
      726967696E616C03000000070043617074696F6E02000000090416002644656C
      657465206F726967696E616C2066696C65731904170026D3E4E0EBFFF2FC20E8
      F1F5EEE4EDFBE520F4E0E9EBFB0B0048656C704B6579776F7264020000000904
      000019040000040048696E740200000009040000190400000000000000000000
      1400636244656C657465546F52656379636C6542696E03000000070043617074
      696F6E0200000009041A0044656C65746520746F20746865207265632679636C
      652062696E19041200D3E4E0EB26FFF2FC20E220CAEEF0E7E8EDF30B0048656C
      704B6579776F7264020000000904000019040000040048696E74020000000904
      0000190400000000000000000000140063624E6F4F726967696E616C46696C65
      4D6F6465050000000B0048656C704B6579776F72640100000009040000040048
      696E7401000000090400000700496D654E616D65010000000904000005004974
      656D730200000009045B00547265617420617320616E206572726F720D0A5570
      6461746520746865206C696E6B206F6E6C792069662074686520746172676574
      2066696C65206578697374730D0A55706461746520746865206C696E6B20616E
      797761790D0A19046900D1F7E8F2E0F2FC20EEF8E8E1EAEEE90D0ACEE1EDEEE2
      E8F2FC20F1F1FBEBEAF320F2EEEBFCEAEE20E5F1EBE820F4E0E9EB20EDE0E7ED
      E0F7E5EDE8FF20F1F3F9E5F1F2E2F3E5F20D0ACEE1EDEEE2E8F2FC20F1F1FBEB
      EAF320E220EBFEE1EEEC20F1EBF3F7E0E50D0A04005465787401000000090400
      0000000000000000000F0063624F76657277726974654D6F6465050000000B00
      48656C704B6579776F72640100000009040000040048696E7401000000090400
      000700496D654E616D65010000000904000005004974656D7302000000090453
      00536B6970207468652063757272656E7420706963747572650D0A50726F6D70
      7420746F206F7665727772697465207468652066696C650D0A416C7761797320
      6F7665727772697465207468652066696C650D0A19045F00CFF0EEEFF3F1EAE0
      F2FC20F2E5EAF3F9E5E520E8E7EEE1F0E0E6E5EDE8E50D0AC2FBE4E0F2FC20E7
      E0EFF0EEF120EDE020EFE5F0E5E7E0EFE8F1FC20F4E0E9EBE00D0AC2F1E5E3E4
      E020EFE5F0E5E7E0EFE8F1FBE2E0F2FC20F4E0E9EB0D0A040054657874010000
      000904000000000000000000000E00636255736543444F7074696F6E73030000
      00070043617074696F6E0200000009042700536574207570202643442F445644
      206372656174696F6E206F7074696F6E732061732077656C6C19042700CDE0F1
      F2F0EEE8F2FC20F2E0EAE6E520EEEFF6E8E820E7E0EFE8F1E820EDE020432644
      2F4456440B0048656C704B6579776F72640100000009040000040048696E7401
      000000090400000000000000000000080064746C734D61696E00000000000000
      000000000013006C4E6F4F726967696E616C46696C654D6F6465030000000700
      43617074696F6E020000000904250049662074686520266F726967696E616C20
      66696C6520646F6573206E6F742065786973743A1904220026C5F1EBE820E8F1
      F5EEE4EDFBE920F4E0E9EB20EDE520F1F3F9E5F1F2E2F3E5F23A0B0048656C70
      4B6579776F72640100000009040000040048696E740100000009040000000000
      00000000000E006C4F76657277726974654D6F64650300000007004361707469
      6F6E0200000009042300496620746865207461726765742066696C6520616C72
      6561647920652678697374733A19042500C5F1EBE820F4E0E9EB20EDE0E7EDE0
      26F7E5EDE8FF20F3E6E520F1F3F9E5F1F2E2F3E5F23A0B0048656C704B657977
      6F72640100000009040000040048696E74010000000904000000000000000000
      00}
  end
end
