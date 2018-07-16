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

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.KinesisEvent;
import com.amazonaws.services.lambda.runtime.events.KinesisEvent.KinesisEventRecord;

public class LambdaFunctionHandler implements RequestHandler<KinesisEvent, Integer> {

	@Override
	public Integer handleRequest(KinesisEvent event, Context context) {
		// Log the input event to the cloudwatch console
		context.getLogger().log("Input: " + event);

		// Read the records from Kinesis Stream and display them on the cloudwatch
		// console
		for (KinesisEventRecord record : event.getRecords()) {
			String payload = new String(record.getKinesis().getData().array());
			context.getLogger().log("Payload: " + payload);
		}
		// return the number of events.
		return event.getRecords().size();
	}
}
