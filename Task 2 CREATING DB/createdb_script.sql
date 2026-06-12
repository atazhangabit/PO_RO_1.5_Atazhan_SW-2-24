DROP SCHEMA IF EXISTS ems_schema CASCADE;
CREATE SCHEMA ems_schema;
SET search_path TO ems_schema;

CREATE TABLE venues (
    venue_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venue_name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address_line VARCHAR(200) NOT NULL,
    capacity INT NOT NULL DEFAULT 100,
    CONSTRAINT chk_venue_capacity CHECK (capacity >= 0)
);

CREATE TABLE organizers (
    organizer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    organizer_name VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE participants (
    participant_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    gender CHAR(1) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    CONSTRAINT chk_participant_gender CHECK (gender IN ('M', 'F'))
);

CREATE TABLE sponsors (
    sponsor_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL UNIQUE,
    contact_email VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE speakers (
    speaker_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    speaker_name VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE events (
    event_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_name VARCHAR(150) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    venue_id INT NOT NULL,
    organizer_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'planned',
    CONSTRAINT fk_event_venue FOREIGN KEY (venue_id) REFERENCES venues(venue_id),
    CONSTRAINT fk_event_organizer FOREIGN KEY (organizer_id) REFERENCES organizers(organizer_id),
    CONSTRAINT chk_event_start_date CHECK (start_date > DATE '2026-01-01'),
    CONSTRAINT chk_event_end_date CHECK (end_date >= start_date),
    CONSTRAINT chk_event_status CHECK (status IN ('planned', 'active', 'completed', 'cancelled'))
);

CREATE TABLE sessions (
    session_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    CONSTRAINT fk_session_event FOREIGN KEY (event_id) REFERENCES events(event_id),
    CONSTRAINT chk_session_time CHECK (end_time > start_time)
);

CREATE TABLE logistics (
    logistics_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_id INT NOT NULL,
    item_name VARCHAR(150) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_logistics_event FOREIGN KEY (event_id) REFERENCES events(event_id),
    CONSTRAINT chk_logistics_quantity CHECK (quantity >= 0)
);

CREATE TABLE registrations (
    participant_id INT NOT NULL,
    event_id INT NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'confirmed',
    PRIMARY KEY (participant_id, event_id),
    CONSTRAINT fk_registration_participant FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    CONSTRAINT fk_registration_event FOREIGN KEY (event_id) REFERENCES events(event_id),
    CONSTRAINT chk_registration_status CHECK (status IN ('confirmed', 'pending', 'cancelled'))
);

CREATE TABLE session_speakers (
    session_id INT NOT NULL,
    speaker_id INT NOT NULL,
    PRIMARY KEY (session_id, speaker_id),
    CONSTRAINT fk_ss_session FOREIGN KEY (session_id) REFERENCES sessions(session_id),
    CONSTRAINT fk_ss_speaker FOREIGN KEY (speaker_id) REFERENCES speakers(speaker_id)
);

CREATE TABLE event_sponsors (
    event_id INT NOT NULL,
    sponsor_id INT NOT NULL,
    sponsorship_level VARCHAR(20) NOT NULL DEFAULT 'Silver',
    PRIMARY KEY (event_id, sponsor_id),
    CONSTRAINT fk_es_event FOREIGN KEY (event_id) REFERENCES events(event_id),
    CONSTRAINT fk_es_sponsor FOREIGN KEY (sponsor_id) REFERENCES sponsors(sponsor_id),
    CONSTRAINT chk_sponsorship_level CHECK (sponsorship_level IN ('Bronze', 'Silver', 'Gold', 'Platinum'))
);
INSERT INTO venues (venue_name, city, address_line, capacity) VALUES
('Atyrau Hall', 'Atyrau', 'Satpayev 15', 500),
('Caspian Center', 'Aktau', 'Mangilik El 9', 300);

INSERT INTO organizers (organizer_name, email, phone) VALUES
('Global Events', 'global@mail.com', '+77011111111'),
('Future Vision', 'future@mail.com', '+77012222222');

INSERT INTO participants (first_name, last_name, gender, email, phone) VALUES
('Ali', 'Nurgaliyev', 'M', 'ali@mail.com', '+77023334455'),
('Dana', 'Sarsenova', 'F', 'dana@mail.com', '+77024445566');

INSERT INTO sponsors (company_name, contact_email) VALUES
('Samsung Kazakhstan', 'samsung@mail.com'),
('TechnoSoft', 'technosoft@mail.com');

INSERT INTO speakers (speaker_name, email) VALUES
('Aruzhan Bekova', 'aruzhan@mail.com'),
('Arman Tulegenov', 'arman@mail.com');

INSERT INTO events (event_name, description, start_date, end_date, venue_id, organizer_id, status) VALUES
('Tech Expo 2026', 'Technology exhibition', '2026-05-10', '2026-05-12', 1, 1, 'planned'),
('Innovation Forum 2026', 'Business conference', '2026-06-15', '2026-06-16', 2, 2, 'active');

INSERT INTO sessions (event_id, title, start_time, end_time) VALUES
(1, 'AI in Education', '2026-05-10 10:00:00', '2026-05-10 11:30:00'),
(2, 'Startup Growth', '2026-06-15 14:00:00', '2026-06-15 15:15:00');

INSERT INTO logistics (event_id, item_name, quantity) VALUES
(1, 'Projector', 3),
(2, 'Microphone', 5);

INSERT INTO registrations (participant_id, event_id, registration_date, status) VALUES
(1, 1, '2026-04-25 14:30:00', 'confirmed'),
(2, 2, '2026-05-20 10:15:00', 'pending');

INSERT INTO session_speakers (session_id, speaker_id) VALUES
(1, 1),
(2, 2);

INSERT INTO event_sponsors (event_id, sponsor_id, sponsorship_level) VALUES
(1, 1, 'Gold'),
(2, 2, 'Silver');

SELECT * FROM venues;
SELECT * FROM organizers;
SELECT * FROM participants;
SELECT * FROM events;
SELECT * FROM registrations;