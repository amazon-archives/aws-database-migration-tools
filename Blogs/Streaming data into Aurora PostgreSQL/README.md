# DMS Blog

This the companion scripts and Cloudformation template for the Blog to move data from S3 to a PostgreSQL database.

## Getting Started

The attached Cloudformation script will stand up an environment that will have the following components

1. S3 Bucket - Source of Data
2. Kinesis Firehose
3. RDS Aurora PostgreSQL - Target database
4. DMS Endpoints and Replication Instance

Once the Cloudformation script has started you can go to Kinesis Firehose console and start the Sample data stream.
