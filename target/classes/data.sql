-- Initial Admin User
INSERT INTO users (username, password, email, first_name, last_name, role, department, created_at, updated_at)
VALUES (
    'admin',
    '$2a$10$rS.bpL0xUkdF9kROS3WQZeQE0qv3k2nW7RMTB9.H.Jq/LGDVyXnPK', -- password: admin123
    'admin@company.com',
    'System',
    'Administrator',
    'ADMIN',
    'IT',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
) ON DUPLICATE KEY UPDATE username = username;

-- Sample Departments Pay Scales
INSERT INTO pay_scales (title, hourly_rate, overtime_rate, department, effective_from, created_at)
VALUES
    ('IT Staff', 25.00, 37.50, 'IT', '2023-01-01', CURRENT_TIMESTAMP),
    ('HR Staff', 22.00, 33.00, 'HR', '2023-01-01', CURRENT_TIMESTAMP),
    ('Finance Staff', 27.00, 40.50, 'Finance', '2023-01-01', CURRENT_TIMESTAMP),
    ('Operations Staff', 20.00, 30.00, 'Operations', '2023-01-01', CURRENT_TIMESTAMP),
    ('Sales Staff', 18.00, 27.00, 'Sales', '2023-01-01', CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE title = VALUES(title);

-- Sample Employee Users
INSERT INTO users (username, password, email, first_name, last_name, role, department, created_at, updated_at)
VALUES
    (
        'john.doe',
        '$2a$10$rS.bpL0xUkdF9kROS3WQZeQE0qv3k2nW7RMTB9.H.Jq/LGDVyXnPK', -- password: password123
        'john.doe@company.com',
        'John',
        'Doe',
        'EMPLOYEE',
        'IT',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'jane.smith',
        '$2a$10$rS.bpL0xUkdF9kROS3WQZeQE0qv3k2nW7RMTB9.H.Jq/LGDVyXnPK', -- password: password123
        'jane.smith@company.com',
        'Jane',
        'Smith',
        'EMPLOYEE',
        'HR',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'bob.wilson',
        '$2a$10$rS.bpL0xUkdF9kROS3WQZeQE0qv3k2nW7RMTB9.H.Jq/LGDVyXnPK', -- password: password123
        'bob.wilson@company.com',
        'Bob',
        'Wilson',
        'EMPLOYEE',
        'Finance',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
ON DUPLICATE KEY UPDATE username = username;

-- Sample Work Logs (for the current month)
INSERT INTO work_logs (user_id, date, start_time, end_time, break_duration, remarks, status, created_at)
SELECT 
    u.id,
    CURRENT_DATE - INTERVAL (a.a + (10 * b.a) + (100 * c.a)) DAY,
    '09:00:00',
    '17:00:00',
    30,
    'Regular work day',
    'APPROVED',
    CURRENT_TIMESTAMP
FROM users u
CROSS JOIN (SELECT 0 AS a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) AS a
CROSS JOIN (SELECT 0 AS a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) AS b
CROSS JOIN (SELECT 0 AS a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) AS c
WHERE u.role = 'EMPLOYEE'
AND (a.a + (10 * b.a) + (100 * c.a)) < 30
AND DAYOFWEEK(CURRENT_DATE - INTERVAL (a.a + (10 * b.a) + (100 * c.a)) DAY) NOT IN (1, 7)
ON DUPLICATE KEY UPDATE user_id = user_id;

-- Sample Payroll Records (for the previous month)
INSERT INTO payroll_records (
    user_id,
    pay_period_start,
    pay_period_end,
    regular_hours,
    overtime_hours,
    gross_pay,
    deductions,
    net_pay,
    status,
    created_at
)
SELECT 
    u.id,
    DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y-%m-01'),
    DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y-%m-15'),
    160.00,
    10.00,
    (160.00 * ps.hourly_rate) + (10.00 * ps.overtime_rate),
    ((160.00 * ps.hourly_rate) + (10.00 * ps.overtime_rate)) * 0.2,
    ((160.00 * ps.hourly_rate) + (10.00 * ps.overtime_rate)) * 0.8,
    'PAID',
    CURRENT_TIMESTAMP
FROM users u
JOIN pay_scales ps ON u.department = ps.department
WHERE u.role = 'EMPLOYEE'
ON DUPLICATE KEY UPDATE user_id = user_id;
