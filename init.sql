-- Каркас схемы БД init.sql

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
