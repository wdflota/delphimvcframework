unit CodeGenerator.Registry;

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  TEntityInfo = record
    ClassName: string;
    UnitName: string;
    RegistryKey: string;
  end;

  TRegistryCodeGenerator = class
  public
    class function Generate(const AEntityInfoList: TArray<TEntityInfo>): string;
  end;

implementation

uses
  System.Classes, System.StrUtils, System.StringBuilder, System.IOUtils;

class function TRegistryCodeGenerator.Generate(const AEntityInfoList: TArray<TEntityInfo>): string;
var
  SB: TStringBuilder;
  LEntityInfo: TEntityInfo;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendLine('unit Entities.Registry;');
    SB.AppendLine('');
    SB.AppendLine('interface');
    SB.AppendLine('');
    SB.AppendLine('implementation');
    SB.AppendLine('');
    SB.AppendLine('uses');
    SB.AppendLine('  MVCFramework.ActiveRecord,');

    if Length(AEntityInfoList) > 0 then
    begin
      for LEntityInfo in AEntityInfoList do
      begin
        SB.AppendLine('  ' + LEntityInfo.UnitName + ',');
      end;
      // Remove the last comma and add a semicolon
      SB.Length := SB.Length - (sLineBreak.Length + 1);
      SB.AppendLine(';');
    end
    else
    begin
      SB.AppendLine('  System.SysUtils;'); // Add at least one unit
    end;

    SB.AppendLine('');
    SB.AppendLine('initialization');
    SB.AppendLine('');

    for LEntityInfo in AEntityInfoList do
    begin
      SB.AppendLine('  ActiveRecordMappingRegistry.AddEntity(''' + LEntityInfo.RegistryKey + ''', ' + LEntityInfo.ClassName + ');');
    end;

    SB.AppendLine('');
    SB.AppendLine('finalization');
    SB.AppendLine('');
    SB.AppendLine('end.');

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

end.
