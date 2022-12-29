unit uSelAbastecimentos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.Buttons,
  Vcl.ExtCtrls;

type
  TfrSelAbastecimentos = class(TForm)
    gbFiltros: TGroupBox;
    edDataDe: TMaskEdit;
    edDataAte: TMaskEdit;
    lbPeriodoAte: TLabel;
    lbPeriodoDe: TLabel;
    edBomba: TLabeledEdit;
    edProduto: TLabeledEdit;
    edDescBomba: TEdit;
    edDescCombustivel: TEdit;
    edTanque: TLabeledEdit;
    edDescTanque: TEdit;
    gbParametros: TGroupBox;
    rgRelatorio: TRadioGroup;
    Label1: TLabel;
    cbAgrupar: TComboBox;
    spEmitir: TSpeedButton;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure spEmitirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edDataDeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    function fValidaDadosTela: Boolean;

  public
    { Public declarations }
  end;

var
  frSelAbastecimentos: TfrSelAbastecimentos;

implementation

{$R *.dfm}

uses util, uDMPosto, uRelAbastecimentos;

procedure TfrSelAbastecimentos.edDataDeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   //Atalho para o dia de hoje...
   if Key = VK_F2 then
      TEdit(Sender).Text := FormatDateTime('dd/mm/yyyy', date);
end;

procedure TfrSelAbastecimentos.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
      begin
         SelectNext(ActiveControl as TWinControl, True, True);
         Key := #0;
      end;
end;

procedure TfrSelAbastecimentos.FormShow(Sender: TObject);
begin
   //J� vamos sugerir os �ltimos 30 dias aqui
   //Poderia ser tamb�m o 1 dia do m�s corrente, vai do gosto aqui...
   edDataAte.Text := FormatDateTime('dd/mm/yyyy', date);
   edDataDe.Text  := FormatDateTime('dd/mm/yyyy', date - 30);
end;

function TfrSelAbastecimentos.fValidaDadosTela: Boolean;
var
   wMsg: String;
begin
   Result := false;
   wMsg   := '';

   //Validando se as datas est�o OK
   if getSoNumeros(edDataDe.Text) = '' then
      addItemListaString(wMsg, '* informe a data inicial;')
   else
      if not isDataValida(edDataDe.Text) then
         addItemListaString(wMsg, '* data inicial inv�lida;');

   if getSoNumeros(edDataAte.Text) = '' then
      addItemListaString(wMsg, '* informe a data final;')
   else
      if not isDataValida(edDataAte.Text) then
         addItemListaString(wMsg, '* data final inv�lida;');

   //Se j� tiver erros aqui, nem adianta querer verificar se a data est� correta ou n�o
   if wMsg = '' then
      begin
         if getDataMaior(edDataDe.Text, edDataAte.Text) = edDataDe.Text then
            addItemListaString(wMsg, '* data inicial n�o pode ser superior a data final;');
      end;

   if getSoNumeros(edBomba.Text) <> '' then
      begin
         if not dmPosto.isDadoValido('tbBombas', 'bdIDBomba', getSoNumeros(edBomba.Text)) then
            addItemListaString(wMsg, '* bomba n�o cadastrada;');
      end
   else
      if getSoNumeros(edTanque.Text) <> '' then
         begin
            if not dmPosto.isDadoValido('tbTanques', 'bdIDTanques', getSoNumeros(edTanque.Text)) then
               addItemListaString(wMsg, '* tanque n�o cadastrado;');
         end
   else
      if getSoNumeros(edProduto.Text) <> '' then
         begin
            if not dmPosto.isDadoValido('tbCombustiveis', 'bdIDCombustivel', getSoNumeros(edProduto.Text)) then
               addItemListaString(wMsg, '* combust�vel n�o cadastrado;');
         end;

   if wMsg <> '' then
      MessageDlg('As seguintes inconsist�ncias foram entradas nos filtros/par�metros:'#13#13+
                 wMsg + #13#13 + 'Verifique!', mtWarning, [mbOK], 0)
   else
      Result := true;
end;

procedure TfrSelAbastecimentos.spEmitirClick(Sender: TObject);
var
   wParametros: RegParAbastecimento;
   wTela: TfrRelAbastecimentos;
begin
   if fValidaDadosTela then
      begin
         wParametros.FDataDe     := edDataDe.Text;
         wParametros.FDataAte    := edDataAte.Text;
         wParametros.FBomba      := getSoNumeros(edBomba.Text);
         wParametros.FTanque     := getSoNumeros(edTanque.Text);
         wParametros.FCombustivel:= getSoNumeros(edProduto.Text);

         wParametros.FModelo    := rgRelatorio.ItemIndex;
         wParametros.FAgrupador := cbAgrupar.ItemIndex;

         wTela := TfrRelAbastecimentos.Create(Self);
         wTela.pSetParametros(wParametros);
         wTela.ShowModal;
      end;

   edDataDe.SetFocus;
end;

end.
