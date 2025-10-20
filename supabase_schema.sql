-- Schema for Supabase tables
-- Generated on 2025-10-12

-- Users table (assuming auth.users is used, but if custom)
-- Supabase handles auth.users automatically

-- Profiles table
CREATE TABLE user_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  display_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Set up Row Level Security (RLS) for profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Política para que cualquier usuario autenticado pueda ver los perfiles
DROP POLICY IF EXISTS "Users can view all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;

CREATE POLICY "Enable read access for authenticated users" ON user_profiles
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Enable update for users based on user_id" ON user_profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable insert for authenticated users" ON user_profiles
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Products table
CREATE TABLE productos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  price NUMERIC NOT NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Set up Row Level Security (RLS) for products
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own products" ON productos
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own products" ON productos
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own products" ON productos
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own products" ON productos
  FOR DELETE USING (auth.uid() = user_id);

-- Actualizar tabla quotes existente para añadir campos de sincronización
-- Ejecutar estos comandos en orden en Supabase SQL Editor

-- 1. Añadir nuevas columnas a la tabla quotes existente
ALTER TABLE quotes ADD COLUMN IF NOT EXISTS local_id TEXT;
ALTER TABLE quotes ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE quotes ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE quotes ADD COLUMN IF NOT EXISTS sync_version INTEGER DEFAULT 1;
ALTER TABLE quotes ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;

-- 2. Actualizar registros existentes con valores por defecto
UPDATE quotes SET
  created_at = COALESCE(created_at, date),
  updated_at = COALESCE(updated_at, NOW()),
  sync_version = COALESCE(sync_version, 1),
  is_deleted = COALESCE(is_deleted, FALSE)
WHERE created_at IS NULL OR updated_at IS NULL OR sync_version IS NULL OR is_deleted IS NULL;

-- 3. Crear índices para optimizar sincronización
CREATE INDEX IF NOT EXISTS idx_quotes_user_id ON quotes(user_id);
CREATE INDEX IF NOT EXISTS idx_quotes_local_id ON quotes(local_id);
CREATE INDEX IF NOT EXISTS idx_quotes_updated_at ON quotes(updated_at);
CREATE INDEX IF NOT EXISTS idx_quotes_user_updated ON quotes(user_id, updated_at);

-- 4. Crear trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_quotes_updated_at
    BEFORE UPDATE ON quotes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 5. Actualizar políticas RLS (si es necesario)
-- Las políticas existentes deberían seguir funcionando

-- Create the update_profile function
CREATE OR REPLACE FUNCTION update_profile(
  p_user_id UUID,
  p_display_name TEXT
) RETURNS user_profiles AS $$
DECLARE
  v_profile user_profiles;
BEGIN
  -- Insert or update the profile
  INSERT INTO user_profiles (user_id, display_name, updated_at)
  VALUES (p_user_id, p_display_name, NOW())
  ON CONFLICT (user_id)
  DO UPDATE SET
    display_name = EXCLUDED.display_name,
    updated_at = NOW()
  RETURNING * INTO v_profile;

  RETURN v_profile;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;