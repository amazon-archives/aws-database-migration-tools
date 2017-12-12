import psycopg2
import sys
import requests
import json


def dbConnect(event):
    #Grab the endpoints
    DBEndPoint = event['ResourceProperties']['DBEndPoint']
    DBPort = event['ResourceProperties']['DBPort']
    DBName = event['ResourceProperties']['DBName']
    DBUserName = event['ResourceProperties']['DBUserName']
    DBPassword = event['ResourceProperties']['DBPassword']

    #Define our connection string
    conn_string = "host=" + DBEndPoint + " port =" + DBPort + " dbname=" + DBName + " user=" + DBUserName + " password=" + DBPassword

    # print the connection string we will use to connect
    print "Connecting to database\n     ->%s" % (conn_string)

    # get a connection, if a connect cannot be made an exception will be raised here
    conn = psycopg2.connect(conn_string)

    # conn.cursor will return a cursor object, you can use this cursor to perform queries
    cursor = conn.cursor()
    print "Connected!\n"

    #Creating schema
    cursor.execute ("Create Schema IF NOT EXISTS Stock")
    print "Schema Created\n"

    cursor.execute(" \
        Create Table IF NOT EXISTS Stock.Ticker \
        ( \
          ticker_symbol varchar(20) not null, \
          sector varchar(20) not null, \
          change float not null, \
          price float not null \
        ) \
    ")
    print ("Table Created ready to accept data...")

def sendResponse(event, context, responseStatus, responseData):
    responseBody = {'Status': responseStatus,
                    'Reason': 'See the details in CloudWatch Log Stream: ' + context.log_stream_name,
                    'PhysicalResourceId': context.log_stream_name,
                    'StackId': event['StackId'],
                    'RequestId': event['RequestId'],
                    'LogicalResourceId': event['LogicalResourceId'],
                    'Data': responseData}
    print 'RESPONSE BODY:n' + json.dumps(responseBody)
    try:
        req = requests.put(event['ResponseURL'], data=json.dumps(responseBody))
        if req.status_code != 200:
            print req.text
            raise Exception('Recieved non 200 response while sending response to CFN.')
        return
    except requests.exceptions.RequestException as e:
        print e
        raise


def lambda_handler(event, context):
    # TODO implement

    dbConnect(event)

    print (event['ResourceProperties'])
    #print (context)
    responseStatus = 'SUCCESS'
    responseData = {'Success': 'Test Passed.'}
    sendResponse(event, context, responseStatus, responseData)
