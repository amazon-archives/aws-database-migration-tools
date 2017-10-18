# Detect non-UTF8 Characters in Oracle

Please follow the below mentioned steps to accurately detect the non-UTF8 Characters in your Oracle tables:

* Find the characterset that your database has been designed with:

```
SELECT VALUE FROM V$NLS_PARAMETERS WHERE PARAMETER IN ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET');
```

* If the output from the step 1 is **UTF8 & AL16UTF16**, use the pl/sql script mentioned in **`utf8.sql`**:

* If the output from the step 1 is **AL32UTF8 & AL16UTF16**, use the pl/sql script mentioned in **`al32utf8.sql`**:

**Note**: The output of the above queries gives the **TABLE NAME**, **COLUMN NAME** and the **TOTAL COUNT OF RECORDS** in a particular column which are non-UTF8 as per DMS.

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

/***********************************************************************************************
 Copyright [2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

    http://aws.amazon.com/apache2.0/

 or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

***********************************************************************************************/
