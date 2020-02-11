object dmMain: TdmMain
  OldCreateOrder = False
  Height = 214
  Width = 438
  object Connection: TFDConnection
    Params.Strings = (
      
        'Database=C:\Program Files (x86)\Embarcadero\Studio\20.0\lib\Otro' +
        's\MVCFramework\samples\data\ORDERSMANAGER_FB25NullTypes.FDB'
      'User_Name=sysdba'
      'Password=masterkey'
      'Protocol=TCPIP'
      'Server=localhost'
      'DriverID=FB')
    ConnectedStoredUsage = []
    LoginPrompt = False
    BeforeConnect = ConnectionBeforeConnect
    Left = 64
    Top = 48
  end
  object dsArticles: TFDQuery
    Connection = Connection
    UpdateOptions.AssignedValues = [uvFetchGeneratorsPoint, uvGeneratorName]
    UpdateOptions.FetchGeneratorsPoint = gpImmediate
    UpdateOptions.GeneratorName = 'GEN_ARTICOLI_ID'
    UpdateOptions.UpdateTableName = 'ARTICOLI'
    UpdateOptions.KeyFields = 'ID'
    UpdateObject = updArticles
    SQL.Strings = (
      'SELECT * FROM ARTICOLI')
    Left = 144
    Top = 48
    object dsArticlesID: TIntegerField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object dsArticlesCODICE: TWideStringField
      FieldName = 'CODICE'
      Origin = 'CODICE'
      Required = True
      Size = 5
    end
    object dsArticlesDESCRIZIONE: TWideStringField
      FieldName = 'DESCRIZIONE'
      Origin = 'DESCRIZIONE'
      Size = 200
    end
    object dsArticlesPREZZO: TFMTBCDField
      FieldName = 'PREZZO'
      Origin = 'PREZZO'
      Precision = 18
      Size = 2
    end
    object dsArticlesFOTO: TBlobField
      FieldName = 'FOTO'
      Origin = 'FOTO'
    end
    object dsArticlesOSSERVAZIONI: TMemoField
      FieldName = 'OSSERVAZIONI'
      Origin = 'OSSERVAZIONI'
      BlobType = ftMemo
    end
    object dsArticlesPESO: TCurrencyField
      FieldName = 'PESO'
      Origin = 'PESO'
    end
    object dsArticlesSTATO: TSmallintField
      FieldName = 'STATO'
      Origin = 'STATO'
    end
    object dsArticlesDATADINASCITA: TDateField
      FieldName = 'DATADINASCITA'
      Origin = 'DATADINASCITA'
    end
    object dsArticlesTEMPODINASCITA: TTimeField
      FieldName = 'TEMPODINASCITA'
      Origin = 'TEMPODINASCITA'
    end
    object dsArticlesDATADICREAZIONE: TSQLTimeStampField
      FieldName = 'DATADICREAZIONE'
      Origin = 'DATADICREAZIONE'
    end
  end
  object updArticles: TFDUpdateSQL
    Connection = Connection
    InsertSQL.Strings = (
      'INSERT INTO ARTICOLI'
      '(ID, CODICE, DESCRIZIONE, PREZZO, FOTO, '
      
        '  OSSERVAZIONI, PESO, STATO, DATADINASCITA, TEMPODINASCITA, DATA' +
        'DICREAZIONE)'
      
        'VALUES (:NEW_ID, :NEW_CODICE, :NEW_DESCRIZIONE, :NEW_PREZZO, :NE' +
        'W_FOTO, '
      
        '  :NEW_OSSERVAZIONI, :NEW_PESO, :NEW_STATO, :NEW_DATADINASCITA, ' +
        ':NEW_TEMPODINASCITA, '
      ':NEW_DATADICREAZIONE)'
      'RETURNING ID {INTO :ID}')
    ModifySQL.Strings = (
      'UPDATE ARTICOLI'
      
        'SET ID = :NEW_ID, CODICE = :NEW_CODICE, DESCRIZIONE = :NEW_DESCR' +
        'IZIONE, '
      
        '  PREZZO = :NEW_PREZZO, FOTO = :NEW_FOTO, OSSERVAZIONI = :NEW_OS' +
        'SERVAZIONI, '
      
        '  PESO = :NEW_PESO, STATO = :NEW_STATO, DATADINASCITA = :NEW_DAT' +
        'ADINASCITA, '
      
        '  TEMPODINASCITA = :NEW_TEMPODINASCITA, DATADICREAZIONE = :NEW_D' +
        'ATADICREAZIONE'
      'WHERE ID = :OLD_ID'
      'RETURNING ID')
    DeleteSQL.Strings = (
      'DELETE FROM ARTICOLI'
      'WHERE ID = :OLD_ID')
    FetchRowSQL.Strings = (
      
        'SELECT ID, CODICE, DESCRIZIONE, PREZZO, FOTO, OSSERVAZIONI, PESO' +
        ', STATO, '
      'DATADINASCITA, TEMPODINASCITA, DATADICREAZIONE'
      'FROM ARTICOLI'
      'WHERE ID = :OLD_ID')
    Left = 144
    Top = 112
  end
end
