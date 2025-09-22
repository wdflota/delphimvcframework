unit Model.Schema.MySQL;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Comp.Client,
  Model.Schema.Interfaces;

type
  TMySQLMetadataReader = class(TInterfacedObject, IDatabaseMetadataReader)
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

{ TMySQLMetadataReader }

constructor TMySQLMetadataReader.Create(const AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TMySQLMetadataReader.GetDataType(const ADataType: string): TDBDataType;
begin
  if SameText(ADataType, 'varchar') or SameText(ADataType, 'char') or
     SameText(ADataType, 'text') or SameText(ADataType, 'longtext') then
    Result := dtString
  else if SameText(ADataType, 'int') or SameText(ADataType, 'integer') or
          SameText(ADataType, 'smallint') or SameText(ADataType, 'tinyint') then
    Result := dtInteger
  else if SameText(ADataType, 'bigint') then
    Result := dtInt64
  else if SameText(ADataType, 'boolean') or SameText(ADataType, 'bool') then
     Result := dtBoolean
  else if SameText(ADataType, 'date') or SameText(ADataType, 'datetime') or
          SameText(ADataType, 'timestamp') then
    Result := dtDateTime
  else if SameText(ADataType, 'float') or SameText(ADataType, 'real') then
    Result := dtFloat
  else if SameText(ADataType, 'double') or SameText(ADataType, 'decimal') or
          SameText(ADataType, 'numeric') then
    Result := dtDouble
  else if SameText(ADataType, 'blob') or SameText(ADataType, 'longblob') then
    Result := dtBlob
  else
    Result := dtUnknown;
end;

function TMySQLMetadataReader.GetTableNames: TArray<string>;
var
  LQuery: TFDQuery;
  LTableNames: TList<string>;
begin
  LTableNames := TList<string>.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT table_name FROM information_schema.tables ' +
      'WHERE table_schema = DATABASE() AND table_type = ''BASE TABLE''';
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

function TMySQLMetadataReader.GetTableDetails(const ATableName: string): TTableInfo;
var
  LQuery: TFDQuery;
  LColumns: TList<TColumnInfo>;
  LColumn: TColumnInfo;
begin
  Result.TableName := ATableName;
  LColumns := TList<TColumnInfo>.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT column_name, data_type, character_maximum_length, ' +
      'numeric_precision, is_nullable, column_key, extra ' +
      'FROM information_schema.columns ' +
      'WHERE table_schema = DATABASE() AND table_name = :TableName ' +
      'ORDER BY ordinal_position';
    LQuery.ParamByName('TableName').AsString := ATableName;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      LColumn := Default(TColumnInfo);
      LColumn.ColumnName := LQuery.FieldByName('column_name').AsString;
      LColumn.DataType := GetDataType(LQuery.FieldByName('data_type').AsString);
      LColumn.DataSize := LQuery.FieldByName('character_maximum_length').AsInteger;
      LColumn.Precision := LQuery.FieldByName('numeric_precision').AsInteger;
      LColumn.IsNullable := SameText(LQuery.FieldByName('is_nullable').AsString, 'YES');
      LColumn.IsPrimaryKey := SameText(LQuery.FieldByName('column_key').AsString, 'PRI');
      LColumn.IsAutoIncrement := Pos('auto_increment', LQuery.FieldByName('extra').AsString) > 0;
      LColumns.Add(LColumn);
      LQuery.Next;
    end;
    Result.Columns := LColumns.ToArray;
  finally
    LQuery.Free;
    LColumns.Free;
  end;
end;

end.
