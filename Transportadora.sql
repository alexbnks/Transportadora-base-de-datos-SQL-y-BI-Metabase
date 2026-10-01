-- 1. Crear e indicar el uso de la base de datos
CREATE DATABASE IF NOT EXISTS transportadora_db;
USE transportadora_db;

-- 2. Categorías y capacidades de vehículos
CREATE TABLE vehicle_types (
    vehicle_type_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,       -- 'SUB', 'HIACE', 'SPRINTER', 'BUS', 'ESCALADE'
    name VARCHAR(50) NOT NULL,
    max_passengers INT NOT NULL
);

-- 3. Zonas operativas
CREATE TABLE zones (
    zone_id INT AUTO_INCREMENT PRIMARY KEY,
    zone_name VARCHAR(50) NOT NULL UNIQUE
);

-- 4. Matriz de Tarifas
CREATE TABLE rates (
    rate_id INT AUTO_INCREMENT PRIMARY KEY,
    zone_id INT NOT NULL,
    vehicle_type_id INT NOT NULL,
    trip_type ENUM('oneway', 'roundtrip') NOT NULL,
    price_usd DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (zone_id) REFERENCES zones(zone_id),
    FOREIGN KEY (vehicle_type_id) REFERENCES vehicle_types(vehicle_type_id),
    CONSTRAINT unique_rate UNIQUE (zone_id, vehicle_type_id, trip_type)
);

-- Insertar Tipos de Vehículos con sus capacidades
INSERT INTO vehicle_types (code, name, max_passengers) VALUES
('SUB', 'Suburban / SUV Similar', 6),
('HIACE', 'Toyota Hiace', 10),
('SPRINTER', 'Mercedes Sprinter', 16),
('BUS', 'Bus Operativo', 45),
('ESCALADE', 'Cadillac Escalade', 5);

-- Insertar Zonas Geográficas
INSERT INTO zones (zone_name) VALUES
('SAN JOSE'),
('CORREDOR'),
('CABO SAN LUCAS'),
('PACIFICO'),
('DIAMANTE');

-- Insertar la Matriz de Tarifas completa (Oneway y Roundtrip)
INSERT INTO rates (zone_id, vehicle_type_id, trip_type, price_usd) VALUES
-- SAN JOSE (Zone 1)
(1, 1, 'oneway', 60.00), (1, 1, 'roundtrip', 120.00), -- SUB
(1, 2, 'oneway', 60.00), (1, 2, 'roundtrip', 120.00), -- HIACE
(1, 3, 'oneway', 80.00), (1, 3, 'roundtrip', 160.00), -- SPRINTER
(1, 4, 'oneway', 240.00), (1, 4, 'roundtrip', 480.00),-- BUS
(1, 5, 'oneway', 80.00), (1, 5, 'roundtrip', 160.00), -- ESCALADE

-- CORREDOR (Zone 2)
(2, 1, 'oneway', 70.00), (2, 1, 'roundtrip', 140.00),
(2, 2, 'oneway', 70.00), (2, 2, 'roundtrip', 140.00),
(2, 3, 'oneway', 90.00), (2, 3, 'roundtrip', 180.00),
(2, 4, 'oneway', 250.00), (2, 4, 'roundtrip', 500.00),
(2, 5, 'oneway', 90.00), (2, 5, 'roundtrip', 180.00),

-- CABO SAN LUCAS (Zone 3)
(3, 1, 'oneway', 80.00), (3, 1, 'roundtrip', 160.00),
(3, 2, 'oneway', 80.00), (3, 2, 'roundtrip', 160.00),
(3, 3, 'oneway', 100.00), (3, 3, 'roundtrip', 200.00),
(3, 4, 'oneway', 270.00), (3, 4, 'roundtrip', 540.00),
(3, 5, 'oneway', 100.00), (3, 5, 'roundtrip', 200.00),

-- PACIFICO (Zone 4)
(4, 1, 'oneway', 90.00), (4, 1, 'roundtrip', 180.00),
(4, 2, 'oneway', 90.00), (4, 2, 'roundtrip', 180.00),
(4, 3, 'oneway', 110.00), (4, 3, 'roundtrip', 220.00),
(4, 4, 'oneway', 280.00), (4, 4, 'roundtrip', 560.00),
(4, 5, 'oneway', 110.00), (4, 5, 'roundtrip', 220.00),

-- DIAMANTE (Zone 5)
(5, 1, 'oneway', 100.00), (5, 1, 'roundtrip', 200.00),
(5, 2, 'oneway', 100.00), (5, 2, 'roundtrip', 200.00),
(5, 3, 'oneway', 120.00), (5, 3, 'roundtrip', 240.00),
(5, 4, 'oneway', 290.00), (5, 4, 'roundtrip', 580.00),
(5, 5, 'oneway', 120.00), (5, 5, 'roundtrip', 240.00);


SELECT 
    z.zone_name AS zona,
    vt.code AS vehiculo,
    vt.max_passengers AS capacidad,
    r.trip_type AS tipo_viaje,
    r.price_usd AS precio_usd,
    (r.price_usd * 17.50) AS precio_aprox_mxn
FROM rates r
JOIN zones z ON r.zone_id = z.zone_id
JOIN vehicle_types vt ON r.vehicle_type_id = vt.vehicle_type_id
ORDER BY z.zone_id, vt.vehicle_type_id, r.trip_type;


USE transportadora_db;

-- 5. Clientes
CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(25),
    country VARCHAR(50) DEFAULT 'USA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Choferes
CREATE TABLE drivers (
    driver_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    phone VARCHAR(25),
    license_number VARCHAR(30) UNIQUE NOT NULL,
    status ENUM('active', 'inactive', 'on_trip') DEFAULT 'active'
);

-- 7. Flota Vehicular Física
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_type_id INT NOT NULL,
    model VARCHAR(50) NOT NULL,            -- ej. 'Suburban LT 2024'
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    status ENUM('active', 'maintenance', 'out_of_service') DEFAULT 'active',
    FOREIGN KEY (vehicle_type_id) REFERENCES vehicle_types(vehicle_type_id)
);

-- 8. Reservaciones (Tabla Central de Negocio)
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_code VARCHAR(20) UNIQUE NOT NULL,      -- ej. 'MCT-2026-1001'
    client_id INT NOT NULL,
    rate_id INT NOT NULL,                          -- Conecta con zona, tipo vehículo y trip_type
    vehicle_id INT NULL,                           -- Se asigna al confirmar/despachar
    driver_id INT NULL,                            -- Se asigna al confirmar/despachar
    
    -- Detalles del Servicio y Vuelo
    passengers INT NOT NULL,
    pickup_datetime DATETIME NOT NULL,
    airline VARCHAR(50),
    flight_number VARCHAR(20),
    hotel_destination VARCHAR(120),                -- ej. 'Riu Palace', 'Hard Rock Cabo'
    
    -- Control Financiero
    exchange_rate DECIMAL(10,4) DEFAULT 17.5000,   -- Tipo de cambio
    total_usd DECIMAL(10,2) NOT NULL,
    total_mxn DECIMAL(10,2) GENERATED ALWAYS AS (total_usd * exchange_rate) STORED,
    
    -- Estatus del Flujo de Trabajo
    status ENUM('quoted', 'confirmed', 'assigned', 'completed', 'cancelled') DEFAULT 'quoted',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (rate_id) REFERENCES rates(rate_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

-- 9. Transacciones de Pago
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    payment_method ENUM('stripe', 'paypal', 'credit_card', 'cash', 'wire_transfer') NOT NULL,
    payment_status ENUM('pending', 'completed', 'refunded') DEFAULT 'completed',
    amount_usd DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id)
);

USE transportadora_db;

-- 1. Insertar Choferes
INSERT INTO drivers (full_name, phone, license_number, status) VALUES
('Carlos Mendoza', '+52 624 123 4567', 'LIC-MX-001298', 'active'),
('José Luis Reyes', '+52 624 234 5678', 'LIC-MX-003451', 'active'),
('Alejandro Gómez', '+52 624 345 6789', 'LIC-MX-009812', 'active'),
('Roberto Martínez', '+52 624 456 7890', 'LIC-MX-004523', 'active'),
('Fernando Castillo', '+52 624 567 8901', 'LIC-MX-007123', 'active'),
('Daniel Sánchez', '+52 624 678 9012', 'LIC-MX-008911', 'active');

-- 2. Insertar Flota Vehicular Física
-- Nota: vehicle_type_id (1: SUB, 2: HIACE, 3: SPRINTER, 4: BUS, 5: ESCALADE)
INSERT INTO vehicles (vehicle_type_id, model, license_plate, status) VALUES
(1, 'Chevrolet Suburban 2023', 'CBO-101-A', 'active'),
(1, 'GMC Yukon XL 2024', 'CBO-102-A', 'active'),
(2, 'Toyota Hiace Executive 2022', 'CBO-201-B', 'active'),
(2, 'Toyota Hiace Grand 2023', 'CBO-202-B', 'active'),
(3, 'Mercedes-Benz Sprinter 2023', 'CBO-301-C', 'active'),
(3, 'Mercedes-Benz Sprinter VIP 2024', 'CBO-302-C', 'active'),
(4, 'Irizar Bus 2022', 'CBO-401-D', 'active'),
(5, 'Cadillac Escalade ESV 2024', 'CBO-501-E', 'active');


USE transportadora_db;

-- 1. Añadir reservaciones


-- 2. Inserción masiva de reservaciones de prueba
INSERT INTO reservations 
(booking_code, client_id, rate_id, vehicle_id, driver_id, passengers, pickup_datetime, airline, flight_number, hotel_destination, exchange_rate, total_usd, status)
VALUES
('MCT-2026-1001', 1, 1, 1, 1, 2, '2025-10-15 10:30:00', 'American Airlines', 'AA-452', 'Barcelo Gran Faro Los Cabos', 17.50, 60.00, 'completed'),
('MCT-2026-1002', 2, 2, 3, 2, 5, '2025-10-16 12:00:00', 'Delta Air Lines', 'DL-891', 'Hyatt Ziva', 17.50, 70.00, 'completed'),
('MCT-2026-1003', 3, 3, 5, 3, 8, '2025-10-17 14:15:00', 'United Airlines', 'UA-204', 'Grand Velas Los Cabos', 17.50, 100.00, 'completed'),
('MCT-2026-1004', 4, 1, NULL, NULL, 1, '2025-10-18 09:00:00', 'Volaris', 'Y4-710', 'Posada Real', 17.50, 60.00, 'cancelled'),
('MCT-2026-1005', 5, 4, 7, 4, 15, '2025-10-19 16:45:00', 'Alaska Airlines', 'AS-332', 'Hard Rock Hotel', 17.50, 280.00, 'completed'),
('MCT-2026-1006', 6, 5, 8, 5, 3, '2025-10-20 11:30:00', 'American Airlines', 'AA-109', 'Nobu Hotel', 17.50, 120.00, 'completed'),
('MCT-2026-1007', 7, 2, 2, 6, 4, '2025-10-21 13:00:00', 'Delta Air Lines', 'DL-554', 'Pueblo Bonito Sunset', 17.50, 90.00, 'confirmed'),
('MCT-2026-1008', 8, 3, 6, 1, 7, '2025-10-22 15:20:00', 'United Airlines', 'UA-881', 'Riu Palace Cabo San Lucas', 17.50, 100.00, 'completed'),
('MCT-2026-1009', 9, 1, 1, 2, 2, '2025-10-23 08:45:00', 'Volaris', 'Y4-502', 'Casa Natalia', 17.50, 60.00, 'completed'),
('MCT-2026-1010', 10, 2, NULL, NULL, 3, '2025-10-24 17:10:00', 'Alaska Airlines', 'AS-118', 'Montage Los Cabos', 17.50, 90.00, 'cancelled'),
('MCT-2026-1011', 11, 3, 4, 3, 6, '2025-11-01 10:00:00', 'American Airlines', 'AA-672', 'Breathless', 17.50, 100.00, 'completed'),
('MCT-2026-1012', 12, 4, 7, 4, 12, '2025-11-02 12:30:00', 'Delta Air Lines', 'DL-443', 'Diamante Cabo San Lucas', 17.50, 290.00, 'completed'),
('MCT-2026-1013', 13, 5, 8, 5, 2, '2025-11-03 14:00:00', 'United Airlines', 'UA-901', 'Four Seasons Resort', 17.50, 120.00, 'confirmed'),
('MCT-2026-1014', 14, 1, 2, 6, 4, '2025-11-04 16:15:00', 'Volaris', 'Y4-220', 'Krystal Grand', 17.50, 60.00, 'completed'),
('MCT-2026-1015', 15, 2, 3, 1, 5, '2025-11-05 09:30:00', 'Alaska Airlines', 'AS-890', 'Solaz', 17.50, 90.00, 'completed'),
('MCT-2026-1016', 16, 3, 5, 2, 8, '2025-11-06 11:45:00', 'American Airlines', 'AA-304', 'Villa del Palmar', 17.50, 100.00, 'completed'),
('MCT-2026-1017', 17, 1, NULL, NULL, 2, '2025-11-07 13:20:00', 'Delta Air Lines', 'DL-112', 'Hotel Tropicana', 17.50, 60.00, 'cancelled'),
('MCT-2026-1018', 18, 4, 7, 3, 18, '2025-11-08 15:00:00', 'United Airlines', 'UA-773', 'Quivira Los Cabos', 17.50, 290.00, 'completed'),
('MCT-2026-1019', 19, 5, 8, 4, 3, '2025-11-09 18:30:00', 'Volaris', 'Y4-881', 'Waldorf Astoria Pedregal', 17.50, 120.00, 'completed'),
('MCT-2026-1020', 20, 2, 4, 5, 6, '2025-11-10 10:15:00', 'Alaska Airlines', 'AS-405', 'Secrets Puerto Los Cabos', 17.50, 90.00, 'completed');



--1. Añadir clientes 

INSERT IGNORE INTO clients (client_id, full_name, email, phone, country) VALUES
(1, 'John Smith', 'john.smith@example.com', '+1 555-0101', 'USA'),
(2, 'Sarah Johnson', 'sarah.j@example.com', '+1 555-0102', 'USA'),
(3, 'Michael Brown', 'mbrown@example.com', '+1 555-0103', 'USA'),
(4, 'Emily Davis', 'emily.davis@example.com', '+1 555-0104', 'Canada'),
(5, 'David Wilson', 'dwilson@example.com', '+1 555-0105', 'USA'),
(6, 'Jessica Taylor', 'jtaylor@example.com', '+1 555-0106', 'USA'),
(7, 'James Anderson', 'j.anderson@example.com', '+1 555-0107', 'Canada'),
(8, 'Amanda Thomas', 'athomas@example.com', '+1 555-0108', 'USA'),
(9, 'Robert Jackson', 'rjackson@example.com', '+1 555-0109', 'Mexico'),
(10, 'Jennifer White', 'jwhite@example.com', '+1 555-0110', 'USA'),
(11, 'Daniel Harris', 'dharris@example.com', '+1 555-0111', 'USA'),
(12, 'Lisa Martin', 'lmartin@example.com', '+1 555-0112', 'Canada'),
(13, 'Christopher Thompson', 'cthompson@example.com', '+1 555-0113', 'USA'),
(14, 'Nancy Garcia', 'ngarcia@example.com', '+1 555-0114', 'USA'),
(15, 'Paul Martinez', 'pmartinez@example.com', '+1 555-0115', 'Mexico'),
(16, 'Karen Robinson', 'krobinson@example.com', '+1 555-0116', 'USA'),
(17, 'Mark Clark', 'mclark@example.com', '+1 555-0117', 'USA'),
(18, 'Betty Rodriguez', 'brodriguez@example.com', '+1 555-0118', 'USA'),
(19, 'Donald Lewis', 'dlewis@example.com', '+1 555-0119', 'USA'),
(20, 'Sandra Lee', 'slee@example.com', '+1 555-0120', 'Canada');

    
    
    
    USE transportadora_db;

-- 1. Insertar 50 clientes adicionales (IDs del 21 al 70)
INSERT IGNORE INTO clients (client_id, full_name, email, phone, country) VALUES
(21, 'Mark Stevenson', 'mark.stevenson@example.com', '+1 555-0201', 'USA'),
(22, 'Laura Miller', 'laura.m@example.com', '+1 555-0202', 'USA'),
(23, 'Kevin Adams', 'kadams@example.com', '+1 555-0203', 'Canada'),
(24, 'Rachel Green', 'rachel.g@example.com', '+1 555-0204', 'USA'),
(25, 'Thomas Wright', 'twright@example.com', '+1 555-0205', 'USA'),
(26, 'Brian Scott', 'bscott@example.com', '+1 555-0206', 'Canada'),
(27, 'Megan Torres', 'mtorres@example.com', '+1 555-0207', 'USA'),
(28, 'Jason King', 'jking@example.com', '+1 555-0208', 'USA'),
(29, 'Hannah Baker', 'hbaker@example.com', '+1 555-0209', 'Mexico'),
(30, 'Eric Hill', 'ehill@example.com', '+1 555-0210', 'USA'),
(31, 'Andrew Flores', 'aflores@example.com', '+1 555-0211', 'USA'),
(32, 'Stephanie Green', 'sgreen@example.com', '+1 555-0212', 'Canada'),
(33, 'Joshua Nelson', 'jnelson@example.com', '+1 555-0213', 'USA'),
(34, 'Rebecca Carter', 'rcarter@example.com', '+1 555-0214', 'USA'),
(35, 'Ryan Mitchell', 'rmitchell@example.com', '+1 555-0215', 'Mexico'),
(36, 'Lauren Perez', 'lperez@example.com', '+1 555-0216', 'USA'),
(37, 'Justin Roberts', 'jroberts@example.com', '+1 555-0217', 'USA'),
(38, 'Victoria Turner', 'vturner@example.com', '+1 555-0218', 'USA'),
(39, 'Brandon Phillips', 'bphillips@example.com', '+1 555-0219', 'USA'),
(40, 'Samantha Campbell', 'scampbell@example.com', '+1 555-0220', 'Canada'),
(41, 'Jonathan Parker', 'jparker@example.com', '+1 555-0221', 'USA'),
(42, 'Ashley Evans', 'aevans@example.com', '+1 555-0222', 'USA'),
(43, 'Benjamin Edwards', 'bedwards@example.com', '+1 555-0223', 'USA'),
(44, 'Brittany Collins', 'bcollins@example.com', '+1 555-0224', 'Canada'),
(45, 'Samuel Stewart', 'sstewart@example.com', '+1 555-0225', 'USA'),
(46, 'Amanda Sanchez', 'asanchez@example.com', '+1 555-0226', 'Mexico'),
(47, 'Patrick Morris', 'pmorris@example.com', '+1 555-0227', 'USA'),
(48, 'Melissa Rogers', 'mrogers@example.com', '+1 555-0228', 'USA'),
(49, 'Alexander Reed', 'areed@example.com', '+1 555-0229', 'USA'),
(50, 'Deborah Cook', 'dcook@example.com', '+1 555-0230', 'Canada'),
(51, 'Jack Morgan', 'jmorgan@example.com', '+1 555-0231', 'USA'),
(52, 'Olivia Bell', 'obell@example.com', '+1 555-0232', 'USA'),
(53, 'Dennis Murphy', 'dmurphy@example.com', '+1 555-0233', 'USA'),
(54, 'Catherine Bailey', 'cbailey@example.com', '+1 555-0234', 'USA'),
(55, 'Jerry Rivera', 'jrivera@example.com', '+1 555-0235', 'Mexico'),
(56, 'Christine Cooper', 'ccooper@example.com', '+1 555-0236', 'Canada'),
(57, 'Tyler Richardson', 'trichardson@example.com', '+1 555-0237', 'USA'),
(58, 'Samantha Cox', 'scox@example.com', '+1 555-0238', 'USA'),
(59, 'Aaron Howard', 'ahoward@example.com', '+1 555-0239', 'USA'),
(60, 'Debra Ward', 'dward@example.com', '+1 555-0240', 'USA'),
(61, 'Henry Torres', 'htorres@example.com', '+1 555-0241', 'USA'),
(62, 'Ruth Peterson', 'rpeterson@example.com', '+1 555-0242', 'Canada'),
(63, 'Douglas Gray', 'dgray@example.com', '+1 555-0243', 'USA'),
(64, 'Carol Ramirez', 'cramirez@example.com', '+1 555-0244', 'Mexico'),
(65, 'Peter James', 'pjames@example.com', '+1 555-0245', 'USA'),
(66, 'Maria Watson', 'mwatson@example.com', '+1 555-0246', 'USA'),
(67, 'Walter Brooks', 'wbrooks@example.com', '+1 555-0247', 'USA'),
(68, 'Heather Kelly', 'hkelly@example.com', '+1 555-0248', 'Canada'),
(69, 'Harold Sanders', 'hsanders@example.com', '+1 555-0249', 'USA'),
(70, 'Teresa Price', 'tprice@example.com', '+1 555-0250', 'USA');

-- 2. Insertar 50 reservaciones adicionales
INSERT INTO reservations 
(booking_code, client_id, rate_id, vehicle_id, driver_id, passengers, pickup_datetime, airline, flight_number, hotel_destination, exchange_rate, total_usd, status)
VALUES
('MCT-2026-1021', 21, 1, 1, 1, 2, '2025-11-11 09:00:00', 'American Airlines', 'AA-101', 'Barcelo Gran Faro Los Cabos', 17.50, 60.00, 'completed'),
('MCT-2026-1022', 22, 2, 3, 2, 4, '2025-11-11 11:30:00', 'Delta Air Lines', 'DL-202', 'Hyatt Ziva', 17.50, 70.00, 'completed'),
('MCT-2026-1023', 23, 3, 5, 3, 6, '2025-11-12 10:15:00', 'United Airlines', 'UA-303', 'Grand Velas Los Cabos', 17.50, 100.00, 'completed'),
('MCT-2026-1024', 24, 4, 7, 4, 12, '2025-11-12 14:00:00', 'Alaska Airlines', 'AS-404', 'Hard Rock Hotel', 17.50, 280.00, 'completed'),
('MCT-2026-1025', 25, 5, 8, 5, 3, '2025-11-13 16:45:00', 'Volaris', 'Y4-505', 'Nobu Hotel', 17.50, 120.00, 'completed'),
('MCT-2026-1026', 26, 2, 2, 6, 5, '2025-11-13 18:20:00', 'American Airlines', 'AA-606', 'Pueblo Bonito Sunset', 17.50, 90.00, 'confirmed'),
('MCT-2026-1027', 27, 3, 6, 1, 8, '2025-11-14 08:30:00', 'Delta Air Lines', 'DL-707', 'Riu Palace Cabo San Lucas', 17.50, 100.00, 'completed'),
('MCT-2026-1028', 28, 1, 1, 2, 2, '2025-11-14 12:00:00', 'United Airlines', 'UA-808', 'Casa Natalia', 17.50, 60.00, 'completed'),
('MCT-2026-1029', 29, 2, 4, 3, 4, '2025-11-15 13:10:00', 'Alaska Airlines', 'AS-909', 'Solaz', 17.50, 90.00, 'completed'),
('MCT-2026-1030', 30, 3, 5, 4, 7, '2025-11-15 15:50:00', 'Volaris', 'Y4-010', 'Breathless', 17.50, 100.00, 'completed'),
('MCT-2026-1031', 31, 4, 7, 5, 14, '2025-11-16 10:00:00', 'American Airlines', 'AA-111', 'Diamante Cabo San Lucas', 17.50, 290.00, 'completed'),
('MCT-2026-1032', 32, 5, 8, 6, 2, '2025-11-16 11:45:00', 'Delta Air Lines', 'DL-222', 'Four Seasons Resort', 17.50, 120.00, 'completed'),
('MCT-2026-1033', 33, 1, NULL, NULL, 1, '2025-11-17 13:30:00', 'United Airlines', 'UA-333', 'Posada Real', 17.50, 60.00, 'cancelled'),
('MCT-2026-1034', 34, 2, 3, 1, 3, '2025-11-17 16:00:00', 'Alaska Airlines', 'AS-444', 'Montage Los Cabos', 17.50, 90.00, 'completed'),
('MCT-2026-1035', 35, 3, 5, 2, 6, '2025-11-18 09:15:00', 'Volaris', 'Y4-555', 'Villa del Palmar', 17.50, 100.00, 'completed'),
('MCT-2026-1036', 36, 4, 7, 3, 10, '2025-11-18 12:30:00', 'American Airlines', 'AA-666', 'Quivira Los Cabos', 17.50, 290.00, 'completed'),
('MCT-2026-1037', 37, 5, 8, 4, 4, '2025-11-19 14:10:00', 'Delta Air Lines', 'DL-777', 'Waldorf Astoria Pedregal', 17.50, 120.00, 'completed'),
('MCT-2026-1038', 38, 2, 2, 5, 5, '2025-11-19 17:20:00', 'United Airlines', 'UA-888', 'Secrets Puerto Los Cabos', 17.50, 90.00, 'completed'),
('MCT-2026-1039', 39, 1, 1, 6, 2, '2025-11-20 10:45:00', 'Alaska Airlines', 'AS-999', 'Krystal Grand', 17.50, 60.00, 'completed'),
('MCT-2026-1040', 40, 3, 6, 1, 8, '2025-11-20 13:00:00', 'Volaris', 'Y4-100', 'Riu Palace Cabo San Lucas', 17.50, 100.00, 'completed'),
('MCT-2026-1041', 41, 1, 1, 2, 2, '2025-11-21 08:30:00', 'American Airlines', 'AA-201', 'Barcelo Gran Faro Los Cabos', 17.50, 60.00, 'completed'),
('MCT-2026-1042', 42, 2, 3, 3, 4, '2025-11-21 11:15:00', 'Delta Air Lines', 'DL-302', 'Hyatt Ziva', 17.50, 70.00, 'completed'),
('MCT-2026-1043', 43, 3, 5, 4, 6, '2025-11-22 13:40:00', 'United Airlines', 'UA-403', 'Grand Velas Los Cabos', 17.50, 100.00, 'completed'),
('MCT-2026-1044', 44, 4, NULL, NULL, 10, '2025-11-22 16:00:00', 'Alaska Airlines', 'AS-504', 'Hard Rock Hotel', 17.50, 280.00, 'cancelled'),
('MCT-2026-1045', 45, 5, 8, 5, 3, '2025-11-23 09:20:00', 'Volaris', 'Y4-605', 'Nobu Hotel', 17.50, 120.00, 'completed'),
('MCT-2026-1046', 46, 2, 2, 6, 5, '2025-11-23 12:10:00', 'American Airlines', 'AA-706', 'Pueblo Bonito Sunset', 17.50, 90.00, 'completed'),
('MCT-2026-1047', 47, 3, 6, 1, 7, '2025-11-24 14:30:00', 'Delta Air Lines', 'DL-807', 'Riu Palace Cabo San Lucas', 17.50, 100.00, 'completed'),
('MCT-2026-1048', 48, 1, 1, 2, 2, '2025-11-24 17:00:00', 'United Airlines', 'UA-908', 'Casa Natalia', 17.50, 60.00, 'completed'),
('MCT-2026-1049', 49, 2, 4, 3, 4, '2025-11-25 10:00:00', 'Alaska Airlines', 'AS-010', 'Solaz', 17.50, 90.00, 'completed'),
('MCT-2026-1050', 50, 3, 5, 4, 8, '2025-11-25 11:45:00', 'Volaris', 'Y4-111', 'Breathless', 17.50, 100.00, 'completed'),
('MCT-2026-1051', 51, 4, 7, 5, 15, '2025-11-26 14:15:00', 'American Airlines', 'AA-222', 'Diamante Cabo San Lucas', 17.50, 290.00, 'completed'),
('MCT-2026-1052', 52, 5, 8, 6, 2, '2025-11-26 16:30:00', 'Delta Air Lines', 'DL-333', 'Four Seasons Resort', 17.50, 120.00, 'completed'),
('MCT-2026-1053', 53, 1, 2, 1, 3, '2025-11-27 09:00:00', 'United Airlines', 'UA-444', 'Posada Real', 17.50, 60.00, 'completed'),
('MCT-2026-1054', 54, 2, 3, 2, 4, '2025-11-27 11:30:00', 'Alaska Airlines', 'AS-555', 'Montage Los Cabos', 17.50, 90.00, 'completed'),
('MCT-2026-1055', 55, 3, 5, 3, 6, '2025-11-28 13:20:00', 'Volaris', 'Y4-666', 'Villa del Palmar', 17.50, 100.00, 'completed'),
('MCT-2026-1056', 56, 4, 7, 4, 11, '2025-11-28 15:50:00', 'American Airlines', 'AA-777', 'Quivira Los Cabos', 17.50, 290.00, 'completed'),
('MCT-2026-1057', 57, 5, 8, 5, 3, '2025-11-29 10:10:00', 'Delta Air Lines', 'DL-888', 'Waldorf Astoria Pedregal', 17.50, 120.00, 'completed'),
('MCT-2026-1058', 58, 2, 2, 6, 5, '2025-11-29 12:40:00', 'United Airlines', 'UA-999', 'Secrets Puerto Los Cabos', 17.50, 90.00, 'completed'),
('MCT-2026-1059', 59, 1, NULL, NULL, 2, '2025-11-30 14:00:00', 'Alaska Airlines', 'AS-100', 'Krystal Grand', 17.50, 60.00, 'cancelled'),
('MCT-2026-1060', 60, 3, 6, 1, 8, '2025-11-30 16:15:00', 'Volaris', 'Y4-201', 'Riu Palace Cabo San Lucas', 17.50, 100.00, 'completed'),
('MCT-2026-1061', 61, 1, 1, 2, 2, '2025-12-01 08:45:00', 'American Airlines', 'AA-302', 'Barcelo Gran Faro Los Cabos', 17.50, 60.00, 'completed'),
('MCT-2026-1062', 62, 2, 3, 3, 4, '2025-12-01 11:00:00', 'Delta Air Lines', 'DL-403', 'Hyatt Ziva', 17.50, 70.00, 'completed'),
('MCT-2026-1063', 63, 3, 5, 4, 7, '2025-12-02 13:15:00', 'United Airlines', 'UA-504', 'Grand Velas Los Cabos', 17.50, 100.00, 'completed'),
('MCT-2026-1064', 64, 4, 7, 5, 13, '2025-12-02 15:30:00', 'Alaska Airlines', 'AS-605', 'Hard Rock Hotel', 17.50, 280.00, 'completed'),
('MCT-2026-1065', 65, 5, 8, 6, 3, '2025-12-03 09:30:00', 'Volaris', 'Y4-706', 'Nobu Hotel', 17.50, 120.00, 'completed'),
('MCT-2026-1066', 66, 2, 2, 1, 5, '2025-12-03 12:00:00', 'American Airlines', 'AA-807', 'Pueblo Bonito Sunset', 17.50, 90.00, 'completed'),
('MCT-2026-1067', 67, 3, 6, 2, 8, '2025-12-04 14:10:00', 'Delta Air Lines', 'DL-908', 'Riu Palace Cabo San Lucas', 17.50, 100.00, 'completed'),
('MCT-2026-1068', 68, 1, 1, 3, 2, '2025-12-04 16:45:00', 'United Airlines', 'UA-010', 'Casa Natalia', 17.50, 60.00, 'completed'),
('MCT-2026-1069', 69, 2, 4, 4, 4, '2025-12-05 10:15:00', 'Alaska Airlines', 'AS-111', 'Solaz', 17.50, 90.00, 'completed'),
('MCT-2026-1070', 70, 3, 5, 5, 6, '2025-12-05 12:50:00', 'Volaris', 'Y4-222', 'Breathless', 17.50, 100.00, 'completed');
