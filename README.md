# docker-base-image-auto-rebuild-on-dependency-update

This action builds new docker base image, if python dependencies defined in (poetry.lock) are updated. It is heavily
inspired by [How to speed up builds and save time and money](https://medium.com/@SergeyNuzhdin/how-to-speed-up-builds-and-save-time-and-money-182f419b2be8).

I use this package for our Github organization's container registry.

## Inputs

### `GH_USERNAME`

**Required** Github username.

### `GH_PERSONAL_ACCESS_TOKEN`

**Required** Github personal access token to authenticate for github container registry.

### `ORGANIZATION_NAME`

**Required** Organization name for your container registry.

### `IMAGE_NAME`

**Required** Name of the docker image.

### `DOCKERFILE_PATH`

**Required** File path for the Dockerfile

### `STAGE`

**Required** Stage for Dockerfile. Can either be `dev` or `prod`

## Outputs

### `TAG`

Name of the image tag.

## Example usage

```
uses: actions/docker-base-image-auto-rebuild-on-dependency-update@v1
with:
  GH_USERNAME: 'my_username'
  GH_PERSONAL_ACCESS_TOKEN: '293jca0239293.....'
  ORGANIZATION_NAME: 'my_organization'
  IMAGE_NAME: 'django'
  DOCKERFILE_PATH: 'docker/images/local/Dockerfile.base'
  STAGE: 'dev'  # or 'prod'
```