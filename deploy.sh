#!/bin/bash

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running! Please start Docker and try again."
    exit 1
fi

# Define variables
GIT_REPO="https://github.com/vseslavcharodei/sysinfo-collector.git"
PIPELINE_GIT_REPO="https://github.com/vseslavcharodei/jenkins-packager.git"

echo "Building the Jenkins container with pre-configured pipeline..."
docker build -t jenkins-packager .

echo "Deleting previous container version..."
docker kill jenkins-packager > /dev/null 2>&1
docker rm jenkins-packager > /dev/null 2>&1

echo "Running the Jenkins container..."
docker run -d --name jenkins-packager \
    -p 8080:8080 -p 50000:50000 \
    -e GIT_REPO="$GIT_REPO" \
    -e PIPELINE_GIT_REPO="$PIPELINE_GIT_REPO" \
    jenkins-packager

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to start Jenkins container!"
    exit 1
fi

echo "Jenkins is now running at: http://localhost:8080"
echo "Retrieving the initial admin password into $(pwd)/jenkinsInit.pass ..."
sleep 10

echo "Jenkins initial Admin Password:"
docker exec -t jenkins-packager cat /var/jenkins_home/secrets/initialAdminPassword | tee jenkinsInit.pass

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to retrieve the initial admin password!"
    exit 1
fi

echo "Pipeline job 'Build-Pipeline' is automatically set up."
echo "Go to Jenkins UI http://localhost:8080 password from $(pwd)/jenkinsInit.pass -> Close 'Launch wizard' -> Open 'Build-Pipeline' job → Click 'Build Now'."
