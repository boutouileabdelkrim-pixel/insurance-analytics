-- ============================================================
-- 00_setup / 01_create_database.sql
-- Create database and schemas
-- Phase 3 — Local environment setup
-- ============================================================

-- Run as postgres superuser:
--   sudo -u postgres psql

CREATE DATABASE insurance_analytics
  WITH ENCODING 'UTF8'
       LC_COLLATE 'en_US.UTF-8'
       LC_CTYPE 'en_US.UTF-8'
       TEMPLATE template0;

-- Then connect to the database:
--   \c insurance_analytics

CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA core;
CREATE SCHEMA analytics;
