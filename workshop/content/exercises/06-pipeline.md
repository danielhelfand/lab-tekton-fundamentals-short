You are now ready to create a `Pipeline` that will use the `Tasks` and `PipelineResources` 
you created in previous sections.

The `Pipeline` you will create is shown below:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: go-web-server-pipeline
spec:
  resources:
    - name: source-repo
      type: git
    - name: image
      type: image
  tasks:
    - name: build-go-web-server
      taskRef:
        name: build-docker-image-from-git-source
      params:
        - name: pathToDockerFile
          value: Dockerfile
      resources:
        inputs:
          - name: docker-source
            resource: source-repo
        outputs:
          - name: builtImage
            resource: image
    - name: deploy-go-web-server
      taskRef:
        name: deploy-using-kubectl
      resources:
        inputs:
          - name: source
            resource: source-repo
          - name: image
            resource: image
            from:
              - build-go-web-server
      params:
        - name: path
          value: /workspace/source/k8s.yaml
        - name: yamlPathToImage
          value: "spec.template.spec.containers[0].image"
```

Under the `resources` property of `go-web-server-pipeline`, this will be where the `PipelineResources` 
created in the previous section will be added.

The first `PipelineResource` required is of `type: git` and is named `source-repo`. This is how you 
will connect the `PipelineResource` named `go-web-server-git` to a `PipelineRun` that will execute 
`go-web-server-pipeline`. 

The second `PipelineResource` required is of `type: image` and is named `image`. This is how you will 
connect the `PipelineResource` named `go-web-server-image` to a `PipelineRun`.

Under the `tasks` property of a `go-web-server-pipeline`, this will be where the `Tasks` created in previous 
sections will be added.

The first `Task` on `go-web-server-pipeline` is named `build-go-web-server`, but the actual `Task` used is declared 
under the property `taskRef`. You will see the `build-docker-image-from-git-source` is the `Task` that is actually 
used even though the `Pipeline` itself allows for different `Task` names to be declared.

Under the `resources` and `params` properties, you can see how this `Pipeline` will pass `PipelineResources` and `params` 
to `build-docker-image-from-git-source`. 

The next `Task` on `go-web-server-pipeline` is named `deploy-go-web-server`. The actual `Task` used is once again declared via a 
`taskRef` and specifies that `deploy-using-kubectl` is the `Task` that will be used. Under the `resources` property, you will see 
how the `source-repo` and `image` `PipelineResources` are passed to `deploy-using-kubectl`. 

Something to make note of under the `resources` property as well is a property called `from`. The `from` property declares that 
the `PipelineResources` used by this `Task` will be supplied from another `Task`. In this case, the `PipelineResources` will come from the `Task` 
that runs before it on the `Pipeline` (i.e. `build-go-web-server`). The `from` property is one of a few ways to declare that `Tasks` on a `Pipeline` 
should run in a certain order. 

Create `go-web-server-pipeline`:

```execute-1
kubectl apply -f /home/eduk8s/tekton/pipeline/pipeline.yaml
```

Verify the creation of `go-web-server-pipeline`:

```execute-1
tkn pipeline ls
```

Now that you have created a `Pipeline`, you have all the necessary resources to create a `PipelineRun` that will build an application into 
a container image, push that image to a local image registry, and then deploy the image as a running container to your Kubernetes cluster.

Clear your terminal before continuing:

```execute-1 
clear
```

Click the **Create a PipelineRun** button to continue.