# Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at
#
#    http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
# Author: Ryan Cote (AWS)
#
import json
# set the output file for the escaped json to use in the cloudformation template
outfile = open('endpoint-settings/escaped-table-settings.txt','w')
# set the input file of the original json to escape
infile = json.loads(open('endpoint-settings/table-settings.json','r').read())
# this is the line that writes the escaped json for the s3 settings
outfile.writelines(json.dumps(json.dumps(infile)))
