"""
Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Information Block.

Checks the messages from SNS to see if its from DMS or CodePipeline
If CodePipeline it retrieves execution token and stores in SSM parameter store
If DMS then based on task status approves or rejects the pipeline
API Triggers: Lambda invoke Custom Resource
Services: DMS, CodePipeline, SNS
Python 3.6 - AWS Lambda - Last Modified 07/01/2019
"""
import boto3
import json
import os
ssm = boto3.client('ssm')
sns = boto3.client('sns')
codepipeline = boto3.client('codepipeline')
ssm_parameter = os.environ['codepipeline_token']
pipeline_name = os.environ['pipeline_name']
task_name = os.environ['dms_task']
topic = os.environ['notify_topic']
def lambda_handler(event, context):
    print(event)
    str_subject = event['Records'][0]['Sns']['Subject']
    if 'APPROVAL NEEDED' in str_subject:
        print('This is a Codepipeline approval action')
        str_sns = event['Records'][0]['Sns']['Message']
        sns_msg = json.loads(str_sns)
        pipeline = sns_msg['approval']['pipelineName']
        stage = sns_msg['approval']['stageName']
        action = sns_msg['approval']['actionName']
        token = sns_msg['approval']['token']
        approve_param ="pipelineName='%s',stageName='%s',actionName='%s',token='%s'" % ( pipeline , stage , action , token)
        print(approve_param)
        response = ssm.put_parameter(Name=ssm_parameter,
            Value=approve_param,
            Type='String',
            Overwrite=True
            )
    elif 'DMS' in str_subject:
        print('This is a message from DMS')
        str_sns = event['Records'][0]['Sns']['Message']
        if 'attempt' in str_sns:
            print(str_sns)
            print('Event notification nothing will be done')
        else:
            sns_msg = json.loads(str_sns)
            print(sns_msg['Event Message'])
            dms_status = sns_msg['Event Message']
            if 'STOPPED_AFTER_FULL_LOAD' in dms_status:
                print('DMS task replication is stopped after full load, proceeding to put an approval in Codepipeline')
                result_pipeline('Approved')
            elif 'started' in dms_status:
                print('Lambda will do nothing at this step as the task is started')
            elif 'Create' in dms_status:
                print('Lambda will do nothing at this step as the task is created')
            elif 'FAIL' in dms_status.upper():
                status = 'DMS task failed. Please check the task'
                print(status)
                subj = 'Status Update on DMS Task ' + os.environ['dms_task']
                sns.publish(TopicArn = topic, Message = status, Subject = subj)
                result_pipeline('Rejected')
            else:
                status = 'DMS task did not stop or errored out after full load. Please check the task'
                print(status)
                subj = 'Status Update on DMS Task ' + os.environ['dms_task']
                sns.publish(TopicArn = topic, Message = status, Subject = subj)
                result_pipeline('Rejected')

    else:
        print('This message is from neither Codepipeline Approval or DMS event. Nothing will be done')


def result_pipeline(event):
    print('Getting Codepipeline parameters from SSM to put a %s' %(event))
    codepipeline_params = ssm.get_parameter(Name=ssm_parameter)['Parameter']['Value'].split("'")
    print(codepipeline_params)
    result_reponse = codepipeline.put_approval_result(
        pipelineName=codepipeline_params[1],
        stageName=codepipeline_params[3],
        actionName=codepipeline_params[5],
        result={
            'summary': event,
            'status': event
        },
        token=codepipeline_params[7]
    )
    print(result_reponse)
