# databasemigration-etl-blog
Resources for AWS Database Migration Service and AWS Glue Blog by Sona Rajamani.

This repo includes two CloudFormation templates that can be deployed in US-East-2 (Ohio) or US-West-2 (Oregon) region. It also includes a PySpark script, which performs the ETL action in AWS Glue job. 

Details about the files in this repo:

##  migrationresource.template ## 
 This template deploys a stack consisting of:
 1. VPC
 1. IGW - Internet Gateway
 1. IAM Role for migration
 1. 2 Public Subnets in two different AZ within a region - [PublicSubnet1, PublicSubnet2] 
 1. Route tables
 1. VPC S3 Endpoint	   
 1. Security Group for EC2 instance
 1. Elatic IP for EC2 instance
 1. EC2 instance from an AMI preconfigured with Oracle XE and HRDATA database.
 1. IAM instance profile
 1. S3 Bucket 
 1. DB Subnet Group
 1. RDS Aurora MySQL Cluster
 1. RDS Aurora MySQL DB Instance
 1. Replication Subnet Group
 1. Replication Instance

Design:

![GitHub Logo](/images/migrationresourcesTemplate.png)


## glueblog.template
 This template deploys a stack consisting of resources in AWA Glue.  The resources are created based on the output of migrationresource stack.  
 1. AWS Glue RDS Amazon Aurora MySQL JDBC connection
 1. AWS Glue database named hrdb
 1. AWS Glue crawler 
 1. AWS Glue ETL Job - The job uses PySpark [blogetl.py] script stored in a s3 bucket for ETL in the job.

Design:

![GitHub Logo](/images/glueblogTemplate.png)

## oracle-aurora-postgresql-deployment.template
This template deploys a stack consisting of:
 1. VPC
 1. IGW - Internet Gateway
 1. IAM Role for migration
 1. 2 Public Subnets in two different AZ within a region - [PublicSubnet1, PublicSubnet2]
 1. Route tables
 1. VPC S3 Endpoint
 1. Security Group for EC2 instance
 1. Elatic IP for EC2 instance
 1. EC2 instance from an AMI preconfigured with Oracle XE and HRDATA database.
 1. IAM instance profile
 1. S3 Bucket
 1. DB Subnet Group
 1. RDS Aurora PostgreSQL Cluster
 1. RDS Aurora PostgreSQL DB Instance
 1. Replication Subnet Group
 1. Replication Instance

Design:
![GitHub Logo](/images/oracle-aurora-postgresql-deployment-designer.png)

## blogetl.py
 Script that does an inner join of EMPLOYEES and DEPARTMENTS tables in HRDATA database and writes the results of the join a new table called EMPLOYEES_DEPARTMENTS in RDS Amazon Aurora MySQL database.	   
