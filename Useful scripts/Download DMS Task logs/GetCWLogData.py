#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
 
import boto3
import sys
import maya


# Parameters are read for replication task id, start time and end time ranges for the logs
replication_task_id = sys.argv[1]
time_string = sys.argv[2]
end_time_string = sys.argv[3]

# Convert the start time to millisecond since epoch
def start_time_milliseconds_since_epoch(time_string):
    datetime = maya.when(time_string)
    seconds = datetime.epoch
    return seconds * 1000

start_time = start_time_milliseconds_since_epoch(time_string)

# Convert the end time to millisecond since epoch
def end_time_milliseconds_since_epoch(end_time_string):
    datetime = maya.when(end_time_string)
    seconds = datetime.epoch
    return seconds * 1000

end_time = end_time_milliseconds_since_epoch(end_time_string)

# Get the replication tasks based on the replication task id
def get_replication_tasks():

    client = boto3.client('dms')

    response = client.describe_replication_tasks(Filters=[
        {
            'Name': 'replication-task-id',
            'Values': [
                replication_task_id,
            ]
        },
    ],
    MaxRecords=100,
    Marker='')

    return response['ReplicationTasks']

# Get replication instance arn from the replicationtasks 
def get_replication_instance_arn():
    for ReplicationTasks in get_replication_tasks():
        ReplicationInstanceArn = ReplicationTasks['ReplicationInstanceArn']

        return ReplicationInstanceArn

rep_instance_arn = get_replication_instance_arn()

# Get replication instances by providing the replication instance arn
def get_replication_instances():

    client = boto3.client('dms')
    
    response = client.describe_replication_instances(Filters=[
        {
            'Name': 'rep-instance-arn',
            'Values': [
                rep_instance_arn,
            ]
        },
    ],
    MaxRecords=100,
    Marker='')
    
    
    return response['ReplicationInstances']

# Get the replication instance id from the Replication Instance result
def get_replication_instance_id():
    for ReplicationInstances in get_replication_instances():
     ReplicationInstanceIdentifier = ReplicationInstances['ReplicationInstanceIdentifier']

     return ReplicationInstanceIdentifier

# Construct log group name by concatenating "dms_tasks" to the replication instance id obtained from the method above
log_group = "dms-tasks-" + get_replication_instance_id()


# Get the cloud watch log events for the DMS Task by supplying the log group, limit and the time range
def get_cloudwatch_log_events(log_group):
    
    client = boto3.client('logs')
    kwargs = {
        'logGroupName': log_group,
        'limit': 10000,
        'startTime': start_time,
        'endTime': end_time
    }
    while True:
        response = client.filter_log_events(**kwargs)
        yield from response['events']
        try:
            kwargs['nextToken'] = response['nextToken']
        except KeyError:
            break

# In the main method print the cloudatch log events
def main():
    for event in get_cloudwatch_log_events(log_group):
        sys.stdout.write(event['message'].rstrip() + '\n')

if __name__ == '__main__':
    main()
    