create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text,
  workspace_type text check (workspace_type in ('personal','team')),
  plan text not null default 'trial' check (plan in ('trial','personal_pro','team')),
  trial_ends_at timestamptz not null default (now() + interval '14 days'),
  stripe_customer_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table profiles enable row level security;
create policy "profiles_owner_read" on profiles for select using (auth.uid() = id);
create policy "profiles_owner_update" on profiles for update using (auth.uid() = id) with check (auth.uid() = id);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into profiles (id,email,display_name)
  values (new.id,new.email,coalesce(new.raw_user_meta_data->>'display_name',split_part(new.email,'@',1)))
  on conflict (id) do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function handle_new_user();
insert into profiles(id,email,display_name)
select id,email,coalesce(raw_user_meta_data->>'display_name',split_part(email,'@',1)) from auth.users
on conflict(id) do nothing;

create table if not exists subscriptions (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  stripe_customer_id text,
  status text not null,
  price_id text,
  current_period_end timestamptz,
  cancel_at_period_end boolean not null default false,
  updated_at timestamptz not null default now()
);
alter table subscriptions enable row level security;
create policy "subscriptions_owner_read" on subscriptions for select using (auth.uid()=user_id);
