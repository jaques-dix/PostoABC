unit uRelAbastecimentos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, Data.DB;

type
  RegParAbastecimento = record
     FDataDe,
     FDataAte,
     FBomba,
     FTanque,
     FCombustivel: String;
     FModelo,
     FAgrupador: Integer;
  end;

  TfrRelAbastecimentos = class(TForm)
    rlAbastecimentos: TRLReport;
    rlbdTitle: TRLBand;
    rllbTitle: TRLSystemInfo;
    rllbPage: TRLSystemInfo;
    rlbPagina: TRLLabel;
    rllbDatas: TRLLabel;
    RLBand1: TRLBand;
    RLBand2: TRLBand;
    RLBand3: TRLBand;
    dsDetalhe: TDataSource;
    RLDBText1: TRLDBText;
    RLDBText2: TRLDBText;
    RLDBText3: TRLDBText;
    RLDBText4: TRLDBText;
    tlbdLitros: TRLDBText;
    tlbdUnitario: TRLDBText;
    tlbdTotal: TRLDBText;
    tlbdImposto: TRLDBText;
    RLLabel1: TRLLabel;
    RLLabel2: TRLLabel;
    RLLabel3: TRLLabel;
    RLLabel4: TRLLabel;
    RLLabel5: TRLLabel;
    RLLabel6: TRLLabel;
    RLLabel7: TRLLabel;
    RLLabel8: TRLLabel;
    RLBand4: TRLBand;
    RLSystemInfo1: TRLSystemInfo;
    RLLabel9: TRLLabel;
    RLSystemInfo2: TRLSystemInfo;
    RLLabel10: TRLLabel;
    rlbdttImposto: TRLDBResult;
    rlbdttTotal: TRLDBResult;
    rlbdttUnitario: TRLDBResult;
    rlbdttLitros: TRLDBResult;
    RLLabel11: TRLLabel;
    procedure rlAbastecimentosBeforePrint(Sender: TObject;
      var PrintIt: Boolean);
  private
    { Private declarations }
    FParametros: RegParAbastecimento;
  public
    { Public declarations }
    procedure EmitirRelatorio(prParametros: RegParAbastecimento);
  end;

var
  frRelAbastecimentos: TfrRelAbastecimentos;

implementation

{$R *.dfm}

uses uDMPosto, uConstPostoABC, util, System.StrUtils;


{ TfrRelAbastecimentos }

procedure TfrRelAbastecimentos.EmitirRelatorio(prParametros: RegParAbastecimento);
var
   wSQL,
   wOrderBy: String;
begin
    //Vamos montar o SQL do relatório
    dmPosto.qrRelatorio.Active := false;
    dmPosto.qrRelatorio.SQL.Clear;

    if FParametros.FModelo = 0 then
       begin
          wSQL := cSQL_ConsGrid + #13;
          //Filtro de Data
          wSQL := wSQL + 'where (ab.bdDataHora >= ''' + getDataSQLite(FParametros.FDataDe) + ' 00:00:00'')'#13 +
                         '  and (ab.bdDataHora <= ''' + getDataSQLite(FParametros.FDataAte) + ' 23:59:59'')';

          wOrderBy := '';
          //Filtros de dados.... Aqui fica mais simples.. se já filtrou por algo mais específico, pode ignorar os outros
          if FParametros.FBomba <> '' then
             begin
                wSQL := wSQL + #13'  and (bomba.bdIDBomba = ' + FParametros.FBomba + ')';
                wOrderBy := 'bomba.bdIDBomba';
             end
          else
             if FParametros.FTanque <> '' then
                begin
                   wSQL := wSQL + #13'  and (tanque.bdIDTanques = ' + FParametros.FTanque + ')';
                   wOrderBy := 'tanque.bdIDTanques';
                end
          else
             if FParametros.FCombustivel <> '' then
                begin
                   wSQL := wSQL + #13'  and (comb.bdIDCombustivel = ' + FParametros.FCombustivel + ')';
                   wOrderBy := 'comb.bdIDCombustivel';
                end;


          wOrderBy := wOrderBy + IfThen(wOrderBy <> '', ',', '') + 'ab.bdIDAbastecimento';

          //Ordenaçăo...
          wSQL := wSQL + #13'order by ' + wOrderBy;
       end
    else
       begin

       end;

    dmPosto.qrRelatorio.SQL.Add(wSQL);
    dmPosto.qrRelatorio.Active := true;

    rlAbastecimentos.Preview();
end;

procedure TfrRelAbastecimentos.rlAbastecimentosBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
   if FParametros.FModelo = 0 then
      rlAbastecimentos.Title := 'Relatório analítico de abastecimentos'
   else
      rlAbastecimentos.Title := 'Relatório sintético de abastecimentos';

   rllbDatas.Caption := 'Período de ' + FParametros.FDataDe + ' até ' + FParametros.FDataAte;

   tlbdLitros.DisplayMask   := cMask_Litros;
   rlbdttLitros.DisplayMask   := cMask_Litros;
   tlbdUnitario.DisplayMask := cMask_Money;
   rlbdttUnitario.DisplayMask := cMask_Money;
   tlbdTotal.DisplayMask    := cMask_Money;
   rlbdttTotal.DisplayMask    := cMask_Money;
   tlbdImposto.DisplayMask  := cMask_Money;
   rlbdttImposto.DisplayMask  := cMask_Money;
end;

end.
