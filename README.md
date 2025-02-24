# Jenkins Automation for Building DEB and RPM Packages

This repository provides a Jenkins automation setup for building `.deb` and `.rpm` packages for this test project: https://github.com/vseslavcharodei/sysinfo-collector.git
It includes a pre-configured Jenkins pipeline, Docker-based Jenkins deployment, and scripts for provisioning the pipeline.

## 📌 Purpose

This setup automates the build process for DEB and RPM packages using Jenkins. The repository includes:
- A **Jenkins Docker container** setup with pre-installed plugins.
- A **Jenkins pipeline** for fetching, building, and packaging code from a Git repository.
- **Groovy scripts** for pipeline job automation and Git branch retrieval.
- **Script approvals** and plugin installation for Jenkins customization.

## 🚀 Installation

### Prerequisites
Before using this setup, ensure you have:
- **Docker & Docker Compose** installed

### Steps
1. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo/jenkins-packager.git
   cd jenkins-packager
   ```
2. **Modify repositories links in `deploy.sh`**
   
   `GIT_REPO` - is a variable that controlls app repository that will be built.
   Default is a test project: https://github.com/vseslavcharodei/sysinfo-collector.git.
   Compatibility with other repositories has not been tested. 

   `PIPELINE_GIT_REPO` - is a variable that controlls repository with Jenkinsfile that will be used to create job in Jenkins under container.
   Default is this very project: https://github.com/vseslavcharodei/jenkins-packager.git
   Compatibility with other repositories has not been tested, as script script also provisions plugins, scriptler script and and approvals, it most probably won't work with your very pipelines.

3. **Run the setup script**
   Execute the provided `deploy.sh` script to set up the Jenkins environment:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

   This script:
   - Pulls and builds the Jenkins Docker container: installing Jenkins plugins (), deploy approvals, Jenkins init scripts and Scriptler scripts.
   - Starts the Jenkins container.
   - Fetches the initial admin password.
   - Configures the Jenkins pipeline automatically.

3. **Access Jenkins**  
   - Open a browser and navigate to `http://localhost:8080`.
   - Retrieve the initial admin password from `jenkinsInit.pass`:
     ```bash
     cat jenkinsInit.pass
     ```
   - Log in using password, skip the setup wizard, and proceed to the Jenkins dashboard.

## ⚙️ Running the Pipeline

1. **Go to Jenkins UI:** [http://localhost:8080](http://localhost:8080)
2. **Select the "Build-Pipeline" job** from the dashboard.
3. Click on **"Build Now"** to trigger the build process.

## 🔄 Workflow Description

1. **Jenkins Container Deployment**
   - The `deploy.sh` script sets up and runs a Jenkins container.
   - It automatically pulls pipeline configurations.

2. **Pipeline Job Setup (`setupPipeline.groovy`)**
   - Creates the **"Build-Pipeline"** job.
   - Configures **Git repositories** for both the application and pipeline.
   - Loads the `Jenkinsfile` to define build steps.

3. **Jenkins Pipeline Execution (`Jenkinsfile`)**
   - Fetches the source code.
   - Builds the application into DEB and RPM packages.
   - Archives build artifacts for deployment.

4. **Script Approvals (`scriptApproval.xml`)**
   - Grants necessary script execution permissions for Jenkins security.

5. **Git Branch Fetching (`getGitBranches.groovy`)**
   - Dynamically retrieves available branches from the Git repository.

6. **Installed Plugins (`jenkins-plugins.txt`)**
   - Lists all required Jenkins plugins for automation.

## 📜 File Structure

```
├── README.md               # This very README file
├── deploy.sh               # Deployment script for Jenkins container
├── Dockerfile              # Docker setup for Jenkins environment
├── Jenkinsfile             # Jenkins pipeline definition
├── jenkins_home
   ├── init.groovy.d
      ├── setupPipeline.groovy    # Script to set up the Jenkins job
   ├── scriptler_scripts
      ├── getGitBranches.groovy   # Fetch Git branches dynamically
      ├── scriptler.xml           # Script configuration for Jenkins Scriptler plugin
   ├── jenkins-plugins.txt     # List of required Jenkins plugins
   ├── scriptApproval.xml      # Approved scripts for execution in Jenkins
```

## 🛠️ Troubleshooting

### Jenkins container doesn't start
- Run `docker logs jenkins-packager` to check logs.
- Ensure Docker is running and accessible.

### Pipeline job doesn't appear
- Check logs for errors in `setupPipeline.groovy` execution.
- Manually add the job in Jenkins if necessary.

### Build fails with missing dependencies
- Ensure all required plugins are installed (`jenkins-plugins.txt`).

### Jenkins init password retrival fails, no jenkinsInit.pass
- Check if `jenkins-packager` container runs with `docker ps -a`.
- If doesn't run, then you may check logs to find out what's going wrong: `docker logs <CONTAINER_ID>`.
- If it is running, exec into `jenkins-packager` using `docker exec -it jenkins-packager bash`, ensure password file exists `/var/jenkins_home/secrets/initialAdminPassword`.
- if password exists, most probably Jenkins didn't finish init in `sleep 10` timeout set before pass retrival. In this case you may use password in `initialAdminPassword` or try to increase `sleep` timeout in `deploy.sh` and re-run it.
- if password doesn't exist, check docker logs for errors `docker logs jenkins-packager`.

## 📌 Contribution
Feel free to submit **issues** and **pull requests** to improve the automation process.

## 📜 License
This project is licensed under the MIT License.
