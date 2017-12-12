from __future__ import print_function

import boto3
import base64
import json
import re

print('Loading function')

batch = boto3.client('batch')


def lambda_handler(event, context):
    output = []
    succeeded_record_cnt = 0
    failed_record_cnt = 0
    for record in event['records']:
        print(record['recordId'])
        payload = base64.b64decode(record['data'])
        #print(payload)
        #{"ticker_symbol":"QXZ", "sector":"HEALTHCARE", "change":-0.05, "price":84.51}
        p = re.compile(r"^\{\"(\w+)\":(\"\w+\"),\"(\w+)\":(\"\w+\"),\"(\w+)\":(.{0,1}\d*.{0,1}\d*),\"(\w+)\":(\d*.{0,1}\d*)\}")
        m = p.match(payload)
        fixed_payload = "INSERT,ticker,stock"

        if m:
            succeeded_record_cnt += 1
            output_payload = fixed_payload + "," + m.group(2) + ',' + m.group(4) + ',' + m.group(6) + ',' + m.group(8) + '\n'
            print(output_payload)
            output_record = {
                'recordId': record['recordId'],
                'result': 'Ok',
                'data': base64.b64encode(output_payload)
            }
        else:
            print(payload)
            output_payload = ",,,,\n"
            print('Parsing failed')
            failed_record_cnt += 1
            output_record = {
                'recordId': record['recordId'],
                'result': 'ProcessingFailed',
                'data': base64.b64encode(output_payload)
            }

        output.append(output_record)

    print (output)

    print('Processing completed.  Successful records {}, Failed records {}.'.format(succeeded_record_cnt, failed_record_cnt))
    return {'records': output}
