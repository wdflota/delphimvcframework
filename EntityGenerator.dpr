program EntityGenerator;

uses
  Vcl.Forms,
  fclsMain in 'fclsMain.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
