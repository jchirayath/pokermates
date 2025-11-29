-- Location: supabase/migrations/20251129175337_poker_game_management_system.sql
-- Schema Analysis: Existing user_profiles table with id, email, full_name, role, etc.
-- Integration Type: NEW MODULE - Poker game management system
-- Dependencies: Existing user_profiles table

-- 1. Custom Types
CREATE TYPE public.game_status AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled');
CREATE TYPE public.payment_status AS ENUM ('pending', 'paid', 'failed');
CREATE TYPE public.member_role AS ENUM ('admin', 'member');

-- 2. Core Tables (no foreign keys)
CREATE TABLE public.poker_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    creator_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.saved_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Dependent Tables (with foreign keys)
CREATE TABLE public.group_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES public.poker_groups(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    role public.member_role DEFAULT 'member'::public.member_role,
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(group_id, user_id)
);

CREATE TABLE public.poker_games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES public.poker_groups(id) ON DELETE CASCADE,
    location_id UUID REFERENCES public.saved_locations(id) ON DELETE SET NULL,
    host_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    scheduled_at TIMESTAMPTZ NOT NULL,
    buyin_amount DECIMAL(10,2) NOT NULL,
    allow_rebuys BOOLEAN DEFAULT false,
    rebuy_amount DECIMAL(10,2),
    status public.game_status DEFAULT 'scheduled'::public.game_status,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.game_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID REFERENCES public.poker_games(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    buyin_count INTEGER DEFAULT 1,
    rebuy_count INTEGER DEFAULT 0,
    total_buyin DECIMAL(10,2) NOT NULL,
    cashout_amount DECIMAL(10,2),
    net_profit DECIMAL(10,2),
    is_confirmed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(game_id, user_id)
);

CREATE TABLE public.payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    participant_id UUID REFERENCES public.game_participants(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    payment_status public.payment_status DEFAULT 'pending'::public.payment_status,
    payment_method TEXT,
    transaction_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- 4. Indexes
CREATE INDEX idx_poker_groups_creator_id ON public.poker_groups(creator_id);
CREATE INDEX idx_group_members_group_id ON public.group_members(group_id);
CREATE INDEX idx_group_members_user_id ON public.group_members(user_id);
CREATE INDEX idx_poker_games_group_id ON public.poker_games(group_id);
CREATE INDEX idx_poker_games_scheduled_at ON public.poker_games(scheduled_at);
CREATE INDEX idx_poker_games_status ON public.poker_games(status);
CREATE INDEX idx_game_participants_game_id ON public.game_participants(game_id);
CREATE INDEX idx_game_participants_user_id ON public.game_participants(user_id);
CREATE INDEX idx_payment_transactions_participant_id ON public.payment_transactions(participant_id);
CREATE INDEX idx_saved_locations_created_by ON public.saved_locations(created_by);

-- 5. Functions (before RLS policies)
CREATE OR REPLACE FUNCTION public.update_poker_game_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

CREATE OR REPLACE FUNCTION public.update_game_participant_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

-- 6. Enable RLS
ALTER TABLE public.poker_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.poker_games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies (Pattern 2 - Simple User Ownership)
CREATE POLICY "users_manage_own_poker_groups"
ON public.poker_groups
FOR ALL
TO authenticated
USING (creator_id = auth.uid())
WITH CHECK (creator_id = auth.uid());

CREATE POLICY "users_manage_own_saved_locations"
ON public.saved_locations
FOR ALL
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

-- Group members can view groups they belong to
CREATE POLICY "members_view_their_groups"
ON public.poker_groups
FOR SELECT
TO authenticated
USING (
    id IN (
        SELECT group_id FROM public.group_members 
        WHERE user_id = auth.uid()
    )
);

-- Group members policies
CREATE POLICY "admins_manage_group_members"
ON public.group_members
FOR ALL
TO authenticated
USING (
    group_id IN (
        SELECT group_id FROM public.group_members 
        WHERE user_id = auth.uid() AND role = 'admin'::public.member_role
    )
)
WITH CHECK (
    group_id IN (
        SELECT group_id FROM public.group_members 
        WHERE user_id = auth.uid() AND role = 'admin'::public.member_role
    )
);

CREATE POLICY "members_view_group_members"
ON public.group_members
FOR SELECT
TO authenticated
USING (
    group_id IN (
        SELECT group_id FROM public.group_members 
        WHERE user_id = auth.uid()
    )
);

-- Game policies - members can view games in their groups
CREATE POLICY "members_view_group_games"
ON public.poker_games
FOR SELECT
TO authenticated
USING (
    group_id IN (
        SELECT group_id FROM public.group_members 
        WHERE user_id = auth.uid()
    )
);

CREATE POLICY "group_admins_manage_games"
ON public.poker_games
FOR ALL
TO authenticated
USING (
    group_id IN (
        SELECT group_id FROM public.group_members 
        WHERE user_id = auth.uid() AND role = 'admin'::public.member_role
    )
)
WITH CHECK (
    group_id IN (
        SELECT group_id FROM public.group_members 
        WHERE user_id = auth.uid() AND role = 'admin'::public.member_role
    )
);

-- Game participants policies
CREATE POLICY "participants_view_game_participants"
ON public.game_participants
FOR SELECT
TO authenticated
USING (
    game_id IN (
        SELECT id FROM public.poker_games 
        WHERE group_id IN (
            SELECT group_id FROM public.group_members 
            WHERE user_id = auth.uid()
        )
    )
);

CREATE POLICY "admins_manage_game_participants"
ON public.game_participants
FOR ALL
TO authenticated
USING (
    game_id IN (
        SELECT id FROM public.poker_games 
        WHERE group_id IN (
            SELECT group_id FROM public.group_members 
            WHERE user_id = auth.uid() AND role = 'admin'::public.member_role
        )
    )
)
WITH CHECK (
    game_id IN (
        SELECT id FROM public.poker_games 
        WHERE group_id IN (
            SELECT group_id FROM public.group_members 
            WHERE user_id = auth.uid() AND role = 'admin'::public.member_role
        )
    )
);

-- Payment policies - users can view their own payments
CREATE POLICY "users_view_own_payments"
ON public.payment_transactions
FOR SELECT
TO authenticated
USING (
    participant_id IN (
        SELECT id FROM public.game_participants 
        WHERE user_id = auth.uid()
    )
);

CREATE POLICY "admins_manage_payments"
ON public.payment_transactions
FOR ALL
TO authenticated
USING (
    participant_id IN (
        SELECT gp.id FROM public.game_participants gp
        JOIN public.poker_games pg ON gp.game_id = pg.id
        JOIN public.group_members gm ON pg.group_id = gm.group_id
        WHERE gm.user_id = auth.uid() AND gm.role = 'admin'::public.member_role
    )
)
WITH CHECK (
    participant_id IN (
        SELECT gp.id FROM public.game_participants gp
        JOIN public.poker_games pg ON gp.game_id = pg.id
        JOIN public.group_members gm ON pg.group_id = gm.group_id
        WHERE gm.user_id = auth.uid() AND gm.role = 'admin'::public.member_role
    )
);

-- 8. Triggers
CREATE TRIGGER update_poker_game_timestamp
    BEFORE UPDATE ON public.poker_games
    FOR EACH ROW
    EXECUTE FUNCTION public.update_poker_game_updated_at();

CREATE TRIGGER update_game_participant_timestamp
    BEFORE UPDATE ON public.game_participants
    FOR EACH ROW
    EXECUTE FUNCTION public.update_game_participant_updated_at();

-- 9. Mock Data (references existing user_profiles)
DO $$
DECLARE
    existing_user_id UUID;
    group1_id UUID := gen_random_uuid();
    group2_id UUID := gen_random_uuid();
    location1_id UUID := gen_random_uuid();
    location2_id UUID := gen_random_uuid();
    game1_id UUID := gen_random_uuid();
    game2_id UUID := gen_random_uuid();
    participant1_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user ID from user_profiles
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NULL THEN
        RAISE NOTICE 'No existing users found. Create user profiles first.';
        RETURN;
    END IF;
    
    -- Create poker groups
    INSERT INTO public.poker_groups (id, name, description, creator_id) VALUES
        (group1_id, 'Friday Night Poker', 'Weekly poker game with friends', existing_user_id),
        (group2_id, 'Weekend Warriors', 'Competitive weekend games', existing_user_id);
    
    -- Create group members
    INSERT INTO public.group_members (group_id, user_id, role) VALUES
        (group1_id, existing_user_id, 'admin'::public.member_role),
        (group2_id, existing_user_id, 'admin'::public.member_role);
    
    -- Create saved locations
    INSERT INTO public.saved_locations (id, name, address, city, state, created_by) VALUES
        (location1_id, 'John''s House', '123 Poker Street', 'Las Vegas', 'NV', existing_user_id),
        (location2_id, 'Mike''s Apartment', '456 Card Avenue', 'Henderson', 'NV', existing_user_id);
    
    -- Create poker games
    INSERT INTO public.poker_games (id, group_id, location_id, host_id, scheduled_at, buyin_amount, allow_rebuys, status) VALUES
        (game1_id, group1_id, location1_id, existing_user_id, CURRENT_TIMESTAMP + INTERVAL '2 days', 50.00, true, 'scheduled'::public.game_status),
        (game2_id, group2_id, location2_id, existing_user_id, CURRENT_TIMESTAMP + INTERVAL '5 days', 100.00, false, 'scheduled'::public.game_status);
    
    -- Create game participants
    INSERT INTO public.game_participants (id, game_id, user_id, total_buyin) VALUES
        (participant1_id, game1_id, existing_user_id, 50.00);
    
    -- Create payment transactions
    INSERT INTO public.payment_transactions (participant_id, amount, payment_status) VALUES
        (participant1_id, 50.00, 'paid'::public.payment_status);
        
END $$;