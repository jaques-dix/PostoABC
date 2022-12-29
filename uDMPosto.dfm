object dmPosto: TdmPosto
  OldCreateOrder = False
  Height = 415
  Width = 634
  object conn: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=C:\Projetos\Posto ABC\Dados\base.sdb'
      'LockingMode=Exclusive')
    LoginPrompt = False
    Left = 16
    Top = 16
  end
  object qrGrid: TFDQuery
    AfterOpen = qrGridAfterOpen
    Connection = conn
    SQL.Strings = (
      
        'Select ab.bdIDAbastecimento, ab.bdDataHora, bomba.bdDescricao AS' +
        ' Bomba, comb.bdDescricao AS Combustivel, ab.bdLitros, ab.bdVlrPr' +
        'oduto, ab.bdVlrTotal, ab.bdVlrImposto '
      'from tbAbastecimento Ab'
      '   inner join tbBombas bomba on bomba.bdIDBomba = ab.bdBomba'
      
        '   inner join tbTanques tanque on tanque.bdIDTanques = bomba.bdT' +
        'anque'
      
        '   inner join tbCombustiveis comb on comb.bdIDCombustivel = tanq' +
        'ue.bdCombustivel')
    Left = 88
    Top = 16
  end
  object dsGrid: TDataSource
    DataSet = qrGrid
    Left = 152
    Top = 16
  end
  object FDQuery: TFDQuery
    Connection = conn
    Left = 88
    Top = 72
  end
  object FD_Delete: TFDQuery
    Connection = conn
    Left = 152
    Top = 72
  end
  object FD_Consulta: TFDQuery
    Connection = conn
    Left = 216
    Top = 72
  end
  object qrRelatorio: TFDQuery
    Connection = conn
    Left = 88
    Top = 128
  end
end
