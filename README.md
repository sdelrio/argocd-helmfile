![master status](https://github.com/sdelrio/argocd-helmfile/actions/workflows/main.yml/badge.svg)

# argocd-helmfile

Auto build image for ArgoCD with Helmfile + SOPS, folowing:

https://hackernoon.com/how-to-handle-kubernetes-secrets-with-argocd-and-sops-r92d3wt1
https://github.com/chatwork/dockerfiles/tree/master/argocd-helmfile

# Tools added to the image

| Tool  | Small description|
|-------|------------------|
| [SOPS](https://github.com/mozilla/sops) | Secret management using PGP  |
| [Helm Diff](https://github.com/databus23/helm-diff) | |
| [Helm Secrets](https://github.com/zendesk/helm-secrets ) | allow helm to use secrets, in our case from SOPS |
| [Helm S3](https://github.com/hypnoglow/helm-s3.git) | Allow to set up a chart repository in S3 |
| [Helm X](https://github.com/mumoshu/helm-x) |  Treat any Kustomization or K8s manifests directory as a Helm chart |
| [Helm git](https://github.com/hypnoglow/helm-s3.git) | Use helm charts through git repositories |
| [Helmfile](https://github.com/roboll/helmfile) | Deploy Kubernetes Helm Charts |

