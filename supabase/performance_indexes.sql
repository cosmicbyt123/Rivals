-- ============================================================================
-- RIVALS FITNESS & GYM PLATFORM - PERFORMANCE INDEXES MIGRATION
-- High-throughput B-Tree & Composite Indexes for Fast Supabase & PostgreSQL Queries
-- ============================================================================

-- 1. GYM MEMBERSHIP & ROSTER QUERIES
CREATE INDEX IF NOT EXISTS idx_gym_members_gym_status 
    ON public.gym_members (gym_id, status);

CREATE INDEX IF NOT EXISTS idx_gym_members_user_id 
    ON public.gym_members (user_id);

CREATE INDEX IF NOT EXISTS idx_gym_members_assigned_trainer 
    ON public.gym_members (assigned_trainer_id) 
    WHERE assigned_trainer_id IS NOT NULL;

-- 2. WORKOUT SESSIONS & REALTIME LIVE TRAINING
CREATE INDEX IF NOT EXISTS idx_workout_sessions_gym_status 
    ON public.workout_sessions (gym_id, status);

CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_started 
    ON public.workout_sessions (user_id, started_at DESC);

-- 3. EXERCISE SETS
CREATE INDEX IF NOT EXISTS idx_exercise_sets_session_order 
    ON public.exercise_sets (session_id, set_number);

CREATE INDEX IF NOT EXISTS idx_exercise_sets_exercise_id 
    ON public.exercise_sets (exercise_id);

-- 4. FINANCIAL LEDGER & PAYMENTS
CREATE INDEX IF NOT EXISTS idx_payments_gym_status 
    ON public.payments (gym_id, status);

CREATE INDEX IF NOT EXISTS idx_payments_user_id 
    ON public.payments (user_id);

CREATE INDEX IF NOT EXISTS idx_payments_created_at 
    ON public.payments (created_at DESC);

-- 5. PERSONAL RECORDS & LEADERBOARD METRICS
CREATE INDEX IF NOT EXISTS idx_personal_records_user_exercise 
    ON public.personal_records (user_id, exercise_id);

-- 6. ACTIVE CHALLENGES & LEADERBOARDS
CREATE INDEX IF NOT EXISTS idx_challenges_gym_status 
    ON public.challenges (gym_id, status);

CREATE INDEX IF NOT EXISTS idx_challenge_participants_user 
    ON public.challenge_participants (user_id, challenge_id);

-- 7. NOTIFICATIONS (Filtered by user unread state)
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread 
    ON public.notifications (user_id, is_read, created_at DESC);

-- 8. USER MEMBERSHIPS & PLANS
CREATE INDEX IF NOT EXISTS idx_memberships_user_status 
    ON public.memberships (user_id, status);

CREATE INDEX IF NOT EXISTS idx_memberships_gym_id 
    ON public.memberships (gym_id);

-- 9. USER PROFILES
CREATE INDEX IF NOT EXISTS idx_profiles_home_gym 
    ON public.profiles (home_gym_id);

CREATE INDEX IF NOT EXISTS idx_profiles_role 
    ON public.profiles (role);
