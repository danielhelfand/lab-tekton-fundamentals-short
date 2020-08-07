LAB - Tekton Fundamentals Short
===============================

This workshop helps teach the fundamentals of using [Tekton](https://github.com/tektoncd/pipeline) for CI/CD with Kubernetes. 
As of this time, it will only run on a Kubernetes cluster provisioned by [Tanzu Mission Control (TMC)](https://tanzu.vmware.com/mission-control?gclid=CjwKCAjw-YT1BRAFEiwAd2WRtqC0WthDAKNAPUQzJF0lMXKelEd1gUJhj4UM9wkHHBK-GXlPeIt99hoCZZIQAvD_BwE). The minimum Kubernetes version is v1.15.0 since Tekton itself requires this version.

This workshop is a shorter version of [another Tekton workshop](https://github.com/eduk8s-tests/lab-tekton-fundamentals), which takes about an hour to complete. Completing this version of the workshop should take about 30 minutes.

Prerequisites
-------------

A Kubernetes cluster v1.15.0 or higher provisioned by Tanzu Mission Control.

The eduk8s operator installed. For installation instructions for the eduk8s operator see:

* https://github.com/eduk8s/eduk8s-operator

Tekton must also be installed on your cluster hosting the workshop. You can install it using the following command:

```
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.15.0/release.yaml
```

Deployment
----------

You need to be a cluster admin to create the deployment using this method.

Deploy the workshop environment run:

```
kubectl apply -k github.com/eduk8s-tests/lab-tekton-fundamentals-short
```

The below command will output the URL to access the web portal for the training environment:

```
kubectl get trainingportal/lab-tekton-fundamentals
```

Deletion
--------

When you are finished with the workshop environment, you can delete it by running:

```
kubectl delete -k github.com/eduk8s-tests/lab-tekton-fundamentals-short
```
