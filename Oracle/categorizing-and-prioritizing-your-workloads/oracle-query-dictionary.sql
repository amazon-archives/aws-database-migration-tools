/***********************************************************************************************
 Copyright [2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

    http://aws.amazon.com/apache2.0/

 or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
***********************************************************************************************/
SET SERVEROUTPUT ON HEADING OFF FEEDBACK OFF VERIFY OFF TRIMSPOOL ON ECHO OFF DEFINE OFF;

SPOOL migration_candidates.csv APPEND;

DECLARE
    host_var VARCHAR2(255) := '';
    inst_var VARCHAR2(255) := '';
    vers_var VARCHAR2(255) := '';
    jobs_var NUMBER(10) := 0;
    tabl_var NUMBER(10) := 0;
    view_var NUMBER(10) := 0;
    proc_var NUMBER(10) := 0;
    func_var NUMBER(10) := 0;
    trig_var NUMBER(10) := 0;
    temp_var NUMBER(10) := 0;
    link_var NUMBER(10) := 0;
    part_var NUMBER(10) := 0;
    fcol_var NUMBER(10) := 0;
    mvew_var NUMBER(10) := 0;
BEGIN
    -- no header for this file, although the format should be well documented as above and below
    SELECT host_name, instance_name INTO host_var, inst_var
      FROM v$instance;
    -- get the database version that is installed on the server
    SELECT banner INTO vers_var
      FROM v$version
     WHERE BANNER LIKE '%Database%';
    -- look at all the schemas of interest with objects and exclude fixed Oracle schemas
    FOR schema_cur IN (SELECT owner FROM dba_objects
                        WHERE owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP', 'SYSMAN')
                       GROUP BY owner)
    LOOP
        -- count of the jobs running for this schema user
        SELECT COUNT(*) INTO jobs_var
          FROM dba_jobs
         WHERE schema_user = schema_cur.owner;
        -- count the number of tables
        SELECT COUNT(*) INTO tabl_var
          FROM dba_objects
         WHERE owner = schema_cur.owner
           AND object_type = 'TABLE';
        -- count the number of procedures
        SELECT COUNT(*) INTO proc_var
          FROM dba_objects
         WHERE owner = schema_cur.owner
           AND object_type IN ('PROCEDURE', 'PACKAGE');
        -- count the number of functions
        SELECT COUNT(*) INTO func_var
          FROM dba_objects
         WHERE owner = schema_cur.owner
           AND object_type = 'FUNCTION';
        -- count the number of views
        SELECT COUNT(*) INTO view_var
          FROM dba_objects
         WHERE owner = schema_cur.owner
           AND object_type = 'VIEW';
        -- count the number of triggers
        SELECT COUNT(*) INTO trig_var
          FROM dba_objects
         WHERE owner = schema_cur.owner
           AND object_type = 'TRIGGER';
        -- count the number of temporary tables
        SELECT COUNT(*) INTO temp_var
          FROM dba_tables
         WHERE owner = schema_cur.owner
           AND temporary = 'Y';
        -- count the number of database links
        SELECT COUNT(*) INTO link_var
          FROM dba_db_links
         WHERE owner = schema_cur.owner;
        -- count the number of partitioned tables
        SELECT COUNT(*) INTO part_var
          FROM dba_part_tables
         WHERE owner = schema_cur.owner;
        -- count the number of functional columns
        SELECT COUNT(*) INTO fcol_var
          FROM dba_tab_columns
         WHERE owner = schema_cur.owner
           AND data_default IS NOT NULL;
        -- count the number of materialized views
        SELECT COUNT(*) INTO mvew_var
          FROM dba_mviews
         WHERE owner = schema_cur.owner;
        -- output the data to a common .csv file for analysis
        DBMS_OUTPUT.PUT_LINE (host_var                   -- host name
                              ||','|| inst_var           -- instance name
                              ||','|| vers_var           -- database version
                              ||','|| schema_cur.owner   -- schema owner
                              ||','|| TO_CHAR(jobs_var)  -- jobs for this schema
                              ||','|| TO_CHAR(proc_var)  -- number of procedures
                              ||','|| TO_CHAR(func_var)  -- number of functions
                              ||','|| TO_CHAR(view_var)  -- number of views
                              ||','|| TO_CHAR(trig_var)  -- number of triggers
                              ||','|| TO_CHAR(temp_var)  -- number of temporary tables
                              ||','|| TO_CHAR(link_var)  -- number of database links
                              ||','|| TO_CHAR(part_var)  -- number of partitioned tables
                              ||','|| TO_CHAR(fcol_var)  -- number of functioal columns
                              ||','|| TO_CHAR(mvew_var)  -- number of materialized views
         );
    END LOOP;
END;
/

SPOOL OFF;
SET SERVEROUTPUT OFF PAGESIZE 120 HEADING ON FEEDBACK OFF VERIFY ON ECHO ON TRIMSPOOL OFF DEFINE ON;

