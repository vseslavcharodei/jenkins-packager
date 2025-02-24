import org.jenkinsci.plugins.gitclient.Git
import org.jenkinsci.plugins.gitclient.GitClient

try {
    // Initialize Git client without workspace
    def git = Git.with(null, null).getClient()

    // Fetch remote references
    def remoteRefs = git.getRemoteReferences(gitRepo, null, false, false)

    // Extract branch names from the map keys
    def branches = remoteRefs.keySet()
        .findAll { it.startsWith("refs/heads/") }  // Only get branches
        .collect { it.replaceFirst("refs/heads/", "") } // Remove "refs/heads/" prefix

    return branches
} catch (Exception e) {
    return ["develop"]  // Return "main" in case of an error
}
