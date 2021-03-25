#!/bin/sh -l

#!/usr/bin/env bash
# inspired by https://medium.com/@SergeyNuzhdin/how-to-speed-up-builds-and-save-time-and-money-182f419b2be8
GH_USERNAME=$1
GH_PERSONAL_ACCESS_TOKEN=$2
ORGANIZATION_NAME=$3
CONTAINER_NAME=$4

echo ${GH_PERSONAL_ACCESS_TOKEN} | docker login ghcr.io -u ${GH_USERNAME} --password-stdin

poetry_lock_hash="$(md5sum poetry.lock | cut -d' ' -f1)"
echo ${poetry_lock_hash}

curl  -H "Authorization: Bearer ${GH_PERSONAL_ACCESS_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/orgs/${ORGANIZATION_NAME}/packages/container/${CONTAINER_NAME}/versions \
  | jq -c -r ".[].metadata.container.tags[]" | grep -q ${poetry_lock_hash}

if [ $? -ne 0 ]; then
#if [ $? -eq 0 ]; then
    CI_REGISTRY_IMAGE="ghcr.io/${ORGANIZATION_NAME}"
    STAGE="dev"
    tag=${CI_REGISTRY_IMAGE}/${CONTAINER_NAME}:${STAGE}-base-${poetry_lock_hash}
    tag_latest=${CI_REGISTRY_IMAGE}/${CONTAINER_NAME}:${STAGE}-base-latest
    docker build -t ${tag} -f compose/common/${CONTAINER_NAME}/${STAGE}-base.Dockerfile .
    docker push ${tag}
    docker tag ${tag} ${tag_latest}
    docker push ${tag_latest}

    STAGE="staging"
    staging_tag=${CI_REGISTRY_IMAGE}/django:${STAGE}-base-${poetry_lock_hash}
    staging_tag_latest=${CI_REGISTRY_IMAGE}/django:${STAGE}-base-latest
    # staging uses same Dockerfile as production
    docker build -t ${staging_tag} -f compose/common/django/prod-base.Dockerfile .
    docker push ${staging_tag}
    docker tag ${staging_tag} ${staging_tag_latest}
    docker push ${staging_tag_latest}

    # also tag and push production as it is same as staging
    STAGE="prod"
    prod_tag=${CI_REGISTRY_IMAGE}/django:${STAGE}-base-${poetry_lock_hash}
    prod_tag_latest=${CI_REGISTRY_IMAGE}/django:${STAGE}-base-latest
    docker tag ${staging_tag_latest} ${prod_tag}
    docker push ${prod_tag}
    docker tag ${staging_tag_latest} ${prod_tag_latest}
    docker push ${prod_tag_latest}
fi

echo "::set-output name=TAG::tag"
