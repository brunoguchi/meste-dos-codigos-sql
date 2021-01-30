/*=========================================================================================================================================================*/
-- =============== QUEST�O 1 E 2 =============== --
/*=========================================================================================================================================================*/

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'Cliente')
CREATE TABLE DBO.Cliente (
	Id int identity(1,1),
	Nome varchar(100) not null
	PRIMARY KEY (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'Categoria')
CREATE TABLE DBO.Categoria (
	Id int identity(1,1),
	Descricao varchar(100) not null
	PRIMARY KEY (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'EstadoPedido')
CREATE TABLE DBO.EstadoPedido (
	Id int identity(1,1),
	Descricao varchar(100) not null
	PRIMARY KEY (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'EstadoHistorico')
CREATE TABLE DBO.EstadoHistorico (
	Id int identity(1,1),
	Descricao varchar(100) not null
	PRIMARY KEY (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'Produto')
CREATE TABLE DBO.Produto (
	Id int identity(1,1),
	Descricao varchar(100) not null,
	CategoriaId int not null,
	PRIMARY KEY (Id),
	FOREIGN KEY (CategoriaId) REFERENCES Categoria (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'Carrinho')
CREATE TABLE DBO.Carrinho (
	ClienteId int,
	ProdutoId int,
	PRIMARY KEY (ClienteId, ProdutoId),
	FOREIGN KEY (ClienteId) REFERENCES Cliente (Id),
	FOREIGN KEY (ProdutoId) REFERENCES Produto (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'Pedido')
CREATE TABLE DBO.Pedido (
	Id int identity(1,1),
	DataLancamento datetime not null,
	ClienteId int not null,
	EstadoId int not null,
	PRIMARY KEY (Id),
	FOREIGN KEY (ClienteId) REFERENCES Cliente (Id),
	FOREIGN KEY (EstadoId) REFERENCES EstadoPedido (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'PedidoDetalhes')
CREATE TABLE DBO.PedidoDetalhes (
	PedidoId int,
	ProdutoId int,
	Quantidade int not null,
	Valor float not null,
	PRIMARY KEY (PedidoId, ProdutoId),
	FOREIGN KEY (PedidoId) REFERENCES Pedido (Id),
	FOREIGN KEY (ProdutoId) REFERENCES Produto (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'PedidoHistorico')
CREATE TABLE DBO.PedidoHistorico (
	Id int identity(1,1),
	DataLancamento datetime not null,
	EstadoId int not null,
	PedidoId int not null,
	PRIMARY KEY (Id),
	FOREIGN KEY (PedidoId) REFERENCES Pedido (Id),
	FOREIGN KEY (EstadoId) REFERENCES EstadoHistorico (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'NotaFiscal')
CREATE TABLE DBO.NotaFiscal (
	Id int identity(1,1),
	DataEmissao datetime not null,
	PedidoId int not null,
	ClienteId int not null,
	PRIMARY KEY (Id),
	FOREIGN KEY (PedidoId) REFERENCES Pedido (Id),
	FOREIGN KEY (ClienteId) REFERENCES Cliente (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'NotaFiscalDetalhes')
CREATE TABLE DBO.NotaFiscalDetalhes (
	NotaFiscalId int not null,
	ProdutoId int not null,
	Quantidade int not null,
	Valor float not null,
	ValorTotal float not null,
	Desconto float not null,
	FOREIGN KEY (NotaFiscalId) REFERENCES NotaFiscal (Id),
	FOREIGN KEY (ProdutoId) REFERENCES Produto (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.INDEXES WHERE NAME = 'IX_ClienteProduto' AND OBJECT_ID = OBJECT_ID('DBO.Carrinho'))
	CREATE INDEX IX_ClienteProduto ON Carrinho (ClienteId, ProdutoId)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.INDEXES WHERE NAME = 'IX_PedidoCliente' AND OBJECT_ID = OBJECT_ID('DBO.Pedido'))
	CREATE INDEX IX_PedidoCliente ON Pedido (Id, ClienteId)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.INDEXES WHERE NAME = 'IX_PedidoDetalhes' AND OBJECT_ID = OBJECT_ID('DBO.PedidoDetalhes'))
	CREATE INDEX IX_PedidoDetalhes ON PedidoDetalhes (PedidoId, ProdutoId)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.INDEXES WHERE NAME = 'IX_PedidoHistorico' AND OBJECT_ID = OBJECT_ID('DBO.PedidoHistorico'))
	CREATE INDEX IX_PedidoHistorico ON PedidoHistorico (PedidoId)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.INDEXES WHERE NAME = 'IX_NotaPedidoCliente' AND OBJECT_ID = OBJECT_ID('DBO.NotaFiscal'))
	CREATE INDEX IX_NotaPedidoCliente ON NotaFiscal (PedidoId, ClienteId)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.INDEXES WHERE NAME = 'IX_NotaFiscalDetalhesNotaProduto' AND OBJECT_ID = OBJECT_ID('DBO.NotaFiscalDetalhes'))
	CREATE INDEX IX_NotaFiscalDetalhesNotaProduto ON NotaFiscalDetalhes (NotaFiscalId, ProdutoId)
GO

/*=========================================================================================================================================================*/
-- =============== QUEST�O 3 =============== --
/*=========================================================================================================================================================*/


SELECT NotaFiscalId, MIN(Quantidade), MAX(Valor), SUM(ValorTotal)
FROM NotaFiscalDetalhes WITH(NOLOCK)
group by NotaFiscalId
having MIN(Quantidade) > 1


/*=========================================================================================================================================================*/
-- =============== QUEST�O 4 =============== --
/*=========================================================================================================================================================*/


IF (OBJECT_ID('tempdb..#Funcionarios') IS NOT NULL) DROP TABLE #Funcionarios
CREATE TABLE #Funcionarios (
    Id INT IDENTITY(1, 1) NOT NULL,
    Nome VARCHAR(60) NOT NULL,
    Nivel_Superior INT NULL
)

INSERT INTO #Funcionarios(Nome, Nivel_Superior)
VALUES ('Palpatine', NULL)

INSERT INTO #Funcionarios(Nome, Nivel_Superior)
VALUES ('Anakin', 1), ('Chewbacca', 2), ('Han Solo', 3), ('Luke Skywalker', 4),
	   ('Yoda', 4), ('Jabba', 5), ('Obi-Wan', 5), ('General Hux', 5)

WITH Hierarquia AS (
    SELECT Id, Nome, Nivel_Superior, 1 AS Nivel
    FROM #Funcionarios
    WHERE Nivel_Superior IS NULL
 
    UNION ALL
 
    SELECT func.Id, func.Nome, func.Nivel_Superior, h.Nivel + 1 as Nivel
    FROM #Funcionarios func
    JOIN Hierarquia h ON func.Nivel_Superior = h.Id
)
SELECT * FROM Hierarquia
ORDER BY Nivel


/*=========================================================================================================================================================*/
-- =============== QUEST�O 5 =============== --
/*=========================================================================================================================================================*/

select distinct p.*
from Pedido p WITH(NOLOCK)
inner join Cliente c WITH(NOLOCK) on p.ClienteId = c.Id
inner join PedidoDetalhes pd WITH(NOLOCK) on pd.PedidoId = p.Id
inner join EstadoHistorico eh WITH(NOLOCK) on p.EstadoId = eh.Id
where pd.ProdutoId = 1
union ALL
select distinct p.*
from Pedido p WITH(NOLOCK)
inner join Cliente c WITH(NOLOCK) on p.ClienteId = c.Id
inner join PedidoDetalhes pd WITH(NOLOCK) on pd.PedidoId = p.Id
inner join EstadoHistorico eh WITH(NOLOCK) on p.EstadoId = eh.Id
left join NotaFiscal n WITH(NOLOCK) on n.PedidoId = p.Id
where pd.ProdutoId = 2

------------------------------------------------------------------------------------------------------------------------

select distinct p.*
from Pedido p WITH(NOLOCK)
inner join Cliente c WITH(NOLOCK) on p.ClienteId = c.Id
inner join PedidoDetalhes pd WITH(NOLOCK) on pd.PedidoId = p.Id
inner join EstadoHistorico eh WITH(NOLOCK) on p.EstadoId = eh.Id
left join NotaFiscal n WITH(NOLOCK) on n.PedidoId = p.Id
where n.Id is null

------------------------------------------------------------------------------------------------------------------------

select prod.Id, count(*)
from Pedido ped WITH(NOLOCK)
inner join PedidoDetalhes pd WITH(NOLOCK) on pd.PedidoId = ped.Id
inner join Produto prod WITH(NOLOCK) on prod.Id = pd.ProdutoId
inner join Categoria c WITH(NOLOCK) on c.Id = prod.CategoriaId
group by prod.Id

------------------------------------------------------------------------------------------------------------------------

select nfd.ProdutoId, count(*)
from Pedido ped WITH(NOLOCK)
inner join PedidoDetalhes pd WITH(NOLOCK) on pd.PedidoId = ped.Id
inner join Produto prod WITH(NOLOCK) on prod.Id = pd.ProdutoId
inner join Categoria c WITH(NOLOCK) on c.Id = prod.CategoriaId
inner join NotaFiscal nf WITH(NOLOCK) on nf.PedidoId = ped.Id
inner join NotaFiscalDetalhes nfd WITH(NOLOCK) on nfd.NotaFiscalId = nf.Id
group by nfd.ProdutoId
having count(*) > 3

------------------------------------------------------------------------------------------------------------------------

select pd.ProdutoId
from Pedido ped WITH(NOLOCK)
inner join PedidoDetalhes pd WITH(NOLOCK) on pd.PedidoId = ped.Id
inner join Produto prod WITH(NOLOCK) on prod.Id = pd.ProdutoId
inner join Categoria c WITH(NOLOCK) on c.Id = prod.CategoriaId
left join NotaFiscal nf WITH(NOLOCK) on nf.PedidoId = ped.Id
where nf.Id is null and pd.Quantidade > 1


/*=========================================================================================================================================================*/
-- =============== QUEST�O 6 =============== --
/*=========================================================================================================================================================*/

declare @resposta6 varchar(500) = 'Linguagem de Manipula��o de Dados: esses comandos indicam uma a��o para o SGBD executar. Utilizados para recuperar, inserir e modificar um registro no banco de dados. Seus comandos s�o: INSERT, DELETE, UPDATE, SELECT e LOCK;'

/*=========================================================================================================================================================*/
-- =============== QUEST�O 7 =============== --
/*=========================================================================================================================================================*/

declare @resposta7 varchar(500) = 'Linguagem de Defini��o de Dados:comandos DDL s�o respons�veis pela cria��o, altera��o e exclus�o dos objetos no banco de dados. S�o eles: CREATE TABLE, CREATE INDEX, ALTER TABLE, DROP TABLE, DROP VIEW e DROP INDEX;'

/*=========================================================================================================================================================*/
-- =============== QUEST�O 8 =============== --
/*=========================================================================================================================================================*/

declare @resposta8 varchar(500) = 'Linguagem de Controle de Dados:respons�vel pelo controle de acesso dos usu�rios, controlando as sess�es e transa��es do SGBD. Alguns de seus comandos s�o: COMMIT, ROLLBACK, GRANT e REVOKE.'

/*=========================================================================================================================================================*/
-- =============== QUEST�O 9 =============== --
/*=========================================================================================================================================================*/

declare @resposta9 varchar(500) = 'Op��o 1 e 2 est�o pr�ximas de estarem corretas, por�m todas as tr�s op��es est�o erradas'

--Op��o 1: alter table serviceorder add constraint fk_serviceorder_client foreign key(id_client) references client (id_serviceorder)
--Op��o 2: alter table serviceorder add constraint fk_serviceorder_client foreign key(id_client) references id_client (client)
--Op��o 3: alter table client add constraint fk_serviceorder_client foreign key(id_serviceorder) references client (id_client)

-- ## CORRETO ##
ALTER TABLE serviceorder ADD CONSTRAINT fk_serviceorder_client FOREIGN KEY (id_client) REFERENCES client (id_client)

/*=========================================================================================================================================================*/
-- =============== QUEST�O 10 =============== --
/*=========================================================================================================================================================*/

insert into #cliente(
  id,
  nome_cliente,
  razao_social,
  dt_cadastro,
  cnpj,
  telefone,
  cidade,
  estado)
values (
  1,
  --'0001', -- ESTE VALOR EST� INCORRETO, POIS N�O POSSUI COLUNA REFERENTE A ELE (Colunas de Ids n�o popularmente n�o s�o do tipo texto)
  'AARONSON',
  'AARONSON FURNITURE LTDA',
  '2015-02-17',
  '17.807.928/0001-85',
  '(21) 8167-6584',
  'MARINGA',
  'PR'
);

/*=========================================================================================================================================================*/
-- =============== QUEST�O 11 =============== --
/*=========================================================================================================================================================*/

-- update client set name = 'FULANO DE TAL'; cnpj = '17807928000185' where id = 3234;

-- O comando acima est� com delimitador ponto-e-v�rgula ap�s a atribui��o do primeiro par�metro e o correto � usar a v�rgula
update client set name = 'FULANO DE TAL', cnpj = '17807928000185' where id = 3234;

/*=========================================================================================================================================================*/
-- =============== QUEST�O 12 =============== --
/*=========================================================================================================================================================*/

SELECT vd.nome, c.nome, sum(vs.totalvenda) as TotalDaVenda
FROM vendas vs WITH(NOLOCK)
inner join vendedor vd WITH(NOLOCK) on vs.vendedorID = vd.id
inner join cliente c WITH(NOLOCK) on vs.clienteID = c.id
group by vd.nome, c.nome

/*=========================================================================================================================================================*/
-- =============== QUEST�O 13 =============== --
/*=========================================================================================================================================================*/

declare @resposta13 varchar(500) = 'Resposta correta: Op��o 1'

/*=========================================================================================================================================================*/
-- =============== QUEST�O 14 =============== --
/*=========================================================================================================================================================*/

ERRADO: SELECT nome FROM cliente WHERE nome = '>Souza'
CORRETO: SELECT nome FROM cliente WHERE nome like '%Souza%'

/*=========================================================================================================================================================*/
-- =============== QUEST�O 15 =============== --
/*=========================================================================================================================================================*/

drop table cliente;

/*=========================================================================================================================================================*/
-- =============== QUEST�O 16 =============== --
/*=========================================================================================================================================================*/

select nome from cliente where id in (12, 10, 199, 18, 1, 2016)

/*=========================================================================================================================================================*/
-- =============== QUEST�O 17 =============== --
/*=========================================================================================================================================================*/

--Obs: N�o sei se foi erro de digita��o no enunciado, mas a coluna "id_cliente" n�o existe no modelo da tabela vendas informado no exemplo, est� com nome diferente "clienteID"

declare @resposta17 varchar(500) = 'Resposta correta: Op��o 1'

/*=========================================================================================================================================================*/
-- =============== QUEST�O 18 =============== --
/*=========================================================================================================================================================*/

--Obs: Este enunciado tamb�m possui erros de sintaxe nos modelos de exemplo (posicionamento dos valores da tabela vendas e repeti��o dos Ids, pois ir� gerar exce��o de viola��o de chave prim�ria)

drop table vendas, cliente

/*=========================================================================================================================================================*/
-- =============== QUEST�O 19, 20 =============== --
/*=========================================================================================================================================================*/

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'Pessoas')
CREATE TABLE Pessoas (
	Id int identity(1,1),
	Nome varchar(100) not null,
	PRIMARY KEY (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'Clientes')
CREATE TABLE Clientes (
	Id int identity(1,1),
	Nome varchar(100) not null,
	PessoaId int not null,
	PRIMARY KEY (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'Usuarios')
CREATE TABLE Usuarios (
	Id int identity(1,1),
	Nome varchar(100) not null,
	PessoaId int not null,
	PRIMARY KEY (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'Funcionarios')
CREATE TABLE Funcionarios (
	Id int identity(1,1),
	Nome varchar(100) not null,
	PessoaId int not null,
	PRIMARY KEY (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'Fornecedores')
CREATE TABLE Fornecedores (
	Id int identity(1,1),
	Nome varchar(100) not null,
	PessoaId int not null,
	PRIMARY KEY (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'TiposEnderecos')
CREATE TABLE TiposEnderecos (
	Id int identity(1,1),
	Descricao varchar(100) not null,
	PRIMARY KEY (Id)
)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'Enderecos')
CREATE TABLE Enderecos (
	Id int identity(1,1),
	Endereco varchar(100) not null,
	Cidade varchar(100) null,
	Estado varchar(100) null,
	PessoaId int not null,
	TipoEnderecoId int not null,
	PRIMARY KEY (Id)
)
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK_Cliente_Endereco') AND parent_object_id = OBJECT_ID(N'dbo.Clientes'))
	ALTER TABLE Clientes ADD CONSTRAINT FK_Cliente_Endereco FOREIGN KEY (PessoaId) REFERENCES Pessoas (Id)
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK_Funcionario_endereco') AND parent_object_id = OBJECT_ID(N'dbo.Funcionarios'))
	ALTER TABLE Funcionarios ADD CONSTRAINT FK_Funcionario_endereco FOREIGN KEY (PessoaId) REFERENCES Pessoas (Id)
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK_Usuario_Endereco') AND parent_object_id = OBJECT_ID(N'dbo.Usuarios'))
	ALTER TABLE Usuarios ADD CONSTRAINT FK_Usuario_Endereco FOREIGN KEY (PessoaId) REFERENCES Pessoas (Id)
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK_Fornecedor_Endereco') AND parent_object_id = OBJECT_ID(N'dbo.Fornecedores'))
	ALTER TABLE Fornecedores ADD CONSTRAINT FK_Fornecedor_Endereco FOREIGN KEY (PessoaId) REFERENCES Pessoas (Id)
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK_Endereco_TipoEndereco') AND parent_object_id = OBJECT_ID(N'dbo.Enderecos'))
	ALTER TABLE Enderecos ADD CONSTRAINT FK_Endereco_TipoEndereco FOREIGN KEY (TipoEnderecoId) REFERENCES TiposEnderecos (Id)
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK_Endereco_Pessoa') AND parent_object_id = OBJECT_ID(N'dbo.Enderecos'))
	ALTER TABLE Enderecos ADD CONSTRAINT FK_Endereco_Pessoa FOREIGN KEY (PessoaId) REFERENCES Pessoas (Id)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.INDEXES WHERE NAME = 'IX_Cliente_Endereco' AND OBJECT_ID = OBJECT_ID('DBO.Clientes'))
	CREATE INDEX IX_Cliente_Endereco ON Clientes (Id, PessoaId)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.INDEXES WHERE NAME = 'IX_Funcionario_Endereco' AND OBJECT_ID = OBJECT_ID('DBO.Funcionarios'))
	CREATE INDEX IX_Funcionario_Endereco ON Funcionarios (Id, PessoaId)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.INDEXES WHERE NAME = 'IX_Usuario_Endereco' AND OBJECT_ID = OBJECT_ID('DBO.Usuarios'))
	CREATE INDEX IX_Usuario_Endereco ON Usuarios (Id, PessoaId)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.INDEXES WHERE NAME = 'IX_Fornecedor_Endereco' AND OBJECT_ID = OBJECT_ID('DBO.Fornecedores'))
	CREATE INDEX IX_Fornecedor_Endereco ON Fornecedores (Id, PessoaId)
GO