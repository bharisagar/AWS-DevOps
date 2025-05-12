What is Amazon S3 (Simple Storage Service)?
Amazon S3 is a cloud storage service offered by AWS.
 Think of it as an online hard drive where you can store files (data) securely and access them anytime over the internet.
Why is it used?

To store images, videos, documents, backups, logs, etc.


It's highly available, scalable, and durable.


Used by websites, apps, and companies to store or share content.

What is a Bucket in S3?
Imagine a bucket as a folder in S3.
 It is the container where all your files (called objects) are stored.
📌 Important rules about Buckets:
The bucket name must be globally unique (across all AWS users).


You create a bucket in a specific region (like us-east-1, ap-south-1).


You can set permissions to control who can access the bucket or its contents.
What is an Object in S3?
An object is any file you upload into the bucket.
 Example: a .jpg image, a .pdf file, a .csv log, etc.
Each object has:
Key (the name/path of the file)
Data (the actual content)
Metadata (info about the file like size, content-type)
Structure of S3:

S3 (Service)
 └── Bucket (like "my-company-docs")
      ├── Object: reports/2025/reports.pdf
      └── Object: images/logo.png

Access and Security:
Use IAM policies to control access.


Can make objects public (for a website) or private (for backups).


Supports encryption, versioning, and logging.
Accessing S3:
We can interact with S3 via:
AWS Console (web UI)


AWS CLI (aws s3 ls, aws s3 cp)


SDKs (Python, Java, Ruby, etc.)
Let’s do a hands-on example using the AWS CLI to create a bucket and upload a file to S3.
Prerequisites:
Make sure:
AWS CLI is installed on your system.


You’ve configured it with aws configure (with your Access Key, Secret Key, Region, and Output format).

(i already configured it in my system)
✅ Step 1: Create an S3 Bucket
aws s3 mb s3://my-unique-bucket-name-12345 --region ap-south-1

 Notes:
mb = Make Bucket
s3://... = URL format for S3
Replace my-unique-bucket-name-12345 with your globally unique name.
Replace ap-south-1 with your preferred AWS region.
📂 Step 2: Create or Choose a File to Upload
Create a simple file named hello.txt:
echo "Hello S3!" > hello.txt
☁️ Step 3: Upload File to S3
aws s3 cp hello.txt s3://my-unique-bucket-name-12345/
You should see output like:
upload: ./hello.txt to s3://my-unique-bucket-name-12345/hello.txt

🔍 Step 4: Verify File in S3
aws s3 ls s3://my-unique-bucket-name-12345/
You’ll see:
2025-05-12  XX:XX:XX     10 hello.txt

Delete the file and bucket (Cleanup):
aws s3 rm s3://my-unique-bucket-name-12345/hello.txt   #rm = remove file

aws s3 rb s3://my-unique-bucket-name-12345 #rb = remove bucket

Let’s see how to make an S3 file public and access it via a URL, step by step.
⚠️ Warning First
By default, S3 buckets and objects are private to keep your data secure.
So when we make a file public, anyone with the URL can see/download it.
✅ Step 1: Upload a File (if not already done)
echo "Public file" > public.txt
aws s3 cp public.txt s3://my-unique-bucket-name-12345/

🔓 Step 2: Make the File Public
Use this command to add public-read ACL:
aws s3 cp public.txt s3://my-unique-bucket-name-12345/ --acl public-read
Or, if already uploaded:
aws s3api put-object-acl --bucket my-unique-bucket-name-12345 --key public.txt --acl public-read

It throws an error AcessDenied, lets fix this:

Disable Public Block Using AWS Console (Recommended)
Go to S3 Console
Click on your bucket: demo-s3-bucket-008
Click Permissions tab
Scroll to Block public access (bucket settings)
Click Edit
Uncheck:
"Block all public access"
"Block public ACLs"
Confirm by typing “confirm” when prompted
Click Save changes

We do  bucket policy that makes all files in our bucket (demo-s3-bucket-008) publicly readable via URL.
✅ Bucket Policy (Public Read Access to All Objects)
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicReadAccessToAllFiles",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::demo-s3-bucket-008/*"
    }
  ]
}

What This Means:
Principal: "*" → Anyone on the internet
Action: "s3:GetObject" → Can download/read objects
Resource → All files inside demo-s3-bucket-008 bucket
Apply the Policy via CLI:
Save the above JSON in a file, say bucket-policy.json
Run:
aws s3api put-bucket-policy --bucket demo-s3-bucket-008 --policy file://bucket-policy.json
 Test in Browser:
After applying the policy, go to:
https://demo-s3-bucket-008.s3.ap-south-1.amazonaws.com/public.txt




If you want to allow public access only to specific files or folders in your S3 bucket (instead of making everything public), here's how you can do it using a more specific bucket policy.

✅ Example: Make Only One File Public (e.g., public.txt)
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicReadAccessToSpecificFile",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::demo-s3-bucket-008/public.txt"
    }
  ]
}


✅ Example: Make a Folder Public (e.g., files under public/ folder)

Suppose your files are like:
public/image1.png
public/docs/file1.pdf
Use this policy:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicReadAccessToPublicFolder",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::demo-s3-bucket-008/public/*"
    }
  ]
}

Steps to Apply:
Save the policy JSON (above) in a file like bucket-policy.json


Run this command:
	aws s3api put-bucket-policy --bucket demo-s3-bucket-008 --policy file://bucket-policy.json

 Now Test:
https://demo-s3-bucket-008.s3.ap-south-1.amazonaws.com/public/hello.txt




We write a script that will:
Upload all files from a local folder
Upload them to a specific S3 bucket and path
Ensure the uploaded files are publicly accessible
Bash Script: upload_public_files.sh
#!/bin/bash

# ====== CONFIGURATION ======
#!/bin/bash

# ====== CONFIGURATION ======
BUCKET_NAME="demo-s3-bucket-008"
LOCAL_FOLDER="./public"
S3_FOLDER="public"
REGION="ap-south-1"
# ===========================

# Upload all files to S3 folder (no ACL)
aws s3 cp "$LOCAL_FOLDER/" "s3://$BUCKET_NAME/$S3_FOLDER/" --recursive --region "$REGION"

echo "Files uploaded."
echo "Access them like:"
echo "https://$BUCKET_NAME.s3.$REGION.amazonaws.com/$S3_FOLDER/your-file-name"







