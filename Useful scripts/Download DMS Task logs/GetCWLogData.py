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


replication_task_id = sys.argv[1]
time_string = sys.argv[2]
end_time_string = sys.argv[3]

def milliseconds_since_epoch(time_string):
    dt = maya.when(time_string)
    seconds = dt.epoch
    return seconds * 1000

start_time = milliseconds_since_epoch(time_string)

def end_time_milliseconds_since_epoch(end_time_string):
    dt = maya.when(end_time_string)
    seconds = dt.epoch
    return seconds * 1000

end_time = end_time_milliseconds_since_epoch(end_time_string)

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


def get_replication_instance_arn():
    for ReplicationTasks in get_replication_tasks():
        ReplicationInstanceArn = ReplicationTasks['ReplicationInstanceArn']

        return ReplicationInstanceArn

rep_instance_arn = get_replication_instance_arn()

def get_replication_id():
    """List the first 10000 log events from a CloudWatch group.

    :param log_group: Name of the CloudWatch log group.

    """
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

def get_log_group():
    for ReplicationInstances in get_replication_id():
     ReplicationInstanceIdentifier = ReplicationInstances['ReplicationInstanceIdentifier']

     return ReplicationInstanceIdentifier

log_group = "dms-tasks-" + get_log_group()

print(log_group)

def get_log_events(log_group):
    """Generate all the log events from a CloudWatch group.

    :param log_group: Name of the CloudWatch log group.

    """
    
    client = boto3.client('logs')
    kwargs = {
        'logGroupName': log_group,
        'limit': 10000,
        'startTime': start_time,
        'endTime': end_time
    }
    while True:
        resp = client.filter_log_events(**kwargs)
        yield from resp['events']
        try:
            kwargs['nextToken'] = resp['nextToken']
        except KeyError:
            break
    
if __name__ == '__main__':
    for event in get_log_events(log_group):
        '''print(event['message'].rstrip())'''
        sys.stdout.write(event['message'].rstrip() + '\n')