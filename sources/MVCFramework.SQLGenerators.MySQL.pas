// *************************************************************************** }
//
// Delphi MVC Framework
//
// Copyright (c) 2010-2018 Daniele Teti and the DMVCFramework Team
//
// https://github.com/danieleteti/delphimvcframework
//
// ***************************************************************************
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ***************************************************************************

unit MVCFramework.SQLGenerators.MySQL;

interface

uses
  FireDAC.Phys.MySQLDef,
  FireDAC.Phys.MySQL,
  System.Rtti,
  System.Generics.Collections,
  MVCFramework.RQL.Parser,
  MVCFramework.ActiveRecord,
  MVCFramework.Commons ;

type
  TMVCSQLGeneratorMySQL = class(TMVCSQLGenerator)
  protected
    function GetCompilerClass: TRQLCompilerClass; override;
  public
    function CreateSelectSQL(
      const TableName: string;
      const Map: TDictionary<TRttiField, string>;
      const PKFieldName: string;
      const PKOptions: TMVCActiveRecordFieldOptions): string; override;
    function CreateInsertSQL(
      const TableName: string;
      const Map: TDictionary<TRttiField, string>;
      const PKFieldName: string;
      const PKOptions: TMVCActiveRecordFieldOptions): string; override;
    function CreateUpdateSQL(
      const TableName: string;
      const Map: TDictionary<TRttiField, string>;
      const PKFieldName: string;
      const PKOptions: TMVCActiveRecordFieldOptions): string; override;
    function CreateDeleteSQL(
      const TableName: string;
      const Map: TDictionary<TRttiField, string>;
      const PKFieldName: string;
      const PKOptions: TMVCActiveRecordFieldOptions;
      const PrimaryKeyValue: Int64): string; override;
    function CreateSelectByPKSQL(
      const TableName: string;
      const Map: TDictionary<TRttiField, string>; const PKFieldName: string;
      const PKOptions: TMVCActiveRecordFieldOptions;
      const PrimaryKeyValue: Int64): string; override;
    function CreateSelectSQLByRQL(
      const RQL: string;
      const Mapping: TMVCFieldsMapping): string; override;
  end;

implementation

uses
  System.SysUtils,
  MVCFramework.RQL.AST2MySQL;

function TMVCSQLGeneratorMySQL.CreateInsertSQL(const TableName: string; const Map: TDictionary<TRttiField, string>;
  const PKFieldName: string; const PKOptions: TMVCActiveRecordFieldOptions): string;
var
  lKeyValue: TPair<TRttiField, string>;
  lSB: TStringBuilder;
begin
  lSB := TStringBuilder.Create;
  try
    lSB.Append('INSERT INTO ' + TableName + '(');
    for lKeyValue in Map do
      lSB.Append(lKeyValue.value + ',');
    lSB.Remove(lSB.Length - 1, 1);
    lSB.Append(') values (');
    for lKeyValue in Map do
    begin
      lSB.Append(':' + lKeyValue.value + ',');
    end;
    lSB.Remove(lSB.Length - 1, 1);
    lSB.Append(')');

    if foAutoGenerated in PKOptions then
    begin
      lSB.Append(';SELECT LAST_INSERT_ID() as ' + PKFieldName);
    end;
    Result := lSB.ToString;
  finally
    lSB.Free;
  end;
end;

function TMVCSQLGeneratorMySQL.CreateSelectByPKSQL(
  const TableName: string;
  const Map: TDictionary<TRttiField, string>; const PKFieldName: string;
  const PKOptions: TMVCActiveRecordFieldOptions;
  const PrimaryKeyValue: Int64): string;
begin
  Result := CreateSelectSQL(TableName, Map, PKFieldName, PKOptions) + ' WHERE ' +
    PKFieldName + '= :' + PKFieldName; // IntToStr(PrimaryKeyValue);
end;

function TMVCSQLGeneratorMySQL.CreateSelectSQL(const TableName: string;
  const Map: TDictionary<TRttiField, string>; const PKFieldName: string;
  const PKOptions: TMVCActiveRecordFieldOptions): string;
begin
  Result := 'SELECT ' + TableFieldsDelimited(Map, PKFieldName, ',') + ' FROM ' + TableName;
end;

function TMVCSQLGeneratorMySQL.CreateSelectSQLByRQL(const RQL: string;
  const Mapping: TMVCFieldsMapping): string;
var
  lMySQLCompiler: TRQLMySQLCompiler;
begin
  lMySQLCompiler := TRQLMySQLCompiler.Create(Mapping);
  try
    GetRQLParser.Execute(RQL, Result, lMySQLCompiler);
  finally
    lMySQLCompiler.Free;
  end;
end;

function TMVCSQLGeneratorMySQL.CreateUpdateSQL(const TableName: string; const Map: TDictionary<TRttiField, string>;
  const PKFieldName: string; const PKOptions: TMVCActiveRecordFieldOptions): string;
var
  keyvalue: TPair<TRttiField, string>;
begin
  Result := 'UPDATE ' + TableName + ' SET ';
  for keyvalue in Map do
  begin
    Result := Result + keyvalue.value + ' = :' + keyvalue.value + ',';
  end;
  Result[Length(Result)] := ' ';
  if not PKFieldName.IsEmpty then
  begin
    Result := Result + ' where ' + PKFieldName + '= :' + PKFieldName;
  end;
end;

function TMVCSQLGeneratorMySQL.GetCompilerClass: TRQLCompilerClass;
begin
  Result := TRQLMySQLCompiler;
end;

function TMVCSQLGeneratorMySQL.CreateDeleteSQL(const TableName: string; const Map: TDictionary<TRttiField, string>;
  const PKFieldName: string; const PKOptions: TMVCActiveRecordFieldOptions; const PrimaryKeyValue: Int64): string;
begin
  Result := 'DELETE FROM ' + TableName + ' WHERE ' + PKFieldName + '= ' + IntToStr(PrimaryKeyValue);
end;

initialization

TMVCSQLGeneratorRegistry.Instance.RegisterSQLGenerator('mysql', TMVCSQLGeneratorMySQL);

finalization

TMVCSQLGeneratorRegistry.Instance.UnRegisterSQLGenerator('mysql');

end.
