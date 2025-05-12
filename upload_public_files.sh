#!/bin/bash

# ====== CONFIGURATION ======
BUCKET_NAME="demo-s3-bucket-008"
LOCAL_FOLDER="./public"
S3_FOLDER="public"
REGION="ap-south-1"
# ===========================

# Upload all files to S3 with the given path and make them public
aws s3 cp "$LOCAL_FOLDER/" "s3://$BUCKET_NAME/$S3_FOLDER/" --recursive --acl public-read --region "$REGION"

echo "✅ Files uploaded and made public."
echo "🌐 Access them like:"
echo "https://$BUCKET_NAME.s3.$REGION.amazonaws.com/$S3_FOLDER/test.txt"
