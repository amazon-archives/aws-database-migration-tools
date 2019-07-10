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

Checks the DMS endpoint during creation to see if they were successful
API Triggers: Lambda invoke Custom Resource
Services: DMS
Python 3.6 - AWS Lambda - Last Modified 07/01/2019
"""

import boto3
import json
import cfnresponse

def lambda_handler(event, context):
   rep_arn = event['ResourceProperties']['ReplicationInstanceArn']
   source_arn = event['ResourceProperties']['SourceArn']
   target_arn = event['ResourceProperties']['TargetArn']
   responseData = {}

   try:
       if event['RequestType'] == 'Delete':
           print('Nothing will be done on DeleteStack call')
       else:
           print('This is a %s event' %(event['RequestType']))
           source_status = dms_status(source_arn,rep_arn)
           target_status = dms_status(target_arn,rep_arn)
           if 'successful' in source_status:
               print('Source endpoint was successfully tested')
               if 'successful' in target_status:
                   print('Target endpoint was successfully tested')
               else:
                   print('Target endpoint was not tested. Please test connection with replication instance')
           else:
               print('Source endpoint was not tested. Please test connection with replication instance.')
       cfnresponse.send(event, context, cfnresponse.SUCCESS, responseData, '')
   except Exception as e:
       print(e)
       cfnresponse.send(event, context, cfnresponse.FAILURE, {}, '')

def dms_status(endpoint, rep_inst):
    try:
        dms_client = boto3.client('dms')
        response = dms_client.describe_connections(
        Filters=[
            {
                'Name': 'endpoint-arn',
                'Values': [endpoint]
            },
            {
                'Name': 'replication-instance-arn',
                'Values': [rep_inst]
            }
            ]
        )
        e = response['Connections'][0]['Status']
    except Exception as e:
        print('Error occured with replication instance: %s and endpoint: %s' %(endpoint,rep_inst))
        print ('Exception is %s' %(e))
    return e
