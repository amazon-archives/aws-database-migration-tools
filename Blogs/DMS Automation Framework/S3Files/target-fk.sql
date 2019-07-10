
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
