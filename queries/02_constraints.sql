-- =========================================
-- Положительные тесты вставки
-- =========================================

INSERT INTO "user" (email, name, password_hash, role)
VALUES (
    'constraints_test@example.com',
    'Constraints Test',
    'test_hash',
    'user'
);

INSERT INTO coworking (
    name, address, opens_at, closes_at, manager_id
)
VALUES (
    'Test Coworking',
    'Test address',
    '09:00',
    '21:00',
    (SELECT user_id
     FROM "user"
     WHERE email = 'constraints_test@example.com')
);

INSERT INTO workspace (
    coworking_id, type, code, capacity, price_per_hour
)
VALUES (
    (SELECT coworking_id
     FROM coworking
     WHERE name = 'Test Coworking'),
    'desk',
    'TEST-01',
    1,
    300.00
);

-- =========================================
-- Бронирование и платеж
-- =========================================

INSERT INTO booking (
    workspace_id, user_id, start_time, end_time
)
VALUES (
    (SELECT workspace_id
     FROM workspace
     WHERE code = 'TEST-01'),
    (SELECT user_id
     FROM "user"
     WHERE email = 'constraints_test@example.com'),
    '2026-12-01 10:00:00+03',
    '2026-12-01 12:00:00+03'
);

INSERT INTO payment (booking_id, amount)
VALUES (
    (SELECT booking_id
     FROM booking
     WHERE workspace_id = (
         SELECT workspace_id
         FROM workspace
         WHERE code = 'TEST-01'
     )
     LIMIT 1),
    600.00
);

SELECT * FROM "user"
WHERE email = 'constraints_test@example.com';

SELECT * FROM coworking
WHERE name = 'Test Coworking';

SELECT * FROM workspace
WHERE code = 'TEST-01';

SELECT * FROM booking
WHERE workspace_id = (
    SELECT workspace_id
        FROM workspace
        WHERE code = 'TEST-01'
    );

SELECT * FROM payment;

-- =========================================
-- Негативные тесты
-- =========================================

-- 1. CHECK: capacity должно быть больше 0
-- Ожидаемая ошибка: check_violation ограничения workspace_capacity_check
-- INSERT INTO workspace (
--     coworking_id, type, code, capacity, price_per_hour
-- )
-- VALUES (
--     (SELECT coworking_id FROM coworking
--      WHERE name = 'Test Coworking'),
--     'desk', 'INVALID-01', 0, 300
-- );

-- 2. CHECK: цена не может быть отрицательной
-- Ожидаемая ошибка: check_violation ограничения workspace_price_check
-- INSERT INTO workspace (
--     coworking_id, type, code, capacity, price_per_hour
-- )
-- VALUES (
--     (SELECT coworking_id FROM coworking
--      WHERE name = 'Test Coworking'),
--     'desk', 'INVALID-02', 1, -100
-- );

-- 3. CHECK: время окончания должно быть позже начала
-- Ожидаемая ошибка: check_violation ограничения booking_time_check
-- INSERT INTO booking (
--     workspace_id, user_id, start_time, end_time
-- )
-- VALUES (
--     (SELECT workspace_id FROM workspace
--      WHERE code = 'TEST-01'),
--     (SELECT user_id FROM "user"
--      WHERE email = 'constraints_test@example.com'),
--     '2026-12-01 15:00:00+03',
--     '2026-12-01 14:00:00+03'
-- );

-- 4. EXCLUSION: пересечение бронирований
-- Ожидаемая ошибка: exclusion_violation
-- INSERT INTO booking (
--     workspace_id, user_id, start_time, end_time
-- )
-- VALUES (
--     (SELECT workspace_id FROM workspace
--      WHERE code = 'TEST-01'),
--     (SELECT user_id FROM "user"
--      WHERE email = 'constraints_test@example.com'),
--     '2026-12-01 11:00:00+03',
--     '2026-12-01 13:00:00+03'
-- );

-- 5. FOREIGN KEY: несуществующий пользователь
-- Ожидаемая ошибка: foreign_key_violation
-- INSERT INTO booking (
--     workspace_id, user_id, start_time, end_time
-- )
-- VALUES (
--     (SELECT workspace_id FROM workspace
--      WHERE code = 'TEST-01'),
--     999999,
--     '2026-12-02 10:00:00+03',
--     '2026-12-02 11:00:00+03'
-- );

-- 6. UNIQUE: повтор кода рабочего места
-- Ожидаемая ошибка: duplicate key value violates unique constraint
-- INSERT INTO workspace (
--     coworking_id, type, code, capacity, price_per_hour
-- )
-- VALUES (
--     (SELECT coworking_id FROM coworking
--          WHERE name = 'Test Coworking'),
--     'desk', 'TEST-01', 1, 300.00
-- );
