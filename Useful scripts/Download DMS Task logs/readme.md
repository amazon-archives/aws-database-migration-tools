The Python code can be used to download the DMS logs based on the dms-task-id. 
 
We use a combination of methods from the DMS and the Cloudwatch API’s to download the logs.
 
Using the DMS API, we call the describe_replication_tasks method and pass the dms-taks-id to it to get the ReplicationInstanceArn. Then with the ReplicationInstanceArn we retrieve the ReplicationInstanceId by calling the DMS API describe_replication_instances method.
 
Once we have the ReplicationInstanceId we then we construct the log group name for the DMS logs.
 
Then we use the log group name and pass it as an argument to the Cloudwatch filter_log_events method to retrieve the logs for a date range.

You will need to install the boto3 and maya libraries as shown below:

pip install boto3

pip install maya


To run the Python code please use the command below:

python GetCWLogData.py <Your DMS Task ID> <Start Time Filter> <End Time Filter> > dmslogs.log

Example:

python GetCWLogData.py dmstaskmigration-abcdefghijklmnop 2019-01-20T00:00:00 2019-01-22T00:00:00 > dmslogs.log
 
