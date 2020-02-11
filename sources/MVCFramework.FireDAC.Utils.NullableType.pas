// ***************************************************************************
//
// Delphi MVC Framework
//
// Copyright (c) 2010-2020 Daniele Teti and the DMVCFramework Team
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
// *************************************************************************** }

unit MVCFramework.FireDAC.Utils.NullableType;

{$I dmvcframework.inc}

interface

uses
  FireDAC.Comp.Client, FireDAC.Stan.Param, System.Rtti,
  Spring, Spring.Persistence.SQL.Params, Spring.Persistence.Mapping.Attributes, // dFlota
  System.Variants;  // dFlota

type
  TFireDACUtils = class sealed
  private
    class var CTX: TRttiContext;
    class function InternalExecuteQuery(AQuery: TFDQuery; AObject: TObject;
      WithResult: boolean): Int64;
  public
    class constructor Create;
    class destructor Destroy;
    class function ExecuteQueryNoResult(AQuery: TFDQuery;
      AObject: TObject): Int64;
    class procedure ExecuteQuery(AQuery: TFDQuery; AObject: TObject);
    class procedure ObjectToParameters(AFDParams: TFDParams; AObject: TObject; AParamPrefix: string = ''; AParamPrefixPK: string = '';
      ASetParamTypes: Boolean = True);  // dFlota = Add AParamPrefixPK
    {$REGION 'dFlota'}
      class function GenerateSQLDelete(AObject: TObject): string;
      class function GenerateSQLInsert(AObject: TObject): string;
      class function GenerateSQLSelect(AObject: TObject; AWithFields: Boolean = False; AWithParams: Boolean = False): string;
      class function GenerateSQLUpdate(AObject: TObject): string;
    {$ENDREGION}
  end;

implementation

uses
  System.Generics.Collections,
  Data.DB,
  System.Classes,
  MVCFramework.Serializer.Commons,
  System.SysUtils;

{ TFireDACUtils }

class constructor TFireDACUtils.Create;
begin
  TFireDACUtils.CTX := TRttiContext.Create;
end;

class destructor TFireDACUtils.Destroy;
begin
  TFireDACUtils.CTX.Free;
end;

class procedure TFireDACUtils.ExecuteQuery(AQuery: TFDQuery; AObject: TObject);
begin
  InternalExecuteQuery(AQuery, AObject, True);
end;

class function TFireDACUtils.ExecuteQueryNoResult(AQuery: TFDQuery;
  AObject: TObject): Int64;
begin
  Result := InternalExecuteQuery(AQuery, AObject, false);
end;

{$REGION 'dFlota'}
class function TFireDACUtils.GenerateSQLDelete(AObject: TObject): string;
const
  LOldPrefix = ':OLD_';
var
  _rttiType: TRttiType;
  obj_fields: TArray<TRttiProperty>;
  obj_field: TRttiProperty;
  obj_field_attr: MVCColumnAttribute;

  LAttribute: TCustomAttribute;
  LSQLCommand, LSQLWhere: TStringBuilder;
begin
  LSQLCommand := TStringBuilder.Create('Delete From ');
  LSQLWhere := TStringBuilder.Create('Where ');

  if Assigned(AObject) then
  begin
    _rttiType := ctx.GetType(AObject.ClassType);
    // Retrieve TableName
    for LAttribute in _rttiType.GetAttributes do
    begin
      if LAttribute is TableAttribute then
      begin
        // Schema is only inserted if the Database supports it
        if TableAttribute(LAttribute).Schema.IsEmpty then
          LSQLCommand.Append(TableAttribute(LAttribute).TableName).Append(' ')
        else
          LSQLCommand.Append(TableAttribute(LAttribute).Schema).Append('.').Append(TableAttribute(LAttribute).TableName).Append(' ');
      end;
    end;

    // Retrieve Fields/Paramaters
    obj_fields := _rttiType.GetProperties;
    for obj_field in obj_fields do
    begin
      if TMVCSerializerHelper.HasAttribute<MVCColumnAttribute>(obj_field, obj_field_attr) then
      begin
        // Retrieve Primarykeys
        if MVCColumnAttribute(obj_field_attr).IsPK then
          LSQLWhere.Append(MVCColumnAttribute(obj_field_attr).FieldName).Append(' = ').Append(LOldPrefix + obj_field.Name).Append(' And ');
      end;
    end;
    LSQLWhere.Remove(LSQLWhere.Length - 5, 5);
  end;
  Result := LSQLCommand.Append(LSQLWhere.ToString).ToString;
end;

class function TFireDACUtils.GenerateSQLInsert(AObject: TObject): string;
const
  LNewPrefix = ':NEW_';
var
  _rttiType: TRttiType;
  obj_fields: TArray<TRttiProperty>;
  obj_field: TRttiProperty;
  obj_field_attr: MVCColumnAttribute;

  LAttribute: TCustomAttribute;
  LSQLCommand, LSQLFields, LSQLFieldsValues: TStringBuilder;
begin
  LSQLCommand := TStringBuilder.Create('Insert Into ');
  LSQLFields := TStringBuilder.Create('(');
  LSQLFieldsValues := TStringBuilder.Create(' Values (');

  if Assigned(AObject) then
  begin
    _rttiType := ctx.GetType(AObject.ClassType);
    // Retrieve TableName
    for LAttribute in _rttiType.GetAttributes do
    begin
      if LAttribute is TableAttribute then
      begin
        // Schema is only inserted if the Database supports it
        if TableAttribute(LAttribute).Schema.IsEmpty then
          LSQLCommand.Append(TableAttribute(LAttribute).TableName).Append(' ')
        else
          LSQLCommand.Append(TableAttribute(LAttribute).Schema).Append('.').Append(TableAttribute(LAttribute).TableName).Append(' ');
      end;
    end;

    // Retrieve Fields/Paramaters
    obj_fields := _rttiType.GetProperties;
    for obj_field in obj_fields do
    begin
      if TMVCSerializerHelper.HasAttribute<MVCColumnAttribute>(obj_field, obj_field_attr) then
      begin
        LSQLFields.Append(obj_field.Name).Append(', ');
        LSQLFieldsValues.Append(LNewPrefix + obj_field.Name).Append(', ');
      end;
    end;
    LSQLFields.Remove(LSQLFields.Length - 2, 2);
    LSQLFields.Append(')');
    LSQLFieldsValues.Remove(LSQLFieldsValues.Length - 2, 2);
    LSQLFieldsValues.Append(')');
  end;
  Result := LSQLCommand.Append(LSQLFields.ToString).Append(LSQLFieldsValues.ToString).ToString;
end;

class function TFireDACUtils.GenerateSQLSelect(AObject: TObject; AWithFields: Boolean;
  AWithParams: Boolean): string;
var
  _rttiType: TRttiType;
  obj_fields: TArray<TRttiProperty>;
  obj_field: TRttiProperty;
  obj_field_attr: MVCColumnAttribute;

  LAttribute: TCustomAttribute;
  LSQLCommand, LSQLFields, LSQLFrom, LSQLWhere: TStringBuilder;
  LFieldName: string;
begin
  LSQLCommand := TStringBuilder.Create('Select ');
  LSQLFields := TStringBuilder.Create;
  LSQLFrom := TStringBuilder.Create('From ');
  LSQLWhere := TStringBuilder.Create('Where ');

  if Assigned(AObject) then
  begin
    _rttiType := ctx.GetType(AObject.ClassType);
    // Retrieve TableName
    for LAttribute in _rttiType.GetAttributes do
    begin
      if LAttribute is TableAttribute then
      begin
        // Schema is only inserted if the Database supports it
        if TableAttribute(LAttribute).Schema.IsEmpty then
          LSQLFrom.Append(TableAttribute(LAttribute).TableName).Append(' ')
        else
          LSQLFrom.Append(TableAttribute(LAttribute).Schema).Append('.').Append(TableAttribute(LAttribute).TableName).Append(' ');
      end;
    end;

    // Retrieve Fields/Paramaters
    obj_fields := _rttiType.GetProperties;
    for obj_field in obj_fields do
    begin
      if TMVCSerializerHelper.HasAttribute<MVCColumnAttribute>(obj_field, obj_field_attr) then
      begin
        if (not AWithFields) and (not AWithParams) then
          Break;

        if AWithFields then
          LSQLFields.Append(obj_field.Name).Append(', ');

        if AWithParams then
        begin
          // Retrieve Primarykeys
          if MVCColumnAttribute(obj_field_attr).IsPK then
          begin
            LFieldName := MVCColumnAttribute(obj_field_attr).FieldName;
            LSQLWhere.Append(LFieldName).Append(' = :').Append(LFieldName).Append(' And ');
          end;
        end;
      end;
    end;
    if LSQLFields.Length = 0 then
      LSQLFields.Append('* ')
    else
      LSQLFields.Remove(LSQLFields.Length - 2, 1);

    if LSQLWhere.Length = 6 then
      LSQLWhere.Clear
    else
      LSQLWhere.Remove(LSQLWhere.Length - 5, 5);

  end;
  Result := LSQLCommand.Append(LSQLFields.ToString).Append(LSQLFrom.ToString).Append(LSQLWhere).ToString;
end;

class function TFireDACUtils.GenerateSQLUpdate(AObject: TObject): string;
const
  LNewPrefix = ':NEW_';
  LOldPrefix = ':OLD_';
var
  _rttiType: TRttiType;
  obj_fields: TArray<TRttiProperty>;
  obj_field: TRttiProperty;
  obj_field_attr: MVCColumnAttribute;

  LAttribute: TCustomAttribute;
  LSQLCommand, LSQLFieldsValues, LSQLWhere: TStringBuilder;
begin
  LSQLCommand := TStringBuilder.Create('Update ');
  LSQLFieldsValues := TStringBuilder.Create('Set ');
  LSQLWhere := TStringBuilder.Create('Where ');

  if Assigned(AObject) then
  begin
    _rttiType := ctx.GetType(AObject.ClassType);
    // Retrieve TableName
    for LAttribute in _rttiType.GetAttributes do
    begin
      if LAttribute is TableAttribute then
      begin
        // Schema is only inserted if the Database supports it
        if TableAttribute(LAttribute).Schema.IsEmpty then
          LSQLCommand.Append(TableAttribute(LAttribute).TableName).Append(' ')
        else
          LSQLCommand.Append(TableAttribute(LAttribute).Schema).Append('.').Append(TableAttribute(LAttribute).TableName).Append(' ');
      end;
    end;

    // Retrieve Fields/Paramaters
    obj_fields := _rttiType.GetProperties;
    for obj_field in obj_fields do
    begin
      if TMVCSerializerHelper.HasAttribute<MVCColumnAttribute>(obj_field, obj_field_attr) then
      begin
        LSQLFieldsValues.Append(obj_field.Name).Append(' = ').Append(LNewPrefix + obj_field.Name).Append(', ');
        // Retrieve Primarykeys
        if MVCColumnAttribute(obj_field_attr).IsPK then
          LSQLWhere.Append(MVCColumnAttribute(obj_field_attr).FieldName).Append(' = ').Append(LOldPrefix + obj_field.Name).Append(' And ');
      end;
    end;
    LSQLFieldsValues.Remove(LSQLFieldsValues.Length - 2, 1);
    LSQLWhere.Remove(LSQLWhere.Length - 5, 5);
  end;
  Result := LSQLCommand.Append(LSQLFieldsValues.ToString).Append(LSQLWhere.ToString).ToString;
end;
{$ENDREGION}

class procedure TFireDACUtils.ObjectToParameters(AFDParams: TFDParams;
  AObject: TObject; AParamPrefix, AParamPrefixPK: string; ASetParamTypes: Boolean);
var
  I: Integer;
  pname: string;
  _rttiType: TRttiType;
  obj_fields: TArray<TRttiProperty>;
  obj_field: TRttiProperty;
  obj_field_attr: MVCColumnAttribute;
  Map: TObjectDictionary<string, TRttiProperty>;
  f: TRttiProperty;
  fv: TValue;
  PrefixLength: Integer;
  {$REGION 'Add By dFlota'}
    LPrefixLengthPK: Integer;
    LIsPrimarykey: Boolean;

    pnamePK: string;
    LDBParam: TDBParam;
    LIsStream: Boolean;
    LMemoryStream: TMemoryStream;
    LMVCSerializeAsStringAttribute: MVCSerializeAsStringAttribute;
    LMVCColumnAttribute: MVCColumnAttribute;
  {$ENDREGION}

  {$REGION 'Delete by dFlota'}
//    function KindToFieldType(AKind: TTypeKind; AProp: TRttiProperty): TFieldType;
//    begin
//      case AKind of
//        tkInteger:
//          Result := ftInteger;
//        tkFloat:
//          begin // daniele teti 2014-05-23
//            if AProp.PropertyType.QualifiedName = 'System.TDate' then
//              Result := ftDate
//            else if AProp.PropertyType.QualifiedName = 'System.TDateTime' then
//              Result := ftDateTime
//            else if AProp.PropertyType.QualifiedName = 'System.TTime' then
//              Result := ftTime
//            else
//              Result := ftFloat;
//          end;
//        tkChar, tkString:
//          Result := ftString;
//        tkWChar, tkUString, tkLString, tkWString:
//          Result := ftWideString;
//        tkVariant:
//          Result := ftVariant;
//        tkArray:
//          Result := ftArray;
//        tkInterface:
//          Result := ftInterface;
//        tkInt64:
//          Result := ftLongWord;
//      else
//        Result := ftUnknown;
//      end;
//    end;
  {$ENDREGION}
begin
  PrefixLength := Length(AParamPrefix);
  LPrefixLengthPK := Length(AParamPrefixPK);  // dFlota

  Map := TObjectDictionary<string, TRttiProperty>.Create;
  try
    if Assigned(AObject) then
    begin
      _rttiType := ctx.GetType(AObject.ClassType);
      obj_fields := _rttiType.GetProperties;
      for obj_field in obj_fields do
      begin
        if TMVCSerializerHelper.HasAttribute<MVCColumnAttribute>(obj_field, obj_field_attr) then
        begin
          Map.Add(MVCColumnAttribute(obj_field_attr).FieldName.ToLower,
            obj_field);
        end
        else
        begin
          Map.Add(obj_field.Name.ToLower, obj_field);
        end
      end;
    end;
    for I := 0 to AFDParams.Count - 1 do
    begin
      {$REGION 'dFlota: Delete Original Code'}
//        pname := AFDParams[I].Name.ToLower;
//        if pname.StartsWith(AParamPrefix, True) then
//          Delete(pname, 1, PrefixLength);
//        if Map.TryGetValue(pname, f) then
//        begin
//          fv := f.GetValue(AObject);
//          // #001: Erro ao definir parametros
//          if ASetParamTypes then
//          begin
//            AFDParams[I].DataType := KindToFieldType(fv.Kind, f);
//          end;
//          // #001: FIM
//          // DmitryG - 2014-03-28
//          AFDParams[I].Value := fv.AsVariant;
//        end
//        else
//        begin
//          AFDParams[I].Clear;
//        end;
      {$ENDREGION}

      {$REGION 'dFlota'}
        LIsPrimarykey := False; // dFlota
        {$REGION 'AFDParams Values'}
          pname := AFDParams[I].Name.ToLower;
          if pname.StartsWith(AParamPrefix, True) then
            Delete(pname, 1, PrefixLength);
          if Map.TryGetValue(pname, f) then
          begin
            fv := f.GetValue(AObject);
          end
          else
          begin
            AFDParams[I].Clear;
          end;
        {$ENDREGION}

        {$REGION 'AFDParams PrimaryKeys Values'}
          if AParamPrefixPK <> '' then
          begin
            pnamePK := AFDParams[I].Name.ToLower;
            if pnamePK.StartsWith(AParamPrefixPK, True) then
            begin
              Delete(pnamePK, 1, LPrefixLengthPK);
              if Map.TryGetValue(pnamePK, f) then
              begin
                if TMVCSerializerHelper.HasAttribute<MVCColumnAttribute>(f, LMVCColumnAttribute) then
                begin
                  if MVCColumnAttribute(f).IsPK then
                    LIsPrimarykey := True;
                end;
                fv := f.GetValue(AObject);
              end
              else
              begin
                AFDParams[I].Clear;
              end;
            end;
          end;
        {$ENDREGION}

        LIsStream := False;
        if ASetParamTypes then
        begin
          if LIsPrimarykey then
            LDBParam := TDBParam.Create(pnamePK, fv)
          else
            LDBParam := TDBParam.Create(pname, fv);

          AFDParams[I].DataType := LDBParam.ParamType;
          {$REGION 'DataType'}
            case AFDParams[I].DataType of
              ftBlob, ftOraBlob, ftOraClob, ftStream, ftGraphic, ftMemo, ftFmtMemo, ftWideMemo:
              begin
                if not LDBParam.Value.IsEmpty then
                begin
                  LMemoryStream := TMemoryStream.Create;
                  try
                    LMemoryStream.LoadFromStream(LDBParam.Value.AsType<TStream>);
                    LMemoryStream.Position := 0;
                    if TMVCSerializerHelper.HasAttribute<MVCSerializeAsStringAttribute>(f, LMVCSerializeAsStringAttribute) then
                      AFDParams[I].LoadFromStream(LMemoryStream, ftMemo)
                    else
                      AFDParams[I].LoadFromStream(LMemoryStream, AFDParams[I].DataType)
                  finally
                    LMemoryStream.Free;
                  end;
                  LIsStream := True;
                end;
              end;
            end;
          {$ENDREGION}
          if not LIsStream then
          begin
            fv := LDBParam.Value;
            AFDParams[I].Value := fv.ToVariant;
          end;
        end;
      {$ENDREGION}
    end;
  finally
    Map.Free;
  end
end;

class function TFireDACUtils.InternalExecuteQuery(AQuery: TFDQuery; AObject: TObject;
  WithResult: boolean): Int64;
begin
  ObjectToParameters(AQuery.Params, AObject);
  Result := 0;
  if WithResult then
    AQuery.Open
  else
  begin
    AQuery.ExecSQL;
    Result := AQuery.RowsAffected;
  end;
end;

end.
