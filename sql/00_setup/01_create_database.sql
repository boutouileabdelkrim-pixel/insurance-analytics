-- ============================================================
-- 00_setup / 01_create_database.sql
-- Création de la base de données et des schémas
-- Phase 3 — Préparation de l'environnement local
-- ============================================================

-- À exécuter en tant que superutilisateur postgres :
--   sudo -u postgres psql

CREATE DATABASE insurance_analytics
  WITH ENCODING 'UTF8'
       LC_COLLATE 'en_US.UTF-8'
       LC_CTYPE 'en_US.UTF-8'
       TEMPLATE template0;

-- Puis se connecter à la base :
--   \c insurance_analytics

CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA core;
CREATE SCHEMA analytics;
