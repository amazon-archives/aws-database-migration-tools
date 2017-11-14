#!/usr/bin/env bash
# profile to use for accessing the bucket, will authorize requester pays
AWSPROFILE="myprofile"
# S3 Bucket and key to upload the files to
BUCKETKEY="mybucket/mykey/"
# Create a temporary directory to hold the files locally before uploading to S3
mkdir -p tempimdbfiles
cd tempimdbfiles
# currently the loop is only looking for one file.
# You can change the --prefix value to look for a group of files or all the files
for DOCUMENT in `aws s3api list-objects --bucket imdb-datasets --prefix "documents/v1/current/title.basics.tsv.gz" --request-payer requester --profile $AWSPROFILE | jq -r .Contents[].Key`; do
    echo "     downloading $DOCUMENT"
    FILENAME="$(echo $DOCUMENT | sed 's|documents/v1/current/||g')"
    echo " saving to file $FILENAME"
    aws s3api get-object --bucket imdb-datasets  --request-payer requester --profile $AWSPROFILE  --key $DOCUMENT $FILENAME
    # unzip the file locally before uploading to S3
    gunzip $FILENAME
done
## upload the items to the bucket
aws s3 sync . s3://$BUCKETKEY --profile "default"
## Clean up after
cd ..
rm -rf tempimdbfiles
