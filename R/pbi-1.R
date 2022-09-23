rm(list=ls())
library(tidyverse)
library(janitor)

obitos_2021 <- read_csv2('https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/main/data/obitos_sexo_idade_2019a2021.csv', locale=locale(encoding = "Latin2"))  %>% 
  clean_names()%>% 
  filter(ano == 2021,
         sexo != "Ignorado") %>% 
  group_by(cod_ibge, sexo) %>% 
  summarise(obitos = sum(obitos))

municipios_populacao <- read_csv2('https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/main/data/demo_geral.csv', locale=locale(encoding = "Latin2")) %>% 
  clean_names() %>% 
  select(cod_ibge, localidades, total_h, total_m) %>% 
  pivot_longer(
    cols = c('total_h', 'total_m'),
    names_to = 'sexo',
    values_to = 'pop'
  ) %>% 
  mutate(sexo = recode(sexo, 'total_h' = 'Homens', 'total_m' = 'Mulheres'))

df_inner <- inner_join(
    obitos_2021,
    municipios_populacao,
    by = c('cod_ibge' = 'cod_ibge', 'sexo' = 'sexo'))
