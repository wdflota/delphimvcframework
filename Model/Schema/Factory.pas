unit Model.Schema.Factory;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  Model.Schema.Interfaces,
  Model.Schema.Firebird,
  Model.Schema.MySQL,
  Model.Schema.PostgreSQL,
  Model.Schema.SQLServer;

type
  TDatabaseType = (dtFirebird, dtMySQL, dtPostgreSQL, dtSQLServer);

  TMetadataReaderFactory = class
  public
    class function CreateReader(const ADatabaseType: TDatabaseType;
      const AConnection: TFDConnection): IDatabaseMetadataReader;
  end;

implementation

{ TMetadataReaderFactory }

class function TMetadataReaderFactory.CreateReader(
  const ADatabaseType: TDatabaseType; const AConnection: TFDConnection): IDatabaseMetadataReader;
begin
  case ADatabaseType of
    dtFirebird:
      Result := TFirebirdMetadataReader.Create(AConnection);
    dtMySQL:
      Result := TMySQLMetadataReader.Create(AConnection);
    dtPostgreSQL:
      Result := TPostgreSQLMetadataReader.Create(AConnection);
    dtSQLServer:
      Result := TSQLServerMetadataReader.Create(AConnection);
  else
    raise EArgumentException.Create('Unsupported database type');
  end;
end;

end.
