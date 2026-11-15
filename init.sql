-- Каркас схемы БД init.sql
--
-- Расширение для использования BIGINT в exclusion
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- -----------------------------------------
-- Пользователи
-- -----------------------------------------
CREATE TABLE "user" (
    user_id       BIGSERIAL PRIMARY KEY,
    email         TEXT      NOT NULL UNIQUE CHECK (position('@' in email) > 1),
    name          TEXT      NOT NULL,
    password_hash TEXT      NOT NULL,
    role          TEXT      NOT NULL
);

-- -----------------------------------------
-- Коворкинги
-- -----------------------------------------
CREATE TABLE coworking (
    coworking_id BIGSERIAL PRIMARY KEY,
    name         TEXT      NOT NULL,
    address      TEXT      NOT NULL,
    opens_at     TIME      NOT NULL,
    closes_at    TIME      NOT NULL,
    manager_id   BIGINT   NOT NULL REFERENCES "user"(user_id) ON DELETE RESTRICT,

    CHECK (closes_at > opens_at)
);

-- -----------------------------------------
-- Рабочие места
-- -----------------------------------------
CREATE TABLE workspace (
    workspace_id   BIGSERIAL      PRIMARY KEY,
    coworking_id   BIGINT         NOT NULL REFERENCES coworking(coworking_id) ON DELETE RESTRICT,
    type           TEXT           NOT NULL,
    code           TEXT           NOT NULL,
    capacity       INT            NOT NULL CHECK (capacity > 0),
    price_per_hour NUMERIC(10, 2) NOT NULL,
    is_active      BOOLEAN        NOT NULL DEFAULT TRUE,

    UNIQUE (coworking_id, code)
);

-- -----------------------------------------
-- Брони
-- -----------------------------------------
CREATE TABLE booking(
    booking_id   BIGSERIAL  PRIMARY KEY,
    workspace_id BIGINT     NOT NULL REFERENCES workspace(workspace_id) ON DELETE RESTRICT,
    user_id      BIGINT     NOT NULL REFERENCES "user"(user_id) ON DELETE RESTRICT,
    start_time   TIMESTAMPTZ 
 NOT NULL,
    end_time     TIMESTAMPTZ 
 NOT NULL,
    status       TEXT       NOT NULL DEFAULT 'pending',
    created_at   TIMESTAMPTZ 
 DEFAULT now(),

    CHECK (end_time > start_time)
);

-- -----------------------------------------
-- Платежи
-- -----------------------------------------
CREATE TABLE payment (
    payment_id  BIGSERIAL      PRIMARY KEY,
    booking_id  BIGINT         NOT NULL REFERENCES booking(booking_id) ON DELETE RESTRICT,
    amount      NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    status      TEXT           NOT NULL DEFAULT 'pending',
    paid_at     TIMESTAMPTZ 
,
    refunded_at TIMESTAMPTZ 
);
