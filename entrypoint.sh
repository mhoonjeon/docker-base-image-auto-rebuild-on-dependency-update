#!/bin/sh -l

#!/usr/bin/env bash
# inspired by https://medium.com/@SergeyNuzhdin/how-to-speed-up-builds-and-save-time-and-money-182f419b2be8
GH_USERNAME=$1
GH_PERSONAL_ACCESS_TOKEN=$2
ORGANIZATION_NAME=$3
IMAGE_NAME=$4
DOCKERFILE_PATH=$5
STAGE=$6

echo ${GH_PERSONAL_ACCESS_TOKEN} | docker login ghcr.io -u ${GH_USERNAME} --password-stdin

poetry_lock_hash="$(md5sum poetry.lock | cut -d' ' -f1)"
echo ${poetry_lock_hash}

curl  -H "Authorization: Bearer ${GH_PERSONAL_ACCESS_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/orgs/${ORGANIZATION_NAME}/packages/container/${IMAGE_NAME}/versions \
  | jq -c -r ".[].metadata.container.tags[]" | grep ${STAGE} | grep -q ${poetry_lock_hash}

# https://www.shell-tips.com/bash/if-statement/
# https://stackoverflow.com/questions/56170215/what-is-the-point-of-grep-q
# https://askubuntu.com/questions/892604/what-is-the-meaning-of-exit-0-exit-1-and-exit-2-in-a-bash-script
if [ $? -ne 0 ];
then
    CI_REGISTRY_IMAGE="ghcr.io/${ORGANIZATION_NAME}"
    tag=${CI_REGISTRY_IMAGE}/${IMAGE_NAME}:${STAGE}-base-${poetry_lock_hash}
    tag_latest=${CI_REGISTRY_IMAGE}/${IMAGE_NAME}:${STAGE}-base-latest
    #docker build -t ${tag} -f compose/common/${IMAGE_NAME}/${STAGE}-base.Dockerfile . --no-cache
    docker build -t ${tag} -f ${DOCKERFILE_PATH} . --no-cache
    docker push ${tag}
    docker tag ${tag} ${tag_latest}
    docker push ${tag_latest}
fi

echo "::set-output name=TAG::tag"
