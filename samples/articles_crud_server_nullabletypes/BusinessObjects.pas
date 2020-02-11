unit BusinessObjects;

interface

uses
  System.Classes,
  Spring,
  Spring.Persistence.Mapping.Attributes,
  MVCFramework.Commons,
  MVCFramework.Serializer.Commons;

type
  TBaseBO = class
  private
    FID: Integer;
    procedure SetID(const Value: Integer);
  public
    procedure CheckInsert; virtual;
    procedure CheckUpdate; virtual;
    procedure CheckDelete; virtual;
    [MVCColumn('ID', True)]
    property ID: Integer read FID write SetID;
  end;

  [MVCNameCase(ncLowerCase)]
  [Table('Articoli', '')]
  TArticle = class(TBaseBO)
  private
    FPrice: Nullable<Currency>;
    FCode: string;
    FDescription: Nullable<string>;
    FFoto: TMemoryStream;
    FObservation: TStringStream;
    FWeight: Nullable<Double>;
    FState: Nullable<Boolean>;
    FBirthDate: Nullable<TDate>;
    FBirthTime: Nullable<TTime>;
    FCreationDate: Nullable<TDateTime>;
    procedure SetCode(const Value: string);
    procedure SetDescription(const Value: Nullable<string>);
    procedure SetPrice(const Value: Nullable<Currency>);
    procedure SetFoto(const Value: TMemoryStream);
    procedure SetObservation(const Value: TStringStream);
    procedure SetWeight(const Value: Nullable<Double>);
    procedure SetState(const Value: Nullable<Boolean>);
    procedure SetBirthDate(const Value: Nullable<TDate>);
    procedure SetBirthTime(const Value: Nullable<TTime>);
    procedure SetCreationDate(const Value: Nullable<TDateTime>);
  public
    constructor Create;
    destructor Destroy; override;

    procedure CheckInsert; override;
    procedure CheckUpdate; override;
    procedure CheckDelete; override;
    [MVCColumn('CODICE', False)]
    property Code: string read FCode write SetCode;
    [MVCColumn('DESCRIZIONE', False)]
    property Description: Nullable<string> read FDescription write SetDescription;
    [MVCColumn('PREZZO', False)]
    property Price: Nullable<Currency> read FPrice write SetPrice;
    [MVCColumn('FOTO', False)]
    property Foto: TMemoryStream read FFoto write SetFoto;
    [MVCColumn('OSSERVAZIONI', False)]
    [MVCSerializeAsStringAttribute] // Necessary to indicate thet it is Text Type in the Database
    property Observation: TStringStream read FObservation write SetObservation;
    [MVCColumn('PESO', False)]
    property Weight: Nullable<Double> read FWeight write SetWeight;
    [MVCColumn('STATO', False)]
    property State: Nullable<Boolean> read FState write SetState;
    [MVCColumn('DATADINASCITA', False)]
    property BirthDate: Nullable<TDate> read FBirthDate write SetBirthDate;
    [MVCColumn('TEMPODINASCITA', False)]
    property BirthTime: Nullable<TTime> read FBirthTime write SetBirthTime;
    [MVCColumn('DATADICREAZIONE', False)]
    property CreationDate: Nullable<TDateTime> read FCreationDate write SetCreationDate;
  end;

implementation

uses
  System.SysUtils, System.RegularExpressions,
  MVCFramework.Serializer.JsonDataObjects.NullableTypes;

{ TBaseBO }

procedure TBaseBO.CheckDelete;
begin

end;

procedure TBaseBO.CheckInsert;
begin

end;

procedure TBaseBO.CheckUpdate;
begin

end;

procedure TBaseBO.SetID(const Value: Integer);
begin
  FID := Value;
end;

{ TArticolo }

procedure TArticle.CheckDelete;
begin
  inherited;
  if Price.Value <= 5 then
    raise Exception.Create('Cannot delete an article with a price below 5 euros (yes, it is a silly check)');
end;

procedure TArticle.CheckInsert;
begin
  inherited;
  if not TRegEx.IsMatch(Code, '^C[0-9]{2,4}') then
    raise Exception.Create('Article code must be in the format "CXX or CXXX or CXXXX"');
end;

procedure TArticle.CheckUpdate;
begin
  inherited;
  CheckInsert;
  if Price.Value <= 2 then
    raise Exception.Create('We cannot sell so low cost pizzas!');
end;

constructor TArticle.Create;
begin
  inherited;
  FFoto := TMemoryStream.Create;
  FObservation := TStringStream.Create;
end;

destructor TArticle.Destroy;
begin
  FFoto.Free;
  FObservation.Free;
  inherited;
end;

procedure TArticle.SetBirthDate(const Value: Nullable<TDate>);
begin
  FBirthDate := Value;
end;

procedure TArticle.SetBirthTime(const Value: Nullable<TTime>);
begin
  FBirthTime := Value;
end;

procedure TArticle.SetCode(const Value: string);
begin
  FCode := Value;
end;

procedure TArticle.SetCreationDate(const Value: Nullable<TDateTime>);
begin
  FCreationDate := Value;
end;

procedure TArticle.SetDescription(const Value: Nullable<string>);
begin
  FDescription := Value;
end;

procedure TArticle.SetFoto(const Value: TMemoryStream);
begin
  if Value <> nil then
    FFoto.LoadFromStream(Value)
  else
    FFoto.Clear;
end;

procedure TArticle.SetObservation(const Value: TStringStream);
begin
  FObservation.LoadFromStream(Value);
end;

procedure TArticle.SetWeight(const Value: Nullable<Double>);
begin
  FWeight := Value;
end;

procedure TArticle.SetPrice(const Value: Nullable<Currency>);
begin
  FPrice := Value;
end;

procedure TArticle.SetState(const Value: Nullable<Boolean>);
begin
  FState := Value;
end;

end.
