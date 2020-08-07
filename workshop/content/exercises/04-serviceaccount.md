In the previous sections, you created `Tasks` that will be able build a container 
image to host an application and then deploy that built image as a container running 
on a Kubernetes cluster. 

For the application your `Pipeline` will deploy to Kubernetes, the `Pipeline` will 
need to be able to create the following Kubernetes resources to support the deployed 
container:
* [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* [Service](https://kubernetes.io/docs/concepts/services-networking/service/)

These resources exist within the manifest YAML file that is part of the GitHub repository 
where the application you will deploy to Kubernetes is. The manifest holds the following 
information:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-web-server-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: go-web-server
  template:
    metadata:
      labels:
        app: go-web-server
    spec:
      imagePullSecrets:
      - name: registry-credentials
      containers:
      - name: go-web-server
        image: danielhelfand/go-web-server:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: go-web-server-service
  labels:
    app: go-web-server
spec:
  type: NodePort
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
  selector:
    app: go-web-server
```

Since the `Pipeline` needs the ability to create these resources, a [ServiceAccount](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/) can be used. This `ServiceAccount` is a user that can be used to help 
with automating certain aspects of working with Kubernetes. A `ServiceAccount` named `tekton-sa` 
has already been created in your namespace that has permissions assigned to it to create and update 
`Deployments` and `Services`.

Run the following command to see the `tekton-sa` `ServiceAccount` available in your namespace:

```execute-1
kubectl get serviceaccount tekton-sa
```

The way permissions are attached to `tekton-sa` is via a Kubernetes [`Role`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/), 
which is a collection of actions or `verbs` that can be used on certain Kubernetes resources. In this 
case, those resources will be `Deployments` and `Services`.

Take a look at the `Role` that `tekton-sa` will have assigned to it:

```execute-1
kubectl describe role create-deployments-services
```

The `create-deployments-services` `Role` allows a user to create and update resources in the namespace where 
the `Role` is created.

You can see how `tekton-sa` is connected to the `create-deployments-services` via a `RoleBinding`, which binds 
a user with the permissions of a `Role`:

```execute-1
kubectl describe rolebinding create-deployments-services-binding
```

Under the `Role` property, you should see `create-deployments-services`, meaning this is the role that will be bound 
to a subject. Under the `Subjects` property, the `tekton-sa` `ServiceAccont` is present.

Having the `tekton-sa` `ServiceAccount` will allow your `Pipeline` to create the supplementary resources needed to 
support that application that will be deployed.

`ServiceAccounts` with Tekton can also be helpful when connecting sensitive information to a user (e.g. an image registry 
username and password) via Kubernetes [`Secrets`](https://kubernetes.io/docs/concepts/configuration/secret/). `tekton-sa` 
will need to make use of a `Secret` with credentials to push to an image registry.

The image registry credentials are available via a local Docker config file, which you can view by running the following 
command:

```execute-1
cat $HOME/.docker/config.json
```

You should see a base64 encoded value under the `auth` property that is a username and password combination for the image registry 
specified above it: `%session_namespace%-registry.%ingress_domain%/`.

Create the `Secret` from the Docker config:

```execute-1
kubectl create secret generic registry-credentials --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson
```

The `Secret` created is named `registry-credentials`. `tekton-sa` already makes use of this `Secret`, which you can see by 
running the following command:

```execute-1
kubectl describe serviceaccount tekton-sa
```

You should see `registry-credentials` available via the `Mountable secrets` property. 

In the next section, you will create `PipelineResources` that will be used to connect an application's GitHub repository 
to a `PipelineRun` as well as an image registry, name, and tag where a built container image will be pushed to.

Clear your terminal before continuing:

```execute-1 
clear
```

Click the **PipelineResources** button to continue.