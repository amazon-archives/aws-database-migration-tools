\t
select 'create sequence dms_sample.player_seq increment by 10 minvalue 1 start with '|| max(id) ||';' from dms_sample.player;
select 'create sequence dms_sample.sporting_event_seq increment by 10 minvalue 1 start with '|| max(id) ||';' from dms_sample.sporting_event;
select 'create sequence dms_sample.sporting_event_ticket_seq increment by 10 minvalue 1 start with '|| max(id) ||';' from dms_sample.sporting_event_ticket;
select 'create sequence dms_sample.sport_location_seq increment by 1 minvalue 1 start with '|| max(id) ||';' from dms_sample.sport_location;
select 'create sequence dms_sample.sport_team_seq increment by 10 minvalue 1 start with '|| max(id) ||';' from dms_sample.sport_team;
