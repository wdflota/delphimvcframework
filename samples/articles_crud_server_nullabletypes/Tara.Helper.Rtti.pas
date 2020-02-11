unit Tara.Helper.Rtti;

interface

uses
  System.Rtti, System.TypInfo, System.DateUtils, System.StrUtils, Spring;

type
  TRttiPropertyHelper = class helper for TRttiProperty
  private
    { Private declarations }
  public
    { Public declarations }
    function IsNullable: Boolean;
    procedure SetNullableValue(AInstance: Pointer; ATypeInfo:
      System.TypInfo.PTypeInfo; AValue: Variant);
  end;

implementation

{ TRttiPropertyHelper }

function TRttiPropertyHelper.IsNullable: Boolean;
const
  LPrefixString = 'Nullable<';
var
  LTypeInfo: System.TypInfo.PTypeInfo;
begin
  LTypeInfo := Self.PropertyType.Handle;
  Result := Assigned(LTypeInfo) and (LTypeInfo.Kind = tkRecord)
                                and StartsText(LPrefixString, GetTypeName(LTypeInfo));
end;

procedure TRttiPropertyHelper.SetNullableValue(AInstance: Pointer;
  ATypeInfo: System.TypInfo.PTypeInfo; AValue: Variant);
//var
//  LUtils: IUtilSingleton;
begin
//  LUtils := TUtilSingleton.GetInstance;
  if ATypeInfo = TypeInfo(Nullable<Integer>) then
    if TVarData(AValue).VType <= varNull then
      Self.SetValue(AInstance, TValue.From(Nullable<Integer>.Create(AValue)))
    else
      Self.SetValue(AInstance, TValue.From(Nullable<Integer>.Create(Integer(AValue))))
  else
  if ATypeInfo = TypeInfo(Nullable<String>) then
    Self.SetValue(AInstance, TValue.From(Nullable<String>.Create(AValue)))
  else
  if ATypeInfo = TypeInfo(Nullable<TDateTime>) then
    if TVarData(AValue).VType <= varNull then
      Self.SetValue(AInstance, TValue.From(Nullable<TDateTime>.Create(AValue)))
    else
//      Self.SetValue(AInstance, TValue.From(Nullable<TDateTime>.Create(LUtils.Iso8601ToDateTime(AValue))))
      Self.SetValue(AInstance, TValue.From(Nullable<TDateTime>.Create(TDateTime(AValue))))

  else
  if ATypeInfo = TypeInfo(Nullable<Currency>) then
    if TVarData(AValue).VType <= varNull then
      Self.SetValue(AInstance, TValue.From(Nullable<Currency>.Create(AValue)))
    else
      Self.SetValue(AInstance, TValue.From(Nullable<Currency>.Create(Currency(AValue))))
  else
  if ATypeInfo = TypeInfo(Nullable<Double>) then
    if TVarData(AValue).VType <= varNull then
      Self.SetValue(AInstance, TValue.From(Nullable<Double>.Create(AValue)))
    else
      Self.SetValue(AInstance, TValue.From(Nullable<Double>.Create(Currency(AValue))))
  else
  if ATypeInfo = TypeInfo(Nullable<Boolean>) then
    Self.SetValue(AInstance, TValue.From(Nullable<Boolean>.Create(AValue)))
  else
  if ATypeInfo = TypeInfo(Nullable<TDate>) then
    if TVarData(AValue).VType <= varNull then
      Self.SetValue(AInstance, TValue.From(Nullable<TDate>.Create(AValue)))
    else
      Self.SetValue(AInstance, TValue.From(Nullable<TDate>.Create(TDate(AValue))))
  else
  if ATypeInfo = TypeInfo(Nullable<TTime>) then
    if TVarData(AValue).VType <= varNull then
      Self.SetValue(AInstance, TValue.From(Nullable<TTime>.Create(AValue)))
    else
      Self.SetValue(AInstance, TValue.From(Nullable<TTime>.Create(TTime(AValue))));
end;

end.
