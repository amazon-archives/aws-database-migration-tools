# Step-by-Step Guide for Microsoft SQL Server Migration to Amazon Aurora (MySQL)

This step-by-step guide demonstrates how you can use [AWS Database Migration Service (DMS)][aws-dms] and [AWS Schema Conversion Tool (AWS SCT)][aws-sct] to migrate data from Microsoft SQL Server to [Amazon Aurora (MySQL)][aurora]. Additionally, you will use AWS DMS to continually replicate database changes from the source database to the target database.

# Connecting to your Environment 

Before proceeding further, make sure you have completed the instructions in the [Environment Configuration][env-config] step to deploy the resources we will be using for this database migration in your own account. These resources include:

- A Microsoft SQL Server running on an [Amazon Elastic Compute Cloud (Amazon EC2)][ec2] instance as the source database. This server is also used run the AWS Schema Conversion Tool (AWS SCT), Microsoft SQL Server Management Studio, and MySQL Workbench.
- An AWS RDS Aurora (MySQL) instance used as the target database.


Once you have completed the instructions in the [Environment Configuration][env-config] step, take special note of the following output values: 

- SourceEC2PublicDNS
- TargetAuroraMySQLEndpoint
- The path to your private key (DMSKeyPair.pem)

# Part 1: Converting Database Schema Using the AWS Schema Conversion Tool (AWS SCT)

The AWS Schema Conversion Tool is a [downloadable][download-sct] application that enables you to convert your existing database schema from one database engine to another. You can convert relational OLTP schemas, data warehouse OLAP schemas, and document-based NoSQL database schemas. AWS SCT specifically eases the transition from one database engine to another.

The following steps provide instructions for converting a Microsoft SQL Server database to an Amazon Aurora (MySQL) database. In this exercise, you perform the following tasks:
- [Log into the Source EC2 Instance Running SQL Server](#log-into-the-source-sql-server-running-on-an-ec2-instance)
- [Install the Schema Conversion Tool on the Server](#install-the-schema-conversion-tool-on-the-server)
- [Create a Database Migration Project in the SCT](#create-a-database-migration-project)
- [Convert the schema using the SCT](#convert-the-schema)
- [Modify Procedural Code to Adapt It For the New Database Dialect](#modify-procedural-code-to-adapt-it-for-the-new-database-dialect)

## Log into the Source EC2 Instance Running SQL Server
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
    
## Install the Schema Conversion Tool on the Server
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

*Note: AWS SCT uses JDBC driver to connect to the source and target database. To download the Microsoft SQL Server and MySQL JDBC drivers on the EC2 instance, go to https://msdn.microsoft.com/en-us/sqlserver/aa937724.aspx & https://dev.mysql.com/downloads/connector/j/ respectively.*

8. Within the Schema Conversion Tool, enter the following values into the form and then click **Next**.

| **Parameter** | **Value** |
| ------ | ------ |
| **Project Name** | AWS Schema Conversion Tool SQL Server to Aurora MySQL |
| **Location** | C:\Users\Administrator\AWS Schema Conversion Tool\Projects |
| **Database Type** | Transactional Database (OLTP) |
| **Source Database Engine** | Microsoft SQL Server / I want to switch engines and optimize for the cloud |

![\[SqlSct05\]](img/SqlSct05.png)

9. Specify the source database configurations in the form, and click **Test Connection**. Once the connection is successfully tested, click **Next**.

| **Parameter** | **Value** |
| ------ | ------ |
| **Project Name** | localhost |
| **Server Port** | 1433 |
| **Instance Name** |  |
| **Authentication** | SQL Server Authentication |
| **User Name** | awssct |
| **Password** | Password1 |
| **Use SSL** | Unchecked |
| **Store Password** | Checked |
| **Microsoft SQL Server Driver Path** | **Path to SQL Server JDBC driver on the EC2 instance that you downloaded from https://msdn.microsoft.com/en-us/sqlserver/aa937724.aspx** |

![\[SqlSct06\]](img/SqlSct06.png)

*Note that after hitting **Next** and loading metadata, you may get a warning message saying: **Metadata loading was intrupted because of data fetching issues.** You can ignore this message as it doesn't affect our sample migraiton.*

10.	Select the **dms_sample** database, then click **Next**.

![\[SqlSct07\]](img/SqlSct07.png)

11.	Review the **Database Migration Assessment Report**.

![\[SqlSct08\]](img/SqlSct08.png)


SCT will examine in detail all of the objects in the schema of source database. It will convert as much as possible automatically and provides detailed information about items it could not convert. 

![\[SqlSct09\]](img/SqlSct09.png)

Generally, packages, procedures, and functions are more likely to have some issues to resolve because they contain the most custom or proprietary SQL code. AWS SCT specifies how much manual change is needed to convert each object type. It also provides hints about how to adapt these objects to the target schema successfully.

12.	After you are done reviewing the database migration assessment report, click **Next**.

13.	Specify the target database configurations in the form, and then click **Test Connection**. Once the connection is successfully tested, click **Finish**.

| **Parameter** | **Value** |
| ------ | ------ |
| **Target Database Engine** | Amazon Aurora (MySQL compatible) |
| **Server Name** | **\< TargetAuroraMySQLEndpoint \>** |
| **Server Port** | 3306 |
| **User Name** | awssct |
| **Password** | Password1 |
| **Use SSL** | Unchecked |
| **Store Password** | Checked |
| **MySQL Driver Path** | **Path to MySQL JDBC driver on the EC2 instance that you downloaded from https://dev.mysql.com/downloads/connector/j/** |

![\[SqlSct10\]](img/SqlSct10.png)

## Convert the Schema Using the SCT
Now that you have created a new Database Migration Project, the next step is to convert the SQL Server schema of the source database to the Amazon Aurora. 

14.	Click on the **View** button, and choose **Assessment Report view**. 

![\[SqlSct11\]](img/SqlSct11.png)

15.	Next, navigate to the **Action Items** tab in the report to see the items that the tool could not convert, and find out how much manual changes you need to make. 

![\[SqlSct12\]](img/SqlSct12.png)

Items with a red exclamation mark next to them cannot be directly translated from the source to the target. In this case, this includes the stored procedures.  For each conversion issue, you can complete one of the following actions:

  1. Modify the objects on the source SQL Server database so that AWS SCT can convert the objects to the target Aurora MySQL database.
  2. Instead of modifying the source schema, modify scripts that AWS SCT generates before applying the scripts on the target Aurora MySQL database.	

For the sake of time, we skip modifying all the objects that could not be automatically converted. Instead, as an example, you will manually modify one of the stored procedures from within SCT to make it compatible with the target database.

## Modify Procedural Code to Adapt It For the New Database Dialect

16.	From the left panel, **uncheck** the items with the exclamation mark except for the **generateTransferActivity** procedure.

![\[SqlSct13\]](img/SqlSct13.png)

17.	Next, click on the **generateTransferActivity** procedure. Observe how the SCT highlights the issue, stating that MySQL does not support the PRINT procedure. To fix this, you simply need to replace the three highlighted PRINT statements with SELECT statement as demonstrated in the following example:

MS SQL Server syntax:
```sql
PRINT (concat('max t: ',@max_tik_id,' min t: ', @min_tik_id, 'max p: ',@max_p_id,' min p: ', @min_p_id));
```

MySQL syntax:
```sql
select concat('max t: ',@max_tik_id,' min t: ', @min_tik_id, 'max p: ',@max_p_id,' min p: ', @min_p_id); 
```

18.	After you make the modification, right-click on the **dbo** schema, and choose **Create Report**. Observe that the schema of the source database is now fully compatible with the target database. 

![\[SqlSct14\]](img/SqlSct14.png)

19.	Right click on the **dms_sample** database in the left panel and select **Convert Schema** to generate the data definition language (DDL) statements for the target database.  

![\[SqlSct15\]](img/SqlSct15.png)

20.	When warned that objects may already exist in database, click **Yes**. 

![\[SqlSct16\]](img/SqlSct16.png)

*NOTE: You may be presented with a different message stating “The operation will be partially performed” and only 3 of the 8 objects will be converted. Click **OK**.*

21.	Right click on the **dms_sample_dbo schema** in the right-hand panel, and click **Apply to database**.

![\[SqlSct17\]](img/SqlSct17.png)

22.	When prompted if you want to apply the schema to the database, click **Yes**.

![\[SqlSct18\]](img/SqlSct18.png)

23.	At this point, the schema has been applied to the target database. Expand the **dms_sample_dbo** schema to see the tables.

![\[SqlSct19\]](img/SqlSct19.png)

You have sucessfully converted the database schema and object from Microsoft SQL Server to the format compatible with Amazon Aurora (MySQL). 

This part demonstrated how easy it is to migrate the schema of a Microsoft SQL Server database into Amazon Aurora (MySQL) using the AWS Schema Conversion Tool.  Similarly, you learned how the Schema Conversion Tool highlights the differences between different database engine dialects, and provides you with tips on how you can successfully modify the code when needed to migrate procedure and other database objects.

The same steps can be followed to migrate SQL Server and Oracle workloads to other RDS engines including PostgreSQL and MySQL.

The next section describes the steps required to move the actual data using AWS DMS.


# Part 2: Migrating the Data Using the AWS Database Migration Service (AWS DMS)

AWS Database Migration Service (DMS) helps you migrate databases to AWS easily and securely. The source database remains fully operational during the migration, minimizing downtime to applications that rely on the database. AWS DMS can migrate your data to and from most widely used commercial and open-source databases. The service supports homogenous migrations such as SQL Server to SQL Server, as well as heterogeneous migrations between different database platforms, such as SQL Server to Amazon Aurora MySQL or Oracle to Amazon Aurora PostgreSQL. AWS DMS can also be used for continuous data replication with high-availability.

AWS DMS doesn't migrate your secondary indexes, sequences, default values, stored procedures, triggers, synonyms, views, and other schema objects that aren't specifically related to data migration. To migrate these objects to your Aurora MySQL target, we used the AWS Schema Conversion Tool (AWS SCT) in Part 1 of this guide. 

*Please note that you need to complete the steps described in the AWS Schema Conversion Tool (SCT) section as a pre-requisite for this part.* 

The following steps provide instructions to migrate existing data from the source Microsoft SQL Server database to an Amazon Aurora MySQL database. In this exercise you perform the following tasks:
- [Connect to the EC2 Instance Running the Source SQL Server](#connect-to-the-ec2-instance-running-the-source-sql-server)
- [Configure the Source SQL Server Database for Replication](#configure-the-source-sql-server-database-for-replication)
- [Configure the Target Aurora RDS database for Replication](#configure-the-target-aurora-rds-database-for-replication)
- [Create an AWS DMS Replication Instance](#create-an-aws-dms-replication-instance)
- [Create AWS DMS Source and Target Endpoints](#create-aws-dms-source-and-target-endpoints)
- [Create And Run an AWS DMS Migration Task](#create-and-run-an-aws-dms-migration-task)
- [Replicating Data Changes from Source to the Target Database](#replicating-data-changes-from-source-to-the-target-database)


## Connect to the EC2 Instance Running the Source SQL Server

If you disconnected from the Source EC2 instance, follow the steps 1 to 3 in Part 1 to RDP to the instance. 

1. Once connected, open **SQL Server Management Studio** from the **Start Menu**.

![\[SqlDms01\]](img/SqlDms01.png)

2. Use the following values to connect to your source database.

| **Parameter** | **Value** |
| ------ | ------ |
| **Server Type** | Database Engine |
| **Server Name** | localhost |
| **Authorization** | Windows Authentication |

![\[SqlDms02\]](img/SqlDms02.png)

## Configure the Source SQL Server Database for Replication

When migrating your Microsoft SQL Server database using AWS DMS, you can choose to migrate existing data only, migrate existing data and replicate ongoing changes, or migrate existing data and use change data capture (CDC) to replicate ongoing changes. 

Migrating only the existing data does not require any configuration on the source SQL Server database. However, to migrate existing data and replicate ongoing changes, you need to either enable **MS-REPLICATION**, or **MS-CDC**. 

3.	In this step you are going to execute a .sql script that will configure the source database for replication

      1. From within **SQL Server Management Studio**, click on **File** menu. Next, select **Open**, and then click on **File**.
      2. Navigate to **C:\Users\Administrator\Desktop\DMS Workshop\Scripts** 
      3. Open **ConfigureSource.sql** 
      4. **Execute** the script.
      
![\[SqlDms03\]](img/SqlDms03.png)

*NOTE: Replication requires a primary key for all tables that are being replicated. If your tables don’t have primary keys defined, consider using MS-CDC instead.*

## Configure the Target Aurora RDS database for Replication

During the full load process, AWS DMS as default does not load tables in any particular order, so it might load child table data before parent table data. As a result, foreign key constraints might be violated if they are enabled. Also, if triggers are present on the target database, they might change data loaded by AWS DMS in unexpected ways.

4. Open **MySQL Workbench 8.0 CE** from within the EC2 server, and create a new database connection for the target Aurora database using the following values:

| **Parameter** | **Value** |
| ------ | ------ |
| **Connection Name** | Target Aurora RDS (MySQL) |
| **Host Name** | **\<TargetAuroraMySQLEndpoint\>** |
| **Port** | 3306 |
| **Username** | awssct |
| **Password** | Password1 |

![\[SqlDms04\]](img/SqlDms04.png)

5. After you receive a message stating **“Successfully made the MySQL connection”**, click **OK**.

6. Click on the **Target Aurora RDS (MySQL)** from the list of MySQL Connections in SQL Workbench to connect to the target database. 

![\[SqlDms05\]](img/SqlDms05.png)

7.	In this step you are going to drop the foreign key constraint from the target database:

    1. Within **MySQL Workbench**, click on the **File** menu, and choose **Open SQL Script**. 
    2. Open **DropConstraintsSQLServer.sql** from **\Desktop\DMS Workshop\Scripts**. 
    3. **Execute** the script.

![\[SqlDms06\]](img/SqlDms06.png)

## Create an AWS DMS Replication Instance

The following illustration shows a high-level view of the migration process.

![\[SqlDms07\]](img/SqlDms07.png)

An AWS DMS replication instance performs the actual data migration between source and target. The replication instance also caches the transaction logs during the migration. The amount of CPU and memory capacity of a replication instance influences the overall time that is required for the migration.

8.	Navigate to the Database Migration Service (DMS) [console][dms-console].

9.	On the left-hand menu click on **Replication Instances**. This will launch the Replication instance screen.

10.	Click on the **Create replication instance** button on the top right side.

![\[SqlDms08\]](img/SqlDms08.png)

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

![\[SqlDms09\]](img/SqlDms09.png)

*NOTE: Creating replication instance will take several minutes. While waiting for the replication instance to be created, you can specify the source and target database endpoints in the next steps. However, test connectivity only after the replication instance has been created, because the replication instance is used in the connection.*

## Create AWS DMS Source and Target Endpoints
Now that you have a replication instance, you need to create source and target endpoints for the sample database. 

12.	Click on the **Endpoints** link on the left, and then click on **Create endpoint** on the top right corner. 

![\[SqlDms10\]](img/SqlDms10.png)

13.	Enter the following information to create an endpoint for the source **dms_sample** database:

| **Parameter** | **Value** |
| ------ | ------ |
| **Endpoint Type** | Source endpoint |
| **Endpoint Identifier** | sqlserver-source |
| **Source Engine** | sqlserver |
| **Server Name** | **\< SourceEC2PrivateDns \>** |
| **Port** | 1433 |
| **SSL Mode** | none |
| **User Name** | awssct |
| **Password** | Password1 | 
| **Database Name** | dms_sample |
| **Test endpoint connection -> VPC** | **\< VPC ID from Environment Setup Step \>** |
| **Replication Instance** | DMSReplication |

![\[SqlDms11\]](img/SqlDms11.png)

14.	Once the information has been entered, click **Run Test**. When the status turns to **successful**, click **Create endpoint**.

15.	Follow the same steps to create another endpoint for the **Target Aurora RDS Database (dms_sample_dbo)** using the following values:

| **Parameter** | **Value** |
| ------ | ------ |
| **Endpoint Type** | Target endpoint |
| **Select RDS DB instance** | **\<StackName\>-AuroraMySQLInstance** |
| **Endpoint Identifier** | aurora-target |
| **Source Engine** | aurora |
| **Server Name** | **\< TargetAuroraMySQLEndpoint  \>** |
| **Port** | 3306 |
| **SSL Mode** | none |
| **User Name** | awssct |
| **Password** | Password1 | 
| **Database Name** | dms_sample |
| **Test endpoint connection -> VPC** | **\< VPC ID from Environment Setup Step \>** |
| **Replication Instance** | DMSReplication |

![\[SqlDms12\]](img/SqlDms12.png)

16.	Once the information has been entered, click **Run Test**. When the status turns to **successful**, click **Create endpoint**.

## Create And Run an AWS DMS Migration Task
AWS DMS uses **Database Migration Task** to migrate the data from source to the target database. 

17.	Click on **Database migration tasks** on the left-hand menu, then click on the **Create task** button on the top right corner.

![\[SqlDms13\]](img/SqlDms13.png)

18.	Create a data migration task with the following values for migrating the **dms_sample** database.

| **Parameter** | **Value** |
| ------ | ------ |
| **Task identifier** | AuroraMigrationTask |
| **Replication instance** | DMSReplication |
| **Source database endpoint** | sqlserver-source |
| **Target database endpoint** | aurora-target |
| **Migration type** | Migrate existing data and replicate ongoing changes |
| **Start task on create** | Checked |
| **CDC stop mode** | Don’t use custom CDC stop mode |
| **Target table preparation mode** | Do nothing |
| **Stop task after full load completes** | Don’t stop |
| **Include LOB columns in replication** | Limited LOB mode |
| **Max LOB size (KB)** | 32 |
| **Enable validation** | Unchecked |
| **Enable CloudWatch logs** | Checked |

*Note: By enabling [Validation][dms-validation] you can ensure that your data was migrated accurately from the source to the target. If you enable validation for a task, AWS DMS begins comparing the source and target data immediately after a full load is performed for a table. Validaiton may add more time to the migraiton task. We did not enable validation to reduce the time it takes to complete this walkthrough.*

19.	Expand the **Table mappings** section, and select **Guided UI** for the editing mode. 

20.	Click on **Add new selection rule** button and enter the following values in the form:

| **Parameter** | **Value** |
| ------ | ------ |
| **Schema** | dbo |
| **Table name** | % |
| **Action** | Include |

*NOTE: If the Create Task screen does not recognize any schemas, make sure to go back to endpoints screen and click on your endpoint. Scroll to the bottom of the page and click on **Refresh Button (⟳)**  in the **Schemas** section. 
If your schemas still do not show up on the Create Task screen, click on the Guided tab and manually select ‘dbo’ schema and all tables.*

21.	Next, expand the **Transformation rules** section, and click on **Add new transformation rule** using the following values:

| **Parameter** | **Value** |
| ------ | ------ |
| **Target** | Schema |
| **Schema Name** | dbo |
| **Action** | Rename to: dms_sample_dbo |

![\[SqlDms14\]](img/SqlDms14.png)

*Note: Alternatively, instead of performing steps 19 to 21, you can simply select **JSON editor** in the **Table mappings** and then paste the following code. Either approach yields the same result.*

```json
{
    "rules": [
        {
            "rule-type": "transformation",
            "rule-id": "1",
            "rule-name": "1",
            "rule-target": "schema",
            "object-locator": {
                "schema-name": "dbo",
                "table-name": "%"
            },
            "rule-action": "rename",
            "value": "dms_sample_dbo",
            "old-value": null
        },
        {
            "rule-type": "selection",
            "rule-id": "2",
            "rule-name": "2",
            "object-locator": {
                "schema-name": "dbo",
                "table-name": "%"
            },
            "rule-action": "include",
            "filters": []
        }
    ]
}
```

22.	After entering the values click on **Create task**. 

23.	At this point, the task should start running and replicating data from the **dms_sample** database running on EC2 to the Amazon Aurora RDS (MySQL) instance.

![\[SqlDms15\]](img/SqlDms15.png)

24.	As the rows are being transferred, you can monitor the task progress:
    1. Click on your task **(auroramigrationtask)** and scroll to the **Table statistics** section to view the table statistics to see how many rows have been moved.
    2. If there is an error, the status color changes from green to red. Click on **View logs** link for the logs to debug.

## Inspect the Content of Target Database

25.	If you already disconnected from the EC2 SQL Server source database server, follow steps 1, 2, and 3 in Part 1 to connect (RDP) to your EC2 instance.

26.	Open **MySQL Workbench 8.0 CE** from within the EC2 server, and click on Target Aurora RDS (MySQL) database connection that you created earlier. 	

27.	Inspect the migrated data, by querying one of the tables in the target database. For example, the following query should return a table with two rows:

```sql
SELECT *
FROM dms_sample_dbo.sport_type;
```
![\[SqlDms16\]](img/SqlDms16.png)

Note that baseball, and football are the only two sports that are currently listed in this table. In the next section you will insert several new records to the source database with information about other sport types. DMS will automatically replicate these new records from the source database to the target database.

28.	Now, use the following script to enable the foreign key constraints that we dropped earlier:

    1. Within **MySQL Workbench**, click on the **File** menu, and choose **Open SQL Script**. 
    2. Open **AddConstraintsSQLServer.sql** from **\Desktop\DMS Workshop\Scripts**. 
    3. **Execute** the script.

## Replicating Data Changes from Source to the Target Database

Now you are going to simulate a transaction to the source database by updating the **sport_type** table. The Database Migration Service will automatically detect and replicate these changes to the target database. 

29.	Use Microsoft SQL Server Management Studio to connect to the **Source SQL Server** on the EC2 instance (described in steps 1, and 2 in Part 2.)

30.	Open a **New Query** window and **execute** the following statement to insert 5 new sports into the **sport_type** table:

```sql
use dms_sample
BULK INSERT dbo.sport_type
FROM 'C:\Users\Administrator\Desktop\DMS Workshop\Scripts\sports.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
```

31.	Repeat steps 25 and 27 to inspect the content of **sport_type** table in the target database.

![\[SqlDms17\]](img/SqlDms17.png)

Notice the new records for: basketball, cricket, hockey, soccer, volleyball that you added to the **sports_type** table in the source database have been replicated to your **dms_sample_dbo** database. You can further investigate the number of inserts, deletes, updates, and DDLs by viewing the **Table statistics** of your **Database migration tasks** in AWS console. 

The AWS DMS task keeps the target Aurora MySQL database up to date with source database changes. AWS DMS keeps all the tables in the task up to date until it's time to implement the application migration. The latency is close to zero, when the target has caught up to the source

## Summary

In the first part of this tutorial we saw how easy it is to convert the database schema from a Microsoft SQL Server database into Amazon Aurora (MySQL) using the AWS Schema Conversion Tool (AWS SCT). In the second part, we used the AWS Database Migration Service (AWS DMS) to migrate the data from our source to target database with no downtime.  Similarly, we observed how DMS automatically replicates new transactions on the source to target database.

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
