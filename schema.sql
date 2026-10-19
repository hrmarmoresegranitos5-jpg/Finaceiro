-- Rode no Supabase: SQL Editor > New query > Run

create table if not exists public.gastos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  valor numeric(12,2) not null check (valor > 0),
  categoria text not null default 'Outros',
  descricao text,
  data date not null default current_date,
  origem text not null default 'app',   -- 'app' ou 'whatsapp'
  criado_em timestamptz not null default now()
);

create index if not exists gastos_user_data_idx on public.gastos (user_id, data desc);

-- Cada usuário só enxerga e altera os próprios gastos.
alter table public.gastos enable row level security;

create policy "gastos_select" on public.gastos for select using (user_id = auth.uid());
create policy "gastos_insert" on public.gastos for insert with check (user_id = auth.uid());
create policy "gastos_update" on public.gastos for update using (user_id = auth.uid());
create policy "gastos_delete" on public.gastos for delete using (user_id = auth.uid());

-- Atualização ao vivo no app quando o bot salvar um gasto.
alter publication supabase_realtime add table public.gastos;

-- O bot grava com a chave service_role (ignora RLS) informando o seu user_id
-- (Authentication > Users > copie o UID do seu usuário).
