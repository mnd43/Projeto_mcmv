USE ProjetMCMV;
EXEC sp_rename 'dbo.mcmv', 't_mcmv', 'OBJECT';
SELECT * FROM t_mcmv;

 
SELECT TOP 100 * FROM t_mcmv;

-- Analisando o tipo dos dados de cada coluna
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 't_mcmv';

-- Como a data de refêrência é sobre quando o governo disponibilizou os dados, e não será útil para a análise, poderia dropar ela
-- ALTER TABLE t_mcmv DROP COLUMN data_referencia;
--TRATAMENTO E LIMPEZA
-- Alterando a vírgula por ponto para conseguir alterar o VARCHAR para DECIMAL
UPDATE t_mcmv 
SET vlr_financiamento = REPLACE(vlr_financiamento, ',', '.')
WHERE vlr_financiamento LIKE '%,%';

UPDATE t_mcmv 
SET vlr_subsidio_desconto_fgts = REPLACE(vlr_subsidio_desconto_fgts, ',', '.')
WHERE vlr_subsidio_desconto_fgts LIKE '%,%';

UPDATE t_mcmv
SET vlr_subsidio_desconto_ogu = REPLACE(vlr_subsidio_desconto_ogu, ',', '.')
WHERE vlr_subsidio_desconto_ogu LIKE '%,%';

UPDATE t_mcmv 
SET vlr_subsidio_equilibrio_fgts = REPLACE(vlr_subsidio_equilibrio_fgts, ',', '.')
WHERE vlr_subsidio_equilibrio_fgts LIKE '%,%';

UPDATE t_mcmv 
SET vlr_subsidio_equilibrio_ogu = REPLACE(vlr_subsidio_equilibrio_ogu, ',', '.')
WHERE vlr_subsidio_equilibrio_ogu LIKE '%,%';

UPDATE t_mcmv 
SET vlr_compra = REPLACE(vlr_compra, ',', '.')
WHERE vlr_compra LIKE '%,%';

UPDATE t_mcmv 
SET vlr_renda_familiar = REPLACE(vlr_renda_familiar, ',', '.')
WHERE vlr_renda_familiar LIKE '%,%';

UPDATE t_mcmv 
SET num_taxa_juros = REPLACE(num_taxa_juros, ',', '.')
WHERE num_taxa_juros LIKE '%,%';
*/


 -- Testei para ver se teriam erros quando fosse transformar o tipo de dado de algumas colunas
SELECT qtd_uh_financiadas, vlr_financiamento, vlr_subsidio_desconto_fgts, vlr_subsidio_desconto_ogu, 
       vlr_subsidio_equilibrio_fgts, vlr_subsidio_equilibrio_ogu, vlr_compra, vlr_renda_familiar, 
       num_taxa_juros, data_assinatura_financiamento, dte_nascimento  
FROM t_mcmv  
WHERE TRY_CONVERT(INT, qtd_uh_financiadas) IS NULL  
   OR TRY_CONVERT(DECIMAL(18,2), vlr_financiamento) IS NULL  
   OR TRY_CONVERT(DECIMAL(18,2), vlr_subsidio_desconto_fgts) IS NULL  
   OR TRY_CONVERT(DECIMAL(18,2), vlr_subsidio_desconto_ogu) IS NULL  
   OR TRY_CONVERT(DECIMAL(18,2), vlr_subsidio_equilibrio_fgts) IS NULL  
   OR TRY_CONVERT(DECIMAL(18,2), vlr_subsidio_equilibrio_ogu) IS NULL  
   OR TRY_CONVERT(DECIMAL(18,2), vlr_compra) IS NULL  
   OR TRY_CONVERT(DECIMAL(18,2), vlr_renda_familiar) IS NULL  
   OR TRY_CONVERT(DECIMAL(18,2), num_taxa_juros) IS NULL  
   OR TRY_CONVERT(DATE, data_assinatura_financiamento) IS NULL  
   OR TRY_CONVERT(DATE, dte_nascimento) IS NULL;
 
-- Nulos: 323 linhas nulas em vlr_compra. 294.766 nulos em num_taxa_juros. 1.275 linhas sem data_assinatura o SQL joga para a "data zero" 1900-01-01. 3.142.349 linhas sem data em dte_nascimento que o SQL joga para a "data zero" 1900-01-01.
  
SELECT num_taxa_juros
FROM t_mcmv  
WHERE TRY_CONVERT(DECIMAL(18,2), num_taxa_juros) IS NULL -- 294.766

SELECT vlr_compra
FROM t_mcmv  
WHERE TRY_CONVERT(DECIMAL(18,2), vlr_compra) IS NULL -- 323

SELECT data_assinatura_financiamento
FROM t_mcmv  
WHERE TRY_CONVERT(DATE, data_assinatura_financiamento) = ' '; -- 1.275 nulos
SELECT dte_nascimento
FROM t_mcmv  
WHERE TRY_CONVERT(DATE, dte_nascimento) = ' '; -- 3.142.349 nulos

-- Transformando os vazios(' ') em null na coluna vlr_compra:
UPDATE t_mcmv
SET vlr_compra = NULL
WHERE LTRIM(RTRIM(vlr_compra)) = ''; -- 323 afetadas

-- Transformando os vazios(' ') em null na coluna num_taxa_juros:
UPDATE t_mcmv
SET num_taxa_juros = NULL
WHERE LTRIM(RTRIM(num_taxa_juros)) = '';-- 294766 afetadas
        

-- Repassando se tem nulos nas outras colunas
SELECT * FROM t_mcmv
WHERE cod_ibge = ' '; -- sem nulos

SELECT * FROM t_mcmv
WHERE txt_municipio = ' ';-- sem nulos

SELECT * FROM t_mcmv
WHERE mcmv_fgts_txt_uf = ' ';-- sem nulos

SELECT * FROM t_mcmv
WHERE txt_programa_fgts IS NULL;-- sem nulos

SELECT * FROM t_mcmv
WHERE txt_tipo_imovel IS NULL;-- sem nulos

SELECT * FROM t_mcmv
WHERE bln_cotista = ' ';--294.766 nulos

SELECT * FROM t_mcmv
WHERE txt_sistema_amortizacao = ' ';--635.554 nulos

SELECT * FROM t_mcmv
WHERE txt_compatibilidade_faixa_renda = ' ';-- sem nulos

SELECT * FROM t_mcmv
WHERE txt_nome_empreendimento = ' ';-- 6.940.805 nulos

-- Alterando o tipo dos dados das colunase numéricas e de  data
ALTER TABLE t_mcmv ALTER COLUMN qtd_uh_financiadas INT;
ALTER TABLE t_mcmv ALTER COLUMN vlr_financiamento DECIMAL(18,2);
ALTER TABLE t_mcmv ALTER COLUMN vlr_subsidio_desconto_fgts DECIMAL(18,2);
ALTER TABLE t_mcmv ALTER COLUMN vlr_subsidio_desconto_ogu DECIMAL(18,2);
ALTER TABLE t_mcmv ALTER COLUMN vlr_subsidio_equilibrio_fgts DECIMAL(18,2);
ALTER TABLE t_mcmv ALTER COLUMN vlr_subsidio_equilibrio_ogu DECIMAL(18,2);
ALTER TABLE t_mcmv ALTER COLUMN vlr_renda_familiar DECIMAL(18,2);
ALTER TABLE t_mcmv ALTER COLUMN data_assinatura_financiamento DATE;
ALTER TABLE t_mcmv ALTER COLUMN dte_nascimento DATE;
ALTER TABLE t_mcmv ALTER COLUMN vlr_compra DECIMAL(18,2);

*/ 
-- Tranformando as datas 01/01/1900 em "null" na coluna data_assinatura_financiamento
UPDATE t_mcmv
SET data_assinatura_financiamento = NULL
WHERE data_assinatura_financiamento = '1900-01-01';

-- Tranformando as datas 01/01/1900 em "null" na coluna dte_nascimento
UPDATE t_mcmv
SET dte_nascimento = NULL
WHERE dte_nascimento = '1900-01-01';

-- Criando tabelas Dimensão
-- DIM Tempo a partir da data de assinatura
CREATE TABLE dim_tempo (
  id_tempo INT IDENTITY(1,1) PRIMARY KEY,
  data_assinatura DATE,
  ano INT,
  mes INT,
  nome_mes VARCHAR(20),
  trimestre INT
);

-- Inserindo na dim_tempo as informações a partir da data_assinatura_financiamento da minha base principal
INSERT INTO dim_tempo (data_assinatura, ano, mes, nome_mes, trimestre)
SELECT DISTINCT
  data_assinatura_financiamento,
  YEAR(data_assinatura_financiamento),
  MONTH(data_assinatura_financiamento),
  DATENAME(MONTH, data_assinatura_financiamento),
  DATEPART(QUARTER, data_assinatura_financiamento)
FROM t_mcmv;

-- Adicionando uma linha especial com valor de "não informado" para preencher os dados faltantes
INSERT INTO dim_tempo (data_assinatura, ano, mes, nome_mes, trimestre)
VALUES (NULL, NULL, NULL, 'Não Informada', NULL);

-- Adicionando a chave estrangeira da dim_tempo na minha base principal
ALTER TABLE t_mcmv ADD id_tempo INT;

-- Criando indices para facilitar na insersão dos dados na tabela fato 
CREATE NONCLUSTERED INDEX idx_dim_tempo_data
ON dim_tempo (data_assinatura);

-- PAREI AQUI 06/07/2025 01:09 da manhã
-- Preenchendo a coluna id_tempo da dim_tempo na tabela fato, principal:
UPDATE t_mcmv
SET id_tempo = dim_tempo.id_tempo
FROM t_mcmv
JOIN dim_tempo 
  ON t_mcmv.data_assinatura_financiamento = dim_tempo.data_assinatura;


SELECT * FROM dim_tempo;
-- Preenchendo os nulls com o id de nulos da dim
UPDATE t_mcmv
SET id_tempo = 4110
WHERE id_tempo IS NULL;


-- Criando DIM localidade
CREATE TABLE dim_localidade (
  id_localidade INT IDENTITY(1,1) PRIMARY KEY,
  cod_ibge VARCHAR(10),
  txt_municipio VARCHAR(70),
  uf CHAR(2),
  regiao VARCHAR(20)
);

-- Criando índice ÚNICO na dimensão (cod_ibge é único por cidade)
CREATE UNIQUE NONCLUSTERED INDEX idx_cod_ibge_dimlocalidade 
ON dim_localidade(cod_ibge);

-- Criando índice auxiliar na FATO para acelerar o JOIN
CREATE NONCLUSTERED INDEX idx_cod_ibge_mcmv 
ON t_mcmv (cod_ibge);


-- Inserindo os dados na DIM a partir da fato
INSERT INTO dim_localidade (cod_ibge, txt_municipio, uf, regiao)
SELECT DISTINCT cod_ibge, txt_municipio, mcmv_fgts_txt_uf, txt_regiao
FROM t_mcmv;

ALTER TABLE t_mcmv ADD id_localidade INT;

UPDATE t
SET id_localidade = d.id_localidade
FROM t_mcmv t
JOIN dim_localidade d ON t.cod_ibge = d.cod_ibge;
 
SELECT * FROM dim_localidade;

 -- Criando DIM Imovel
 CREATE TABLE dim_tipo_imovel (
  id_tipo_imovel INT IDENTITY(1,1) PRIMARY KEY,
  descricao_tipo_imovel VARCHAR(100)
);

-- Preenchedo dim_imovel a partir da fato
INSERT INTO dim_tipo_imovel (descricao_tipo_imovel)
SELECT DISTINCT txt_tipo_imovel
FROM t_mcmv
WHERE txt_tipo_imovel <> ' ';

-- Criando uma linha especial para nulos
INSERT INTO dim_tipo_imovel (descricao_tipo_imovel)
VALUES ('Não Informado');

SELECT * FROM dim_tipo_imovel;

-- Criando indice
CREATE NONCLUSTERED INDEX idx_txt_tipo_imovel_mcmv 
ON t_mcmv (txt_tipo_imovel);

-- Criando a coluna id_tipo_imovel na fato
ALTER TABLE t_mcmv ADD id_tipo_imovel INT;

-- Atualizando a fato com os valores de id_imovel da DIM
UPDATE t
SET id_tipo_imovel = d.id_tipo_imovel
FROM t_mcmv t
JOIN dim_tipo_imovel d 
  ON LTRIM(RTRIM(t.txt_tipo_imovel)) = d.descricao_tipo_imovel;

SELECT * FROM dim_tipo_imovel;
SELECT * FROM t_mcmv
WHERE id_tipo_imovel = 3;
-- Atualizando os nulos da fato com os valores de id_imovel da DIM - Nessa atualização da tabela 25/06 nao tem mais nulos
--UPDATE t_mcmv
--SET id_tipo_imovel = 3
--WHERE id_tipo_imovel IS NULL;


-- Criando DIM faixa de renda
CREATE TABLE dim_faixa_renda (
  id_faixa_renda INT IDENTITY(1,1) PRIMARY KEY,
  faixa_renda VARCHAR(100)
);

-- Preenchendo com os dados da fato
INSERT INTO dim_faixa_renda (faixa_renda)
SELECT DISTINCT txt_compatibilidade_faixa_renda
FROM t_mcmv;

-- Criando indices
CREATE NONCLUSTERED INDEX idx_mcmv_faixa_renda 
ON t_mcmv (txt_compatibilidade_faixa_renda);
CREATE UNIQUE NONCLUSTERED INDEX idx_dim_faixa_renda 
ON dim_faixa_renda (faixa_renda);

-- Adicionando a coluna na fato
ALTER TABLE t_mcmv ADD id_faixa_renda INT;

-- Preenchendo a coluna na fato
UPDATE t_mcmv
SET id_faixa_renda = dim_faixa_renda.id_faixa_renda
FROM t_mcmv
JOIN dim_faixa_renda ON t_mcmv.txt_compatibilidade_faixa_renda = dim_faixa_renda.faixa_renda;


-- Criando DIM sistemas de amortização
CREATE TABLE dim_sistema_amortizacao (
  id_sistema INT IDENTITY(1,1) PRIMARY KEY,
  sistema VARCHAR(100)
);
 -- Preenchendo dim_sistema_amortizacao
INSERT INTO dim_sistema_amortizacao (sistema)
SELECT DISTINCT 
  CASE 
    WHEN txt_sistema_amortizacao = ' ' THEN 'Não informado'
    ELSE txt_sistema_amortizacao
  END
FROM t_mcmv;

-- Adicionando a coluna na fato
ALTER TABLE t_mcmv ADD id_sistema INT;

-- Criando os indices
CREATE NONCLUSTERED INDEX idx_mcmv_sistema_amortizacao 
ON t_mcmv (txt_sistema_amortizacao);

CREATE UNIQUE NONCLUSTERED INDEX idx_dim_sistema_amortizacao 
ON dim_sistema_amortizacao (sistema);

UPDATE t_mcmv
SET id_sistema = d.id_sistema
FROM t_mcmv
JOIN dim_sistema_amortizacao d 
  ON t_mcmv.txt_sistema_amortizacao = d.sistema;

-- Preenchendo os nulos

UPDATE t_mcmv
SET id_sistema = 3
WHERE id_sistema IS NULL;

SELECT * FROM dim_sistema_amortizacao;
SELECT TOP 300 * FROM t_mcmv;

-- Criando DIM programa
CREATE TABLE dim_programa (
  id_programa INT IDENTITY(1,1) PRIMARY KEY,
  nome_programa VARCHAR(255)
);


-- Preenchendo a dim_programa com as informações a partir da fato
INSERT INTO dim_programa (nome_programa)
SELECT DISTINCT txt_programa_fgts
FROM t_mcmv;

-- Adicionando a coluna id_programa na fato
ALTER TABLE t_mcmv ADD id_programa INT;

-- Criei indice para facilitar no preenchimento da fato
CREATE NONCLUSTERED INDEX idx_txt_programa_fgts_mcmv
ON t_mcmv (txt_programa_fgts);

-- Atualizando a fato com os valores de id_programa da dim_programa
UPDATE t_mcmv
SET id_programa = p.id_programa
FROM t_mcmv
JOIN dim_programa p 
  ON t_mcmv.txt_programa_fgts = p.nome_programa; 

 -- Criando a DIM cotista
 CREATE TABLE dim_cotista (
  id_cotista INT IDENTITY(1,1) PRIMARY KEY,
  situacao_cotista VARCHAR(20)
);
SELECT TOP 250 * FROM t_mcmv;
-- Preenchendo a dim_costisa não a partir da fato, mas a partir do que já sabemos que a coluna identifica
INSERT INTO dim_cotista (situacao_cotista)
VALUES 
  ('Sim'),
  ('Não'),
  ('Não Informado');

-- Adicionando a coluna na fato
ALTER TABLE t_mcmv ADD id_cotista INT;

CREATE NONCLUSTERED INDEX idx_bln_cotista_mcmv 
ON t_mcmv (bln_cotista);

-- Atualiza a fato com os IDs da DIM
UPDATE t_mcmv
SET id_cotista = d.id_cotista
FROM t_mcmv
JOIN dim_cotista d 
  ON 
    (t_mcmv.bln_cotista = 'S' AND d.situacao_cotista = 'Sim') OR
    (t_mcmv.bln_cotista = 'N' AND d.situacao_cotista = 'Não') OR
    (LTRIM(RTRIM(t_mcmv.bln_cotista)) = '' AND d.situacao_cotista = 'Não Informado');


-- Preenchendo os X
SELECT TOP 250 * FROM t_mcmv;

UPDATE t_mcmv
SET id_cotista = 3
WHERE bln_cotista = 'X';


SELECT * FROM dim_cotista;
SELECT TOP 250 * FROM t_mcmv;

/*--fazendo um backup do projeto até aqui
BACKUP DATABASE ProjetMCMV
TO DISK = 'D:\Amanda\Yukio\Projeto MCMV\backup_mcmv.bak'
WITH INIT, NAME = 'Backup_MCMV_Sem_Compressao';
*/

/*--Check para conferir se os valores batem tanto direto da fato quanto com os JOINs depois do drop de colunas
SELECT 
  mcmv_fgts_txt_uf AS UF,
  SUM(qtd_uh_financiadas) AS total_unidades_financiadas
FROM t_mcmv
GROUP BY mcmv_fgts_txt_uf
ORDER BY total_unidades_financiadas DESC;


SELECT 
  dim_localidade.uf AS UF,
  SUM(t_mcmv.qtd_uh_financiadas) AS total_unidades_financiadas
FROM t_mcmv
JOIN dim_localidade 
  ON t_mcmv.id_localidade = dim_localidade.id_localidade
GROUP BY dim_localidade.uf
ORDER BY total_unidades_financiadas DESC;
*/ 


-- Verificando todos os índices que usam colunas da tabela fato t_mcmv (que criei para facilitar a criação das DIMs)
SELECT i.name AS nome_indice, c.name AS coluna
FROM sys.indexes i
JOIN sys.index_columns ic ON i.index_id = ic.index_id AND i.object_id = ic.object_id
JOIN sys.columns c ON ic.column_id = c.column_id AND ic.object_id = c.object_id
WHERE OBJECT_NAME(i.object_id) = 't_mcmv';

-- O que acontece quando você deleta um índice
-- Não afeta a estrutura da tabela:
-- A tabela (t_mcmv, por exemplo) continua existindo normalmente
-- Nenhuma coluna é alterada nem perde dados
-- Nenhuma constraint (PRIMARY KEY, FOREIGN KEY, etc.) é afetada, a menos que o índice seja parte de uma constraint (não é seu caso aqui)


SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 't_mcmv';

-- Apagando índices que dependem de colunas que serão removidas
DROP INDEX idx_bln_cotista_mcmv ON t_mcmv;
DROP INDEX idx_cod_ibge_mcmv ON t_mcmv;
DROP INDEX idx_txt_tipo_imovel_mcmv ON t_mcmv;
DROP INDEX idx_mcmv_faixa_renda ON t_mcmv;
DROP INDEX idx_mcmv_sistema_amortizacao ON t_mcmv;
DROP INDEX idx_txt_programa_fgts_mcmv ON t_mcmv;


-- O comando BEGIN TRANSACTION inicia explicitamente uma transação. 
-- A partir desse ponto, qualquer modificação no banco de dados (como INSERT, UPDATE, DELETE, ou ALTER) ficará em estado pendente até que se execute:
-- COMMIT: para confirmar e aplicar definitivamente todas as alterações realizadas desde o início da transação.
-- ROLLBACK: para cancelar a transação e desfazer todas as alterações realizadas dentro dela.

-- Fazendo um begin transaction prar dropar várias colunas.
BEGIN TRANSACTION;

-- DROP das colunas já representadas pelas DIMs
ALTER TABLE t_mcmv 
DROP COLUMN 
  cod_ibge,
  txt_municipio,
  mcmv_fgts_txt_uf,
  txt_regiao,
  txt_programa_fgts,
  txt_tipo_imovel,
  txt_sistema_amortizacao,
  txt_compatibilidade_faixa_renda,
  bln_cotista,
  data_assinatura_financiamento;

-- Verifique se tudo está OK até aqui
SELECT * FROM dim_tipo_imovel;
SELECT * FROM dim_tempo;
SELECT * FROM dim_sistema_amortizacao;
SELECT * FROM dim_programa;
SELECT * FROM dim_localidade;
SELECT * FROM dim_faixa_renda;
SELECT * FROM dim_cotista;
SELECT TOP 100 * FROM t_mcmv;

-- Se estiver tudo certo, CONFIRMA:
--COMMIT;

-- Se quiser desfazer tudo:
--ROLLBACK;

-- ## CONSULTAS - VISUALIZAÇÕES ## 

-- Visualizando o valor total geral de unidades financiadas.
-- Como cada registro se refere a um financiamento, até mesmo pela natureza do programa que permite financiamento apenas de uma unidade, temos o total igual ao total 
-- de linhas da tabela: 6.911.512

SELECT SUM(qtd_uh_financiadas) AS Total_habitações
FROM t_mcmv;

-- Visualizando ano mais antigo, desde quando temos os dados de financiamentos: 2005
SELECT MIN(dd.ano) AS data_mais_antiga
FROM t_mcmv t
JOIN dim_tempo dd ON t.id_tempo = dd.id_tempo;

-- O programa MCMV foi criado em 2009, pela lógica é estranho ter datas anteriores a 2009: 232 registros entre 2005 e 2008.
-- Depois de me aprofundar no assunto, entendi que existiam outros programas antes do MCMV e que em 1967 começou a prática da utilização do FGTS.
-- Aparentemente a base mantem alguns dados antigos.
SELECT dd.ano, COUNT(dd.ano) AS ano_mais_antigo
FROM t_mcmv t
JOIN dim_tempo dd ON t.id_tempo = dd.id_tempo
WHERE dd.ano <= 2008
GROUP by dd.ano
ORDER BY dd.ano DESC;


-- Visualizando a ano mais recente que temos os dados de financiamentos: 2025
SELECT MAX(dd.ano) AS ano_mais_recente
FROM t_mcmv t
JOIN dim_tempo dd ON t.id_tempo = dd.id_tempo;

-- Visualizando o total de unidades financiadas por UF
SELECT dl.uf, SUM(qtd_uh_financiadas) AS Quantidade
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
GROUP BY dl.uf
ORDER BY Quantidade DESC;

WITH TotalGeral AS (
  SELECT SUM(qtd_uh_financiadas) AS total
  FROM t_mcmv
)

SELECT 
  dl.uf, 
  SUM(qtd_uh_financiadas) AS Quantidade,
  CAST(
    100.0 * SUM(qtd_uh_financiadas) / tg.total AS DECIMAL(5,2)
  ) AS Percentual
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
CROSS JOIN TotalGeral tg
GROUP BY dl.uf, tg.total
ORDER BY Quantidade DESC;



-- Visualizando o total de unidades financiadas por cidade do país
SELECT dl.txt_municipio, dl.uf, SUM(qtd_uh_financiadas) AS Quantidade
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
GROUP BY dl.txt_municipio, dl.uf
ORDER BY Quantidade DESC;

-- Visualizando as unidades por faixa de renda
SELECT dfr.faixa_renda, SUM(qtd_uh_financiadas) AS Quantidade
FROM t_mcmv t
JOIN dim_faixa_renda dfr ON t.id_faixa_renda = dfr.id_faixa_renda
GROUP BY dfr.faixa_renda
ORDER BY Quantidade DESC;


-- Visualizando as unidades por faixa de renda por UF
SELECT dl.uf, dfr.faixa_renda, SUM(qtd_uh_financiadas) AS Quantidade
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
JOIN dim_faixa_renda dfr ON t.id_faixa_renda = dfr.id_faixa_renda
GROUP BY dfr.faixa_renda, dl.uf
ORDER BY dl.uf, Quantidade DESC;

-- Visualizando a porcentagem de cada faixa da UF em relação ao total geral de unidades financiadas
  WITH TotalUnidades AS (
  SELECT SUM(qtd_uh_financiadas) AS total_geral
  FROM t_mcmv t
)

SELECT 
  dl.uf, 
  dfr.faixa_renda, 
  SUM(qtd_uh_financiadas) AS Quantidade,
  CAST(
    100.0 * SUM(qtd_uh_financiadas) / total_geral 
    AS DECIMAL(5,2)
  ) AS Percentual_do_Total
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
JOIN dim_faixa_renda dfr ON t.id_faixa_renda = dfr.id_faixa_renda
CROSS JOIN TotalUnidades
GROUP BY 
  dl.uf, 
  dfr.faixa_renda, 
  total_geral
ORDER BY 
  dl.uf, 
  dfr.faixa_renda;

-- Visualizando a média geral da renda familiar das contratações de financiamento com FGTS: 3041.175200

  SELECT AVG(vlr_renda_familiar) AS renda_media
  FROM t_mcmv;

 -- Visualizando a média de renda familiar por UF

 SELECT dl.uf, AVG(vlr_renda_familiar) AS renda_media
 FROM t_mcmv t
 JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
 GROUP BY dl.uf
 ORDER BY renda_media DESC, dl.uf;

  -- Visualizando quais UFs tem a média de renda familiar maior do que a média nacional

SELECT dl.uf, AVG(vlr_renda_familiar) AS renda_media
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
GROUP BY dl.uf
HAVING AVG(vlr_renda_familiar) > (
  SELECT AVG(vlr_renda_familiar)
  FROM t_mcmv
)
ORDER BY renda_media DESC, dl.uf;

-- Visualizando quais UFs tem a média de renda familiar menor do que a média nacional

SELECT dl.uf, AVG(vlr_renda_familiar) AS renda_media
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
GROUP BY dl.uf
HAVING AVG(vlr_renda_familiar) < (
  SELECT AVG(vlr_renda_familiar)
  FROM t_mcmv
)
ORDER BY renda_media DESC, dl.uf;

-- Visualizando o valor médio nacional de financiamento

SELECT CAST(AVG(vlr_financiamento) AS DECIMAL(18,2)) AS financiamento_medio
FROM t_mcmv t
ORDER BY financiamento_medio DESC

-- Visualizando o valor médio mínimo e máximo nacional de financiamento

SELECT 
  MAX(vlr_financiamento) AS financiamento_maximo,
  MIN(vlr_financiamento) AS financiamento_minimo
FROM t_mcmv
WHERE vlr_financiamento > 1; -- para ignorar os registros sem financiamento e pegar apenas linhas que tiveram algum valor


 -- Visualizando o valor médio de financiamento por UF

SELECT dl.uf, CAST(AVG(vlr_financiamento) AS DECIMAL(18,2)) AS financiamento_medio
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
GROUP BY dl.uf
ORDER BY financiamento_medio DESC, dl.uf;

 -- Visualizando o valor médio, mínimo e máximo de financiamento por UF

SELECT dl.uf, 
COUNT(*) AS total_quantidades,
MIN(vlr_financiamento) AS valor_minimo,
MAX(vlr_financiamento) AS valor_maximo,
CAST(AVG(vlr_financiamento) AS DECIMAL(18,2)) AS financiamento_medio
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
WHERE vlr_financiamento > 1 -- para ignorar os registros sem financiamento
GROUP BY dl.uf
ORDER BY financiamento_medio DESC, dl.uf;

SELECT dl.uf, 
COUNT(*) AS total_quantidades,
MIN(vlr_financiamento) AS valor_minimo,
MAX(vlr_financiamento) AS valor_maximo,
CAST(AVG(vlr_financiamento) AS DECIMAL(18,2)) AS financiamento_medio
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
WHERE vlr_financiamento > 1 -- para ignorar os registros sem financiamento
GROUP BY dl.uf
ORDER BY valor_minimo DESC, dl.uf;

 -- Visualizando (do mair para o menor) o total de financiamento por ANO, desconsiderando as linhas sem ano
SELECT  
  dt.ano AS ano_assinatura,
  CAST(SUM(vlr_financiamento) AS DECIMAL (18,2)) AS financiamento_total
FROM t_mcmv t
JOIN dim_tempo dt ON t.id_tempo = dt.id_tempo
WHERE dt.ano <> ' '
GROUP BY dt.ano
ORDER BY financiamento_total DESC;

-- Visualizando o total de financiamento por ANO, desconsiderando as linhas sem ano, em ordem cronológica
SELECT  
  dt.ano AS ano_assinatura,
  CAST(SUM(vlr_financiamento) AS DECIMAL (18,2)) AS financiamento_total
FROM t_mcmv t
JOIN dim_tempo dt ON t.id_tempo = dt.id_tempo
WHERE dt.ano <> ' '
GROUP BY dt.ano
ORDER BY ano_assinatura, financiamento_total DESC;

 -- Visualizando o total de financiamento por ANO, considerando as linhas sem ano
SELECT  
  dt.ano AS ano_assinatura,
  CAST(SUM(vlr_financiamento) AS DECIMAL(18,2)) AS financiamento_total
FROM t_mcmv t
JOIN dim_tempo dt ON t.id_tempo = dt.id_tempo
GROUP BY dt.ano
ORDER BY ano_assinatura, financiamento_total DESC;


-- Visualizando os valores de subsidio (desconto) por FGTS e OGU por UF

SELECT dl.uf, 
SUM(vlr_subsidio_desconto_fgts) AS total_fgts,
SUM(vlr_subsidio_desconto_ogu) AS total_ogu
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
GROUP BY dl.uf
ORDER BY total_fgts DESC, dl.uf;


-- Visualizando os valores de subsidio (desconto) por OGU por UF

SELECT dl.uf, 
SUM(vlr_subsidio_desconto_ogu) AS total_ogu
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
GROUP BY dl.uf
ORDER BY total_ogu DESC, dl.uf;

-- Visualizando os valores de subsidio (desconto) por FGTS por UF

SELECT dl.uf, 
SUM(vlr_subsidio_desconto_fgts) AS total_fgts
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
GROUP BY dl.uf
ORDER BY total_fgts DESC, dl.uf;


-- Visualizando os valores de equilibrio por FGTS e OGU por UF

SELECT dl.uf, 
SUM(vlr_subsidio_equilibrio_fgts) AS total_fgts,
SUM(vlr_subsidio_equilibrio_ogu) AS total_ogu
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
GROUP BY dl.uf
ORDER BY total_fgts DESC, dl.uf;



-- Visualizando a idade das pessoas quando assinaram o contrato e quantas pessoas com aquela idade por UF
SELECT dl.uf,
  DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura) AS idade,
  COUNT(*) AS quantidade
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
JOIN dim_tempo dt ON t.id_tempo = dt.id_tempo
WHERE t.dte_nascimento IS NOT NULL AND dt.data_assinatura IS NOT NULL
GROUP BY dl.uf, DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura)
ORDER BY idade;

-- Visualizando a idade média, menor idade e maior idade nacionais
SELECT
  AVG(DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura)) AS idade_média,
  MIN(DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura)) AS menor_idade,
  MAX(DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura)) AS maior_idade
FROM t_mcmv t
JOIN dim_tempo dt ON t.id_tempo = dt.id_tempo
WHERE t.dte_nascimento IS NOT NULL AND dt.data_assinatura IS NOT NULL


-- Visualizando a idade média, menor idade e maior idade por UF
SELECT dl.uf,
  AVG(DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura)) AS idade_média,
  MIN(DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura)) AS menor_idade,
  MAX(DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura)) AS maior_idade
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
JOIN dim_tempo dt ON t.id_tempo = dt.id_tempo
WHERE t.dte_nascimento IS NOT NULL AND dt.data_assinatura IS NOT NULL
GROUP BY dl.uf;


-- Visualizando os retornos com idades menor de 18 anos

SELECT 
	DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura) AS idade,
	COUNT(*) AS Quantidade
FROM t_mcmv t
JOIN dim_tempo dt ON t.id_tempo = dt.id_tempo
WHERE dt.data_assinatura IS NOT NULL AND DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura) < 18
GROUP BY DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura)

-- Visualizando os retornos com idades menor de 18 anos por regiao

SELECT dl.regiao,
	DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura) AS idade,
	COUNT(*) AS Quantidade
FROM t_mcmv t
JOIN dim_tempo dt ON t.id_tempo = dt.id_tempo
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
WHERE dt.data_assinatura IS NOT NULL AND DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura) < 18
GROUP BY DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura), dl.regiao
ORDER BY Quantidade DESC;

-- Visualizando os retornos com idades menor de 18 anos por UF

SELECT dl.uf AS UF,
	DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura) AS idade,
	COUNT(*) AS Quantidade
FROM t_mcmv t
JOIN dim_tempo dt ON t.id_tempo = dt.id_tempo
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
WHERE dt.data_assinatura IS NOT NULL AND DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura) < 18
GROUP BY DATEDIFF(YEAR, t.dte_nascimento, dt.data_assinatura), dl.uf
ORDER BY Quantidade DESC;

-- Percentual de registros sem taxa de juros informada por UF
/*SELECT mcmv_fgts_txt_uf AS UF,
  COUNT(*) AS total_contratos,
  SUM(CASE WHEN num_taxa_juros = '' THEN 1 ELSE 0 END) AS contratos_sem_taxa,
  CAST(
    100.0 * SUM(CASE WHEN num_taxa_juros = '' THEN 1 ELSE 0 END) / COUNT(*) 
    AS DECIMAL(5,2)
  ) AS percentual_sem_taxa
FROM t_mcmv
GROUP BY mcmv_fgts_txt_uf
ORDER BY percentual_sem_taxa DESC;
*/
SELECT 
  dl.uf AS UF,
  COUNT(*) AS total_contratos,
  SUM(CASE WHEN TRY_CAST(t.num_taxa_juros AS FLOAT) IS NULL THEN 1 ELSE 0 END) AS contratos_sem_taxa,
  CAST(
    100.0 * SUM(CASE WHEN TRY_CAST(t.num_taxa_juros AS FLOAT) IS NULL THEN 1 ELSE 0 END) / COUNT(*) 
    AS DECIMAL(5,2)
  ) AS percentual_sem_taxa
FROM t_mcmv t
JOIN dim_localidade dl ON t.id_localidade = dl.id_localidade
GROUP BY dl.uf
ORDER BY percentual_sem_taxa DESC;

-- Registros sem taxa de juros
SELECT COUNT(*) AS total_sem_taxa
FROM t_mcmv
WHERE num_taxa_juros IS NULL;

-- Percentual de registros sem taxa de juros informada
SELECT COUNT(*) AS total_contratos
FROM t_mcmv
WHERE num_taxa_juros IS NULL;

-- Registros sem taxa de juros por faixa de renda
SELECT dfr.faixa_renda,
COUNT(*) AS total_contratos
FROM t_mcmv t
JOIN dim_faixa_renda dfr ON t.id_faixa_renda = dfr.id_faixa_renda
WHERE num_taxa_juros IS NULL
GROUP BY dfr.faixa_renda;


-- Tipo de imovel mais financiado
SELECT dti.descricao_tipo_imovel,
  COUNT(*) AS quantidade
FROM t_mcmv t
JOIN dim_tipo_imovel dti ON t.id_tipo_imovel = dti.id_tipo_imovel
GROUP BY dti.descricao_tipo_imovel
ORDER BY quantidade DESC;

-- Análise do tipo de imóvel mais comum por faixa de renda
SELECT  dfr.faixa_renda,dti.descricao_tipo_imovel,
  COUNT(*) AS quantidade
FROM t_mcmv t
JOIN dim_faixa_renda dfr ON t.id_faixa_renda = dfr.id_faixa_renda
JOIN dim_tipo_imovel dti ON t.id_tipo_imovel = dti.id_tipo_imovel
GROUP BY dfr.faixa_renda, dti.descricao_tipo_imovel
ORDER BY dfr.faixa_renda, quantidade DESC;


-- Distribuição dos sistemas de amortização usados nos financiamentos
SELECT dsa.sistema,
  COUNT(*) AS total
FROM t_mcmv t
JOIN dim_sistema_amortizacao dsa ON t.id_sistema = dsa.id_sistema
GROUP BY dsa.sistema
ORDER BY total DESC;

SELECT 
  dsa.sistema,
  COUNT(*) AS total,
  CAST(
    100.0 * COUNT(*) / 
    (SELECT COUNT(*) FROM t_mcmv WHERE id_sistema IS NOT NULL)
    AS DECIMAL(5,2)
  ) AS percentual_sobre_total
FROM t_mcmv t
JOIN dim_sistema_amortizacao dsa ON t.id_sistema = dsa.id_sistema
GROUP BY dsa.sistema
ORDER BY total DESC;



