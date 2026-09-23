-- =========================================================
-- V101__update_demo_user_passwords.sql
-- Nexus Migration: Fix BCrypt password hash for demo persona accounts
-- Password: Password123!
-- =========================================================

UPDATE users 
SET password_hash = '$2a$10$13V.tJPu8a5ZwWzNv7eiGeLldiP5.nsWqmzpjv/MGPiYP4Ixxh.zW'
WHERE email IN (
    'requester@nexus.com',
    'operator@nexus.com',
    'lead@nexus.com',
    'problem.manager@nexus.com',
    'admin@nexus.com'
);









