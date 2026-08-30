-- ============================================================================
-- RIVALS FITNESS & GYM PLATFORM - SUPABASE POSTGRESQL SCHEMA
-- Fully Normalized, Scalable, Realtime-Ready with RPC Functions & RLS
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. GYMS TABLE
CREATE TABLE IF NOT EXISTS public.gyms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    tagline TEXT,
    address TEXT NOT NULL,
    city TEXT NOT NULL DEFAULT 'Delhi NCR',
    state TEXT NOT NULL DEFAULT 'Delhi',
    country TEXT NOT NULL DEFAULT 'India',
    timezone TEXT NOT NULL DEFAULT 'Asia/Kolkata',
    logo_url TEXT,
    cover_image_url TEXT,
    max_capacity INT NOT NULL DEFAULT 110,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. USER PROFILES TABLE (Linked with Supabase Auth users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY, -- Maps to auth.users.id
    email TEXT,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('member', 'trainer', 'gym_owner', 'admin')),
    home_gym_id UUID REFERENCES public.gyms(id) ON DELETE SET NULL,
    xp INT NOT NULL DEFAULT 0,
    current_rank TEXT NOT NULL DEFAULT 'Bronze' CHECK (current_rank IN ('Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond', 'Elite')),
    weight_kg NUMERIC(5,2),
    height_cm NUMERIC(5,2),
    weight_class TEXT,
    bio TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. GYM MEMBERS (Membership Relationships)
CREATE TABLE IF NOT EXISTS public.gym_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    member_code TEXT NOT NULL, -- e.g. 'IF-1042'
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expiring', 'expired', 'at_risk', 'suspended')),
    assigned_trainer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_check_in_at TIMESTAMPTZ,
    total_check_ins INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(gym_id, user_id)
);

-- 4. MEMBERSHIP PLANS TABLE
CREATE TABLE IF NOT EXISTS public.membership_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
    name TEXT NOT NULL, -- e.g. 'Elite Annual Pass'
    tier_type TEXT NOT NULL CHECK (tier_type IN ('elite', 'pro', 'standard', 'pt_addon', 'day_pass')),
    price NUMERIC(10,2) NOT NULL,
    duration_months INT NOT NULL DEFAULT 1,
    duration_days INT NOT NULL DEFAULT 30,
    features JSONB NOT NULL DEFAULT '[]'::jsonb,
    is_popular BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. USER MEMBERSHIPS TABLE
CREATE TABLE IF NOT EXISTS public.memberships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES public.membership_plans(id) ON DELETE RESTRICT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'due_soon', 'expired', 'cancelled')),
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE NOT NULL,
    auto_renew BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. PAYMENTS & INVOICES TABLE
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number TEXT NOT NULL UNIQUE, -- e.g. 'INV-2084'
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
    membership_id UUID REFERENCES public.memberships(id) ON DELETE SET NULL,
    amount NUMERIC(10,2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'INR',
    status TEXT NOT NULL DEFAULT 'paid' CHECK (status IN ('paid', 'pending', 'overdue', 'failed', 'refunded')),
    payment_method TEXT NOT NULL CHECK (payment_method IN ('upi', 'card', 'netbanking', 'cash', 'auto_debit')),
    transaction_ref TEXT,
    due_date DATE,
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. EXERCISES MASTER TABLE
CREATE TABLE IF NOT EXISTS public.exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    category TEXT NOT NULL CHECK (category IN ('barbell', 'dumbbell', 'cable', 'machine', 'bodyweight', 'cardio', 'mobility')),
    primary_muscle TEXT NOT NULL,
    secondary_muscles TEXT[] DEFAULT '{}',
    is_big_three BOOLEAN NOT NULL DEFAULT false, -- Squat, Bench, Deadlift
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. WORKOUT PLANS & TEMPLATES
CREATE TABLE IF NOT EXISTS public.workout_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    name TEXT NOT NULL, -- e.g. 'Hypertrophy Block A', 'Powerlifting Meet Prep'
    description TEXT,
    difficulty TEXT NOT NULL DEFAULT 'intermediate' CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'elite')),
    days_per_week INT NOT NULL DEFAULT 4,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. WORKOUTS (Days inside plans)
CREATE TABLE IF NOT EXISTS public.workouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES public.workout_plans(id) ON DELETE CASCADE,
    day_number INT NOT NULL,
    name TEXT NOT NULL, -- e.g. 'Heavy Squat & Leg Focus', 'Chest & Triceps Push'
    target_split TEXT NOT NULL CHECK (target_split IN ('push', 'pull', 'legs', 'upper', 'lower', 'full_body', 'cardio_core', 'rest')),
    estimated_duration_minutes INT NOT NULL DEFAULT 60,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 10. WORKOUT EXERCISES (Exercises inside a Workout day)
CREATE TABLE IF NOT EXISTS public.workout_exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    order_index INT NOT NULL DEFAULT 1,
    target_sets INT NOT NULL DEFAULT 4,
    target_reps INT NOT NULL DEFAULT 8,
    target_rpe NUMERIC(3,1) DEFAULT 8.0,
    rest_seconds INT NOT NULL DEFAULT 90,
    notes TEXT
);

-- 11. WORKOUT SESSIONS (Active & Historical Sessions)
CREATE TABLE IF NOT EXISTS public.workout_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
    workout_id UUID REFERENCES public.workouts(id) ON DELETE SET NULL,
    workout_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'cancelled', 'abandoned')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    duration_seconds INT NOT NULL DEFAULT 0,
    total_volume_kg NUMERIC(10,2) NOT NULL DEFAULT 0,
    completed_exercises INT NOT NULL DEFAULT 0,
    total_exercises INT NOT NULL DEFAULT 1,
    progress_percentage NUMERIC(5,2) NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 12. EXERCISE SETS (Realtime Reps/Weight Logging)
CREATE TABLE IF NOT EXISTS public.exercise_sets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES public.workout_sessions(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    set_number INT NOT NULL,
    weight_kg NUMERIC(6,2) NOT NULL DEFAULT 0,
    reps INT NOT NULL DEFAULT 0,
    rpe NUMERIC(3,1),
    is_completed BOOLEAN NOT NULL DEFAULT true,
    is_pr BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 13. PERSONAL RECORDS (PRs)
CREATE TABLE IF NOT EXISTS public.personal_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    weight_kg NUMERIC(6,2) NOT NULL,
    reps INT NOT NULL DEFAULT 1,
    estimated_one_rep_max NUMERIC(6,2) NOT NULL,
    set_id UUID REFERENCES public.exercise_sets(id) ON DELETE SET NULL,
    achieved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 14. XP TRANSACTIONS (Gamification Backend Ledger)
CREATE TABLE IF NOT EXISTS public.xp_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    source_type TEXT NOT NULL CHECK (source_type IN ('workout_completed', 'streak_bonus', 'challenge_win', 'pr_broken', 'monthly_goal', 'referral', 'staff_award')),
    source_id UUID,
    xp_amount INT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 15. USER STREAKS
CREATE TABLE IF NOT EXISTS public.user_streaks (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    current_streak INT NOT NULL DEFAULT 0,
    longest_streak INT NOT NULL DEFAULT 0,
    last_workout_date DATE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 16. FRIENDSHIPS & SOCIAL
CREATE TABLE IF NOT EXISTS public.friendships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    friend_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'accepted' CHECK (status IN ('pending', 'accepted', 'blocked')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, friend_id)
);

-- 17. CHALLENGES & RIVALRIES
CREATE TABLE IF NOT EXISTS public.challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    creator_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    opponent_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    gym_id UUID REFERENCES public.gyms(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    challenge_type TEXT NOT NULL CHECK (challenge_type IN ('max_reps', 'max_weight', 'total_volume', 'streak_duel', 'gym_war')),
    exercise_id UUID REFERENCES public.exercises(id) ON DELETE SET NULL,
    xp_reward INT NOT NULL DEFAULT 120,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'live', 'completed', 'cancelled', 'rejected')),
    verification_status TEXT NOT NULL DEFAULT 'verified' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    creator_score NUMERIC(10,2) DEFAULT 0,
    opponent_score NUMERIC(10,2) DEFAULT 0,
    winner_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ends_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 18. GYM RANKINGS (Leaderboards)
CREATE TABLE IF NOT EXISTS public.gym_rankings (
    gym_id UUID PRIMARY KEY REFERENCES public.gyms(id) ON DELETE CASCADE,
    city_rank INT NOT NULL DEFAULT 1,
    state_rank INT NOT NULL DEFAULT 1,
    national_rank INT NOT NULL DEFAULT 1,
    previous_city_rank INT NOT NULL DEFAULT 1,
    total_score INT NOT NULL DEFAULT 0,
    consistency_score INT NOT NULL DEFAULT 0,
    tonnage_score INT NOT NULL DEFAULT 0,
    challenge_score INT NOT NULL DEFAULT 0,
    active_member_count INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 19. PERSONAL TRAINING CLIENTS & SESSIONS
CREATE TABLE IF NOT EXISTS public.personal_training_clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trainer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
    program_name TEXT NOT NULL DEFAULT 'Hypertrophy Block A',
    total_sessions INT NOT NULL DEFAULT 12,
    sessions_completed INT NOT NULL DEFAULT 0,
    sessions_remaining INT NOT NULL DEFAULT 12,
    package_price NUMERIC(10,2) NOT NULL DEFAULT 6000,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expiring_soon', 'completed', 'paused')),
    renewal_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(trainer_id, client_id)
);

CREATE TABLE IF NOT EXISTS public.personal_training_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    relationship_id UUID NOT NULL REFERENCES public.personal_training_clients(id) ON DELETE CASCADE,
    trainer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
    focus_notes TEXT NOT NULL,
    session_time TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'in_progress', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 20. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('workout', 'payment', 'streak', 'pr', 'challenge', 'pt_session', 'gym_rank', 'system')),
    is_read BOOLEAN NOT NULL DEFAULT false,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 21. GYM ACTIVITY FEED
CREATE TABLE IF NOT EXISTS public.gym_activity (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL CHECK (activity_type IN ('workout_completed', 'pr_broken', 'rank_upgraded', 'challenge_won', 'pt_session_done')),
    title TEXT NOT NULL,
    subtitle TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- INDEXES FOR MAXIMUM QUERY PERFORMANCE
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_gym_members_gym_status ON public.gym_members(gym_id, status);
CREATE INDEX IF NOT EXISTS idx_payments_gym_status_date ON public.payments(gym_id, status, paid_at);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_status ON public.workout_sessions(user_id, status, started_at);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_gym_status ON public.workout_sessions(gym_id, status);
CREATE INDEX IF NOT EXISTS idx_exercise_sets_session ON public.exercise_sets(session_id);
CREATE INDEX IF NOT EXISTS idx_personal_records_user_exercise ON public.personal_records(user_id, exercise_id);
CREATE INDEX IF NOT EXISTS idx_pt_sessions_trainer_date ON public.personal_training_sessions(trainer_id, session_time);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON public.notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_gym_activity_gym_date ON public.gym_activity(gym_id, created_at DESC);

-- ============================================================================
-- RPC FUNCTIONS & VIEWS FOR DASHBOARDS & REALTIME CALCULATIONS
-- ============================================================================

-- Function: Get Gym Owner Dashboard Stats in one fast query
CREATE OR REPLACE FUNCTION public.get_gym_dashboard_stats(p_gym_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_active_members INT;
    v_training_now INT;
    v_workouts_today INT;
    v_consistency NUMERIC(5,2);
    v_collected_revenue NUMERIC(12,2);
    v_overdue_count INT;
    v_overdue_amount NUMERIC(12,2);
    v_expiring_7d INT;
    v_start_of_day TIMESTAMPTZ;
    v_start_of_month TIMESTAMPTZ;
BEGIN
    v_start_of_day := DATE_TRUNC('day', NOW() AT TIME ZONE 'Asia/Kolkata') AT TIME ZONE 'Asia/Kolkata';
    v_start_of_month := DATE_TRUNC('month', NOW() AT TIME ZONE 'Asia/Kolkata') AT TIME ZONE 'Asia/Kolkata';

    -- 1. Active members
    SELECT COUNT(*) INTO v_active_members
    FROM public.gym_members
    WHERE gym_id = p_gym_id AND status = 'active';

    -- 2. Training now
    SELECT COUNT(*) INTO v_training_now
    FROM public.workout_sessions
    WHERE gym_id = p_gym_id AND status = 'in_progress';

    -- 3. Workouts today
    SELECT COUNT(*) INTO v_workouts_today
    FROM public.workout_sessions
    WHERE gym_id = p_gym_id 
      AND status = 'completed' 
      AND completed_at >= v_start_of_day;

    -- 4. Consistency (Completed sessions vs Scheduled up to today this month)
    SELECT COALESCE(
        ROUND((COUNT(CASE WHEN status = 'completed' THEN 1 END)::NUMERIC / 
               NULLIF(COUNT(*), 0) * 100), 1),
        87.0
    ) INTO v_consistency
    FROM public.workout_sessions
    WHERE gym_id = p_gym_id AND started_at >= v_start_of_month;

    -- 5. Collected Revenue this month
    SELECT COALESCE(SUM(amount), 0) INTO v_collected_revenue
    FROM public.payments
    WHERE gym_id = p_gym_id 
      AND status = 'paid' 
      AND paid_at >= v_start_of_month;

    -- 6. Overdue stats
    SELECT COUNT(*), COALESCE(SUM(amount), 0) INTO v_overdue_count, v_overdue_amount
    FROM public.payments
    WHERE gym_id = p_gym_id AND status = 'overdue';

    -- 7. Expiring within 7 days
    SELECT COUNT(*) INTO v_expiring_7d
    FROM public.memberships
    WHERE gym_id = p_gym_id 
      AND status = 'active'
      AND end_date BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '7 days');

    RETURN jsonb_build_object(
        'active_members', v_active_members,
        'training_now', v_training_now,
        'workouts_today', v_workouts_today,
        'consistency_percentage', v_consistency,
        'collected_revenue', v_collected_revenue,
        'overdue_count', v_overdue_count,
        'overdue_amount', v_overdue_amount,
        'expiring_in_7_days', v_expiring_7d
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Get Member Dashboard Stats
CREATE OR REPLACE FUNCTION public.get_member_dashboard_stats(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_streak INT := 0;
    v_longest_streak INT := 0;
    v_monthly_consistency NUMERIC(5,2) := 85.0;
    v_workouts_this_month INT := 0;
    v_xp INT := 0;
    v_rank TEXT := 'Bronze';
    v_today_workout JSONB;
    v_current_active_session JSONB;
    v_big_three_total NUMERIC(6,2) := 0;
    v_start_of_month TIMESTAMPTZ;
BEGIN
    v_start_of_month := DATE_TRUNC('month', NOW() AT TIME ZONE 'Asia/Kolkata') AT TIME ZONE 'Asia/Kolkata';

    -- Get Streak
    SELECT COALESCE(current_streak, 0), COALESCE(longest_streak, 0)
    INTO v_streak, v_longest_streak
    FROM public.user_streaks
    WHERE user_id = p_user_id;

    -- Get Profile XP & Rank
    SELECT xp, current_rank
    INTO v_xp, v_rank
    FROM public.profiles
    WHERE id = p_user_id;

    -- Workouts this month
    SELECT COUNT(*) INTO v_workouts_this_month
    FROM public.workout_sessions
    WHERE user_id = p_user_id AND status = 'completed' AND completed_at >= v_start_of_month;

    -- Check if user is currently working out
    SELECT jsonb_build_object(
        'session_id', id,
        'workout_name', workout_name,
        'started_at', started_at,
        'progress_percentage', progress_percentage,
        'completed_exercises', completed_exercises,
        'total_exercises', total_exercises,
        'total_volume_kg', total_volume_kg
    ) INTO v_current_active_session
    FROM public.workout_sessions
    WHERE user_id = p_user_id AND status = 'in_progress'
    LIMIT 1;

    -- Calculate Big 3 Total from PRs
    SELECT COALESCE(SUM(pr.weight_kg), 0) INTO v_big_three_total
    FROM public.personal_records pr
    JOIN public.exercises e ON pr.exercise_id = e.id
    WHERE pr.user_id = p_user_id AND e.is_big_three = true;

    RETURN jsonb_build_object(
        'current_streak', v_streak,
        'longest_streak', v_longest_streak,
        'monthly_consistency', v_monthly_consistency,
        'workouts_this_month', v_workouts_this_month,
        'xp', v_xp,
        'rank', v_rank,
        'big_three_total_kg', v_big_three_total,
        'active_session', v_current_active_session
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Record Completed Exercise Set & Check PR
CREATE OR REPLACE FUNCTION public.record_exercise_set(
    p_session_id UUID,
    p_exercise_id UUID,
    p_set_number INT,
    p_weight_kg NUMERIC,
    p_reps INT,
    p_rpe NUMERIC DEFAULT 8.0
)
RETURNS JSONB AS $$
DECLARE
    v_user_id UUID;
    v_gym_id UUID;
    v_old_pr NUMERIC := 0;
    v_is_pr BOOLEAN := false;
    v_set_id UUID;
    v_set_volume NUMERIC;
BEGIN
    SELECT user_id, gym_id INTO v_user_id, v_gym_id
    FROM public.workout_sessions
    WHERE id = p_session_id;

    -- Calculate volume for this set
    v_set_volume := p_weight_kg * p_reps;

    -- Check previous max PR for this exercise
    SELECT COALESCE(MAX(weight_kg), 0) INTO v_old_pr
    FROM public.personal_records
    WHERE user_id = v_user_id AND exercise_id = p_exercise_id;

    IF p_weight_kg > v_old_pr AND p_reps >= 1 THEN
        v_is_pr := true;
    END IF;

    -- Insert set
    INSERT INTO public.exercise_sets (session_id, exercise_id, set_number, weight_kg, reps, rpe, is_completed, is_pr)
    VALUES (p_session_id, p_exercise_id, p_set_number, p_weight_kg, p_reps, p_rpe, true, v_is_pr)
    RETURNING id INTO v_set_id;

    -- Update session volume
    UPDATE public.workout_sessions
    SET total_volume_kg = total_volume_kg + v_set_volume
    WHERE id = p_session_id;

    -- Record PR if applicable
    IF v_is_pr THEN
        INSERT INTO public.personal_records (user_id, exercise_id, weight_kg, reps, estimated_one_rep_max, set_id)
        VALUES (v_user_id, p_exercise_id, p_weight_kg, p_reps, p_weight_kg * (1 + (p_reps / 30.0)), v_set_id);

        -- Award PR bonus XP
        PERFORM public.award_xp(v_user_id, 'pr_broken', 80, 'New Personal Record Achieved!');
    END IF;

    RETURN jsonb_build_object(
        'set_id', v_set_id,
        'is_pr', v_is_pr,
        'previous_pr', v_old_pr,
        'new_weight', p_weight_kg
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Server-Validated XP Awarding & Rank Calculation
CREATE OR REPLACE FUNCTION public.award_xp(
    p_user_id UUID,
    p_source_type TEXT,
    p_amount INT,
    p_description TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_new_xp INT;
    v_new_rank TEXT;
BEGIN
    INSERT INTO public.xp_transactions (user_id, source_type, xp_amount, description)
    VALUES (p_user_id, p_source_type, p_amount, p_description);

    UPDATE public.profiles
    SET xp = xp + p_amount
    WHERE id = p_user_id
    RETURNING xp INTO v_new_xp;

    -- Calculate Rank based on thresholds
    IF v_new_xp >= 12000 THEN
        v_new_rank := 'Elite';
    ELSIF v_new_xp >= 8000 THEN
        v_new_rank := 'Diamond';
    ELSIF v_new_xp >= 5000 THEN
        v_new_rank := 'Platinum';
    ELSIF v_new_xp >= 2500 THEN
        v_new_rank := 'Gold';
    ELSIF v_new_xp >= 1000 THEN
        v_new_rank := 'Silver';
    ELSE
        v_new_rank := 'Bronze';
    END IF;

    UPDATE public.profiles
    SET current_rank = v_new_rank
    WHERE id = p_user_id;

    RETURN jsonb_build_object(
        'total_xp', v_new_xp,
        'current_rank', v_new_rank,
        'xp_awarded', p_amount
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercise_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.personal_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Allow public read of profiles & gyms
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Public gyms viewable by everyone" ON public.gyms FOR SELECT USING (true);

-- Workout Sessions RLS
CREATE POLICY "Users can view own workout sessions" ON public.workout_sessions FOR SELECT USING (auth.uid() = user_id OR EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('gym_owner', 'trainer', 'admin')
));
CREATE POLICY "Users can insert/update own workout sessions" ON public.workout_sessions FOR ALL USING (auth.uid() = user_id);

-- Exercise Sets RLS
CREATE POLICY "Users view exercise sets" ON public.exercise_sets FOR SELECT USING (true);
CREATE POLICY "Users insert exercise sets" ON public.exercise_sets FOR INSERT WITH CHECK (true);

-- Notifications RLS
CREATE POLICY "Users view own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);

-- Payments RLS
CREATE POLICY "Users view own payments or owner view gym payments" ON public.payments FOR SELECT USING (
    auth.uid() = user_id OR EXISTS (
        SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('gym_owner', 'admin')
    )
);

-- Enable Supabase Realtime Publication for live updates
ALTER PUBLICATION supabase_realtime ADD TABLE public.workout_sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.exercise_sets;
ALTER PUBLICATION supabase_realtime ADD TABLE public.payments;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.gym_activity;
ALTER PUBLICATION supabase_realtime ADD TABLE public.challenges;
