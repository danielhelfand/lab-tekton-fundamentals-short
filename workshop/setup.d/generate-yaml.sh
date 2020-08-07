#!/bin/bash

cat tekton/pipelineresources/image.yaml.in | envsubst > tekton/pipelineresources/image.yaml
cat tekton/ingress/ingress.yaml.in | envsubst > tekton/ingress/ingress.yaml