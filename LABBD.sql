CREATE DATABASE LabBDEx06

CREATE TABLE Produto(
	Codigo					INT				NOT NULL,
	Nome					VARCHAR(100)	NOT NULL,
	Valor					DECIMAL(6,2)	NOT NULL,
	PRIMARY KEY(Codigo)
)

CREATE TABLE ENTRADA(
	Codigo_Transacao		INT				NOT NULL,
	Codigo_Produto			INT				NOT NULL,
	Quantidade				INT				NOT NULL,
	Valor_Total				DECIMAL(8,2)	NOT NULL
	PRIMARY KEY(Codigo_Transacao, Codigo_Produto)
	FOREIGN KEY(Codigo_Produto) REFERENCES Produto(Codigo)
)

CREATE TABLE SAIDA(
	Codigo_Transacao		INT				NOT NULL,
	Codigo_Produto			INT				NOT NULL,
	Quantidade				INT				NOT NULL,
	Valor_Total				DECIMAL(8,2)	NOT NULL
	PRIMARY KEY(Codigo_Transacao, Codigo_Produto)
	FOREIGN KEY(Codigo_Produto) REFERENCES Produto(Codigo)
)


CREATE PROCEDURE sp_produto(@opcao CHAR(1), @codigo_transacao INT, @codigo_produto INT, @quantidade INT)
AS 
	DECLARE @query VARCHAR(200), @valor_total DECIMAL(10,2), @tabela VARCHAR(10), @codigo_ver VARCHAR(MAX), @valido BIT = 1
	IF(LOWER(@opcao) != 'e' AND LOWER(@opcao) != 's')
	BEGIN
		RAISERROR('Opcao Invalido',16,1)
	END
	ELSE
	BEGIN
		EXEC sp_tabela @opcao, @tabela OUTPUT
		EXEC sp_calcular_valor @codigo_produto, @quantidade, @valor_total OUTPUT

		BEGIN TRY
			SET @codigo_ver = 'SELECT Codigo FROM Produto WHERE '+CAST(@codigo_produto AS VARCHAR(100)) +' = Codigo'
			EXEC(@codigo_ver)
		END TRY
		BEGIN CATCH
			SET @valido = 0
			RAISERROR('Erro no codigo do produto', 16,1)
		END CATCH

		BEGIN TRY
			SET @codigo_ver = 'SELECT '+CAST(@codigo_transacao AS VARCHAR(100))
								+' FROM '+ @tabela+ 'WHERE '+CAST(@codigo_transacao AS VARCHAR(100)) +' = Codigo_Transacao'
			EXEC(@codigo_ver)
		END TRY
		BEGIN CATCH
			SET @valido = 0
			RAISERROR('Erro no codigo da transacao', 16,1)
		END CATCH


		IF(@valido = 0)
		BEGIN
			RAISERROR('Erro no codigo', 16,1)
		END 
		ELSE
		BEGIN
			SET @query = 'INSERT INTO '+@tabela+' VALUES('+CAST(@codigo_transacao AS VARCHAR(6))+', '+CAST(@codigo_produto AS VARCHAR(12))+', '
								+CAST(@quantidade AS VARCHAR(12))+', '+CAST(@valor_total AS VARCHAR(12))+')';
			PRINT(@query)
			EXEC(@query)
		END
	END


CREATE PROCEDURE sp_calcular_valor(@codigo_produto INT, @quantidade INT, @valor_total DECIMAL(10,2) OUTPUT)
AS
	SET @valor_total = (
		SELECT Valor FROM Produto
		WHERE @codigo_produto = Codigo
	) * @quantidade

CREATE PROCEDURE sp_tabela @opcao CHAR(1), @tabela VARCHAR(10) OUTPUT
AS
	IF(@opcao = LOWER('e'))
	BEGIN
		SET @tabela = 'ENTRADA'
	END
	ELSE
	BEGIN
		SET @tabela = 'SAIDA'
	END


INSERT INTO Produto VALUES(1, 'Tenis nike', 399.90)
INSERT INTO Produto VALUES(2, 'Tenis AIR MAX 69', 699.90)
INSERT INTO Produto VALUES(3, 'Tenis ATIDAS ALLCHUPAR', 399.90)

EXEC sp_produto 'e', 1, 2, 5
EXEC sp_produto 's', 1, 3, 2
EXEC sp_produto 'e', 4, 4, 5
EXEC sp_produto 'i', 4, 3, 5
EXEC sp_produto 'e', 5, 2, 1

SELECT  e.Codigo_Transacao, e.Quantidade, p.Nome, e.Valor_Total
FROM ENTRADA AS e, Produto AS p
WHERE e.Codigo_Produto = p.Codigo

SELECT  e.Codigo_Transacao, e.Quantidade, p.Nome, e.Valor_Total
FROM SAIDA AS e, Produto AS p
WHERE e.Codigo_Produto = p.Codigo
