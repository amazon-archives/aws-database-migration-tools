select MESSAGE_ID, count(*) from mailing_list_message_table
where MESSAGE_TEXT_AOL LIKE concat('%',X'8F','%') or MESSAGE_TEXT_AOL LIKE concat('%',X'90','%') or MESSAGE_TEXT_AOL LIKE concat('%',X'81','%') or MESSAGE_TEXT_AOL LIKE concat('%',X'8D','%')or MESSAGE_TEXT_AOL LIKE concat('%',X'9D','%');
