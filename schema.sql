-- Практика №2
-- Создание схемы БД системы бронирования коворкингов

-- Расширение для использования BIGINT в exclusion
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- -----------------------------------------
-- Пользователи
-- -----------------------------------------
CREATE TABLE "user" (
    user_id       BIGSERIAL PRIMARY KEY,
    email         TEXT      NOT NULL
        UNIQUE CHECK (position('@' in email) > 1),
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
    manager_id   BIGINT    NOT NULL
        REFERENCES "user"(user_id) ON DELETE RESTRICT,

    CONSTRAINT coworking_hours_check
        CHECK (closes_at > opens_at)
);

-- -----------------------------------------
-- Рабочие места
-- -----------------------------------------
CREATE TABLE workspace (
    workspace_id   BIGSERIAL      PRIMARY KEY,
    coworking_id   BIGINT         NOT NULL
        REFERENCES coworking(coworking_id) ON DELETE RESTRICT,
    type           TEXT           NOT NULL,
    code           TEXT           NOT NULL,
    capacity       INT            NOT NULL,
    price_per_hour NUMERIC(10, 2) NOT NULL,
    is_active      BOOLEAN        NOT NULL DEFAULT TRUE,

    CONSTRAINT workspace_capacity_check
        CHECK (capacity > 0),

    CONSTRAINT workspace_price_check
        CHECK (price_per_hour >= 0),

    CONSTRAINT workspace_code_altkey
        UNIQUE (coworking_id, code)
);

-- -----------------------------------------
-- Брони
-- -----------------------------------------
CREATE TABLE booking (
    booking_id   BIGSERIAL   PRIMARY KEY,
    workspace_id BIGINT      NOT NULL
        REFERENCES workspace(workspace_id) ON DELETE RESTRICT,
    user_id      BIGINT      NOT NULL
        REFERENCES "user"(user_id) ON DELETE RESTRICT,
    start_time   TIMESTAMPTZ NOT NULL,
    end_time     TIMESTAMPTZ NOT NULL,
    status       TEXT        NOT NULL DEFAULT 'pending',
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT booking_time_check
        CHECK (end_time > start_time),

    CONSTRAINT booking_no_overlap
        EXCLUDE USING gist (
            workspace_id WITH =,
            tstzrange(start_time, end_time, '[)') WITH &&
        )
        WHERE (status <> 'cancelled')
);

-- -----------------------------------------
-- Платежи
-- -----------------------------------------
CREATE TABLE payment (
    payment_id  BIGSERIAL      PRIMARY KEY,
    booking_id  BIGINT         NOT NULL
        REFERENCES booking(booking_id) ON DELETE RESTRICT,
    amount      NUMERIC(10, 2) NOT NULL,
    status      TEXT           NOT NULL DEFAULT 'pending',
    paid_at     TIMESTAMPTZ,
    refunded_at TIMESTAMPTZ,

    CONSTRAINT payment_amount_check
        CHECK (amount >= 0),
);

-- Комментарии к таблицам
COMMENT ON TABLE "user" IS
'Пользователи платформы';

COMMENT ON TABLE coworking IS
'Коворкинги, управляемые пользователями';

COMMENT ON TABLE workspace IS
'Рабочие места, доступные для бронирования';

COMMENT ON TABLE booking IS
'Бронирования рабочих мест с временными интервалами';

COMMENT ON TABLE payment IS
'Платежные операции по бронированиям';


-- Комментарии к столбцам
COMMENT ON COLUMN booking.status IS
'Статус бронирования: pending, confirmed, cancelled, completed ';

COMMENT ON COLUMN payment.status IS
'Статус платежа: pending, paid, failed, refunded';

-- Комментарии к ограничениям
COMMENT ON CONSTRAINT booking_no_overlap ON booking IS
'Запрещает пересечение активных бронирований одного рабочего места';
