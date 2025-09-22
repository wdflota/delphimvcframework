unit Model.Schema.PostgreSQL;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Comp.Client,
  Model.Schema.Interfaces;

type
  TPostgreSQLMetadataReader = class(TInterfacedObject, IDatabaseMetadataReader)
  private
    FConnection: TFDConnection;
    function GetDataType(const ADataType: string): TDBDataType;
  public
    constructor Create(const AConnection: TFDConnection);
    function GetTableNames: TArray<string>;
    function GetTableDetails(const ATableName: string): TTableInfo;
  end;

implementation

uses
  System.Generics.Collections, System.StrUtils;

{ TPostgreSQLMetadataReader }

constructor TPostgreSQLMetadataReader.Create(const AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TPostgreSQLMetadataReader.GetDataType(const ADataType: string): TDBDataType;
begin
  if SameText(ADataType, 'varchar') or SameText(ADataType, 'char') or
     SameText(ADataType, 'text') or SameText(ADataType, 'bpchar') then
    Result := dtString
  else if SameText(ADataType, 'int4') or SameText(ADataType, 'int2') or
          SameText(ADataType, 'integer') or SameText(ADataType, 'serial') then
    Result := dtInteger
  else if SameText(ADataType, 'int8') or SameText(ADataType, 'bigserial') then
    Result := dtInt64
  else if SameText(ADataType, 'bool') then
     Result := dtBoolean
  else if SameText(ADataType, 'date') or SameText(ADataType, 'timestamp') or
          SameText(ADataType, 'timestamptz') then
    Result := dtDateTime
  else if SameText(ADataType, 'float4') or SameText(ADataType, 'real') then
    Result := dtFloat
  else if SameText(ADataType, 'float8') or SameText(ADataType, 'numeric') or
          SameText(ADataType, 'decimal') then
    Result := dtDouble
  else if SameText(ADataType, 'bytea') then
    Result := dtBlob
  else
    Result := dtUnknown;
end;

function TPostgreSQLMetadataReader.GetTableNames: TArray<string>;
var
  LQuery: TFDQuery;
  LTableNames: TList<string>;
begin
  LTableNames := TList<string>.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT table_name FROM information_schema.tables ' +
      'WHERE table_schema = ''public'' AND table_type = ''BASE TABLE''';
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

function TPostgreSQLMetadataReader.GetTableDetails(const ATableName: string): TTableInfo;
var
  LQuery: TFDQuery;
  LColumns: TList<TColumnInfo>;
  LColumn: TColumnInfo;
  LPKFields: TStringList;
begin
  Result.TableName := ATableName;
  LColumns := TList<TColumnInfo>.Create;
  LPKFields := TStringList.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;

    // First, get PKs
    LQuery.SQL.Text := 'SELECT kcu.column_name ' +
      'FROM information_schema.table_constraints AS tc ' +
      'JOIN information_schema.key_column_usage AS kcu ' +
      '  ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema ' +
      'WHERE tc.constraint_type = ''PRIMARY KEY'' ' +
      '  AND tc.table_name = :TableName AND tc.table_schema = ''public''';
    LQuery.ParamByName('TableName').AsString := ATableName;
    LQuery.Open;
    while not LQuery.Eof do
    begin
      LPKFields.Add(LQuery.Fields[0].AsString);
      LQuery.Next;
    end;
    LQuery.Close;

    // Now get column details
    LQuery.SQL.Text :=
      'SELECT column_name, udt_name, character_maximum_length, ' +
      'numeric_precision, is_nullable, column_default ' +
      'FROM information_schema.columns ' +
      'WHERE table_schema = ''public'' AND table_name = :TableName ' +
      'ORDER BY ordinal_position';
    LQuery.ParamByName('TableName').AsString := ATableName;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      LColumn := Default(TColumnInfo);
      LColumn.ColumnName := LQuery.FieldByName('column_name').AsString;
      LColumn.DataType := GetDataType(LQuery.FieldByName('udt_name').AsString);
      LColumn.DataSize := LQuery.FieldByName('character_maximum_length').AsInteger;
      LColumn.Precision := LQuery.FieldByName('numeric_precision').AsInteger;
      LColumn.IsNullable := SameText(LQuery.FieldByName('is_nullable').AsString, 'YES');
      LColumn.IsPrimaryKey := LPKFields.IndexOf(LColumn.ColumnName) > -1;
      LColumn.IsAutoIncrement := (LQuery.FieldByName('column_default').AsString <> '') and
        (Pos('nextval', LQuery.FieldByName('column_default').AsString) > 0);
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
