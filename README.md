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
| [Helm git](https://github.com/aslafy-z/helm-git) | Use helm charts through git repositories |
| [Helmfile](https://github.com/roboll/helmfile) | Deploy Kubernetes Helm Charts |

# Requirements

## GPG key k8s secret into argocd namespace

Upload key to k8s with sample script in this repo. Make sure your secrets.yaml has this key included so it can be decrypted.

```bash
$ ./argo-gpg-key.sh 1234566789ABFCDEF
```

## Mount secret as vlume

Make sure repoServer has `SOPS_PGP_FP` key defined and private secret key mounted as volume
```yaml
  env:
    - name: "SOPS_PGP_FP"
      value: "<YOUR_GPG_KEY_HERE>"

  volumeMounts:
    - name: "gpg-asc"
      mountPath: "/home/argocd/gpg"
      readOnly: true
  volumes:
    - name: "gpg-asc"

```

## ArgoCD server plugin config helmfilesops

```yaml
server:
  config:
    configManagementPlugins: |
      - name: helmfilesops
        init:
          command: ["/usr/bin/gpg"]
          args: ["--import", "/home/argocd/gpg/gpg.asc"]
        generate:
          command: ["/bin/sh", "-c"]
          args: ["helmfile template $HELMFILE_OPTS"]

```


## Defined app App with plugin helmfilesops

```yaml
apiVersion:  argoproj.io/v1alpha1
kind:  Application
metadata:  
  name:  testapp
  namespace: argocd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:  
  project: default
  source:  
    repoURL: 'https://github.com/youruser/yourrepo.git'
    targetRevision: master
    path: k8s-charts
    plugin:
      name: helmfilesops
#      env:
#        - name: HELMFILE_OPTS
#          value: "--environment xxx -l key=value"
        
  destination:  
    server:  https://kubernetes.default.svc
    namespace: testapp
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

