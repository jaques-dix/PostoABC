unit uConsAbastecimentos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, uDMPosto;

type
  TfrConsAbastecimentos = class(TForm)
    pnTopo: TPanel;
    pnBottom: TPanel;
    grConsAbastecimentos: TDBGrid;
    lbTitulo: TLabel;
    spAbastecer: TSpeedButton;
    spRelatorio: TSpeedButton;
    ckListarDiaApenas: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure spAbastecerClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure spRelatorioClick(Sender: TObject);
    procedure grConsAbastecimentosKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure grConsAbastecimentosDblClick(Sender: TObject);
    procedure ckListarDiaApenasClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frConsAbastecimentos: TfrConsAbastecimentos;

implementation

{$R *.dfm}

uses uAbastecimento, uConstPostoABC, uAbastecerController, uSelAbastecimentos;

procedure TfrConsAbastecimentos.ckListarDiaApenasClick(Sender: TObject);
begin
   dmPosto.LoadGridAbastecimentos(ckListarDiaApenas.Checked);
end;

procedure TfrConsAbastecimentos.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   case Key of
      VK_F5: spAbastecerClick(Self);
      VK_F9: spRelatorioClick(Self);
      VK_ESCAPE: Close;
   end;
end;

procedure TfrConsAbastecimentos.FormShow(Sender: TObject);
var
   wIdx: Integer;
begin

   //Deixando os panels com o visual final desejado.
   //Em tempo de projeto de mantém para facilitar a visualização
   for wIdx := 0 to ComponentCount -1 do
      begin
         if Components[wIdx] is TPanel then
            begin
               with TPanel(Components[wIdx]) do
                  begin
                     Caption    := '';
                     BevelOuter := bvNone;
                  end;
            end;
      end;

   dmPosto.Conectar;
   dmPosto.LoadGridAbastecimentos(ckListarDiaApenas.Checked);
end;

procedure TfrConsAbastecimentos.grConsAbastecimentosDblClick(Sender: TObject);
var
   wTela: TfrAbastecimento;
begin
   wTela := TfrAbastecimento.Create(Self, mtEdicao, grConsAbastecimentos.DataSource.DataSet.FieldByName('bdIDAbastecimento').AsInteger);
   wTela.ShowModal;
end;

procedure TfrConsAbastecimentos.grConsAbastecimentosKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   case Key of
      VK_DELETE: TControlAbastecer.Delete(grConsAbastecimentos.DataSource.DataSet.FieldByName('bdIDAbastecimento').AsInteger, grConsAbastecimentos.DataSource.DataSet);
      VK_RETURN: grConsAbastecimentosDblClick(nil);
   end;
end;

procedure TfrConsAbastecimentos.spAbastecerClick(Sender: TObject);
var
   wTela: TfrAbastecimento;
begin
   wTela := TfrAbastecimento.Create(Self, mtInsercao);
   wTela.ShowModal;
end;

procedure TfrConsAbastecimentos.spRelatorioClick(Sender: TObject);
var
   wTela: TfrSelAbastecimentos;
begin
   //emissão de relatórios
   wTela := TfrSelAbastecimentos.Create(Self);
   wTela.ShowModal;
end;

end.
