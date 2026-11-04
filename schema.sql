-- QR Restaurant Manager: Supabase schema
create extension if not exists pgcrypto;

create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null default 'Staff',
 role text not null default 'staff' check (role in ('admin','staff')),
 created_at timestamptz not null default now()
);
create table if not exists public.menu_items (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 category text,
 price numeric(10,2) not null check(price >= 0),
 active boolean not null default true,
 created_at timestamptz not null default now()
);
create table if not exists public.orders (
 id uuid primary key default gen_random_uuid(),
 order_no bigint generated always as identity,
 order_type text not null check(order_type in ('dine_in','takeaway')),
 table_no text,
 customer_name text,
 customer_note text,
 payment_method text not null check(payment_method in ('cash','qr')),
 payment_status text not null default 'pending' check(payment_status in ('pending','paid','refunded')),
 status text not null default 'new' check(status in ('new','preparing','ready','completed','cancelled')),
 total numeric(10,2) not null check(total >= 0),
 created_at timestamptz not null default now()
);
create table if not exists public.order_items (
 id uuid primary key default gen_random_uuid(),
 order_id uuid not null references public.orders(id) on delete cascade,
 menu_item_id uuid references public.menu_items(id),
 item_name text not null,
 unit_price numeric(10,2) not null,
 quantity integer not null check(quantity > 0),
 line_total numeric(10,2) not null
);
create table if not exists public.expenses (
 id uuid primary key default gen_random_uuid(),
 description text not null,
 amount numeric(10,2) not null check(amount > 0),
 payment_method text not null check(payment_method in ('cash','qr')),
 staff_name text,
 created_at timestamptz not null default now()
);
create table if not exists public.closings (
 id uuid primary key default gen_random_uuid(),
 expected_cash numeric(10,2) not null,
 actual_cash numeric(10,2) not null,
 cash_variance numeric(10,2) not null,
 expected_qr numeric(10,2) not null,
 actual_qr numeric(10,2) not null,
 qr_variance numeric(10,2) not null,
 staff_name text,
 note text,
 created_at timestamptz not null default now()
);
create table if not exists public.audit_logs (
 id uuid primary key default gen_random_uuid(),
 action text not null,
 record_id uuid,
 details jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.menu_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.expenses enable row level security;
alter table public.closings enable row level security;
alter table public.audit_logs enable row level security;

-- Authenticated users can use the internal dashboard.
create policy "profiles_read_authenticated" on public.profiles for select to authenticated using (true);
create policy "menu_read_all" on public.menu_items for select using (true);
create policy "menu_write_authenticated" on public.menu_items for all to authenticated using (true) with check (true);
create policy "orders_read_authenticated" on public.orders for select to authenticated using (true);
create policy "orders_insert_public" on public.orders for insert to anon, authenticated with check (true);
create policy "orders_update_authenticated" on public.orders for update to authenticated using (true) with check (true);
create policy "items_read_authenticated" on public.order_items for select to authenticated using (true);
create policy "items_insert_public" on public.order_items for insert to anon, authenticated with check (true);
create policy "expenses_all_authenticated" on public.expenses for all to authenticated using (true) with check (true);
create policy "closings_all_authenticated" on public.closings for all to authenticated using (true) with check (true);
create policy "audit_insert_any" on public.audit_logs for insert to anon, authenticated with check (true);
create policy "audit_read_authenticated" on public.audit_logs for select to authenticated using (true);

-- IMPORTANT SECURITY NOTE:
-- This starter policy set is for initial testing. Before public launch, replace
-- permissive policies with stricter role-based policies and server-side order
-- creation/payment verification. Do not expose service_role keys in the browser.
