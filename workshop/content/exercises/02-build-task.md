Now that you have an understanding of the basics of a `Task` and a `TaskRun`, 
this next section will allow you to create `Tasks` that can be used as part 
of a `Pipeline`. The `Pipeline` you will create will build an application from 
a Dockerfile, push that resulting container image to an image registry, and deploy 
the pushed image to the namespace you are currently using.

The `Tasks` needed for this `Pipeline` will be as follows:
* Building a container image via a Dockerfile and pushing the image to a registry
* Deploying the pushed container image to your Kubernetes cluster

The first `Task` you will create is named `build-docker-image-from-git-source`:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-docker-image-from-git-source
spec:
  params:
    - name: pathToDockerfile
      type: string
      description: The path to the dockerfile to build
      default: /workspace/docker-source/Dockerfile
    - name: pathToContext
      type: string
      description: |
        The build context used by Kaniko
        (https://github.com/GoogleContainerTools/kaniko#kaniko-build-contexts)
      default: /workspace/docker-source
  resources:
    inputs:
      - name: docker-source
        type: git
    outputs:
      - name: builtImage
        type: image
  steps:
    - name: build-and-push
      image: gcr.io/kaniko-project/executor:v0.17.1
      # specifying DOCKER_CONFIG is required to allow kaniko to detect docker credential
      env:
        - name: "DOCKER_CONFIG"
          value: "/tekton/home/.docker/"
      command:
        - /kaniko/executor
      args:
        - --dockerfile=$(params.pathToDockerfile)
        - --destination=$(resources.outputs.builtImage.url)
        - --context=$(params.pathToContext)
```

To summarize, `build-docker-image-from-git-source` will take a git repository input, build the Dockerfile present in the git 
repository using `kaniko`, and then will push the built image to an image registry.

Under the `resources` property of the `Task`, an `input` `PipelineResource` of `type: git` is declared, meaning that this 
`Task` expects a git repository to work with. 

The `output` `PipelineResource` of `type: image` specifies the container image registry, image name, and tag associated with 
the image where a built container image will be pushed to. 

The last portion of the `Task` declares the `step` that is used to build and push a container image to an image registry. A `Step` is a 
container that will execute a particular command or an entire script. A `Task` is used to order the execution of `Steps` in sequential order, 
meaning these containers run in a Kubernetes `Pod` in the order they are defined under the `steps` property of a `Task`.

The `name` of the `step` is `build-and-push`, and it uses the official `kaniko` project container image, which allows the 
`step` to run the `command` `/kaniko/executor`. It also adds `args` to the `/kaniko/executor` root command. 

Create `build-docker-image-from-git-source`:

```execute-1
kubectl apply -f /home/eduk8s/tekton/tasks/kaniko.yaml
```

Verify the `build-docker-image-from-git-source` was created:

```execute-1
tkn task ls
```

You should now see a `Task` created in your namespace: `build-docker-image-from-git-source`.

In the next section, you will learn about the second `Task` for the `Pipeline` you will create to deploy the 
container image built from `build-docker-image-from-git-source`.

Clear your terminal before continuing:

```execute-1 
clear
```

Click the **Deploy Task** button to continue.