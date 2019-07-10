-- ------------ Write DROP-TRIGGER-stage scripts -----------

DROP TRIGGER IF EXISTS player_id_trg
ON dms_sample.player;



DROP TRIGGER IF EXISTS sport_team_id_trg
ON dms_sample.sport_team;



DROP TRIGGER IF EXISTS sporting_event_id_trg
ON dms_sample.sporting_event;



-- ------------ Write DROP-FOREIGN-KEY-CONSTRAINT-stage scripts -----------

ALTER TABLE dms_sample.player DROP CONSTRAINT sport_team_fk;



ALTER TABLE dms_sample.seat DROP CONSTRAINT s_sport_location_fk;



ALTER TABLE dms_sample.seat DROP CONSTRAINT seat_type_fk;



ALTER TABLE dms_sample.sport_division DROP CONSTRAINT sd_sport_league_fk;



ALTER TABLE dms_sample.sport_division DROP CONSTRAINT sd_sport_type_fk;



ALTER TABLE dms_sample.sport_league DROP CONSTRAINT sl_sport_type_fk;



ALTER TABLE dms_sample.sport_team DROP CONSTRAINT home_field_fk;



ALTER TABLE dms_sample.sport_team DROP CONSTRAINT st_sport_type_fk;



ALTER TABLE dms_sample.sporting_event DROP CONSTRAINT se_away_team_id_fk;



ALTER TABLE dms_sample.sporting_event DROP CONSTRAINT se_home_team_id_fk;



ALTER TABLE dms_sample.sporting_event DROP CONSTRAINT se_location_id_fk;



ALTER TABLE dms_sample.sporting_event DROP CONSTRAINT se_sport_type_fk;



ALTER TABLE dms_sample.sporting_event_ticket DROP CONSTRAINT set_person_id;



ALTER TABLE dms_sample.sporting_event_ticket DROP CONSTRAINT set_seat_fk;



ALTER TABLE dms_sample.sporting_event_ticket DROP CONSTRAINT set_sporting_event_fk;



ALTER TABLE dms_sample.ticket_purchase_hist DROP CONSTRAINT tph_sport_event_tic_id;



ALTER TABLE dms_sample.ticket_purchase_hist DROP CONSTRAINT tph_ticketholder_id;



ALTER TABLE dms_sample.ticket_purchase_hist DROP CONSTRAINT tph_transfer_from_id;



-- ------------ Write DROP-CONSTRAINT-stage scripts -----------

ALTER TABLE dms_sample.name_data DROP CONSTRAINT name_data_pk;



ALTER TABLE dms_sample.person DROP CONSTRAINT person_pk;



ALTER TABLE dms_sample.player DROP CONSTRAINT player_pk;



ALTER TABLE dms_sample.seat DROP CONSTRAINT seat_pk;



ALTER TABLE dms_sample.seat_type DROP CONSTRAINT st_seat_type_pk;



ALTER TABLE dms_sample.sport_division DROP CONSTRAINT sport_division_pk;



ALTER TABLE dms_sample.sport_league DROP CONSTRAINT sport_league_pk;



ALTER TABLE dms_sample.sport_location DROP CONSTRAINT sport_location_pk;



ALTER TABLE dms_sample.sport_team DROP CONSTRAINT sport_team_pk;



ALTER TABLE dms_sample.sport_type DROP CONSTRAINT sport_type_pk;



ALTER TABLE dms_sample.sporting_event DROP CONSTRAINT chk_sold_out;



ALTER TABLE dms_sample.sporting_event DROP CONSTRAINT sporting_event_pk;



ALTER TABLE dms_sample.sporting_event_ticket DROP CONSTRAINT sporting_event_ticket_pk;



ALTER TABLE dms_sample.ticket_purchase_hist DROP CONSTRAINT ticket_purchase_hist_pk;



-- ------------ Write DROP-INDEX-stage scripts -----------

DROP INDEX IF EXISTS dms_sample.seat_sport_location_idx;



DROP INDEX IF EXISTS dms_sample.sport_team_u;



DROP INDEX IF EXISTS dms_sample.se_start_date_fcn;



DROP INDEX IF EXISTS dms_sample.set_ev_id_tkholder_id_idx;



DROP INDEX IF EXISTS dms_sample.set_seat_idx;



DROP INDEX IF EXISTS dms_sample.set_sporting_event_idx;



DROP INDEX IF EXISTS dms_sample.set_ticketholder_idx;



DROP INDEX IF EXISTS dms_sample.tph_purch_by_id;



DROP INDEX IF EXISTS dms_sample.tph_trans_from_id;



-- ------------ Write DROP-TABLE-stage scripts -----------

DROP TABLE IF EXISTS dms_sample.mlb_data;



DROP TABLE IF EXISTS dms_sample.name_data;



DROP TABLE IF EXISTS dms_sample.nfl_data;



DROP TABLE IF EXISTS dms_sample.nfl_stadium_data;



DROP TABLE IF EXISTS dms_sample.person;



DROP TABLE IF EXISTS dms_sample.player;



DROP TABLE IF EXISTS dms_sample.seat;



DROP TABLE IF EXISTS dms_sample.seat_type;



DROP TABLE IF EXISTS dms_sample.sport_division;



DROP TABLE IF EXISTS dms_sample.sport_league;



DROP TABLE IF EXISTS dms_sample.sport_location;



DROP TABLE IF EXISTS dms_sample.sport_team;



DROP TABLE IF EXISTS dms_sample.sport_type;



DROP TABLE IF EXISTS dms_sample.sporting_event;



DROP TABLE IF EXISTS dms_sample.sporting_event_ticket;



DROP TABLE IF EXISTS dms_sample.ticket_purchase_hist;



-- ------------ Write CREATE-DATABASE-stage scripts -----------

CREATE SCHEMA IF NOT EXISTS dms_sample;



-- ------------ Write CREATE-TABLE-stage scripts -----------

CREATE TABLE dms_sample.mlb_data(
mlb_id DOUBLE PRECISION,
mlb_name CHARACTER VARYING(30),
mlb_pos CHARACTER VARYING(30),
mlb_team CHARACTER VARYING(30),
mlb_team_long CHARACTER VARYING(30),
bats CHARACTER VARYING(30),
throws CHARACTER VARYING(30),
birth_year CHARACTER VARYING(30),
bp_id DOUBLE PRECISION,
bref_id CHARACTER VARYING(30),
bref_name CHARACTER VARYING(30),
cbs_id CHARACTER VARYING(30),
cbs_name CHARACTER VARYING(30),
cbs_pos CHARACTER VARYING(30),
espn_id DOUBLE PRECISION,
espn_name CHARACTER VARYING(30),
espn_pos CHARACTER VARYING(30),
fg_id CHARACTER VARYING(30),
fg_name CHARACTER VARYING(30),
lahman_id CHARACTER VARYING(30),
nfbc_id DOUBLE PRECISION,
nfbc_name CHARACTER VARYING(30),
nfbc_pos CHARACTER VARYING(30),
retro_id CHARACTER VARYING(30),
retro_name CHARACTER VARYING(30),
debut CHARACTER VARYING(30),
yahoo_id DOUBLE PRECISION,
yahoo_name CHARACTER VARYING(30),
yahoo_pos CHARACTER VARYING(30),
mlb_depth CHARACTER VARYING(30)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.name_data(
name_type CHARACTER VARYING(15) NOT NULL,
name CHARACTER VARYING(45) NOT NULL
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.nfl_data(
position CHARACTER VARYING(5),
player_number NUMERIC(3,0),
name CHARACTER VARYING(40),
status CHARACTER VARYING(10),
stat1 CHARACTER VARYING(10),
stat1_val CHARACTER VARYING(10),
stat2 CHARACTER VARYING(10),
stat2_val CHARACTER VARYING(10),
stat3 CHARACTER VARYING(10),
stat3_val CHARACTER VARYING(10),
stat4 CHARACTER VARYING(10),
stat4_val CHARACTER VARYING(10),
team CHARACTER VARYING(10)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.nfl_stadium_data(
stadium CHARACTER VARYING(60),
seating_capacity DOUBLE PRECISION,
location CHARACTER VARYING(40),
surface CHARACTER VARYING(80),
roof CHARACTER VARYING(30),
team CHARACTER VARYING(40),
opened CHARACTER VARYING(10),
sport_location_id DOUBLE PRECISION
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.person(
id DOUBLE PRECISION NOT NULL,
full_name CHARACTER VARYING(60) NOT NULL,
last_name CHARACTER VARYING(30),
first_name CHARACTER VARYING(30)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.player(
id DOUBLE PRECISION NOT NULL,
sport_team_id DOUBLE PRECISION NOT NULL,
last_name CHARACTER VARYING(30),
first_name CHARACTER VARYING(30),
full_name CHARACTER VARYING(30)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.seat(
sport_location_id DOUBLE PRECISION NOT NULL,
seat_level NUMERIC(1,0) NOT NULL,
seat_section CHARACTER VARYING(15) NOT NULL,
seat_row CHARACTER VARYING(10) NOT NULL,
seat CHARACTER VARYING(10) NOT NULL,
seat_type CHARACTER VARYING(15)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.seat_type(
name CHARACTER VARYING(15) NOT NULL,
description CHARACTER VARYING(120),
relative_quality NUMERIC(2,0)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.sport_division(
sport_type_name CHARACTER VARYING(15) NOT NULL,
sport_league_short_name CHARACTER VARYING(10) NOT NULL,
short_name CHARACTER VARYING(10) NOT NULL,
long_name CHARACTER VARYING(60),
description CHARACTER VARYING(120)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.sport_league(
sport_type_name CHARACTER VARYING(15) NOT NULL,
short_name CHARACTER VARYING(10) NOT NULL,
long_name CHARACTER VARYING(60) NOT NULL,
description CHARACTER VARYING(120)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.sport_location(
id DOUBLE PRECISION NOT NULL,
name CHARACTER VARYING(60) NOT NULL,
city CHARACTER VARYING(60) NOT NULL,
seating_capacity NUMERIC(7,0),
levels NUMERIC(1,0),
sections NUMERIC(4,0)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.sport_team(
id DOUBLE PRECISION NOT NULL,
name CHARACTER VARYING(30) NOT NULL,
abbreviated_name CHARACTER VARYING(10),
home_field_id NUMERIC(3,0),
sport_type_name CHARACTER VARYING(15) NOT NULL,
sport_league_short_name CHARACTER VARYING(10) NOT NULL,
sport_division_short_name CHARACTER VARYING(10)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.sport_type(
name CHARACTER VARYING(15) NOT NULL,
description CHARACTER VARYING(120)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.sporting_event(
id DOUBLE PRECISION NOT NULL,
sport_type_name CHARACTER VARYING(15) NOT NULL,
home_team_id DOUBLE PRECISION NOT NULL,
away_team_id DOUBLE PRECISION NOT NULL,
location_id DOUBLE PRECISION NOT NULL,
start_date_time TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
sold_out NUMERIC(1,0) NOT NULL DEFAULT 0
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.sporting_event_ticket(
id DOUBLE PRECISION NOT NULL,
sporting_event_id DOUBLE PRECISION NOT NULL,
sport_location_id DOUBLE PRECISION NOT NULL,
seat_level NUMERIC(1,0) NOT NULL,
seat_section CHARACTER VARYING(15) NOT NULL,
seat_row CHARACTER VARYING(10) NOT NULL,
seat CHARACTER VARYING(10) NOT NULL,
ticketholder_id DOUBLE PRECISION,
ticket_price NUMERIC(8,2) NOT NULL
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE dms_sample.ticket_purchase_hist(
sporting_event_ticket_id DOUBLE PRECISION NOT NULL,
purchased_by_id DOUBLE PRECISION NOT NULL,
transaction_date_time TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
transferred_from_id DOUBLE PRECISION,
purchase_price NUMERIC(8,2) NOT NULL
)
        WITH (
        OIDS=FALSE
        );



-- ------------ Write CREATE-INDEX-stage scripts -----------

CREATE INDEX seat_sport_location_idx
ON dms_sample.seat
USING BTREE (sport_location_id ASC);



CREATE UNIQUE INDEX sport_team_u
ON dms_sample.sport_team
USING BTREE (sport_type_name ASC, sport_league_short_name ASC, name ASC);



CREATE INDEX se_start_date_fcn
ON dms_sample.sporting_event
USING BTREE (start_date_time ASC);



CREATE INDEX set_ev_id_tkholder_id_idx
ON dms_sample.sporting_event_ticket
USING BTREE (sporting_event_id ASC, ticketholder_id ASC);



CREATE INDEX set_seat_idx
ON dms_sample.sporting_event_ticket
USING BTREE (sport_location_id ASC, seat_level ASC, seat_section ASC, seat_row ASC, seat ASC);



CREATE INDEX set_sporting_event_idx
ON dms_sample.sporting_event_ticket
USING BTREE (sporting_event_id ASC);



CREATE INDEX set_ticketholder_idx
ON dms_sample.sporting_event_ticket
USING BTREE (ticketholder_id ASC);



CREATE INDEX tph_purch_by_id
ON dms_sample.ticket_purchase_hist
USING BTREE (purchased_by_id ASC);



CREATE INDEX tph_trans_from_id
ON dms_sample.ticket_purchase_hist
USING BTREE (transferred_from_id ASC);



-- ------------ Write CREATE-CONSTRAINT-stage scripts -----------

ALTER TABLE dms_sample.name_data
ADD CONSTRAINT name_data_pk PRIMARY KEY (name_type, name);



ALTER TABLE dms_sample.person
ADD CONSTRAINT person_pk PRIMARY KEY (id);



ALTER TABLE dms_sample.player
ADD CONSTRAINT player_pk PRIMARY KEY (id);



ALTER TABLE dms_sample.seat
ADD CONSTRAINT seat_pk PRIMARY KEY (sport_location_id, seat_level, seat_section, seat_row, seat);



ALTER TABLE dms_sample.seat_type
ADD CONSTRAINT st_seat_type_pk PRIMARY KEY (name);



ALTER TABLE dms_sample.sport_division
ADD CONSTRAINT sport_division_pk PRIMARY KEY (sport_type_name, sport_league_short_name, short_name);



ALTER TABLE dms_sample.sport_league
ADD CONSTRAINT sport_league_pk PRIMARY KEY (short_name);



ALTER TABLE dms_sample.sport_location
ADD CONSTRAINT sport_location_pk PRIMARY KEY (id);



ALTER TABLE dms_sample.sport_team
ADD CONSTRAINT sport_team_pk PRIMARY KEY (id);



ALTER TABLE dms_sample.sport_type
ADD CONSTRAINT sport_type_pk PRIMARY KEY (name);



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT chk_sold_out CHECK (sold_out IN (0, 1));



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT sporting_event_pk PRIMARY KEY (id);



ALTER TABLE dms_sample.sporting_event_ticket
ADD CONSTRAINT sporting_event_ticket_pk PRIMARY KEY (id);



ALTER TABLE dms_sample.ticket_purchase_hist
ADD CONSTRAINT ticket_purchase_hist_pk PRIMARY KEY (sporting_event_ticket_id, purchased_by_id, transaction_date_time);



-- ------------ Write CREATE-FOREIGN-KEY-CONSTRAINT-stage scripts -----------

ALTER TABLE dms_sample.player
ADD CONSTRAINT sport_team_fk FOREIGN KEY (sport_team_id) 
REFERENCES dms_sample.sport_team (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.seat
ADD CONSTRAINT s_sport_location_fk FOREIGN KEY (sport_location_id) 
REFERENCES dms_sample.sport_location (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.seat
ADD CONSTRAINT seat_type_fk FOREIGN KEY (seat_type) 
REFERENCES dms_sample.seat_type (name)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sport_division
ADD CONSTRAINT sd_sport_league_fk FOREIGN KEY (sport_league_short_name) 
REFERENCES dms_sample.sport_league (short_name)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sport_division
ADD CONSTRAINT sd_sport_type_fk FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample.sport_type (name)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sport_league
ADD CONSTRAINT sl_sport_type_fk FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample.sport_type (name)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sport_team
ADD CONSTRAINT home_field_fk FOREIGN KEY (home_field_id) 
REFERENCES dms_sample.sport_location (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sport_team
ADD CONSTRAINT st_sport_type_fk FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample.sport_type (name)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT se_away_team_id_fk FOREIGN KEY (away_team_id) 
REFERENCES dms_sample.sport_team (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT se_home_team_id_fk FOREIGN KEY (home_team_id) 
REFERENCES dms_sample.sport_team (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT se_location_id_fk FOREIGN KEY (location_id) 
REFERENCES dms_sample.sport_location (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event
ADD CONSTRAINT se_sport_type_fk FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample.sport_type (name)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event_ticket
ADD CONSTRAINT set_person_id FOREIGN KEY (ticketholder_id) 
REFERENCES dms_sample.person (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event_ticket
ADD CONSTRAINT set_seat_fk FOREIGN KEY (sport_location_id, seat_level, seat_section, seat_row, seat) 
REFERENCES dms_sample.seat (sport_location_id, seat_level, seat_section, seat_row, seat)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.sporting_event_ticket
ADD CONSTRAINT set_sporting_event_fk FOREIGN KEY (sporting_event_id) 
REFERENCES dms_sample.sporting_event (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.ticket_purchase_hist
ADD CONSTRAINT tph_sport_event_tic_id FOREIGN KEY (sporting_event_ticket_id) 
REFERENCES dms_sample.sporting_event_ticket (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.ticket_purchase_hist
ADD CONSTRAINT tph_ticketholder_id FOREIGN KEY (purchased_by_id) 
REFERENCES dms_sample.person (id)
ON DELETE NO ACTION;



ALTER TABLE dms_sample.ticket_purchase_hist
ADD CONSTRAINT tph_transfer_from_id FOREIGN KEY (transferred_from_id) 
REFERENCES dms_sample.person (id)
ON DELETE NO ACTION;



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



