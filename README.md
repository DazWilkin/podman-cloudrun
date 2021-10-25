# Issues deploying Podman built images to Cloud Run

## GCP preamble

```bash
BILLING=...
PROJECT=...
REGION=...
REPO=...
GXR="${REGION}-docker.pkg.dev/${PROJECT}/${REPO}"
TAG="$(git rev-parse HEAD)"

gcloud projects create ${PROJECT}
gcloud beta billing projects link ${PROJECT} \
--billing-account=${BILLING}

gcloud services enable run.googleapis.com --project=${PROJECT}
gcloud services enable artifactregistry.googleapis.com --project=${PROJECT}

gcloud artifacts repositories create ${REPOSITORY} \
--location=${REGION} \
--repository-format=docker \
--project=${PROJECT}
```

## Docker

```bash
gcloud auth print-access-token \
| docker login \
  --username=oauth2accesstoken \
  --password-stdin \
  ${REGION}-docker.pkg.dev

docker build \
--tag=${GXR}/test:${TAG} \
--file=./Dockerfile \
.

docker push ${GXR}/test:${TAG}}
 
gcloud run deploy test \
--max-instances=1 \
--platform=managed \
--ingress=all \
--allow-unauthenticated \
--image=${GXR}/test:${TAG} \
--project=${PROJECT} \
--region=${REGION}
``` 

Manifest:

```JSON
{
   "schemaVersion": 2,
   "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
   "config": {
      "mediaType": "application/vnd.docker.container.image.v1+json",
      "size": 2170,
      "digest": "sha256:f783d5105f86039f7b1e4be4b6098ec825c6b5bd691c9895a96ada45b8bc7948"
   },
   "layers": [
      {
         "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
         "size": 3353027,
         "digest": "sha256:2ee6e5a95ffd776c838173760a9e26b8928af254de26ffa46239a8784d230cb6"
      },
      {
         "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
         "size": 506,
         "digest": "sha256:8c8d35748333119603266ea2ce97e88340292e457b0f55d01ed6ddc05b9388d3"
      }
   ]
}
```

## Podman

```bash
gcloud auth print-access-token \
| podman login \
  --username=oauth2accesstoken \
  --password-stdin \
  ${REGION}-docker.pkg.dev

podman build \
--tag=${GXR}/test:${TAG}} \
--file=./Dockerfile \
.

podman push ${GXR}/test:${TAG}
 
gcloud run deploy test \
--max-instances=1 \
--platform=managed \
--ingress=all \
--allow-unauthenticated \
--image=${GXR}/test:${TAG} \
--project=${PROJECT} \
--region=${REGION}
```

Fails:

```console
ERROR: (gcloud.run.deploy) Image '${GXR}/test:${TAG}' not found.
```

But:

```bash
gcloud artifacts docker tags list ${GXR}/test \
--format="value(tag)"
```
Yields:

```
be0d7950c65509e8eec7d95ee29c02f8c5ce0343
```

Manifest:

```JSON
{
   "schemaVersion": 2,
   "config": {
      "mediaType": "application/vnd.oci.image.config.v1+json",
      "digest": "sha256:c5b7c280249c63bca3ba83a7852d7390000dc6a8a8c53cd3e062f6de666c2c00",
      "size": 1252
   },
   "layers": [
      {
         "mediaType": "application/vnd.oci.image.layer.v1.tar+gzip",
         "digest": "sha256:fbbe5ec849096cd0a717b9dffac72feff3c726904f5c97d915033c1f3d0aa080",
         "size": 3416701
      },
      {
         "mediaType": "application/vnd.oci.image.layer.v1.tar+gzip",
         "digest": "sha256:ff1530fdc3b761a80710ba1fa297d8e49a08d8ba741233b961ec7203e398aed9",
         "size": 528
      }
   ],
   "annotations": {
      "org.opencontainers.image.base.digest": "sha256:4c2bc00a54eca50b19c362ad7ad661533a9a7faddb56f05e786389978ab48ed5",
      "org.opencontainers.image.base.name": ""
   }
}
```
