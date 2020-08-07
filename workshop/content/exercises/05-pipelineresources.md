In order to connect the `Pipeline` you will create to `PipelineResources`, you will need to 
create two `PipelineResources`.

The first is a `PipelineResource` named `go-web-server-git`. This `PipelineResource` 
contains information about a [git repository](https://github.com/danielhelfand/go-web-server) 
with a web server application written in golang:

```yaml
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: go-web-server-git
spec:
  type: git
  params:
    - name: revision
      value: master
    - name: url
      value: https://github.com/danielhelfand/go-web-server
```

Upon being included, this `PipelineResource` will clone the git repository at the url included 
under the `params` property. 

Create the `go-web-server-git` `PipelineResource`:

```execute-1
kubectl apply -f /home/eduk8s/tekton/pipelineresources/git.yaml
```

The last `PipelineResource` your `Pipeline` will need is named `go-web-server-image`. This `PipelineResource` 
captures information about the image registry you will push the resulting container image to after building 
the container image from the `go-web-server-git` `PipelineResource`:

```yaml
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: go-web-server-image
spec:
  type: image
  params:
    - name: url
      value: %session_namespace%-registry.%ingress_domain%/go-web-server:latest
```

Under the `params` property of `go-web-server-image`, the `value` for the param `url` consists of three parts:
* %session_namespace%-registry.%ingress_domain%/ - This value is the domain of a local image registry available on your cluster
* go-web-server - The name of the container image that will be pushed to %session_namespace%-registry.%ingress_domain%/
* latest - The tag of the image 

Create the `go-web-server-image` `PipelineResource`:

```execute-1
kubectl apply -f /home/eduk8s/tekton/pipelineresources/image.yaml
```

Verify that both `PipelineResources` are available in your namespace:

```execute-1
tkn resource ls
```

You should see both `go-web-server-git` and `go-web-server-image` are now created.

Now that you have created and learned about all of the supplementary resources associated 
with creating a `Pipeline` with Tekton, in the next section you will learn about and create 
a `Pipeline` to deploy the application available via `go-web-server-git` to your Kubernetes 
cluster.

Clear your terminal before continuing:

```execute-1
clear
```

Click the **Create a Pipeline** button to continue.