program PostoABC;

uses
  Vcl.Forms,
  uConsAbastecimentos in 'uConsAbastecimentos.pas' {frConsAbastecimentos},
  uDMPosto in 'uDMPosto.pas' {dmPosto: TDataModule},
  uConstPostoABC in 'uConstPostoABC.pas',
  uAbastecimento in 'uAbastecimento.pas' {frAbastecimento},
  uAbastecerController in 'Controllers\uAbastecerController.pas',
  util in 'Misc\util.pas',
  uControllerPadrao in 'Controllers\uControllerPadrao.pas',
  uSelAbastecimentos in 'Relatorios\uSelAbastecimentos.pas' {frSelAbastecimentos},
  uRelAbastecimentos in 'Relatorios\uRelAbastecimentos.pas' {frRelAbastecimentos};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdmPosto, dmPosto);
  Application.CreateForm(TfrConsAbastecimentos, frConsAbastecimentos);
  Application.Run;
end.
