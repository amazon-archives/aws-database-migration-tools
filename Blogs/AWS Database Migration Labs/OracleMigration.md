# Step-by-Step Guide for Oracle Migration to Amazon Aurora (PostgreSQL)

This step-by-step guide demonstrates how you can use [AWS Database Migration Service (DMS)][aws-dms] and [AWS Schema Conversion Tool (AWS SCT)][aws-sct] to migrate an Oracle database to [Amazon Aurora (PostgreSQL)][aurora]. Additionally, you will use AWS DMS to continually replicate database changes from the source database to the target database.

# Connecting to your Environment 

Before proceeding further, make sure you have completed the instructions in the [Environment Configuration][env-config] step to deploy the resources we will be using for this database migration in your own account. These resources include:

- An [Amazon Elastic Compute Cloud (Amazon EC2)][ec2] instance to run the AWS Schema Conversion Tool (AWS SCT), Microsoft SQL Server Management Studio, and MySQL Workbench.
-	An Amazon RDS Instance used to host the source Oracle database. 
- An AWS RDS Aurora (PostgreSQL) instance used as the target database.

Once you have completed the instructions in the [Environment Configuration][env-config] step, take special note of the following output values: 

- SourceEC2PublicDNS
- TargetAuroraMySQLEndpoint
- The path to your private key (DMSKeyPair.pem)

# Part 1: Converting Database Schema Using the AWS Schema Conversion Tool (AWS SCT)

The AWS Schema Conversion Tool is a [downloadable][download-sct] application that enables you to convert your existing database schema from one database engine to another. You can convert relational OLTP schemas, data warehouse OLAP schemas, and document-based NoSQL database schemas. AWS SCT specifically eases the transition from one database engine to another. In addition, it can move your table DDL, views, and stored procedure DML to a different platform. The tool generates an assessment report which lists the objects that can be automatically converted and recommends manual changes were needed.

The following steps provide instructions for converting an Oracle database to an Amazon Aurora PostgreSQL database. Additionally, you will observe how AWS SCT helps you spot the differences between the two dialects; and, provides you with tips about how you can modify procedural code when needed to successfully migrate all database objects. 

In this exercise, you perform the following tasks:
- [Log into the Windows EC2 Instance](#log-into-the-windows-ec2-instance)
- [Install the Schema Conversion Tool on the Server](#install-the-schema-conversion-tool-on-the-server)
- [Create a Database Migration Project in the SCT](#create-a-database-migration-project)
- [Convert the schema using the SCT](#convert-the-schema)
- [Modify Procedural Code to Adapt It For the New Database Dialect](#modify-procedural-code-to-adapt-it-for-the-new-database-dialect)

## Log into the Windows EC2 Instance
1.	Go to the AWS EC2 [console][ec2-console] and click on **Instances** in the left column.
2.	Select the instance with the name **\<StackName\>-EC2Instance** and then click the Connect button. 

![\[SqlSct01\]](img/SqlSct01.png)

3. In this step, you retrieve the EC2 administrator password in order to RDP into the instnace:

    1. Click the **Get Password** button.
    ![\[SqlSct02\]](img/SqlSct02.png)
    2. Upload the **Key Pair** file that you downloaded earlier.
    3. Click on **Decrypt Password**.
    ![\[SqlSct02-b\]](img/SqlSct02-b.png)
    4. Take note of the EC2 console generated administrator password.
    5. Click on **Download Remote Desktop File** to download the RDP file to access this EC2 instance. 
    6. Connect to the EC2 instance using an RDP client.

## Install the Schema Conversion Tool on the server
Now that you are connected to the source SQL Server (the EC2 instance), you are going to install the AWS Schema Conversion tool on the server. Downloading the file and installing it will give you the latest version of the AWS Schema Conversion Tool.

4. On the EC2 server, open the **DMS Workshop** folder that is on the **Desktop**. Then, double-click on **AWS Schema Conversion Tool Download** to get the latest version of the software. 

5. When the download is complete, unzip the content and install the AWS Schema Conversion Tool.

*NOTE: When the installer is complete the installation dialog will disappear. There is no other notification.*

6. Once the installation is complete, go to the **Start Menu** and launch the AWS Schema Conversion Tool. 

![\[SqlSct03\]](img/SqlSct03.png)

7. **Accept** the terms and Conditions.

![\[SqlSct04\]](img/SqlSct04.png)

## Create a Database Migration Project in the SCT
Now that you have installed the AWS Schema Conversion Tool, the next step is to create a Database Migration Project using the tool.

*Note: AWS SCT uses JDBC driver to connect to the source and target database. To download the Oracle and PostgreSQL JDBC drivers on the EC2 instance, go to https://www.oracle.com/jdbc & https://jdbc.postgresql.org/ respectively.*

8. Within the Schema Conversion Tool, enter the following values into the form and then click **Next**.

| **Parameter** | **Value** |
| ------ | ------ |
| **Project Name** | AWS Schema Conversion Tool Oracle to Aurora PostgreSQL |
| **Location** | C:\Users\Administrator\AWS Schema Conversion Tool\Projects |
| **Database Type** | Transactional Database (OLTP) |
| **Source Database Engine** | Oracle / I want to switch engines and optimize for the cloud |

![\[OracleSct05\]](img/OracleSct05.png)

9. Specify the source database configurations in the form, and click **Test Connection**. Once the connection is successfully tested, click **Next**.

| **Parameter** | **Value** |
| ------ | ------ |
| **Type** | SID |
| **Server Name** | **\< SourceOracleEndpoint \>** |
| **Server Port** | 1521 |
| **Oracle SID** | ORACLEDB |
| **User Name** | dbmaster |
| **Password** | dbmaster123 |
| **Use SSL** | Unchecked |
| **Store Password** | Checked |
| **Oracle Driver Path** | **Path to Oracle JDBC driver on the EC2 instance that you downloaded from https://www.oracle.com/jdbc** |

![\[OracleSct06\]](img/OracleSct06.png)

10.	Select the **DMS_SAMPLE** database, then click **Next**.

![\[OracleSct07\]](img/OracleSct07.png)

11.	Review the **Database Migration Assessment Report**.

![\[OracleSct08\]](img/OracleSct08.png)


SCT will examine in detail all of the objects in the schema of source database. It will convert as much as possible automatically and provides detailed information about items it could not convert. 

![\[OracleSct09\]](img/OracleSct09.png)

Generally, packages, procedures, and functions are more likely to have some issues to resolve because they contain the most custom or proprietary SQL code. AWS SCT specifies how much manual change is needed to convert each object type. It also provides hints about how to adapt these objects to the target schema successfully.

12.	After you are done reviewing the database migration assessment report, click **Next**.

13.	Specify the target database configurations in the form, and then click **Test Connection**. Once the connection is successfully tested, click **Finish**.

| **Parameter** | **Value** |
| ------ | ------ |
| **Target Database Engine** | Amazon Aurora (PostgreSQL compatible) |
| **Server Name** | **\< TargetAuroraPostgreSQLEndpoint \>** |
| **Server Port** | 5432 |
| **Database Name** | AuroraDB |
| **User Name** | dbmaster |
| **Password** | dbmaster123 |
| **Use SSL** | Unchecked |
| **Save Password** | Checked |
| **Amazon Aurora Driver Path** | **Path to PostgreSQL JDBC driver on the EC2 instance that you downloaded from https://jdbc.postgresql.org/** |

![\[OracleSct10\]](img/OracleSct10.png)

## Convert the Schema Using the SCT
Now that you have created a new Database Migration Project, the next step is to convert the Oracle schema of the source database to that of Amazon Aurora PostgreSQL database. 

14.	Right-click on the **DMS_SAMPLE** schema from Oracle source and select **Convert Schema** to generate the data definition language (DDL) statements for the target database.  

You can view the generated DDL in the project console, and edit it before applying it to the target database. You can also choose to save it as an .sql file for application later.

*NOTE: You may be prompted with a dialog box “Object may already exist in the target database, replace?” Select Yes and conversion will start.*

![\[OracleSct11\]](img/OracleSct11.png)

AWS SCT analyses the schema and creates a database migration assessment report for the conversion to PostgreSQL. Items with a red exclamation mark next to them cannot be directly translated from the source to the target. This includes Stored Procedures, and Packages.

15.	Click on the **View** button, and choose **Assessment Report view**. 

![\[OracleSct12\]](img/OracleSct12.png)

16.	Next, navigate to the **Action Items** tab in the report to see the items that the tool could not convert, and find out how much manual changes you need to make. 

![\[OracleSct13\]](img/OracleSct13.png)

Check each of the issues listed and compare the contents under the source Oracle panel and the target Aurora PostgreSQL panel. Are the issues resolved? And how? 

SCT has proposed resolutions by generating equivalent PostgreSQL DDL to convert the objects. Additionally, SCT highlights each conversion issue where it cannot automatically generate a conversion, and provides you with hints on how you can successfully convert the database object.

Notice the issue highlighted in the private function named **GET_OPEN_EVENTS**. You’ll see that SCT is unable to automatically convert the assign operation. You can complete one of the following actions to fix the issue:

  1. Modify the objects on the source Oracle database so that AWS SCT can convert the objects to the target Aurora PostgreSQL database.
  2. Instead of modifying the source schema, modify scripts that AWS SCT generates before applying the scripts on the target Aurora PostgreSQL database.

![\[OracleSct14\]](img/OracleSct14.png)

17.	[Optional] Manually fix the schema issue. Then, right-click on the DMS_SAMPLE schema, and choose Create Report. Observe that the schema of the source database is now fully compatible with the target database. 


18.	Right click on the **dms_sample** schema in the right-hand panel, and click **Apply to database**.

![\[OracleSct15\]](img/OracleSct15.png)

19.	When prompted if you want to apply the schema to the database, click **Yes**.

![\[OracleSct16\]](img/OracleSct16.png)

20.	At this point, the schema has been applied to the target database. Expand the **dms_sample** schema to see the tables.

*NOTE: You may see an exclamation mark on certain database objects such as indexes, and foreign key constraints. In Part 2 we will drop foreign key target database.*

You have sucessfully converted the database schema and object from Oracle to the format compatible with Amazon Aurora (PostgreSQL). 

This part demonstrated how easy it is to migrate the schema of an Oracle database into Amazon Aurora (PostgreSQL) using the AWS Schema Conversion Tool.  Similarly, you learned how the Schema Conversion Tool highlights the differences between different database engine dialects, and provides you with tips on how you can successfully modify the code when needed to migrate procedure and other database objects.

The same steps can be followed to migrate SQL Server and Oracle workloads to other RDS engines including PostgreSQL and MySQL.

The next section describes the steps required to move the actual data using AWS DMS.


# Part 2: Migrating the Data Using the AWS Database Migration Service (AWS DMS)

AWS Database Migration Service (DMS) helps you migrate databases to AWS easily and securely. The source database remains fully operational during the migration, minimizing downtime to applications that rely on the database. AWS DMS can migrate your data to and from most widely used commercial and open-source databases. The service supports homogenous migrations such as SQL Server to SQL Server, as well as heterogeneous migrations between different database platforms, such as SQL Server to Amazon Aurora MySQL or Oracle to Amazon Aurora PostgreSQL. AWS DMS can also be used for continuous data replication with high-availability.

AWS DMS doesn't migrate your secondary indexes, sequences, default values, stored procedures, triggers, synonyms, views, and other schema objects that aren't specifically related to data migration. To migrate these objects to your Aurora PostgreSQL target, we used the AWS Schema Conversion Tool (AWS SCT) in Part 1 of this guide. 

In this section we will perform database migration from a source Oracle database on an Amazon RDS instance to a target Amazon Aurora (PostgreSQL) in two parts:

1. First, you perform a full load migration of source oracle database to target Aurora PostgreSQL database using AWS DMS.

2. Next, you capture data changes (CDC) from the Oracle database, and replicate them automatically to Aurora PostgreSQL instance using AWS DMS.	

*Please note that you need to complete the steps described in the AWS Schema Conversion Tool (SCT) section as a pre-requisite for this part.* 

The following steps provide instructions to migrate existing data from the source Oracle running on an Amazon RDS instance to a target Amazon Aurora (PostgreSQL) database. In this exercise you perform the following tasks:
- [Connect To The Source Oracle Database](#connect-to-the-source-oracle-database-)
- [Configure The Source Oracle Database For Replication](#configure-the-source-oracle-database-for-replication)
- [Configure The Target Aurora RDS Database For Replication](#configure-the-target-aurora-rds-database-for-replication)
- [Create an AWS DMS Replication Instance](#create-an-aws-dms-replication-instance)
- [Create AWS DMS Source and Target Endpoints](#create-aws-dms-source-and-target-endpoints)
- [Create And Run an AWS DMS Migration Task](#create-and-run-an-aws-dms-migration-task)
- [Inspect the Content of Target Database](#inspect-the-content-of-the-target-database)
- [Capture Data Changes](#capture-data-changes)
- [Replicating Data Changes from Source to the Target Database](#replicating-data-changes-from-source-to-the-target-database)

## Connect To The Source Oracle Database

If you disconnected from the Source EC2 instance, follow the steps 1 to 3 in Part 1 to RDP to the instance. 

1. Once connected, open **Oracle SQL Developer** from the **Taskbar**.

![\[OracleDms01\]](img/OracleDms01.png)

2. Click on the **plus sign** from the left-hand menu to create a **New Database Connection** using the following values, then click **Connect**.

| **Parameter** | **Value** |
| ------ | ------ |
| **Connection Name** | Source Oracle |
| **Username** | dbmaster |
| **Password** | dbmaster123 |
| **Save Password ** | Check |
| **Hostname** | **\< SourceOracleEndpoint \>** |
| **Port** | 1521 |
| **SID** | ORACLEDB |

![\[OracleDms02\]](img/OracleDms02.png)

3. After the you see the test status as **Successful**, click **Connect**. 

## Configure the Source Oracle Database for Replication

To use Oracle as a source for AWS Database Migration Service (AWS DMS), you must first provide a user account (DMS user) with read and write privileges on the Oracle database. 

You also need to ensure that ARCHIVELOG MODE is on to provide information to LogMiner. AWS DMS uses LogMiner to read information from the archive logs so that AWS DMS can capture changes.  

For AWS DMS to read this information, make sure the archive logs are retained on the database server as long as AWS DMS requires them. Retaining archive logs for 24 hours is usually sufficient. 

To capture change data, AWS DMS requires database-level supplemental logging to be enabled on your source database. Doing this ensures that the LogMiner has the minimal information to support various table structures such as clustered and index-organized tables. 	

Similarly, you need to enable table-level supplemental logging for each table that you want to migrate.

4. Click on the **SQL Worksheet** icon within **Oracle SQL Developer**, then connect to the **Source Oracle** database.  
      
![\[OracleDms03\]](img/OracleDms03.png)

5. Next, execute the below statements to grant the following privileges to the AWS DMS user to access the source Oracle endpoint:

```sql
GRANT SELECT ANY TABLE to DMS_USER;
GRANT SELECT on ALL_VIEWS to DMS_USER;
GRANT SELECT ANY TRANSACTION to DMS_USER;
GRANT SELECT on DBA_TABLESPACES to DMS_USER;
GRANT SELECT on ALL_TAB_PARTITIONS to DMS_USER;
GRANT SELECT on ALL_INDEXES to DMS_USER;
GRANT SELECT on ALL_OBJECTS to DMS_USER;
GRANT SELECT on ALL_TABLES to DMS_USER;
GRANT SELECT on ALL_USERS to DMS_USER;
GRANT SELECT on ALL_CATALOG to DMS_USER;
GRANT SELECT on ALL_CONSTRAINTS to DMS_USER;
GRANT SELECT on ALL_CONS_COLUMNS to DMS_USER;
GRANT SELECT on ALL_TAB_COLS to DMS_USER;
GRANT SELECT on ALL_IND_COLUMNS to DMS_USER;
GRANT SELECT on ALL_LOG_GROUPS to DMS_USER;
GRANT LOGMINING TO DMS_USER;
```
![\[OracleDms04\]](img/OracleDms04.png)

6. In addition, run the following:

```sql
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$ARCHIVED_LOG','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOG','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGFILE','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$DATABASE','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$THREAD','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$PARAMETER','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$NLS_PARAMETERS','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$TIMEZONE_NAMES','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$TRANSACTION','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_REGISTRY','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('OBJ$','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('ALL_ENCRYPTED_COLUMNS','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_LOGS','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_CONTENTS','DMS_USER','SELECT');
exec rdsadmin.rdsadmin_util.grant_sys_object('DBMS_LOGMNR','DMS_USER','EXECUTE');
```

![\[OracleDms05\]](img/OracleDms05.png)

7. Run the following query to retain archived redo logs of the source Oracle database instance for 24 hours:

```sql
exec rdsadmin.rdsadmin_util.set_configuration('archivelog retention hours',24);
```

8. Run the following query to enable database-level supplemental logging:

```sql
exec rdsadmin.rdsadmin_util.alter_supplemental_logging('ADD');
```

9. Run the following query to enable PRIMARY KEY logging for tables that have primary keys:

```sql
exec rdsadmin.rdsadmin_util.alter_supplemental_logging('ADD','PRIMARY KEY');
```

10.	Run the following queries to add supplemental logging for tables that don’t have primary keys, use the following command to add supplemental logging:

```sql
alter table dms_sample.nfl_stadium_data add supplemental log data (ALL) columns;
alter table dms_sample.mlb_data add supplemental log data (ALL) columns;
alter table dms_sample.nfl_data add supplemental log data (ALL) columns;
```

![\[OracleDms06\]](img/OracleDms06.png)

## Configure The Target Aurora RDS Database For Replication

During the full load process, AWS DMS does not load tables in any particular order, so it might load the child table data before parent table data. As a result, foreign key constraints might be violated if they are enabled. Also, if triggers are present on the target database, they might change data loaded by AWS DMS in unexpected ways.

11.	Open **pgAdmin 4** from the **Taskbar** on the EC2 server.

![\[OracleDms07\]](img/OracleDms07.png)

12. You may be prompted to set a **Master Password**. Enter **dbmaster123**, then click, **OK**.

![\[OracleDms08\]](img/OracleDms08.png)

13.	Click on the **Add New Server** icon, and enter the following values. Then, press **Save**.

| **Parameter** | **Value** |
| ------ | ------ |
| **General -> Name** | Target Aurora RDS (PostgreSQL) |
| **Connection -> Host Name/Address** | **\<TargetAuroraPostgreSQLEndpoint\>** |
| **Connection -> Port** | 5432 |
| **Connection -> Username** | dbmaster |
| **Connection -> Password** | dbmaster123 |
| **Connection -> Save Password** | Check |

![\[OracleDms09\]](img/OracleDms09.png)

14.	Right-click on **AuroraDB** database from left-hand menu, and then select **Query Tool**. 

![\[OracleDms10\]](img/OracleDms10.png)

15.	In this step you are going to drop the foreign key constraints from the target database:
- 1. Open **DropConstraintsPostgreSQL.sql** inside the **DMS Workshop\Scripts** folder in Notepad. 
- 2. Copy the content of the file to the **Query Editor** in **pgAdmin 4**.
- 3. **Execute** the script.

![\[OracleDms11\]](img/OracleDms11.png)

## Create an AWS DMS Replication Instance

The following illustration shows a high-level view of the migration process.

![\[OracleDms12\]](img/OracleDms12.png)

An AWS DMS replication instance performs the actual data migration between source and target. The replication instance also caches the transaction logs during the migration. The amount of CPU and memory capacity of a replication instance influences the overall time that is required for the migration.

8.	Navigate to the Database Migration Service (DMS) [console][dms-console].

9.	On the left-hand menu click on **Replication Instances**. This will launch the Replication instance screen.

10.	Click on the **Create replication instance** button on the top right side.

![\[OracleDms13\]](img/OracleDms13.png)

11.	Enter the following information for the **Replication Instance**. Then, click on the **Create** button.

| **Parameter** | **Value** |
| ------ | ------ |
| **Name** | DMSReplication |
| **Description** | Replication server for Database Migration |
| **Instance Class** | dms.c4.xlarge |
| **Engine version** | Leave the default value |
| **Allocated storage (GB)** | 50 |
| **VPC** | **\<VPC ID from Environment Setup Step\>** |
| **Multi-AZ** | No |
| **Publicly accessible** | No |
| **Advanced -> VPC Security Group(s)** | default |

![\[OracleDms14\]](img/OracleDms14.png)

*NOTE: Creating replication instance will take several minutes. While waiting for the replication instance to be created, you can specify the source and target database endpoints in the next steps. However, test connectivity only after the replication instance has been created, because the replication instance is used in the connection.*


## Create AWS DMS Source and Target Endpoints
Now that you have a replication instance, you need to create source and target endpoints for the sample database. 

12.	Click on the **Endpoints** link on the left, and then click on **Create endpoint** on the top right corner. 

![\[OracleDms15\]](img/OracleDms15.png)

13.	Enter the following information to create an endpoint for the source **dms_sample** database:

| **Parameter** | **Value** |
| ------ | ------ |
| **Endpoint Type** | Source endpoint |
| **Select RDS DB instance** | Check |
| **RDS Instance** | **\<StackName\>-SourceOracleDB** |
| **Endpoint Identifier** | sqlserver-source |
| **Source Engine** | oracle |
| **Server Name** | **\< SourceOracleEndpoint  \>** |
| **Port** | 1521 |
| **SSL Mode** | none |
| **User Name** | dbmaster |
| **Password** | dbmaster123 | 
| **SID/Service Namee** | ORACLEDB |
| **Test endpoint connection -> VPC** | **\< VPC ID from Environment Setup Step \>** |
| **Replication Instance** | oracle-replication |

![\[OracleDms16\]](img/OracleDms16.png)

14.	Once the information has been entered, click **Run Test**. When the status turns to **successful**, click **Create endpoint**.

15.	Follow the same steps to create another endpoint for the **Target Aurora RDS Database** using the following values:

| **Parameter** | **Value** |
| ------ | ------ |
| **Endpoint Type** | Target endpoint |
| **Select RDS DB instance** | **\<StackName\>-AuroraPostgreSQLInstance** |
| **Endpoint Identifier** | aurora-target |
| **Source Engine** | aurora-postgresql |
| **Server Name** | **\< TargetAuroraPostgreSQLEndpoint   \>** |
| **Port** | 5432 |
| **SSL Mode** | none |
| **User Name** | dbmaster |
| **Password** | dbmaster123 | 
| **Database Name** | AuroraDB |
| **Test endpoint connection -> VPC** | **\< VPC ID from Environment Setup Step \>** |
| **Replication Instance** | oracle-replication |

![\[OracleDms17\]](img/OracleDms17.png)

16.	Once the information has been entered, click **Run Test**. When the status turns to **successful**, click **Create endpoint**.

## Create And Run an AWS DMS Migration Task
AWS DMS uses **Database Migration Task** to migrate the data from source to the target database. For this migraiton, you are going to create two Database Migration Tasks: one for migrating the existing data, and another for capturing data changes on the source database and replicating the changes to the target database. 

17.	Click on **Database migration tasks** on the left-hand menu, then click on the **Create task** button on the top right corner.

![\[OracleDms18\]](img/OracleDms18.png)

18.	Create a data migration task with the following values for migrating the **dms_sample** database.

| **Parameter** | **Value** |
| ------ | ------ |
| **Task identifier** | oracle-migration-task |
| **Replication instance** | oracle-replication |
| **Source database endpoint** | oracle-source |
| **Target database endpoint** | aurora-target |
| **Migration type** | Migrate existing data |
| **Start task on create** | Checked |
| **Target table preparation mode** | Do nothing |
| **Include LOB columns in replication** | Limited LOB mode |
| **Max LOB size (KB)** | 32 |
| **Enable validation** | Unchecked |
| **Enable CloudWatch logs** | Checked |

*Note: By enabling [Validation][dms-validation] you can ensure that your data was migrated accurately from the source to the target. If you enable validation for a task, AWS DMS begins comparing the source and target data immediately after a full load is performed for a table. Validaiton may add more time to the migraiton task. We did not enable validation to reduce the time it takes to complete this walkthrough.*

19.	Expand the **Table mappings** section, and select **Guided UI** for the editing mode. 

20.	Click on **Add new selection rule** button and enter the following values in the form:

| **Parameter** | **Value** |
| ------ | ------ |
| **Schema** | DMS_SAMPLE |
| **Table name** | % |
| **Action** | Include |

*NOTE: If the Create Task screen does not recognize any schemas, make sure to go back to endpoints screen and click on your endpoint. Scroll to the bottom of the page and click on **Refresh Button (⟳)**  in the **Schemas** section. 
If your schemas still do not show up on the Create Task screen, click on the Guided tab and manually select **DMS_SAMPLE** schema and all tables.*

21.	Next, expand the **Transformation rules** section, and click on **Add new transformation rule** using the following values:

| **Parameter** | **Value** |
| ------ | ------ |
| **Target** | Schema |
| **Schema Name** | DMS_SAMPLE |
| **Action** | Make lowercase |

| **Parameter** | **Value** |
| ------ | ------ |
| **Target** | Table |
| **Schema Name** | DMS_SAMPLE |
| **Table Name** | % |
| **Action** | Make lowercase |

| **Parameter** | **Value** |
| ------ | ------ |
| **Target** | Column |
| **Schema Name** | DMS_SAMPLE |
| **Table Name** | % |
| **Column Name** | % |
| **Action** | Make lowercase |

![\[OracleDms19\]](img/OracleDms19.png)

22.	After entering the values click on **Create task**. 

23.	At this point, the task should start running and replicating data from the **dms_sample** database running on EC2 to the Amazon Aurora RDS (MySQL) instance.

![\[OracleDms20\]](img/OracleDms20.png)

24.	As the rows are being transferred, you can monitor the task progress:	

- 1. Click on your task (oracle-migration-task) and scroll to the Table statistics section to view the table statistics to see how many rows have been moved.
- 2. If there is an error, the status color changes from green to reed. Click on View logs link for the logs to debug.	

## Inspect the Content of Target Database

25.	If you already disconnected from the EC2 Server, follow steps 1, 2, and 3 at the top of this toturial to connect (RDP) to your EC2 instance.

26.	Open **pgAdmin4** from within the EC2 server, and then connect to the Target Aurora RDS (PostgreSQL) database connection that you created earlier. 	

27.	Inspect the migrated data, by querying one of the tables in the target database. For example, the following query should return a table with two rows:

```sql
SELECT *
FROM dms_sample.sport_type;
```

![\[OracleDms21\]](img/OracleDms21.png)

Note that baseball, and football are the only two sports that are currently listed in this table. In the next section you will insert several new records to the source database with information about other sport types. DMS will automatically replicate these new records from the source database to the target database. 

28. Now, use the following script to enable the foreign key constraints that we dropped earlier:
	1. Open **AddConstraintsPostgreSQL.sql** inside the **DMS Workshop\Scripts** folder in Notepad. 
	2. Copy the content of the file to the **Query Editor** in **pgAdmin 4**.
	3. **Execute** the script.

## Capture Data Changes

29.	Create another **Data Migration Task** with the following values for capturing data changes to the source Oracle database, and replicating the changes to the target Aurora RDS instance.

| **Parameter** | **Value** |
| ------ | ------ |
| **Task identifier** | oracle-replication-task |
| **Replication instance** | oracle-replication |
| **Source database endpoint** | oracle-source |
| **Target database endpoint** | aurora-target |
| **Migration type** | Replicate data changes only |
| **Start task on create** | Checked |
| **CDC stop mode** | Don’t use custom CDC stop mode |
| **Target table preparation mode** | Do nothing |
| **Stop task after full load completes** | Don’t stop |
| **Include LOB columns in replication** | Limited LOB mode |
| **Max LOB size (KB)** | 32 |
| **Enable validation** | Unchecked |
| **Enable CloudWatch logs** | Checked |

30. Expand the **Table mappings** section, and select **Guided UI** for the editing mode.

31.	Add the same **Selection**, and **Transformation** rules as specified in steps 19 to 21.

![\[OracleDms22\]](img/OracleDms22.png)

32.	After entering the values click on **Create task**.

33.	At this point, the new migration task is ready to replicate ongoing data changes from the source Oracle RDS to the Amazon Aurora RDS (PostgreSQL) database.

![\[OracleDms23\]](img/OracleDms23.png)

## Replicating Data Changes from Source to the Target Database
Now you are going to simulate a transaction to the source database by updating the **sport_type** table. The Database Migration Service will automatically detect and replicate these changes to the target database. 

34.	Use **Oracle SQL Developer** connect to the source Oracle RDS instance (described in steps 4, and 5.)

35.	Open a **New Query** window and **execute** the following statement to insert 5 new sports into the **sport_type** table:

```sql
INSERT ALL

INTO dms_sample.sport_type (name,description) VALUES ('hockey', 'A sport in which two teams play against each other by trying to more a puck into the opponents goal using a hockey stick')

INTO dms_sample.sport_type (name,description) VALUES ('basketball', 'A sport in which two teams of five players each that oppose one another shoot a basketball through the defenders hoop')

INTO dms_sample.sport_type (name,description) VALUES ('soccer','A sport played with a spherical ball between two teams of eleven players')

INTO dms_sample.sport_type (name,description) VALUES ('volleyball','two teams of six players are separated by a net and each team tries to score by grounding a ball on the others court')

INTO dms_sample.sport_type (name,description) VALUES ('cricket','A bat-and-ball game between two teams of eleven players on a field with a wicket at each end')

SELECT * FROM dual; 

COMMIT;

SELECT * FROM dms_sample.sport_type; 
```

![\[OracleDms24\]](img/OracleDms24.png)

36.	Repeat steps 25 and 27 to inspect the content of **sport_type** table in the target database.

![\[OracleDms25\]](img/OracleDms25.png)

Notice the new records for: basketball, cricket, hockey, soccer, and volleyball that you added to the sports_type table in the source database have been replicated to your **dms_sample** database. You can further investigate the number of inserts, deletes, updates, and DDLs by viewing the **Table statistics** of your **Database migration tasks** in AWS console. 

The AWS DMS task keeps the target Aurora PostgreSQL database up to date with source database changes. AWS DMS keeps all the tables in the task up to date until it's time to implement the application migration. The latency is close to zero when the target has caught up to the source.

# Summary

In the first part of this tutorial we saw how easy it is to convert the database schema from an Oracle database into Amazon Aurora (PostgreSQL) using the AWS Schema Conversion Tool (AWS SCT). In the second part, we used the AWS Database Migration Service (AWS DMS) to migrate the data from our source to target database with no downtime. Similarly, we observed how DMS automatically replicates new transactions on the source to target database.

You can follow the same steps to migrate SQL Server and Oracle workloads to other RDS engines including PostgreSQL and MySQL.

[ec2-console]: <http://amzn.to/2atGc3r>
[dms-console]: https://console.aws.amazon.com/dms/
[env-config]: <https://github.com/awslabs/aws-database-migration-tools/blob/master/Blogs/AWS%20Database%20Migration%20Labs/EnvironmentConfiguration.md>
[aws-sct]: <https://aws.amazon.com/dms/schema-conversion-tool/?nc=sn&loc=2>
[aws-dms]: <https://aws.amazon.com/dms/>
[aurora]: <https://aws.amazon.com/rds/aurora/>
[ec2]: <https://aws.amazon.com/ec2/>
[vpc]: <https://aws.amazon.com/vpc/>
[download-sct]: <https://docs.aws.amazon.com/SchemaConversionTool/latest/userguide/CHAP_Installing.html>
[dms-validation]: <https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TaskSettings.DataValidation.html>
