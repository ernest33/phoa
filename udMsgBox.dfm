object dMsgBox: TdMsgBox
  Left = 491
  Top = 465
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = '<>'
  ClientHeight = 83
  ClientWidth = 312
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = True
  Position = poMainFormCenter
  DesignSize = (
    312
    83)
  PixelsPerInch = 96
  TextHeight = 13
  object iIcon: TImage
    Left = 11
    Top = 11
    Width = 32
    Height = 32
  end
  object lMessage: TLabel
    Left = 60
    Top = 20
    Width = 16
    Height = 13
    AutoSize = False
    Caption = '<>'
    WordWrap = True
  end
  object cbDontShowAgain: TCheckBox
    Left = 11
    Top = 54
    Width = 277
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Don'#39't &show this message again'
    TabOrder = 0
  end
  object dtlsMain: TDTLanguageSwitcher
    Language = 1033
    Left = 280
    Top = 4
    LangData = {
      0700644D7367426F7804000000070043617074696F6E02000000090402003C3E
      190402003C3E080048656C7046696C650200000009040000190400000B004865
      6C704B6579776F7264020000000904000019040000040048696E740200000009
      04000019040000000000000600000008006276426F74746F6D020000000B0048
      656C704B6579776F7264020000000904000019040000040048696E7402000000
      090400001904000000000000000000000F006362446F6E7453686F7741676169
      6E03000000070043617074696F6E0200000009041E00446F6E2774202673686F
      772074686973206D65737361676520616761696E19042600C1EEEBFCF8E520ED
      E52026EFEEEAE0E7FBE2E0F2FC20E4E0EDEDEEE520F1EEEEE1F9E5EDE8E50B00
      48656C704B6579776F7264020000000904000019040000040048696E74020000
      0009040000190400000000000000000000080064746C734D61696E0000000000
      0000000000000005006949636F6E020000000B0048656C704B6579776F726402
      0000000904000019040000040048696E74020000000904000019040000000000
      000000000008006C4D65737361676503000000070043617074696F6E02000000
      090402003C3E190402003C3E0B0048656C704B6579776F726402000000090400
      0019040000040048696E7402000000090400001904000000000000000000000E
      0070427574746F6E73426F74746F6D03000000070043617074696F6E02000000
      09040000190400000B0048656C704B6579776F72640200000009040000190400
      00040048696E740200000009040000190400000000000000000000}
  end
end
