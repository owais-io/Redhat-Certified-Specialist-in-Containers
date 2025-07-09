# Setting `WORKDIR` and Running as Non-Root User

## Objectives

- Set up the working directory using `WORKDIR`
- Add a non-root user and switch to it using `USER`
- Validate file ownership and process context
- Analyze how these choices affect container security

## Prerequisites

To follow along, make sure:

- Podman or Docker is installed (`podman` is preferred for OpenShift compatibility)
- You're working on a Linux/Unix system (or WSL2 if on Windows)
- You are familiar with the basics of containers and Dockerfiles

## Lab Setup

First, verify your Podman installation:

```bash
podman --version
```

Then create a working directory for this lab:

```bash
mkdir container-security-lab && cd container-security-lab
```

---

## Task 1: Set the Working Directory

### Step 1.1: Create the Containerfile

Start by creating a new `Containerfile`:

```bash
touch Containerfile
```

And add the following content:

```Dockerfile
FROM registry.access.redhat.com/ubi9/ubi-minimal
LABEL maintainer="Your Name <your.email@example.com>"
WORKDIR /app
RUN pwd > /tmp/workdir.log && whoami >> /tmp/workdir.log
```

### Step 1.2: Build and Verify

Build the image:

```bash
podman build -t workdir-demo .
```

Now check what the container logs say about the working directory and user:

```bash
podman run --rm workdir-demo cat /tmp/workdir.log
```

Expected output:

```
/app
root
```

> The `WORKDIR` sets the default directory for subsequent instructions and container runtime execution.

---

## Task 2: Create and Use a Non-Root User

### Step 2.1: Modify the Containerfile

Edit the Containerfile to install tools and create a non-root user:

```Dockerfile
RUN microdnf install shadow-utils && \
    useradd -u 1001 -d /home/appuser -m appuser && \
    chown -R appuser:appuser /app
USER appuser
RUN whoami >> /tmp/user.log && ls -ld /app >> /tmp/user.log
```

### Step 2.2: Build and Verify

Rebuild the image:

```bash
podman build -t nonroot-demo .
```

Then verify the user and ownership:

```bash
podman run --rm nonroot-demo cat /tmp/user.log
```

Expected output:

```
appuser
drwxr-xr-x 2 appuser appuser 6 Mar 1 12:00 /app
```

> Switching to a non-root user improves security by restricting container permissions.

---

## Task 3: Security Validation

### Step 3.1: Attempt Restricted Operation

Try accessing a kernel file that’s usually not allowed:

```bash
podman run --rm nonroot-demo touch /sys/kernel/profiling
```

Expected result:

```
touch: cannot touch '/sys/kernel/profiling': Permission denied
```

### Step 3.2: Check User Context

Start a long-running container:

```bash
podman run -d --name testuser nonroot-demo sleep 300
```

Then inspect running processes:

```bash
podman exec testuser ps -ef
```

Expected output:

```
UID        PID  ...
appuser      1  ...
```

> All processes should now be owned by `appuser`, not root.

---

## Task 4: Analyzing the Security Impact

Let’s compare by running both containers:

```bash
podman run --rm --user root workdir-demo whoami
podman run --rm nonroot-demo whoami
```

Difference:

* `root` user has access to system-level files and devices
* `appuser` is limited to what is owned or permitted

> Always prefer running containers with the minimum privileges required.

---

## Cleanup

To remove the created images and temporary files:

```bash
podman rmi workdir-demo nonroot-demo
rm -rf container-security-lab
```