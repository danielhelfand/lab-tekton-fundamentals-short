Now that you have created a `Task` to build and push a container image to an image
registry, the next `Task` your `Pipeline` will need is a `Task` that can deploy the 
the container and start it up on Kubernetes.

The `Task` you will create is named `deploy-using-kubectl`:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deploy-using-kubectl
spec:
  params:
    - name: path
      type: string
      description: Path to the manifest to apply
    - name: yamlPathToImage
      type: string
      description: |
        The path to the image to replace in the yaml manifest (arg to yq)
  resources:
    inputs:
      - name: source
        type: git
      - name: image
        type: image
  steps:
    # replace-image replaces image specified in manifest
    # with the image resource used for the TaskRun
    - name: replace-image
      image: mikefarah/yq
      command: ["yq"]
      args:
        - "w"
        - "-i"
        - "$(params.path)"
        - "$(params.yamlPathToImage)"
        - "$(resources.inputs.image.url)"
    # run-kubectl applies the manifest passed in via the 
    # path param to deploy the image specified via the image
    # resource
    - name: run-kubectl
      image: lachlanevenson/k8s-kubectl
      command: ["kubectl"]
      args:
        - "apply"
        - "-f"
        - "$(params.path)"
```

Once again, this `Task` has `PipelineResources` that it requires in order to be ran. This `Task` requires a `PipelineResource` 
of `type: git` and another of `type: image`, but this isn't exactly the same as `build-docker-image-from-git-source`. 

The major difference is that the `image` `PipelineResource` is an `input` `PipelineResource` this time instead of an `output` like 
with `build-docker-image-from-git-source`. The significance of this is that `deploy-using-kubectl` is expecting a container image 
as a value that it will use instead of something that is produced as a result of the `Task`. 

The last portion of this `Task` is a list of its `steps`. The first `step` for `deploy-using-kubectl` is named `replace-image`. 
This `step` uses the official image for `yq`, which is a CLI tool for working with YAML files. 

`replace-image` makes sure the manifest YAML file (i.e. Kubernetes resources needed to support an application) you will use to 
deploy the container built from `build-docker-image-from-git-source` uses the image built from the `Task` instead of a hard coded 
value in the manifest. This allows you to change information at run time via a `TaskRun` about which image to deploy.

The second `step` is named `run-kubectl`. This `step` allows you to use `kubectl` during the execution of this `Task` to run an 
`apply -f` subcommand on a file. In this case, the file will be the manifest YAML file with resources defined to support the application 
your `Pipeline` will deploy.

You may be wondering where this manifest is located. It will be available in the git repository provided by the `git` `PipelineResource` 
named `source`. So the git repository provided via a `PipelineResource` will be how `run-kubectl` can find the manifest to apply.

Create `deploy-using-kubectl` by running:

```execute-1
kubectl apply -f /home/eduk8s/tekton/tasks/kubectl.yaml
```

Verify the `Task` was created:

```execute-1
tkn task ls
```

You should now see a second `Task` in your namespace. You have created all the `Tasks` needed for the `Pipeline` you will create. Before creating 
the `Pipeline`, you should learn a bit about how a Kubernetes `ServiceAccount` can help with automating processes with CI/CD and manage sensitive 
information used during your CI/CD process via Kubernetes `Secrets`.

Clear your terminals before continuing:

```execute-1 
clear
```

Click the **ServiceAccount** button to continue.