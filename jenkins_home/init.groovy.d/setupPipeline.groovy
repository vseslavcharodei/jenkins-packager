import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.plugins.git.*

def jenkins = Jenkins.instance

// Define repository URLs
def appRepoUrl = System.getenv("APP_GIT_REPO") // MyApp Repository
def pipelineRepoUrl = System.getenv("PIPELINE_GIT_REPO") // Jenkinsfile Repository

def jobName = "Build-Pipeline"
def existingJob = jenkins.getItem(jobName)

if (existingJob == null) {
    println "Creating new pipeline job: ${jobName}"
    
    def job = jenkins.createProject(WorkflowJob, jobName)

    // Configure source code repository (MyApp Repo)
    def appScm = new hudson.plugins.git.GitSCM(appRepoUrl)
    appScm.branches = [new hudson.plugins.git.BranchSpec("*/main")]

    // Configure separate pipeline repository (Jenkinsfile Repo)
    def pipelineScm = new hudson.plugins.git.GitSCM(pipelineRepoUrl)
    pipelineScm.branches = [new hudson.plugins.git.BranchSpec("*/develop")]

    // Load the Jenkinsfile from the pipeline repository
    def flowDefinition = new CpsScmFlowDefinition(pipelineScm, "Jenkinsfile")
    job.definition = flowDefinition
    job.save()

    println "Pipeline job '${jobName}' created successfully."
} else {
    println "Pipeline job '${jobName}' already exists. Updating it..."

    // Update pipeline repository to fetch Jenkinsfile
    def pipelineScm = new hudson.plugins.git.GitSCM(pipelineRepoUrl)
    pipelineScm.branches = [new hudson.plugins.git.BranchSpec("*/main")]

    def flowDefinition = new CpsScmFlowDefinition(pipelineScm, "Jenkinsfile")
    existingJob.definition = flowDefinition
    existingJob.save()

    println "Pipeline job '${jobName}' updated successfully."
}

