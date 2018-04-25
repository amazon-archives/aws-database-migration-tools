# Migrating BLOB/CLOB tables from Oracle to PostgreSQL using ora2pg and AWS Database Migration Service
# Overview
This repository contains the code and cloudformation templates that supports migrating Large objects from AWS RDS Oracle to AWS RDS PostgreSQL.

### Prerequisites
#### You will need the following.
```
• An oracle account to download the oracle client packages.
• An AWS account that provides access to AWS services.
• IAM user with access key and secret access key to configure AWS CLI.
• For testing purpose the below mentioned services needs to be created in us-east-1a availability zone in us-east-1 region.
```
#### Additionally:
```
• We will configure all services in the same VPC and in us-east-1 region to simplify networking considerations.
• The predefined database schema name and password in source RDS Oracle database are “awsorauser” and “awsorauser”.
• The predefined root username and password for source RDS Oracle database are “admin” and “admin123” respectively.
• While creating the RDS PostgreSQL database, use lower case letters for database name, master user name schema names. 
• IMPORTANT: The cloud formation templates that are demonstrated use hard-coded usernames and passwords and open security groups. These are just for testing purpose, not intended for production use with out any modifications.
```
### AWS Components that are used
#### Following AWS components are needed for successful testing of this migration.
| Number | Component | Purpose |
| --- | --- | --- |
| 1	| Amazon RDS Oracle instance | 	This is the source oracle database instance – will be restored from a provided snapshot. |
| 2	| Amazon RDS Postgresql instance | 	This is the target postgresql instance – Our source oracle database will be migrated to this RDS postgresql instance. |
| 3	| Amazon EC2 machine (m4.xlarge) | 	This EC2 machine is used to add new data into source oracle database while the initial migration is running from source RDS Oracle database to target Postgresql database. This machine uses oracle client version 12.2 as “sqlldr” comes with this version and is needed for adding new data into source RDS oracle database. |
| 4	| Amazon EC2 machine (m4.4xlarge) | 	This EC2 machine is used to move the data from RDS Oracle database to RDS postgresql database using ora2pg. We need to install 11.2 version of Oracle client on this machine instead of 12.2 version. Thus, we need two separate EC2 instances. |
| 5	| AWS DMS instance | 	This DMS instance is needed to enable ongoing replication from source RDS oracle database to target RDS postgresql database. |

### Implementation
#### For detailed steps check AWS Blog article "".
#### 1. Setting up VPC, Two Subnets, Security group, Source Oracle RDS Database from the snapshot, Target PostgreSQL RDS database and two EC2 instances for loading the test data and configuring ora2pg tool/software respectively. 
```
• Create a AWS cloud formation stack using the template url :  https://s3.amazonaws.com/aws-bigdata-blog/artifacts/awsora2pgblogfiles/cftemplates/SetupOra2pgRequiredResources.template
```
##### 2. Configure EC2 instance for loading test data into Amazon RDS Oracle database
```
• Configure 1st EC2 instance(CF stack output Key: EC2InstanceForSourceDataLoadingPublicDNS) with oracle 12.2 version client rpm files. Copy the client rpm files to /tmp direcotry.
• Configure AWS CLI on the 1st EC2 instance which was crated using the above cloudformation template.
• Login to the 1st EC2 instance and download the wrapper script using the below s3 command.
   •	cd; aws s3 cp s3://aws-bigdata-blog/artifacts/awsora2pgblogfiles/data-loading/scripts/setting_oracle_client_host.sh .
• Execute the script using the below command.
   •	cd; sh -x ./setting_oracle_client_host.sh <RDS_ORACLE_END_POINT> <EC2_INSTANCE_AVAILABILTY_ZONE> <DB_NAME>
   •	For eg: cd; sh -x ./setting_oracle_client_host.sh awsorains.xxxxxxxxxxxx.us-east-1.rds.amazonaws.com us-east-1a AWSORA
```
##### 3. Installing and Configuring Ora2pg tool
```
• Configure 2nd EC2 instance(CF stack output Key: EC2InstanceForOra2PgPublicDNS) with oracle 11.2 version client rpm files. Copy the client rpm files to /tmp direcotry.
• Configure AWS CLI on the 1st EC2 instance which was crated using the above cloudformation template.
• cd; aws s3 cp s3://aws-bigdata-blog/artifacts/awsora2pgblogfiles/data-loading/scripts/setting_ora2pg_host_step1.sh .
• cd; aws s3 cp s3://aws-bigdata-blog/artifacts/awsora2pgblogfiles/data-loading/scripts/setting_ora2pg_host_step2.sh .
• cd; chmod 755 setting_ora2pg_host_step1.sh
• ./setting_ora2pg_host_step1.sh <RDS_ORACLE_END_POINT> <ORA_DB_NAME>
• execute: ./setting_ora2pg_host_step1.sh awsorains.xxxxxxxxxxxx.us-east-1.rds.amazonaws.com AWSORA
• cpan
• cpan> look Test::More
• perl Makefile.PL
• sudo make
• sudo make install
• Once this command is complete, exit from the shell by running the “exit” command twice.
• cpan
• cpan> look DBD::Pg
• perl Makefile.PL
• sudo make
• sudo make install
• Once this command is complete, exit from the shell by running the “exit” command twice.
• cpan
• cpan> look DBD::Oracle
• perl Makefile.PL
• sudo make
• sudo make install
• Once this command is complete, exit from the shell by running the “exit” command twice.
• cd; chmod 755 setting_ora2pg_host_step2.sh
./setting_ora2pg_host_step2.sh awsorains.xxxxxx.us-east-1.rds.amazonaws.com AWSORA awspgins.xxxxxx.us-east-1.rds.amazonaws.com root Rootroot123 awspgdb miguser migpasswd awspgschema awspgctrlschema
```
#### 4.	Load new data into Source oracle database
```
• Login to 1st Oracle client EC2 instance. The key name of the ec2 instance from the above 1st cloud formation template is : EC2InstanceForSourceDataLoadingPublicDNS
• cd; date; nohup time sh -x /home/ec2-user/data-loading/scripts/load_tables.sh customer /home/ec2-user/data-loading/input-files/customer/customer.tbl.1.100rows awsorauser awsorauser AWSORA > load_tables_customer_tbl.100rows.log &
```
#### 5. Create DMS Source and Target endpoints and DMS instance
```
• Create a AWS cloud formation stack using the template url : https://s3.amazonaws.com/aws-bigdata-blog/artifacts/awsora2pgblogfiles/cftemplates/SetupDMSEndPointsAndInstance.template
```
#### 6. Create a DMS tasks with CDC to enable replication from source RDS Oracle database to target RDS PostgreSQL database
```
• Make sure “setting_ora2pg_host_step2.sh” script is completed before proceeding with this step. 
• Create a AWS cloud formation stack using the template url : https://s3.amazonaws.com/aws-bigdata-blog/artifacts/awsora2pgblogfiles/cftemplates/SetupDMSTasks.template
```
#### 7.	Cleanup
```
 After completing and testing this solution, clean up the resources by deleting the cloudformation stacks. Before deleting the stacks, go to DMS console and navigate to Tasks page and stop the tasks manually one after another. After this go to cloudformation web ui and delete the stacks in reverse order of their creation. Next delete the EBS volume which was created as part of this blog post. Go to EC2 web console, click on “Volumes” under “Elastic Block Store” section and select EBS volume which has the name “oracle-client-for-rds-oracle-restored-volume1” and click on “Delete Volume” option under Actions.
```
#### 8.	Conclusion
```
This post gives an overview of migrating the RDS oracle database to RDS PostgreSQL using open source ora2pg and Amazon DMS service. The same procedure can be used to migrate your on-premise Oracle database to Amazon RDS PostgreSQL database or Amazon Aurora PostgreSQL database as well. We can migrate the initial data load using various methods and migrate the remaining data using “Custom CDC start time” option available in Amazon DMS service and can enable the ongoing replication until the cutover is complete.  
```
