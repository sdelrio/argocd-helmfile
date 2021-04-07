#!/bin/bash

get_latest_release() {
# Usage
# get_latest_release user/project
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub API
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                   # Pluck JSON value
}

update_dockerfile() {
# Usage
# update_dockerfile ENVVAR VALUE
  if egrep -q "ARG $1=\"$2\"" Dockerfile; then
    echo "Update on $1=$2 not needed"
  else
    echo "Updating $1=$2"
    sed -i "s/ARG $1=.*/ARG $1=\"$2\"/" Dockerfile
  fi 
}

APPS=(
    "argoproj/argo-cd"
)

VERSIONS=(
    "VERSION"
)


counter=0
for a in ${APPS[@]}; do 
    ENVVAR=${VERSIONS[$counter]}
    RELEASE=$(get_latest_release ${a})


    if [ ! -z "${RELEASE}" ]; then
        echo ${p} latest release ${RELEASE}
        update_dockerfile ${ENVVAR} ${RELEASE}
    fi

    ((counter=counter + 1))
done
