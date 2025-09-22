unit Model.Schema.Interfaces;

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  { TDBDataType defines the supported database data types in a generic way. }
  TDBDataType = (
    dtUnknown,
    dtString,
    dtInteger,
    dtInt64,
    dtBoolean,
    dtDateTime,
    dtFloat,
    dtBlob,
    dtDouble
  );

  { TColumnInfo holds all relevant metadata for a single database column. }
  TColumnInfo = record
    ColumnName: string;
    DataType: TDBDataType;
    DataSize: Integer;
    Precision: Integer;
    IsNullable: Boolean;
    IsPrimaryKey: Boolean;
    IsAutoIncrement: Boolean;
  end;

  { TTableInfo holds the metadata for a database table, including its columns. }
  TTableInfo = record
    TableName: string;
    Columns: TArray<TColumnInfo>;
  end;

  {
    IDatabaseMetadataReader is the core interface for abstracting database schema
    retrieval. Any class that can read metadata from a specific database
    (like MySQL, Firebird, etc.) must implement this interface.
  }
  IDatabaseMetadataReader = interface
    ['{2E5B5D68-3A47-4B6A-B25A-15C2982B349C}']

    // Returns a list of all user table names in the database.
    function GetTableNames: TArray<string>;

    // Returns detailed information (columns, types, etc.) for a specific table.
    function GetTableDetails(const ATableName: string): TTableInfo;
  end;

implementation

end.
