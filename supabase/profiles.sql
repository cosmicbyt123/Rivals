create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  avatar_url text,
  short_id text unique,
  current_streak integer not null default 0,
  longest_streak integer not null default 0,
  last_streak_date timestamptz,
  total_workouts integer not null default 0,
  streak_activity_dates text[] not null default '{}',
  xp integer not null default 0,
  total_volume numeric not null default 0,
  calories_burned integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.profiles add column if not exists full_name text;
alter table public.profiles add column if not exists avatar_url text;
alter table public.profiles add column if not exists short_id text unique;
alter table public.profiles add column if not exists current_streak integer not null default 0;
alter table public.profiles add column if not exists longest_streak integer not null default 0;
alter table public.profiles add column if not exists last_streak_date timestamptz;
alter table public.profiles add column if not exists total_workouts integer not null default 0;
alter table public.profiles add column if not exists streak_activity_dates text[] not null default '{}';
alter table public.profiles add column if not exists xp integer not null default 0;
alter table public.profiles add column if not exists total_volume numeric not null default 0;
alter table public.profiles add column if not exists calories_burned integer not null default 0;

create table if not exists public.workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  workout_name text not null default 'Push Day',
  status text not null default 'completed' check (status in ('planned', 'in_progress', 'completed')),
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists workout_sessions_user_completed_idx
  on public.workout_sessions (user_id, completed_at);

create table if not exists public.challenges (
  user_id uuid primary key references auth.users(id) on delete cascade,
  challenge_name text not null default '100 Push-ups vs Rahul',
  user_reps integer not null default 0 check (user_reps >= 0),
  opponent_reps integer not null default 0 check (opponent_reps >= 0),
  target_reps integer not null default 100 check (target_reps > 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.activity_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  activity_type text not null default 'workout',
  activity_date date not null default current_date,
  created_at timestamptz not null default now(),
  unique(user_id, activity_date)
);

alter table public.profiles enable row level security;
alter table public.workout_sessions enable row level security;
alter table public.challenges enable row level security;
alter table public.activity_log enable row level security;

drop policy if exists "Users can view their own profile" on public.profiles;
drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can view their own profile"
  on public.profiles for select to authenticated using (auth.uid() = id);
create policy "Users can update their own profile"
  on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "Users can view their own workout sessions" on public.workout_sessions;
drop policy if exists "Users can insert their own workout sessions" on public.workout_sessions;
create policy "Users can view their own workout sessions"
  on public.workout_sessions for select to authenticated using (auth.uid() = user_id);
create policy "Users can insert their own workout sessions"
  on public.workout_sessions for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "Users can view their own challenge" on public.challenges;
drop policy if exists "Users can insert or update their own challenge" on public.challenges;
drop policy if exists "Users can update their own challenge" on public.challenges;
create policy "Users can view their own challenge"
  on public.challenges for select to authenticated using (auth.uid() = user_id);
create policy "Users can insert or update their own challenge"
  on public.challenges for insert to authenticated with check (auth.uid() = user_id);
create policy "Users can update their own challenge"
  on public.challenges for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users can view their own activity log" on public.activity_log;
drop policy if exists "Users can insert their own activity log" on public.activity_log;
create policy "Users can view their own activity log"
  on public.activity_log for select to authenticated using (auth.uid() = user_id);
create policy "Users can insert their own activity log"
  on public.activity_log for insert to authenticated with check (auth.uid() = user_id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, coalesce(new.email, ''), coalesce(new.raw_user_meta_data ->> 'full_name', split_part(coalesce(new.email, 'User'), '@', 1)))
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
