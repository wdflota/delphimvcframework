unit Model.Schema.Firebird;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Comp.Client,
  Model.Schema.Interfaces;

type
  TFirebirdMetadataReader = class(TInterfacedObject, IDatabaseMetadataReader)
  private
    FConnection: TFDConnection;
    function GetDataType(const AFieldType, AFieldSubType: Integer): TDBDataType;
  public
    constructor Create(const AConnection: TFDConnection);
    function GetTableNames: TArray<string>;
    function GetTableDetails(const ATableName: string): TTableInfo;
  end;

implementation

uses
  System.Generics.Collections;

{ TFirebirdMetadataReader }

constructor TFirebirdMetadataReader.Create(const AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TFirebirdMetadataReader.GetDataType(const AFieldType, AFieldSubType: Integer): TDBDataType;
begin
  // This is a simplified mapping.
  // A real implementation would be more comprehensive.
  case AFieldType of
    7, 8, 9, 16: // SMALLINT, INTEGER, QUAD, BIGINT
      Result := dtInteger;
    10, 11, 27: // FLOAT, D_FLOAT, DOUBLE
      Result := dtFloat;
    12, 13, 35: // DATE, TIME, TIMESTAMP
      Result := dtDateTime;
    14, 37:     // CHAR, VARCHAR
      Result := dtString;
    23: // BLOB is handled by sub-type
      Result := dtBoolean;
    261:
      case AFieldSubType of
        0: Result := dtBlob;
        1: Result := dtString; // BLOB SUB_TYPE 1 is TEXT
      else
        Result := dtUnknown;
      end;
  else
    Result := dtUnknown;
  end;
end;

function TFirebirdMetadataReader.GetTableNames: TArray<string>;
var
  LQuery: TFDQuery;
  LTableNames: TList<string>;
begin
  LTableNames := TList<string>.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT TRIM(RDB$RELATION_NAME) FROM RDB$RELATIONS ' +
      'WHERE RDB$SYSTEM_FLAG = 0 AND RDB$VIEW_BLR IS NULL';
    LQuery.Open;
    while not LQuery.Eof do
    begin
      LTableNames.Add(LQuery.Fields[0].AsString);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
  Result := LTableNames.ToArray;
  LTableNames.Free;
end;

function TFirebirdMetadataReader.GetTableDetails(const ATableName: string): TTableInfo;
var
  LQuery: TFDQuery;
  LColumns: TList<TColumnInfo>;
  LColumn: TColumnInfo;
  LPKFields: TStringList;
  LSQL: string;
begin
  Result.TableName := ATableName;
  LColumns := TList<TColumnInfo>.Create;
  LPKFields := TStringList.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;

    // First, get Primary Key fields for the table
    LSQL :=
      'SELECT TRIM(s.RDB$FIELD_NAME) FROM RDB$INDEX_SEGMENTS s ' +
      'JOIN RDB$RELATION_CONSTRAINTS rc ON s.RDB$INDEX_NAME = rc.RDB$INDEX_NAME ' +
      'WHERE rc.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' AND rc.RDB$RELATION_NAME = :TableName';
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('TableName').AsString := ATableName;
    LQuery.Open;
    while not LQuery.Eof do
    begin
      LPKFields.Add(LQuery.Fields[0].AsString);
      LQuery.Next;
    end;
    LQuery.Close;

    // Now, get all field details for the table
    LSQL :=
      'SELECT TRIM(rf.RDB$FIELD_NAME), f.RDB$FIELD_TYPE, f.RDB$FIELD_SUB_TYPE, ' +
      'f.RDB$FIELD_LENGTH, f.RDB$FIELD_PRECISION, rf.RDB$NULL_FLAG, ' +
      '(SELECT COUNT(*) FROM RDB$GENERATORS WHERE RDB$GENERATOR_NAME = ''GEN_'' || TRIM(rf.RDB$RELATION_NAME) || ''_'' || TRIM(rf.RDB$FIELD_NAME)) ' +
      'FROM RDB$RELATION_FIELDS rf ' +
      'JOIN RDB$FIELDS f ON rf.RDB$FIELD_SOURCE = f.RDB$FIELD_NAME ' +
      'WHERE rf.RDB$RELATION_NAME = :TableName ' +
      'ORDER BY rf.RDB$FIELD_POSITION';
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('TableName').AsString := ATableName;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      LColumn := Default(TColumnInfo);
      LColumn.ColumnName := LQuery.Fields[0].AsString;
      LColumn.DataType := GetDataType(LQuery.Fields[1].AsInteger, LQuery.Fields[2].AsInteger);
      LColumn.DataSize := LQuery.Fields[3].AsInteger;
      LColumn.Precision := LQuery.Fields[4].AsInteger;
      LColumn.IsNullable := not LQuery.Fields[5].AsBoolean; // RDB$NULL_FLAG is 1 if NOT NULL
      LColumn.IsPrimaryKey := LPKFields.IndexOf(LColumn.ColumnName) > -1;
      LColumn.IsAutoIncrement := LQuery.Fields[6].AsInteger > 0; // Simple check for a conventional generator name
      LColumns.Add(LColumn);
      LQuery.Next;
    end;

    Result.Columns := LColumns.ToArray;
  finally
    LQuery.Free;
    LColumns.Free;
    LPKFields.Free;
  end;
end;

end.
