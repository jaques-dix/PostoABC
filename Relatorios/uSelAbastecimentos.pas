unit uSelAbastecimentos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.Buttons,
  Vcl.ExtCtrls, Data.DB, RLReport;

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
    rlAbastecimentos: TRLReport;
    rlbdTitle: TRLBand;
    rllbTitle: TRLSystemInfo;
    rllbPage: TRLSystemInfo;
    rlbPagina: TRLLabel;
    rllbDatas: TRLLabel;
    RLBand1: TRLBand;
    rllID: TRLLabel;
    RLLabel2: TRLLabel;
    RLLabel3: TRLLabel;
    RLLabel4: TRLLabel;
    RLLabel5: TRLLabel;
    RLLabel7: TRLLabel;
    RLLabel8: TRLLabel;
    RLBand2: TRLBand;
    rlbdImposto: TRLBand;
    rlBDID: TRLDBText;
    RLDBText2: TRLDBText;
    RLDBText3: TRLDBText;
    RLDBText4: TRLDBText;
    tlbdLitros: TRLDBText;
    tlbdTotal: TRLDBText;
    tlbdImposto: TRLDBText;
    RLBand4: TRLBand;
    RLSystemInfo1: TRLSystemInfo;
    RLLabel9: TRLLabel;
    RLSystemInfo2: TRLSystemInfo;
    RLLabel10: TRLLabel;
    dsDetalhe: TDataSource;
    RLTTID: TRLLabel;
    RllTotais: TRLLabel;
    rlbdttLitros: TRLDBResult;
    rlbdttTotal: TRLDBResult;
    rlbdttImposto: TRLDBResult;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure spEmitirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edDataDeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure rlAbastecimentosBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure rlbdttLitrosCompute(Sender: TObject; var Value: Variant;
      var AText: string; var ComputeIt: Boolean);
    procedure rlbdttTotalCompute(Sender: TObject; var Value: Variant;
      var AText: string; var ComputeIt: Boolean);
    procedure rlbdttImpostoCompute(Sender: TObject; var Value: Variant;
      var AText: string; var ComputeIt: Boolean);
    procedure RLDBText2BeforePrint(Sender: TObject; var AText: string;
      var PrintIt: Boolean);
    procedure rllIDBeforePrint(Sender: TObject; var AText: string;
      var PrintIt: Boolean);
  private
    { Private declarations }
    FParametros: RegParAbastecimento;

    function fValidaDadosTela: Boolean;
    procedure EmitirRelatorio;

  public
    { Public declarations }
  end;

var
  frSelAbastecimentos: TfrSelAbastecimentos;

implementation

{$R *.dfm}

uses util, uDMPosto, {uRelAbastecimentos, }uConstPostoABC, System.StrUtils;

procedure TfrSelAbastecimentos.edDataDeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   //Atalho para o dia de hoje...
   if Key = VK_F2 then
      TEdit(Sender).Text := FormatDateTime('dd/mm/yyyy', date)
   else
      inherited;
end;

procedure TfrSelAbastecimentos.EmitirRelatorio;
var
   wSQL,
   wOrderBy: String;

   procedure AddWhere;
   begin
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
   end;
begin
    //Vamos montar o SQL do relatório
    dmPosto.qrRelatorio.Active := false;
    dmPosto.qrRelatorio.SQL.Clear;

    if FParametros.FModelo = 0 then
       begin
          wSQL := cSQL_ConsGrid + #13;

          AddWhere;

          wOrderBy := wOrderBy + IfThen(wOrderBy <> '', ',', '') + 'ab.bdIDAbastecimento';
          //Ordenação...
          wSQL := wSQL + #13'order by ' + wOrderBy;
       end
    else
       begin
          wSQL := 'Select Date(ab.bdDataHora) AS bdDataHora, bomba.bdDescricao AS Bomba, comb.bdDescricao AS Combustivel,'#13 +
                  '       SUM(CAST(ab.bdLitros AS DECIMAL(15,3))) AS bdLitros, SUM(CAST(ab.bdVlrTotal AS DECIMAL(15,2))) AS bdVlrTotal, SUM(CAST(ab.bdVlrImposto AS DECIMAL(15,2))) AS bdVlrImposto'#13 +
                  'from tbAbastecimento Ab'#13 +
                  '   inner join tbBombas bomba on bomba.bdIDBomba = ab.bdBomba'#13 +
                  '   inner join tbTanques tanque on tanque.bdIDTanques = bomba.bdTanque'#13 +
                  '   inner join tbCombustiveis comb on comb.bdIDCombustivel = tanque.bdCombustivel'#13;

          AddWhere;

          wSQL := wSQL + #13'group by 1, 2, 3'#13 +
                            'order by 1, 2';
       end;

    dmPosto.qrRelatorio.SQL.Add(wSQL);
    dmPosto.qrRelatorio.Active := true;

    rlAbastecimentos.Preview();
end;

procedure TfrSelAbastecimentos.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key = VK_F9 then
      spEmitir.Click
   else
      if Key = VK_ESCAPE then
         Close;
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
   Width := gbFiltros.Width + 19;
   //Já vamos sugerir os últimos 30 dias aqui
   //Poderia ser também o 1 dia do mês corrente, vai do gosto aqui...
   edDataAte.Text := FormatDateTime('dd/mm/yyyy', date);
   edDataDe.Text  := FormatDateTime('dd/mm/yyyy', date - 30);
end;

function TfrSelAbastecimentos.fValidaDadosTela: Boolean;
var
   wMsg: String;
begin
   Result := false;
   wMsg   := '';

   //Validando se as datas estão OK
   if getSoNumeros(edDataDe.Text) = '' then
      addItemListaString(wMsg, '* informe a data inicial;')
   else
      if not isDataValida(edDataDe.Text) then
         addItemListaString(wMsg, '* data inicial inválida;');

   if getSoNumeros(edDataAte.Text) = '' then
      addItemListaString(wMsg, '* informe a data final;')
   else
      if not isDataValida(edDataAte.Text) then
         addItemListaString(wMsg, '* data final inválida;');

   //Se já tiver erros aqui, nem adianta querer verificar se a data está correta ou não
   if wMsg = '' then
      begin
         if (edDataDe.Text <> edDataAte.Text) and (getDataMaior(edDataDe.Text, edDataAte.Text) = edDataDe.Text) then
            addItemListaString(wMsg, '* data inicial não pode ser superior a data final;');
      end;

   if getSoNumeros(edBomba.Text) <> '' then
      begin
         if not dmPosto.isDadoValido('tbBombas', 'bdIDBomba', getSoNumeros(edBomba.Text)) then
            addItemListaString(wMsg, '* bomba não cadastrada;');
      end
   else
      if getSoNumeros(edTanque.Text) <> '' then
         begin
            if not dmPosto.isDadoValido('tbTanques', 'bdIDTanques', getSoNumeros(edTanque.Text)) then
               addItemListaString(wMsg, '* tanque não cadastrado;');
         end
   else
      if getSoNumeros(edProduto.Text) <> '' then
         begin
            if not dmPosto.isDadoValido('tbCombustiveis', 'bdIDCombustivel', getSoNumeros(edProduto.Text)) then
               addItemListaString(wMsg, '* combustível não cadastrado;');
         end;

   if wMsg <> '' then
      MessageDlg('As seguintes inconsistências foram entradas nos filtros/parâmetros:'#13#13+
                 wMsg + #13#13 + 'Verifique!', mtWarning, [mbOK], 0)
   else
      Result := true;
end;

procedure TfrSelAbastecimentos.rlAbastecimentosBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
   if FParametros.FModelo = 0 then
      begin
         rlAbastecimentos.Title := 'Relatório analítico de abastecimentos';
         RLLabel2.Caption := 'Data/hora';
      end
   else
      begin
         rlAbastecimentos.Title := 'Relatório sintético de abastecimentos';
         RLLabel2.Caption := 'Data';
      end;

   rllbDatas.Caption := 'Período de ' + FParametros.FDataDe + ' até ' + FParametros.FDataAte;

   tlbdLitros.DisplayMask   := cMask_Litros;
   rlbdttLitros.DisplayMask   := cMask_Litros;
   tlbdTotal.DisplayMask    := cMask_Money;
   rlbdttTotal.DisplayMask    := cMask_Money;
   tlbdImposto.DisplayMask  := cMask_Money;
   rlbdttImposto.DisplayMask  := cMask_Money;
end;

procedure TfrSelAbastecimentos.rlbdttImpostoCompute(Sender: TObject; var Value: Variant; var AText: string; var ComputeIt: Boolean);
begin
   Value := dmPosto.qrRelatorio.FieldByName('bdVlrImposto').AsFloat;
end;

procedure TfrSelAbastecimentos.rlbdttLitrosCompute(Sender: TObject; var Value: Variant; var AText: string; var ComputeIt: Boolean);
begin
   Value := dmPosto.qrRelatorio.FieldByName('bdLitros').AsFloat;
end;

procedure TfrSelAbastecimentos.rlbdttTotalCompute(Sender: TObject; var Value: Variant; var AText: string; var ComputeIt: Boolean);
begin
   Value := dmPosto.qrRelatorio.FieldByName('bdVlrTotal').AsFloat;
end;

procedure TfrSelAbastecimentos.RLDBText2BeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
   AText := Copy(AText, 9, 2) + '/' + Copy(AText, 6, 2) + '/' + Copy(AText, 1, 4);
end;

procedure TfrSelAbastecimentos.rllIDBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
   if FParametros.FModelo <> 0 then
      AText := '';
end;

procedure TfrSelAbastecimentos.spEmitirClick(Sender: TObject);
begin
   if fValidaDadosTela then
      begin
         FParametros.FDataDe     := edDataDe.Text;
         FParametros.FDataAte    := edDataAte.Text;
         FParametros.FBomba      := getSoNumeros(edBomba.Text);
         FParametros.FTanque     := getSoNumeros(edTanque.Text);
         FParametros.FCombustivel:= getSoNumeros(edProduto.Text);

         FParametros.FModelo    := rgRelatorio.ItemIndex;
         FParametros.FAgrupador := cbAgrupar.ItemIndex;

         EmitirRelatorio;
      end;

   edDataDe.SetFocus;
end;

end.
