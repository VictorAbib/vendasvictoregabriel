# Quanto Sobrou

Controle de importação e revenda: dá entrada no produto quando compra, registra a chegada
e, na saída, aplica sozinho a taxa do canal (Mercado Livre, Shopee, OLX, Facebook…) e o frete,
mostrando o que realmente sobrou.

Também projeta quanto ainda pode entrar do estoque parado, sem misturar previsão com venda
realizada — faturamento e lucro só contam quando a saída é registrada de verdade.

## Onde ficam os dados

Nesta versão hospedada, tudo é guardado **no armazenamento local do próprio navegador**, no
aparelho em que você está usando. Não existe servidor e nada é enviado para lugar nenhum.

Duas consequências que valem saber:

- Abrir o site em outro celular ou computador começa do zero — os aparelhos não conversam.
- Limpar os dados de navegação apaga o cadastro.

Por isso existe o cartão **Backup dos seus dados** no fim da página. Baixe o arquivo de vez em
quando: ele serve tanto para restaurar quanto para levar o cadastro de um aparelho para outro.

## Como rodar sem internet

O arquivo `index.html` é autossuficiente — sem dependências, sem CDN, sem build.
Basta baixar e abrir com duplo clique.
