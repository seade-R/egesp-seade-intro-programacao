# Abrindo dados no R

Neste tutorial vamos cobrir uma série de métodos disponíveis para abrirmos arquivos de texto, editores de planilhas e de outros softwares de análise de dados no R. Vamos dar atenção aos argumentos das funções de forma a solucionar dificuldades de abertura de dados com diferentes características ou em sistemas operacionais variados.

Lembre-se que você sempre pode recorrer ao botão "Import Dataset" do RStudio caso tenha dificuldades de abrir um arquivo.

## Pacotes no R

Antes de avançarmos à tarefa principal, vamos aprender um pouco mais sobre pacotes. Já foi destacado diversas vezes que uma das vantagens do R é a existência de uma comunidade produtiva e que desenvolve continuamente novas funcionalidades, tudo em código aberto.

Para instalarmos um novo pacote de R que esteja disponível no CRAN -- "The Comprehensive R Archive Network" -- utilizamos a função `install.packages`. Veja o exemplo com o pacote `beepr`:

```{r, eval = F}
install.packages("beepr")
```

Note que o nome do pacote deve estar em parêntese e aspas. Além disso, é possível que você tenha sido perguntada sobre de qual servidor do CRAN você quer baixar o pacote. A escolha em nada muda o resultado, exceto o tempo de duração do download.

Uma vez que um pacote foi instalado, ele está disponível em seu computador, mas não ainda para uso neste script e sessão R. Apenas depois de executarmos a função `library` é que teremos o pacote em nossa "biblioteca" de funções.

```{r}
library(beepr)
```

Você pode dispensar as aspas ao usar a função `library`, pois é opcional.

Se você quiser usar rapidamente apenas uma função de um pacote sem carregá-lo, você pode utilizar a função precedidade por `::` (":" duas vezes) e o nome do pacote. Veja o exemplo:

```{r}
beepr::beep()
```

O pacote `beepr` é um dos mais úteis de R. Ele só serve para fazer um beep. Você pode colocá-lo no final de um código pesado e ir tomar café. Seu computador vai apitar quando o código chegar na função `beep` como um microondas que acabou de esquentar a comida.

## Caminhos no R

Para importar dados para R é preciso informar onde o arquivo está em seu computador (ou informar o endereço na web). R sempre começa a procurar pelos arquivos no 'diretório de trabalho', ou 'wd'. Você pode verificar em qual diretório está trabalhando executando o seguinte comando:

```{r, eval = F}
getwd()
```

E como eu altero o "wd" (_working directory_)?

```{r, eval = F}
setwd("C:\\User\\Documents")
```

Simples e muito útil para evitar escrevermos "labirintos de pastas" cada vez que queremos importar dados. Agora só precisamos nos referir ao nome do arquivo (e não a sua pasta) para abrí-lo. É uma boa prática manter todos os arquivos, scripts e saídas importados em uma pasta de projeto bem organizada.

IMPORTANTE! Um detalhe fundamental para quem usa Windows: os caminhos devem ser escritos com duas barras no lugar de uma, como no exemplo acima. É uma chatice e a melhor solução é mudar definitivamente para Linux.

Se você preferir não se preocupar com as pastas, pode criar um projeto para armazenar toda a documentação em uma única pasta, como vimos no vídeo disponibilizado na 2a aula.

## readr

Existem muitas funções para abrir arquivos de dados. No curso vamos nos concentrar em um conjunto de funções do pacote `readr`. O pacote `readr` contém funções para abertura de dados 'retangulares' em formato de texto (.csv, .tsv, .txt). 

`readr` é parte do `tidyverse` e, ao carregar o último, as funções de abertura do `readr` estarão disponíveis.

```{r}
library(tidyverse)
```

Provavelmente as funções mais usadas no `readr` são `read\_csv` e `read\_csv2`, que abrem arquivos .csv separados por vírgula e ponto e vírgula, respectivamente. Temos à nossa disposição no repositório do github a base de dados da pesquisa SEADE Investimentos com a qual trabalhamos anteriormente salva em formatos de texto variados -- com vírgula ou ponto e vírgula como separador, com ou sem cabeçalho na primeira linha identificando o nome das variáveis e com diferentes encodings.

Nosso exemplo da pesquisa SEADE Investimentos abrimos um arquivo em .csv separado por ponto e vírgula:

```{r}
url_piesp <- 'https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/master/data/piesp.csv'
piesp <- read_csv2(url_piesp)
```

Se preferir repetir o código acima em um único passo: 

```{r}
piesp <- read_csv2('https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/master/data/piesp.csv')
```

Como vamos trabalhar com arquivos parecidos armazenados em diversos URLs, colocaremos sempre como argumento da função de abertura de dados um objeto que armazena o URL e não o próprio o URL para explicitar o que estamos fazendo. E vamos desde já guardar os URLS dos arquivos com os quais vamos trabalhar como objetos:

```{r}
url_piesp <- 'https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/master/data/piesp.csv'
url_piesp_virgula <- 'https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/master/data/piesp_virgula.csv'
url_piesp_tab <- 'https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/master/data/piesp_tab.txt'
url_piesp_sem_cabecalho <- 'https://raw.githubusercontent.com/seade-R/egesp-seade-intro-programacao/master/data/piesp_sem_cabecalho.csv'
url_covid_latin1 <- 'https://raw.githubusercontent.com/seade-R/dados-covid-sp/master/data/dados_covid_sp_latin1.csv'
```

```{r}
piesp_virgula <- read_csv(url_piesp_virgula)
```

Funciona da mesma maneira.

`read\_csv` e `read\_csv2` fazem parte da 'família' de funções `read\_delim`. Ou, melhor dizendo, são a função `read\_delim` especificada para arquivos separados por vírgula e ponto e vírgula.

A função `read\_delim` nos dá mais flexibilidade para lidar com tipos incomuns de arquivos, pois permite especificar qual será o delimitador. Utilizamos o argumento `delim`, que vem após o endereço do arquivo logo após a vírgula. Em nosso terceiro exemplo temos um arquivo separado por 'tab', cujo símbolo é '\t' (e, para variar, com extensão .txt, mas a extensão não importa quando estamos tratando de arquivos de texto). Veja como funciona `read\_delim`:

```{r}
piesp_tab <- read_delim(url_piesp_tab, delim = "\t")
```

Repetindo os 2 primeiros exemplos usando `read\_delim`:

```{r}
piesp <- read_delim(url_piesp, , delim = ";")
piesp_virgula <- read_delim(url_piesp_virgula, delim = ",")
```

O padrão de `read\_delim` (e `read\_csv` e `read\_csv2`) é importar a primeira linha como nome das variáveis. Se nossos dados não tiverem um _header_ (cabeçalho, ou seja, nomes das variáveis na primeira linhas), a primeira linha de dados se torna equivocadamente o nome das variáveis (inclusive os números, que aparecem antecedidos por um "X"). Para corrigir o problema utilizamos o argumento `col_names`, que deve ser igual a `FALSE` para os dados armezenados sem nomes de colunas, por exemplo:

```{r}
piesp <- read_delim(url_piesp_sem_cabecalho, 
                    delim = ";", 
                    col_names = F)
```

Além dos valores lógicos, `col_names` também aceita um vetor com novos nomes para as colunas como argumento:

```{r}
piesp_com_cabecalho_novo <- read_delim(url_piesp_sem_cabecalho, 
                    col_names = c("Ano", "Trimestre", "Data do Anuncio", "Empresa alvo do investimento",
                                  "Empresa(s) investidora(s)", "Real (em milhoes)", "Dolar (em milhoes)",
                                  "Valor Informado", "Municipio", "Regiao", "Descricao do investimento", 
                                  "CNAE Empresa alvo do investimento", "CNAE Empresa(s) investidora(s)",
                                  "Tipo Investimento", "Periodo"),
                    delim = ";")
```

Por vezes, é interessante definir as classes das variáveis a serem importadas, para evitar novas transformações quando os dados forem importados. O argumento `col\_types` deve ser uma sequência de caracteres onde "c" = "character", "d" = "double", "l" = "logical" e "i" = "integer". Por exemplo:

```{r}
piesp <- read_delim(url_piesp, 
                    delim = ";", 
                    col_types = "iiccccccccccccc")
```

Perceba que quando abrimos os dados sem especificar o tipo da coluna, a função `read\_delim` e suas variantes tentam identificá-los. 

Uma complexidade de abertura de dados brasileiros é o uso da vírgula como separador decimal e o ponto para indicar milhares. Note que deixamos as colunas de valores como 'character' por usar ',' como de separador de decimal, quando o padrão em R é '.'. Temos que especificar no argumento _locale_ essas diferenças. 

```{r}
piesp <- read_delim(url_piesp, 
                    delim = ";", 
                    col_types = 'iicccddiccccccc',
                    locale = locale(decimal_mark = ",", grouping_mark = "."))
```

No caso dos dados da pesquisa SEADE Investimentos, alguns números não são lidos corretamente por haver espaços inúteis antes ou depois. Com o argumento `trim_ws = TRUE` eliminamos espaços em que precedem ou sucedem a informação em todas as variáveis. Vamos usá-lo:

```{r}
piesp <- read_delim(url_piesp, 
                    delim = ";", 
                    col_types = 'iicccddiccccccc',
                    trim_ws = T,
                    locale = locale(decimal_mark = ",", grouping_mark = "."))
```

Também podemos usar `locale` para especificar o formato da hora, o formato da data e o encoding do arquivo que estamos lendo.

É comum termos problemas para abrir arquivos que contenham caracteres especiais, pois há diferentes formas do computador transformar 0 e 1 em vogais acentuadas, cecedilha, etc. O "encoding" de cada arquivo varia de acordo com o sistema operacional e aplicativo no qual foi gerado.

No servidor do SEADE utilizamos como encoding nativo "UTF-8", pois o servidor é Linux (use Linux!). Mac também costuma usar UTF-8. Windowns, por sua vez, costuma usar outros encodings, como 'Latin1'. Vamos abrir um arquivo sobre casos e óbitos relacionados à epidemia de COVID-19 em São Paulo cujo encoding é 'Latin1' sem informar o parâmetro do encoding:

```{r}
covid <- read_csv2(url_covid_latin1) 

head(covid)
```

Notem como a grafia dos municípios com nomes acentuados está totalmente bagunçada. Em alguns casos, sequer conseguimos abrir o arquivo.

```{r}
covid <- read_csv2(url_covid_latin1,
                    locale = locale(encoding = 'latin1'))

head(covid)
```

Veja como agora resolvemos o problema.

Infelizmente não há formas automáticas infalíveis de descobrir o "encoding" de um arquivo e é preciso conhecer como foi gerado -- seja por que você produziu o arquivo ou por que você teve acesso à documentação. Ou descobrir a partir para tentativa e erro. Alguns "encodings" comuns são "latin1", "latin2" e "utf8", mas há diversos outros.

Finalmente, você pode pular escolher 'pular' algumas linhas do arquivo (por exemplo, no caso de arquivos com informações que não fazem parte do banco na primeira linha) como argumento 'skip' ou limitar a abertura a um número de linhas com 'n_max'. Se estiver lidando com bases muito grandes, convém abrir apenas as primeiras para acertar todos os parâmetros da abertura e depois excluir o limite para abrir o arquivo completo.

Recomendo que você leia rapidamento 'help' das funções com as quais trabalhamos para aprender um pouco mais:

```{r}
?read_delim
```

## Fread, a melhor função de abertura

R é uma linguagem com vários dialetos. Um dialeto excelente, mas não tão popular quanto o do `dplyr` é o do pacote `data.table`. Não vamos falar dele no curso. Mas vamos instalá-lo para usar uma única função disponível que vale muito a pena ter em nosso repertório: `fread`.

OBS: se estiver com problemas de instalação de pacotes no curso, pode pular o código abaixo.

```{r}
install.packages('data.table')
```

Lembre-se de carregá-lo:

```{r}
library(data.table)
```

A função `fread` é extremamente rápida e inteligente para abrir dados. Ela reconhece automaticamente boa parte dos parâmetros necessários para abrir os dados. E consegue abrir bases muito grandes na RAM que as funções do `readr` não conseguem (e fazem o RStudio 'quebrar'). Seu uso é trivial:

```{r}
piesp <- fread(url_piesp)
```

Como as funções do `readr`, há vários parâmetros que podem ser informados. Se precisar, use o 'help' para aprender mais.

## A família read.table

As funções do `readr` são redundantes em relação a funções de abertura de dados que havia no pacote 'base'. Estas são da 'família' `read.table`. A grafia das funções do `readr` levam '\_' enquanto as do _base_ levam '.'.

O uso de `read.table` e suas derivadas é muito semelhante ao de `read\_delim` e companhia, mas os nomes dos parâmetros mudam. Novamente, se precisar, use o 'help' para aprender mais.

## Dados em arquivos editores de planilhas

Editores de planilha são, em geral, a primeira ferramenta de análise de dados que aprendemos. Diversas organizações disponibilizam seus dados em formato .xls ou .xlsx e muitos pesquisadores utilizam editores de planilha para construir bases de dados. Nossa missão nesse curso é fazer você abandonar o editor de planilhas.

Vamos ver como obter dados em formato .xls ou .xlsx diretamente, sem precisar abrir os arquivos e exportá-los para um formato de texto.

Há dois bons pacotes com funções para dados em editores de planilha: _readxl_ e _gdata_. Vamos trabalhar apenas com o primeiro, mas convém conhecer o segundo se você for trabalhar constantemente com planilhas e quiser editá-las, e não só salvá-las. `readxl` também é parte do movimennto `tidyverse`, mas temos que abri a biblioteca direitamente, pois não é carregada ao carregarmos o pacote `tidyverse`. Instale e carregue o pacote:

```{r}
install.packages('readxl')
library(readxl)
```

### Um pouco sobre donwload e manipulação de arquivos

Nosso exemplo de arquivo em .xlsx será a tabela sobre "Cartões de Bilhetagem Eletrônica Ativos" produzida pela [EMTU](https://www.emtu.sp.gov.br/emtu/dados-abertos/dados-abertos-principal/bilhetagem-eletronica/arquivos-de-bilhetagem-eletronica.fss). Você pode baixá-la no URL https://www.emtu.sp.gov.br/EMTU/pdf/Jan16%20a%20Ago18_cartoes%20ativos%20BOM.xlsx.

Em vez de baixarmos o arquivo manualmente, vamos fazer download em código com a função `download.file`: Em primeiro lugar, vamos guardar o endereço URL do arquivo em um objeto e fazer o download.

```{r}
url_arquivo <- "https://www.emtu.sp.gov.br/EMTU/pdf/Jan16%20a%20Ago18_cartoes%20ativos%20BOM.xlsx"
```

A seguir, utilizaremos `download.file`. O primeiro argumento desta função é o URL e o segundo é o nome do arquivo que será salvo no seu computador (veja, ainda não estamos criando um objeto, só estamos fazendo download como se utilizassemos um navegador).

```{r}
download.file(url_arquivo, "bilhetagem_eletronica.xlsx")
```

Temos agora o arquivo "bilhetagem_eletronica.xlsx" na nossa pasta de trabalho. Com a função `list.files`
você examina os arquivos que estão nesta pasta (sem precisar olhar dentro da pasta). "bilhetagem_eletronica.xlsx" estará lá

```{r, eval = F}
list.files()
```

## Voltando às planilhas

Coma função `excel\_sheets` examinamos quais são as planilhas existentes do arquivo:

```{r}
excel_sheets("bilhetagem_eletronica.xlsx")
```

Em nosso caso, temos apenas 1 planilha dentro do arquivo, denominada "RMSP". Mas é possível trabalhar com arquivos com múltiplas planilhas. Vamos importá-la. Podemos usar tanto o nome quanto a posição para indicar qual planilha utilizaremos no argumento 'sheet':

```{r}
be <- read_excel("bilhetagem_eletronica.xlsx", sheet = "RMSP")
```

ou

```{r}
be <- read_excel("bilhetagem_eletronica.xlsx", sheet = 1)
```

Quando há apenas uma planilha, 'sheet' torna-se dispensável:

```{r}
be <- read_excel("bilhetagem_eletronica.xlsx")
```

A função `read\_excel` aceita os argumentos "col_names" e "col_types" tal como as funções de importação do pacote `readr`.

Veja que a planilha não contém apenas a matriz de dados. Há também informações antes ou depois e todas são importadas. E tudo foi importado em um data frame, ainda que incorretamente.

Podemos delimitar a área da qual importaremos os dados adicionando o argumento 'range':

```{r}
be <- read_excel('bilhetagem_eletronica.xlsx', sheet = "RMSP", range = "A4:H36")
```

Muito melhor! Precisaríamos agora renomear as variáveis e alterar o seu tipo. Mas temos uma importação feita com sucesso!

## Dados de SPSS, Stata e SAS

R é bastante flexível quanto à importação de dados de outros softwares estatísticos. Para este fim também há um pacote `haven`, que é, advinhe só, parte do `tidyverse`. 

```{r}
library(haven)
```

Basicamente, há cinco funções de importação de dados em`haven`: `read\_sas`, para dados em SAS; `read\_stata` e `read\_dta`, idênticas, para dados em formato .dta gerados em Stata; e `read\_sav` e `read\_por`, uma para cada formato de dados em SPSS. O uso, como era de se esperar, é bastante similar ao que vimos no tutorial todo.

Vamos usar como exemplo os dados da PED de 2019, disponível em https://produtos2.seade.gov.br/produtos/microdados/.

Começaremos baixando o arquivo no URL https://produtos2.seade.gov.br/produtos/midia/2019/07/PED2019_Jan_a_Jun_sav.zip que está em formato .zip. Usaremos a função `download.file` como fizemos anteriormente (não ligue para as quebras de linha, é só para variar um pouco o estilo do código):

```{r}
download.file(
  'https://produtos2.seade.gov.br/produtos/midia/2019/07/PED2019_Jan_a_Jun_sav.zip',
  'ped_2019.zip'
)
```

Precisamos agora ir até a pasta para descompactar o arquivo .zip? É evidente que não! Faremos com código!

```{r}
unzip('ped_2019.zip')
```

Com `list.files` vamos verificar se o arquivo .sav está lá após descompactarmos o arquivo que baixamos:

```{r}
list.files()
```

Pronto, podemos importar a base em .sav.

```{r}
ped19 <- read_sav("PED2019_Jan_a_Jun_sav.SAV")
```

ou, uma função quase idêntica, mas que também abre arquivos de extensão .por

```{r}
ped19 <- read_spss("PED2019_Jan_a_Jun_sav.SAV")
```

Simples assim.

Há critérios de conversão de variáveis categóricas, rótulos e etc, adotados pelo R ao importar arquivos de outras linguagens, mas você pode descobrí-los testando sozinha.

O procedimento para dados em provenientes de Stata ou SAS é bastante similar e a grafia das funções fácil de advinhar: `read\_stata` e `read\_sas`.

## readxl e haven no botão (aaaaaaaaaaaaaaaaargh!!!) Import Dataset

Podemos utilizar o botão (aaaaaaaaaaaaaaaaargh!!!) 'Import Dataset' para abrir planilhas ou arquivos de outros softwares. Pode testar, funciona.

## Uau! Quanta coisa!

Abrir dados em R é por vezes uma aventura. A grande vantagem é que podemos abrir qualquer tipo de dado de qualquer formato. Parece muita coisa agora, mas não precisamos memorizar nada. Use este tutorial como guia no futuro.