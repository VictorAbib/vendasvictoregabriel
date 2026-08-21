# Quanto Sobrou

Controle de importação e revenda para duas pessoas. Dá entrada no produto quando compra,
registra a chegada e, na saída, aplica sozinho a taxa do canal (Mercado Livre, Shopee, OLX,
Facebook…) e o frete, mostrando o que realmente sobrou.

Também projeta quanto ainda pode entrar do estoque parado, sem misturar previsão com venda
realizada — faturamento e lucro só contam quando a saída é registrada de verdade.

## Como funciona

Uma página só, sem dependências, sem build. Os dados ficam num banco Postgres no Supabase,
e o navegador conversa com ele direto.

Cada pessoa tem sua aba. As duas enxergam tudo, mas **cada uma só altera a própria** — e
isso não é controlado pela tela, é regra do banco (Row Level Security). Uma tentativa de
gravar na aba alheia é recusada no servidor, mesmo vinda de fora do app.

## Sobre a chave neste repositório

O arquivo contém a URL do projeto e a chave `anon` do Supabase. **As duas são públicas por
natureza** — todo app Supabase as carrega no navegador do usuário. Sozinhas não dão acesso a
nada: sem estar autenticado, uma consulta à tabela devolve lista vazia.

Quem protege os dados são as políticas de acesso, que rodam no servidor. A chave
`service_role`, essa sim sensível, não está aqui e nunca deve estar.

## Estrutura do banco

Uma tabela, `public.pessoas`, com uma linha por aba e os produtos em `jsonb`. O SQL que a
cria, junto das políticas de permissão, está fora deste repositório, na pasta de
administração do projeto.
