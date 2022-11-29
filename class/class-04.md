#  4o Aula - ggplot2: Gramática de gráficos

## Objetivos Gerais

No encontro de hoje vamos seguir com a gramática do `dplyr` para transformar os dados e produzir tabelas. Utilizaremos um pacote excelente (e desconhecido para mim até pouco tempo) chamado `janitor`. No meio do caminho, aprenderemos um pouco sobre `factors`, que é a estrutura de dados utilizada em R para variáveis categóricas.

A seguir, aprenderemos uma nova 'gramática' de R: a gramática de gráficos do pacote `ggplot2`. Este pacote é certamente uma das razões pelas quais R se tornou popular (e uma das vantagens de R sobre python). Trabalharemos algumas das inúmeros 'geometrias' do pacote, nos preocupando menos em colecionar funções e mais em compreender a estrutura dessa gramática.

## Roteiro

0 - Às 9h30 faremos um encontro virtual (Teams) de 1h para falarmos dos objetivos de hoje e tirarmos dúvidas sobre a aula passada.

1 - Entre 9h às 9h30, leia as instruções deste roteiro. Se deixou algum tutorial inacabado do encontro anterior, comece a ele. Caso contrário, prossiga.

2 - Comece pelo tutorial no qual parou: [Tutorial 1](https://github.com/seade-R/egesp-seade-intro-programacao/blob/master/tutorial/tutorial-01.md), [Tutorial 2](https://github.com/seade-R/egesp-seade-intro-programacao/blob/master/tutorial/tutorial-02.md), [Tutorial 3](https://github.com/seade-R/egesp-seade-intro-programacao/blob/master/tutorial/tutorial-03.md), [Tutorial 4](https://github.com/seade-R/egesp-seade-intro-programacao/blob/master/tutorial/tutorial-04.md), [Tutorial 5](https://github.com/seade-R/egesp-seade-intro-programacao/blob/master/tutorial/tutorial-05.md) e [Tutorial 6](https://github.com/seade-R/egesp-seade-intro-programacao/blob/master/tutorial/tutorial-06.md)

3 - Na sequência, vá para o [Tutorial 7](https://github.com/seade-R/egesp-seade-intro-programacao/blob/master/tutorial/tutorial-07.md), já indicado no encontro passado, que apresenta o pacote `janitor` para limpeza de dados e construção de tabelas, simples e de duas entradas.

4 - Finalmente vá para o [Tutorial 8](https://github.com/seade-R/egesp-seade-intro-programacao/blob/master/tutorial/tutorial-08.md) que introduz um das especialidades de R: a gramática de gráficos do pacote `ggplot2`.

## Opcional

5 - Em algum momento do curso, ou após, seria interessante ter uma exposição à gramática básica do R. Se, e somente se, você estiver confortável com a gramática do `dplyr` e houver tempo, faça (ou comece) o [Tutorial 9](https://github.com/seade-R/egesp-seade-intro-programacao/blob/master/tutorial/tutorial-09.md)

## Dicas de Leitura

- Voltando à gramática de gráficos, não trabalhamos, propositalmente, com todos os elementos visuais secundários às geometrias: títulos, legenda, eixos, etc. Você pode aprender um pouco mais explorando os exemplos do livro [R Graphics Cookbook](https://r-graphics.org/): gráficos de barras no [Capítulo 3](https://r-graphics.org/chapter-bar-graph); gráficos de linha no [Capítulo 4](https://r-graphics.org/chapter-line-graph); ou gráficos de dispersão no [Capítulo 5](https://r-graphics.org/chapter-scatter). Finalmente, se tiver tempo, explore a [página do R Graphics Cookbook](http://www.cookbook-r.com/Graphs/) (que é diferente do livro).

- Uma leitura alternativa e introdutória sobre `ggplot2` é o [Capítulo 3](https://r4ds.had.co.nz/data-visualisation.html) do livro 'R for Data Science'. Se o Tutorial 8 não foi suficiente para você aprender, recomendo esta leitura.

- O livro 'R for Data Science' tem um excelente capítulo sobre Factors ([Capítulo 15](https://r4ds.had.co.nz/factors.html)).