/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.amazonaws.lambda.demo;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.ByteBuffer;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.S3Event;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.S3Object;

import com.amazonaws.services.kinesis.AmazonKinesis;
import com.amazonaws.services.kinesis.AmazonKinesisClientBuilder;

public class LambdaFunctionHandler implements RequestHandler<S3Event, String> {

	private AmazonS3 s3 = AmazonS3ClientBuilder.standard().build();

	private static AmazonKinesis kinesis;

	public LambdaFunctionHandler() {
	}

	LambdaFunctionHandler(AmazonS3 s3) {
		this.s3 = s3;
	}

	// Request Handler for the Lambda Function
	@Override
	public String handleRequest(S3Event event, Context context) {
		context.getLogger().log("Received event: " + event);

		//Build Kinesis CLient
		kinesis = AmazonKinesisClientBuilder.standard().withRegion("us-east-1").build();
		
		// Get Kinesis Stream name from Lambda Environment Variables
		String streamName = System.getenv("KinesisStream");

		// Get the object from the S3 event and processes the CSV file
		// String holder for each line is CSV file
		String line = "";
		
		// String holder for content type retrieved from object metadata
		String contentType = "";
		
		// Get bucket name
		String bucket = event.getRecords().get(0).getS3().getBucket().getName();
		// Get bucket key
		String key = event.getRecords().get(0).getS3().getObject().getKey();

		try {
			// Retrieve the S3 object with by providing the bucket and key to the ObjectRequest object
			S3Object response = s3.getObject(new GetObjectRequest(bucket, key));
			
			// Get the content type from the S3Object
			contentType = response.getObjectMetadata().getContentType();
			
			// Create an InputStreamReader to hold the Object Content from S3 Object
			InputStreamReader isr = new InputStreamReader(response.getObjectContent());
			
			// Pass in the Input STream Reader to the Buffered Reader
			BufferedReader br = new BufferedReader(isr);
            
			// Process the records from the CSV file one line at a time.
			while ((line = br.readLine()) != null) {
				// get current time as milliseconds to use as Kinesis Partition Key
				long createTime = System.currentTimeMillis();
				//Log to the Lambda Logs in Cloudwatch console.
				context.getLogger().log("CSV: " + line);
				// Put record in Kinesis Data Stream
				kinesis.putRecord(streamName, ByteBuffer.wrap(line.getBytes()), String.format("partitionKey-%d", createTime));
			}
			
			// Log the content type on the Cloudwatch console
			context.getLogger().log("CONTENT TYPE: " + contentType);
		
		} catch (IOException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
			context.getLogger().log(String.format("Error getting object %s from bucket %s. Make sure they exist and"
					+ " your bucket is in the same region as this function.", key, bucket));
			throw e;
		}
		return contentType;
	}
}