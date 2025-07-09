# Securing Container Images with Least Privilege

## Objectives

By following this lab, you will:

- Scan images for known vulnerabilities
- Clean up package caches to reduce image size and surface area
- Use smaller, minimal base images like Alpine
- Build and run containers as non-root users
- Sign and verify images to ensure provenance

## Prerequisites

Before you start, make sure the following requirements are met:

- A Linux system with Podman (version 3.0 or newer)
- Internet access to pull container images
- Basic knowledge of how containers work
- `sudo` privileges on your system

## Lab Setup

Start by verifying that Podman is installed:

```bash
podman --version
```

You should see output similar to:

```text
podman version 3.4.4
```

Now, create a directory to hold your lab files:

```bash
mkdir secure_lab && cd secure_lab
```

## Task 1: Scan Images for Vulnerabilities

### 1.1 Pull the Sample Image

```bash
podman pull docker.io/library/nginx:latest
```

### 1.2 Scan the Image

```bash
podman scan nginx:latest
```

You will get a vulnerability report listing CVEs with severity levels. This helps you evaluate how safe the image is.

### 1.3 Read the Results

Look for:

* Critical vulnerabilities (CVSS ≥ 9.0)
* High vulnerabilities (CVSS 7.0–8.9)
* Affected package names and versions

## Task 2: Remove Package Caches

Let’s reduce the image size and remove unnecessary package caches.

### 2.1 Write a Dockerfile

Create a file called `Dockerfile.clean`:

```dockerfile
FROM docker.io/library/nginx:latest

# Remove cache directories
RUN rm -rf /var/cache/apt/* /var/lib/apt/lists/*
```

### 2.2 Build the Image

```bash
podman build -f Dockerfile.clean -t nginx_clean .
```

### 2.3 Check Image Size

```bash
podman images
```

Compare this size with the original image.

## Task 3: Use Minimal Base Images

Now let's rebuild the image using Alpine, which is much smaller than Debian-based images.

### 3.1 Create Dockerfile with Alpine Base

Create a file called `Dockerfile.alpine`:

```dockerfile
FROM docker.io/library/alpine:latest

RUN apk add --no-cache nginx && \
    rm -rf /var/cache/apk/*
```

### 3.2 Build and Compare

```bash
podman build -f Dockerfile.alpine -t nginx_alpine .
podman images | grep nginx
```

You should see that the Alpine-based image is significantly smaller.

## Task 4: Run Containers as Non-Root Users

Let’s enforce least privilege by avoiding the use of the `root` user inside containers.

### 4.1 Add a Non-Root User in Dockerfile

Create `Dockerfile.nonroot`:

```dockerfile
FROM docker.io/library/alpine:latest

RUN apk add --no-cache nginx && \
    adduser -D nginxuser && \
    chown -R nginxuser:nginxuser /var/lib/nginx

USER nginxuser
```

### 4.2 Build and Run the Container

```bash
podman build -f Dockerfile.nonroot -t nginx_nonroot .
podman run -d --name secure_nginx -p 8080:80 nginx_nonroot
```

### 4.3 Verify Process Ownership

```bash
podman exec secure_nginx ps aux
```

Expected: All nginx processes should be running under `nginxuser`, not root.

## Task 5: Implement Image Provenance

Let’s sign the image so we can later verify its authenticity.

### 5.1 Sign the Image

> You must have GPG set up. Run `gpg --gen-key` first if you haven't already.

```bash
podman image sign --sign-by your@email.com nginx_nonroot
```

### 5.2 Verify the Signature

```bash
podman image trust show
```

You should see your signed image listed in the trust store.

## Cleanup

To remove containers and images created in this lab:

```bash
podman stop secure_nginx
podman rm secure_nginx
podman rmi nginx nginx_clean nginx_alpine nginx_nonroot
```

## Summary

Here, you learned:

* How to **scan container images** for security flaws
* How to **reduce image size** and surface area by clearing caches
* The importance of **using minimal base images** like Alpine
* How to **run containers with non-root users** for better isolation
* How to **sign and verify images** for provenance and trust

These practices help secure your containerized applications in real-world production setups by following the principle of least privilege.