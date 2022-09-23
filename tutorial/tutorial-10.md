# Bases relacionais com a gramática do dplyr

Nos tutoriais anteriores trabalhamos quase que exclusivamente com um único data frame, produzindo transformações de colunas, mudando os nomes das variáveis, selecionando de linhas e colunas e agrupando para produzir tabelas e estatísticas descritivas. Neste tutorial vamos aprender a trabalhar com bases relacionais, ou seja, a combinar data frames usando as funções de sufixo 'join' do `dplyr`.

Combinar data frames é necessário quando as informações que serão utilizadas na análise estão presentes em mais de um fonte de dados. Vamos trabalhar neste tutorial com 4 fontes de dados para exemplificar os diferentes tipos de combinação ('joins'): (1) uma base óbitos por município entre 2019 e 2021, produzida pelo SEADE; (2) a base de Informações dos Municípios Paulistas (IMP), da qual retiraremos a população dos municípios em 2019; (3) os dados de população dos municípios paulistas em 2020 do SEADE; e (4) os dados de casos e óbitos por COVID-19 nos municípios paulistas (fixados em 01 de maio de 2020 por razões didáticas).

Note que as 4 fontes tem o mesmo 'identificador', ou seja, todas elas contém uma informação que permite relacioná-la com as demais. No nosso caso, o indexador é o código do município fornecido pelo IBGE.

Antes de avançar, carregue os pacotes que utilizaremos nesta atividade:

```{r}
library(tidyverse)
library(janitor)
```

## Mortalidade de homens e mulheres por município

Nosso primeiro objetivo será calcular a mortalidade (óbitos por 1000 habitantes) por município para homens e mulheres, separadamente, para o ano de 2021. Precisamos, pois, de duas informações para cada município: o total de óbitos para cada grupo de sexo por município; e a população do município.

A primeira informação, óbitos para cada grupo de sexo por município, podem ser encontradas aqui: [https://mortalidade.seade.gov.br/](https://mortalidade.seade.gov.br/). Vamos abrir os dados, disponibilizados em .csv. Note que devemos incluir `locale=locale(encoding = "Latin2")` para identificar o _encoding_ do arquivo e os acentos utilizados no cabeçalho do arquivo sejam lidos corretamente:

```{r}
obitos_2021 <- read_csv2('https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/main/data/obitos_sexo_idade_2019a2021.csv', locale=locale(encoding = "Latin2"))
```

Examinando com _glimpse_:

```{r}
obitos_2021 %>% 
  glimpse()
```

Vamos limpar os nomes das variáveis `clean_names` do pacote `janitor`:

```{r}
obitos_2021 <- obitos_2021 %>% 
  clean_names()

obitos_2021 %>% 
  glimpse()
```

Há 3 anos no arquivo e 3 categorias na variável sexo:

```{r}
obitos_2021 %>% 
  tabyl(ano)

obitos_2021 %>% 
  tabyl(sexo)
```

Vamos selecionar apenas o ano de 2021, excluir sexo "Ignorado" e agrupar os dados por Idade para trabalharmos apenas com a variável sexo:

```{r}
obitos_2021 <- obitos_2021 %>%
  filter(ano == 2021,
         sexo != "Ignorado") %>% 
  group_by(cod_ibge, sexo) %>% 
  summarise(obitos = sum(obitos))
```

Reexamine os dados:

```{r}
obitos_2021 %>% 
  glimpse()
```

Ótimo! Vamos agora abrir nossa segunda fonte de dados, o com informações sobre os municípios paulistas: [https://municipios.seade.gov.br/](https://municipios.seade.gov.br/)

```{r}
municipios_populacao <- read_csv2('https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/main/data/demo_geral.csv', locale=locale(encoding = "Latin2"))
```

Veja que utilizamos novamente o argumento `locale`. Os dados do de municípios publicados pelo SEADE vêm com o encoding 'Latin1' e como trabalhando no servidor RStudio do servidor Linux do SEADE, precisamos informar esse parâmetro para que o dado seja lido corretamente.

Examine os dados:

```{r}
municipios_populacao %>% 
  glimpse()
```

Nomes fora de padrão? `clean_names`

```{r}
municipios_populacao <- municipios_populacao %>% 
  clean_names()
```

Reexaminando:

```{r}
municipios_populacao %>% 
  glimpse()
```

Vamos selecionar apenas as variáveis que nos interessam para a análise, que são o código e nome dodo município os totais da população separada por sexo:

```{r}
municipios_populacao <- municipios_populacao %>% 
  select(cod_ibge, localidades, total_h, total_m)
```

Os dados estão em formato _wide_, ou seja, a população por sexo está separada por colunas em vez de haver uma variável denominada sexo. Vamos redesenhar este data frame com `pivot_longer`:

```{r}
municipios_populacao <- municipios_populacao %>% 
  pivot_longer(
    cols = c('total_h', 'total_m'),
    names_to = 'sexo',
    values_to = 'pop'
  )
```

Agora vamos recodificar a variável sexo para "Homens" e "Mulheres" e chegar ao mesmo padrão do data frame de óbitos em 2021:

```{r}
municipios_populacao <- municipios_populacao %>% 
  mutate(sexo = recode(sexo, 'total_h' = 'Homens', 'total_m' = 'Mulheres'))
```

Observando o resultado:

```{r}
municipios_populacao %>% 
  tabyl(sexo)
```

## Inner Join

Pronto! Temos agora dois data frames preparados com as informações de duas fontes de dados diferentes e com 2 identificadores em comum, o nome do muncípio e o sexo.

Há 6 tipos de 'joins' em R: 'inner', 'full', 'left', 'right', 'semi' e 'anti'. Começaremos com o `inner_join`

No `inner_join`, o resultado da combinação é a interseção dos dois conjuntos, ou seja, o data frame resultante contém apenas os casos presentes nas duas bases. É, pois, o 'join' mais restritivo, pois exclui qualquer caso ausente em alguma dos data frames originais.

Vamos, antes de avançar, simplicar o primeiro exemplo, eliminando a variável sexo de ambos data frames com uma operação de agrupamento e guardando o resultado em dois novos objetos com sufixo "_total".

```{r}
obitos_2021_total <- obitos_2021 %>% 
  group_by(cod_ibge) %>% 
  summarise(obitos = sum(obitos))

municipios_populacao_total <- municipios_populacao %>%
  group_by(cod_ibge, localidades) %>%
  summarise(pop = sum(pop))
```

Esses dois novos data frames têm entre si apenas um identificador em comum, que é o nome do município. Combinando-os temos:

```{r}
df_inner_total <- inner_join(
    obitos_2021_total,
    municipios_populacao_total,
    by = c('cod_ibge' = 'cod_ibge'))
```

Note que temos 645 linhas no novo data frame. Mas o data frame de óbitos continha 646 linhas. O que aconteceu?

Essa linha extras são informações sobre o Estado de São Paulo, cujo "código de município" é 1080. Ou seja, há uma linha cujos óbitos é a soma dos óbitos de todas a outras linhas. Ao exigirmos que o novo data frame tenha apenas os casos completos com o uso de um _join_ do tipo _inner_, ou seja, que resulta no conjunto de municípios existentes em ambos data frames de origem, essa linha excedente é descartada.

Observe o resultado:

```{r}
df_inner_total %>% 
  glimpse()
```

Pronto. Temos agora as 3 variáveis que precisamos para calcular a mortalidade por município por mil habitantes em um único data frame:

```{r}
df_inner_total <- df_inner_total %>% 
  mutate(mortalidade = obitos * 1000 / pop)

df_inner_total %>% 
  glimpse()
```

Vamos agora refazer esse mesmo exercício contemplando a separação por sexo com os data frames que produzimos antes de agruparmos os dados. Repetiremos o `inner_join`, mas neste caso, há duas variáveis comuns a ambos data frames e devemos indicá-las para fazer a combinação:

```{r}
df_inner <- inner_join(
    obitos_2021,
    municipios_populacao,
    by = c('cod_ibge' = 'cod_ibge', 'sexo' = 'sexo'))
```

Como as variáveis de ambos data frames que servem de chave para a combinação foram nomeadas da mesma forma, poderíamos simplificar o argumento `by` da seguinte maneira:

```{r}
df_inner <- inner_join(
    obitos_2021,
    municipios_populacao,
    by = c('cod_ibge', 'sexo'))
```

Calculando a mortalidade novamente temos:

```{r}
df_inner <- df_inner %>% 
  mutate(mortalidade = obitos * 1000 / pop)

df_inner %>% 
  glimpse()
```

## Exportando um data frame

No tutorial anterior exportamos tabelas produzidas com `tabyl` com o comando `write_csv2`. Essa função vale para qualquer objeto da classe data frame e a que vamos utilizar para exportar conjunto de dados para .csv. Veja o exemplo:

```{r}
write_csv2(df_inner, 'mortalidade_sexo_municipio.csv')
```

ou, equivalentemente,

```{r}
df_inner %>% 
  write_csv2('mortalidade_sexo_municipio.csv')
```

Há um problema bastante sério com as funções de exportação do _readr_: elas não permitem exportar em outro encoding além de UTF-8. E, se você trabalhar com dados com caracteres especiais e em Windows, você terá problemas.

A alternativa é utilizar a função equivalente do pacote base, cuja grafia leva '.' no lugar de '\_', para poder especificar o encoding do arquivo exportado no argumento 'fileEncoding':

```{r}
df_inner %>% 
  write.csv2('mortalidade_sexo_municipio.csv', fileEncoding = 'Latin1', row.names = F)
```

Por padrão, as funções de exportação do base inserem uma coluna com a numeração das linhas à esquerda, o que provoca uma desordem nos nomes das variáveis, todas deslocadas uma célula à esquerda. Para evitar esse problema, precisamos do argumento `row.names = F`.

## Caso e óbitos covid por habitante

Neste segundo exercício, vamos calcular o número de casos de COVID-19 por 100 mil habitantes para os municípios paulistas em 01 de maio de 2020. A data foi escolhida fortuitmente, pois à época a epidemia não havia chegado a todos os municípios do estado e, portanto, teremos conjuntos de dados -- a base de COVID-19 e a de população em 2020 -- sem correspondência completa entre suas observações para testarmos os diferentes tipos de joins

Vamos começar obtendo dados sobre a projeção das populações municipais em 2020, disponível em arquivo disponíbilizado pelo SEADE em seu [repositório](https://repositorio.seade.gov.br/dataset/populacao-municipal-2010-2022/resource/4a05d680-ab13-428a-abef-3c6f69a6f800):


```{r}
pop20 <- read_csv2('https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/main/data/populacao_municipal.csv')
```

Examinando os dados:

```{r}
pop20 %>% 
  glimpse()
```

Não é preciso limpar os nomes, que já estão dentro das convenções com as quais estamos nos habituando a trabalhar. Contudo, note que temos diversos anos no arquivo, de 2000 a 2021:

```{r}
pop20 %>% 
  tabyl(ano)
```

Vamos, assim selecionar apenas as linhas correspondentes à 2020:

```{r}
pop20 <- pop20 %>% 
  filter(ano == 2020)
```


Pronto!

Agora vamos abrir os dados de casos de COVID-19 nos municípios do estado de Sâo Paulo em 01 de maio de 2020, disponíveis no repositório do curso:

```{r}
covid_maio <- read_csv2('https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/master/data/covid_sp_20200501.csv')
```

Vamos manter apenas as informações dos municípios e a contagem de casos até a data:

```{r}
covid_maio <- covid_maio %>% 
  select(codigo_ibge, nome_munic, casos)
```

Excelente! Podemos agora combinar os dois conjuntos.

## Left e right join

As duas fontes de dados têm tamanhos distintos. Enquanto 'pop20' contém os 645 municípios paulistas, 'covid_maio' contém apenas 327:

```{r}
nrow(pop20)
nrow(covid_maio)
```

Começaremos fazendo um `left_join`. 'Esquerda', significa que escolheremos um data frame para mantermos à esquerda e que terá todos os seus casos preservados na combinação, ou seja, mesmo que os casos não encontrem correspondência no data frame à 'direita' estarão no resultado final da combinação. Contrariamente, os casos do data frame à 'direita' que não existam à esquerda serão descartados. 

O efeito é semelhante ao de acrescentar colunas do data frame à direita no data frame da esquerda, mantendo este última integra.

```{r}
df_left <- left_join(covid_maio, pop20, by = c('codigo_ibge' = 'cod_ibge'))
```

Outra maneira de escrever o mesmo 'join', com pipe (%>%), é:

```{r}
df_left <- covid_maio %>% 
  left_join(pop20,  by = c('codigo_ibge' = 'cod_ibge'))
```

O dta frame à esquerda é, portanto, a que está fora da função quando utilizamos o pipe. O resultado final tem, como esperávamos, o mesmo número de linhas da base à esquerda, 'covid_maio'. Existe apenas um caso deste conjunto de dados que não tem par em 'pop20': o município de número 9999999, 'Ignorado'.

O que acontece com as variáveis de 'pop20' acrescentadas à linha do município 'Ignorado'? Vamos examinar:

```{r}
df_left %>% 
  filter(codigo_ibge == 9999999)
```

Como 'Ignorado' não existe em 'pop20', as variáveis para esta linha provenientes do data frame de população recebem NA.

A operação de `right_join` é idêntica à de `left_join` se trocarmos os data frames de posição. Intuitivamente, faz mais sentido usar a combinação 'esquerda', pois em geral queremos acrescentar colunas de uma segunda fonte de dados àquela com a qual estamos trabalhando. Note que as variáveis que servem como chave dentro do argumento `by` também trocam de posição.

```{r}
df_right <- pop20 %>% 
  right_join(covid_maio, by = c('cod_ibge' = 'codigo_ibge'))
```

Com os dados combinados, podemos calcular a taxa por da população de cada município por 100 mil habitantes que teve confirmadamente COVID-19 (vamos aproveitar e excluir o município 'Ignorado'):

```{r}
df_left <- df_left %>% 
  filter(codigo_ibge != 9999999) %>% 
  mutate(casos_pc = casos * 100000 / populacao)
```

## Full join

Tanto 'inner join' quanto 'left/right join' descartam casos de pelo menos alguma das origens dos dados quando não há correspondência. Se quisermos que a combinação resulte na união completa de casos de ambas as bases utilizamos `full_join`:

```{r}
df_full <- covid_maio %>% 
  full_join(pop20, by = 
              c('codigo_ibge' = 'cod_ibge'))
```

Não importa qual é o data frame à esquerda ou à direita. O resultado para a combinação de 'covid_maio' e 'pop20' terá 646 linhas, 326 municípios paulistas que tinham casos com COVID-19 em 01 de maio de 2020, 319 que ainda não constavam no conjunto 'covid_maio' e o 'Ignorado', que não tem informações sobre a população em 2020.

## Filtering joins

Há outros 2 joins bastante úteis em R: `semi_join` e `anti_join`. São os chamados 'filtering joins'. Seu uso é diferente dos demais. Não produzem um novo data frame com a combinação das colunas das duas fontes de dados, `semi_join` resulta em um data frame com as mesmas colunas do data frame à esquerda, apenas, e com os casos do data frame à esquerda que encontram correspondência no conjunto à direita.

Vamos trocar as posições colocar agora 'pop20' à esquerda e 'covid_maio' a direita e aplicar um 'semi join'

```{r}
df_semi <- pop20 %>% 
  semi_join(covid_maio, by = c('cod_ibge' = 'codigo_ibge'))
```

O resultado é um data frame igual a 'pop20', mas sem as linhas de municípios que não têm par em 'covid_maio'. É como aplicassemos em 'pop20' um filtro que, por extenso, seria lido como: 'manter apenas os municípios também encontrados em "covid_maio"'. O resultado, como esperávamos, tem 326 linhas.

O 'anti join' é a operação complementar à de 'semi joint': são mantidas apenas as linhas do conjunto à esquerda que __não__ encontram par no data frame à direita.

```{r}
df_anti <- pop20 %>% 
  anti_join(covid_maio, by = c('cod_ibge' = 'codigo_ibge'))
```

Permanecem no resultado as linhas dos 319 municípios de 'pop20' que não estavam também em 'covid_maio'.

