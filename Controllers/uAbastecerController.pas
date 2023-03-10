unit uAbastecerController;

interface

uses Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, uControllerPadrao, SysUtils,
     System.Classes, Winapi.Windows;

type
   TControlAbastecer = class(TControllerPadrao)
   private
      FTela: TForm;
      FBomba: TLabeledEdit;
      FData: TLabeledEdit;
      FProduto: TLabeledEdit;
      FDescBomba: TEdit;
      FDescCombustivel: TEdit;
      FLitros: TLabeledEdit;
      FUnitario: TLabeledEdit;
      FTotal: TLabeledEdit;
      FImposto: TLabeledEdit;
      FRegistrarFechar: TSpeedButton;
      FRegistrarSempre: TSpeedButton;
      FFecharTela: TSpeedButton;
      FPercImposto: Extended;

      procedure setTela(const Value: TForm);
      procedure setBomba(const Value: TLabeledEdit);
      procedure setData(const Value: TLabeledEdit);
      procedure setDescBomba(const Value: TEdit);
      procedure setDescCombustivel(const Value: TEdit);
      procedure setImposto(const Value: TLabeledEdit);
      procedure setLitros(const Value: TLabeledEdit);
      procedure setProduto(const Value: TLabeledEdit);
      procedure setRegistrarFechar(const Value: TSpeedButton);
      procedure setRegistrarSempre(const Value: TSpeedButton);
      procedure setTotal(const Value: TLabeledEdit);
      procedure setUnitario(const Value: TLabeledEdit);
      procedure setFecharTela(const Value: TSpeedButton);

      procedure spRegistrarFecharClick(Sender: TObject);
      procedure spRegistrarSempreClick(Sender: TObject);
      procedure FBombaExit(Sender: TObject);
      procedure FLitrosExit(Sender: TObject);
      procedure FImpostoExit(Sender: TObject);
      procedure FBombaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
   protected
      function PostData: String; override;
      function PostDataAuto: String; override;
      class function GetDeleteSQL: String; override;
      procedure LimpaTela; override;
      procedure CarregaTela; override;
      procedure Consulta;

   public
      function PodeFechar: Boolean; override;
      procedure StartControl; override;

      property Tela: TForm  read FTela write setTela;
      property Bomba:TLabeledEdit read FBomba write setBomba;
      property Data:TLabeledEdit read FData write setData;
      property Produto:TLabeledEdit read FProduto write setProduto;
      property DescBomba:TEdit read FDescBomba write setDescBomba;
      property DescCombustivel:TEdit read FDescCombustivel write setDescCombustivel;
      property Litros:TLabeledEdit read FLitros write setLitros;
      property Unitario:TLabeledEdit read FUnitario write setUnitario;
      property Total:TLabeledEdit read FTotal write setTotal;
      property Imposto:TLabeledEdit read FImposto write setImposto;
      property RegistrarFechar:TSpeedButton read FRegistrarFechar write setRegistrarFechar;
      property RegistrarSempre:TSpeedButton read FRegistrarSempre write setRegistrarSempre;
      property FecharTela:TSpeedButton read FFecharTela write setFecharTela;
   end;

implementation

{ TControlAbastecer }

uses uConstPostoABC, uDMPosto, uConsAbastecimentos, util, Vcl.Dialogs, System.UITypes,
     StrUtils, uConsultaController;

procedure TControlAbastecer.StartControl;
begin
   inherited;

   FBomba.ReadOnly     := FModoTela = mtConsulta;
   FData.ReadOnly      := true;
   FProduto.ReadOnly   := true;
   FDescBomba.ReadOnly := true;

   FDescCombustivel.ReadOnly := true;

   FLitros.ReadOnly    := FModoTela = mtConsulta;
   FUnitario.ReadOnly  := true;
   FTotal.ReadOnly     := true;
   FImposto.ReadOnly   := true;

   RegistrarSempre.Visible := FModoTela = mtInsercao;

   //S? pra n?o ficar "um buraco" na tela...
   if not RegistrarSempre.Visible then
      FFecharTela.Left := RegistrarSempre.Left;

   case FModoTela of
      mtInsercao: LimpaTela;
      mtConsulta,
      mtEdicao  : CarregaTela;
   end;

   FUltimoControl := FImposto;
end;

procedure TControlAbastecer.CarregaTela;
begin
   inherited;

   FCarregandoTela := true;
   try
      dmPosto.FD_Consulta.Active := False;
      dmPosto.FD_Consulta.SQL.Clear;
      dmPosto.FD_Consulta.SQL.Add(cSQL_Abastecimento_Cons);
      dmPosto.FD_Consulta.ParamByName('ID').AsInteger := ID;
      dmPosto.FD_Consulta.Active := true;

      if dmPosto.FD_Consulta.IsEmpty then
         begin
            //Pode ter sido exclu?do por outro usu?rio, ent?o daremos o refresh antes de avisar
            dmPosto.qrGrid.Refresh;
            FFechandoTela := true; //Evitar perguntas
            FTela.Close;

            raise Exception.Create('Registro n?o encontrado!');
         end
      else
         begin
            FData.Text  := dmPosto.FD_Consulta.FieldByName('bdDataHora').AsString;
            FBomba.Text := dmPosto.FD_Consulta.FieldByName('bdBomba').AsString;

            FBombaExit(nil);

            FLitros.Text   := FormatFloat(cMask_Litros, dmPosto.FD_Consulta.FieldByName('bdLitros').AsFloat);
            FUnitario.Text := FormatFloat(cMask_Money, dmPosto.FD_Consulta.FieldByName('bdVlrProduto').AsFloat);
            FTotal.Text    := FormatFloat(cMask_Money, dmPosto.FD_Consulta.FieldByName('bdVlrTotal').AsFloat);
            FImposto.Text  := FormatFloat(cMask_Money, dmPosto.FD_Consulta.FieldByName('bdVlrImposto').AsFloat);
         end;
   finally
      FCarregandoTela := false;
   end;

end;

procedure TControlAbastecer.Consulta;
var
   wConsControll: TConsultaBomba;
begin
   wConsControll := TConsultaBomba.Create(FBomba);
   wConsControll.Inicializa;
end;

procedure TControlAbastecer.FBombaExit(Sender: TObject);
var
   wAtualiza: Boolean;
begin
   dmPosto.FDQuery.Active := False;
   dmPosto.FDQuery.SQL.Clear;
   dmPosto.FDQuery.SQL.Add(cSQL_Bomba_Cons);
   dmPosto.FDQuery.ParamByName('bomba').AsInteger := Trunc(getValorNumerico(FBomba.Text, 0));
   dmPosto.FDQuery.Active := true;

   if dmPosto.FDQuery.IsEmpty then
      begin
         FBomba.SetFocus;
         raise Exception.Create('Bomba n?o cadastrada!');
      end
   else
      begin
         DescBomba.Text       := dmPosto.FDQuery.FieldByName('bdDescricao').AsString;
         Produto.Text         := dmPosto.FDQuery.FieldByName('bdIDCombustivel').AsString;
         DescCombustivel.Text := dmPosto.FDQuery.FieldByName('descComb').AsString;

         wAtualiza := true;

         //Se editando a registro e est? passando pelo campo
         if (FModoTela <> mtInsercao) and (not FCarregandoTela) then
            begin
               if     (FPercImposto <> dmPosto.FDQuery.FieldByName('bdPercImposto').AsFloat)
                  or  (getValorMoney(Unitario.Text) <> dmPosto.FDQuery.FieldByName('bdVlrVenda').AsFloat)
               then
                  wAtualiza := MessageDlg('O par?metro de imposto e/ou valor unit?rio do produto est?o divergindo do cadastro.'#13'Deseja atualizar?', mtConfirmation, [mbYes, mbNo], 0, mbNo) = mrYes;
            end;

         if wAtualiza then
            begin
               Unitario.Text := FormatFloat(cMask_Money, dmPosto.FDQuery.FieldByName('bdVlrVenda').AsFloat);
               FPercImposto  := dmPosto.FDQuery.FieldByName('bdPercImposto').AsFloat;

               FLitrosExit(nil);
            end
      end;

end;

procedure TControlAbastecer.FBombaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key = VK_F7 then
      Consulta;

end;

procedure TControlAbastecer.FImpostoExit(Sender: TObject);
begin
   FImposto.Text := FormatFloat(cMask_Money, getValorMoney(FImposto.Text));

   if FTela.ActiveControl = FData then
      PostDataAuto;
end;

procedure TControlAbastecer.FLitrosExit(Sender: TObject);
begin
   TEdit(Sender).Text := FormatFloat(cMask_Litros, getValorMoney(TEdit(Sender).Text));

   if FModoTela <> mtConsulta then
      begin
         Total.Text   := FormatFloat(cMask_Money, getValorNumerico(Unitario.Text, 2) * getValorNumerico(Litros.Text, 2));
         Imposto.Text := FormatFloat(cMask_Money, getValorNumerico(Total.Text, 2) * FPercImposto / 100);
      end;
end;

class function TControlAbastecer.GetDeleteSQL: String;
begin
   Result := cSQL_Abastecimento_Del;
end;

procedure TControlAbastecer.LimpaTela;
begin
  inherited;

   FBomba.Text     := '';
   FData.Text      := FormatDateTime('dd/mm/yyyy hh:mm:ss', now);
   FProduto.Text   := '';
   FDescBomba.Text := '';
   FDescCombustivel.Text := '';
   FLitros.Text   := '0,000';
   FUnitario.Text := '0,00';
   FTotal.Text    := '0,00';
   FImposto.Text  := '0,00';
   FPercImposto   := 0;

   FBomba.SetFocus;
end;

function TControlAbastecer.PodeFechar: Boolean;
begin
   Result := true;

   if (not FFechandoTela) and ((FModoTela = mtEdicao) or (getValorNumerico(FBomba.Text, 0) > 0)) then
      Result := MessageDlg(IfThen(FModoTela = mtInsercao, cMsg_FecharInsercao, cMsg_FecharEdicao), mtConfirmation, [mbYes, mbNo], 0, mbNo) = mrYes;

end;

function TControlAbastecer.PostData: String;
begin
   Result := '';

   try
      dmPosto.FDQuery.Active := false;
      dmPosto.FDQuery.SQL.Clear;

      if FModoTela = mtInsercao then
         dmPosto.FDQuery.SQL.Add(cSQL_Abastecimento_Ins)
      else
         begin
            dmPosto.FDQuery.SQL.Add(cSQL_Abastecimento_Edit);
            dmPosto.FDQuery.ParamByName('ID').AsInteger := FID;
         end;

      dmPosto.FDQuery.ParamByName('bdBomba').AsInteger     := Trunc(getValorNumerico(FBomba.Text, 0));
      dmPosto.FDQuery.ParamByName('bdDataHora').AsDateTime := now;
      dmPosto.FDQuery.ParamByName('bdLitros').AsFloat      := getValorNumerico(FLitros.Text, 3);
      dmPosto.FDQuery.ParamByName('bdVlrProduto').AsFloat  := getValorMoney(FUnitario.Text);
      dmPosto.FDQuery.ParamByName('bdVlrTotal').AsFloat    := getValorMoney(FTotal.Text);
      dmPosto.FDQuery.ParamByName('bdVlrImposto').AsFloat  := getValorMoney(FImposto.Text);

      dmPosto.FDQuery.ExecSQL;

      //Atualizando o grid automaticamente
      dmPosto.qrGrid.Refresh;
   except
      on E:exception do
         Result := E.Message;
   end;
end;

function TControlAbastecer.PostDataAuto: String;
begin
   if FTela.ActiveControl = FData then
      begin
         if FModoTela = mtInsercao then
            FRegistrarSempre.Click
         else
            FRegistrarFechar.Click;
      end;
end;

procedure TControlAbastecer.setBomba(const Value: TLabeledEdit);
begin
  FBomba := Value;
  FBomba.Hint   := 'F7 consultar';
  FBomba.ShowHint := true;
  FBomba.OnExit := FBombaExit;
  FBomba.OnKeyDown := FBombaKeyDown;
end;

procedure TControlAbastecer.setData(const Value: TLabeledEdit);
begin
  FData := Value;
end;

procedure TControlAbastecer.setDescBomba(const Value: TEdit);
begin
  FDescBomba := Value;
end;

procedure TControlAbastecer.setDescCombustivel(const Value: TEdit);
begin
  FDescCombustivel := Value;
end;

procedure TControlAbastecer.setFecharTela(const Value: TSpeedButton);
begin
  FFecharTela := Value;
end;

procedure TControlAbastecer.setImposto(const Value: TLabeledEdit);
begin
  FImposto := Value;
  config_editMoney(TEdit(FImposto));
  FImposto.OnExit := FImpostoExit;
end;

procedure TControlAbastecer.setLitros(const Value: TLabeledEdit);
begin
  FLitros := Value;
  config_editLitros(TEdit(FLitros));
  FLitros.OnExit := FLitrosExit;
end;

procedure TControlAbastecer.setProduto(const Value: TLabeledEdit);
begin
  FProduto := Value;
end;

procedure TControlAbastecer.setRegistrarFechar(const Value: TSpeedButton);
begin
  FRegistrarFechar := Value;
  FRegistrarFechar.OnClick := spRegistrarFecharClick;
end;

procedure TControlAbastecer.setRegistrarSempre(const Value: TSpeedButton);
begin
  FRegistrarSempre := Value;
  FRegistrarSempre.OnClick := spRegistrarSempreClick;
end;

procedure TControlAbastecer.setTela(const Value: TForm);
begin
  FTela := Value;
end;

procedure TControlAbastecer.setTotal(const Value: TLabeledEdit);
begin
  FTotal := Value;
  config_editMoney(TEdit(FTotal));
end;

procedure TControlAbastecer.setUnitario(const Value: TLabeledEdit);
begin
  FUnitario := Value;
  config_editMoney(TEdit(FUnitario));
end;

procedure TControlAbastecer.spRegistrarFecharClick(Sender: TObject);
begin
   if PostData = '' then
      begin
         FFechandoTela := true; //Evitar perguntas
         FTela.Close;
      end;
end;

procedure TControlAbastecer.spRegistrarSempreClick(Sender: TObject);
begin
   if PostData = '' then
      LimpaTela;
end;

end.
