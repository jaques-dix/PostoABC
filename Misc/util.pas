unit util;

interface

function getValorMoney(prTexto: String): Extended;
function getValorNumerico(prTexto: String; prDecimais: Integer): Extended;
function getTrataKeyMoney(prKey: Char): Char;
function isDataValida(prData: String): Boolean;
function getSoNumeros(prNumero: String): String;
function getDataMaior(prData1, prData2: String): String;
function getDataSQLite(prData: String): String;

procedure addItemListaString(var prString: String; prItem: String);

implementation

uses System.SysUtils, System.Math, Winapi.Windows;

function getValorMoney(prTexto: String): Extended;
begin
   Result := getValorNumerico(prTexto, 2);
end;

function getValorNumerico(prTexto: String; prDecimais: Integer): Extended;
var
   wIdx: Integer;
   wTextoPuro: String;
begin
   if Trim(prTexto) = '' then
      Result := 0
   else
      begin
         try
            wTextoPuro := '';

            //pegando apenas os n�meros e o separador de decimais...
            for wIdx := 1 to Length(prTexto) do
               begin
                  if prTexto[wIdx] in ['0'..'9', ','] then
                     wTextoPuro := wTextoPuro + prTexto[wIdx];
               end;

            //se informar prDecimais = -1 ent�o n�o quer truncar o valor
            if prDecimais > -1 then
               begin
                  //Se houver separador de decimais...
                  if Pos(',', wTextoPuro) > 0 then
                     //deixando apenas a quantidade de decimais conforme o par�metro
                     wTextoPuro := Copy(wTextoPuro, 1, Pos(',', wTextoPuro) + IfThen(prDecimais = 0, -1, prDecimais));
               end;

            Result := StrToFloat(wTextoPuro);
         except
            Result := 0;
         end;
      end;
end;

function getSoNumeros(prNumero: String): String;
var
   wIdx: Integer;
begin
   if Trim(prNumero) = '' then
      Result := ''
   else
      begin
         try
            //pegando apenas os n�meros e o separador de decimais...
            for wIdx := 1 to Length(prNumero) do
               begin
                  if prNumero[wIdx] in ['0'..'9'] then
                     Result := Result + prNumero[wIdx];
               end;
         except
            Result := '';
         end;
      end;
end;

function getTrataKeyMoney(prKey: Char): Char;
begin
   if not (prKey in ['0'..'9', ',', Chr(VK_BACK), Chr(VK_RETURN), Chr(VK_ESCAPE)]) then
      Result := #0
   else
      Result := prKey;
end;

function getDataMaior(prData1, prData2: String): String;
begin
   if StrToDateDef(prData1, 0) > StrToDateDef(prData2, 0) then
      Result := prData1
   else
      Result := prData2;
end;

function isDataValida(prData: String): Boolean;
begin
   Result := StrToDateDef(prData, 0) > 0;
end;

procedure addItemListaString(var prString: String; prItem: String);
begin
   if prString <> '' then
      prString := prString + #13;

   prString := prString + prItem;
end;

function getDataSQLite(prData: String): String;
begin
   Result := FormatDateTime('yyyy-mm-dd', StrToDateDef(prData, 0));
end;

end.
