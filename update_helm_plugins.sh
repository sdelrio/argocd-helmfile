#!/bin/bash

get_latest_release() {
# Usage
# get_latest_release user/project
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub API
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"v([^"]+)".*/\1/'                                    # Pluck JSON value
}

update_dockerfile() {
# Usage
# update_dockerfile ENVVAR VALUE
  if egrep -q "ARG $1=\"$2\"" Dockerfile; then
    echo "Update of $1=$2 not needed"
  else
    echo "Updating $1=$2"
    sed -i "s/ARG $1=.*/ARG $1=\"$2\"/" Dockerfile
  fi 
}

PLUGINS=(
    "databus23/helm-diff"
    "zendesk/helm-secrets"
    "hypnoglow/helm-s3"
    "mumoshu/helm-x"
    "aslafy-z/helm-git"
)

VERSIONS=(
    "HELM_DIFF_VERSION"
    "HELM_SECRETS_VERSION"
    "HELM_S3_VERSION"
    "HELM_X_VERSION"
    "HELM_GIT_VERSION"
)


counter=0
for p in ${PLUGINS[@]}; do 
    ENVVAR=${VERSIONS[$counter]}
#    echo $p  $ENVVAR
    RELEASE=$(get_latest_release ${p})
    if [ ! -z "${RELEASE}" ]; then
        echo ${p} latest release ${RELEASE}
        update_dockerfile ${ENVVAR} ${RELEASE}
    fi
    ((counter=counter + 1))
done
