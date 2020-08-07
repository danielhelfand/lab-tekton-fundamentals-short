You have now successfully used a `Pipeline` to deploy a container-hosted application
to your Kubernetes cluster. 

To verify a successful deployment of the application from `go-web-server-pipeline`, create 
an `Ingress` to create an endpoint to access the application:

```execute-1
kubectl apply -f /home/eduk8s/tekton/ingress/ingress.yaml
```

Run the following command to ping the application to get back a response:

```execute-1
curl http://go-web-server-service.%session_namespace%.svc.cluster.local:8080/Tekton
```

You should get back a response of `Hi there, I love Tekton!`, which confirms a successful deployment.

Click on **Workshop Summary** to finish up the workshop.