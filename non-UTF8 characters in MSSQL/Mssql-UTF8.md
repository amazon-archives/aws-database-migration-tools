# Detect non-UTF8 Characters in SQL Server

Please follow the below mentioned steps to accurately detect the non-UTF8 Characters in your SQL Server tables:

1. Run the following script to create stored procedure for non-UTF8 characters check in a schema:

  ```
  SET ANSI_NULLS ON
  GO
  SET ANSI_NULLS ON
  GO
  CREATE PROCEDURE [dbo].[spSearchString]
  (@Table_Schema sysname)
   AS
   BEGIN
  IF OBJECT_ID('TempDB..#Result', N'U') IS NOT NULL DROP TABLE #Result;
  CREATE TABLE #RESULT ( [TABLE SCHEMA] sysname, [TABLE Name] sysname, [COLUMN Name] sysname,  [Number of Rows] NVARCHAR(MAX))
  DECLARE @Columns NVARCHAR(MAX), @Cols NVARCHAR(MAX), @PkColumn NVARCHAR(MAX), @Table_Name NVARCHAR(MAX)
  DECLARE curAllTables CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY
      FOR
      SELECT   Table_Name
      FROM     INFORMATION_SCHEMA.Tables   
      WHERE TABLE_TYPE = 'BASE TABLE'
      ORDER BY Table_Schema, Table_Name

      OPEN curAllTables
      FETCH  curAllTables
      INTO @Table_Name   
      WHILE (@@FETCH_STATUS = 0) -- Loop through all tables in the database
        BEGIN  
  -- Get all character columns
  SET @Columns = STUFF((SELECT ', ' + QUOTENAME(Column_Name)
   FROM INFORMATION_SCHEMA.COLUMNS
   WHERE DATA_TYPE IN ('text','ntext','varchar','nvarchar','char','nchar') AND
   TABLE_NAME = @Table_Name AND TABLE_SCHEMA = @Table_Schema
   ORDER BY COLUMN_NAME
   FOR XML PATH('')),1,2,'');

  IF @Columns IS NULL -- no character columns
     RETURN -1;

  -- Get columns for select statement - we need to convert all columns to nvarchar(max)
  SET @Cols = STUFF((SELECT ', CAST(' + QUOTENAME(Column_Name) + ' AS nvarchar(max)) COLLATE DATABASE_DEFAULT AS ' + QUOTENAME(Column_Name)
   FROM INFORMATION_SCHEMA.COLUMNS
  --Filter required DATA Types
   WHERE DATA_TYPE IN ('text','ntext','varchar','nvarchar','char','nchar')
   AND TABLE_NAME = @Table_Name AND TABLE_SCHEMA = @Table_Schema
   ORDER BY COLUMN_NAME
   FOR XML PATH('')),1,2,'');

   SET @PkColumn = STUFF((SELECT N' + ''|'' + ' + ' CAST(' + QUOTENAME(CU.COLUMN_NAME) + ' AS nvarchar(max)) COLLATE DATABASE_DEFAULT '

  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
  INNER JOIN
  INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS CU
  ON TC.CONSTRAINT_TYPE = 'PRIMARY KEY' AND
  TC.CONSTRAINT_NAME = CU.CONSTRAINT_NAME

   WHERE TC.TABLE_SCHEMA = @Table_Schema AND TC.TABLE_NAME = @Table_Name
   ORDER BY CU.ORDINAL_POSITION
   FOR XML PATH('')),1,9,'');

   IF @PkColumn IS NULL
      SELECT @PkColumn = 'CAST(NULL AS nvarchar(max))';

   -- set select statement using dynamic UNPIVOT
   DECLARE @SQL NVARCHAR(MAX)
   SET @SQL = 'SELECT ' + QUOTENAME(@Table_Schema,'''') + ' AS [Table Schema], ' + QUOTENAME(@Table_Name,'''') + ' AS [Table Name],' +
  '[Column Name], count([Column Value]) As [Number of Rows] '+
    ' FROM
    (SELECT '+ @PkColumn + ' AS [PK Column], ' + @Cols + ' FROM ' 
  + QUOTENAME(@Table_Schema) + '.' + QUOTENAME(@Table_Name) +  ' ) src 
  UNPIVOT ([Column Value] for [Column Name] IN (' + @Columns + ')) unpvt
   WHERE patindex(''%[^ !-~]%'' COLLATE Latin1_General_BIN, [Column Value]) >0 AND [Column Value] not like ''%''+char(13)+''%'' AND [Column Value] not like ''%''+char(10)+''%'' GROUP BY unpvt.[Column Name]' 
   --[Column Value] LIKE ''%'' + @SearchString + ''%'''

  INSERT #RESULT ([TABLE SCHEMA], [TABLE Name], [COLUMN Name], [Number of Rows] )
  EXECUTE sp_ExecuteSQL @SQL;
  FETCH  curAllTables
          INTO @Table_Name
        END -- while
      CLOSE curAllTables
      DEALLOCATE curAllTables
  SELECT * FROM #RESULT ORDER BY [Table Name]
  END
  GO
  ```

2. The above script will generate a stored prcedure **`spSearchString`**. (Input: **SCHEMA_NAME**)

  ```
  execute dbo.spSearchString @table_schema = '<SCHEMA_NAME>'
  ```

  The above stored procedure will create a stored procedure which will scan for all the non-UTF8 characters not supported by DMS on schema level and will give **SCHEMA NAME**, **TABLE NAME**, **COLUMN NAME** and the **TOTAL COUNT OF RECORDS** in a particular column which are non-UTF8 as per DMS.

3. To get the exact values in a particular table based on the output from the above step, run the following T-SQL script to create the stored procedure:

  ```
  USE [test]
  GO

  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE PROCEDURE [dbo].[spUTF8check]
  (@Table_Schema sysname = 'dbo',
   @Table_Name sysname)
   AS
   BEGIN
  DECLARE @Columns NVARCHAR(MAX), @Cols NVARCHAR(MAX), @PkColumn NVARCHAR(MAX)

  -- Get all character columns
  SET @Columns = STUFF((SELECT ', ' + QUOTENAME(Column_Name)
   FROM INFORMATION_SCHEMA.COLUMNS
   WHERE DATA_TYPE IN ('text','ntext','varchar','nvarchar','char','nchar') AND
   TABLE_NAME = @Table_Name AND TABLE_SCHEMA = @Table_Schema
   ORDER BY COLUMN_NAME
   FOR XML PATH('')),1,2,'');

  IF @Columns IS NULL -- no character columns
     RETURN -1;

  -- Get columns for select statement - we need to convert all columns to nvarchar(max)
  SET @Cols = STUFF((SELECT ', CAST(' + QUOTENAME(Column_Name) + ' AS nvarchar(max)) COLLATE DATABASE_DEFAULT AS ' + QUOTENAME(Column_Name)
   FROM INFORMATION_SCHEMA.COLUMNS
  --Filter required DATA Types
   WHERE DATA_TYPE IN ('text','ntext','varchar','nvarchar','char','nchar')
   AND TABLE_NAME = @Table_Name AND TABLE_SCHEMA = @Table_Schema
   ORDER BY COLUMN_NAME
   FOR XML PATH('')),1,2,'');

   SET @PkColumn = STUFF((SELECT N' + ''|'' + ' + ' CAST(' + QUOTENAME(CU.COLUMN_NAME) + ' AS nvarchar(max)) COLLATE DATABASE_DEFAULT '

  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
  INNER JOIN
  INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS CU
  ON TC.CONSTRAINT_TYPE = 'PRIMARY KEY' AND
  TC.CONSTRAINT_NAME = CU.CONSTRAINT_NAME

   WHERE TC.TABLE_SCHEMA = @Table_Schema AND TC.TABLE_NAME = @Table_Name
   ORDER BY CU.ORDINAL_POSITION
   FOR XML PATH('')),1,9,'');

   IF @PkColumn IS NULL
      SELECT @PkColumn = 'CAST(NULL AS nvarchar(max))';

   -- set select statement using dynamic UNPIVOT
   DECLARE @SQL NVARCHAR(MAX)
   SET @SQL = 'SELECT *, ' + QUOTENAME(@Table_Schema,'''') + ' AS [Table Schema], ' + QUOTENAME(@Table_Name,'''') + ' AS [Table Name]' +
    ' FROM
    (SELECT '+ @PkColumn + ' AS [PK Column], ' + @Cols + ' FROM ' + QUOTENAME(@Table_Schema) + '.' + QUOTENAME(@Table_Name) +  ' ) src UNPIVOT ([Column Value] for [Column Name] IN (' + @Columns + ')) unpvt
   WHERE patindex(''%[^ !-~]%'' COLLATE Latin1_General_BIN, [Column Value]) >0 AND [Column Value] not like ''%''+char(13)+''%'' AND [Column Value] not like ''%''+char(10)+''%''' 
   --[Column Value] LIKE ''%'' + @SearchString + ''%'''

  EXECUTE sp_ExecuteSQL @SQL;
  END

  GO
  ```

4. Execute the above t-sql script to create the stored procedure **`spUTF8check`** (Input: **Schema_Name** and **Table_Name**):

  ```
  execute dbo.spUTF8check @table_schema = '<SCHEMA_NAME>', @table_name = '<TABLE_NAME>'
  ```
  
## Usage

* Execute the whole t-sql script mentioned in step 1 to create the stored procedure **`spSearchString`**

* Execute the whole t-sql script mentioned in step 3 to create the stored procedure **`spUTF8check`**

* Get the non-UTF8 character information:

![spSearchString][erd2]

[erd2]: https://github.com/fdrgiit/LibraryMgmtSys/blob/master/Images/sql1.PNG "spSearchString"

* Get the exact values in the tables based on the above output:

![spUTF8check][erd3]

[erd3]: https://github.com/fdrgiit/LibraryMgmtSys/blob/master/Images/sql2.PNG "spUTF8check"

## Author

Abhinav Singh
