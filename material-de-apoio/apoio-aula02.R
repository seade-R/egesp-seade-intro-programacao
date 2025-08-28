# ============================================================================
# Material de Apoio — Transição Aula 2 → Aula 3
# Resumo | Resposta do Desafio | Preview
# ============================================================================


# ----------------------------------------------------------------------------
# 0) Preparação e dados -------------------------------------------------------
# ----------------------------------------------------------------------------

library(datasets)                     # pacote com vários bancos de dados de exemplo
library(tidyverse)
data("Titanic")                       
titanic <- as.data.frame(Titanic)     


# ----------------------------------------------------------------------------
# 1) Revisão rápida de operadores (matemáticos, relacionais, lógicos e %in%) --
# ----------------------------------------------------------------------------
# 1.1 Operadores matemáticos (baseiam-se em vetores)


x <- c(2, 4, 6, 8, 10)
sum(x)        # soma
mean(x)       # média
sd(x)         # desvio-padrão amostral
min(x)
max(x)
sqrt(16); log(100); log10(100); exp(1)
round(pi, 2); floor(3.9); ceiling(3.1)


# 1.2 Operadores relacionais: >, <, >=, <=, ==, !=
x > 5      # TRUE/FALSE para cada elemento
x == 6
x != 2


# 1.3 Operadores lógicos: &, |, !  (E, OU, NÃO)
(x > 5) & (x <= 8)
(x < 3) | (x > 9)
!(x == 6)


# 1.4 %in% e sua negação (com !)
classes_superiores <- c("1st", "2nd")
titanic$Class %in% classes_superiores                # Em quais linhas a classe é 1st ou 2nd?
!(titanic$Class %in% classes_superiores)             # Negação: NÃO está em 1st/2nd


# ----------------------------------------------------------------------------
# 2) DESAFIO — Aula 2: Lógica condicional (%in%, if vs ifelse) + table() ------
# ----------------------------------------------------------------------------

# Diferença conceitual:
# - if { ... } else { ... } testa UMA condição (escalar). Se der um vetor, usa
#   só o primeiro elemento (errado para criar colunas).
# - ifelse(cond_vetorial, a, b) é vetorizado: decide elemento a elemento.
# Exemplo (NÃO faça): if (titanic$Sex == "Female") "mulher" else "homem"
# Correto (vetorizado): ifelse(titanic$Sex == "Female","mulher","homem")
# Regras para nossa variável 'prioridade_resgate':
#  Alta: Age == "Child" OR (Sex == "Female" & Class %in% c("1st","2nd"))
#  Média: (Female & Class %in% c("3rd","Crew")) OR (Male & Class %in% c("1st","2nd"))
#  Baixa: Male & !(Class %in% c("1st","2nd"))


# 2.1 Expandir dados (1 linha por pessoa) ------------------------------------
titanic_expandido <- titanic %>%
  uncount(Freq) %>%  # expande linhas baseado na coluna Freq
  select(Class, Sex, Age, Survived)

nrow(titanic_expandido)  # 2201 pessoas

# 2.2 Método 1: FOR com IF (didático, mas ineficiente) -----------------------


# Criar coluna vazia
titanic_expandido$prioridade_for <- ""

# Loop por cada linha
for (i in 1:nrow(titanic_expandido)) {
  # Extrair valores da linha i
  idade <- titanic_expandido$Age[i]
  sexo <- titanic_expandido$Sex[i]
  classe <- titanic_expandido$Class[i]
  
  # Aplicar regras com if/else sequenciais
  if (idade == "Child" | (sexo == "Female" & classe %in% c("1st", "2nd"))) {
    titanic_expandido$prioridade_for[i] <- "Alta"
  } else if ((sexo == "Female" & classe %in% c("3rd", "Crew")) | 
             (sexo == "Male" & classe %in% c("1st", "2nd"))) {
    titanic_expandido$prioridade_for[i] <- "Média"
  } else if (sexo == "Male" & !(classe %in% c("1st", "2nd"))) {
    titanic_expandido$prioridade_for[i] <- "Baixa"
  } else {
    titanic_expandido$prioridade_for[i] <- NA  # caso não previsto
  }
}

# 2.3 Método 2: IFELSE vetorizado (para lidar direto com vetores) -------------------

titanic_expandido <- titanic_expandido %>%
  mutate(
    # 1) Prioridade Alta
    prioridade_ifelse = ifelse(
      Age == "Child" | (Sex == "Female" & Class %in% c("1st","2nd")),
      "Alta", 
      NA_character_
    ),
    # 2) Média só onde ainda não há valor
    prioridade_ifelse = ifelse(
      is.na(prioridade_ifelse) &
        ((Sex == "Female" & Class %in% c("3rd","Crew")) |
           (Sex == "Male"   & Class %in% c("1st","2nd"))),
      "Média",
      prioridade_ifelse
    ),
    # 3) Baixa só onde ainda não há valor
    prioridade_ifelse = ifelse(
      is.na(prioridade_ifelse) &
        (Sex == "Male" & !(Class %in% c("1st","2nd"))),
      "Baixa",
      prioridade_ifelse
    )
  )

# 2.4. Ainda mais simples: usando case_when()
titanic_expandido <- titanic_expandido %>%
  mutate(
    prioridade_casewhen = case_when(
      Age == "Child" ~ "Alta",
      Sex == "Female" & Class %in% c("1st","2nd") ~ "Alta",
      Sex == "Female" & Class %in% c("3rd","Crew") ~ "Média",
      Sex == "Male"   & Class %in% c("1st","2nd") ~ "Média",
      Sex == "Male"   & !(Class %in% c("1st","2nd")) ~ "Baixa",
      .default = NA_character_
    )
  )


# 2.5 Verificação: todos os métodos devem produzir o mesmo resultado ------------

table(titanic_expandido$prioridade_for, titanic_expandido$prioridade_ifelse)

table(titanic_expandido$prioridade_for, titanic_expandido$prioridade_casewhen)


# Ou comparando tudo com summarise()
titanic_expandido_checagem <- titanic_expandido %>%
  group_by(prioridade_for, prioridade_ifelse, prioridade_casewhen) %>%
  summarise(Freq = n())



# ----------------------------------------------------------------------------
# PONTOS IMPORTANTES:
# 1. FOR com IF: mais lento, mas permite lógica complexa e é familiar
# 2. IFELSE: vetorizado, eficiente, mas pode ficar difícil de ler com muitos níveis
# 3. Use %in% para testar múltiplos valores de uma vez
# 4. Use ! para negação lógica
# 5. table() é fundamental para análise exploratória de variáveis categóricas
# ----------------------------------------------------------------------------



# ----------------------------------------------------------------------------
# 3) PREVIEW — Aula 3: Importação de dados, agrupamentos e tabelas -----------
# ----------------------------------------------------------------------------
# A Aula 3 será mais leve e focará em habilidades práticas essenciais:
# importação/exportação de dados, criação de tabelas profissionais e agrupamentos.

# 3.1 Importação de dados de diferentes formatos -----------------------------
# Na Aula 3 veremos como importar dados de várias fontes:

# CSV com diferentes delimitadores (readr)
# read_csv()    # separado por vírgula
# read_csv2()   # separado por ponto-e-vírgula (padrão BR)
# read_delim()  # delimitador customizável

# Excel (readxl)
# read_excel()  # importa planilhas .xlsx e .xls

# Outros softwares estatísticos (haven)
# read_sav()    # SPSS
# read_stata()  # Stata
# read_sas()    # SAS

# A função mágica: fread() do data.table
# fread()       # detecta automaticamente formato e parâmetros!

# Para agregações de dados:
# - count(): rápido para contagens simples
# - group_by() + summarise(): flexível para estatísticas customizadas
# - tabyl(): ideal para tabelas prontas para relatório
# - Use count() para exploração rápida
# - Use group_by() + summarise() para análises complexas
# - Use tabyl() para tabelas finais e apresentações

