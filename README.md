# Quanto Sobrou

Controle de importação e revenda com abas independentes. Dá entrada no produto quando compra,
registra a chegada e, na saída, aplica sozinho a taxa do canal (Mercado Livre, Shopee, OLX,
Facebook…) e o frete, mostrando o que realmente sobrou.

Também projeta quanto ainda pode entrar do estoque parado, sem misturar previsão com venda
realizada — faturamento e lucro só contam quando a saída é registrada de verdade.

## Como funciona

Uma página só, sem dependências, sem build. Os dados ficam num banco Postgres no Supabase,
e o navegador conversa com ele direto.

Cada pessoa tem sua aba. As contas podem consultar as abas, mas **só alteram as que gerenciam** — e
isso não é controlado pela tela, é regra do banco (Row Level Security). Uma tentativa de
gravar na aba alheia é recusada no servidor, mesmo vinda de fora do app.

## Sobre a chave neste repositório

O arquivo contém a URL do projeto e a chave `anon` do Supabase. **As duas são públicas por
natureza** — todo app Supabase as carrega no navegador do usuário. Sozinhas não dão acesso a
nada: sem estar autenticado, uma consulta à tabela devolve lista vazia.

Quem protege os dados são as políticas de acesso, que rodam no servidor. A chave
`service_role`, essa sim sensível, não está aqui e nunca deve estar.

## Estrutura do banco

As tabelas `public.pessoas`, `public.produtos` e `public.unidades` guardam as abas,
os cadastros e as unidades de estoque. Os canais e seus históricos auxiliares ficam
no JSON de cada pessoa. As políticas de RLS controlam a escrita no servidor.

## Aba Eduarda

A migração `supabase/migrations/20261108_eduarda.sql` cria a aba `eduarda`, com
nome **Eduarda**, e associa a edição exclusivamente ao usuário já cadastrado com
o e-mail `victorhugoabib@gmail.com`. Ela deve ser aplicada por um administrador
no Supabase; publicar o código no GitHub Pages não executa a migração do banco.

A migração copia somente as definições gerais dos canais da aba Victor. Os
produtos, as unidades, as vendas, as despesas e as devoluções da nova aba começam
vazios. Uma nova execução preserva os dados de Eduarda, atualizando seu nome e dono.

As permissões específicas cobrem pessoas, produtos e unidades. Políticas
restritivas bloqueiam gravações em Eduarda feitas por outras contas, inclusive
quando há outra política permissiva mais ampla. As políticas existentes das
demais abas são mantidas. O e-mail é resolvido para o UUID real em `auth.users`;
não há credencial administrativa no navegador.

O site carrega a aba do banco e reutiliza todos os módulos. A proteção da tela
também confere o UUID proprietário e o e-mail autorizado. Ao entrar, Victor
continua abrindo sua aba pessoal por padrão, podendo alternar para Eduarda.
