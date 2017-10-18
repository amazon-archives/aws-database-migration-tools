# Detect non-UTF8 Characters in Oracle

Please follow the below mentioned steps to accurately detect the non-UTF8 Characters in your Oracle tables:

* Find the characterset that your database has been designed with:

```
SELECT VALUE FROM V$NLS_PARAMETERS WHERE PARAMETER IN ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET');
```

* If the output from the step 1 is **UTF8 & AL16UTF16**, use the following query:

```
SET SERVEROUTPUT ON SIZE 100000

DECLARE
  MATCH_COUNT INTEGER;
BEGIN  
  FOR T IN (SELECT OWNER, TABLE_NAME, COLUMN_NAME FROM ALL_TAB_COLUMNS WHERE DATA_TYPE IN ('CHAR', 'VARCHAR2', 'NCHAR', 'NVARCHAR2', 'CLOB', 'NCLOB') AND OWNER = **'<SCHEMA_NAME>'**) 
  LOOP   
    BEGIN
      EXECUTE IMMEDIATE    
        'SELECT COUNT(*) FROM ' || T.OWNER || '.' || T.TABLE_NAME || ' WHERE REGEXP_LIKE ('||T.COLUMN_NAME||', UNISTR(''[\D800-\DFFF]''))'
         INTO MATCH_COUNT;  
      IF MATCH_COUNT > 0 THEN 
        DBMS_OUTPUT.PUT_LINE( T.OWNER || '.' || T.TABLE_NAME ||' '||T.COLUMN_NAME||' '||MATCH_COUNT );
      END IF; 
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE( 'ERROR ENCOUNTERED TRYING TO READ ' || T.COLUMN_NAME || ' FROM ' || T.OWNER || '.' || T.TABLE_NAME );
    END;
  END LOOP;
END;

```

* If the output from the step 1 is **AL32UTF8 & AL16UTF16**, use the following query:

```
SET SERVEROUTPUT ON SIZE 100000

DECLARE
  MATCH_COUNT INTEGER;
BEGIN  
  FOR T IN (SELECT OWNER, TABLE_NAME, COLUMN_NAME FROM ALL_TAB_COLUMNS WHERE DATA_TYPE IN ('CHAR', 'VARCHAR2', 'NCHAR', 'NVARCHAR2', 'CLOB', 'NCLOB') AND OWNER = **'<SCHEMA_NAME>'**) 
  LOOP   
    BEGIN
      EXECUTE IMMEDIATE    
        'SELECT COUNT(*) FROM ' || T.OWNER || '.' || T.TABLE_NAME || ' WHERE REGEXP_LIKE ('||T.COLUMN_NAME||', UNISTR(''[\FFFF-\DBFF\DFFF]''))'
         INTO MATCH_COUNT;  
      IF MATCH_COUNT > 0 THEN 
        DBMS_OUTPUT.PUT_LINE( T.OWNER || '.' || T.TABLE_NAME ||' '||T.COLUMN_NAME||' '||MATCH_COUNT );
      END IF; 
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE( 'ERROR ENCOUNTERED TRYING TO READ ' || T.COLUMN_NAME || ' FROM ' || T.OWNER || '.' || T.TABLE_NAME );
    END;
  END LOOP;
END;

```

**Note**: The output of the query gives the **TABLE NAME**, **COLUMN NAME** and the **TOTAL COUNT OF RECORDS** in a particular column which are non-UTF8 as per DMS.

* To further review the exact records from the tables which were the output of the above query, use the below mentioned one to get more granular view:

  * If the output from the step 1 is **UTF8 & AL16UTF16**, use the following query:

      ```
      SELECT   COL_NAME, VAL, <PRIMARY_KEY_COLUMN>
      FROM     <TABLENAME>
      UNPIVOT  ( VAL FOR COL_NAME IN (
      **<OUTPUT FROM STEP2>**
      ) )
      WHERE REGEXP_LIKE( VAL, UNISTR('[\D800-\DFFF]'));
      ```

  * If the output from the step 1 is **AL32UTF8 & AL16UTF16**, use the following query:

      ```
      SELECT   COL_NAME, VAL, <PRIMARY_KEY_COLUMN>
      FROM     <TABLENAME>
      UNPIVOT  ( VAL FOR COL_NAME IN (
      **<OUTPUT FROM STEP2>**
      ) )
      WHERE REGEXP_LIKE( VAL, UNISTR('[\FFFF-\DBFF\DFFF]'));
      ```

## Usage

* Get the characterset:

![Characterset][erd]

[erd]: https://github.com/fdrgiit/LibraryMgmtSys/blob/master/Images/ora1.PNG "Characterset"

* Based on the above output, ran the query in Step 2

![UTF8identifier][erd1]

[erd1]: https://github.com/fdrgiit/LibraryMgmtSys/blob/master/Images/ora2.PNG "UTF8identifier"

* Get the data in the columns based on the above output

![columns][erd2]

[erd2]: https://github.com/fdrgiit/LibraryMgmtSys/blob/master/Images/ora3.PNG "columns"

## Author

Abhinav Singh
