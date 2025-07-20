# Image Tagging and Registry Interaction

You will learn how to:

- Tag images using semantic versioning
- Authenticate to public or private registries
- Push and pull container images
- Understand image digests and tag immutability

## Prerequisites

Before you begin, ensure you have the following:

- Podman installed (version 3.0 or later)
- A Docker Hub account (or access to a private registry)
- Internet access
- Basic knowledge of Linux CLI

## Task 1: Tagging Images Semantically

To begin, list the images on your system:

```bash
podman images
```

Now tag an image using semantic versioning (vMAJOR.MINOR.PATCH). For example:

```bash
podman tag docker.io/library/nginx my-nginx:v1.0
```

You can verify the new tag with:

```bash
podman images | grep nginx
```

> Tip: Semantic versioning helps you manage image versions more clearly and predictably in production environments.

## Task 2: Logging into a Registry

To push or pull from a registry, you need to authenticate first. For Docker Hub, run:

```bash
podman login docker.io
```

You'll be prompted to enter your Docker Hub username and password.

To verify the login:

```bash
podman info | grep -A 5 "registries"
```

> If using a private registry, replace `docker.io` with your registry's URL.

## Task 3: Pushing Images to Registry

Before pushing an image, it must be tagged with the registry path:

```bash
podman tag my-nginx:v1.0 docker.io/<your_username>/my-nginx:v1.0
```

Then push the image:

```bash
podman push docker.io/<your_username>/my-nginx:v1.0
```

Check Docker Hub’s web UI to verify the image has been uploaded.

## Task 4: Pulling Images from Registry

To test image retrieval, first remove the local copy:

```bash
podman rmi docker.io/<your_username>/my-nginx:v1.0
```

Then pull the image again:

```bash
podman pull docker.io/<your_username>/my-nginx:v1.0
```

Confirm it has been re-downloaded:

```bash
podman images
```

> Tags can be updated over time, but the actual image associated with a specific digest never changes.

## Task 5: Understanding Tag Immutability and Digests

To inspect the image digest (immutable identifier):

```bash
podman inspect --format '{{.Digest}}' docker.io/<your_username>/my-nginx:v1.0
```

To pull an image by its digest:

```bash
podman pull docker.io/<your_username>/my-nginx@<digest>
```

Now push a new image using the same tag (e.g., `v1.0`) and observe how the digest changes, even though the tag name remains the same.

> This demonstrates that **tags are mutable**, but **digests are not**. Always prefer digests in production for guaranteed immutability.

## Cleanup

To remove all images created or used during this lab:

```bash
podman rmi -f $(podman images -q)
```

> This will delete **all** local images. Use with caution.