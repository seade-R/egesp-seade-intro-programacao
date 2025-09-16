# ============================================================================
# Material de Apoio — Aula 6
# Tutoriais obrigatórios e opcionais | Review breve | Resolução do desafio
# ============================================================================

library(tidyverse)
library(janitor)
library(scales)

# ============================================================================
# 1) REVIEW BREVE — Tutoriais
# ----------------------------------------------------------------------------

# TUTORIAIS OBRIGATÓRIOS -----------------------------------------------------

# Tutorial 10 — Bases de dados relacionais com dplyr
# -------------------------------------------------
# Principais funções:
#   inner_join(x, y, by=...) -> mantém apenas correspondências
#   left_join(x, y, by=...)  -> mantém todas as linhas de x
#   right_join(x, y, by=...) -> mantém todas as linhas de y
#   full_join(x, y, by=...)  -> mantém todas as linhas de x e y
#
# Filtering joins (úteis para auditoria):
#   semi_join(x, y) -> mantém x que tem correspondência em y
#   anti_join(x, y) -> mantém x que NÃO tem correspondência em y
#
# Erros comuns:
# - Chaves com nomes diferentes -> usar by = c("id_x"="id_y")
# - Chaves duplicadas -> número de linhas explode
# - NA nas colunas vindas do join ≠ zero (significa ausência de correspondência)

# Tutorial 11 — Indivíduos e domicílios (TICDOM)
# -----------------------------------------------
# Cenário: juntar tabela de indivíduos com tabela de domicílios.
#   left_join(individuos, domicilios, by="id_domicilio")
#   -> mantém todos os indivíduos, mesmo sem domicílio correspondente
#
# Erros comuns:
# - Confundir qual é a base principal (se usar right_join muda a lógica)
# - Colunas duplicadas fora da chave aparecem como .x/.y
# - NA em variáveis do domicílio = indivíduo não encontrado na base domiciliar

# TUTORIAS OPCIONAIS ---------------------------------------------------------

# ============================================================================
# Tutorial 9 — R Base
# -------------------
# Indexação: df[linhas, colunas]
# Funções úteis: order(), cut(), duplicated(), merge()
# Erros comuns: confundir NA com NULL; esquecer a vírgula em df[,2]
# ============================================================================

# Criando um data frame de exemplo
df <- data.frame(
  id = 1:6,
  idade = c(23, 45, 31, 23, 45, NA),
  renda = c(2000, 3500, 1800, 2000, 3500, 4000),
  sexo = c("M", "F", "M", "M", "F", "F")
)

# Indexação por linha e coluna
df[1, ]          # primeira linha
df[, 2]          # segunda coluna (vetor)
df[, "renda"]    # coluna pelo nome
df[1:3, c(2,3)]  # linhas 1 a 3, colunas 2 e 3

# Usando order() para ordenar
df[order(df$renda, decreasing = TRUE), ]

# Usando cut() para criar categorias
df$faixa_idade <- cut(df$idade, breaks = c(0, 30, 60), labels = c("jovem", "adulto"))
table(df$faixa_idade)

# Identificar duplicados
duplicated(df$renda)
df[duplicated(df$renda), ]

# Merge em R base
df2 <- data.frame(id = c(1,2,3), cidade = c("SP","RJ","BH"))
merge(df, df2, by = "id", all.x = TRUE)

# Cuidado: diferença entre NA e NULL
is.na(df$idade)        # verifica valores ausentes
is.null(df$idade)      # FALSE, porque a coluna existe
df$nova <- NULL        # exclui a coluna

# ============================================================================
# Tutorial 12 — Integração com Power BI
# -------------------------------------
# Exportar dados do R para importar no Power BI
# Erros comuns: usar pacotes não suportados; caminhos absolutos
# ============================================================================

# Exportando CSVs
write_csv(df, "dados_utf8.csv")                 # UTF-8 (bom para R e Python)
write.csv2(df, "dados_latin1.csv", fileEncoding = "Latin1") # compatível com Power BI

# Transformações simples no R antes de levar ao Power BI
df_limpo <- df %>%
  clean_names() %>%
  mutate(renda_mil = renda/1000)

# ============================================================================
# Tutorial 13 — Integração com SQL
# --------------------------------
# Pacotes: DBI, duckdb, RSQLite, RMySQL
# Erros comuns: esquecer de fechar a conexão; senhas escritas no código
# ============================================================================

library(DBI)
library(duckdb)

# Conexão DuckDB em memória
con <- dbConnect(duckdb::duckdb())

# Criando tabela e consultando
dbWriteTable(con, "tabela_exemplo", df)
dbGetQuery(con, "SELECT sexo, AVG(renda) as media_renda FROM tabela_exemplo GROUP BY sexo")

# Integração com dplyr
tbl(con, "tabela_exemplo") %>%
  filter(renda > 2500) %>%
  group_by(sexo) %>%
  summarise(media = mean(renda, na.rm = TRUE)) %>%
  collect()

# Encerrando conexão
dbDisconnect(con, shutdown = TRUE)

# ============================================================================
# Tutorial 14 — Relatórios Reproduzíveis (RMarkdown)
# --------------------------------------------------
# Estrutura: YAML + texto + chunks R
# Renderização com rmarkdown::render()
# Automação: Task Scheduler (Windows) ou cron (Linux/Mac)
# Erros comuns: chunks com nomes repetidos; caminhos absolutos; dependências faltando
# ============================================================================

library(rmarkdown)

# Renderizar relatório manualmente
# (necessário ter um arquivo "relatorio.Rmd" válido no diretório de trabalho)
# rmarkdown::render("relatorio.Rmd", output_file = "saida.html")

# Gerar relatórios com nomes dinâmicos
nome_saida <- paste0("relatorio_", format(Sys.Date(), "%Y%m%d"), ".html")
# rmarkdown::render("relatorio.Rmd", output_file = nome_saida)

# Exemplo de script para agendamento (executar via .bat ou cron):
# Rscript -e "rmarkdown::render('relatorio.Rmd', output_file='saida.html')"



# ============================================================================
# RESOLUÇÃO DO DESAFIO — Integração e análise de bases relacionais
# ============================================================================

# Bases de exemplo (COVID + população municipal 2020)
pop20 <- read_csv2(
  "https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/main/data/populacao_municipal.csv",
  show_col_types = FALSE
) %>%
  clean_names() %>%
  filter(ano == 2020) %>%
  select(cod_ibge, nome_munic, populacao)

covid_maio <- read_csv2(
  "https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/master/data/covid_sp_20200501.csv",
  show_col_types = FALSE
) %>%
  clean_names() %>%
  select(codigo_ibge, nome_munic, casos)

# INNER JOIN -> só municípios presentes nas duas bases
dados_inner <- inner_join(
  covid_maio, pop20, by = c("codigo_ibge" = "cod_ibge")
) %>%
  mutate(casos_pc_100k = casos * 100000 / populacao)

# LEFT JOIN -> mantém todos os municípios da COVID
dados_left <- left_join(
  covid_maio, pop20, by = c("codigo_ibge" = "cod_ibge")
) %>%
  mutate(casos_pc_100k = casos * 100000 / populacao)

# RIGHT JOIN -> mantém todos os municípios da população
dados_right <- right_join(
  covid_maio, pop20, by = c("codigo_ibge" = "cod_ibge")
) %>%
  mutate(casos_pc_100k = casos * 100000 / populacao)

# Comparação simples
comparacao <- tibble(
  tipo = c("inner","left","right"),
  n_linhas = c(nrow(dados_inner), nrow(dados_left), nrow(dados_right)),
  n_NA = c(sum(is.na(dados_inner$casos_pc_100k)),
           sum(is.na(dados_left$casos_pc_100k)),
           sum(is.na(dados_right$casos_pc_100k)))
)
print(comparacao)

# Gráfico simples — diferenças entre joins
comparacao %>%
  ggplot(aes(x = tipo, y = n_linhas)) +
  geom_col(fill="steelblue") +
  geom_text(aes(label = n_linhas), vjust = -0.2) +
  labs(title="Número de linhas por tipo de join", x=NULL, y="Linhas") +
  theme_minimal()

# Justificativa:
#   - inner_join garante consistência (apenas pares completos)
#   - left_join mantém todos os municípios com casos, mesmo sem população
#   - right_join garante cobertura demográfica completa
# Para análise de taxas, inner_join costuma ser a escolha mais adequada.
