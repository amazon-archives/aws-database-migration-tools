from __future__ import print_function

import json
import urllib
import boto3
import random

print('Loading function')

s3 = boto3.client('s3')


def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.unquote_plus(event['Records'][0]['s3']['object']['key'].encode('utf8'))

    targetBucket = bucket
    targetKey = "changedata/CDC" + "{:0^6}".format(str(random.randint(1,100000))) + ".csv"

    s3.copy_object(Bucket=targetBucket, CopySource=bucket+"/"+key, Key = targetKey)

    return targetKey
