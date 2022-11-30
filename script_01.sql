-- Atenção! A sintaxe abaixo é do banco SQLite

/* 1FN - Primeira forma normal.

Dizemos que uma tabela está na Primeira, quando:
	- Possui uma chave primária
	- Ela não possui atributos multivalorados
		(os valores dos atributos devem ser atômicos ou indivisíveis)
	- Não possui atributos compostos

**/

-- Exemplo de tabela fora da 1FN

CREATE TABLE IF NOT EXISTS tb_contatos(
	id INTEGER NOT NULL,
	nome TEXT NOT NULL,
	endereco TEXT NOT NULL,
	telefone TEXT NOT NULL
);

-- Inserindo alguns registros

INSERT INTO tb_contatos (id, nome, endereco, telefone) VALUES
	(2, "João", "Rua Dez, 1000, Garcia, Blumenau, SC", "47988182464"),
	(3, "José", "Rua Quinze, 16, Ponta Aguda, Blumenau, SC", "47988246478, 23401865"),
	(4, "Maria", "Rua do Bosque, 98, Vila Itoupava, Blumenau, SC", "47999952413, 23401865");

SELECT * FROM tb_contatos;

-- Renomeando a tabela tb_contatos
ALTER TABLE tb_contatos RENAME TO tb_contatos_naonormalizada;

-- Aplicando as regras da 1FN

/*
 * Definimos a coluna id como chave primária;
 * Retiramos a coluna telefones, e criamos a tabela tb_telefones para armazenar os múltiplos
 * valores de telefone, removendo assim a coluna multivalorada e;
 * 'Quebramos' o campo composto endereço em vários outros campos (logradouro, numero e etc)
 */

CREATE TABLE IF NOT EXISTS tb_contatos(
	-- Definir um campo como chave primária
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	nome TEXT NOT NULL,
	tipo_logradouro TEXT NOT NULL,
	logradouro TEXT NOT NULL,
	numero TEXT NOT NULL,
	bairro TEXT NOT NULL,
	cidade TEXT NOT NULL,
	uf TEXT NOT NULL
);

/*
 * Aqui criamos uma tabela para armazenar os dados de telefone dos contatos. Dessa maneira
 * podemos retirar o atributo multivalorado 'telefone' da tabela tb_contatos
 */
CREATE TABLE IF NOT EXISTS tb_telefones(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	id_contato INTEGER NOT NULL,
	telefone TEXT NOT NULL,
	FOREIGN KEY (id_contato) REFERENCES tb_contatos (id)
);

SELECT * FROM tb_contatos tc ;
SELECT * FROM tb_telefones tt ;

-- Para converter os dados, rode o arquivo script_01.py

-- Atenção! A sintaxe abaixo é do banco SQLite

/* 2FN - Segunda forma normal.

A segunda forma normal é baseada no conceito de dependência funcional total
Para estar na 2FN, uma tabela precisa:
	- Estar na 1FN;
	- Todo atributo da tabela deve ser dependente de todas as partes da chave primária;
	- Caso exista um atributo que dependa parcialmente da chave, esse atributo
	deve estar em outra tabela.

*/

-- Exemplo de tabela fora da 2FN

CREATE TABLE IF NOT EXISTS tb_itens(
	id INTEGER,
	id_fornecedor INTEGER,
	uf_fornecedor TEXT NOT NULL,
	telefone_fornecedor TEXT NOT NULL,
	qtd_estoque INT NOT NULL,
	PRIMARY KEY(id, id_fornecedor)
);

INSERT INTO tb_itens (id, id_fornecedor, uf_fornecedor , telefone_fornecedor, qtd_estoque) VALUES
(1001, 10, "SP", "23784449", 150),
(1002, 10, "SP", "23784449", 90),
(1002, 11, "CE", "28900198", 12);

SELECT * FROM tb_itens ti ;

/*
 * Como visto, os campos uf_fornecedor e telefone_fornecedor estão dentro do mesmo domínio que id_fornecedor,
 * ou seja, dependem apenas de 1 lado da chave primária.
 * Nesse caso, precisamos remover esses campos da tabela de itens e colocá-los em outra tabela,
 * que no caso, chamaremos de tb_fornecedores.
 */

CREATE TABLE IF NOT EXISTS tb_fornecedores(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	uf_fornecedor TEXT NOT NULL,
	telefone_fornecedor TEXT NOT NULL
);

-- Renomear a tb_itens para criação da nova tb_itens
ALTER TABLE tb_itens RENAME TO tb_itens_naonormalizada;

-- Criar a nova tabela tb_itens, já com a 2FN aplicada
CREATE TABLE IF NOT EXISTS tb_itens(
	id INTEGER NOT NULL,
	id_fornecedor INTEGER NOT NULL,
	qtd_estoque INTEGER NOT NULL,
	PRIMARY KEY(id, id_fornecedor),
	FOREIGN KEY(id_fornecedor) REFERENCES tb_fornecedores(id)
);

SELECT * FROM tb_fornecedores tf ;
SELECT * FROM tb_itens ti ;

-- Atenção! A sintaxe abaixo é do banco SQLite

/*
 * 3FN - Terceira Forma Normal.
 *
 * Baseada no conceito de dependência transitiva
 * A tabela não deve ter um atributo não chave dependente de outro atributo não chave.
 *
 * Para estar na 3FN, uma tabela deve:
 * 	- Estar na 2FN;
 * 	- Não podem existir dependências transitivas
 */

CREATE TABLE IF NOT EXISTS tb_pedidos_itens(
	id_pedido INTEGER NOT NULL,
	id_item INTEGER NOT NULL,
	quantidade INTEGER NOT NULL,
	valor_unitario REAL NOT NULL, --> REAL = float
	subtotal REAL NOT NULL
);

SELECT * FROM tb_pedidos_itens tpi ;

INSERT INTO tb_pedidos_itens (id_pedido, id_item, quantidade, valor_unitario, subtotal) VALUES
	(1, 20, 3, 3.59, 3.59 * 3),
	(1, 21, 5, 1.19, 1.19 * 5),
	(1, 49, 11, 0.68, 0.68 * 11);

/*
 * A coluna subtotal depende do resultado da multiplicação entre as colunas 'quantidade' e 'valor_unitario'
 * ou seja, temos um atributo não chave da tabela dependendo de outro(s) atributo(s) não chave.
 * Nesse caso, devemos excluir a coluna subtotal, e fazer esse cálcuulo na hora em que estivermos
 * trazendo as informações da tabela.
 */

-- 1: Excluir a coluna 'subtotal'
ALTER TABLE tb_pedidos_itens DROP COLUMN subtotal;

-- 2: Fazer a operação de multiplicação e apresentar como a coluna subtotal, utilizando 'AS'
-- A coluna 'subtotal' existirá apenas enquanto o comando SELECT estiver sendo executado.
-- Ou seja, ela não existe mais fisicamente na tabela.
SELECT
	id_pedido, id_item, quantidade, valor_unitario, quantidade * valor_unitario AS "subtotal"
FROM tb_pedidos_itens tpi ;