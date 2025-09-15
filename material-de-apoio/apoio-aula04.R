# ============================================================================
# Material de Apoio — Transição Aula 4 → Aula 5
# Resumo | Resposta do Desafio | Preview
# ============================================================================
# ----------------------------------------------------------------------------
# 0) Preparação e dados -------------------------------------------------------
# ----------------------------------------------------------------------------

# Pacotes
library(tidyverse)
library(janitor)
library(forcats)
library(scales)


# ----------------------------------------------------------------------------
# Manipulando tempo

library(lubridate)
library(hms)

# Exemplo com hora e fuso horário definido
tempo_1 <- as.POSIXct(c("20:03:01", "12:00:00"),
                format = "%H:%M:%S", 
                tz = "Etc/GMT+3") 
# Atenção: o "Etc/GMT+3" é o inverso! 
# Como São Paulo está em UTC-3, devemos usar GMT+3 para ter o mesmo resultado.

tempo_2 <- as.POSIXct(c("20:03:01", "12:00:00"),
                format = "%H:%M:%S",
                tz = "America/Sao_Paulo") 
# Aqui usamos diretamente o identificador da cidade.


# Podemos fazer operações matemáticas diretamente:
tempo_1[1] - tempo_1[2]
#> Time difference of 8 hours

as.period(tempo_1[1] - tempo_1[2])
#> "8H 0M 1S"


# Se não precisamos de datas completas, o pacote hms é útil para representar só horas, minutos e segundos:
tempo_3 <- as_hms(c("20:03:01", "12:00:00"))

tempo_3[1] - tempo_3[2]
#> Time difference of 8 hours 3.01 secs

as.period(tempo_3[1] - tempo_3[2])
#> "8H 0M 1S"


# Com lubridate::floor_date() podemos arredondar horários, por exemplo, para análise de eventos por hora:
horas <- as.POSIXct(c("20:03:01", "20:45:10", "12:15:00"),
                    format = "%H:%M:%S",
                    tz = "America/Sao_Paulo")

floor_date(horas, unit = "hour")
#> "2025-02-01 20:00:00" "2025-02-01 20:00:00" "2025-02-01 12:00:00"


# Ou também podemos usar cut() para categorizar automaticamente em períodos de tempo que desejarmos. Por exemplo, dividindo manhã, tarde, noite:

periodos <- cut(
  as_hms(horas),
  breaks = hms::as_hms(c("00:00:00", "12:00:00", "18:00:00", "23:59:59")),
  labels = c("Manhã", "Tarde", "Noite"),
  include.lowest = TRUE, right = FALSE
)

cbind(horas, periodos)

# ---------------------------------------------------------------------

# Revisando Aula 4

# Dados 1: Óbitos 2021 (Registro Civil, SEADE)
obitos_2021 <- read_csv2(
  "https://raw.githubusercontent.com/seade-R/seade-intro-programacao/main/data/microdados_obitos2021.csv",
  show_col_types = FALSE) %>%
  clean_names() %>%
  mutate(
    idadeanos = suppressWarnings(as.numeric(idadeanos)),
    sexo_f = recode_factor(sexo, 'F'='Feminino','M'='Masculino','I'='Ignorado'),
    racacor_f = recode_factor(
      racacor, '1'='Branca','2'='Preta','3'='Amarela','4'='Parda','5'='Indígena','9'='Ignorada'
    )
  ) %>%
  filter(idadeanos != 999) # removendo variáveis com código para idade desconhecida

# Dados 2: Nascidos Vivos 2017 (Registro Civil, SEADE)
nv_2017 <- read_csv2(
  "https://raw.githubusercontent.com/seade-R/seade-intro-programacao/main/data/nv_2017.csv",
  show_col_types = FALSE
) %>%
  clean_names() %>%
  mutate(
    peso = suppressWarnings(as.numeric(peso)),
    idademae = suppressWarnings(as.numeric(idademae)),
    idadepai = suppressWarnings(as.numeric(idadepai)),
    sexo_f = recode_factor(sexo, 'F'='Feminino','M'='Masculino','I'='Ignorado')
  ) %>%
  filter(peso != 9999, idademae != 99, idadepai != 99, sexo_f != "Ignorado")

set.seed(3599999)                               # garantindo reprodutibilidade escolhendo a semente do número pseudo-aleatório
nv_2017_s <- nv_2017 %>% slice_sample(n = 200, replace = T)  # amostra com reposição de 200 casos

# ============================================================================
# PARTE I: GRAMÁTICA DO GGPLOT2 — Fundamentos e estrutura
# ============================================================================

# ----------------------------------------------------------------------------
# 1.1) A Gramática de Gráficos
# ----------------------------------------------------------------------------

# ESTRUTURA FUNDAMENTAL DO GGPLOT2:
# dados + aes() + geometrias (+ estatísticas) + escalas + facetas + tema

# COMPONENTES ESSENCIAIS:
# - DADOS: data.frame ou tibble
# - MAPEAMENTOS ESTÉTICOS (aes): x, y, color, fill, size, shape, alpha...
# - GEOMETRIAS (geom_*): pontos, linhas, barras, histograma, boxplot...
# - ESCALAS (scale_*): como mapear dados para propriedades visuais
# - FACETAS (facet_*): subgráficos por categorias
# - TEMA (theme_*): aparência geral (fontes, cores de fundo, etc.)

# ----------------------------------------------------------------------------
# 1.2) Regras Fundamentais
# ----------------------------------------------------------------------------

# DENTRO vs FORA de aes():
# - DENTRO de aes(): mapeamentos que dependem dos DADOS
#   Exemplos: aes(x = idade, y = peso, color = sexo, size = renda)
#
# - FORA de aes(): valores CONSTANTES para todos os pontos
#   Exemplos: geom_point(color = "red", size = 3, alpha = 0.7)

# HERANÇA de mapeamentos:
# - O que você define em ggplot(aes(...)) é "herdado" por todas as camadas
# - Você pode sobrescrever nos geom_* individuais quando necessário

# GEOMETRIAS principais:
# - geom_bar(): conta automaticamente (stat = "count")
# - geom_col(): usa valores pré-calculados (stat = "identity")
# - geom_point(): gráficos de dispersão
# - geom_line(): séries temporais, linhas conectando pontos
# - geom_histogram(): distribuições de variáveis contínuas
# - geom_boxplot(): comparar distribuições entre grupos

# ----------------------------------------------------------------------------
# 1.3) Exemplo básico demonstrativo
# ----------------------------------------------------------------------------

# Estrutura mínima funcional:
exemplo_basico <- obitos_2021 %>%
  filter(sexo_f != "Ignorado") %>%
  mutate(racacor_f = fct_reorder(racacor_f, idadeanos, median, na.rm = TRUE)) %>%
  ggplot(aes(x = racacor_f, y = idadeanos, fill = racacor_f)) +  # dados + mapeamentos
  geom_boxplot() +                                               # geometria
  labs(x = NULL, y = "Idade (anos)") +                          # rótulos
  theme_minimal() +                                              # tema base
  theme(legend.position = "none")                                # personalização

exemplo_basico

# ============================================================================
# PARTE II: EXEMPLOS PROGRESSIVOS — Do simples ao complexo
# ============================================================================

# ----------------------------------------------------------------------------
# 2.1) NÍVEL BÁSICO: Gráfico de barras simples
# ----------------------------------------------------------------------------

# Contar e visualizar categorias
g_simples <- obitos_2021 %>%
  count(racacor_f) %>%
  ggplot(aes(x = racacor_f, y = n)) +
  geom_col(fill = "steelblue") +
  labs(title = "Óbitos por raça/cor", x = NULL, y = "Contagem") +
  theme_minimal()

g_simples

# ----------------------------------------------------------------------------
# 2.2) NÍVEL BÁSICO+: Melhorando a apresentação
# ----------------------------------------------------------------------------

# Adicionando reordenação e formatação
g_melhorado <- obitos_2021 %>%
  count(racacor_f, name = "n") %>%
  mutate(racacor_f = fct_reorder(racacor_f, n)) %>%  # reordena por frequência
  ggplot(aes(x = racacor_f, y = n)) +
  geom_col(fill = "#4E79A7") +
  scale_y_continuous(labels = label_number(big.mark=".", decimal.mark=",")) +  # formatação
  labs(title = "Óbitos por raça/cor", subtitle = "(Registro Civil 2021)", x = NULL, y = "Total") +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank())

g_melhorado

# ----------------------------------------------------------------------------
# 2.3) NÍVEL INTERMEDIÁRIO: Adicionando rótulos
# ----------------------------------------------------------------------------

# Barras com rótulos de valores
ag_raca <- obitos_2021 %>%
  count(racacor_f, name = "n") %>%
  mutate(racacor_f = fct_reorder(racacor_f, n))

g_com_rotulos <- ag_raca %>%
  ggplot(aes(racacor_f, n)) +
  geom_col(fill = "#4E79A7") +
  geom_text(  # NOVA CAMADA: texto
    aes(label = label_number(big.mark = ".", decimal.mark = ",")(n)),
    vjust = 0.5, color = "white", fontface = "bold",
    position = position_stack(vjust = 0.5)
  ) +
  labs(title = "Óbitos por raça/cor com valores", x = NULL, y = "Total") +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank())

g_com_rotulos


# ... temos barras muito pequenas para caber o texto em certos casos.
# vamos mudar para mostrar no topo: 

g_com_rotulos_topo <- ag_raca %>%
  ggplot(aes(racacor_f, n)) +
  geom_col(fill = "#4E79A7") +
  geom_text(  # NOVA CAMADA: texto no topo
    aes(label = label_number(big.mark = ".", decimal.mark = ",")(n)),
    vjust = -0.2, color = "black", fontface = "bold"
  ) +
  # escala decimal:
  scale_y_continuous(labels = scales::label_number(big.mark = ".", decimal.mark = ",")) + 
  labs(title = "Óbitos por raça/cor com valores", x = NULL, y = "Total") +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank())

g_com_rotulos_topo


# ----------------------------------------------------------------------------
# 2.4) NÍVEL INTERMEDIÁRIO: Múltiplas variáveis (facetas)
# ----------------------------------------------------------------------------

# Boxplot com facetas por sexo
g_facetas <- obitos_2021 %>%
  filter(sexo_f != "Ignorado", racacor_f != "Ignorada") %>%
  mutate(racacor_f = fct_reorder(racacor_f, idadeanos, median, na.rm = TRUE)) %>%
  ggplot(aes(racacor_f, idadeanos, fill = racacor_f)) +
  geom_boxplot(alpha = 0.8) +
  facet_wrap(~ sexo_f) +  # NOVA FUNCIONALIDADE: facetas
  labs(title = "Distribuição de idades por raça/cor e sexo", x = NULL, y = "Idade (anos)") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

g_facetas

# ----------------------------------------------------------------------------
# 2.5) NÍVEL INTERMEDIÁRIO: Combinando geometrias
# ----------------------------------------------------------------------------

# Dispersão com linha de tendência
g_dispersao <- nv_2017_s %>%
  ggplot(aes(idademae, peso, color = sexo_f)) +
  geom_point(alpha = 0.6, size = 2) +     # pontos
  geom_smooth(method = "lm", se = TRUE) +  # linha de tendência
  labs(
    title = "Idade da mãe vs. peso ao nascer",
    x = "Idade da mãe (anos)", y = "Peso (g)", color = "Sexo"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

g_dispersao

# ----------------------------------------------------------------------------
# 2.6) NÍVEL AVANÇADO: Múltiplas geometrias + estatísticas
# ----------------------------------------------------------------------------

# Histograma + densidade + medianas
medianas <- obitos_2021 %>%
  filter(sexo_f != "Ignorado", between(idadeanos, 0, 110)) %>%
  group_by(sexo_f) %>%
  summarise(med = median(idadeanos, na.rm = TRUE), .groups = "drop")

g_multiplas <- obitos_2021 %>%
  filter(sexo_f != "Ignorado", between(idadeanos, 0, 110)) %>%
  ggplot(aes(idadeanos)) +
  # Camada 1: histograma (convertido para densidade)
  geom_histogram(
    aes(y = after_stat(density), fill = sexo_f),
    binwidth = 5, boundary = 0, position = "identity", alpha = 0.25, color = "grey90"
  ) +
  # Camada 2: curva de densidade
  geom_density(aes(color = sexo_f), linewidth = 1) +
  # Camada 3: linhas de mediana
  geom_vline(data = medianas, aes(xintercept = med, color = sexo_f), linetype = "dashed") +
  # Camada 4: rótulos das medianas
  geom_text(
    data = medianas,
    aes(x = med, y = 0.012, label = paste0("Mediana: ", med), color = sexo_f),
    angle = 90, vjust = -0.5, size = 3.2, show.legend = FALSE
  ) +
  # Escalas personalizadas
  scale_fill_manual(values = c("Feminino"="#E15759","Masculino"="#4E79A7")) +
  scale_color_manual(values = c("Feminino"="#E15759","Masculino"="#4E79A7")) +
  labs(
    title = "Distribuição de idades de óbito por sexo",
    subtitle = "Histograma, densidade e medianas combinados",
    x = "Idade (anos)", y = "Densidade", fill = "Sexo", color = "Sexo"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

g_multiplas

# ----------------------------------------------------------------------------
# 2.7) NÍVEL AVANÇADO: Facetas bidimensionais
# ----------------------------------------------------------------------------

# facet_grid com duas variáveis (linhas × colunas)
serie <- obitos_2021 %>%
  filter(sexo_f != "Ignorado", racacor_f != "Ignorada", between(idadeanos, 0, 100)) %>%
  mutate(racacor_top = fct_lump_n(racacor_f, n = 3)) %>%  # manter só as 3 principais
  count(idadeanos, sexo_f, racacor_top, name = "n")

g_facet_grid <- serie %>%
  ggplot(aes(idadeanos, n, color = racacor_top, group = racacor_top)) +
  geom_line() +
  geom_point(size = 0.9) +
  facet_grid(sexo_f ~ racacor_top) +  # linhas = sexo, colunas = raça
  labs(
    title = "Contagem por idade — facetas bidimensionais",
    subtitle = "Linhas = sexo, colunas = raça/cor",
    x = "Idade (anos)", y = "Contagem"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

g_facet_grid

# ----------------------------------------------------------------------------
# 2.8) NÍVEL AVANÇADO: Barras empilhadas proporcionais
# ----------------------------------------------------------------------------

# Composição percentual com position="fill"
comp_raca_sexo <- obitos_2021 %>%
  filter(racacor_f != "Ignorada", sexo_f != "Ignorado") %>%
  count(racacor_f, sexo_f, name = "n") %>%
  group_by(racacor_f) %>%
  mutate(p = n / sum(n)) %>%
  ungroup() %>%
  mutate(racacor_f = fct_reorder(racacor_f, n, sum))

g_proporcional <- comp_raca_sexo %>%
  ggplot(aes(racacor_f, p, fill = sexo_f)) +
  geom_col(position = "fill", color = "white") +  # position="fill" = 100% empilhado
  geom_text(
    aes(label = percent(p, accuracy = 0.1)),
    position = position_fill(vjust = 0.5), color = "white", size = 3.2
  ) +
  scale_y_continuous(labels = label_percent()) +
  scale_fill_manual(values = c("Feminino"="#E15759","Masculino"="#4E79A7")) +
  labs(
    title = "Composição percentual por sexo dentro de cada raça/cor",
    x = NULL, y = "Proporção", fill = "Sexo"
  ) +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank())

g_proporcional

# ============================================================================
# PARTE III: RESOLUÇÃO DO DESAFIO — Soluções-modelo detalhadas
# ============================================================================

# ----------------------------------------------------------------------------
# 3.1) Desafio 1: Gráfico de barras (geom_col) com agregação prévia
# ----------------------------------------------------------------------------
# OBJETIVO: contar óbitos por raça/cor e ordenar categorias pela contagem
# DECISÕES TÉCNICAS:
# - Usar count() para agregação prévia
# - geom_col() para valores já calculados (vs geom_bar() que conta automaticamente)
# - fct_reorder() para ordenar categorias por frequência
# - Formatação de números grandes com scales::label_number()

solucao_1 <- obitos_2021 %>%
  count(racacor_f, name = "n") %>%                    # agregação prévia
  mutate(racacor_f = fct_reorder(racacor_f, n)) %>%   # reordenação
  ggplot(aes(x = racacor_f, y = n)) +
  geom_col(fill = "#4E79A7") +                        # geom_col para valores pré-calculados
  scale_y_continuous(labels = label_number(big.mark=".", decimal.mark=",")) +
  labs(
    title = "Óbitos por raça/cor (Registro Civil 2021)",
    x = NULL,
    y = "Total de óbitos"
  ) +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank())

solucao_1

# ----------------------------------------------------------------------------
# 3.2) Desafio 2: Histograma (geom_histogram) — distribuição contínua
# ----------------------------------------------------------------------------
# OBJETIVO: visualizar distribuição de idades com bins adequados
# DECISÕES TÉCNICAS:
# - Filtrar idades plausíveis (0-110) para clareza visual
# - binwidth=5 para classes de 5 anos
# - boundary=0 para bins alinhados (0-5, 5-10, 10-15, ...)
# - Cores fixas (fora de aes) para todos os bins

solucao_2 <- obitos_2021 %>%
  filter(between(idadeanos, 0, 110)) %>%              # filtro para clareza
  ggplot(aes(x = idadeanos)) +
  geom_histogram(
    binwidth = 5,                                     # largura das classes
    boundary = 0,                                     # alinhamento dos bins
    color = "white",                                  # cor da borda
    fill = "#59A14F"                                  # cor do preenchimento (constante)
  ) +
  labs(
    title = "Distribuição de idades (óbitos, 2021)",
    x = "Idade (anos)",
    y = "Frequência"
  ) +
  theme_light(base_size = 12)

solucao_2

# ----------------------------------------------------------------------------
# 3.3) Desafio 3: Dispersão + tendência (geom_point + geom_smooth)
# ----------------------------------------------------------------------------
# OBJETIVO: relacionar idade da mãe com peso do bebê, diferenciando por sexo
# DECISÕES TÉCNICAS:
# - Usar amostra (n=200) para não sobrecarregar visualmente
# - color=sexo_f dentro de aes() para colorir por grupos
# - geom_smooth(method="lm") para tendência linear
# - se=TRUE para mostrar intervalo de confiança
# - alpha para transparência dos pontos

nv_amostra <- nv_2017 %>% slice_sample(n = 200)

solucao_3 <- nv_amostra %>%
  ggplot(aes(x = idademae, y = peso, color = sexo_f)) +  # color dentro de aes()
  geom_point(alpha = 0.7, size = 2) +                   # transparência nos pontos
  geom_smooth(method = "lm", se = TRUE) +                # linha de tendência linear
  scale_y_continuous(labels = label_number(big.mark=".", decimal.mark=",")) +
  labs(
    title = "Idade da mãe vs. peso ao nascer (amostra)",
    x = "Idade da mãe (anos)",
    y = "Peso (g)",
    color = "Sexo"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

solucao_3

# ----------------------------------------------------------------------------
# 3.4) Desafio 4: Múltiplas camadas — histograma + densidade + medianas
# ----------------------------------------------------------------------------
# OBJETIVO: combinar diferentes geometrias com escalas compatíveis
# DECISÕES TÉCNICAS:
# - y = after_stat(density) no histograma para compatibilizar com geom_density
# - position="identity" + alpha para sobreposição transparente
# - data= específico nas camadas que precisam de dados diferentes
# - Paleta manual consistente para fill e color
# - Supressão de legenda para geom_text (show.legend = FALSE)

medianas_desafio <- obitos_2021 %>%
  filter(sexo_f != "Ignorado") %>%
  group_by(sexo_f) %>%
  summarise(med = median(idadeanos, na.rm = TRUE), .groups = "drop")

solucao_4 <- obitos_2021 %>%
  filter(sexo_f != "Ignorado", between(idadeanos, 0, 110)) %>%
  ggplot(aes(x = idadeanos)) +
  # Camada 1: histograma em escala de densidade
  geom_histogram(
    aes(y = after_stat(density), fill = sexo_f),      # after_stat() para conversão
    binwidth = 5, boundary = 0, position = "identity", 
    alpha = 0.25, color = "grey90"
  ) +
  # Camada 2: curva de densidade suavizada
  geom_density(aes(color = sexo_f), linewidth = 1.0, adjust = 1) +
  # Camada 3: linhas verticais nas medianas
  geom_vline(
    data = medianas_desafio,                           # dados específicos
    aes(xintercept = med, color = sexo_f),
    linetype = "dashed", linewidth = 0.9
  ) +
  # Escalas manuais para consistência visual
  scale_fill_manual(values = c("Feminino"="#E15759","Masculino"="#4E79A7")) +
  scale_color_manual(values = c("Feminino"="#E15759","Masculino"="#4E79A7")) +
  labs(
    title = "Distribuição de idades por sexo (óbitos, 2021)",
    subtitle = "Histograma (densidade) + curvas de densidade + medianas por sexo",
    x = "Idade (anos)",
    y = "Densidade",
    fill = "Sexo",
    color = "Sexo"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

solucao_4

# ============================================================================
# PREVIEW — Aula 05
# ============================================================================

# ----------------------------------------------------------------------------
# 4.1) Joins (Junção de Tabelas)
# ----------------------------------------------------------------------------

# CONCEITO: Joins combinam dados de diferentes tabelas baseado em colunas-chave comuns
# É essencial para análises que precisam integrar múltiplas fontes de dados

# TIPOS PRINCIPAIS DE JOIN:
# - inner_join(): mantém apenas registros que existem em AMBAS as tabelas
# - left_join(): mantém TODOS os registros da tabela da esquerda
# - right_join(): mantém TODOS os registros da tabela da direita  
# - full_join(): mantém TODOS os registros de AMBAS as tabelas
# Veja a representação visual aqui:
# https://raw.githubusercontent.com/seade-R/seade-intro-programacao/refs/heads/main/tutorial/join.png


# SINTAXE GERAL:
# tabela1 %>% 
#   inner_join(tabela2, by = "coluna_chave")
# 
# # Ou quando as colunas têm nomes diferentes:
# tabela1 %>%
#   left_join(tabela2, by = c("id_tabela1" = "id_tabela2"))

# Importante:
# Considere sempre que tipos de join são mais apropriados para cada situação


# ----------------------------------------------------------------------------
# 4.2) Tutoriais opcionais — Escolha conforme seu interesse
# ----------------------------------------------------------------------------

# A partir de agora, você pode escolher um ou dois tutoriais opcionais para aprofundar:

# TUTORIAL 09 - R Base: 
# - Foco: Sintaxe base do R (sem tidyverse)
# - Para quem: quer entender os fundamentos "puros" do R
# - Útil para: trabalhar com códigos legados, compreender a base da linguagem
# - Conteúdo: 
#   Acesso a colunas com $ e indexação por [linhas, colunas]
#   Seleção por posição e por nome; vetores lógicos com operadores relacionais (&, |, !)
#   Criação, modificação e exclusão de variáveis (atribuição, NULL, NA)
#   Recodificações: replace(), cut(); comparação com recode() (dplyr) quando pertinente
#   Ordenação e duplicatas: order(), duplicated()
#   Renomear colunas via names()
#   Tabelas e gráficos simples em base R: table(), plot(), density()

# TUTORIAL 12 - Integração com Power BI:
# - Foco: Uso de R dentro do Power BI para importar, transformar e visualizar dados
# - Para quem: trabalha com BI e quer aproveitar análises em R no Power BI
# - Útil para: dashboards dinâmicos e análises personalizadas
# - Conteúdo:
#   Importar dados modelados com R para o Power BI
#   Transformar dados já carregados usando scripts em R
#   Criar gráficos simples com R no Power BI

# TUTORIAL 13 - Integração com SQL:
# - Foco: Conectar R a bancos SQL (DBI/dbplyr) e operar dados locais/remotos
# - Para quem: usa SGBDs e/ou dados grandes
# - Útil para: ETL, consultas reprodutíveis e análises “fora da memória”
# - Conteúdo:
#   Conexões: SQLite, MySQL/MariaDB, PostgreSQL, SQL Server, Oracle, DuckDB
#   dplyr com bancos (dbplyr): tbl(), collect(), show_query()
#   SQL direto com DBI: dbGetQuery(), dbWriteTable(), dbListTables()
#   Segurança: variáveis de ambiente, SSL, fechar conexões
#   DuckDB/duckplyr: ler CSV/Parquet (incl. httpfs), trabalhar > RAM,

# TUTORIAL 14 - Relatórios com RMarkdown:
# - Foco: Relatórios dinâmicos e reprodutíveis (texto + código + visualizações)
# - Para quem: precisa automatizar relatórios periódicos
# - Útil para: atualizar dados com 1 comando e agendar execuções
# - Conteúdo:
#   Estrutura Rmd (YAML, Markdown, chunks), R inline e opts_chunk
#   Tabelas/figuras e gráficos atualizáveis (knitr, ggplot2, kable)
#   Renderização: rmarkdown::render() e nomes de saída dinâmicos
#   Automação: Task Scheduler (Windows) e cron (Linux/Mac)
#   Envio por e-mail: blastula com credenciais seguras (SMTP)
#   Boas práticas: caminhos relativos, logs, versionamento (Git)
#   Formatos: HTML, PDF (LaTeX), Word e apresentações

# TUTORIAL 15 - Análise de Dados do Início ao Fim:
# - Foco: pipeline completo (ingestão → limpeza → EDA → modelagem → comunicação)
# - Para quem: quer ver o fluxo integrado com dados reais
# - Útil para: diagnosticar problemas comuns e evitar erros de agregação
# - Conteúdo:
#   Importação via URL e encodings (Latin-1 vs UTF-8)
#   Conversão de números (vírgula→ponto) e clean_names()
#   Join com dicionários; checagens de qualidade (intervalos, NAs, somas=100)
#   Transformações (pivot_longer/wider), correlações e regressão linear simples
#   Comunicação: tabelas/plots interpretáveis e registro das decisões de limpeza

# RECOMENDAÇÃO: 
# Escolha o tutorial que mais se alinha com seus objetivos profissionais:
# - Programação base → Tutorial 8
# - Business Intelligence → Tutorial 12  
# - Banco de dados → Tutorial 13
# - Relatórios automatizados → Tutorial 14
# - Metodologia completa → Tutorial 15

# Todos são opcionais e foram pensados para aprofundar aspectos específicos
# conforme a área de interesse e necessidade de cada aluno.

# ============================================================================
