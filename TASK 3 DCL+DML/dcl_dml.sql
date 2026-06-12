SET search_path TO ems_schema;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'ems_schema'
ORDER BY table_name;

SET search_path TO ems_schema;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ems_admin_role') THEN
        CREATE ROLE ems_admin_role;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ems_readonly_role') THEN
        CREATE ROLE ems_readonly_role;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ems_admin_user') THEN
        CREATE ROLE ems_admin_user LOGIN PASSWORD 'admin123';
    ELSE
        ALTER ROLE ems_admin_user WITH LOGIN PASSWORD 'admin123';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ems_reader_user') THEN
        CREATE ROLE ems_reader_user LOGIN PASSWORD 'reader123';
    ELSE
        ALTER ROLE ems_reader_user WITH LOGIN PASSWORD 'reader123';
    END IF;
END $$;

GRANT ems_admin_role TO ems_admin_user;
GRANT ems_readonly_role TO ems_reader_user;

GRANT ems_admin_role TO ems_admin_user;
GRANT ems_readonly_role TO ems_reader_user;

GRANT CONNECT ON DATABASE event_management_db TO ems_admin_role;
GRANT CONNECT ON DATABASE event_management_db TO ems_readonly_role;

GRANT USAGE ON SCHEMA ems_schema TO ems_admin_role;
GRANT USAGE ON SCHEMA ems_schema TO ems_readonly_role;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA ems_schema
TO ems_admin_role;

GRANT SELECT
ON ALL TABLES IN SCHEMA ems_schema
TO ems_readonly_role;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA ems_schema
TO ems_admin_role;

TRUNCATE TABLE
    event_sponsors,
    session_speakers,
    registrations,
    logistics,
    sessions,
    events,
    speakers,
    sponsors,
    participants,
    organizers,
    venues
RESTART IDENTITY CASCADE;

INSERT INTO venues (venue_name, city, address_line, capacity) VALUES
('Atyrau Hall', 'Atyrau', 'Satpayev 15', 500),
('Caspian Center', 'Aktau', 'Mangilik El 9', 300),
('Expo Center', 'Astana', 'Turan Avenue 20', 800),
('Business Hub', 'Almaty', 'Abay Avenue 101', 450),
('Conference Room A', 'Atyrau', 'Azattyk 45', 120);

INSERT INTO organizers (organizer_name, email, phone) VALUES
('Global Events', 'global@mail.com', '+77011111111'),
('Future Vision', 'future@mail.com', '+77012222222'),
('Tech Group', 'techgroup@mail.com', '+77013333333'),
('Student Union', 'studentunion@mail.com', '+77014444444'),
('Business Club', 'businessclub@mail.com', '+77015555555');

INSERT INTO participants (first_name, last_name, gender, email, phone) VALUES
('Ali', 'Nurgaliyev', 'M', 'ali@mail.com', '+77023334455'),
('Dana', 'Sarsenova', 'F', 'dana@mail.com', '+77024445566'),
('Arman', 'Tulegenov', 'M', 'arman@mail.com', '+77025556677'),
('Aruzhan', 'Bekova', 'F', 'aruzhan@mail.com', '+77026667788'),
('Nursultan', 'Kairatov', 'M', 'nursultan@mail.com', '+77027778899');

INSERT INTO sponsors (company_name, contact_email) VALUES
('Samsung Kazakhstan', 'samsung@mail.com'),
('TechnoSoft', 'technosoft@mail.com'),
('Kaspi Tech', 'kaspitech@mail.com'),
('Kcell Business', 'kcell@mail.com'),
('Atyrau Energy', 'energy@mail.com');

INSERT INTO speakers (speaker_name, email) VALUES
('Aruzhan Bekova', 'speaker.aruzhan@mail.com'),
('Arman Tulegenov', 'speaker.arman@mail.com'),
('Dana Sarsenova', 'speaker.dana@mail.com'),
('Miras Omarov', 'speaker.miras@mail.com'),
('Aidos Karimov', 'speaker.aidos@mail.com');

INSERT INTO events (event_name, description, start_date, end_date, venue_id, organizer_id, status) VALUES
(
    'Tech Expo 2026',
    'Technology exhibition',
    '2026-05-10',
    '2026-05-12',
    (SELECT venue_id FROM venues WHERE venue_name = 'Atyrau Hall'),
    (SELECT organizer_id FROM organizers WHERE organizer_name = 'Global Events'),
    'planned'
),
(
    'Innovation Forum 2026',
    'Business conference',
    '2026-06-15',
    '2026-06-16',
    (SELECT venue_id FROM venues WHERE venue_name = 'Caspian Center'),
    (SELECT organizer_id FROM organizers WHERE organizer_name = 'Future Vision'),
    'active'
),
(
    'Student IT Day',
    'Event for students interested in IT',
    '2026-07-05',
    '2026-07-05',
    (SELECT venue_id FROM venues WHERE venue_name = 'Conference Room A'),
    (SELECT organizer_id FROM organizers WHERE organizer_name = 'Student Union'),
    'planned'
),
(
    'Business Meetup',
    'Small business networking event',
    '2026-08-20',
    '2026-08-20',
    (SELECT venue_id FROM venues WHERE venue_name = 'Business Hub'),
    (SELECT organizer_id FROM organizers WHERE organizer_name = 'Business Club'),
    'planned'
),
(
    'Digital Future Summit',
    'Conference about future technologies',
    '2026-09-10',
    '2026-09-12',
    (SELECT venue_id FROM venues WHERE venue_name = 'Expo Center'),
    (SELECT organizer_id FROM organizers WHERE organizer_name = 'Tech Group'),
    'planned'
);

INSERT INTO sessions (event_id, title, start_time, end_time) VALUES
((SELECT event_id FROM events WHERE event_name = 'Tech Expo 2026'), 'AI in Education', '2026-05-10 10:00:00', '2026-05-10 11:30:00'),
((SELECT event_id FROM events WHERE event_name = 'Innovation Forum 2026'), 'Startup Growth', '2026-06-15 14:00:00', '2026-06-15 15:15:00'),
((SELECT event_id FROM events WHERE event_name = 'Student IT Day'), 'How to Start Coding', '2026-07-05 12:00:00', '2026-07-05 13:00:00'),
((SELECT event_id FROM events WHERE event_name = 'Business Meetup'), 'Marketing Basics', '2026-08-20 11:00:00', '2026-08-20 12:00:00'),
((SELECT event_id FROM events WHERE event_name = 'Digital Future Summit'), 'Cybersecurity Trends', '2026-09-10 15:00:00', '2026-09-10 16:30:00');

INSERT INTO logistics (event_id, item_name, quantity) VALUES
((SELECT event_id FROM events WHERE event_name = 'Tech Expo 2026'), 'Projector', 3),
((SELECT event_id FROM events WHERE event_name = 'Innovation Forum 2026'), 'Microphone', 5),
((SELECT event_id FROM events WHERE event_name = 'Student IT Day'), 'Laptop', 10),
((SELECT event_id FROM events WHERE event_name = 'Business Meetup'), 'Chairs', 80),
((SELECT event_id FROM events WHERE event_name = 'Digital Future Summit'), 'LED Screen', 2);

INSERT INTO registrations (participant_id, event_id, registration_date, status) VALUES
((SELECT participant_id FROM participants WHERE email = 'ali@mail.com'), (SELECT event_id FROM events WHERE event_name = 'Tech Expo 2026'), '2026-04-25 14:30:00', 'confirmed'),
((SELECT participant_id FROM participants WHERE email = 'dana@mail.com'), (SELECT event_id FROM events WHERE event_name = 'Innovation Forum 2026'), '2026-05-20 10:15:00', 'pending'),
((SELECT participant_id FROM participants WHERE email = 'arman@mail.com'), (SELECT event_id FROM events WHERE event_name = 'Student IT Day'), '2026-06-10 09:00:00', 'confirmed'),
((SELECT participant_id FROM participants WHERE email = 'aruzhan@mail.com'), (SELECT event_id FROM events WHERE event_name = 'Business Meetup'), '2026-07-12 16:20:00', 'cancelled'),
((SELECT participant_id FROM participants WHERE email = 'nursultan@mail.com'), (SELECT event_id FROM events WHERE event_name = 'Digital Future Summit'), '2026-08-01 18:45:00', 'confirmed');

INSERT INTO session_speakers (session_id, speaker_id) VALUES
((SELECT session_id FROM sessions WHERE title = 'AI in Education'), (SELECT speaker_id FROM speakers WHERE speaker_name = 'Aruzhan Bekova')),
((SELECT session_id FROM sessions WHERE title = 'Startup Growth'), (SELECT speaker_id FROM speakers WHERE speaker_name = 'Arman Tulegenov')),
((SELECT session_id FROM sessions WHERE title = 'How to Start Coding'), (SELECT speaker_id FROM speakers WHERE speaker_name = 'Dana Sarsenova')),
((SELECT session_id FROM sessions WHERE title = 'Marketing Basics'), (SELECT speaker_id FROM speakers WHERE speaker_name = 'Miras Omarov')),
((SELECT session_id FROM sessions WHERE title = 'Cybersecurity Trends'), (SELECT speaker_id FROM speakers WHERE speaker_name = 'Aidos Karimov'));

INSERT INTO event_sponsors (event_id, sponsor_id, sponsorship_level) VALUES
((SELECT event_id FROM events WHERE event_name = 'Tech Expo 2026'), (SELECT sponsor_id FROM sponsors WHERE company_name = 'Samsung Kazakhstan'), 'Gold'),
((SELECT event_id FROM events WHERE event_name = 'Innovation Forum 2026'), (SELECT sponsor_id FROM sponsors WHERE company_name = 'TechnoSoft'), 'Silver'),
((SELECT event_id FROM events WHERE event_name = 'Student IT Day'), (SELECT sponsor_id FROM sponsors WHERE company_name = 'Kaspi Tech'), 'Bronze'),
((SELECT event_id FROM events WHERE event_name = 'Business Meetup'), (SELECT sponsor_id FROM sponsors WHERE company_name = 'Kcell Business'), 'Silver'),
((SELECT event_id FROM events WHERE event_name = 'Digital Future Summit'), (SELECT sponsor_id FROM sponsors WHERE company_name = 'Atyrau Energy'), 'Platinum');

UPDATE events
SET status = 'completed'
WHERE event_name = 'Tech Expo 2026';

UPDATE logistics
SET quantity = quantity + 2
WHERE item_name = 'Microphone';

UPDATE registrations r
SET status = 'confirmed'
FROM events e
WHERE r.event_id = e.event_id
  AND e.event_name = 'Innovation Forum 2026';

BEGIN;

DELETE FROM registrations
WHERE status = 'cancelled';

ROLLBACK;

SELECT * FROM venues;
SELECT * FROM organizers;
SELECT * FROM participants;
SELECT * FROM events;
SELECT * FROM registrations;

SET search_path TO ems_schema;

SELECT COUNT(*) AS venues_count FROM venues;
SELECT COUNT(*) AS organizers_count FROM organizers;
SELECT COUNT(*) AS participants_count FROM participants;
SELECT COUNT(*) AS events_count FROM events;
SELECT COUNT(*) AS registrations_count FROM registrations;