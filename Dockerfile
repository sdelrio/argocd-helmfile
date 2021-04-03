ARG VERSION="v1.8.7"
FROM argoproj/argocd:${VERSION}

LABEL version="argo1.8.7-sops3.7.0-helmfile0.138.7"

ARG SOPS_VERSION="v3.7.0"
ARG SOPS_PGP_FP="1234567890ABCDEF123467890ABCDEF123456789"

ARG HELMFILE_VERSION="v0.138.7"

ARG HELM_VERSION="v3.5.3"
ARG HELM_DIFF_VERSION="3.1.3"
ARG HELM_SECRETS_VERSION="2.0.3"
ARG HELM_S3_VERSION="0.10.0"
ARG HELM_X_VERSION="0.8.1"
ARG HELM_GIT_VERSION="0.10.0"
ARG HELM_LOCATION="https://get.helm.sh"
ARG HELM_FILENAME="helm-${HELM_VERSION}-linux-amd64.tar.gz"
ARG HELM_EXTRA_VERSION="v3.4.2"
ARG HELM_EXTRA_FILENAME="helm-${HELM_EXTRA_VERSION}-linux-amd64.tar.gz"

ARG KUBECTL_VERSION=1.19.8


ENV SOPS_PGP_FP=${SOPS_PGP_FP}


USER root  
RUN apt-get update && \
    apt-get install -y \
        curl \
        gpg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # sops
    curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux && \
    # kubectl
    curl -o /usr/local/bin/kubectl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \ 
    # helm
    curl -OL ${HELM_LOCATION}/${HELM_FILENAME} && \
    echo Extracting ${HELM_FILENAME}... && \
    tar zxvf ${HELM_FILENAME} && mv ./linux-amd64/helm /usr/local/bin/ && \
    rm ${HELM_FILENAME} && rm -r ./linux-amd64 && \
    # helm extra version
    curl -OL ${HELM_LOCATION}/${HELM_EXTRA_FILENAME} && \
    echo Extracting ${HELM_EXTRA_FILENAME}... && \
    tar zxvf ${HELM_EXTRA_FILENAME} && mv ./linux-amd64/helm /usr/local/bin/helm-${HELM_EXTRA_VERSION} && \
    rm ${HELM_EXTRA_FILENAME} && rm -r ./linux-amd64 && \
    # helmfile
    curl -o /usr/local/bin/helmfile -L https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64 && \
    # Make sure binaries downloaded are exectuable
    chmod +x /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helmfile && \
    chmod +x /usr/local/bin/sops         

# helm plugins should be installed as user argocd or it won't be found
USER argocd
RUN helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION} && \
    helm plugin install https://github.com/zendesk/helm-secrets --version ${HELM_SECRETS_VERSION} && \
    helm plugin install https://github.com/hypnoglow/helm-s3.git --version ${HELM_S3_VERSION} && \
    helm plugin install https://github.com/mumoshu/helm-x --version ${HELM_X_VERSION} && \
    helm plugin install https://github.com/aslafy-z/helm-git.git --version ${HELM_GIT_VERSION}

