unit fclsMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Phys.FB, FireDAC.Phys.MySQL, FireDAC.Phys.PG, FireDAC.Phys.MSSQL,
  Model.Schema.Interfaces, Model.Schema.Factory;

type
  TFormMain = class(TForm)
    pnlTop: TPanel;
    lblDBType: TLabel;
    cboDBType: TComboBox;
    lblHost: TLabel;
    edtHost: TEdit;
    lblDatabase: TLabel;
    edtDatabase: TEdit;
    lblUser: TLabel;
    edtUser: TEdit;
    lblPassword: TLabel;
    edtPassword: TEdit;
    lblOutputPath: TLabel;
    edtOutputPath: TEdit;
    btnSelectPath: TButton;
    pnlBottom: TPanel;
    btnGenerate: TButton;
    memLog: TMemo;
    procedure btnGenerateClick(Sender: TObject);
    procedure btnSelectPathClick(Sender: TObject);
  private
    procedure Log(const AMessage: string);
    procedure RunGeneration;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.IOUtils,
  System.Generics.Collections,
  CodeGenerator.Entity,
  CodeGenerator.Registry;

{$R *.dfm}

procedure TFormMain.Log(const AMessage: string);
begin
  memLog.Lines.Add(FormatDateTime('[hh:nn:ss] ', Now) + AMessage);
  Application.ProcessMessages;
end;

procedure TFormMain.btnSelectPathClick(Sender: TObject);
var
  LFolder: string;
begin
  with TFileOpenDialog.Create(nil) do
  try
    Title := 'Seleccione la Carpeta de Salida';
    Options := Options + [fdoPickFolders];
    if Execute then
    begin
      LFolder := FileName;
      if not LFolder.EndsWith('\') then
      begin
        LFolder := LFolder + '\';
      end;
      edtOutputPath.Text := LFolder;
    end;
  finally
    Free;
  end;
end;

procedure TFormMain.btnGenerateClick(Sender: TObject);
begin
  memLog.Clear;
  try
    btnGenerate.Enabled := False;
    Application.ProcessMessages;
    RunGeneration;
  finally
    btnGenerate.Enabled := True;
  end;
end;

procedure TFormMain.RunGeneration;
var
  LConnection: TFDConnection;
  LReader: IDatabaseMetadataReader;
  LDBType: TDatabaseType;
  LDriverName: string;
  LTableNames: TArray<string>;
  LTableName: string;
  LTableInfo: TTableInfo;
  LGeneratedCode: string;
  LFileName: string;
  LEntityInfoList: TList<TEntityInfo>;
  LEntityInfo: TEntityInfo;
  LClassName: string;
begin
  if (edtHost.Text = '') or (edtDatabase.Text = '') or (edtUser.Text = '') or
     (edtPassword.Text = '') or (edtOutputPath.Text = '') then
  begin
    Log('Error: Por favor, complete todos los campos.');
    Exit;
  end;

  LConnection := TFDConnection.Create(nil);
  LEntityInfoList := TList<TEntityInfo>.Create;
  try
    LDBType := TDatabaseType(cboDBType.ItemIndex);
    case LDBType of
      dtFirebird: LDriverName := 'FB';
      dtMySQL: LDriverName := 'MySQL';
      dtPostgreSQL: LDriverName := 'PG';
      dtSQLServer: LDriverName := 'MSSQL';
    else
      LDriverName := '';
    end;

    LConnection.Params.DriverID := LDriverName;
    LConnection.Params.Add('Server=' + edtHost.Text);
    LConnection.Params.Add('Database=' + edtDatabase.Text);
    LConnection.Params.Add('User_Name=' + edtUser.Text);
    LConnection.Params.Add('Password=' + edtPassword.Text);
    LConnection.LoginPrompt := False;

    try
      Log('Conectando a la base de datos...');
      LConnection.Connected := True;
      Log('Conexión exitosa.');
    except
      on E: Exception do
      begin
        Log('Error de conexión: ' + E.Message);
        Exit;
      end;
    end;

    LReader := TMetadataReaderFactory.CreateReader(LDBType, LConnection);
    Log('Leyendo esquema de la base de datos...');
    LTableNames := LReader.GetTableNames;
    Log(Format('Se encontraron %d tablas.', [Length(LTableNames)]));

    Log('Iniciando generación de código ActiveRecord...');
    for LTableName in LTableNames do
    begin
      try
        Log('Generando entidad para la tabla: ' + LTableName);
        LTableInfo := LReader.GetTableDetails(LTableName);
        if Length(LTableInfo.Columns) = 0 then
        begin
          Log('  > Advertencia: La tabla no tiene columnas o no se pudo leer. Se omite.');
          continue;
        end;

        if LTableName.EndsWith('S') then
          LClassName := 'T' + LTableName.Substring(0, LTableName.Length - 1).ToPascalCase
        else
          LClassName := 'T' + LTableName.ToPascalCase;

        LEntityInfo.ClassName := LClassName;
        LEntityInfo.UnitName := 'Entities.' + LClassName.Substring(1);
        LEntityInfo.RegistryKey := LClassName.Substring(1).ToLower;

        LGeneratedCode := TEntityCodeGenerator.Generate(LTableInfo, 'Entities');
        LFileName := TPath.Combine(edtOutputPath.Text, LEntityInfo.UnitName + '.pas');
        TFile.WriteAllText(LFileName, LGeneratedCode);
        Log('  > Archivo de entidad guardado: ' + LFileName);
        LEntityInfoList.Add(LEntityInfo);

      except
        on E: Exception do
        begin
          Log(Format('  > Error generando la entidad para la tabla %s: %s', [LTableName, E.Message]));
        end;
      end;
    end;

    if LEntityInfoList.Count > 0 then
    begin
      Log('Generando archivo de registro de entidades...');
      LGeneratedCode := TRegistryCodeGenerator.Generate(LEntityInfoList.ToArray);
      LFileName := TPath.Combine(edtOutputPath.Text, 'Entities.Registry.pas');
      TFile.WriteAllText(LFileName, LGeneratedCode);
      Log('  > Archivo de registro guardado: ' + LFileName);
    end;

    Log('¡Generación de código finalizada!');

  finally
    LEntityInfoList.Free;
    LConnection.Free;
  end;
end;

end.
