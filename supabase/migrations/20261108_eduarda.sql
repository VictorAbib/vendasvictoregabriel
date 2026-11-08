-- Cria a aba Eduarda, vazia, e atribui sua gestao exclusivamente ao cadastro
-- victorhugoabib@gmail.com. Execute com o administrador do projeto Supabase.
-- O bloco inteiro e atomico e pode ser executado novamente sem apagar dados.
DO $eduarda$
DECLARE
  usuario_victor uuid;
  canais_origem jsonb;
  canais_novos jsonb;
  tabela text;
  coluna_aba text;
  filtro_aba text;
  condicao_dono text;
  condicao_guard text;
BEGIN
  IF to_regclass('public.pessoas') IS NULL
     OR to_regclass('public.produtos') IS NULL
     OR to_regclass('public.unidades') IS NULL THEN
    RAISE EXCEPTION 'As tabelas pessoas, produtos e unidades precisam existir antes desta migracao.';
  END IF;

  SELECT id INTO STRICT usuario_victor
  FROM auth.users
  WHERE lower(trim(email)) = 'victorhugoabib@gmail.com';

  SELECT canais::jsonb INTO canais_origem
  FROM public.pessoas
  WHERE id = 'victor' AND dono = usuario_victor;
  IF canais_origem IS NULL OR jsonb_typeof(canais_origem) <> 'array'
     OR jsonb_array_length(canais_origem) = 0 THEN
    RAISE EXCEPTION 'Nao foi encontrada a aba Victor com os canais cadastrados para victorhugoabib@gmail.com.';
  END IF;

  -- Copia somente a definicao dos marketplaces. Estoque, cadastros de
  -- produtos, vendas, despesas, devolucoes e configuracoes por produto nao
  -- sao copiados da aba Victor.
  SELECT jsonb_agg(jsonb_build_object(
    'id', c.valor->'id', 'nome', c.valor->'nome',
    'curto', c.valor->'curto', 'cor', c.valor->'cor', 'fg', c.valor->'fg',
    'pct', c.valor->'pct', 'fixa', c.valor->'fixa', 'limite', c.valor->'limite',
    'frete', c.valor->'frete', 'freteMin', c.valor->'freteMin'
  ) ORDER BY c.ordem) INTO canais_novos
  FROM jsonb_array_elements(canais_origem) WITH ORDINALITY AS c(valor, ordem);

  INSERT INTO public.pessoas (id, nome, dono, canais)
  VALUES ('eduarda', 'Eduarda', usuario_victor, canais_novos)
  ON CONFLICT (id) DO UPDATE
    SET nome = 'Eduarda', dono = EXCLUDED.dono;

  FOREACH tabela IN ARRAY ARRAY['pessoas', 'produtos', 'unidades'] LOOP
    coluna_aba := CASE WHEN tabela = 'pessoas' THEN 'id' ELSE 'pessoa' END;
    filtro_aba := format('%I = %L', coluna_aba, 'eduarda');
    condicao_dono := format('(SELECT auth.uid()) = %L::uuid', usuario_victor);
    IF tabela = 'pessoas' THEN
      condicao_dono := condicao_dono || format(' AND dono = %L::uuid', usuario_victor);
    END IF;
    condicao_guard := format('(%I <> %L OR (%s))', coluna_aba, 'eduarda', condicao_dono);

    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', tabela);

    -- Mantem o comportamento de leitura das abas: contas autenticadas
    -- podem consultar Eduarda; somente Victor pode gravar nela.
    EXECUTE format('DROP POLICY IF EXISTS eduarda_leitura ON public.%I', tabela);
    EXECUTE format('CREATE POLICY eduarda_leitura ON public.%I FOR SELECT TO authenticated USING (%s)', tabela, filtro_aba);

    -- Permissao explicitamente limitada a Eduarda e ao UUID do Victor.
    -- Nao concede escrita nas abas de outras pessoas.
    EXECUTE format('DROP POLICY IF EXISTS eduarda_gestor ON public.%I', tabela);
    EXECUTE format(
      'CREATE POLICY eduarda_gestor ON public.%I FOR ALL TO authenticated USING (%s AND (%s)) WITH CHECK (%s AND (%s))',
      tabela, filtro_aba, condicao_dono, filtro_aba, condicao_dono
    );

    -- Guardas restritivas continuam bloqueando as demais contas mesmo
    -- quando existir outra politica permissiva mais ampla no projeto.
    EXECUTE format('DROP POLICY IF EXISTS eduarda_protecao_insert ON public.%I', tabela);
    EXECUTE format('CREATE POLICY eduarda_protecao_insert ON public.%I AS RESTRICTIVE FOR INSERT TO public WITH CHECK (%s)', tabela, condicao_guard);
    EXECUTE format('DROP POLICY IF EXISTS eduarda_protecao_update ON public.%I', tabela);
    EXECUTE format('CREATE POLICY eduarda_protecao_update ON public.%I AS RESTRICTIVE FOR UPDATE TO public USING (%s) WITH CHECK (%s)', tabela, condicao_guard, condicao_guard);
    EXECUTE format('DROP POLICY IF EXISTS eduarda_protecao_delete ON public.%I', tabela);
    EXECUTE format('CREATE POLICY eduarda_protecao_delete ON public.%I AS RESTRICTIVE FOR DELETE TO public USING (%s)', tabela, condicao_guard);
  END LOOP;
END
$eduarda$;
