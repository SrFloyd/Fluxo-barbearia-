-- BARBOSA BARBEARIA
-- Compatibilidade com o banco JÁ criado no projeto Supabase do usuário.
-- Usa public.shops, public.shop_members e public.transactions.
-- Não apaga tabelas nem movimentações existentes.

alter table public.shops enable row level security;
alter table public.shop_members enable row level security;
alter table public.transactions enable row level security;

-- A aplicação guarda os serviços selecionados como JSON.
alter table public.transactions
  add column if not exists services jsonb;

-- Permissões SQL para usuários autenticados.
revoke all on public.shops from anon;
revoke all on public.shop_members from anon;
revoke all on public.transactions from anon, authenticated;

grant select on public.shops, public.shop_members to authenticated;
grant select, insert, update, delete on public.transactions to authenticated;

-- Recria as políticas desta aplicação de forma idempotente.
drop policy if exists "members can view shop" on public.shops;
drop policy if exists "members can view own membership" on public.shop_members;
drop policy if exists "members can view transactions" on public.transactions;
drop policy if exists "owner can insert transactions" on public.transactions;
drop policy if exists "owner can update transactions" on public.transactions;
drop policy if exists "owner can delete transactions" on public.transactions;

create policy "members can view shop"
on public.shops
for select to authenticated
using (
  exists (
    select 1
    from public.shop_members m
    where m.shop_id = shops.id
      and m.user_id = (select auth.uid())
  )
);

-- Cada conta só pode consultar seu próprio vínculo.
create policy "members can view own membership"
on public.shop_members
for select to authenticated
using (user_id = (select auth.uid()));

-- Proprietário e sócio podem ler as movimentações da mesma barbearia.
create policy "members can view transactions"
on public.transactions
for select to authenticated
using (
  exists (
    select 1
    from public.shop_members m
    where m.shop_id = transactions.shop_id
      and m.user_id = (select auth.uid())
  )
);

-- Somente owner pode inserir.
create policy "owner can insert transactions"
on public.transactions
for insert to authenticated
with check (
  exists (
    select 1
    from public.shop_members m
    where m.shop_id = transactions.shop_id
      and m.user_id = (select auth.uid())
      and m.role = 'owner'
  )
);

-- Somente owner pode alterar.
create policy "owner can update transactions"
on public.transactions
for update to authenticated
using (
  exists (
    select 1
    from public.shop_members m
    where m.shop_id = transactions.shop_id
      and m.user_id = (select auth.uid())
      and m.role = 'owner'
  )
)
with check (
  exists (
    select 1
    from public.shop_members m
    where m.shop_id = transactions.shop_id
      and m.user_id = (select auth.uid())
      and m.role = 'owner'
  )
);

-- Somente owner pode excluir.
create policy "owner can delete transactions"
on public.transactions
for delete to authenticated
using (
  exists (
    select 1
    from public.shop_members m
    where m.shop_id = transactions.shop_id
      and m.user_id = (select auth.uid())
      and m.role = 'owner'
  )
);

-- Habilita atualização em tempo real, se ainda não estiver habilitada.
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'transactions'
  ) then
    alter publication supabase_realtime add table public.transactions;
  end if;
end $$;
