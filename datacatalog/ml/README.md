# Trabalho Prático — DataOps & Data Quality

**FIAP — MBA em Engenharia de Dados**
Prof. André Pontes Sampaio · Versão 3

---

## Sumário

1. [Contexto e Objetivo](#1-contexto-e-objetivo)
2. [Etapa 1 — Deploy da Aplicação](#2-etapa-1--deploy-da-aplicação)
3. [Etapa 2 — Análise da Arquitetura e Modelo de Maturidade](#3-etapa-2--análise-da-arquitetura-e-modelo-de-maturidade)
4. [Etapa 3 — Critérios de Qualidade de Dados Implementados](#4-etapa-3--critérios-de-qualidade-de-dados-implementados)
5. [Estrutura do Repositório](#5-estrutura-do-repositório)
6. [Dataset — curso.txt](#6-dataset--cursotxt)
7. [Pipeline de Dados e Transformações](#7-pipeline-de-dados-e-transformações)
8. [Resultados dos Testes](#8-resultados-dos-testes)

---

## 1. Contexto e Objetivo

A adoção de práticas de **DataOps** na construção de pipelines de dados é essencial para empresas que buscam agilidade, qualidade e governança na gestão de seus dados. DataOps promove ciclos de entrega mais curtos, redução de erros e maior confiabilidade nas informações disponibilizadas, apoiando decisões estratégicas através de pipelines bem estruturados.

Este trabalho implementa **testes automatizados de qualidade de dados** em Python/Jupyter sobre um dataset educacional, cobrindo os sete critérios exigidos pelo enunciado:

| # | Critério | Objetivo |
| --- | ---------- | ---------- |
| I | Schema | Verificar colunas, nomes e tipos de dados |
| II | Volume | Verificar quantidade de registros e completude |
| III | Valores | Verificar domínios e conjuntos de valores permitidos |
| IV | Numéricos e Datas | Verificar ranges, mínimos, máximos e estatísticas |
| V | Formatos | Verificar padrões e estrutura de campos |
| VI | Unicidade | Verificar chaves primárias e identificadores únicos |
| VII | Integridade Referencial | Verificar consistência lógica entre colunas relacionadas |

---

## 2. Etapa 1 — Deploy da Aplicação

### Pré-requisitos

- Docker e Docker Compose instalados
- Git instalado

### Passos para deploy

```bash
# 1. Clonar o repositório
git clone https://github.com/tonanuvem/datacatalog.git
cd datacatalog

# 2. Subir o ambiente Jupyter com o notebook do trabalho
sh trabalho.sh
```

O script `trabalho.sh` executa:

```bash
# Para todos os containers em execução (evitar conflito de portas)
docker ps -q | xargs -r docker stop

# Sobe o Jupyter Notebook via Docker Compose
docker-compose -f docker-compose-jupyter.yml up -d
```

Ao final do script, a URL de acesso ao Jupyter é exibida no terminal:

```
TRABALHO : definir e implementar critérios de qualidade de dados.
- JUPYTER AUTO ML : http://<IP>:8789/?token=<TOKEN>
```

Abrir o arquivo `trab_testes_data_quality.ipynb` no Jupyter para executar os testes.

### Destruir o ambiente

```bash
exit
sh destruir.sh
```

### Serviços disponíveis

| Serviço | Porta | Descrição |
| --------- | ------- | ----------- |
| Jupyter Notebook | `8789` | Ambiente de execução dos testes (AutoML) |
| MySQL (curso DB) | `3366` | Banco de dados com tabela `curso` |
| phpMyAdmin | `8082` | Interface web para o MySQL |
| Kafka | `9092` | Plataforma de streaming de eventos |
| Debezium Connect | `8073` | CDC — Change Data Capture |
| Kowl | `8070` | Visualizador de tópicos Kafka |

### Arquitetura dos containers (docker-compose)

```
┌─────────────────────────────────────────────────────────┐
│                     Rede: app_net                        │
│                  (172.16.240.0/24)                       │
│                                                          │
│  ┌──────────────┐    ┌──────────────┐                   │
│  │   Jupyter    │    │    MySQL     │◄── phpMyAdmin      │
│  │  (automl)    │    │  cursomysql  │    (porta 8082)    │
│  │  porta 8789  │    │  porta 3366  │                    │
│  └──────────────┘    └──────────────┘                   │
│          │                   ▲                           │
│          │ lê curso.txt      │ CDC                       │
│          ▼                   │                           │
│  ┌──────────────┐    ┌──────────────┐                   │
│  │  Pipeline DQ │    │   Debezium   │◄── Zookeeper      │
│  │  (notebook)  │    │   Connect    │    (porta 2181)   │
│  └──────────────┘    │  porta 8073  │                   │
│                      └──────┬───────┘                   │
│                             │                            │
│                      ┌──────▼───────┐                   │
│                      │    Kafka     │◄── Kowl            │
│                      │  porta 9092  │    (porta 8070)   │
│                      └──────────────┘                   │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Etapa 2 — Análise da Arquitetura e Modelo de Maturidade

### Questão: A partir de qual modelo de maturidade devemos ter testes de qualidade de dados no pipeline?

**Resposta: A partir do Stage 1 (Batch), com evolução obrigatória no Stage 2 (Realtime).**

### Modelos de Maturidade

| Stage | Nome | Arquitetura | Necessidade de Testes DQ |
| ------- | ------ | ------------- | -------------------------- |
| **0** | None | Monolith → DB | Não há pipeline; dados não saem do sistema fonte |
| **1** | Batch | Monolith → DB → Scheduler → DWH | **Mínimo viável**: testes de schema e volume |
| **2** | Realtime | Monolith → DB → Streaming Platform → DWH | **Obrigatório**: adicionar testes de valores e formatos |
| **3** | Integration | Múltiplos serviços → NoSQL/DB/NewSQL → Streaming → DWH/Search/GraphDB | **Crítico**: unicidade e integridade referencial entre fontes |
| **4** | Automation | Stage 3 + Data Catalog + MLOps + DLP + Orchestration + Monitoring | **Completo**: todos os 7 critérios automatizados no pipeline |
| **5** | Decentralization | Stage 4 com múltiplos DWHs descentralizados | **Crítico por domínio**: testes DQ distribuídos por equipe |

### Justificativa

No **Stage 0** os dados ficam confinados ao monolito — não há movimento de dados, portanto não há pipeline para testar.

No **Stage 1** os dados começam a ser copiados para um DWH por um scheduler. Um erro de schema ou um volume inesperado pode silenciosamente corromper relatórios analíticos sem que ninguém perceba. Por isso, testes de **schema** e **volume** já devem estar presentes aqui — são o mínimo indispensável.

No **Stage 2** os dados fluem em tempo real. Um registro inválido pode se propagar por toda a cadeia antes de ser detectado. Testes de **valores** (domínio) e **formatos** tornam-se obrigatórios.

No **Stage 3 em diante**, com múltiplas fontes heterogêneas, os testes de **unicidade** e **integridade referencial** passam a ser críticos para evitar duplicatas e inconsistências entre sistemas.

> Em resumo: **qualidade de dados deve começar no Stage 1 e evoluir junto com a maturidade da plataforma**. Quanto mais tarde os testes são introduzidos, maior o custo de correção e o risco de decisões baseadas em dados incorretos.

---

## 4. Etapa 3 — Critérios de Qualidade de Dados Implementados

Os testes estão no arquivo [`trab_testes_data_quality.ipynb`](trab_testes_data_quality.ipynb) e são aplicados em **quatro estados progressivos** do DataFrame ao longo do pipeline de transformações:

| DataFrame | Estado |
| ----------- | -------- |
| `df_data_1` | Dados brutos carregados do CSV |
| `df_data_2` | Após tratamento de NaN em `INGLES` (preenchido com `-1`) |
| `df_data_3` | Após imputação de `NOTA_MAT_4` com `0` via `SimpleImputer` |
| `df_data_4` | Após criação de colunas `CURSOU_MAT_X_DESC` e imputação da média |

---

### I. Testes de Schema

**Objetivo:** Verificar se as colunas esperadas estão presentes e com os tipos de dados corretos.

**O que é verificado:**
- Presença das 15 colunas esperadas
- Tipos de dados corretos para cada coluna (`int64`, `float64`, `object`)
- Colunas extras não esperadas (aviso)

**Colunas e tipos esperados:**

| Coluna | Tipo Esperado |
| -------- | -------------- |
| `MATRICULA` | `int64` |
| `NOME` | `object` |
| `REPROVACOES_MAT_1` a `4` | `int64` |
| `NOTA_MAT_1` a `4` | `float64` |
| `INGLES` | `float64` |
| `H_AULA_PRES`, `TAREFAS_ONLINE`, `FALTAS` | `int64` |
| `PERFIL` | `object` |

**Resultado:** `[OK]` — 15 colunas presentes, todos os tipos corretos.

---

### II. Testes de Volume

**Objetivo:** Verificar se a quantidade de dados está dentro do esperado.

**O que é verificado:**
- DataFrame não está vazio (> 0 linhas)
- Volume mínimo atingido (≥ 10 registros)
- Número correto de colunas (= 15)
- Nenhuma coluna com mais de 20% de valores nulos

**Resultado:** `[OK]` — 199 linhas × 15 colunas. Colunas `NOTA_MAT_4` e `INGLES` possuem 37 NaN cada (18,6% — abaixo do limite de 20%).

---

### III. Testes de Valores (Domínio)

**Objetivo:** Verificar se valores em colunas categóricas pertencem ao conjunto esperado.

**O que é verificado:**

**Em `df_data_1` (dados brutos):**
- `PERFIL` contém apenas: `{'EXCELENTE', 'MUITO_BOM', 'BOM', 'REGULAR', 'DIFICULDADE'}`
- `INGLES` contém apenas: `{0.0, 1.0, NaN}`
- Todas as colunas `REPROVACOES_MAT_X` são não-negativas

**Em `df_data_2` (após tratamento de NaN):**
- `INGLES` não contém mais NaN (substituído por `-1`)
- `INGLES` contém o valor `-1` (indicador de "SEM RESPOSTA")
- `INGLES` contém apenas: `{-1.0, 0.0, 1.0}`

**Em `df_data_4` (após criação de colunas descritivas):**
- `CURSOU_MAT_X_DESC` contém apenas: `{-1, 0, 1}`
  - `1` = APROVADO (nota ≥ 4 e sem reprovações)
  - `0` = REPROVADO (nota < 4 e com reprovações)
  - `-1` = AINDA NÃO CURSOU (nota imputada com média)

**Resultado:** `[OK]` — Todos os domínios validados.

---

### IV. Testes Numéricos e Datas

**Objetivo:** Verificar se valores numéricos estão dentro dos ranges esperados.

**O que é verificado:**

**Em `df_data_1` (dados brutos):**
- `NOTA_MAT_X`: range `[0.0, 10.0]` — min e max verificados para as 4 matérias
- `REPROVACOES_MAT_X`, `H_AULA_PRES`, `TAREFAS_ONLINE`, `FALTAS`: sem valores negativos

**Em `df_data_3` (após imputação de `NOTA_MAT_4`):**
- `NOTA_MAT_4`: sem NaN após imputação com `0`
- `NOTA_MAT_4`: mínimo = `0.0` (confirmação da imputação)
- `NOTA_MAT_4`: máximo ≤ `10.0` (range preservado)
- Contagem de zeros ≥ quantidade de NaN originais (37)

**Em `df_data_4` (após imputação de média):**
- Registros com `CURSOU_MAT_X_DESC == -1` têm `NOTA_MAT_X == média calculada`
- Nenhum NaN remanescente nas colunas de nota

**Médias calculadas para imputação (alunos que cursaram):**

| Coluna | Média |
| -------- | ------- |
| `NOTA_MAT_1` | ~5.14 |
| `NOTA_MAT_2` | ~5.00 |
| `NOTA_MAT_3` | ~4.76 |
| `NOTA_MAT_4` | ~4.22 |

**Resultado:** `[OK]` — Todos os ranges e imputações validados.

---

### V. Testes de Formatos

**Objetivo:** Verificar se campos de texto e identificadores seguem o padrão esperado.

**O que é verificado:**
- `MATRICULA`: inteiro positivo de exatamente 6 dígitos
- `NOME`: campo não-vazio e não apenas espaços em branco
- `NOME`: contém pelo menos um espaço (nome + sobrenome)

**Regra de formato de MATRICULA:**
```
MATRICULA deve ser um inteiro positivo de 6 dígitos (ex.: 502375, 397093)
```

**Resultado:** `[OK]` — 199/199 matrículas com 6 dígitos; 199/199 nomes preenchidos com sobrenome.

---

### VI. Testes de Unicidade

**Objetivo:** Verificar se colunas que servem como identificadores são de fato únicas.

**O que é verificado:**
- `MATRICULA`: chave primária — sem duplicatas (`is_unique == True`)
- Par `(MATRICULA, NOME)`: sem duplicatas
- `NOME`: verificação de homônimos (aviso informativo)

**Resultado:** `[OK]` — 199 MATRÍCULAs distintas em 199 registros. `is_unique = True`.

---

### VII. Testes de Integridade Referencial

**Objetivo:** Verificar a consistência lógica entre colunas relacionadas dentro da mesma tabela.

**Regras verificadas:**

**Em `df_data_1` (dados brutos):**

| Regra | Descrição |
| ------- | ----------- |
| Se `NOTA_MAT_X < 4` (e nota > 0) → `REPROVACOES_MAT_X > 0` | Aluno com nota baixa deve ter reprovações registradas |
| Se `NOTA_MAT_X ≥ 4` → `REPROVACOES_MAT_X == 0` | Aluno aprovado não deve ter reprovações |

**Em `df_data_4` (após criação das colunas descritivas):**

| Valor `CURSOU_MAT_X_DESC` | Condição esperada |
| -------------------------- | ------------------- |
| `1` (APROVADO) | `NOTA_MAT_X ≥ 4` E `REPROVACOES_MAT_X == 0` |
| `0` (REPROVADO) | `NOTA_MAT_X < 4` E `REPROVACOES_MAT_X > 0` |
| `-1` (AINDA NÃO CURSOU) | `NOTA_MAT_X == média_imputada` E `REPROVACOES_MAT_X == 0` |

**Resultado obtido em `df_data_4`:**

| Matéria | APROVADO (1) | REPROVADO (0) | NÃO CURSOU (-1) | Violações |
| --------- | ------------- | -------------- | ---------------- | ----------- |
| MAT_1 | 163 alunos | 36 alunos | 0 alunos | 0 |
| MAT_2 | 163 alunos | 36 alunos | 0 alunos | 0 |
| MAT_3 | 155 alunos | 44 alunos | 0 alunos | 0 |
| MAT_4 | 124 alunos | 44 alunos | 31 alunos | 0 |

**Resultado:** `[OK]` — 0 violações de integridade referencial em todos os estados do pipeline.

---

## 5. Estrutura do Repositório

```
datacatalog/
├── trabalho.sh                        # Script principal de deploy do trabalho
├── docker-compose-jupyter.yml         # Jupyter Notebook (porta 8789)
├── docker-compose-curso.yml           # MySQL + phpMyAdmin
├── docker-compose-eventos.yml         # Kafka + Zookeeper + Debezium + Kowl
├── ml/
│   ├── trab_testes_data_quality.ipynb # Notebook com os 7 critérios implementados
│   ├── curso.txt                      # Dataset educacional (199 alunos, 15 colunas)
│   └── README.md                      # Este arquivo
├── mysql/
│   ├── Dockerfile.mysql.curso_id_logs
│   └── init/
│       ├── mysql_init_database.sql    # DDL + carga inicial da tabela curso
│       └── mysql_run_config.sql       # Configurações do MySQL (CDC/binlog)
├── cluster/                           # Configurações para ambiente em cluster
├── bkp/                               # Backups de configurações anteriores
└── README.md                          # Documentação geral do projeto
```

---

## 6. Dataset — curso.txt

Dataset com dados de **199 estudantes** para classificação de perfil acadêmico e treinamento de modelo de Machine Learning.

### Variáveis de entrada (features)

| Coluna | Tipo | Descrição |
| -------- | ------ | ----------- |
| `MATRICULA` | `int64` | Identificador único do estudante (6 dígitos) |
| `NOME` | `object` | Nome completo do estudante |
| `REPROVACOES_MAT_1` a `4` | `int64` | Número de reprovações por disciplina |
| `NOTA_MAT_1` a `4` | `float64` | Média das notas por disciplina (0–10) |
| `INGLES` | `float64` | Conhecimento em inglês: `0`=não, `1`=sim, `NaN`=não informado |
| `H_AULA_PRES` | `int64` | Horas de estudo presencial |
| `TAREFAS_ONLINE` | `int64` | Número de tarefas online entregues |
| `FALTAS` | `int64` | Total de faltas acumuladas |

### Variável-alvo

| Coluna | Valores possíveis |
| -------- | ------------------ |
| `PERFIL` | `EXCELENTE`, `MUITO_BOM`, `BOM`, `REGULAR`, `DIFICULDADE` |

### Distribuição de PERFIL no dataset

| Perfil | Qtd | % | Necessita Mentoria |
| -------- | ----- | --- | -------------------- |
| DIFICULDADE | 77 | 38,7% | Sim (várias disciplinas) |
| REGULAR | 72 | 36,2% | Sim (algumas matérias) |
| BOM | 38 | 19,1% | Não |
| MUITO_BOM | 9 | 4,5% | Não |
| EXCELENTE | 3 | 1,5% | Não |

### Dados faltantes (df_data_1)

| Coluna | NaN | % |
| -------- | ----- | --- |
| `NOTA_MAT_4` | 37 | 18,6% |
| `INGLES` | 37 | 18,6% |
| Demais colunas | 0 | 0% |

---

## 7. Pipeline de Dados e Transformações

```
curso.txt
    │
    ▼
[df_data_1] ─── Dados brutos carregados
    │           └─ Testes DQ: Schema, Volume, Valores, Numéricos,
    │                         Formatos, Unicidade, Integridade Ref.
    │
    ▼
Transformação 1a: INGLES NaN → -1 (fillna)
    │
    ▼
[df_data_2] ─── INGLES sem NaN
    │           └─ Testes DQ: Valores (INGLES revisão)
    │
    ▼
Transformação 1b: NOTA_MAT_4 NaN → 0 (SimpleImputer)
    │
    ▼
[df_data_3] ─── NOTA_MAT_4 sem NaN
    │           └─ Testes DQ: Numéricos (NOTA_MAT_4 revisão)
    │
    ▼
Transformação 2a: Criar CURSOU_MAT_X_DESC (1/0/-1)
Transformação 2b: NOTA_MAT_X (onde DESC==-1) → média dos que cursaram
    │
    ▼
[df_data_4] ─── Dataset final para ML
    │           └─ Testes DQ: Valores (novas colunas),
    │                         Numéricos (médias imputadas),
    │                         Integridade Ref. (CURSOU_MAT_X_DESC)
    │
    ▼
DecisionTreeClassifier
    │
    ▼
curso_ml_transformado.csv
```

### Regras de negócio das colunas `CURSOU_MAT_X_DESC`

| Valor | Rótulo | Condição |
| ------- | -------- | ---------- |
| `1` | APROVADO | `NOTA_MAT_X ≥ 4` AND `REPROVACOES_MAT_X == 0` |
| `0` | REPROVADO | `NOTA_MAT_X < 4` AND `REPROVACOES_MAT_X > 0` |
| `-1` | AINDA NÃO CURSOU | `NOTA_MAT_X == 0` AND `REPROVACOES_MAT_X == 0` |

---

## 8. Resultados dos Testes

Todos os testes foram executados com sucesso — **0 falhas de asserção**.

### Resumo geral

| Critério | Estado | Células no Notebook |
| ---------- | -------- | --------------------- |
| I — Schema | PASSOU | `df_data_1` |
| II — Volume | PASSOU | `df_data_1` |
| III — Valores | PASSOU | `df_data_1`, `df_data_2`, `df_data_4` |
| IV — Numéricos | PASSOU | `df_data_1`, `df_data_3`, `df_data_4` |
| V — Formatos | PASSOU | `df_data_1` |
| VI — Unicidade | PASSOU | `df_data_1` |
| VII — Integridade Referencial | PASSOU | `df_data_1`, `df_data_4` |

### Observações e achados relevantes

- **NOTA_MAT_4 e INGLES** apresentam 37 NaN cada (18,6%) — abaixo do limiar de alerta de 20%, mas recomenda-se investigar a origem desses valores ausentes no sistema fonte.
- **MUITO_BOM** é armazenado com underscore (`MUITO_BOM`) no dataset, divergindo do enunciado que usa espaço (`MUITO BOM`). Os testes foram ajustados para refletir o valor real do dado.
- **MAT_4** é a única disciplina com alunos classificados como "AINDA NÃO CURSOU" (31 alunos = 15,6%). Para essas linhas, a nota foi imputada com a média dos alunos que cursaram (≈ 4,22). A integridade referencial confirma que nenhuma dessas linhas possui reprovações registradas.
- O modelo **DecisionTreeClassifier** treinado ao final do notebook utiliza os dados tratados (`df_data_4`), demonstrando como a qualidade dos dados upstream impacta diretamente a confiabilidade do modelo de Machine Learning.

---

*Trabalho desenvolvido no contexto do MBA em Engenharia de Dados — FIAP, 2025.*
