
# ER-диаграмма платформы бронирования коворкингов

Диаграмма описывает сущности платформы бронирования,
их атрибуты и связи между ними.

```mermaid
erDiagram
    direction LR
    USER ||--o{ BOOKING : creates
    USER ||--o{ COWORKING : manages
    COWORKING ||--o{ WORKSPACE : contains
    WORKSPACE ||--o{ BOOKING : booked_for
    BOOKING ||--o{ PAYMENT : has

    USER {
        int user_id PK
        string email UK
        string name
        string password_hash
        string role
    }

    COWORKING {
        int coworking_id PK
        string name
        string address
        time opens_at
        time closes_at
        int manager_id FK
    }

    WORKSPACE {
        int workspace_id PK
        int coworking_id FK
        string type
        string code
        int capacity
        decimal price_per_hour
        boolean is_active
    }

    BOOKING {
        int booking_id PK
        int workspace_id FK
        int user_id FK
        datetime start_time
        datetime end_time
        string status
        datetime created_at
    }

    PAYMENT {
        int payment_id PK
        int booking_id FK
        decimal amount
        string status
        datetime paid_at
        datetime refunded_at
    }
```

## Особенности модели

- M:N между USER и WORKSPACE реализована через BOOKING.
- У каждой сущности есть собственный PK.
- Email пользователя является альтернативным уникальным ключом.
- Код рабочего места уникален в пределах одного коворкинга (составной AK: coworking_id + code).
- Рекурсивная связь и слабая сущность не используются, так как в текущей предметной области они не требуются.
- Многозначные атрибуты в текущей модели отсутствуют.
