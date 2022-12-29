CREATE TABLE tbCombustíveis (
	bdIDCombustível integer PRIMARY KEY AUTOINCREMENT,
	bdDescricao varchar,
	bdVlrVenda decimal,
	bdPercImposto decimal
);

CREATE TABLE tbTanques (
	bdIDTanques integer PRIMARY KEY AUTOINCREMENT,
	bdDescricao varchar,
	bdCombustivel integer,
	bdCapacidade decimal
);

CREATE TABLE tbBombas (
	bdIDBomba integer PRIMARY KEY AUTOINCREMENT,
	bdTanque integer,
	bdDescricao varchar
);

CREATE TABLE tbAbastecimento (
	bdIDAbastecimento integer PRIMARY KEY AUTOINCREMENT,
	bdBomba integer,
	bdDataHora datetime,
	bdLitros decimal,
	bdVlrProduto decimal,
	bdVlrTotal decimal,
	bdVlrImposto decimal
);





