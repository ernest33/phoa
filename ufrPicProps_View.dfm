inherited frPicProps_View: TfrPicProps_View
  Height = 298
  OnMouseWheel = FrameMouseWheel
  object tbMain: TTBXToolbar
    Left = 0
    Top = 0
    Width = 576
    Height = 22
    Align = alTop
    ChevronHint = 'More buttons|'
    Images = fMain.ilActionsSmall
    SystemFont = False
    TabOrder = 1
    object cbViewFile: TTBXComboBoxItem
      EditWidth = 330
      Hint = 'File to view'
      ShowImage = True
      OnChange = cbViewFileChange
      DropDownList = True
      MinListWidth = 330
      ShowListImages = True
      OnAdjustImageIndex = cbViewFileAdjustImageIndex
    end
    object bViewZoomIn: TTBXItem
      Action = aZoomIn
      DisplayMode = nbdmImageAndText
    end
    object bViewZoomOut: TTBXItem
      Action = aZoomOut
      DisplayMode = nbdmImageAndText
    end
    object bViewZoomActual: TTBXItem
      Action = aZoomActual
      DisplayMode = nbdmImageAndText
    end
    object bViewZoomFit: TTBXItem
      Action = aZoomFit
      DisplayMode = nbdmImageAndText
    end
  end
  object iMain: TImage32
    Left = 0
    Top = 22
    Width = 576
    Height = 276
    Align = alClient
    BitmapAlign = baCustom
    PopupMenu = pmMain
    Scale = 1.000000000000000000
    ScaleMode = smScale
    TabOrder = 0
    TabStop = True
    OnMouseDown = iMainMouseDown
    OnMouseMove = iMainMouseMove
    OnMouseUp = iMainMouseUp
    OnResize = iMainResize
  end
  object alMain: TActionList
    Images = fMain.ilActionsSmall
    Left = 8
    Top = 308
    object aZoomIn: TAction
      Caption = 'Zoom &in'
      Hint = 'Zoom in|Enlarge the image'
      ImageIndex = 25
      OnExecute = aaZoomIn
    end
    object aZoomOut: TAction
      Caption = 'Zoom ou&t'
      Hint = 'Zoom out|Zoom image out'
      ImageIndex = 26
      OnExecute = aaZoomOut
    end
    object aZoomActual: TAction
      Caption = 'Zoom &actual'
      Hint = 'Set zoom to 1:1'
      ImageIndex = 28
      OnExecute = aaZoomActual
    end
    object aZoomFit: TAction
      Caption = '&Fit window'
      Hint = 'Set zoom to fit window'
      ImageIndex = 27
      OnExecute = aaZoomFit
    end
  end
  object pmMain: TTBXPopupMenu
    Images = fMain.ilActionsSmall
    Left = 36
    Top = 308
  end
  object dtlsMain: TDTLanguageSwitcher
    Language = 1033
    Left = 8
    Top = 252
    LangData = {
      0F00667250696350726F70735F56696577020000000B0048656C704B6579776F
      7264050000001904000009040000070400001604000022040000040048696E74
      050000001904000009040000070400001604000022040000000000000E000000
      0600616C4D61696E0000000000000000000000000B00615A6F6F6D4163747561
      6C05000000070043617074696F6E0500000019040C00CC26E0F1F8F2E0E12031
      3A3109040C005A6F6F6D202661637475616C070413002654617473E463686C69
      63686572205A6F6F6D16040D0054616D616E686F20526526616C22040C00CC26
      E0F1F8F2E0E120313A31080043617465676F7279050000001904000009040000
      0704000016040000220400000B0048656C704B6579776F726405000000190400
      0009040000070400001604000022040000040048696E740500000019041600D3
      F1F2E0EDEEE2E8F2FC20ECE0F1F8F2E0E120313A3109040F00536574207A6F6F
      6D20746F20313A31070414005A6F6F6D2061756620313A31207374656C6C656E
      16041000416A7573746172207A6F6F6D20313A3122041600C2F1F2E0EDEEE2E8
      F2E820ECE0F1F8F2E0E120313A3112005365636F6E6461727953686F72744375
      7473050000001904000009040000070400001604000022040000000000000000
      00000800615A6F6F6D46697405000000070043617074696F6E0500000019040E
      0026C220F0E0E7ECE5F020EEEAEDE009040B00264669742077696E646F770704
      150044656D202646656E7374657220616E70617373656E16040F00264D656C68
      6F722074616D616E686F22040F0026D320F0EEE7ECB3F020E2B3EAEDE0080043
      617465676F72790500000019040000090400000704000016040000220400000B
      0048656C704B6579776F72640500000019040000090400000704000016040000
      22040000040048696E740500000019042300D3F1F2E0EDEEE2E8F2FC20ECE0F1
      F8F2E0E120EFEE20F0E0E7ECE5F0E0EC20EEEAEDE009041600536574207A6F6F
      6D20746F206669742077696E646F77070420005A6F6F6D206175662046656E73
      7465726772F6DF652065696E7374656C6C656E16042200416A7573746172207A
      6F6F6D2070617261206361626572206E61206A616E656C612022042400C2F1F2
      E0EDEEE2E8F2E820ECE0F1F8F2E0E120EFEE20F0EEE7ECB3F0E0F520E2B3EAED
      E012005365636F6E6461727953686F7274437574730500000019040000090400
      0007040000160400002204000000000000000000000700615A6F6F6D496E0500
      0000070043617074696F6E0500000019040A0026D3E2E5EBE8F7E8F2FC090408
      005A6F6F6D2026696E070408005A6F6F6D2026696E1604080026416D706C6961
      7222040A0026C7E1B3EBFCF8E8F2E8080043617465676F727905000000190400
      00090400000704000016040000220400000B0048656C704B6579776F72640500
      00001904000009040000070400001604000022040000040048696E7405000000
      19041F00D3E2E5EBE8F7E8F2FC7CD3E2E5EBE8F7E8F2FC20E8E7EEE1F0E0E6E5
      EDE8E5090419005A6F6F6D20696E7C456E6C617267652074686520696D616765
      07041B005A6F6F6D20696E7C5665726772F6DF657274206461732042696C6416
      042100416D706C6961727C416D706C6961E7E36F20646120696D6167656D2076
      6973746122041E00C7E1B3EBFCF8E8F2E87CC7E1B3EBFCF8E8F2E820E7EEE1F0
      E0E6E5EDEDFF12005365636F6E6461727953686F727443757473050000001904
      00000904000007040000160400002204000000000000000000000800615A6F6F
      6D4F757405000000070043617074696F6E0500000019040A00D326ECE5EDFCF8
      E8F2FC090409005A6F6F6D206F752674070409005A6F6F6D206F752674160408
      0026526564757A697222040900C726ECE5EDF8E8F2E8080043617465676F7279
      0500000019040000090400000704000016040000220400000B0048656C704B65
      79776F7264050000001904000009040000070400001604000022040000040048
      696E740500000019041F00D3ECE5EDFCF8E8F2FC7CD3ECE5EDFCF8E8F2FC20E8
      E7EEE1F0E0E6E5EDE8E5090417005A6F6F6D206F75747C5A6F6F6D20696D6167
      65206F7574070415005A6F6F6D206F75747C5A6F6F6D74206865726175731604
      1F00526564757A69727C52656475E7E36F20646120696D6167656D2076697374
      6122041C00C7ECE5EDF8E8F2E87CC7ECE5EDF8E8F2E820E7EEE1F0E0E6E5EDED
      FF12005365636F6E6461727953686F7274437574730500000019040000090400
      0007040000160400002204000000000000000000000F0062566965775A6F6F6D
      41637475616C0000000000000000000000000C0062566965775A6F6F6D466974
      0000000000000000000000000B0062566965775A6F6F6D496E00000000000000
      00000000000C0062566965775A6F6F6D4F75740000000000000000000000000A
      0063625669657746696C6505000000070043617074696F6E0500000019040000
      090400000704000016040000220400000B004564697443617074696F6E050000
      001904000009040000070400001604000022040000040048696E740500000019
      041200D4E0E9EB20E4EBFF20EFF0EEF1ECEEF2F0E009040C0046696C6520746F
      207669657707041000416E67657A6569677465732042696C6416041200566973
      75616C697A6172206172717569766F22041200D4E0E9EB20E4EBFF20EFE5F0E5
      E3EBFFE4F30700537472696E6773050000001904000009040000070400001604
      0000220400000400546578740500000019040000090400000704000016040000
      220400000000000000000000080064746C734D61696E00000000000000000000
      00000500694D61696E020000000B0048656C704B6579776F7264050000001904
      000009040000070400001604000022040000040048696E740500000019040000
      0904000007040000160400002204000000000000000000000600706D4D61696E
      000000000000000000000000060074624D61696E03000000070043617074696F
      6E0500000019040000090400000704000016040000220400000B004368657672
      6F6E48696E740500000019040B00C5F9B820EAEDEEEFEAE87C09040D004D6F72
      6520627574746F6E737C070416005765697465726520536368616C74666CE463
      68656E7C16040C004D61697320626F74F565737C22040A00D9E520EAEDEEEFEA
      E87C0B0048656C704B6579776F72640500000019040000090400000704000016
      040000220400000000000000000000}
  end
end
