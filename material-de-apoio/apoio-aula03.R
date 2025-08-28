# ============================================================================
# Material de Apoio — Transição Aula 3 → Aula 4
# Resumo | Resposta do Desafio | Preview
# ============================================================================
# ----------------------------------------------------------------------------
# 0) Preparação e dados -------------------------------------------------------
# ----------------------------------------------------------------------------

library(tidyverse)                     # dplyr, readr, ggplot2
library(readxl)                        # para arquivos Excel
library(haven)                         # para SPSS, Stata, SAS
library(data.table)                    # para fread()
library(janitor)                       # para limpeza e tabelas

# Dados para demonstração
url_piesp <- 'https://raw.githubusercontent.com/seade-R/seade-intro-programacao/main/data/piesp.csv'
piesp <- read_csv2(url_piesp)


# ----------------------------------------------------------------------------
# 1) Resumo — Aula 3: Tidyverse para manipulação de dados --------------------
# ----------------------------------------------------------------------------

# 1.1 Importação de dados (Tutorial 5) ---------------------------------------
# Na aula 3 aprendemos múltiplas formas de importar dados:

# CSV com diferentes separadores (readr)
exemplo_csv1 <- read_csv("arquivo.csv")      # separado por vírgula
exemplo_csv2 <- read_csv2("arquivo.csv")     # separado por ponto-e-vírgula (padrão BR)  
exemplo_delim <- read_delim("arquivo.txt", delim = "\t")  # customizável

# Excel (readxl)  
exemplo_excel <- read_excel("planilha.xlsx", sheet = "Sheet1")

# Outros softwares estatísticos (haven)
exemplo_spss <- read_sav("dados.sav")        # SPSS
exemplo_stata <- read_stata("dados.dta")     # Stata  
exemplo_sas <- read_sas("dados.sas7bdat")    # SAS

# A função universal: fread() (data.table)
exemplo_fread <- fread("qualquer_arquivo.csv")  # detecta formato automaticamente!

# Argumentos importantes: col_names, col_types, locale, trim_ws, skip, encoding


# 1.2 Agrupamentos e tabelas com dplyr (Tutorial 6) -------------------------
# Aprendemos que na gramática do tidyverse, tabelas são data frames agrupados:

# Contagens simples por grupo
piesp %>% 
  group_by(Ano) %>% 
  count()

# Estatísticas por grupo  
piesp %>% 
  group_by(Ano) %>% 
  summarise(
    quantidade = n(),
    valor_medio = mean(`Real (em milhoes)`, na.rm = TRUE),
    valor_total = sum(`Real (em milhoes)`, na.rm = TRUE)
  )

# Tabelas cruzadas (formato long vs wide)
piesp %>% 
  group_by(Ano, `Tipo Investimento`) %>% 
  count() %>% 
  pivot_wider(names_from = `Tipo Investimento`, values_from = n)


# 1.3 Pacote janitor para limpeza e tabelas (início do Tutorial 7) ----------
# O janitor simplifica a limpeza de dados e criação de tabelas:

# Limpeza de nomes de variáveis
piesp_limpo <- piesp %>% 
  clean_names()  # transforma nomes em snake_case, remove acentos/espaços

# Tabelas simples com frequências e percentuais
piesp_limpo %>% 
  tabyl(tipo_investimento) %>%      # contagem + percentual automaticamente
  adorn_pct_formatting() %>%        # formatação de percentuais  
  adorn_totals() %>%                # adiciona totais
  adorn_rounding(2)                 # controla casas decimais


# ----------------------------------------------------------------------------
# 2) DESAFIO — Aula 3: Importação, limpeza e análise exploratória básica ----
# ----------------------------------------------------------------------------

# 2.1 Simulando uma planilha Excel complexa ----------------------------------
# Vamos simular um arquivo Excel típico do ambiente corporativo

# Criando dados fictícios de vendas trimestrais
vendas_ficticias <- data.frame(
  "Trimestre" = rep(c("Q1-2023", "Q2-2023", "Q3-2023", "Q4-2023"), each = 12),
  "Mês" = rep(month.abb, 4),
  "Produto" = sample(c("Produto A", "Produto B", "Produto C"), 48, replace = TRUE),
  "Vendas (R$ mil)" = round(runif(48, 50, 500), 1),
  "Unidades Vendidas" = sample(100:1000, 48),
  "Região" = sample(c("Norte", "Sul", "Sudeste", "Centro-Oeste"), 48, replace = TRUE),
  check.names = FALSE
)

# 2.2 Importação e limpeza dos dados -----------------------------------------
# Simulando processo de limpeza como se viesse de Excel
vendas <- vendas_ficticias %>%
  
  # Limpeza de nomes com janitor
  clean_names() %>%
  
  # Transformações de tipos 
  mutate(
    vendas_r_mil = as.numeric(vendas_r_mil),
    unidades_vendidas = as.numeric(unidades_vendidas),
    
    # Criando variáveis derivadas
    receita_por_unidade = vendas_r_mil * 1000 / unidades_vendidas,
    performance = ifelse(vendas_r_mil > 300, "Alta", 
                 ifelse(vendas_r_mil > 200, "Média", "Baixa")),
    
    # Transformando variáveis categóricas em factors ordenados
    trimestre_f = factor(trimestre, 
                        levels = c("Q1-2023", "Q2-2023", "Q3-2023", "Q4-2023")),
    mes_f = factor(mes, levels = month.abb),
    performance_f = factor(performance, levels = c("Baixa", "Média", "Alta"))
  )


# 2.3 Tabelas de frequência simples ------------------------------------------
# Distribuição por trimestre
vendas %>%
  tabyl(trimestre_f) %>%
  adorn_pct_formatting() %>%
  rename("Trimestre" = trimestre_f)

# Distribuição por região  
vendas %>%
  tabyl(regiao) %>%
  adorn_pct_formatting() %>%
  adorn_totals() %>%
  rename("Região" = regiao, "Frequência" = n, "Percentual" = percent)


# 2.4 Tabelas cruzadas -------------------------------------------------------
# Performance por região
vendas %>%
  tabyl(regiao, performance_f) %>%
  adorn_totals(where = c("row", "col")) %>%
  adorn_title(placement = "top", row_name = "Região", col_name = "Performance")

# Performance por trimestre (com percentuais)
vendas %>%
  tabyl(trimestre_f, performance_f) %>%
  adorn_percentages(denominator = "row") %>%
  adorn_pct_formatting() %>%
  adorn_title(placement = "top", row_name = "Trimestre", col_name = "Performance")


# 2.5 Análises por grupo com dplyr -------------------------------------------
# Resumo por trimestre
vendas %>%
  group_by(trimestre_f) %>%
  summarise(
    n_vendas = n(),
    vendas_media = round(mean(vendas_r_mil), 1),
    vendas_total = round(sum(vendas_r_mil), 1),
    unidades_total = sum(unidades_vendidas),
    receita_media_por_unidade = round(mean(receita_por_unidade, na.rm = TRUE), 2)
  ) %>%
  rename("Trimestre" = trimestre_f)

# Performance por região e produto
vendas %>%
  group_by(regiao, produto, performance_f) %>%
  summarise(
    vendas_totais = sum(vendas_r_mil),
    unidades_totais = sum(unidades_vendidas),
    .groups = "drop"
  ) %>%
  arrange(desc(vendas_totais))


# 2.6 Criação de faixas com cut() --------------------------------------------
# Categorizando vendas em faixas
vendas_com_faixas <- vendas %>%
  mutate(
    faixa_vendas = cut(vendas_r_mil,
                      breaks = c(0, 150, 300, 500),
                      labels = c("Baixa (até 150k)", "Média (150-300k)", "Alta (300k+)"),
                      include.lowest = TRUE),
    
    faixa_unidades = cut(unidades_vendidas,
                        breaks = c(0, 300, 600, 1000), 
                        labels = c("Poucas", "Médio volume", "Alto volume"),
                        include.lowest = TRUE)
  )

# Tabela cruzada das faixas
vendas_com_faixas %>%
  tabyl(faixa_vendas, faixa_unidades) %>%
  adorn_totals(where = c("row", "col")) %>%
  adorn_title(placement = "top", 
              row_name = "Faixa de Vendas", 
              col_name = "Volume de Unidades")


# ----------------------------------------------------------------------------
# PONTOS IMPORTANTES DA AULA 3:
# 1. IMPORTAÇÃO: read_csv(), read_csv2(), read_excel(), read_sav(), fread()
# 2. JANITOR: clean_names() para nomes consistentes, tabyl() para tabelas
# 3. FACTORS: factor() com levels= para controlar ordem de categorias  
# 4. RECODIFICAÇÃO: recode() e recode_factor() para transformar valores
# 5. FAIXAS: cut() para discretizar variáveis contínuas
# 6. TABELAS PROFISSIONAIS: adorn_* para formatação (pct, totals, titles)
# 7. ENCODING: locale() para caracteres especiais (acentos, cedilhas)
# 8. TABELAS CRUZADAS: tabyl(var1, var2) + adorn_percentages()
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# 3) PREVIEW — Aula 4: ggplot2: Gramática de gráficos -----------------------
# ----------------------------------------------------------------------------
# A Aula 4 introduzirá uma das especialidades do R: visualização de dados com ggplot2.

# 3.1 Estrutura básica do ggplot2 --------------------------------------------
# ggplot2 segue uma "gramática de gráficos" com estrutura consistente:
# ggplot(data) + geom_*() + elementos adicionais

# Exemplo básico (preview):
vendas %>%
  ggplot() +
  geom_bar(aes(x = performance_f))

# 3.2 Geometrias principais --------------------------------------------------
# Cada tipo de dados tem geometrias apropriadas:

# Para variáveis categóricas:
# geom_bar() - gráficos de barras

# Para variáveis contínuas:  
# geom_histogram() - histogramas
# geom_density() - curvas de densidade

# Para duas variáveis contínuas:
# geom_point() - gráficos de dispersão  
# geom_smooth() - linhas de tendência

# Para contínua + categórica:
# geom_boxplot() - boxplots por grupo
# geom_violin() - gráficos de violino


# 3.3 Aesthetics (aes) -------------------------------------------------------
# Dentro de aes() mapeamos variáveis para elementos visuais:
# x, y: posição nos eixos
# fill: preenchimento  
# color: contorno/borda
# size: tamanho
# shape: forma (pontos)

# Exemplo de preview:
vendas %>%
  ggplot() +
  geom_point(aes(x = vendas_r_mil, 
                 y = unidades_vendidas,
                 color = regiao,
                 size = receita_por_unidade))


# 3.4 Elementos de customização ----------------------------------------------
# + facet_wrap(): múltiplos gráficos por categoria
# + labs(): títulos, legendas, eixos
# + theme(): aparência geral
# + scale_*(): controle de escalas e cores

# Na Aula 4, aprenderemos a construir visualizações profissionais que revelem
# padrões nos dados de forma clara e atrativa!
