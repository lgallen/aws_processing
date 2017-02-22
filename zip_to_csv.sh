#!/bin/bash

# Bash script can be used to unzip all files in an S3 folder. It loads them to an EC2 instance, unzips,
# then moves the resulting files to a new S3 folder.

# Loop through every file in the subdirectory of my bucket
for key in `aws s3api list-objects --bucket my-bucket --prefix my-subfolder | jq -r '.Contents[].Key'`
do
  # Check to see if it is a zip file
  if [[ $key == *".zip" ]]; then
    echo $key
    # Copy the file from S3 to the target directory
    aws s3 cp s3://my-bucket/$key ~/temp
    # Unnzip the file to a new folder
    unzip -j 'temp/*.zip' -d processed/
    # Move all the files from the processed directory to a new s3 subfolder with the same name
    aws s3 mv ~/processed s3://my-bucket/processed --recursive 
    # Delete the zip file from ec2
    rm ~/temp/*.zip
  fi;
done