unit uControllerPadrao;

interface

uses Winapi.Windows, Vcl.StdCtrls, System.SysUtils, System.Classes, System.UITypes,
     uConstPostoABC, Vcl.ComCtrls, Data.DB, Vcl.Dialogs, Vcl.Controls;

type

   TControllerPadrao = class
  private
       procedure AtuStatusBar;
       procedure setStatusBar(const Value: TStatusBar);
       procedure SetModoTela(const Value: TModoTela);
       procedure getID(const Value: Integer);
   protected
       FModoTela: TModoTela;
       FStatusBar: TStatusBar;
       FID: Integer;
       FCarregandoTela: Boolean;
       FUltimoControl: TWinControl;
       FFechandoTela: Boolean;

       function PostData: String; virtual; abstract;
       function PostDataAuto: String; virtual; abstract;
       procedure LimpaTela; virtual; abstract;
       procedure CarregaTela; virtual; abstract;

       class function GetDeleteSQL: String; virtual;

       //Rotinas padr�es de manipula��o e comportamento dos componentes da tela.
       class function config_editMoney(prEdit: TEdit): Boolean;
       class function config_editLitros(prEdit: TEdit): Boolean;

       class procedure editMoney_KeyPress(Sender: TObject; var Key: Char);
       class procedure editMoney_Exit(Sender: TObject);

   public
      constructor Create;
      procedure StartControl; virtual; abstract;

      function PodeFechar: Boolean; virtual; abstract;
      class function Delete(prID: Integer; prQuery: TDataSet): Boolean;

      property ModoTela: TModoTela read FModoTela write SetModoTela;
      property StatusBar: TStatusBar read FStatusBar write setStatusBar;
      property ID: Integer read FID write getID;
   end;

implementation

uses util, uDMPosto;

{ TControllerPadrao }

procedure TControllerPadrao.AtuStatusBar;
begin
   if Assigned(FStatusBar) then
      begin
         case FModoTela of
            mtInsercao: FStatusBar.Panels[0].Text := 'Inserindo';
            mtConsulta: FStatusBar.Panels[0].Text := 'Consultando';
            mtEdicao  : FStatusBar.Panels[0].Text := 'Editando';
         end;
      end;
end;

class function TControllerPadrao.config_editLitros(prEdit: TEdit): Boolean;
begin
    Result := true;

    try
       //Configurando eventos
       prEdit.OnExit     := editMoney_Exit;
       prEdit.OnKeyPress := editMoney_KeyPress;

       //configurando apar�ncia
       prEdit.Text      := '0,000';
       prEdit.Alignment := taRightJustify;

    except
       Result := false;
    end;

end;

class function TControllerPadrao.config_editMoney(prEdit: TEdit): Boolean;
begin
    Result := true;

    try
       //Configurando eventos
       prEdit.OnExit     := editMoney_Exit;
       prEdit.OnKeyPress := editMoney_KeyPress;

       //configurando apar�ncia
       prEdit.Text      := '0,00';
       prEdit.Alignment := taRightJustify;

    except
       Result := false;
    end;
end;

constructor TControllerPadrao.Create;
begin
   FCarregandoTela := false;
   FUltimoControl  := nil;
   FFechandoTela     := false;
end;

class function TControllerPadrao.Delete(prID: Integer; prQuery: TDataSet): Boolean;
begin
   Result := true;

   try
      if MessageDlg('Deseja realmente excluir este registro?', mtConfirmation, [mbYes, mbNo], 0, mbNo) = mrYes then
         begin
            dmPosto.FD_Delete.Active := false;
            dmPosto.FD_Delete.SQL.Clear;
            dmPosto.FD_Delete.SQL.Add(GetDeleteSQL);

            if dmPosto.FD_Delete.ParamByName('ID') = nil then
               raise Exception.Create('SQL de exclus�o n�o possui filtro pelo ID!')
            else
               dmPosto.FD_Delete.ParamByName('ID').AsInteger := prID;

            dmPosto.FD_Delete.ExecSQL;

            //se informar alguma query de consulta, j� atualiza por aqui mesmo
            if prQuery <> nil then
               prQuery.Refresh;
         end;
   except
      on E:exception do
         begin
            Result := false;
            MessageDlg(E.Message, mtError, [mbOK], 0);
         end;
   end;
end;

class procedure TControllerPadrao.editMoney_KeyPress(Sender: TObject; var Key: Char);
begin
   Key := getTrataKeyMoney(Key);
end;

class function TControllerPadrao.GetDeleteSQL: String;
begin
   raise Exception.Create('Faltou implementar o GetDeleteSQL!');
end;

procedure TControllerPadrao.getID(const Value: Integer);
begin
  FID := Value;
end;

procedure TControllerPadrao.SetModoTela(const Value: TModoTela);
begin
   FModoTela := Value;
   AtuStatusBar;
end;

procedure TControllerPadrao.setStatusBar(const Value: TStatusBar);
begin
  FStatusBar := Value;

  FStatusBar.Panels.Clear;
  FStatusBar.Panels.Add;
  FStatusBar.Panels[0].Width := FStatusBar.Width;

  AtuStatusBar;
end;

class procedure TControllerPadrao.editMoney_Exit(Sender: TObject);
begin
   TEdit(Sender).Text := FormatFloat(cMask_Money, getValorMoney(TEdit(Sender).Text));
end;

end.
