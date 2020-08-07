As a refresher of what you have learned, a `PipelineRun` is how run time information can be 
passed to a `Pipeline` and its associated `Tasks`. For the `Pipeline` you have created, there 
are three run time values to specify for a `PipelineRun`:
* A `PipelineResource` for a git repository
* A `PipelineResource` representing where to push a container image
* A `ServiceAccount` with appropriate permissions to create a `Deployment` and `Service`

To pass all of this information to a `PipelineRun`, you can use `tkn pipeline start` to create 
a `PipelineRun` that will run your `Pipeline`. 

Before starting your `PipelineRun`, you can also watch the `Pods` that are being created throughout this `PipelineRun` in the top terminal. 
You will see a `Pod` hosting the `build-go-web-server` `TaskRun` when you start your `PipelineRun`. `Pods` hosting `TaskRuns` will have the 
name of the `Task` being executed in the name of the `Pod`.

```execute-1
watch kubectl get pods
```

Create the `PipelineRun`:

```execute-2
tkn pipeline start go-web-server-pipeline -r source-repo=go-web-server-git -r image=go-web-server-image -s tekton-sa
```

After running the command above, you will see a confirmation message stating the the `PipelineRun` has been created and is now in progress. 
You will also notice a `Pod` is starting up in the top terminal with a name containing `build-go-web-server`.

In the lower terminal, start the logs of the `PipelineRun`:

```execute-2
tkn pr logs --last -f
```

You should begin seeing information about what is occurring during your `PipelineRun` from the logs of the `Pod` hosting the `TaskRun` that is 
executing. The format of the logs of a `PipelineRun` is as follows:

```
[TaskName : StepName]
```

The log output from `[build-go-web-server : build-and-push]` will show instructions being executed for building a Dockerfile for a go application.

As soon as the `build-go-web-server` `TaskRun` finishes, a new `Pod` will be created to host the second `TaskRun` your `Pipeline` will use to deploy an application to your cluster. This `Pod` will have a name containing `deploy-go-web-server`. 

Your `PipelineRun` is finished executing when you see the following output from the logs, which means the `Deployment` and `Service` for the 
go application being deployed were successfully created:

```
[deploy-go-web-server : run-kubectl] deployment.apps/go-web-server-deployment created
[deploy-go-web-server : run-kubectl] service/go-web-server-service created
```

Wait until you see the output above before executing any more commands in this section.

After you see the above output, you will see two more `Pods` are created with names containing `go-web-server-deployment`. These `Pods` will 
each host the container built by your `Pipeline`. Wait until both `Pods` have a `STATUS` of `Running` before continuing.

Since a `PipelineRun` consists of several `TaskRuns`, the creation of the above `PipelineRun` should result in new `TaskRuns` that were created.
Run the following command to see the new `TaskRuns` that were been created:

```execute-2
tkn taskrun ls
```

Which `TaskRun` corresponds to which `Task` on the `Pipeline` can be seen by the name of the `TaskRun`, which contains to the name of `Task` that was 
run. Since both `TaskRuns` have a `STATUS` of `Succeeded`, the `PipelineRun` should also have a `Succeeded` `STATUS`, which can be confirmed by running the command below:

```execute-2
tkn pipelinerun ls
```

Stop the watch on the `Pods` in the first terminal:

```execute-1
<ctrl+c>
```

Clear your terminals before continuing:

```execute-1 
clear
```

```execute-2
clear
```

In the next section, you can view the application your `Pipeline` deployed.

Click the **Verify Deployment** button to continue.