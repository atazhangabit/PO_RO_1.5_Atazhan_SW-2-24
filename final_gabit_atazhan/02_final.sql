CREATE SCHEMA IF NOT EXISTS septic_service;

SET search_path TO septic_service;

DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_services CASCADE;
DROP TABLE IF EXISTS service_orders CASCADE;
DROP TABLE IF EXISTS drivers CASCADE;
DROP TABLE IF EXISTS vehicles CASCADE;
DROP TABLE IF EXISTS service_types CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    customer_type VARCHAR(20) NOT NULL DEFAULT 'individual',
    temporary_note VARCHAR(100),
    CONSTRAINT chk_customer_type
        CHECK (customer_type IN ('individual', 'business'))
);

CREATE TABLE IF NOT EXISTS addresses (
    address_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL,
    district VARCHAR(80) NOT NULL,
    street VARCHAR(120) NOT NULL,
    house_number VARCHAR(20) NOT NULL,
    septic_volume NUMERIC(8,2) NOT NULL,
    CONSTRAINT fk_address_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_septic_volume
        CHECK (septic_volume >= 0)
);

CREATE TABLE IF NOT EXISTS service_types (
    service_type_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL UNIQUE,
    base_price NUMERIC(10,2) NOT NULL,
    description TEXT,
    CONSTRAINT chk_service_price
        CHECK (base_price >= 0)
);

CREATE TABLE IF NOT EXISTS vehicles (
    vehicle_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    plate_number VARCHAR(20) NOT NULL UNIQUE,
    brand VARCHAR(80) NOT NULL,
    tank_capacity NUMERIC(8,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    CONSTRAINT chk_tank_capacity
        CHECK (tank_capacity > 0),
    CONSTRAINT chk_vehicle_status
        CHECK (status IN ('available', 'working', 'repair'))
);

CREATE TABLE IF NOT EXISTS drivers (
    driver_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    license_number VARCHAR(30) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'available',
    CONSTRAINT chk_driver_status
        CHECK (status IN ('available', 'busy', 'off'))
);

CREATE TABLE IF NOT EXISTS service_orders (
    order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    address_id INT NOT NULL,
    vehicle_id INT,
    driver_id INT,
    order_date DATE NOT NULL,
    requested_time TIME,
    status VARCHAR(20) NOT NULL DEFAULT 'new',
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_address
        FOREIGN KEY (address_id)
        REFERENCES addresses(address_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_vehicle
        FOREIGN KEY (vehicle_id)
        REFERENCES vehicles(vehicle_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_order_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_order_date
        CHECK (order_date > DATE '2026-01-01'),
    CONSTRAINT chk_order_status
        CHECK (status IN ('new', 'assigned', 'completed', 'cancelled'))
);

CREATE TABLE IF NOT EXISTS order_services (
    order_id INT NOT NULL,
    service_type_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price NUMERIC(10,2) NOT NULL,
    line_total NUMERIC(12,2)
        GENERATED ALWAYS AS (quantity * unit_price) STORED,
    PRIMARY KEY (order_id, service_type_id),
    CONSTRAINT fk_order_service_order
        FOREIGN KEY (order_id)
        REFERENCES service_orders(order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_order_service_type
        FOREIGN KEY (service_type_id)
        REFERENCES service_types(service_type_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_service_quantity
        CHECK (quantity > 0),
    CONSTRAINT chk_unit_price
        CHECK (unit_price >= 0)
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INT NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    paid_at TIMESTAMP,
    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES service_orders(order_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_payment_amount
        CHECK (amount > 0),
    CONSTRAINT chk_payment_method
        CHECK (payment_method IN ('cash', 'card', 'kaspi')),
    CONSTRAINT chk_payment_status
        CHECK (payment_status IN ('pending', 'paid', 'refunded'))
);

ALTER TABLE customers
ADD COLUMN IF NOT EXISTS email VARCHAR(120);

ALTER TABLE addresses
ADD COLUMN IF NOT EXISTS landmark VARCHAR(150);

ALTER TABLE vehicles
ADD COLUMN IF NOT EXISTS manufacture_year INT;

ALTER TABLE drivers
ADD COLUMN IF NOT EXISTS experience_years INT NOT NULL DEFAULT 0;

ALTER TABLE service_orders
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP;

INSERT INTO customers
(full_name, phone, customer_type, temporary_note)
VALUES
('Aidar Nurgaliyev', '+77011234567', 'individual', 'Call before arrival'),
('Dana Sarsenova', '+77022345678', 'individual', NULL),
('Caspian Cafe', '+77033456789', 'business', 'Service entrance'),
('Arman Tulegenov', '+77044567890', 'individual', NULL),
('Atyrau Market', '+77055678901', 'business', 'Work after closing');

INSERT INTO addresses
(customer_id, district, street, house_number, septic_volume)
VALUES
(
    (SELECT customer_id FROM customers WHERE phone = '+77011234567'),
    'Nursaya',
    'Satpayev Street',
    '15',
    5.00
),
(
    (SELECT customer_id FROM customers WHERE phone = '+77022345678'),
    'Avangard',
    'Auezov Street',
    '24',
    4.50
),
(
    (SELECT customer_id FROM customers WHERE phone = '+77033456789'),
    'Balykshi',
    'Abai Street',
    '10A',
    8.00
),
(
    (SELECT customer_id FROM customers WHERE phone = '+77044567890'),
    'Zhumysker',
    'Azattyk Street',
    '45',
    6.00
),
(
    (SELECT customer_id FROM customers WHERE phone = '+77055678901'),
    'Privokzalny',
    'Makhambet Street',
    '7',
    12.00
);

INSERT INTO service_types
(service_name, base_price, description)
VALUES
('Septic tank pumping', 15000, 'Standard septic tank pumping'),
('Cesspool cleaning', 18000, 'Cleaning of cesspools'),
('Pipe flushing', 12000, 'Flushing blocked pipes'),
('Emergency service', 25000, 'Urgent service'),
('Wastewater transport', 10000, 'Wastewater transportation');

INSERT INTO vehicles
(plate_number, brand, tank_capacity, status)
VALUES
('001AAA06', 'KamAZ', 10.00, 'available'),
('002BBB06', 'GAZ', 6.00, 'working'),
('003CCC06', 'MAN', 12.00, 'available'),
('004DDD06', 'Hyundai', 8.00, 'repair'),
('005EEE06', 'Isuzu', 7.00, 'available');

INSERT INTO drivers
(full_name, phone, license_number, status)
VALUES
('Murat Bekov', '+77061111111', 'ATY001', 'available'),
('Serik Omarov', '+77062222222', 'ATY002', 'busy'),
('Dias Karimov', '+77063333333', 'ATY003', 'available'),
('Nurlan Akhmetov', '+77064444444', 'ATY004', 'off'),
('Askar Zhanibekov', '+77065555555', 'ATY005', 'available');

INSERT INTO service_orders
(address_id, vehicle_id, driver_id, order_date, requested_time, status, notes)
VALUES
(
    (SELECT address_id
     FROM addresses
     WHERE street = 'Satpayev Street'
       AND house_number = '15'),
    (SELECT vehicle_id
     FROM vehicles
     WHERE plate_number = '001AAA06'),
    (SELECT driver_id
     FROM drivers
     WHERE license_number = 'ATY001'),
    '2026-06-20',
    '09:00',
    'assigned',
    'Standard service'
),
(
    (SELECT address_id
     FROM addresses
     WHERE street = 'Auezov Street'
       AND house_number = '24'),
    (SELECT vehicle_id
     FROM vehicles
     WHERE plate_number = '002BBB06'),
    (SELECT driver_id
     FROM drivers
     WHERE license_number = 'ATY002'),
    '2026-06-21',
    '11:00',
    'completed',
    NULL
),
(
    (SELECT address_id
     FROM addresses
     WHERE street = 'Abai Street'
       AND house_number = '10A'),
    (SELECT vehicle_id
     FROM vehicles
     WHERE plate_number = '003CCC06'),
    (SELECT driver_id
     FROM drivers
     WHERE license_number = 'ATY003'),
    '2026-06-22',
    '14:00',
    'new',
    'Business customer'
),
(
    (SELECT address_id
     FROM addresses
     WHERE street = 'Azattyk Street'
       AND house_number = '45'),
    (SELECT vehicle_id
     FROM vehicles
     WHERE plate_number = '005EEE06'),
    (SELECT driver_id
     FROM drivers
     WHERE license_number = 'ATY005'),
    '2026-06-23',
    '16:00',
    'assigned',
    'Urgent request'
),
(
    (SELECT address_id
     FROM addresses
     WHERE street = 'Makhambet Street'
       AND house_number = '7'),
    (SELECT vehicle_id
     FROM vehicles
     WHERE plate_number = '003CCC06'),
    (SELECT driver_id
     FROM drivers
     WHERE license_number = 'ATY003'),
    '2026-06-24',
    '19:00',
    'new',
    'Service after closing'
);

INSERT INTO order_services
(order_id, service_type_id, quantity, unit_price)
VALUES
(
    (SELECT order_id
     FROM service_orders
     WHERE order_date = '2026-06-20'),
    (SELECT service_type_id
     FROM service_types
     WHERE service_name = 'Septic tank pumping'),
    1,
    15000
),
(
    (SELECT order_id
     FROM service_orders
     WHERE order_date = '2026-06-20'),
    (SELECT service_type_id
     FROM service_types
     WHERE service_name = 'Emergency service'),
    1,
    25000
),
(
    (SELECT order_id
     FROM service_orders
     WHERE order_date = '2026-06-21'),
    (SELECT service_type_id
     FROM service_types
     WHERE service_name = 'Cesspool cleaning'),
    1,
    18000
),
(
    (SELECT order_id
     FROM service_orders
     WHERE order_date = '2026-06-22'),
    (SELECT service_type_id
     FROM service_types
     WHERE service_name = 'Pipe flushing'),
    2,
    12000
),
(
    (SELECT order_id
     FROM service_orders
     WHERE order_date = '2026-06-23'),
    (SELECT service_type_id
     FROM service_types
     WHERE service_name = 'Emergency service'),
    1,
    25000
),
(
    (SELECT order_id
     FROM service_orders
     WHERE order_date = '2026-06-24'),
    (SELECT service_type_id
     FROM service_types
     WHERE service_name = 'Wastewater transport'),
    3,
    10000
);

INSERT INTO payments
(order_id, amount, payment_method, payment_status, paid_at)
VALUES
(
    (SELECT order_id
     FROM service_orders
     WHERE order_date = '2026-06-20'),
    40000,
    'kaspi',
    'paid',
    '2026-06-20 10:30:00'
),
(
    (SELECT order_id
     FROM service_orders
     WHERE order_date = '2026-06-21'),
    18000,
    'cash',
    'paid',
    '2026-06-21 12:30:00'
),
(
    (SELECT order_id
     FROM service_orders
     WHERE order_date = '2026-06-22'),
    24000,
    'card',
    'pending',
    NULL
),
(
    (SELECT order_id
     FROM service_orders
     WHERE order_date = '2026-06-23'),
    25000,
    'kaspi',
    'paid',
    '2026-06-23 17:30:00'
),
(
    (SELECT order_id
     FROM service_orders
     WHERE order_date = '2026-06-24'),
    30000,
    'cash',
    'pending',
    NULL
);

UPDATE customers
SET email = LOWER(REPLACE(full_name, ' ', '.')) || '@mail.kz'
WHERE email IS NULL;

UPDATE addresses
SET landmark = CASE
    WHEN district = 'Nursaya' THEN 'Near Atyrau Mall'
    WHEN district = 'Avangard' THEN 'Near School 17'
    WHEN district = 'Balykshi' THEN 'Near the market'
    WHEN district = 'Zhumysker' THEN 'Near the mosque'
    WHEN district = 'Privokzalny' THEN 'Near the railway station'
END
WHERE landmark IS NULL;

UPDATE vehicles
SET manufacture_year = CASE
    WHEN plate_number = '001AAA06' THEN 2018
    WHEN plate_number = '002BBB06' THEN 2016
    WHEN plate_number = '003CCC06' THEN 2020
    WHEN plate_number = '004DDD06' THEN 2019
    WHEN plate_number = '005EEE06' THEN 2021
END
WHERE manufacture_year IS NULL;

UPDATE drivers
SET experience_years = CASE
    WHEN license_number = 'ATY001' THEN 8
    WHEN license_number = 'ATY002' THEN 6
    WHEN license_number = 'ATY003' THEN 5
    WHEN license_number = 'ATY004' THEN 10
    WHEN license_number = 'ATY005' THEN 4
END;

UPDATE service_orders
SET status = 'completed',
    completed_at = '2026-06-22 16:30:00'
WHERE order_date = '2026-06-22';

UPDATE payments p
SET payment_status = 'paid',
    paid_at = so.completed_at
FROM service_orders so
WHERE p.order_id = so.order_id
  AND so.status = 'completed'
  AND p.payment_status = 'pending';

DELETE FROM drivers
WHERE license_number = 'ATY004'
  AND status = 'off';

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'septic_manager_role'
    ) THEN
        CREATE ROLE septic_manager_role;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'septic_readonly_role'
    ) THEN
        CREATE ROLE septic_readonly_role;
    END IF;
END $$;

GRANT CONNECT ON DATABASE septic_service_db
TO septic_manager_role, septic_readonly_role;

GRANT USAGE ON SCHEMA septic_service
TO septic_manager_role, septic_readonly_role;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA septic_service
TO septic_manager_role;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA septic_service
TO septic_manager_role;

GRANT SELECT
ON ALL TABLES IN SCHEMA septic_service
TO septic_readonly_role;

REVOKE DELETE
ON septic_service.payments
FROM septic_manager_role;

SET search_path TO septic_service;

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM addresses;
SELECT COUNT(*) FROM service_types;
SELECT COUNT(*) FROM vehicles;
SELECT COUNT(*) FROM drivers;
SELECT COUNT(*) FROM service_orders;
SELECT COUNT(*) FROM order_services;
SELECT COUNT(*) FROM payments;