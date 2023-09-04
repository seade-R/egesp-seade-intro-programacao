# Apresentação

Aqui você encontrará um compilado das respostas dos exercícios disponibilizados ao final de cada tutorial. 

## Tutorial 01

Para consolidar o conhecimento adquirido até aqui, vamos agora colocar em prática nossa aprendizagem por meio de alguns exercícios.

No ambiente do R, estão disponíveis diversas bases de dados nativas que podem ser facilmente acessadas por qualquer usuário. Vamos usar uma base chamada *mtcars* como referência para as próximas atividades.

A base de dados *mtcars* consiste em uma planilha disponibilizada no próprio R. Esses dados foram extraídos da revista "Motor Trend US" de 1974 e englobam informações referentes ao consumo de combustível, bem como as características físicas e de desempenho de 32 automóveis (modelos fabricados entre 1973-1974).

Carregar esses dados é simples. Basta atribuir a função abaixo a um objeto no R:

``` r
mtcars <- mtcars
```

Agora que você tem acesso aos dados, é hora de começar.

1. Quantas observações e variáveis estão presentes no _data frame_?

``` r
Resposta:

n_obs <- nrow(mtcars)
n_vars <- ncol(mtcars)
cat("Número de observações:", n_obs, "\n")
cat("Número de variáveis:", n_vars, "\n")
```

2. Quais são os nomes das variáveis disponíveis?

``` r
Resposta:

var_names <- names(mtcars)
cat("Nomes das variáveis:\n")
cat(var_names, "\n")
```

3. Exiba as 15 primeiras linhas do conjunto de dados no seu Console.

``` r
Resposta:

head(mtcars, 15)
```

4. Utilizando o operador de encadeamento `%>%`, renomeie três variáveis na base de dados.

``` r
Resposta:

mtcars <- mtcars %>%
  rename(mpg_new = mpg,
         cyl_new = cyl,
         disp_new = disp)
```

5. Explore o significado de cada variável no conjunto de dados. Lembre-se de que, apesar de ser uma base de dados, para o R o *mtcars* é tratado como uma função normal.

``` r
Resposta:

?mtcars
```

6. Selecione as variáveis relacionadas à 'potência bruta' e ao 'peso' de cada carro, e salve essas informações em um novo data frame chamado 'mtcars2'.

``` r
Resposta:

mtcars2 <- mtcars %>%
  select(hp, 
         wt)
```

7. Elimine do conjunto 'mtcars2' os carros que apresentam 'potência bruta' inferior a 105. 

``` r
Resposta:

mtcars2 <- mtcars2 %>%
  filter(hp >= 105)
```

8. Combine as etapas 6 e 7 em um único código, utilizando o operador de encadeamento `%>%`.

``` r
Resposta:

mtcars2 <- mtcars %>%
  select(hp, 
         wt) %>%
  filter(hp >= 105)
```

9. Salve seu script com o nome `tutorial01.R` no diretório do seu projeto no curso. Caso esteja em dúvida sobre como criar um diretório, volte à instrução 1 do arquivo de apresentação da [Aula 1](/class/class-01.md).

## Tutorial 02

Chegou a hora de aplicarmos o conhecimento que adquirimos. Desta vez, utilizaremos o conjunto de dados nativo do R chamado *iris*.

O conjunto de dados Iris, apresentado por Ronald Fisher em seu artigo de 1936 _The use of multiple measurements in taxonomic problems_, contém três espécies de plantas (setosa, virginica, versicolor) e quatro características medidas para cada amostra. Estes quantificam a variação morfológica da flor da íris em suas três espécies, todas medidas dadas em centímetros

Assim como fizemos com a base *mtcars*, carregar esses dados é simples. Basta atribuir a função a seguir a um objeto no R:

``` r
iris <- iris
```

Com base nas informações fornecidas, responda às questões a seguir:

1. Transforme todas as letras da variável 'Species' em maiúsculas e armazene o resultado em uma nova variável. Dica: a função `str_to_upper` é útil para realizar essa alteração.

``` r
Resposta:

iris <- iris %>%
  mutate(species_maiusculas = str_to_upper(Species))
```

2. Crie um novo data frame contendo apenas as flores da espécie `virginica`.

``` r
Resposta:

iris_virginica <- iris %>%
  filter(Species == "virginica")
```

3. Realize uma operação de agrupamento nos dados por espécie e calcule a média do comprimento da pétala para cada uma delas. Certifique-se de salvar essa análise em um banco de dados.

``` r
Resposta:

media_petal_length <- iris %>%
  group_by(Species) %>%
  summarise(media_petal_length = mean(Petal.Length))
```

4. Além da média, calcule também o desvio-padrão e a mediana do comprimento da pétala para cada grupo. Use a função `sd` para o desvio padrão e a função `median` para a mediana.

``` r
Resposta:

estatisticas_petal_length <- iris %>%
  group_by(Species) %>%
  summarise(media_petal_length = mean(Petal.Length),
            desvio_padrao_petal_length = sd(Petal.Length),
            mediana_petal_length = median(Petal.Length))
```

5. Ordene o conjunto de dados em ordem alfabética decrescente, usando a variável `Species` como critério de ordenação.

``` r
Resposta:

iris_ordenado <- iris %>%
  arrange(desc(Species))
```

## Tutorial 03


## Tutorial 04


## Tutorial 05


## Tutorial 06


## Tutorial 07

Agora nós iremos explorar os pacotes `janitor` e `dplyr`. Com foco na manipulação de dados, utilizaremos a base de dados `diamonds` para aplicar conceitos importantes e realizar tarefas de transformação e análise. 

A base de dados `diamonds` fornece informações sobre características como o peso do diamante em quilates, a qualidade do corte, a coloração, a clareza, proporções, preço em dólares e dimensões físicas em milímetros. As colunas `carat`, `cut`, `color`, `clarity`, `depth`, `table`, `price` e `x`, `y`, `z` contêm dados valiosos sobre cada diamante. Para obter detalhes específicos sobre cada variável, recomendamos o uso do comando *?diamonds*.

Para carregar a base de dados, utilize o seguinte comando:

``` r
data(diamonds)
```

Agora, prosseguiremos com os exercícios:

1. Iniciaremos pela padronização dos nomes das colunas, utilizando a função `clean_names()` do pacote `janitor`.

``` r
Resposta:

diamonds_cleaned <- diamonds %>%
  clean_names()
```

2. Selecione as colunas `carat`, `cut`, `color`, `depth` e `price` da base de dados.

``` r
Resposta:

diamonds_cleaned <- diamonds_cleaned %>%
  select(carat, 
         cut, 
         color, 
         depth, 
         price)
```

3. Utilize a função `cut()` para criar intervalos de peso dos diamantes (`carat`) e salve em uma nova variável. Os intervalos (`breaks`) você é que escolhe.

``` r
Resposta:

breaks_intervals <- c(0, 1, 2, 3, 4, Inf)

labels_intervals <- c("0 - 1", "1 - 2", "2 - 3", "3 - 4", ">4")

diamonds_cleaned <- diamonds_cleaned %>%
  mutate(carat_interval = cut(carat, 
                              breaks = breaks_intervals, 
                              labels = labels_intervals, 
                              include.lowest = TRUE))
```

4. Introduza a coluna `price_per_carat`, que deve exibir o preço por quilate de cada diamante.

``` r
Resposta:

diamonds_cleaned <- diamonds_cleaned %>%
  mutate(price_per_carat = price / carat)
```

5. Realize uma análise agrupando os diamantes por categoria de corte (variável `cut`), calculando a média do preço por quilate para cada grupo.

``` r
Resposta:

average_price_by_cut <- diamonds_cleaned %>%
  group_by(cut) %>%
  summarise(avg_price_per_carat = mean(price_per_carat))
```

6. Acrescente a coluna `price_category`, a qual categorizará os preços por quilate em "baixo" (menor que 500), "médio" (entre 500 e 1000) ou "alto" (igual ou acima de 1000). Ordene as categorias de forma crescente e transforme a variável em um fator. Dica: use a função [`case_when`](https://dplyr.tidyverse.org/reference/case_when.html) para criar a nova variável.

``` r
Resposta:

diamonds_cleaned <- diamonds_cleaned %>%
  mutate(price_category = case_when(
    price_per_carat < 500 ~ "baixo",
    price_per_carat >= 500 & price_per_carat < 1000 ~ "médio",
    price_per_carat >= 1000 ~ "alto")) %>%
  mutate(price_category = factor(price_category, 
                                 levels = c("baixo", 
                                            "médio", 
                                            "alto")))
```

7. Calcule a contagem de diamantes em cada categoria de corte (`cut`) e exiba os resultados em ordem decrescente.

``` r
Resposta:

count_by_cut <- diamonds_cleaned %>%
  group_by(cut) %>%
  summarise(diamond_count = n()) %>%
  arrange(desc(diamond_count))
```

8. Calcule a média e o desvio-padrão da profundidade (`depth`) dos diamantes para cada categoria de corte (`cut`).

``` r
Resposta:

summary_depth_by_cut <- diamonds_cleaned %>%
  group_by(cut) %>%
  summarise(avg_depth = mean(depth),
            sd_depth = sd(depth)) %>%
  adorn_rounding(digits = 2)
```

9. Produza um resumo estatístico que englobe a média, mediana, desvio-padrão, mínimo e máximo do preço por quilate (`price_per_carat`) para cada combinação de corte (`cut`) e cor (`color`).

``` r
Resposta:

summary_by_cut_and_color <- diamonds_cleaned %>%
  group_by(cut, 
           color) %>%
  summarise(avg_price_per_carat = mean(price_per_carat),
            median_price_per_carat = median(price_per_carat),
            sd_price_per_carat = sd(price_per_carat),
            min_price_per_carat = min(price_per_carat),
            max_price_per_carat = max(price_per_carat)) %>%
  adorn_rounding(digits = 2)
```

10. Calcule a média e o desvio-padrão do preço por quilate (`price_per_carat`) para diamantes de diferentes tamanhos, arredondando os valores para duas casas decimais. Use a variável que você criou no exercício 3 como referência para os tamanhos.

``` r
Resposta:

summary_by_carat <- diamonds_cleaned %>%
  group_by(carat_interval) %>%
  summarise(avg_price_per_carat = mean(price_per_carat),
            sd_price_per_carat = sd(price_per_carat)) %>%
  adorn_rounding(digits = 2)
```

Agora que você possui as ferramentas necessárias, mãos à obra!

## Tutorial 08

Nesta série de exercícios, continuaremos a explorar o pacote `ggplot2` no ambiente R, usando a base de dados `diamonds`, a mesma que utilizamos no [Tutorial 07](tutorial-07.md).

Para carregar a base de dados, utilize o seguinte comando:

``` r
data(diamonds)
```
Agora, vamos aos exercícios, utilizando a combinação de `ggplot2` e `dplyr` para criar gráficos e explorar insights nos dados dos diamantes:

1. Utilize o `filter()` do `dplyr` para selecionar os diamantes de corte (`cut`) "Ideal". Crie um gráfico de barras (`bar plot`) usando o `ggplot2` para mostrar a contagem de diamantes por cor (`color`).

``` r
Resposta:

diamonds %>%
  filter(cut == "Ideal") %>%
  ggplot(aes(x = color,
             fill = color)) +
  geom_bar() +
  labs(title = "Contagem de Diamantes por Cor (Corte Ideal)", 
       x = "Cor", 
       y = "Contagem")
```

2. Crie um histograma usando o `ggplot2` para visualizar a distribuição dos preços (`price`) dos diamantes, divididos por categoria de corte (`cut`). Use a função `facet_wrap` para deixar o gráfico menos poluído.

``` r
Resposta:

diamonds %>%
  ggplot(aes(x = price, 
             fill = cut),
             alpha = 0.3) +
  geom_histogram(binwidth = 50) +
  facet_wrap(~cut) +
  labs(title = "Distribuição de Preços dos Diamantes por Categoria de Corte", 
       x = "Preço", 
       y = "Contagem") +
  scale_fill_discrete(name = "Corte")
```

3. Utilize o `mutate()` para criar uma nova coluna chamada `volume`, representando o volume do diamante calculado pela fórmula `x * y * z`. Crie um gráfico de dispersão usando o `ggplot2`, onde o eixo x é o volume e o eixo y é o preço (`price`), colorindo os pontos de acordo com a qualidade de corte (`cut`). Existe alguma relação entre volume e preço?

``` r
Resposta:

diamonds %>%
  mutate(volume = x * y * z) %>%
  ggplot(aes(x = volume, 
             y = price, 
             color = cut)) +
  geom_point() +
  labs(title = "Relação entre Volume e Preço dos Diamantes", 
       x = "Volume", 
       y = "Preço", 
       color = "Corte")
```

4. Utilize o `group_by()` e `summarise()` do `dplyr` para calcular a média do preço por quilate para cada categoria de corte (`cut`). Crie um gráfico de barras (`bar plot`) usando o `ggplot2` para visualizar essas médias.

``` r
Resposta:

diamonds %>%
  group_by(cut) %>%
  summarise(avg_price_per_carat = mean(price / carat)) %>%
  ggplot(aes(x = cut, 
             y = avg_price_per_carat,
             fill = cut)) +
  geom_bar(stat = "identity") +
  labs(title = "Média de Preço por Quilate por Categoria de Corte", 
       x = "Corte", 
       y = "Média de Preço por Quilate")

```

5. Crie um gráfico de caixa (`box plot`) usando o `ggplot2` para comparar a distribuição dos preços (`price`) dos diamantes entre diferentes categorias de corte (`cut`).

``` r
Resposta:

diamonds %>%
  ggplot(aes(x = cut, 
             y = price, 
             fill = cut)) +
  geom_boxplot() +
  labs(title = "Distribuição de Preços dos Diamantes por Categoria de Corte", 
       x = "Corte", 
       y = "Preço") +
  scale_fill_discrete(name = "Corte")

```

6. Utilize o `filter()` do `dplyr` para selecionar os diamantes com preço acima de $500. Crie um gráfico de dispersão usando o `ggplot2`, onde o eixo x é o peso (`carat`) e o eixo y é o preço por quilate (`price_per_carat`), colorindo os pontos pela coloração (`color`).

``` r
Resposta:

diamonds %>%
 filter(price > 500) %>%
  mutate(price_per_carat = price / carat) %>%
  ggplot(aes(x = carat, 
             y = price_per_carat, 
             color = color)) +
  geom_point() +
  labs(title = "Relação entre Peso e Preço por Quilate dos Diamantes", 
       x = "Peso", 
       y = "Preço por Quilate", 
       color = "Coloração")
```

7. Utilize o `mutate()` para criar uma nova coluna chamada `depth_category`, que categoriza a profundidade (`depth`) em "baixa" (abaixo de 60), "média" (entre 60 e 65) e "alta" (acima de 65). Crie um gráfico de barras (`bar plot`) usando o `ggplot2` para mostrar a contagem de diamantes em cada categoria de corte (`cut`), agrupados pela categoria de profundidade.

``` r
Resposta:

diamonds %>%
  mutate(depth_category = case_when(
    depth < 60 ~ "baixa",
    depth >= 60 & depth <= 65 ~ "média",
    depth > 65 ~ "alta")) %>%
  ggplot(aes(x = cut, 
             fill = depth_category)) +
  geom_bar() +
  labs(title = "Contagem de Diamantes por Categoria de Corte e Categoria de Profundidade", 
       x = "Corte", 
       y = "Contagem") +
  scale_fill_discrete(name = "Profundidade")
```

8. Utilize o `filter()` para selecionar os diamantes com coloração (`color`) D, E ou F. Crie um gráfico de densidade usando o `ggplot2` para comparar a distribuição das proporções da variável tabela (`table`) entre essas diferentes cores. Use a função `facet_wrap` para o gráfico não ficar muito poluído.

``` r
Resposta:

diamonds %>%
  filter(color %in% c("D", "E", "F")) %>%
  ggplot(aes(x = table, 
             fill = color)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~color) +
  labs(title = "Distribuição da Proporção de Tabela por Cor", 
       x = "Proporção de Tabela", 
       y = "Densidade") +
  scale_fill_discrete(name = "Cor")
```

9. Utilize o `mutate()` para criar uma nova coluna chamada `carat_category`, que categoriza o peso (`carat`) em intervalos de 0.75 quilates. Crie um gráfico de barras (`bar plot`) usando o `ggplot2` para mostrar a contagem de diamantes em cada categoria de corte (`cut`), agrupados pela nova categoria de peso, `carat_category`.

``` r
Resposta:

diamonds %>%
 mutate(carat_category = cut(carat, 
                             breaks = seq(0, 5.5, 
                                          by = 0.75))) %>%
  ggplot(aes(x = cut, 
             fill = carat_category)) +
  geom_bar() +
  labs(title = "Contagem de Diamantes por Categoria de Corte e Categoria de Peso", 
       x = "Corte", 
       y = "Contagem") +
  scale_fill_discrete(name = "Peso")
```

10. Utilize o `mutate()` para criar uma nova coluna chamada `price_log`, que contém o logaritmo natural dos preços (`price`) dos diamantes. Crie um gráfico de dispersão usando o `ggplot2`, onde o eixo x é o peso (`carat`) e o eixo y é o log do preço, colorindo os pontos pela clareza (`clarity`). Referência: Para obter mais informações sobre a função `log()` no R, você pode consultar a documentação oficial [aqui](https://www.statology.org/log-in-r/).

``` r
Resposta:

diamonds %>%
  mutate(price_log = log(price)) %>%
  ggplot(aes(x = carat, y = price_log, 
             color = clarity)) +
  geom_point() +
  labs(title = "Relação entre Peso e Log do Preço dos Diamantes", 
       x = "Peso", 
       y = "Log do Preço", 
       color = "Clareza")
```

Não hesite em explorar novos parâmetros, cores, formas e funções para personalizar suas visualizações. Um excelente recurso para aprender mais sobre as possibilidades do `ggplot2` e como criar visualizações impressionantes é o site [R Graphics Cookbook](https://r-graphics.org/) de Winston Chang. Lá você encontrará muitos exemplos e dicas úteis para aprimorar suas habilidades em visualização de dados.

Bom trabalho!

## Tutorial 09



## Tutorial 10

### Exercício 1: Carregar Pacotes e Dados

1.1. Carregue os pacotes `tidyverse`, `janitor`, e `nycflights13`.

``` r
Resposta:

library(tidyverse)
library(janitor)
library(nycflights13)
```

1.2. Carregue os seguintes conjuntos de dados: `flights`, `airlines`, `airports`, `planes`. Verifique a documentação de cada um deles.

``` r
Resposta:

data(flights)
data(airlines)
data(airports)
data(planes)
```

### Exercício 2: Explorar os Dados

2.1. Quantos voos foram realizados em 2013?

``` r
Resposta:

nrow(flights)
```

2.2. Qual é a companhia aérea mais popular em termos de voos?

``` r
Resposta:

flights %>%
  group_by(carrier) %>%
  summarise(total_flights = n()) %>%
  arrange(desc(total_flights)) %>%
  head(1)
```

2.3. Qual é o aeroporto de origem mais movimentado?

``` r
Resposta:

flights %>%
  group_by(origin) %>%
  summarise(total_flights = n()) %>%
  arrange(desc(total_flights)) %>%
  head(1)
```

### Exercício 3: Transformação de Dados

3.1. Crie uma nova coluna chamada `speed` que represente a velocidade média dos voos (distância/tempo).

``` r
Resposta:

flights %>%
  mutate(speed = distance / air_time)
```

3.2. Adicione uma coluna `delayed` que contenha informações se um voo teve atraso (tempo de atraso maior que 0) ou não.

``` r
Resposta:

flights %>%
  mutate(delayed = ifelse(dep_delay > 0, 
                          "Yes", 
                          "No"))
```

### Exercício 4: Agregação de Dados

4.1. Calcule o tempo médio de atraso por companhia aérea.

``` r
Resposta:

flights %>%
  group_by(carrier) %>%
  summarise(avg_dep_delay = mean(dep_delay,
                                 na.rm = TRUE))
```

4.2. Encontre o aeroporto com o maior atraso médio.

``` r
Resposta:

flights %>%
  group_by(origin) %>%
  summarise(avg_dep_delay = mean(dep_delay,
                                 na.rm = TRUE)) %>%
  arrange(desc(avg_dep_delay)) %>%
  head(1)
```

4.3. Qual é o dia da semana com mais voos atrasados?

``` r
Resposta:

flights %>%
  mutate(day_of_week = weekdays(as.Date(time_hour))) %>%
  filter(dep_delay > 0) %>%
  group_by(day_of_week) %>%
  summarise(total_delayed_flights = n()) %>%
  arrange(desc(total_delayed_flights)) %>%
  head(1)
```

### Exercício 5: Visualizações com ggplot2

5.1. Crie um gráfico de barras que mostre o número de voos por companhia aérea.

``` r
Resposta:

flights %>%
  filter(!is.na(carrier)) %>% 
  ggplot(aes(x = carrier,
             fill = carrier)) +
  geom_bar() +
  labs(title = "Número de Voos por Companhia Aérea")
```

5.2. Crie um histograma que represente a distribuição dos atrasos de partida.

``` r
Resposta:

flights %>%
  filter(!is.na(dep_delay)) %>% 
  ggplot(aes(x = dep_delay)) +
  geom_histogram(binwidth = 50) +
  labs(title = "Distribuição dos Atrasos de Partida")
```

### Exercício 6: Junção de Dados

6.1. Crie um novo _dataframe_ que una os dados dos voos com informações sobre as companhias aéreas (`airlines`).

``` r
Resposta:

flights_with_airlines <- flights %>%
  left_join(airlines, by = "carrier")
```

6.2. Faça o mesmo com os dados dos aeroportos (`airports`).

``` r
Resposta:

flights_with_airports <- flights %>%
  left_join(airports, by = c("origin" = "faa"))
```

6.3. Combine os dados de voos com informações sobre os aviões (`planes`).

``` r
Resposta:

flights_with_planes <- flights %>%
  left_join(planes, by = "tailnum")
```

### Exercício 7: Filtragem de Dados

7.1. Filtre os voos que tiveram atraso na partida e chegaram atrasados no destino.

``` r
Resposta:

delayed_flights <- flights %>%
  filter(dep_delay > 0 & 
         arr_delay > 0)
```

7.2. Encontre voos que partiram do aeroporto JFK (John F. Kennedy International) para Los Angeles (LAX) e tiveram atraso na partida.

``` r
Resposta:

jfk_to_lax_delayed <- flights %>%
  filter(origin == "JFK" & 
         dest == "LAX" &
         dep_delay > 0)
```

### Exercício 8: Reshaping os Dados

8.1. Use a função `pivot_longer` para transformar as colunas de atraso (`dep_delay`, `arr_delay`) em uma única coluna de atraso.

``` r
Resposta:

flights_long <- flights %>%
  pivot_longer(cols = c(dep_delay, 
                        arr_delay), 
               names_to = "delay_type", 
               values_to = "delay_minutes")
```

8.2. Use a função `pivot_wider` para transformar a coluna `carrier` em colunas separadas para cada companhia aérea.

``` r
Resposta:

flights_wide <- flights %>%
  pivot_wider(names_from = carrier, 
              values_from = dep_delay)
```

### Exercício 9: Análise Temporal

9.1. Crie um gráfico de linhas que mostre a variação do número de voos ao longo dos meses de 2013.

``` r
Resposta:

flights %>%
  mutate(month = factor(month, 
                        labels = month.name)) %>%
  group_by(month) %>%
  summarise(total_flights = n()) %>%
  ggplot(aes(x = month, 
             y = total_flights, 
             group = 1)) +
  geom_line(color = "skyblue") +
  labs(x = "Mês", 
       y = "Número de Voos",
       title = "Variação do Número de Voos ao Longo dos Meses de 2013")
```

9.2. Analise se existe uma tendência sazonal nos atrasos de partida ao longo do ano.

``` r
Resposta:

flights %>%
  mutate(month = factor(month, 
                        labels = month.name)) %>%
  group_by(month) %>%
  summarise(avg_dep_delay = mean(dep_delay, 
                                 na.rm = TRUE)) %>%
  ggplot(aes(x = month, 
             y = avg_dep_delay, 
             group = 1)) +
  geom_line(color = "skyblue") +
  labs(x = "Mês", 
       y = "Atraso Médio na Partida (minutos)") +
  ggtitle("Tendência Sazonal nos Atrasos de Partida")

```

### Exercício 10: Estatísticas Descritivas

10.1. Calcule a distância média dos voos por aeroporto de origem.

``` r
Resposta:

flights %>%
  group_by(origin) %>%
  summarise(avg_distance = mean(distance, 
                                na.rm = TRUE))
```

10.2. Encontre a companhia aérea com o maior atraso médio na chegada.

``` r
Resposta:

flights %>%
  group_by(carrier) %>%
  summarise(avg_arr_delay = mean(arr_delay, 
                                 na.rm = TRUE)) %>%
  arrange(desc(avg_arr_delay)) %>%
  head(1)
```

10.3. Calcule a distância total de voo para cada companhia aérea.

``` r
Resposta:

flights %>%
  group_by(carrier) %>%
  summarise(total_distance = sum(distance, 
  na.rm = TRUE))
```

Bom trabalho!
