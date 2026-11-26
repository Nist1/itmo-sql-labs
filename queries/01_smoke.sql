-- ============================================================
-- 1. Версия СУБД
-- ============================================================
SELECT version();

-- ============================================================
-- 2. Вставка корректных данных
-- ============================================================
-- Сотрудник
INSERT INTO "user" (email, name, password_hash, role)
VALUES ('staff@example.com', 'Staff Member', 'hash123', 'staff');

-- Клиент
INSERT INTO "user" (email, name, password_hash, role)
VALUES ('client@example.com', 'Client User', 'hash456', 'client');

-- Коворкинг
INSERT INTO coworking (name, address, opens_at, closes_at, manager_id)
VALUES ('Cowork-1', 'ул. Ленина, 1', '09:00', '21:00', 1);

-- Рабочее место
INSERT INTO workspace (coworking_id, type, code, capacity, price_per_hour)
VALUES (1, 'desk', 'A101', 4, 150.00);

-- ============================================================
-- 3. Чтение данных
-- ============================================================
SELECT * FROM "user";
SELECT * FROM coworking;
SELECT * FROM workspace;

-- ============================================================
-- 4. Негативный тест FK (ОЖИДАЕТСЯ ОШИБКА)
-- ============================================================
-- Негативный тест FK: ожидается ошибка
INSERT INTO workspace (coworking_id, type, code, capacity, price_per_hour)
VALUES (999999, 'desk', 'INVALID-01', 1, 150.00);
