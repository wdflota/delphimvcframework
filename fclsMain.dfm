object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Generador de Entidades DMVCFramework'
  ClientHeight = 450
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 600
    Height = 250
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblDBType: TLabel
      Left = 24
      Top = 24
      Width = 93
      Height = 15
      Caption = 'Tipo de Base de Datos:'
    end
    object lblHost: TLabel
      Left = 24
      Top = 80
      Width = 51
      Height = 15
      Caption = 'Servidor:'
    end
    object lblDatabase: TLabel
      Left = 320
      Top = 80
      Width = 80
      Height = 15
      Caption = 'Base de Datos:'
    end
    object lblUser: TLabel
      Left = 24
      Top = 136
      Width = 43
      Height = 15
      Caption = 'Usuario:'
    end
    object lblPassword: TLabel
      Left = 320
      Top = 136
      Width = 63
      Height = 15
      Caption = 'Contrase'#241'a:'
    end
    object lblOutputPath: TLabel
      Left = 24
      Top = 192
      Width = 91
      Height = 15
      Caption = 'Carpeta de Salida:'
    end
    object cboDBType: TComboBox
      Left = 24
      Top = 45
      Width = 257
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = 'Firebird'
      Items.Strings = (
        'Firebird'
        'MySQL'
        'PostgreSQL'
        'SQL Server')
    end
    object edtHost: TEdit
      Left = 24
      Top = 101
      Width = 257
      Height = 23
      TabOrder = 1
      Text = 'localhost'
    end
    object edtDatabase: TEdit
      Left = 320
      Top = 101
      Width = 257
      Height = 23
      TabOrder = 2
    end
    object edtUser: TEdit
      Left = 24
      Top = 157
      Width = 257
      Height = 23
      TabOrder = 3
    end
    object edtPassword: TEdit
      Left = 320
      Top = 157
      Width = 257
      Height = 23
      PasswordChar = '*'
      TabOrder = 4
    end
    object edtOutputPath: TEdit
      Left = 24
      Top = 213
      Width = 457
      Height = 23
      TabOrder = 5
    end
    object btnSelectPath: TButton
      Left = 487
      Top = 212
      Width = 90
      Height = 25
      Caption = '...'
      TabOrder = 6
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 384
    Width = 600
    Height = 66
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnGenerate: TButton
      Left = 24
      Top = 16
      Width = 553
      Height = 33
      Caption = 'Generar Entidades'
      TabOrder = 0
    end
  end
  object memLog: TMemo
    Left = 0
    Top = 250
    Width = 600
    Height = 134
    Align = alClient
    Lines.Strings = (
      'Listo para generar entidades...')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
end
