### JenkinsFile explanation

The plugins installed into Jenkins enhance what is available to the Groovy Pipeline DSL. The values.yaml files we used has several plugins, including the [kubernetes](https://plugins.jenkins.io/kubernetes) plugin.

Based on the [Scaling Docker with Kubernetes](http://www.infoq.com/articles/scaling-docker-with-kubernetes) article, automates the scaling of Jenkins agents running in Kubernetes.

The plugin creates a Kubernetes Pod for each agent started, defined by the Docker image to run, and stops it after each build.

Agents are launched using JNLP, so it is expected that the image connects automatically to the Jenkins master. For that some environment variables are automatically injected:

JENKINS_URL: Jenkins web interface url
JENKINS_SECRET: the secret key for authentication
JENKINS_NAME: the name of the Jenkins agent


## podTemplate

The **podTemplate** is a template of a pod that will be used to create agents. It can be either configured via the user interface, or via pipeline.

## node
**node** is a special step that schedules the contained steps to run by adding them to Jenkins’ build queue. Even better, requesting a node leverages Jenkins’ distributed build system. Of course, to select the right kind of node for your build, the node element takes a label expression `node("test")`

The node step also creates a workspace: a directory specific
to this job where you can check out sources, run commands,
and do other work. Resource-intensive work in your pipeline
should occur on a node. You can also use the ws step to
explicitly ask for another workspace on the current slave,
without grabbing a new executor slot. Inside its body all
commands run in the second workspace.

## stage

**Stages** are usually the topmost element of Workflow syntax. Stages allow you to group your build step into its component parts. By default, multiple builds of the same workflow can run concurrently.
