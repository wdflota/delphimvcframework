object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Articles CRUD SAMPLE'
  ClientHeight = 391
  ClientWidth = 876
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 876
    Height = 39
    Align = alTop
    TabOrder = 0
    object DBNavigator1: TDBNavigator
      AlignWithMargins = True
      Left = 585
      Top = 4
      Width = 287
      Height = 31
      DataSource = dsrcArticles
      Align = alRight
      TabOrder = 0
    end
    object btnOpen: TButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 75
      Height = 31
      Align = alLeft
      Caption = 'Open'
      TabOrder = 1
      OnClick = btnOpenClick
    end
    object btnRefreshRecord: TButton
      AlignWithMargins = True
      Left = 166
      Top = 4
      Width = 107
      Height = 31
      Align = alLeft
      Caption = 'Refresh Record'
      TabOrder = 2
      OnClick = btnRefreshRecordClick
    end
    object Button1: TButton
      AlignWithMargins = True
      Left = 85
      Top = 4
      Width = 75
      Height = 31
      Align = alLeft
      Caption = 'Close'
      TabOrder = 3
      OnClick = btnCloseClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 39
    Width = 876
    Height = 202
    Align = alTop
    Caption = 'Panel2'
    TabOrder = 1
    object Grid1: TDBGrid
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 868
      Height = 194
      Align = alClient
      DataSource = dsrcArticles
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'ID'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Code'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Description'
          Width = 200
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Price'
          Width = 74
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Foto'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Observation'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Weight'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'State'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'BirthDate'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'BirthTime'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CreationDate'
          Visible = True
        end>
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 241
    Width = 876
    Height = 150
    Align = alClient
    Caption = 'Panel3'
    TabOrder = 2
    object Splitter1: TSplitter
      Left = 447
      Top = 1
      Width = 7
      Height = 148
      ExplicitLeft = 106
    end
    object ImgFOTO: TDBImage
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 440
      Height = 142
      Align = alLeft
      DataField = 'Foto'
      DataSource = dsrcArticles
      TabOrder = 0
      OnDblClick = ImgFOTODblClick
    end
    object MemoOSSERVAZIONI: TDBMemo
      AlignWithMargins = True
      Left = 457
      Top = 4
      Width = 415
      Height = 142
      Align = alClient
      DataField = 'Observation'
      DataSource = dsrcArticles
      TabOrder = 1
    end
  end
  object dsArticles: TFDMemTable
    AfterOpen = dsArticlesAfterOpen
    BeforePost = dsArticlesBeforePost
    BeforeDelete = dsArticlesBeforeDelete
    BeforeRefresh = dsArticlesBeforeRefresh
    FieldDefs = <>
    IndexDefs = <>
    BeforeRowRequest = dsArticlesBeforeRowRequest
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
    FormatOptions.MaxBcdPrecision = 2147483647
    FormatOptions.MaxBcdScale = 1073741823
    ResourceOptions.AssignedValues = [rvPersistent, rvSilentMode]
    ResourceOptions.Persistent = True
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable]
    UpdateOptions.LockWait = True
    UpdateOptions.FetchGeneratorsPoint = gpNone
    UpdateOptions.CheckRequired = False
    StoreDefs = True
    Left = 136
    Top = 120
    object dsArticlesID: TIntegerField
      DisplayWidth = 10
      FieldName = 'ID'
      Required = True
    end
    object dsArticlesCODICE: TWideStringField
      DisplayWidth = 9
      FieldName = 'Code'
      Required = True
      Size = 5
    end
    object dsArticlesDESCRIZIONE: TWideStringField
      DisplayWidth = 200
      FieldName = 'Description'
      Size = 200
    end
    object dsArticlesPREZZO: TFMTBCDField
      DisplayWidth = 19
      FieldName = 'Price'
      Precision = 18
      Size = 2
    end
    object dsArticlesFOTO: TBlobField
      DisplayWidth = 10
      FieldName = 'Foto'
    end
    object dsArticlesOSSERVAZIONI: TMemoField
      DisplayWidth = 12
      FieldName = 'Observation'
      BlobType = ftMemo
    end
    object dsArticlesPeso: TCurrencyField
      FieldName = 'Weight'
    end
    object dsArticlesState: TBooleanField
      FieldName = 'State'
    end
    object dsArticlesBirthDate: TDateField
      FieldName = 'BirthDate'
    end
    object dsArticlesBirthTime: TTimeField
      FieldName = 'BirthTime'
    end
    object dsArticlesCreationDate: TDateTimeField
      FieldName = 'CreationDate'
    end
  end
  object dsrcArticles: TDataSource
    DataSet = dsArticles
    Left = 136
    Top = 184
  end
  object ConIB: TFDConnection
    Params.Strings = (
      
        'Database=C:\Program Files (x86)\Embarcadero\Studio\20.0\lib\Otro' +
        's\MVCFramework\samples\data\ORDERSMANAGER_FB25NullTypes.FDB'
      'User_Name=sysdba'
      'Password=masterkey'
      'Server=tar-dsk00'
      'DriverID=FB')
    LoginPrompt = False
    Left = 432
    Top = 200
  end
  object QryArticles: TFDQuery
    Connection = ConIB
    SQL.Strings = (
      'Select * From Articoli')
    Left = 496
    Top = 200
    object QryArticlesID: TIntegerField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object QryArticlesCODICE: TWideStringField
      FieldName = 'CODICE'
      Origin = 'CODICE'
      Required = True
      Size = 5
    end
    object QryArticlesDESCRIZIONE: TWideStringField
      FieldName = 'DESCRIZIONE'
      Origin = 'DESCRIZIONE'
      Size = 200
    end
    object QryArticlesPREZZO: TFMTBCDField
      FieldName = 'PREZZO'
      Origin = 'PREZZO'
      Precision = 18
      Size = 2
    end
    object QryArticlesFOTO: TBlobField
      FieldName = 'FOTO'
      Origin = 'FOTO'
    end
    object QryArticlesOSSERVAZIONI: TMemoField
      FieldName = 'OSSERVAZIONI'
      Origin = 'OSSERVAZIONI'
      BlobType = ftMemo
    end
    object QryArticlesPESO: TCurrencyField
      FieldName = 'PESO'
      Origin = 'PESO'
    end
    object QryArticlesSTATO: TSmallintField
      FieldName = 'STATO'
      Origin = 'STATO'
    end
    object QryArticlesDATADINASCITA: TDateField
      FieldName = 'DATADINASCITA'
      Origin = 'DATADINASCITA'
    end
    object QryArticlesTEMPODINASCITA: TTimeField
      FieldName = 'TEMPODINASCITA'
      Origin = 'TEMPODINASCITA'
    end
    object QryArticlesDATADICREAZIONE: TSQLTimeStampField
      FieldName = 'DATADICREAZIONE'
      Origin = 'DATADICREAZIONE'
    end
  end
  object OpenDialog: TOpenDialog
    Left = 136
    Top = 256
  end
end
