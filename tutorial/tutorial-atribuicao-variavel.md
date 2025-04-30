A preferência por `<-` em vez de `=` para criar objetos em R combina razões históricas, clareza na intenção do código e convenções comunitárias. Apesar disso, R permite o uso de ambos os operadores, oferecendo flexibilidade aos programadores em seus estilos de codificação. Ainda assim, o uso de `<-` é amplamente recomendado em diversos guias de estilo da comunidade R, como pode ser observado [aqui](http://adv-r.had.co.nz/Style.html), [aqui](https://google.github.io/styleguide/Rguide.html), [aqui](https://style.tidyverse.org/) e [aqui](https://jef.works/R-style-guide/).

A seguir estão algumas razões detalhadas para preferir `<-` a `=` em atribuições no R:

1. **Tradição Histórica:**  
   O operador `<-` provém da linguagem S, antecessora direta do R. Os criadores do R optaram por preservar essa sintaxe para facilitar a transição dos usuários que vinham do S, mantendo uma coerência histórica.

2. **Escopo e Estilo:**  
   Em R, o operador `=` é mais frequentemente utilizado para atribuir valores a parâmetros dentro de funções e loops, enquanto `<-` é preferido para atribuir valores a variáveis no ambiente global ou no interior de funções. Essa distinção ajuda na clareza do código, tornando evidente se estamos definindo variáveis ou passando argumentos para funções.

3. **Clareza e Distinção:**  
   O operador `<-` distingue claramente atribuição de variáveis (`<-`) do teste lógico de igualdade (`==`). Embora `=` também possa realizar atribuições em R, o uso do `<-` torna o código mais explícito e fácil de compreender, especialmente importante no contexto estatístico, onde a legibilidade é crucial.

4. **Rigor e Intenção:**  
   Do ponto de vista matemático e conceitual, utilizar `<-` deixa clara a intenção de atribuição, enquanto o uso de `=` pode gerar ambiguidades. Observe o exemplo:

```r
x = 1
y <- 2
```

Nesse ponto, as diferenças parecem sutis. Entretanto, ao complexificar o código, a clareza se torna essencial:

```r
x = x / y
x <- x / y
```

Sob a perspectiva da computação, ambos os códigos são funcionalmente idênticos, já que ambos apenas reservam espaço na memória para objetos. Contudo, matematicamente, a expressão `x = x / y` pode sugerir incorretamente uma equação matemática em vez de uma atribuição.

Ao utilizar `<-`, fica claro que estamos atribuindo um novo valor ao objeto `x`, em vez de sugerir uma igualdade matemática.

---

### Curiosidade:

Na verdade, existem três maneiras de atribuir valores em R: `<-`, `=` e `->`. Embora tecnicamente possível, o operador `->` está em desuso devido sua falta de praticidade.

Veja o exemplo abaixo, considerando as três formas:

```r
w = 1
x = 2
x = w
y <- x
y -> z
```

Perceba como o uso de `=` na linha `x = w` gera ambiguidade, dificultando a compreensão imediata sobre qual variável está sendo alterada. Em contraste, o uso de `<-` ou `->` explicita claramente a direção e a intenção da atribuição.

Sempre lembre que um dos principais objetivos do código é ser facilmente compreendido por outros usuários, inclusive por você mesmo no futuro. Investir alguns segundos extras para escrever um código mais claro pode economizar horas de esforço no futuro!