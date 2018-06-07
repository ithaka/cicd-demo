multibranchPipelineJob('example') {
    branchSources {
        git {
            remote('https://github.com/StevenACoffman/cicd-demo.git')
            includes('JENKINS-*')
        }
    }
    orphanedItemStrategy {
        discardOldItems {
            numToKeep(20)
        }
    }
}
