-- ------------ Write DROP-TRIGGER-stage scripts -----------

DROP TRIGGER IF EXISTS player_id_trg
ON dms_sample.player;



DROP TRIGGER IF EXISTS sport_team_id_trg
ON dms_sample.sport_team;



DROP TRIGGER IF EXISTS sporting_event_id_trg
ON dms_sample.sporting_event;



-- ------------ Write DROP-FUNCTION-stage scripts -----------

DROP FUNCTION IF EXISTS dms_sample.generate_tickets(IN DOUBLE PRECISION);



DROP FUNCTION IF EXISTS dms_sample.generateseats();



DROP FUNCTION IF EXISTS dms_sample.loadmlbplayers();



DROP FUNCTION IF EXISTS dms_sample.loadmlbteams();



DROP FUNCTION IF EXISTS dms_sample.loadnflplayers();



DROP FUNCTION IF EXISTS dms_sample.loadnflteams();



DROP FUNCTION IF EXISTS dms_sample.player_id_trg$player();



DROP FUNCTION IF EXISTS dms_sample.sport_team_id_trg$sport_team();



DROP FUNCTION IF EXISTS dms_sample.sporting_event_id_trg$sporting_event();



-- ------------ Write CREATE-FUNCTION-stage scripts -----------

CREATE OR REPLACE FUNCTION dms_sample.generate_tickets(
     IN p_event_id DOUBLE PRECISION)
RETURNS void
AS
$BODY$
DECLARE
    event_cur CURSOR (p_id DOUBLE PRECISION) FOR
    SELECT
        id, location_id
        FROM dms_sample.sporting_event
        WHERE id = p_id;
    standard_price NUMERIC(6, 2);
BEGIN
    standard_price := aws_oracle_ext.dbms_random$value(30, 50);

    FOR event_rec IN event_cur (P_event_id) LOOP
        INSERT INTO dms_sample.sporting_event_ticket (id, sporting_event_id, sport_location_id, seat_level, seat_section, seat_row, seat, ticket_price)
        SELECT
            nextval('dms_sample.sporting_event_ticket_seq'), dms_sample.sporting_event.id, dms_sample.seat.sport_location_id, dms_sample.seat.seat_level, dms_sample.seat.seat_section, dms_sample.seat.seat_row, dms_sample.seat.seat, (CASE
                WHEN dms_sample.seat.seat_type = 'luxury' THEN 3 * standard_price
                WHEN dms_sample.seat.seat_type = 'premium' THEN 2 * standard_price
                WHEN dms_sample.seat.seat_type = 'standard' THEN standard_price
                WHEN dms_sample.seat.seat_type = 'sub-standard' THEN 0.8 * standard_price
                WHEN dms_sample.seat.seat_type = 'obstructed' THEN 0.5 * standard_price
                WHEN dms_sample.seat.seat_type = 'standing' THEN 0.5 * standard_price
            END) AS ticket_price
            FROM dms_sample.sporting_event, dms_sample.seat
            WHERE dms_sample.sporting_event.location_id = dms_sample.seat.sport_location_id AND dms_sample.sporting_event.id = event_rec.id;
    END LOOP;
END;
$BODY$
LANGUAGE  plpgsql;



CREATE OR REPLACE FUNCTION dms_sample.generateseats()
RETURNS void
AS
$BODY$
DECLARE
    aws_oracle_ext$array_id$temporary BIGINT;
    loc_cur CURSOR FOR
    SELECT
        id, seating_capacity, levels, sections
        FROM dms_sample.sport_location;
    seat_tab VARCHAR(100) := 'seat_tab';
    seat_type_tab VARCHAR(100) := 'seat_type_tab';
    s_ct INTEGER := 1;
    max_rows_per_section NUMERIC(38) := 25;
    min_rows_per_section NUMERIC(38) := 15;
    rows NUMERIC(38);
    seats NUMERIC(38);
    s_ref CHARACTER VARYING(26) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    tot_seats NUMERIC(10);
BEGIN
    /* load seat type percentage table */
    aws_oracle_ext$array_id$temporary := aws_oracle_ext.array$create_array('seat_tab', 'dms_sample.generateseats');
    PERFORM aws_oracle_ext.array$add_fields_to_array(aws_oracle_ext$array_id$temporary, '[{"sport_location_id":"DOUBLE PRECISION"},{"seat_level":"NUMERIC(1, 0)"},{"seat_section":"CHARACTER VARYING(15)"},{"seat_row":"CHARACTER VARYING(10)"},{"seat":"CHARACTER VARYING(10)"},{"seat_type":"CHARACTER VARYING(15)"}]');
    aws_oracle_ext$array_id$temporary := aws_oracle_ext.array$create_array('seat_type_tab', 'dms_sample.generateseats');
    PERFORM aws_oracle_ext.array$add_fields_to_array(aws_oracle_ext$array_id$temporary, '[{"":"CHARACTER VARYING(15)"}]');

    FOR i IN 1..100 LOOP
        CASE
            WHEN i <= 5 THEN
                PERFORM aws_oracle_ext.array$set_value('seat_type_tab[' || i || ']', 'dms_sample.generateseats', 'luxury'::CHARACTER VARYING(15)); /* 5% luxury seats */
            WHEN 5 < i AND i <= 35 THEN
                PERFORM aws_oracle_ext.array$set_value('seat_type_tab[' || i || ']', 'dms_sample.generateseats', 'premium'::CHARACTER VARYING(15)); /* 30% premium seats */
            WHEN 35 < i AND i <= 89 THEN
                PERFORM aws_oracle_ext.array$set_value('seat_type_tab[' || i || ']', 'dms_sample.generateseats', 'standard'::CHARACTER VARYING(15)); /* 54% standard seats */
            WHEN 89 < i AND i <= 99 THEN
                PERFORM aws_oracle_ext.array$set_value('seat_type_tab[' || i || ']', 'dms_sample.generateseats', 'sub-standard'::CHARACTER VARYING(15)); /* 10% sub-standard seats */
            WHEN i = 100 THEN
                PERFORM aws_oracle_ext.array$set_value('seat_type_tab[' || i || ']', 'dms_sample.generateseats', 'obstructed'::CHARACTER VARYING(15)); /* 1% obstructed seats */
        END CASE;
    END LOOP;

    FOR lrec IN loc_cur LOOP
        tot_seats := 0;
        rows := ROUND(aws_oracle_ext.dbms_random$value(min_rows_per_section, max_rows_per_section));
        seats := TRUNC((lrec.seating_capacity / (lrec.levels * lrec.sections * rows)::NUMERIC + 1)::NUMERIC);

        FOR i IN 1..lrec.levels LOOP
            FOR j IN 1..lrec.sections LOOP
                FOR k IN 1..rows LOOP
                    FOR l IN 1..seats LOOP
                        tot_seats := tot_seats + 1;

                        IF tot_seats <= lrec.seating_capacity THEN
                            PERFORM aws_oracle_ext.array$set_value('seat_tab[' || s_ct || '].seat_level', 'dms_sample.generateseats', i);
                            PERFORM aws_oracle_ext.array$set_value('seat_tab[' || s_ct || '].seat_section', 'dms_sample.generateseats', j);
                            PERFORM aws_oracle_ext.array$set_value('seat_tab[' || s_ct || '].seat_row', 'dms_sample.generateseats', aws_oracle_ext.substr(s_ref, k, 1));
                            PERFORM aws_oracle_ext.array$set_value('seat_tab[' || s_ct || '].seat', 'dms_sample.generateseats', l);
                            PERFORM aws_oracle_ext.array$set_value('seat_tab[' || s_ct || '].sport_location_id', 'dms_sample.generateseats', lrec.id);
                            PERFORM aws_oracle_ext.array$set_value('seat_tab[' || s_ct || '].seat_type', 'dms_sample.generateseats', aws_oracle_ext.array$get_value('seat_type_tab[' || ROUND(aws_oracle_ext.dbms_random$value(1, 100)) || ']', 'dms_sample.generateseats', NULL::CHARACTER VARYING(15)));
                            s_ct := s_ct + 1;

                            IF s_ct >= 1000 THEN
                                PERFORM aws_oracle_ext.array$create_storage_table(p_array_name => 'seat_tab', p_procedure_name => 'dms_sample.generateseats', p_cast_type_name => 'dms_sample.SEAT');
                                INSERT INTO dms_sample.seat
                                SELECT
                                    (e).m
                                    FROM aws_oracle_ext.table(pVal => '{"Array Name": "seat_tab", "Procedure Name": "dms_sample.generateseats"}'::JSONB, pValType => 'ASSOC', pTypeToCast => 'dms_sample.seat')
                                        AS (a dms_sample.seat);
                                s_ct := 1;
                                PERFORM aws_oracle_ext.array$delete('seat_tab', 'dms_sample.generateseats');
                            END IF;
                        END IF;
                    END LOOP;
                END LOOP;
            END LOOP;
        END LOOP;
        PERFORM aws_oracle_ext.array$create_storage_table(p_array_name => 'seat_tab', p_procedure_name => 'dms_sample.generateseats', p_cast_type_name => 'dms_sample.SEAT');
        INSERT INTO dms_sample.seat
        SELECT
            (e).m
            FROM aws_oracle_ext.table(pVal => '{"Array Name": "seat_tab", "Procedure Name": "dms_sample.generateseats"}'::JSONB, pValType => 'ASSOC', pTypeToCast => 'dms_sample.seat')
                AS (a dms_sample.seat);
        PERFORM aws_oracle_ext.array$delete('seat_tab', 'dms_sample.generateseats');
        s_ct := 1;
    END LOOP;
    PERFORM aws_oracle_ext.array$clear_procedure('dms_sample.generateseats');
END;
$BODY$
LANGUAGE  plpgsql;



CREATE OR REPLACE FUNCTION dms_sample.loadmlbplayers()
RETURNS void
AS
$BODY$
DECLARE
    t_id DOUBLE PRECISION;
    mlb_players CURSOR FOR
    SELECT DISTINCT
        CASE TRIM(mlb_team_long)
            WHEN 'Anaheim Angels' THEN 'Los Angeles Angels'
            ELSE mlb_team_long
        END AS t_name, TRIM(mlb_name) AS name, aws_oracle_ext.substr(TRIM(mlb_name), 1, aws_oracle_ext.INSTR(mlb_name, ' ')) AS l_name, aws_oracle_ext.substr(TRIM(mlb_name), aws_oracle_ext.INSTR(mlb_name, ' ')) AS f_name
        FROM dms_sample.mlb_data;
BEGIN
    FOR trec IN mlb_players LOOP
        SELECT
            id
            INTO STRICT t_id
            FROM dms_sample.sport_team
            WHERE sport_type_name = 'baseball' AND sport_league_short_name = 'MLB' AND name = trec.t_name;
        INSERT INTO dms_sample.player (sport_team_id, last_name, first_name, full_name)
        VALUES (t_id, trec.l_name, trec.f_name, trec.name);
    END LOOP;
END;
$BODY$
LANGUAGE  plpgsql;



CREATE OR REPLACE FUNCTION dms_sample.loadmlbteams()
RETURNS void
AS
$BODY$
DECLARE
    v_div DMS_SAMPLE.SPORT_DIVISION.short_name%TYPE;
    mlb_teams CURSOR FOR
    SELECT DISTINCT
        CASE TRIM(mlb_team)
            WHEN 'AAA' THEN 'LAA'
            ELSE mlb_team
        END AS a_name,
        CASE TRIM(mlb_team_long)
            WHEN 'Anaheim Angels' THEN 'Los Angeles Angels'
            ELSE mlb_team_long
        END AS l_name
        FROM dms_sample.mlb_data;
BEGIN
    FOR trec IN mlb_teams LOOP
        CASE
            WHEN trec.a_name IN ('BAL', 'BOS', 'TOR', 'TB', 'NYY') THEN
                v_div := 'AL East';
            WHEN trec.a_name IN ('CLE', 'DET', 'KC', 'CWS', 'MIN') THEN
                v_div := 'AL Central';
            WHEN trec.a_name IN ('TEX', 'SEA', 'HOU', 'OAK', 'LAA') THEN
                v_div := 'AL West';
            WHEN trec.a_name IN ('WSH', 'MIA', 'NYM', 'PHI', 'ATL') THEN
                v_div := 'NL East';
            WHEN trec.a_name IN ('CHC', 'STL', 'PIT', 'MIL', 'CIN') THEN
                v_div := 'NL Central';
            WHEN trec.a_name IN ('COL', 'SD', 'LAD', 'SF', 'ARI') THEN
                v_div := 'NL West';
        END CASE;
        INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
        VALUES (trec.l_name, trec.a_name, 'baseball', 'MLB', v_div);
    END LOOP;
END;
$BODY$
LANGUAGE  plpgsql;



CREATE OR REPLACE FUNCTION dms_sample.loadnflplayers()
RETURNS void
AS
$BODY$
DECLARE
    t_id DOUBLE PRECISION;
    nfl_players CURSOR FOR
    SELECT
        team, name, RTRIM(TRIM(aws_oracle_ext.substr(TRIM(name), 1, aws_oracle_ext.INSTR(name, ','))), ',') AS l_name, TRIM(LTRIM(TRIM(aws_oracle_ext.substr(TRIM(name), aws_oracle_ext.INSTR(name, ','))), ',')) AS f_name
        FROM dms_sample.nfl_data;
BEGIN
    FOR prec IN nfl_players LOOP
        SELECT
            id
            INTO STRICT t_id
            FROM dms_sample.sport_team
            WHERE sport_type_name = 'football' AND sport_league_short_name = 'NFL' AND abbreviated_name = prec.team;
        INSERT INTO dms_sample.player (sport_team_id, last_name, first_name, full_name)
        VALUES (t_id, prec.l_name, prec.f_name, prec.name);
    END LOOP;
END;
$BODY$
LANGUAGE  plpgsql;



CREATE OR REPLACE FUNCTION dms_sample.loadnflteams()
RETURNS void
AS
$BODY$
DECLARE
    v_sport_type CHARACTER VARYING(10) := 'football';
    v_league CHARACTER VARYING(10) := 'NFL';
    v_division CHARACTER VARYING(10);
BEGIN
    v_division := 'AFC North';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Baltimore Ravens', 'BAL', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Cincinnati Bengals', 'CIN', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Cleveland Browns', 'CLE', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Pittsburgh Steelers', 'PIT', v_sport_type, v_league, v_division);
    v_division := 'AFC South';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Houston Texans', 'HOU', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Indianapolis Colts', 'IND', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Jacksonville Jaguars', 'JAX', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Tennessee Titans', 'TEN', v_sport_type, v_league, v_division);
    v_division := 'AFC East';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Buffalo Bills', 'BUF', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Miami Dolphins', 'MIA', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('New England Patriots', 'NE', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('New York Jets', 'NYJ', v_sport_type, v_league, v_division);
    v_division := 'AFC West';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Denver Broncos', 'DEN', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Kansas City Chiefs', 'KC', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Oakland Raiders', 'OAK', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('San Diego Chargers', 'SD', v_sport_type, v_league, v_division);
    v_division := 'NFC North';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Chicago Bears', 'CHI', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Detroit Lions', 'DET', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Green Bay Packers', 'GB', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Minnesota Vikings', 'MIN', v_sport_type, v_league, v_division);
    v_division := 'NFC South';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Atlanta Falcons', 'ATL', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Carolina Panthers', 'CAR', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('New Orleans Saints', 'NO', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Tampa Bay Buccaneers', 'TB', v_sport_type, v_league, v_division);
    v_division := 'NFC East';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Dallas Cowboys', 'DAL', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('New York Giants', 'NYG', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Philadelphia Eagles', 'PHI', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Washington Redskins', 'WAS', v_sport_type, v_league, v_division);
    v_division := 'NFC West';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Arizona Cardinals', 'ARI', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Los Angeles Rams', 'LA', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('San Francisco 49ers', 'SF', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Seattle Seahawks', 'SEA', v_sport_type, v_league, v_division);
END;
$BODY$
LANGUAGE  plpgsql;



CREATE OR REPLACE FUNCTION dms_sample.player_id_trg$player()
RETURNS trigger
AS
$BODY$
BEGIN
    IF (new.id IS NULL) THEN
        new.id := nextval('dms_sample.player_seq');
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE  plpgsql;



CREATE OR REPLACE FUNCTION dms_sample.sport_team_id_trg$sport_team()
RETURNS trigger
AS
$BODY$
BEGIN
    IF (new.id IS NULL) THEN
        new.id := nextval('dms_sample.sport_team_seq');
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE  plpgsql;



CREATE OR REPLACE FUNCTION dms_sample.sporting_event_id_trg$sporting_event()
RETURNS trigger
AS
$BODY$
BEGIN
    IF (new.id IS NULL) THEN
        new.id := nextval('dms_sample.sporting_event_seq');
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE  plpgsql;



-- ------------ Write CREATE-TRIGGER-stage scripts -----------

CREATE TRIGGER player_id_trg
BEFORE INSERT
ON dms_sample.player
FOR EACH ROW
EXECUTE PROCEDURE dms_sample.player_id_trg$player();



CREATE TRIGGER sport_team_id_trg
BEFORE INSERT
ON dms_sample.sport_team
FOR EACH ROW
EXECUTE PROCEDURE dms_sample.sport_team_id_trg$sport_team();



CREATE TRIGGER sporting_event_id_trg
BEFORE INSERT
ON dms_sample.sporting_event
FOR EACH ROW
EXECUTE PROCEDURE dms_sample.sporting_event_id_trg$sporting_event();
