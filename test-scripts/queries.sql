-- ============================================================================
-- TEST-SKRIPT FOR OBLIG 1


--Del 5: SQL-spørringer og Automatisk Testing

-- Oppgave 5.1 - Vise alle sykler
SELECT *
FROM Sykkel;d


-- Oppgave 5.2 - Kunder sortert alfabetisk på etternavn
SELECT Etternavn, Fornavn, Mobilnummer
FROM Kunde
ORDER BY Etternavn ASC;


-- Oppgave 5.3 - Sykler tatt i bruk etter 1. april 2024
SELECT *
FROM Sykkel
WHERE Innkjopsdato > DATE '2023-04-01';

-- Oppgave 5.4 - Viser antall kunder i casen
SELECT COUNT(*) AS Antall_kunder
FROM Kunde;


-- Oppgave 5.5 - Alle kunder med antall utleieforhold (inkl. kunder uten utleieforhold)
SELECT
    k.Kunde_id,
    k.Fornavn,
    k.Etternavn,
    COUNT(u.Utleie_id) AS Antall_utleier
FROM Kunde k
         LEFT JOIN Utleie u ON k.Kunde_id = u.Kunde_id
GROUP BY k.Kunde_id, k.Fornavn, k.Etternavn
ORDER BY k.Kunde_id;


-- Oppgave 5.6 - Kunder som aldri har leid en sykkel
SELECT k.*
FROM Kunde k
         LEFT JOIN Utleie u ON k.Kunde_id = u.Kunde_id
WHERE u.Utleie_id IS NULL;



-- Oppgave 5.7 - Sykler som aldri har vært utleid
SELECT s.*
FROM Sykkel s
         LEFT JOIN Utleie u ON s.Sykkel_id = u.Sykkel_id
WHERE u.Utleie_id IS NULL;


-- Oppgave 5.8 - Sykler som ikke er levert tilbake etter et døgn
SELECT
    s.Sykkel_id,
    k.Fornavn,
    k.Etternavn,
    u.Utleie_tidspunkt
FROM Utleie u
         JOIN Sykkel s ON u.Sykkel_id = s.Sykkel_id
         JOIN Kunde k ON u.Kunde_id = k.Kunde_id
WHERE u.Innlevert_tidspunkt IS NULL
  AND u.Utleie_tidspunkt < NOW() - INTERVAL '1 dag';











-- ============================================================================


-- Kjør med: docker-compose exec postgres psql -h -U admin -d data1500_db -f test-scripts/queries.sql

-- En test med en SQL-spørring mot metadata i PostgreSQL (kan slettes fra din script)
select nspname as schema_name from pg_catalog.pg_namespace;


