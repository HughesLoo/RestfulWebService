#!/bin/bash

if [ $# -ne 1 ] && [ $# -ne 2 ]; then
    echo "Parameter Error!!! Please check!"
    echo "Usage: $0 dev|uat|prod|... [version]"
    exit 1
fi

source_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $source_path

latest_artifact=$(ls mls-web-api*.zip -rt | tail -1)

echo ">>> Unzipping $source_path/$latest_artifact"
temp_folder=temp
unzip -q $latest_artifact -d $temp_folder

cd $temp_folder

ENV=$1

if [ $# -eq 2 ]; then
    version=$2
else
    version=$(unzip -p mls-web-api*.war **/pom.properties | grep version | sed 's/version=//')
fi

dest_path=/razorapp/scb/mls_$ENV/mls-web/api

echo "the destination is $dest_path, version is $version"

# check if dest_path is ready
if [ ! -d $dest_path ]; then
    echo "$dest_path doesn't exist. Then create it now."
    mkdir -p $dest_path
fi

dos2unix *.sh
chmod 544 *.sh

# delete the deployment scripts
rm -rf deployment

cd configuration

cp -f application.properties.$ENV application.properties
cp -f logback.xml.$ENV logback.xml

rm -f application.properties.*
rm -f logback.xml.*

echo ">>> Moving build artifacts to production folder"
if [ ! -d $dest_path/$version ]; then
    mkdir $dest_path/$version
fi

echo ">>> check logs folder, if not existed, then create it"
if [ ! -d $dest_path/../logs ]; then
    mkdir $dest_path/../logs
fi

cd $source_path
mv $temp_folder/* $dest_path/$version/
rm -rf $temp_folder

cd $dest_path
echo ">>> Setting up symbolic link"
if [ -L prev ]; then
    echo "=> symbolic link prev exist"
    rm -f prev
fi

if [ -L live ]; then
    echo "=> symbolic link live exist"
    mv live prev
fi

ln -s $version live

cd $dest_path/live/configuration
if [ ! -f application.properties ]; then
    echo "deployment error: application.properties is not existed"
fi

if [ ! -f jetty.xml ]; then
    echo "deployment error: jetty.xml is not existed"
fi

if [ ! -f logback.xml ]; then
    echo "deployment error: logback.xml is not existed"
fi

cd $dest_path/live
if [ ! -f start_web_api_services.sh ]; then
    echo "deployment error: start_web_api_services.sh is not existed"
fi

if [ ! -f stop_web_api_services.sh ]; then
    echo "deployment error: stop_web_api_services.sh is not existed"
fi

echo ">>> Deployment successfully completed"