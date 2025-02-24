node {

    // Ensure required environment variables are set
    if (!env.GIT_REPO) {
        error("ERROR: GIT_REPO environment variable is not set!")
    }

    // Define GIT_REPO local variable to pass value from env.GIT_REPO to ScriptlerScript
    def gitRepo = env.GIT_REPO
    
    // Define Job Properties and Parameters
    properties([
        parameters([
            [$class: 'CascadeChoiceParameter',
                name: 'APP_VERSION',
                script: [
                    $class: 'ScriptlerScript',
                    scriptlerScriptId: 'getGitBranches.groovy',
                    parameters: [
                        [name: 'gitRepo', value: gitRepo]
                    ]
                ],
                choiceType: 'PT_SINGLE_SELECT',
                description: 'Select an application version to build'
            ],
            choice(
                name: 'PACKAGE_TYPE', 
                choices: ['rpm', 'deb', 'all'], 
                description: 'Select package type to build',
                defaultValue: 'rpm'
            )
        ])
    ])

    // Define other params to use in stages
    def appVersion = params.APP_VERSION == "develop" ? "2.1" : params.APP_VERSION
    def packageType = params.PACKAGE_TYPE
    def appName = gitRepo.tokenize('/').last().replaceAll(/\.git$/, '')
    def checkoutDir = "${appName}-${appVersion}"
    // Define build base directory path
    def artifactSourceDir = "${WORKSPACE}/${BUILD_NUMBER}"
    // Define repo directory path
    def repoDir = "${WORKSPACE}/${BUILD_NUMBER}/${checkoutDir}"


    // Checkout Code from Git
    stage("Checkout") {
        script {
            echo "Create build directory path: ${repoDir}"
            sh "mkdir -p ${repoDir}"

            echo "Cloning repository from ${gitRepo} (Branch: ${appVersion}) into ${repoDir}"

            // Checkout inside the specified directory
            dir(repoDir) {
                git branch: "${appVersion}", url: "${gitRepo}"
            }

            echo "DEBUG: Listing files in ${repoDir} after checkout:"
            sh "ls -lah ${repoDir}"
        }
    }

    // Build RPM Package if selected
    if (packageType == 'rpm' || packageType == 'all') {
        stage("Build RPM") {
            script {
                sh """
                #!/bin/bash
                set -e  # Stop script on error
                
                APP_NAME="${appName}"
                APP_VERSION="${appVersion}"
                CHECKOUT_DIR="${checkoutDir}"
                BUILD_DIR="${artifactSourceDir}"

                echo "Current directory: \$(pwd)"

                echo "Navigate to \$BUILD_DIR dir"
                cd \$BUILD_DIR

                echo "Building RPM package for \$APP_NAME version \$APP_VERSION"
                
                # Archive the source directory into a tarball
                tar czvf "\$CHECKOUT_DIR.tar.gz" "\$CHECKOUT_DIR"
                
                # Run rpmbuild with workspace-defined directories
                rpmbuild -ba "\$CHECKOUT_DIR/rpm/\$APP_NAME.spec" --define "_sourcedir \$BUILD_DIR" --define "_topdir \$BUILD_DIR/rpmbuild" --define "_tmppath \$BUILD_DIR/rpmbuild/tmp" --define "version \$APP_VERSION"
                
                # Move built RPMs to the workspace for Jenkins archiving
                mkdir -p "\$BUILD_DIR/artifacts"
                find "\$BUILD_DIR/rpmbuild/RPMS" "\$BUILD_DIR/rpmbuild/SRPMS" -name "*.rpm" -exec mv -v {} "\$BUILD_DIR/artifacts/" \\;
                """
            }
        }
    }

    // Build DEB Package if selected
    if (packageType == 'deb' || packageType == 'all') {
        stage("Build DEB") {
            script {
                sh """
                #!/bin/bash
                set -e  # Stop script on error
                
                APP_NAME="${appName}"
                APP_VERSION="${appVersion}"
                CHECKOUT_DIR="${checkoutDir}"
                BUILD_DIR="${artifactSourceDir}"

                echo "Current directory: \$(pwd)"

                echo "Navigate to \$BUILD_DIR dir"
                cd \$BUILD_DIR

                echo "Building DEB package for \$APP_NAME version \$APP_VERSION"
                echo "Navigate to package root direcory WORKSPACE/CHECKOUT_DIR"
                cd \$BUILD_DIR/\$CHECKOUT_DIR
                
                # Build DEB package
                dpkg-buildpackage -us -uc

                # Move built DEBs to the workspace for Jenkins archiving
                mkdir -p "\$BUILD_DIR/artifacts"
                find "\$BUILD_DIR" -name "*.deb" -exec mv -v {} "\$BUILD_DIR/artifacts/" \\;
                """
            }
        }
    }

    // Archive Build Artifacts
    stage("Archive Packages") {
        script {
            def artifactsExist = false

            // Check if any artifacts exist before attempting to archive
            dir(artifactSourceDir) {
                def rpmExists = sh(script: "ls -A artifacts/*.rpm 2>/dev/null", returnStatus: true) == 0
                def debExists = sh(script: "ls -A artifacts/*.deb 2>/dev/null", returnStatus: true) == 0
                artifactsExist = rpmExists || debExists  // Set to true if either format exists
            }

            if (artifactsExist) {
                echo "Artifacts found, archiving..."
                dir(artifactSourceDir) {
                    archiveArtifacts artifacts: 'artifacts/*.rpm, artifacts/*.deb', fingerprint: true
                }
                currentBuild.description = "Artifacts archived"
            } else {
                echo "No artifacts found, skipping archive."
            }
        }
    }

    // Cleanup stage after successful archive
    stage("Cleanup") {
        script {
            if (currentBuild.description?.contains("Artifacts archived")) {
                echo "Deleting ${artifactSourceDir}"
                sh "rm -rf ${artifactSourceDir}"
                sh "rm -rf ${artifactSourceDir}@tmp"
            } else {
                echo "No artifacts were archived, skipping cleanup."
            }
        }
    }

}