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

