unit uDMPosto;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TdmPosto = class(TDataModule)
    conn: TFDConnection;
    qrGrid: TFDQuery;
    dsGrid: TDataSource;
    FDQuery: TFDQuery;
    FD_Delete: TFDQuery;
    FD_Consulta: TFDQuery;
    qrRelatorio: TFDQuery;
    procedure qrGridAfterOpen(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Conectar;
    procedure LoadGridAbastecimentos(prSomenteDia: Boolean);
    function isDadoValido(prTabela, prCampo, prChave: String): Boolean;
  end;

var
  dmPosto: TdmPosto;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses uConstPostoABC;

{$R *.dfm}

{ TdmPosto }

procedure TdmPosto.Conectar;
begin
   conn.Connected := true;
end;

function TdmPosto.isDadoValido(prTabela, prCampo, prChave: String): Boolean;
begin
   FDQuery.Active := false;
   FDQuery.SQL.Clear;
   FDQuery.SQL.Add('SELECT 1 FROM ' + prTabela + ' WHERE ' + prCampo + ' = ' + prChave);

   try
      FDQuery.Active := true;

      Result := not FDQuery.IsEmpty;
   except
      Result := false;
   end;
end;

procedure TdmPosto.LoadGridAbastecimentos(prSomenteDia: Boolean);
begin
   qrGrid.SQL.Clear;

   if prSomenteDia then
      qrGrid.SQL.Add(cSQL_ConsGrid_Dia)
   else
      qrGrid.SQL.Add(cSQL_ConsGrid);

   qrGrid.Active := true;
end;

procedure TdmPosto.qrGridAfterOpen(DataSet: TDataSet);
begin
   TFloatField(qrGrid.FieldByName('bdVlrProduto')).DisplayFormat := cMask_Money;
   TFloatField(qrGrid.FieldByName('bdVlrTotal')).DisplayFormat   := cMask_Money;
   TFloatField(qrGrid.FieldByName('bdVlrImposto')).DisplayFormat := cMask_Money;

   TFloatField(qrGrid.FieldByName('bdLitros')).DisplayFormat := cMask_Litros;
end;

end.