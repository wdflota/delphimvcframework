unit Model.Schema.SQLServer;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Comp.Client,
  Model.Schema.Interfaces;

type
  TSQLServerMetadataReader = class(TInterfacedObject, IDatabaseMetadataReader)
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

{ TSQLServerMetadataReader }

constructor TSQLServerMetadataReader.Create(const AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TSQLServerMetadataReader.GetDataType(const ADataType: string): TDBDataType;
begin
  if SameText(ADataType, 'varchar') or SameText(ADataType, 'char') or
     SameText(ADataType, 'nvarchar') or SameText(ADataType, 'nchar') or
     SameText(ADataType, 'text') or SameText(ADataType, 'ntext') then
    Result := dtString
  else if SameText(ADataType, 'int') or SameText(ADataType, 'smallint') or
          SameText(ADataType, 'tinyint') then
    Result := dtInteger
  else if SameText(ADataType, 'bigint') then
    Result := dtInt64
  else if SameText(ADataType, 'bit') then
     Result := dtBoolean
  else if SameText(ADataType, 'date') or SameText(ADataType, 'datetime') or
          SameText(ADataType, 'datetime2') or SameText(ADataType, 'smalldatetime') then
    Result := dtDateTime
  else if SameText(ADataType, 'real') then
    Result := dtFloat
  else if SameText(ADataType, 'float') or SameText(ADataType, 'decimal') or
          SameText(ADataType, 'numeric') or SameText(ADataType, 'money') then
    Result := dtDouble
  else if SameText(ADataType, 'image') or SameText(ADataType, 'varbinary') then
    Result := dtBlob
  else
    Result := dtUnknown;
end;

function TSQLServerMetadataReader.GetTableNames: TArray<string>;
var
  LQuery: TFDQuery;
  LTableNames: TList<string>;
begin
  LTableNames := TList<string>.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT name FROM sys.tables WHERE type = ''U'' ORDER BY name';
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

function TSQLServerMetadataReader.GetTableDetails(const ATableName: string): TTableInfo;
var
  LQuery: TFDQuery;
  LColumns: TList<TColumnInfo>;
  LColumn: TColumnInfo;
  LSQL: string;
begin
  Result.TableName := ATableName;
  LColumns := TList<TColumnInfo>.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LSQL :=
      'SELECT ' +
      '  c.name AS ColumnName, ' +
      '  t.name AS TypeName, ' +
      '  c.max_length AS MaxLength, ' +
      '  c.precision AS Precision, ' +
      '  c.is_nullable AS IsNullable, ' +
      '  c.is_identity AS IsIdentity, ' +
      '  ISNULL((SELECT 1 FROM sys.indexes i ' +
      '    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id ' +
      '    WHERE i.is_primary_key = 1 AND i.object_id = c.object_id AND ic.column_id = c.column_id), 0) AS IsPrimaryKey ' +
      'FROM sys.columns c ' +
      'INNER JOIN sys.types t ON c.user_type_id = t.user_type_id ' +
      'WHERE c.object_id = OBJECT_ID(:TableName) ' +
      'ORDER BY c.column_id';

    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('TableName').AsString := ATableName;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      LColumn := Default(TColumnInfo);
      LColumn.ColumnName := LQuery.FieldByName('ColumnName').AsString;
      LColumn.DataType := GetDataType(LQuery.FieldByName('TypeName').AsString);
      LColumn.DataSize := LQuery.FieldByName('MaxLength').AsInteger;
      LColumn.Precision := LQuery.FieldByName('Precision').AsInteger;
      LColumn.IsNullable := LQuery.FieldByName('IsNullable').AsBoolean;
      LColumn.IsPrimaryKey := LQuery.FieldByName('IsPrimaryKey').AsBoolean;
      LColumn.IsAutoIncrement := LQuery.FieldByName('IsIdentity').AsBoolean;
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
