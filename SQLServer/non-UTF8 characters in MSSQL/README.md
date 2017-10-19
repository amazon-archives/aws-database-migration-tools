# Detect non-UTF8 Characters in SQL Server

Please follow the below mentioned steps to accurately detect the non-UTF8 Characters in your SQL Server tables:

1. Run the script from **UTF8 Check.sql** to create stored procedure for non-UTF8 characters check in a schema

2. The above script will generate a stored prcedure **`spSearchString`**. (Input: **SCHEMA_NAME**)

  ```
  execute dbo.spSearchString @table_schema = '<SCHEMA_NAME>'
  ```

  The above stored procedure will create a stored procedure which will scan for all the non-UTF8 characters not supported by DMS on schema level and will give **SCHEMA NAME**, **TABLE NAME**, **COLUMN NAME** and the **TOTAL COUNT OF RECORDS** in a particular column which are non-UTF8 as per DMS.

3. To get the exact values in a particular table based on the output from the above step, run the T-SQL script from **UTF8 Value Check.sql** to create the stored procedure.

4. The above t-sql script will create the stored procedure **`spUTF8check`** (Input: **Schema_Name** and **Table_Name**):

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

/***********************************************************************************************
 Copyright [2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

    http://aws.amazon.com/apache2.0/

 or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 
***********************************************************************************************/
