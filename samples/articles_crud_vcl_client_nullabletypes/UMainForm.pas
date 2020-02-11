unit UMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MVCFramework.RESTClient,
  MVCFramework.DataSet.Utils.NullableType,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Stan.StorageBin, FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet;

type
  TForm1 = class(TForm)
    ConSQL: TFDConnection;
    QryArticoli: TFDQuery;
    QryArticoliID: TIntegerField;
    QryArticoliCODICE: TWideStringField;
    QryArticoliDESCRIZIONE: TWideStringField;
    QryArticoliPREZZO: TFMTBCDField;
    QryArticoliFOTO: TBlobField;
    QryArticoliOSSERVAZIONI: TMemoField;
    MQryArticoli: TFDMemTable;
    MQryArticoliID: TIntegerField;
    MQryArticoliCODICE: TWideStringField;
    MQryArticoliDESCRIZIONE: TWideStringField;
    MQryArticoliPREZZO: TFMTBCDField;
    MQryArticoliFOTO: TBlobField;
    MQryArticoliOSSERVAZIONI: TMemoField;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MQryArticoliAfterOpen(DataSet: TDataSet);
  private
    { Private declarations }
    FLoading: Boolean;
    procedure ShowError(const AResponse: IRESTResponse);
  public
    { Public declarations }
    LRESTClient: MVCFramework.RESTClient.TRESTClient;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  LRESTClient := MVCFramework.RESTClient.TRESTClient.Create('http://192.168.0.101', 8080);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  LRESTClient.Free;
end;

procedure TForm1.MQryArticoliAfterOpen(DataSet: TDataSet);
var
  LRESTResponse: IRESTResponse;
begin
  // this a simple sychronous request...
  LRESTResponse := LRESTClient.doGET('/articles', []);
  if LRESTResponse.HasError then
  begin
    ShowError(LRESTResponse);
    Exit;
  end;

  DataSet.DisableControls;
  try
    FLoading := true;
    MQryArticoli.LoadFromJSONArrayString(LRESTResponse.BodyAsString);
    FLoading := false;
    MQryArticoli.First;
  finally
    DataSet.EnableControls;
  end;
end;

procedure TForm1.ShowError(const AResponse: IRESTResponse);
begin
  if AResponse.HasError then
    MessageDlg(
      AResponse.Error.HTTPError.ToString + ': ' + AResponse.Error.ExceptionMessage + sLineBreak +
      '[' + AResponse.Error.ExceptionClassname + ']',
      mtError, [mbOK], 0)
  else
    MessageDlg(
      AResponse.ResponseCode.ToString + ': ' + AResponse.ResponseText + sLineBreak +
      AResponse.BodyAsString,
      mtError, [mbOK], 0);
end;

end.
