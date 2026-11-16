-- ==============================================================================
-- NAIRAFLOW CLOUD SQL DATABASE SCHEMA (POSTGRESQL FOR SUPABASE)
-- Multi-User Relational Architecture with Row-Level Security (RLS)
-- ==============================================================================

-- 1. PROFILES (Extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    institution TEXT,
    student_mode BOOLEAN DEFAULT TRUE,
    expected_allowance_day INTEGER DEFAULT 28,
    allowance_amount NUMERIC(12, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. WALLETS (Commercial Banks, Fintechs, Cash, Locked Savings)
CREATE TABLE IF NOT EXISTS public.wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    bank_name TEXT,
    balance NUMERIC(12, 2) DEFAULT 0.00,
    tag TEXT DEFAULT 'Commercial Bank',
    is_locked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. TRANSACTIONS (Income, Expense, Transfers)
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    wallet_id UUID REFERENCES public.wallets(id) ON DELETE SET NULL,
    type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
    title TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    category TEXT NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. CAMPUS HANDOUTS & DUES (Student Survival)
CREATE TABLE IF NOT EXISTS public.campus_handouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    cost NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    paid BOOLEAN DEFAULT FALSE,
    due_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. CAMPUS SINKING FUNDS (Off-Campus Lodge Rent, Phone Fund, Laptop Fund)
CREATE TABLE IF NOT EXISTS public.campus_sinking_funds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    target_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    current_saved NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    deadline DATE,
    icon TEXT DEFAULT '🏠',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. DAILY MEAL SPENDS (Breakfast, Lunch, Dinner in Naira)
CREATE TABLE IF NOT EXISTS public.daily_meal_spends (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    breakfast NUMERIC(12, 2) DEFAULT 0.00,
    lunch NUMERIC(12, 2) DEFAULT 0.00,
    dinner NUMERIC(12, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- 7. CALORIE PLATE ITEMS (Portion-Scaled Meal Logs)
CREATE TABLE IF NOT EXISTS public.calorie_plate_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    food_id TEXT NOT NULL,
    quantity NUMERIC(6, 2) NOT NULL DEFAULT 1.00,
    logged_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. DEBTS & COURSEMATE IOUS (Who owes me & Who I owe)
CREATE TABLE IF NOT EXISTS public.debts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    person TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('owing_me', 'i_owe')),
    reason TEXT,
    due_date DATE,
    status TEXT NOT NULL DEFAULT 'unpaid' CHECK (status IN ('unpaid', 'paid')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. MARKET STAPLES (Marketplace Memory)
CREATE TABLE IF NOT EXISTS public.market_staples (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    item_name TEXT NOT NULL,
    price NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    market_location TEXT,
    last_bought DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. USER SETTINGS & CUSTOM QUICK PRESETS
CREATE TABLE IF NOT EXISTS public.user_presets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    preset_key TEXT NOT NULL,
    name TEXT NOT NULL,
    short_name TEXT,
    icon TEXT,
    cost NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    category TEXT,
    wallet_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) - ENSURES 100% USER DATA PRIVACY
-- Users can ONLY view, insert, update, and delete their own records.
-- ==============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campus_handouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campus_sinking_funds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_meal_spends ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calorie_plate_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_staples ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_presets ENABLE ROW LEVEL SECURITY;

-- Policies for PROFILES
CREATE POLICY "Users can manage own profile" ON public.profiles
    FOR ALL USING (auth.uid() = id);

-- Policies for WALLETS
CREATE POLICY "Users can manage own wallets" ON public.wallets
    FOR ALL USING (auth.uid() = user_id);

-- Policies for TRANSACTIONS
CREATE POLICY "Users can manage own transactions" ON public.transactions
    FOR ALL USING (auth.uid() = user_id);

-- Policies for CAMPUS HANDOUTS
CREATE POLICY "Users can manage own handouts" ON public.campus_handouts
    FOR ALL USING (auth.uid() = user_id);

-- Policies for SINKING FUNDS
CREATE POLICY "Users can manage own sinking funds" ON public.campus_sinking_funds
    FOR ALL USING (auth.uid() = user_id);

-- Policies for DAILY MEAL SPENDS
CREATE POLICY "Users can manage own meal spends" ON public.daily_meal_spends
    FOR ALL USING (auth.uid() = user_id);

-- Policies for CALORIE PLATE
CREATE POLICY "Users can manage own plate" ON public.calorie_plate_items
    FOR ALL USING (auth.uid() = user_id);

-- Policies for DEBTS
CREATE POLICY "Users can manage own debts" ON public.debts
    FOR ALL USING (auth.uid() = user_id);

-- Policies for MARKET STAPLES
CREATE POLICY "Users can manage own market staples" ON public.market_staples
    FOR ALL USING (auth.uid() = user_id);

-- Policies for USER PRESETS
CREATE POLICY "Users can manage own presets" ON public.user_presets
    FOR ALL USING (auth.uid() = user_id);

-- ==============================================================================
-- AUTOMATIC USER INITIALIZATION TRIGGER
-- When a user registers via Supabase Auth, automatically set up their profile
-- and 4 default Nigerian wallets with 0.00 Naira balance.
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- 1. Create Profile
    INSERT INTO public.profiles (id, email, full_name, student_mode)
    VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'full_name', 'Student User'), TRUE);

    -- 2. Create 4 default blank wallets (0.00 Naira)
    INSERT INTO public.wallets (user_id, name, bank_name, balance, tag, is_locked)
    VALUES
        (NEW.id, 'Primary Commercial Bank', 'Access Bank / GTBank', 0.00, 'Commercial Bank', FALSE),
        (NEW.id, 'Fintech (OPay/PalmPay)', 'OPay / PalmPay', 0.00, 'Daily Spends', FALSE),
        (NEW.id, 'Cash in Hand', 'Physical Cash', 0.00, 'Physical Cash', FALSE),
        (NEW.id, 'Locked Savings', 'SafeLock / Target', 0.00, 'SafeLock / Target', TRUE);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

