# Understanding the FROM Instruction in Container Builds

## Prerequisites

Before beginning, make sure:

- You have Podman installed:
  
  ```bash
  podman --version
  ```

Expected output:

```
podman version 3.4.4
```

* You’ve created a working directory for this lab:

  ```bash
  mkdir from-lab && cd from-lab
  ```

## Task 1: Understanding the FROM Instruction

### What is the FROM Instruction?

The `FROM` instruction is the first line in any `Containerfile` or `Dockerfile`. It sets the base image for your container and acts as the foundation upon which all other commands operate. This instruction determines the environment inside your container and can point to any valid image—official or custom, local or remote.

### Why Base Image Selection Matters

When selecting a base image, consider the following:

* **Size**: Alpine is lightweight, while Ubuntu is more comprehensive.
* **Security**: Official images are safer than unverified community ones.
* **Maintenance**: Choose images that are regularly updated and patched.
* **Compatibility**: Make sure the architecture and OS suit your application needs.

## Task 2: Selecting and Pinning a Base Image

### Finding Red Hat UBI Images

You can search for official Red Hat UBI (Universal Base Images) with:

```bash
podman search registry.access.redhat.com/ubi8
```

### Inspecting Image Metadata

To inspect image tags and digests:

```bash
skopeo inspect docker://registry.access.redhat.com/ubi8/ubi:latest
```

> If `skopeo` is not installed, install it using:
>
> ```bash
> sudo dnf install skopeo
> ```

### Pinning a Specific Image Version

Avoid using `latest`—always pin the image version:

```bash
podman pull registry.access.redhat.com/ubi8/ubi:8.7
```

Pinning ensures consistent builds and better reproducibility across environments.

## Task 3: Writing and Building a Containerfile

### Creating a Containerfile

First, create an empty file named `Containerfile`:

```bash
touch Containerfile
```

Add the following content:

```Dockerfile
# Use a pinned UBI 8 image
FROM registry.access.redhat.com/ubi8/ubi:8.7

# Set a label
LABEL maintainer="your.email@example.com"

# Run a simple command
RUN echo "Base image successfully set up" > /tmp/status.txt
```

### Building the Image

To build the image:

```bash
podman build -t my-base-image .
```

After the build completes, list images to verify:

```bash
podman images
```

### Running and Testing the Image

To verify the image and check the status file:

```bash
podman run --rm my-base-image cat /tmp/status.txt
```

Expected output:

```
Base image successfully set up
```

## Troubleshooting

* **Image Not Found**: Double-check the image name and tag.
* **Build Fails**: Look for typos or syntax issues in the Containerfile.
* **Permission Errors**: Either use root or configure rootless Podman correctly.
* **Cache Issues**: Use `--no-cache` during build to force fresh steps.

## Cleanup

To remove the built image:

```bash
podman rmi my-base-image
```

To remove all unused images:

```bash
podman image prune -a
```
