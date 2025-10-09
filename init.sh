#!/bin/bash

helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  -f argo-apps/gitlab/values.yaml \
  --version 9.4.1

helm upgrade --install gitlab-runner gitlab/gitlab-runner \
  --timeout 600s \
  -f argo-apps/gitlab-runner/values.yaml \
  --version 0.81.0