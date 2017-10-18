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