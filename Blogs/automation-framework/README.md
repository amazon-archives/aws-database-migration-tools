This code allows you to create an automated framework to migrate relational databases.

Steps:
1. Make sure you have a source or create source Oracle database in RDS as per the command:
aws rds create-db-instance --db-instance-identifier sourcedb06 --engine oracle-ee --engine-version 12.1.0.2.v16 --storage-type gp2 --allocated-storage 100 --db-instance-class db.t2.large --master-username master --master-user-password Passw0rd --vpc-security-group-ids sg-3bbe8340
2. If you created a brand new source you can populate source based on https://github.com/aws-samples/aws-database-migration-samples/tree/master/oracle/sampledb/v1 . Your local client must have sqlplus installed.
  - git clone git clone https://github.com/aws-samples/aws-database-migration-samples.git
  - cd aws-database-migration-samples/oracle/sampledb/v1
  - echo "exit;" >> install-rds.sql
  - sqlplus $DB_USER/$DB_PASSWORD@$DB_HOST/$DB_NAME @install-rds.sql
  - wget https://raw.githubusercontent.com/nagmesh/aws-database-migration-samples/master/oracle/sampledb/v1/schema/fix.sql
  - sqlplus $DB_USER/$DB_PASSWORD@$DB_HOST/$DB_NAME @fix.sql
3. Create target Aurora Postgres RDS as per the command:
aws rds create-db-cluster --db-cluster-identifier targetdb06 --engine aurora-postgresql --engine-version 10.7 --master-username master --master-user-password Passw0rd --vpc-security-group-ids sg-3bbe8340
aws rds create-db-instance --db-instance-identifier targetdb06 --db-cluster-identifier targetdb06 --db-instance-class db.t3.medium --engine aurora-postgresql --engine-version 10.7
4. Make sure you have a replication instance or create a DMS replication instance using the command below:
aws dms create-replication-instance --replication-instance-identifier sample-inst-01 --vpc-security-group-ids sg-3bbe8340 --replication-instance-class dms.t2.medium
5. Create the DMS endpoint for source and target
aws dms create-endpoint --endpoint-identifier sourcedb06 --endpoint-type source --engine-name oracle --username master --password Passw0rd --port 1521 --server-name sourcedb06.cmbi8axdpp1y.us-west-2.rds.amazonaws.com --database-name ORCL
aws dms create-endpoint --endpoint-identifier targetdb06 --endpoint-type target --engine-name aurora-postgresql --username master --password Passw0rd --port 5432 --server-name targetdb06.cmbi8axdpp1y.us-west-2.rds.amazonaws.com --database-name postgres

6. Test the source database connection to replication instance:
aws dms test-connection --endpoint-arn $(aws dms describe-endpoints --filters Name=endpoint-id,Values=sourcedb06 --query 'Endpoints[0].EndpointArn' --output text) --replication-instance-arn $(aws dms describe-replication-instances --filters Name=replication-instance-id,Values=sample-inst-01 --query 'ReplicationInstances[0].ReplicationInstanceArn' --output text)
aws dms wait test-connection-succeeds --filters Name=endpoint-arn,Values=$(aws dms describe-endpoints --filters Name=endpoint-id,Values=sourcedb06 --query 'Endpoints[0].EndpointArn' --output text),Name=replication-instance-arn,Values=$(aws dms describe-replication-instances --filters Name=replication-instance-id,Values=sample-inst-01 --query 'ReplicationInstances[0].ReplicationInstanceArn' --output text)

aws dms test-connection --endpoint-arn $(aws dms describe-endpoints --filters Name=endpoint-id,Values=targetdb06 --query 'Endpoints[0].EndpointArn' --output text) --replication-instance-arn $(aws dms describe-replication-instances --filters Name=replication-instance-id,Values=sample-inst-01 --query 'ReplicationInstances[0].ReplicationInstanceArn' --output text)
aws dms wait test-connection-succeeds --filters Name=endpoint-arn,Values=$(aws dms describe-endpoints --filters Name=endpoint-id,Values=targetdb06 --query 'Endpoints[0].EndpointArn' --output text),Name=replication-instance-arn,Values=$(aws dms describe-replication-instances --filters Name=replication-instance-id,Values=sample-inst-01 --query 'ReplicationInstances[0].ReplicationInstanceArn' --output text)

7. Verify that the output of the commands below are successful
aws dms describe-connections --filters Name=endpoint-arn,Values=$(aws dms describe-endpoints --filters Name=endpoint-id,Values=sourcedb06 --query 'Endpoints[0].EndpointArn' --output text),Name=replication-instance-arn,Values=$(aws dms describe-replication-instances --filters Name=replication-instance-id,Values=sample-inst-01 --query 'ReplicationInstances[0].ReplicationInstanceArn' --output text) --query 'Connections[0].Status' --output text
aws dms describe-connections --filters Name=endpoint-arn,Values=$(aws dms describe-endpoints --filters Name=endpoint-id,Values=targetdb06 --query 'Endpoints[0].EndpointArn' --output text),Name=replication-instance-arn,Values=$(aws dms describe-replication-instances --filters Name=replication-instance-id,Values=sample-inst-01 --query 'ReplicationInstances[0].ReplicationInstanceArn' --output text) --query 'Connections[0].Status' --output text

8. Upload the S3Files/test.zip to an S3 bucket
9. Launch the template at CloudFormationTemplate/automation-migration.yml


$DB_USER/$DB_PASSWORD@$DB_HOST/$DB_NAME
