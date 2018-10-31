# Oracle Database Zero Downtime Migration with AWS DMS and Accelario

# Overview
This template includes a sample configuration:
* A source Oracle database running on RDS.
* A destination Oracle database running RDS.
* An Accelario server directly deployed from AWS Marketplace.

# Installation
1. Download the rds1.template file
2. Goto CloudFormation console and press “Create Stack” button.
3. Use the second option “Upload a template to Amazon S3” and choose the downloaded file. 
4. Click “Next” and you will get a parameters screen. Fill all the fields – VPC, Key Pair, Master RDS username and password. 
5. Click “Next” and you will get to Options screen. Do not change anything here, click “Next” and you will get to Review screen. 
6. Review the details and if everything is correct press “Create” button. 
7. All the components will be created.
8. After the creation you can find the Accelario link in the Outputs tab. Use the link to connect to newly created Accelario server, use the AccelarioUser and AccelarioPassword as credentials to login.

# Uninstall
1. Delete the Accelario server - use EC2 console
2. Delete the source and destination RDS databases - use RDS console

**Note:** All the resources are billable. Please review the pricing for details.