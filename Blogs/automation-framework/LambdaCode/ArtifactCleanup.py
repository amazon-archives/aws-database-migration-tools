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

Cleans up S3 versions and removes objects so bucket can be deleted
API Triggers: Lambda invoke Custom Resource
Services: S3
Python 3.6 - AWS Lambda - Last Modified 07/01/2019
"""

import boto3
import cfnresponse
import json

def lambda_handler(event, context):
  try:
    bucketcfn=event['ResourceProperties']['DestBucket']
    responseData = {}

    if event['RequestType'] == 'Create':
      print('Create stack operation nothing will be done')
    elif event['RequestType'] == 'Delete':
      s3 = boto3.resource('s3')
      bucket = s3.Bucket(bucketcfn)
      bucket.object_versions.all().delete()
      print('Delete stack in progress the bucket is emptied')
    elif event['RequestType'] == 'Update':
      print('Update stack')
    cfnresponse.send(event, context, cfnresponse.SUCCESS, {}, '')
  except Exception as e:
    print(e)
    cfnresponse.send(event, context, cfnresponse.FAILURE, {}, '')
