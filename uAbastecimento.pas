unit uAbastecimento;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  uConstPostoABC, uAbastecerController, Vcl.ComCtrls, uFormBase;

type
  TfrAbastecimento = class(TfrFormBase)
    edBomba: TLabeledEdit;
    edData: TLabeledEdit;
    edProduto: TLabeledEdit;
    edDescBomba: TEdit;
    edDescCombustivel: TEdit;
    edLitros: TLabeledEdit;
    edUnitario: TLabeledEdit;
    edTotal: TLabeledEdit;
    edImposto: TLabeledEdit;
    bvLinha: TBevel;
    spContinuarRegistrando: TSpeedButton;
    spRegistrarFechar: TSpeedButton;
    sbStatus: TStatusBar;
    spSair: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure spSairClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

  private
    { Private declarations }
    wController: TControlAbastecer;

  public
    { Public declarations }
    constructor Create(prOwner: TComponent; prModoTela: TModoTela; prID: Integer = -1);

  end;

var
  frAbastecimento: TfrAbastecimento;

implementation

{$R *.dfm}

{ TfrAbastecimento }

constructor TfrAbastecimento.Create(prOwner: TComponent; prModoTela: TModoTela; prID: Integer = -1);
begin
   inherited Create(prOwner);

   wController := TControlAbastecer.Create;
   wController.ModoTela := prModoTela;
   wController.ID       := prID;
end;

procedure TfrAbastecimento.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose := wController.PodeFechar;
end;

procedure TfrAbastecimento.FormShow(Sender: TObject);
begin
   wController.Bomba    := edBomba;
   wController.Data     := edData;
   wController.Produto  := edProduto;
   wController.DescBomba:= edDescBomba;

   wController.DescCombustivel := edDescCombustivel;

   wController.Litros  := edLitros;
   wController.Unitario:= edUnitario;
   wController.Total   := edTotal;
   wController.Imposto := edImposto;

   wController.RegistrarFechar:= spRegistrarFechar;
   wController.RegistrarSempre:= spContinuarRegistrando;
   wController.FecharTela     := spSair;
   wController.StatusBar      := sbStatus;

   wController.Tela := Self;
   wController.StartControl;
end;

procedure TfrAbastecimento.spSairClick(Sender: TObject);
begin
   Close;
end;

end.
