-- ============================================================================
-- RIVALS FITNESS & GYM PLATFORM - SUPABASE SEED DATA
-- Populates Gyms, Athletes, Trainers, Workouts, Sessions, Payments, Rankings
-- ============================================================================

-- 1. SEED GYMS
INSERT INTO public.gyms (id, name, slug, tagline, address, city, state, timezone, max_capacity)
VALUES 
('11111111-1111-1111-1111-111111111111', 'Iron Forge Fitness', 'iron-forge', 'Elite Powerlifting & Strength Arena', 'Hauz Khas, Sector 3', 'Delhi NCR', 'Delhi', 'Asia/Kolkata', 110),
('22222222-2222-2222-2222-222222222222', 'Titan Strength Arena', 'titan-strength', 'Defending City Champions', 'Connaught Place, Block B', 'Delhi NCR', 'Delhi', 'Asia/Kolkata', 150),
('33333333-3333-3333-3333-333333333333', 'Olympus Barbell Club', 'olympus-barbell', 'Olympic Lifting & Conditioning', 'Gurugram Sector 29', 'Delhi NCR', 'Haryana', 'Asia/Kolkata', 120)
ON CONFLICT (id) DO NOTHING;

-- 2. SEED PROFILES (Owner, Trainers, Members)
INSERT INTO public.profiles (id, email, full_name, role, home_gym_id, xp, current_rank, weight_kg, height_cm, weight_class, avatar_url)
VALUES
-- Gym Owner: Rahul
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'owner@ironforge.com', 'Rahul (Gym Owner)', 'gym_owner', '11111111-1111-1111-1111-111111111111', 14500, 'Elite', 85.0, 180.0, '93kg', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCYbtPGXiEBX4T5zIDKQAdI_lgNRqH86r8BBUzXGhK1zMaiP2yqC1rlGxeQ4T7HpxidJdYjsJvyQRzc6L2PHCU0PnXwVbV3q4Nnt1p9LvknNJzK_9EXO-CeCrPlQdDGg3Xk-2aPBjBfTE-j8sUKQlTKZ6a58m9RC9RS4h7YXlkeFehaHE7zMw8O6OUA7zpAzhKCGUygP3Ai10XVZds3XT2JCpLG4ddgtCVjl69wW0rSzak9WM7JlHUK'),
-- Head Trainer: Vikram Rathore
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'vikram@ironforge.com', 'Coach Vikram Rathore', 'trainer', '11111111-1111-1111-1111-111111111111', 9800, 'Diamond', 88.0, 182.0, '93kg', NULL),
-- Functional Coach: Ananya Roy
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'ananya@ironforge.com', 'Coach Ananya Roy', 'trainer', '11111111-1111-1111-1111-111111111111', 8600, 'Diamond', 60.0, 168.0, '63kg', NULL),
-- Top Athlete 1: Arjun Verma
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'arjun@gmail.com', 'Arjun Verma', 'member', '11111111-1111-1111-1111-111111111111', 6400, 'Platinum', 82.5, 178.0, '83kg', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCCO3m4vbKxcQlPsPGxMF6cc-5OTfVPWq4WQmvwPEOeB0jS5d8WSbplaPKKImNe6FT9qADhpPeUvVwu-vRd4lEmq-IcyiRoOR0156ruYkU-6ybNUoSqf-G0yvyucQWgkpTduchOYdjm50j58aYc-pkh9szuvQZxtDPtfa-TaASHvrqVU3_NFmq7hTS7RYyrRL8f4WNnSBpMJDAFWiOHa3rkGNK8f0BVHwbwXe7Tz8iyrP2OvlqIEdKP'),
-- Top Athlete 2: Rahul Sen
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'rahulsen@gmail.com', 'Rahul Sen', 'member', '11111111-1111-1111-1111-111111111111', 4800, 'Gold', 92.0, 185.0, '93kg', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAOnohnDs5IkwGmNrst3AclC_veosAq_oo6-hOrNGaxMp4SAiFB9e8zRQz6-_ZhDqrpWNYUbDZ6o_K1pwvquhKR83UM0AdzQ3xlEKGRof91vxtWgINERS0a61Gv3yz1Bzi8Yka5es6qaaIsDhpib7bg9qd-IWrjMa3x2BlTQFbEypmUPHySekVQOQEIlJEjbtHVtxIiEoNcfrE9tvT_1CKDecO0rzqOohvjEchzH4CGcu4kZmvLjCN5'),
-- Top Athlete 3: Tanya Malik
('ffffffff-ffff-ffff-ffff-ffffffffffff', 'tanya@gmail.com', 'Tanya Malik', 'member', '11111111-1111-1111-1111-111111111111', 3900, 'Gold', 62.0, 165.0, '63kg', NULL),
-- Member 4: Devansh Chawla
('10101010-1010-1010-1010-101010101010', 'devansh@gmail.com', 'Devansh Chawla', 'member', '11111111-1111-1111-1111-111111111111', 2800, 'Gold', 73.5, 172.0, '74kg', NULL),
-- Member 5: Kavita Nair
('20202020-2020-2020-2020-202020202020', 'kavita@gmail.com', 'Kavita Nair', 'member', '11111111-1111-1111-1111-111111111111', 3200, 'Gold', 56.0, 160.0, '57kg', NULL)
ON CONFLICT (id) DO NOTHING;

-- 3. SEED GYM MEMBERS
INSERT INTO public.gym_members (gym_id, user_id, member_code, status, assigned_trainer_id, total_check_ins)
VALUES
('11111111-1111-1111-1111-111111111111', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'IF-1042', 'active', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 84),
('11111111-1111-1111-1111-111111111111', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'IF-1088', 'active', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 72),
('11111111-1111-1111-1111-111111111111', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 'IF-1120', 'active', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 65),
('11111111-1111-1111-1111-111111111111', '10101010-1010-1010-1010-101010101010', 'IF-1154', 'expiring', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 42),
('11111111-1111-1111-1111-111111111111', '20202020-2020-2020-2020-202020202020', 'IF-1192', 'active', NULL, 95)
ON CONFLICT (gym_id, user_id) DO NOTHING;

-- 4. SEED MEMBERSHIP PLANS
INSERT INTO public.membership_plans (id, gym_id, name, tier_type, price, duration_months, duration_days, features, is_popular)
VALUES
('p1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Elite Annual Pass', 'elite', 24000, 12, 365, '["All Gym Access 24/7", "Sauna & Recovery Lounge", "2 Free PT Consultations/Mo", "Dietary Plan Included"]'::jsonb, true),
('p2222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Quarterly Pro Plan', 'pro', 7500, 3, 90, '["Full Gym & Free Weights Access", "Locker Facility", "Group Classes Included"]'::jsonb, false),
('p3333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Standard Monthly', 'standard', 3000, 1, 30, '["General Equipment Access", "Off-Peak Priority"]'::jsonb, false)
ON CONFLICT (id) DO NOTHING;

-- 5. SEED PAYMENTS
INSERT INTO public.payments (invoice_number, user_id, gym_id, amount, status, payment_method, paid_at, due_date)
VALUES
('INV-2084', 'dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-1111-1111-1111-111111111111', 24000, 'paid', 'upi', NOW() - INTERVAL '2 hours', NULL),
('INV-2083', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '11111111-1111-1111-1111-111111111111', 6000, 'paid', 'card', NOW() - INTERVAL '5 hours', NULL),
('INV-2082', '10101010-1010-1010-1010-101010101010', '11111111-1111-1111-1111-111111111111', 7500, 'overdue', 'upi', NULL, CURRENT_DATE - INTERVAL '4 days'),
('INV-2081', '20202020-2020-2020-2020-202020202020', '11111111-1111-1111-1111-111111111111', 7500, 'paid', 'upi', NOW() - INTERVAL '2 days', NULL),
('INV-2079', 'ffffffff-ffff-ffff-ffff-ffffffffffff', '11111111-1111-1111-1111-111111111111', 24000, 'paid', 'netbanking', NOW() - INTERVAL '6 days', NULL);

-- 6. SEED EXERCISES
INSERT INTO public.exercises (id, name, category, primary_muscle, is_big_three)
VALUES
('e1111111-1111-1111-1111-111111111111', 'Barbell Deadlift', 'barbell', 'Back & Hamstrings', true),
('e2222222-2222-2222-2222-222222222222', 'Barbell Back Squat', 'barbell', 'Quadriceps & Glutes', true),
('e3333333-3333-3333-3333-333333333333', 'Barbell Bench Press', 'barbell', 'Chest & Triceps', true),
('e4444444-4444-4444-4444-444444444444', 'Overhead Shoulder Press', 'barbell', 'Deltoids', false),
('e5555555-5555-5555-5555-555555555555', 'Lat Pulldown', 'cable', 'Latissimus Dorsi', false)
ON CONFLICT (id) DO NOTHING;

-- 7. SEED PERSONAL RECORDS
INSERT INTO public.personal_records (user_id, exercise_id, weight_kg, reps, estimated_one_rep_max)
VALUES
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'e1111111-1111-1111-1111-111111111111', 290, 1, 290),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'e2222222-2222-2222-2222-222222222222', 225, 1, 225),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'e3333333-3333-3333-3333-333333333333', 140, 1, 140),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'e2222222-2222-2222-2222-222222222222', 245, 1, 245),
('ffffffff-ffff-ffff-ffff-ffffffffffff', 'e1111111-1111-1111-1111-111111111111', 185, 1, 185)
ON CONFLICT (id) DO NOTHING;

-- 8. SEED LIVE WORKOUT SESSIONS (Training Now on Owner Dashboard)
INSERT INTO public.workout_sessions (id, user_id, gym_id, workout_name, status, started_at, progress_percentage, completed_exercises, total_exercises, total_volume_kg)
VALUES
('s1111111-1111-1111-1111-111111111111', 'dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-1111-1111-1111-111111111111', 'Hypertrophy Block A', 'in_progress', NOW() - INTERVAL '35 minutes', 80.0, 4, 5, 4850),
('s2222222-2222-2222-2222-222222222222', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '11111111-1111-1111-1111-111111111111', 'Cardio & Core Circuit', 'in_progress', NOW() - INTERVAL '20 minutes', 60.0, 3, 5, 1200),
('s3333333-3333-3333-3333-333333333333', '10101010-1010-1010-1010-101010101010', '11111111-1111-1111-1111-111111111111', 'Powerlifting - Squat Day', 'in_progress', NOW() - INTERVAL '10 minutes', 30.0, 1, 4, 2100)
ON CONFLICT (id) DO NOTHING;

-- 9. SEED USER STREAKS
INSERT INTO public.user_streaks (user_id, current_streak, longest_streak, last_workout_date)
VALUES
('dddddddd-dddd-dddd-dddd-dddddddddddd', 26, 32, CURRENT_DATE),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 21, 28, CURRENT_DATE),
('ffffffff-ffff-ffff-ffff-ffffffffffff', 29, 45, CURRENT_DATE - INTERVAL '1 day'),
('10101010-1010-1010-1010-101010101010', 14, 18, CURRENT_DATE - INTERVAL '2 days'),
('20202020-2020-2020-2020-202020202020', 34, 112, CURRENT_DATE)
ON CONFLICT (user_id) DO NOTHING;

-- 10. SEED GYM RANKINGS
INSERT INTO public.gym_rankings (gym_id, city_rank, state_rank, national_rank, previous_city_rank, total_score, consistency_score, tonnage_score, challenge_score, active_member_count)
VALUES
('11111111-1111-1111-1111-111111111111', 3, 5, 12, 5, 48920, 2650, 1850, 1420, 248),
('22222222-2222-2222-2222-222222222222', 1, 1, 3, 1, 54200, 2900, 2100, 1650, 310),
('33333333-3333-3333-3333-333333333333', 2, 3, 7, 3, 50370, 2800, 1950, 1500, 275)
ON CONFLICT (gym_id) DO NOTHING;
