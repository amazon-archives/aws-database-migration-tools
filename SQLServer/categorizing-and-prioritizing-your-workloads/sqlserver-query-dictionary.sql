/***********************************************************************************************
 Copyright [2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

    http://aws.amazon.com/apache2.0/

 or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
***********************************************************************************************/

-- Suggested Use
-- --------------
-- sqlcmd -S myServer\myInstance -d mydatabase -U myUserAccount -P myPassword -i C:\myScript.sql -o C:\myOutput.txt
-- sqlcmd -S myServer -d mydatabase -E -i C:\mydir\myScript.sql -o C:\mydir\migration_candidates.csv
DECLARE @jobs_var NUMERIC(10) = 0
,@tabl_var NUMERIC(10) = 0
,@view_var NUMERIC(10) = 0
,@proc_var NUMERIC(10) = 0
,@func_var NUMERIC(10) = 0
,@trig_var NUMERIC(10) = 0
,@temp_var NUMERIC(10) = 0
,@link_var NUMERIC(10) = 0
,@fcol_var NUMERIC(10) = 0
,@mvew_var NUMERIC(10) = 0;
-- get the count of the jobs on the server
SELECT @jobs_var = COUNT(*)
  FROM msdb.dbo.sysjobs;
-- get count of number of tables
SELECT @tabl_var = COUNT(*)
  FROM sys.objects
 WHERE type = 'U';
-- get count of number of views
SELECT @view_var = COUNT(*)
  FROM sys.objects
 WHERE type = 'V';
-- get count of number of procedures
SELECT @proc_var = COUNT(*)
  FROM sys.objects
 WHERE type IN ('P', 'PC');
-- get count of number of functions
SELECT @func_var = COUNT(*)
  FROM sys.objects
 WHERE type IN ('FN', 'IF', 'TF');
-- get count of number of triggers
SELECT @trig_var = COUNT(*)
  FROM sys.objects
 WHERE type = 'TR';
-- global temporary tables
SELECT @temp_var = COUNT(*)
  FROM tempdb.sys.tables
 WHERE name LIKE '##%';
-- get the count of linked servers
SELECT  @link_var = COUNT(*)
  FROM  sys.servers
 WHERE name <> @@SERVERNAME;
-- computed or function columns
SELECT @fcol_var = COUNT(*)
  FROM sys.columns
 WHERE is_computed = 1;
-- list the indexed views
SELECT @mvew_var = COUNT(*)
  FROM sysobjects o
        JOIN sysindexes i ON o.id = i.id
 WHERE o.xtype = 'V' -- View

SELECT @@SERVERNAME
       + ',' + db_name()
       + ',' + @@VERSION
       + ',' + CAST(@jobs_var AS VARCHAR)
       + ',' + CAST(@view_var AS VARCHAR)
       + ',' + CAST(@proc_var AS VARCHAR)
       + ',' + CAST(@func_var AS VARCHAR)
       + ',' + CAST(@trig_var AS VARCHAR)
       + ',' + CAST(@temp_var AS VARCHAR)
       + ',' + CAST(@link_var AS VARCHAR)
       + ',' + CAST(@fcol_var AS VARCHAR)
       + ',' + CAST(@mvew_var AS VARCHAR);