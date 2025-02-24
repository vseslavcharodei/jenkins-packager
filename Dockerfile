FROM jenkins/jenkins:lts

USER root

# Install dpkg utilities and other dependencies for building RPM and DEB packages
RUN apt-get update && apt-get install -y \
    git \
    rpm \
    dpkg-dev \
    devscripts \
    debhelper \
    fakeroot \
    lintian \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for Jenkins
ENV GIT_REPO=https://github.com/vseslavcharodei/sysinfo-collector.git
ENV PIPELINE_GIT_REPO=https://github.com/vseslavcharodei/jenkins-pipelines.git
ENV JENKINS_HOME=/var/jenkins_home
ARG LOCAL_JENKINS_HOME=jenkins_home
# INSECURE: Uncomment below line if you want to disable auth and initial set up wizard to be displayed.
#ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Copy the Groovy scripts for pipeline setup
COPY ${LOCAL_JENKINS_HOME}/init.groovy.d/setupPipeline.groovy ${JENKINS_HOME}/init.groovy.d/
COPY ${LOCAL_JENKINS_HOME}/scriptler_scripts/getGitBranches.groovy ${JENKINS_HOME}/scriptler/scripts/
COPY ${LOCAL_JENKINS_HOME}/scriptler_scripts/scriptler.xml ${JENKINS_HOME}/scriptler/
COPY ${LOCAL_JENKINS_HOME}/scriptApproval.xml ${JENKINS_HOME}/
COPY ${LOCAL_JENKINS_HOME}/jenkins-plugins.txt ${JENKINS_HOME}/jenkins-plugins.txt

# Ensure the scripts has correct permissions
RUN chown -R jenkins:jenkins ${JENKINS_HOME}/init.groovy.d/ \
    && chmod 755 ${JENKINS_HOME}/init.groovy.d/setupPipeline.groovy

RUN chown -R jenkins:jenkins ${JENKINS_HOME}/scriptler/ \
    && chmod 644 ${JENKINS_HOME}/scriptler/scripts/getGitBranches.groovy \
    && chmod 644 ${JENKINS_HOME}/scriptler/scriptler.xml

RUN chown jenkins:jenkins ${JENKINS_HOME}/scriptApproval.xml \
    && chmod 644 ${JENKINS_HOME}/scriptApproval.xml

RUN ls -lah ${JENKINS_HOME}

# Install required Jenkins plugins
RUN jenkins-plugin-cli --plugin-file ${JENKINS_HOME}/jenkins-plugins.txt

# Set Jenkins to run with proper permissions
USER jenkins
