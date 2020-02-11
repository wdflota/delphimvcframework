object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 242
  ClientWidth = 527
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ConSQL: TFDConnection
    Params.Strings = (
      
        'Database=C:\Program Files (x86)\Embarcadero\Studio\20.0\lib\Otro' +
        's\MVCFramework\samples\data\ORDERSMANAGER_FB25NullTypes.FDB'
      'User_Name=sysdba'
      'Password=masterkey'
      'Server=localhost'
      'DriverID=FB')
    LoginPrompt = False
    Left = 336
    Top = 136
  end
  object QryArticoli: TFDQuery
    Connection = ConSQL
    SQL.Strings = (
      'Select * From Articoli')
    Left = 392
    Top = 136
    object QryArticoliID: TIntegerField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object QryArticoliCODICE: TWideStringField
      FieldName = 'CODICE'
      Origin = 'CODICE'
      Required = True
      Size = 5
    end
    object QryArticoliDESCRIZIONE: TWideStringField
      FieldName = 'DESCRIZIONE'
      Origin = 'DESCRIZIONE'
      Size = 200
    end
    object QryArticoliPREZZO: TFMTBCDField
      FieldName = 'PREZZO'
      Origin = 'PREZZO'
      Precision = 18
      Size = 2
    end
    object QryArticoliFOTO: TBlobField
      FieldName = 'FOTO'
      Origin = 'FOTO'
    end
    object QryArticoliOSSERVAZIONI: TMemoField
      FieldName = 'OSSERVAZIONI'
      Origin = 'OSSERVAZIONI'
      BlobType = ftMemo
    end
  end
  object MQryArticoli: TFDMemTable
    AfterOpen = MQryArticoliAfterOpen
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    FormatOptions.AssignedValues = [fvMaxBcdPrecision, fvMaxBcdScale]
    FormatOptions.MaxBcdPrecision = 2147483647
    FormatOptions.MaxBcdScale = 1073741823
    ResourceOptions.AssignedValues = [rvPersistent, rvSilentMode]
    ResourceOptions.Persistent = True
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvUpdateChngFields, uvUpdateMode, uvLockMode, uvLockPoint, uvLockWait, uvRefreshMode, uvFetchGeneratorsPoint, uvCheckRequired, uvCheckReadOnly, uvCheckUpdatable, uvAutoCommitUpdates]
    UpdateOptions.LockWait = True
    UpdateOptions.FetchGeneratorsPoint = gpNone
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 48
    Top = 144
    object MQryArticoliID: TIntegerField
      FieldName = 'ID'
      Required = True
    end
    object MQryArticoliCODICE: TWideStringField
      FieldName = 'CODICE'
      Required = True
      Size = 5
    end
    object MQryArticoliDESCRIZIONE: TWideStringField
      FieldName = 'DESCRIZIONE'
      Size = 200
    end
    object MQryArticoliPREZZO: TFMTBCDField
      FieldName = 'PREZZO'
      Precision = 18
      Size = 2
    end
    object MQryArticoliFOTO: TBlobField
      FieldName = 'FOTO'
    end
    object MQryArticoliOSSERVAZIONI: TMemoField
      FieldName = 'OSSERVAZIONI'
      BlobType = ftMemo
    end
  end
end
