-- =====================================================
-- GYM WEBSITE - Complete Supabase Database Schema
-- شغّل هذا الكود في SQL Editor في Supabase
-- =====================================================

-- 1. MEMBERS (الأعضاء)
CREATE TABLE members (
  id            BIGSERIAL PRIMARY KEY,
  full_name     TEXT NOT NULL,
  email         TEXT UNIQUE NOT NULL,
  phone         TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  age           INTEGER,
  gender        TEXT DEFAULT 'female',
  goals         TEXT,
  status        TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 2. PLANS (الباقات)
CREATE TABLE plans (
  id            BIGSERIAL PRIMARY KEY,
  name          TEXT NOT NULL,
  name_ar       TEXT,
  duration      TEXT NOT NULL CHECK (duration IN ('monthly', 'yearly')),
  price         DECIMAL(10,2) NOT NULL,
  original_price DECIMAL(10,2),
  features      TEXT[],
  is_featured   BOOLEAN DEFAULT false,
  is_active     BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 3. MEMBERSHIPS (الاشتراكات)
CREATE TABLE memberships (
  id            BIGSERIAL PRIMARY KEY,
  member_id     BIGINT REFERENCES members(id) ON DELETE CASCADE,
  plan_id       BIGINT REFERENCES plans(id),
  start_date    DATE NOT NULL DEFAULT CURRENT_DATE,
  end_date      DATE NOT NULL,
  status        TEXT DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled')),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 4. INVOICES (الفواتير)
CREATE TABLE invoices (
  id            BIGSERIAL PRIMARY KEY,
  member_id     BIGINT REFERENCES members(id) ON DELETE CASCADE,
  membership_id BIGINT REFERENCES memberships(id),
  amount        DECIMAL(10,2) NOT NULL,
  status        TEXT DEFAULT 'pending' CHECK (status IN ('paid', 'pending', 'cancelled')),
  payment_date  TIMESTAMPTZ,
  due_date      DATE NOT NULL,
  notes         TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TRAINERS (المدربين)
CREATE TABLE trainers (
  id            BIGSERIAL PRIMARY KEY,
  full_name     TEXT NOT NULL,
  specialty     TEXT NOT NULL,
  bio           TEXT,
  photo_url     TEXT,
  experience_years INTEGER,
  rating        DECIMAL(3,2) DEFAULT 5.0,
  is_active     BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 6. CLASSES (الحصص)
CREATE TABLE classes (
  id            BIGSERIAL PRIMARY KEY,
  name          TEXT NOT NULL,
  name_ar       TEXT,
  type          TEXT NOT NULL CHECK (type IN ('Cardio', 'Strength', 'Yoga', 'Pilates', 'Zumba', 'HIIT', 'Other')),
  trainer_id    BIGINT REFERENCES trainers(id),
  day_of_week   TEXT NOT NULL CHECK (day_of_week IN ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')),
  start_time    TIME NOT NULL,
  end_time      TIME NOT NULL,
  capacity      INTEGER DEFAULT 20,
  is_active     BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 7. GALLERY (معرض الصور)
CREATE TABLE gallery (
  id            BIGSERIAL PRIMARY KEY,
  title         TEXT,
  image_url     TEXT NOT NULL,
  category      TEXT CHECK (category IN ('weights', 'equipment', 'classes', 'clients', 'other')),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 8. CONTACT MESSAGES (رسائل التواصل)
CREATE TABLE contact_messages (
  id            BIGSERIAL PRIMARY KEY,
  full_name     TEXT NOT NULL,
  email         TEXT NOT NULL,
  phone         TEXT,
  message       TEXT NOT NULL,
  is_read       BOOLEAN DEFAULT false,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================
ALTER TABLE members          ENABLE ROW LEVEL SECURITY;
ALTER TABLE plans            ENABLE ROW LEVEL SECURITY;
ALTER TABLE memberships      ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices         ENABLE ROW LEVEL SECURITY;
ALTER TABLE trainers         ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes          ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery          ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;

-- السماح بكل العمليات (للتطوير - يمكن تقييدها لاحقاً)
CREATE POLICY "allow_all" ON members          FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON plans            FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON memberships      FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON invoices         FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON trainers         FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON classes          FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON gallery          FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON contact_messages FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- SAMPLE DATA (بيانات تجريبية)
-- =====================================================

-- باقات تجريبية
INSERT INTO plans (name, name_ar, duration, price, original_price, features, is_featured) VALUES
('Silver', 'فضي', 'monthly', 15.00, NULL,    ARRAY['Gym access 6AM-10PM', 'Locker & shower', '2 group classes/month', 'Basic assessment'], false),
('Gold',   'ذهبي', 'monthly', 25.00, 30.00,  ARRAY['Unlimited gym access', 'All group classes', 'Personal trainer 2x/month', 'Nutrition guidance', 'Progress tracking'], true),
('Platinum','بلاتيني','monthly',40.00, 50.00, ARRAY['All Gold features', 'Daily personal training', 'Spa & wellness', 'Meal plan', 'Priority booking', 'VIP lounge'], false),
('Silver Annual','فضي سنوي','yearly', 150.00, 180.00, ARRAY['Gym access 6AM-10PM', 'Locker & shower', '2 group classes/month', 'Basic assessment', 'Save 17%'], false),
('Gold Annual',  'ذهبي سنوي','yearly', 250.00, 300.00, ARRAY['Unlimited gym access', 'All group classes', 'Personal trainer 2x/month', 'Nutrition guidance', 'Save 17%'], false);

-- مدربين تجريبيين
INSERT INTO trainers (full_name, specialty, bio, experience_years, rating) VALUES
('Sara Al-Balushi',  'Yoga & Pilates',       'Certified yoga instructor with 8 years experience. Specializes in mindfulness and flexibility training.', 8, 4.9),
('Haya Al-Rashidi',  'Cardio & HIIT',        'Former national athlete turned fitness coach. Expert in high-intensity training and weight loss programs.', 6, 4.8),
('Noura Al-Farsi',   'Strength & Nutrition', 'Certified personal trainer and nutritionist. Helps clients build strength and healthy eating habits.', 5, 4.7),
('Fatima Al-Habsi',  'Zumba & Dance Fitness','Energetic dance fitness instructor bringing joy to every workout session.', 4, 4.9);

-- حصص تجريبية
INSERT INTO classes (name, name_ar, type, trainer_id, day_of_week, start_time, end_time, capacity) VALUES
('Morning Yoga',    'يوغا الصباح',      'Yoga',     1, 'Sunday',    '07:00', '08:00', 15),
('HIIT Blast',      'هيت بلاست',        'HIIT',     2, 'Sunday',    '09:00', '10:00', 20),
('Strength Build',  'تقوية العضلات',    'Strength', 3, 'Monday',    '08:00', '09:00', 12),
('Zumba Party',     'زومبا',            'Zumba',    4, 'Monday',    '17:00', '18:00', 25),
('Pilates Core',    'بيلاتس',          'Pilates',  1, 'Tuesday',   '07:30', '08:30', 10),
('Cardio Burn',     'كارديو',          'Cardio',   2, 'Tuesday',   '10:00', '11:00', 20),
('Evening Yoga',    'يوغا المساء',      'Yoga',     1, 'Wednesday', '18:00', '19:00', 15),
('Power Training',  'تدريب القوة',      'Strength', 3, 'Wednesday', '09:00', '10:00', 12),
('Zumba Fiesta',    'زومبا فيستا',      'Zumba',    4, 'Thursday',  '17:30', '18:30', 25),
('Full Body HIIT',  'هيت كامل',         'HIIT',     2, 'Thursday',  '08:00', '09:00', 20),
('Weekend Yoga',    'يوغا الويكند',     'Yoga',     1, 'Friday',    '09:00', '10:00', 15),
('Dance Cardio',    'رقص كارديو',       'Cardio',   4, 'Saturday',  '10:00', '11:00', 20);
