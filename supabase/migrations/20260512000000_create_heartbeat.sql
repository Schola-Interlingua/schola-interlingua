-- Dedicated heartbeat table for a minimal GitHub Actions write that helps
-- prevent Supabase Free inactivity pauses.
create table if not exists public.heartbeat (
  id text primary key,
  last_seen_at timestamptz not null default now(),
  updated_by text not null default 'github-actions'
);

comment on table public.heartbeat is
  'Single-row technical heartbeat updated by GitHub Actions to keep Supabase Free active.';

alter table public.heartbeat enable row level security;

revoke all on table public.heartbeat from anon;
revoke all on table public.heartbeat from authenticated;

notify pgrst, 'reload schema';
