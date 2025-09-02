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
# 1.4) DICAS PRÁTICAS                           ------------------------------
# ----------------------------------------------------------------------------

# 1.4.1 Gerenciamento do ambiente de trabalho --------------------------------
# Salvar todos os objetos criados na sessão atual:
save(list = ls(), file = "minha_sessao.RData")

# Carregar objetos salvos de volta:
load("minha_sessao.RData")

# Limpar todos os objetos do ambiente (útil para "começar limpo"):
rm(list = ls())
# ATENÇÃO: Não coloque rm(list = ls()) no início dos seus scripts!
# É má etiqueta, pois interfere no ambiente de quem vai rodar seu código.
# Use apenas quando necessário para limpeza durante desenvolvimento.

# Ver objetos no ambiente atual:
ls()


# 1.4.2 Reordenando variáveis com select() ----------------------------------
# select() não serve só para escolher colunas, mas também para reordená-las:

# Colocar variáveis específicas primeiro, depois o resto
piesp %>%
  select(Ano, Municipio, `Real (em milhoes)`, everything()) %>%
  head(3)

# Mover uma variável para o final
piesp %>%
  select(-Municipio, Municipio) %>%  # remove e adiciona no final
  head(3)

# Reordenar usando números de posição
piesp %>%
  select(1, 3, 2, 4:ncol(.)) %>%    # coluna 1, depois 3, depois 2, depois resto
  head(3)


# 1.4.3 Outras funções úteis do select() ------------------------------------
# Seleção por padrão de nome
piesp %>%
  select(starts_with("Real")) %>%   # colunas que começam com "Real"
  head(3)

piesp %>%
  select(ends_with("milhoes")) %>%  # colunas que terminam com "milhoes"
  head(3)

piesp %>%
  select(contains("Empresa")) %>%  # colunas que contêm "Empresa"
  head(3)

# Seleção por tipo de dados
piesp %>%
  select(where(is.numeric)) %>%    # apenas colunas numéricas
  head(3)

piesp %>%
  select(where(is.character)) %>%  # apenas colunas de texto
  head(3)

piesp %>%
select(-c(Ano, Trimestre, CNAE)) %>% # ao invés de usar "-" cada vez que quiser remover uma variável, podemos escrevê-las dentro de um vetor
head(3)

# 1.4.4 Dicas para filter() --------------------------------------------------
# Múltiplas condições de forma mais clara
piesp %>%
  filter(
    Ano >= 2018,                   # ano recente
    !is.na(`Real (em milhoes)`),   # valor não faltante
    `Real (em milhoes)` > 100      # valor alto
  ) %>%
  head(3)

# Filtrar por lista de valores (alternativa ao |)
municipios_interesse <- c("Sao Paulo", "Campinas", "Santos")
piesp %>%
  filter(Municipio %in% municipios_interesse) %>%
  head(3)

# Filtrar strings com detecção de padrões
piesp %>%
  filter(str_detect(Municipio, "Sao|Santo")) %>%  # contém "Sao" OU "Santo"
  head(3)


# 1.4.5 Truques úteis com mutate() --------------------------------------------
# Múltiplas transformações da mesma variável em sequência
piesp %>%
  mutate(
    Municipio = str_to_title(Municipio),        # primeira letra maiúscula
    Municipio = str_replace(Municipio, "De", "de"),  # corrige "De" para "de"
    Municipio = str_replace(Municipio, "Do", "do")   # corrige "Do" para "do"
  ) %>%
  head(3)

# Criar variáveis condicionais com case_when() (mais claro que ifelse aninhado)
piesp %>%
  mutate(
    porte_investimento = case_when(
      `Real (em milhoes)` >= 500 ~ "Grande",
      `Real (em milhoes)` >= 100 ~ "Médio", 
      `Real (em milhoes)` >= 10  ~ "Pequeno",
      .default = "Micro"  # equivale ao "else"
    )
  ) %>%
  head(3)


# 1.4.6 Combinando verbos de forma eficiente ---------------------------------
# Pipeline típico de limpeza e análise
resultado_completo <- piesp %>%
  # Limpeza inicial
  clean_names() %>%
  filter(!is.na(real_em_milhoes)) %>%
  
  # Transformações
  mutate(
    valor_categoria = case_when(
      real_em_milhoes >= 200 ~ "Alto",
      real_em_milhoes >= 50  ~ "Médio",
      .default = "Baixo"
    ),
    municipio = str_to_title(municipio)
  ) %>%
  
  # Análise
  group_by(ano, valor_categoria) %>%
  summarise(
    investimentos = n(),
    valor_total = sum(real_em_milhoes, na.rm = TRUE),
    valor_medio = round(mean(real_em_milhoes, na.rm = TRUE), 1),
    .groups = "drop"  # remove agrupamento após summarise
  ) %>%
  
  # Organização final
  arrange(ano, desc(valor_total))


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
# 3) PREVIEW — Aula 4: ggplot2: filosofia e gramática em poucas linhas -------
# ----------------------------------------------------------------------------
# Ideia central: um gráfico no ggplot2 é declarado por uma gramática:
# dados + mapeamentos estéticos (aes) + geometrias (geom_*) + estatísticas (stat)
# + escalas (scale_*) + facetas (facet_*) + tema (theme_*).
# O gráfico "cresce" por camadas usando o operador "+".

# 3.1 Estrutura mínima -------------------------------------------------------
# ggplot(dados) + geom_*(aes(...))
vendas %>%
  ggplot() +
  geom_bar(aes(x = performance_f))   # conta categorias de 'performance_f'

# 3.2 Aesthetics (aes): mapeamento vs. valor fixo ----------------------------
# Dentro de aes() mapeamos variáveis para elementos visuais:
# x, y → posição | fill → preenchimento | color → contorno | size → tamanho | shape → forma.
# Valores fixos ficam FORA de aes().
vendas %>%
  ggplot(aes(x = performance_f)) +
  geom_bar(fill = "steelblue")       # cor fixa fora de aes()

vendas %>%
  ggplot() +
  geom_point(aes(x = vendas_r_mil,
                 y = unidades_vendidas,
                 color = regiao))    # color mapeado cria legenda

# 3.3 Geometrias principais --------------------------------------------------
# Categóricas:      geom_bar()
# Contínuas:        geom_histogram(), geom_density()
# Duas contínuas:   geom_point(), geom_smooth()
# Contínua + cat.:  geom_boxplot(), geom_violin()
vendas %>% ggplot(aes(x = performance_f)) + geom_bar()
vendas %>% ggplot(aes(x = vendas_r_mil)) + geom_histogram(binwidth = 50)
vendas %>% ggplot(aes(x = vendas_r_mil)) + geom_density()
vendas %>% ggplot(aes(vendas_r_mil, unidades_vendidas)) + geom_point()
vendas %>% ggplot(aes(vendas_r_mil, unidades_vendidas)) + geom_smooth(se = FALSE)
vendas %>% ggplot(aes(x = regiao, y = vendas_r_mil)) + geom_boxplot()
vendas %>% ggplot(aes(x = regiao, y = vendas_r_mil)) + geom_violin()

# 3.4 Geometria x Estatística ------------------------------------------------
# geom_bar() aplica contagem por padrão. Se já houver y agregado, use stat="identity"
# ou, de forma idiomática, geom_col().
vendas %>%
  count(performance_f, name = "n") %>%
  ggplot(aes(performance_f, n)) +
  geom_col()

# 3.5 Duas contínuas e tendência ---------------------------------------------
# Dispersão para relação entre variáveis numéricas; geom_smooth adiciona tendência.
vendas %>%
  ggplot(aes(x = vendas_r_mil, y = unidades_vendidas)) +
  geom_point(alpha = 0.7) +
  geom_smooth(se = FALSE)

# 3.6 Escalas e percentuais --------------------------------------------------
# Scales formatam rótulos/transformações sem mexer nos dados.
library(scales)
vendas %>%
  ggplot(aes(x = performance_f)) +
  geom_bar(aes(y = after_stat(count / sum(count)))) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(y = "Percentual")

# 3.7 Facetas para comparar subgrupos ----------------------------------------
# Pequenos múltiplos para comparação direta entre categorias.
vendas %>%
  ggplot(aes(x = vendas_r_mil)) +
  geom_histogram(binwidth = 50) +
  facet_wrap(~ regiao)

# 3.8 Aparência separada do conteúdo -----------------------------------------
# labs() rotula; theme() define aparência. Troque a "roupa" sem tocar nos dados.
vendas %>%
  ggplot(aes(x = performance_f)) +
  geom_bar(fill = "grey40") +
  labs(title = "Distribuição de performance",
       x = "Categoria", y = "Frequência") +
  theme_minimal()

# Na aula, vamos praticar essa gramática: começar simples, somar camadas e usar
# escalas, facetas e tema para comunicar melhor com o mínimo de código.
