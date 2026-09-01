create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can view their own profile"
on public.profiles
for select
to authenticated
using (auth.uid() = id);


create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do update set email = excluded.email;

  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


alter table public.profiles
add column short_id text unique;

-- Streak tracking columns
alter table public.profiles
add column current_streak integer default 0,
add column longest_streak integer default 0,
add column last_streak_date timestamptz,
add column total_workouts integer default 0,
add column streak_activity_dates text[] default '{}';

-- Create activity_log table to track user activities
create table public.activity_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  activity_type text not null default 'workout',
  activity_date date not null default current_date,
  created_at timestamptz not null default now(),
  unique(user_id, activity_date)
);

alter table public.activity_log enable row level security;

create policy "Users can view their own activity log"
on public.activity_log
for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert their own activity log"
on public.activity_log
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update their own activity log"
on public.activity_log
for update
to authenticated
using (auth.uid() = user_id);

-- Function to update streak on activity
create or replace function public.update_streak_on_activity()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  v_current_streak integer;
  v_longest_streak integer;
  v_last_streak_date timestamptz;
  v_days_since_last integer;
  v_today_date date;
begin
  v_today_date := CURRENT_DATE;
  
  -- Get current user streak data
  select current_streak, longest_streak, last_streak_date
  into v_current_streak, v_longest_streak, v_last_streak_date
  from public.profiles
  where id = new.user_id;
  
  if v_current_streak is null then
    v_current_streak := 1;
    v_longest_streak := 1;
    v_last_streak_date := now();
  else
    -- Calculate days since last activity
    v_days_since_last := v_last_streak_date::date - v_today_date;
    
    if v_days_since_last = -1 then
      -- Consecutive day - increment streak
      v_current_streak := v_current_streak + 1;
      if v_current_streak > v_longest_streak then
        v_longest_streak := v_current_streak;
      end if;
    elsif v_days_since_last <= -2 then
      -- Streak broken - reset
      v_current_streak := 1;
    end if;
  end if;
  
  -- Update profile
  update public.profiles
  set 
    current_streak = v_current_streak,
    longest_streak = v_longest_streak,
    last_streak_date = now(),
    total_workouts = total_workouts + 1
  where id = new.user_id;
  
  return new;
end;
$$;

create trigger on_activity_created
  after insert on activity_log
  for each row execute function public.update_streak_on_activity();
