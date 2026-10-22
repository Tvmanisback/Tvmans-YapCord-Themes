-- Run this in Supabase SQL Editor after the original themes table and Storage bucket exist.
-- Adds CSS metadata fields, public creator profiles, and owner-only delete permissions.

alter table public.themes
  add column if not exists theme_author text not null default 'Community member',
  add column if not exists version text not null default 'Unversioned';

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

grant select, insert, update on public.profiles to authenticated;
grant select on public.profiles to anon;

drop policy if exists "Public can view profiles" on public.profiles;
create policy "Public can view profiles"
on public.profiles for select
to anon, authenticated
using (true);

drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile"
on public.profiles for insert
to authenticated
with check (auth.uid() = id);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
on public.profiles for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "Users can delete their own themes" on public.themes;
create policy "Users can delete their own themes"
on public.themes for delete
to authenticated
using (auth.uid() = author_id);

grant delete on public.themes to authenticated;

drop policy if exists "Users can delete their own theme files" on storage.objects;
create policy "Users can delete their own theme files"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'themes'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);
