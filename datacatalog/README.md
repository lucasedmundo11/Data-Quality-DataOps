# Data governance

<img width="650" alt="image" src="https://github.com/user-attachments/assets/648404c0-48a0-4be3-9735-ebb47164a6f9" />


## 💡 Como garantir Qualidade dos Dados em DataOps usando testes

Esses testes podem ser incorporados em pipelines de dados usando frameworks como Great Expectations ou dbt. A prática recomendada é iniciar com os testes básicos (schema, volume, validade) e evoluir conforme o conhecimento do domínio aumenta.

## ✅ 1. Testes de Esquema (Schema Tests)

### Objetivo: Verificar se as colunas esperadas existem, estão na ordem correta e com os tipos corretos.

#### Tipos de verificação:

    Verificar nomes, ordem e tipo das colunas.

    Verificar apenas nomes e tipos.

    Verificar colunas específicas.

    Verificar apenas a quantidade de colunas.

#### Exemplo para a tabela curso:

    Garantir que ID seja do tipo INTEGER e esteja presente.

    Garantir que NOTA_MAT_1 a NOTA_MAT_4 sejam do tipo NUMERIC.

    Verificar que a tabela tenha exatamente 15 colunas.

## 📊 2. Testes de Volume (Volume Tests)

### Objetivo: Verificar se a quantidade de dados (linhas) está dentro do esperado.

#### Tipos de verificação:

    Verificar contagem de linhas com um valor fixo (ex.: exatamente 1.000 registros).

    Verificar com base em valores dinâmicos (comparação com médias históricas).

#### Exemplo:

    Esperar que a tabela curso tenha entre 19.000 e 21.100 registros.

## 📏 3. Testes de Validade (Validity Tests)

### Objetivo: Verificar se os dados são plausíveis, mesmo sem uma fonte de verdade.

#### Tipos de testes:
a) Conjuntos finitos (valores fixos permitidos):

    Valores devem estar dentro de um conjunto (ex.: PERFIL ∈ {“DIFICULDADE”, “MUITO BOM”, “EXCELENTE”}).

    Valores não devem estar em um conjunto (ex.: PERFIL ≠ “inválido”).

    Valor mais comum deve estar em um conjunto.

b) Numéricos e datas:

    Valores dentro de um intervalo (NOTA_MAT_1 entre 0 e 10).

    Estatísticas como média, mediana, desvio padrão.

    Soma total de colunas (ex.: total de FALTAS < 10.000).

c) Formato (shape):

    Verificar tamanho do valor (NOME com até 157 caracteres).

    Verificar se o valor segue um padrão (MATRICULA com 6 dígitos numéricos).

    Garantir que certos padrões não estejam presentes (ex.: não permitir ALUNO COM NOTA ZERO E SEM REPROVAÇÃO).

## 🆔 4. Testes de Unicidade (Uniqueness Tests)

### Objetivo: Verificar se valores que devem ser únicos realmente são.

#### Exemplo:

    ID deve ser único.

    MATRICULA deve ser única por estudante.

    A proporção de valores únicos em NOME deve estar entre 90% e 100%.

## 🔗 5. Testes de Integridade Referencial (Referential Integrity Testing)

### Objetivo: Verificar relações entre colunas ou entre tabelas.

#### Tipos de verificação:

    Entre colunas: Consistência interna. Ex: se REPROVACOES_MAT_1 > 0, então NOTA_MAT_1 deve ser < 4.

    Entre tabelas: Validar que MATRICULA existe em uma tabela CURSO.

