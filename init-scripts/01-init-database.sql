-- ============================================================================
-- DATA1500 - Oblig 1: Arbeidskrav I våren 2026
-- Initialiserings-skript for PostgreSQL
-- ============================================================================

-- Opprett grunnleggende tabeller

DROP TABLE IF EXISTS Utleie CASCADE;
DROP TABLE IF EXISTS Sykkel CASCADE;
DROP TABLE IF EXISTS Las CASCADE;
DROP TABLE IF EXISTS Stasjon CASCADE;
DROP TABLE IF EXISTS Kunde CASCADE;


CREATE TABLE Kunde (
    Kunde_id    INTEGER PRIMARY KEY,
    Fornavn     VARCHAR(50)  NOT NULL,
    Etternavn   VARCHAR(50)  NOT NULL,
    Mobilnummer VARCHAR(15)  NOT NULL,
    Epost       VARCHAR(100) NOT NULL,
   CONSTRAINT mobilnummer_regel
       CHECK (Mobilnummer ~ '^[0-9]{8}$'),
   CONSTRAINT epost_regel
       CHECK (Epost LIKE '%@%.%')
);

CREATE TABLE Stasjon (
    Stasjon_id      INTEGER PRIMARY KEY,
    Stasjon_navn    VARCHAR(100) NOT NULL,
    Stasjon_adresse VARCHAR(200) NOT NULL
);



CREATE TABLE Las (
     las_id INTEGER PRIMARY KEY,
     stasjon_id INTEGER NOT NULL,

    FOREIGN KEY (stasjon_id)
    REFERENCES Stasjon(stasjon_id)
);


CREATE TABLE Sykkel (
    Sykkel_id INTEGER PRIMARY KEY,
    Modell VARCHAR(100) NOT NULL,
    Innkjopsdato DATE NOT NULL,
    Navarende_stasjon_id  INTEGER,
    Navarende_las_id  INTEGER UNIQUE,

    FOREIGN KEY (navarende_stasjon_id)
        REFERENCES Stasjon(stasjon_id),

    FOREIGN KEY (navarende_las_id)
        REFERENCES Las(las_id)
);


CREATE TABLE Utleie (
                        Utleie_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                        Kunde_id   INTEGER  NOT NULL,
                        Sykkel_id INTEGER  NOT NULL,
                        Start_stasjon_id INTEGER  NOT NULL,
                        Slutt_stasjon_id  INTEGER,
                        Utleie_tidspunkt  TIMESTAMP NOT NULL,
                        Innlevert_tidspunkt TIMESTAMP,
                        Pris NUMERIC(8, 2) CHECK (Pris >= 0),

                        FOREIGN KEY (kunde_id)
                            REFERENCES Kunde(kunde_id),

                        FOREIGN KEY (sykkel_id)
                            REFERENCES Sykkel(sykkel_id),

                        FOREIGN KEY (start_stasjon_id)
                            REFERENCES Stasjon(stasjon_id),

                        FOREIGN KEY (slutt_stasjon_id)
                            REFERENCES Stasjon(stasjon_id)
);








-- Sett inn testdata


-- 5 Sykkelstasjoner
INSERT INTO Stasjon (Stasjon_id, Stasjon_navn, Stasjon_adresse) VALUES
(1, 'Jernbanetorget',    'Jernbanetorget 1, 0154 Oslo'),
(2, 'Aker Brygge',       'Stranden 3, 0250 Oslo'),
(3, 'Grunerløkka',       'Thorvald Meyers gate 2, 0555 Oslo'),
(4, 'Majorstuen',        'Bogstadveien 1, 0355 Oslo'),
(5, 'Nationaltheatret',  'Johanne Dybwads plass 1, 0161 Oslo');


-- 5 Kunder
INSERT INTO Kunde (Kunde_id, Fornavn, Etternavn, Mobilnummer, Epost) VALUES
(1, 'Ola',    'Nordmann',  '91234567', 'ola.nordmann@epost.no'),
(2, 'Kari',   'Hansen',    '98765432', 'kari.hansen@gmail.com'),
(3, 'Per',    'Olsen',     '45678901', 'per.olsen@hotmail.com'),
(4, 'Ingrid', 'Berg',      '47654321', 'ingrid.berg@yahoo.no'),
(5, 'Thomas', 'Dahl',      '92345678', 'thomas.dahl@epost.no');



-- 100 Låser (20 per stasjon)
INSERT INTO Las (Las_id, Stasjon_id)
SELECT
   gs.las_id,
   ((gs.las_id - 1) / 20) + 1 AS stasjon_id
FROM generate_series(1, 100) AS gs(las_id);



-- 100 Sykler
-- Sykler 1–80: parkert på stasjon med lås (16 per stasjon)
-- Sykler 81–100: utleid (NULL stasjon og lås)
INSERT INTO Sykkel (Sykkel_id, Modell, Innkjopsdato, Navarende_stasjon_id, Navarende_las_id)
SELECT
    s.id,
    CASE (s.id % 3)
        WHEN 0 THEN 'Bysykkel Standard'
        WHEN 1 THEN 'El-sykkel Pro'
        ELSE        'Bysykkel Lett'
    END,
    DATE '2022-01-01' + (s.id * 10) * INTERVAL '1 day',
    CASE WHEN s.id <= 60 THEN ((s.id - 1) / 12) + 1 ELSE NULL END,
    CASE WHEN s.id <= 60 THEN s.id ELSE NULL END
    FROM generate_series(1, 100) AS s(id);





--  Utleier ========================================================================


-- 20 Avsluttede utleier

INSERT INTO Utleie (
    kunde_id,
    sykkel_id,
    start_stasjon_id,
    slutt_stasjon_id,
    utleie_tidspunkt,
    innlevert_tidspunkt,
    pris
)
SELECT
    (i % 5) + 1,
    80 + i,
    (i % 5) + 1,
    ((i + 1) % 5) + 1,
    NOW() - (30 - i) * INTERVAL '1 day',
    NOW() - (30 - i) * INTERVAL '1 day' + (i * 15) * INTERVAL '1 minute',
    ROUND((i * 3.5)::NUMERIC, 2)
FROM generate_series(1,20) AS s(i);




-- 20 paagoende utleier (sykler 61-80, ikke levert ennaa)
-- Disse skiller seg fra avsluttede ved at:
--   - Slutt_stasjon_id  = NULL
--   - Innlevert_tidspunkt = NULL
--   - Pris               = NULL

INSERT INTO Utleie (
    Kunde_id, Sykkel_id,
    Start_stasjon_id, Slutt_stasjon_id,
    Utleie_tidspunkt, Innlevert_tidspunkt,
    Pris
)
SELECT
    (i % 5) + 1,
    60 + i,
    (i % 5) + 1,
    NULL,
    NOW() - i * INTERVAL '2 hour',
    NULL,
    NULL
FROM generate_series(1, 20) AS s(i);




-- 10 Ekstra avsluttede utleier
INSERT INTO Utleie (
    kunde_id,
    sykkel_id,
    start_stasjon_id,
    slutt_stasjon_id,
    utleie_tidspunkt,
    innlevert_tidspunkt,
    pris
)
SELECT
    (i % 5) + 1,
    i,
    (i % 5) + 1,
    ((i + 2) % 5) + 1,
    NOW() - (60 + i) * INTERVAL '1 day',
    NOW() - (60 + i) * INTERVAL '1 day' + (i * 20) * INTERVAL '1 minute',
    ROUND((i * 5.0)::NUMERIC, 2)
FROM generate_series(1,10) AS s(i);



-- DBA setninger (rolle: kunde, bruker: kunde_1)

-- Eventuelt: Opprett indekser for ytelse



-- Vis at initialisering er fullført (kan se i loggen fra "docker-compose log"
SELECT 'Database initialisert!' as status;




-- Oppgave 3.1: Roller

-- Opprett kunde-rollen
CREATE ROLE kunde;

-- Opprett eksempelbruker kunde_1 med passord
CREATE USER kunde_1 WITH PASSWORD 'kunde123';

 -- Gi kunde_1 kunde-rollen
GRANT kunde TO kunde_1;


-- Gir lesetilgang til kunde-rollen
GRANT SELECT ON Kunde TO kunde;
GRANT SELECT ON Stasjon TO kunde;
GRANT SELECT ON Sykkel TO kunde;
GRANT SELECT ON Utleie TO kunde;


-- Oppgave 3.2: VIEW

CREATE VIEW mine_utleier AS
SELECT *
FROM Utleie
WHERE Kunde_id = 1;

GRANT SELECT ON mine_utleier TO kunde;