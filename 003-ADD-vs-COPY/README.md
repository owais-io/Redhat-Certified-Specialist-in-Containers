# Understanding `ADD` vs `COPY` Instructions in Dockerfiles

## Objectives

- Understand when to use `COPY` vs `ADD`
- Observe `ADD`'s automatic archive extraction behavior
- Test `ADD`'s remote file download capability
- Compare caching behavior between both instructions
- Analyze the security implications of each instruction

## Prerequisites

Before beginning, make sure you have the following:

- Podman or Docker installed (Podman preferred for OpenShift compatibility)
- A working internet connection
- A text editor like Vim, Nano, or VS Code
- Basic familiarity with Dockerfile syntax and Linux shell commands

Install Podman if it's not installed:

```bash
# For RHEL/Fedora/CentOS:
sudo dnf install -y podman

# For Ubuntu/Debian:
sudo apt-get install -y podman
```

Verify the installation:

```bash
podman --version
```

Then, create your lab directory:

```bash
mkdir add_vs_copy_lab && cd add_vs_copy_lab
```

## Task 1: Basic `COPY` Instruction

This task will help you understand the basic and predictable file copying behavior of the `COPY` instruction.

```bash
echo "This is a test file for COPY instruction" > testfile.txt
```

Create `Dockerfile.copy`:

```Dockerfile
FROM alpine:latest
COPY testfile.txt /destination/
RUN cat /destination/testfile.txt
```

Build and run the container:

```bash
podman build -t copy-demo -f Dockerfile.copy .
podman run --rm copy-demo
```

You should see the file contents printed. `COPY` is simple and only works with local build context files. It does not extract archives or fetch URLs.

## Task 2: Basic `ADD` Instruction

This task shows that `ADD` can perform similar file copying.

Create `Dockerfile.add`:

```Dockerfile
FROM alpine:latest
ADD testfile.txt /destination/
RUN cat /destination/testfile.txt
```

Build and run:

```bash
podman build -t add-demo -f Dockerfile.add .
podman run --rm add-demo
```

The behavior is the same as `COPY` for plain file copying, but `ADD` comes with extra capabilities.

## Task 3: Archive Extraction Using `ADD`

Here, you'll see `ADD` automatically extract archives.

Create an archive:

```bash
tar -czf archive.tar.gz testfile.txt
```

Then write `Dockerfile.add-extract`:

```Dockerfile
FROM alpine:latest
ADD archive.tar.gz /extracted/
RUN ls -la /extracted/
RUN cat /extracted/testfile.txt
```

Build and run:

```bash
podman build -t add-extract-demo -f Dockerfile.add-extract .
podman run --rm add-extract-demo
```

You will notice that the tar archive is automatically extracted by `ADD`. This can be helpful but also opens the door to potential risks.

## Task 4: Fetching Remote URLs with `ADD`

In this task, `ADD` will be used to pull a remote file.

Create `Dockerfile.add-url`:

```Dockerfile
FROM alpine:latest
ADD https://raw.githubusercontent.com/moby/moby/master/README.md /remote/
RUN cat /remote/README.md
```

Build and run:

```bash
podman build -t add-url-demo -f Dockerfile.add-url .
podman run --rm add-url-demo
```

You will see the downloaded remote content. Be cautious: this introduces dependency on external resources and increases attack surface.

---

## Task 5: Caching Behavior of `COPY` and `ADD`

This task compares how each instruction interacts with Docker’s build cache.

```bash
echo "Version 1" > version.txt
```

Create `Dockerfile.cache`:

```Dockerfile
FROM alpine:latest
COPY version.txt /app/
RUN cat /app/version.txt
```

Build the image:

```bash
podman build -t cache-demo -f Dockerfile.cache .
```

Now change the file:

```bash
echo "Version 2" > version.txt
podman build -t cache-demo -f Dockerfile.cache .
```

Do the same with `ADD` and observe that both will invalidate cache if the file content changes.

## Task 6: Simulated Security Concern with Archive Extraction

This task simulates the risk of untrusted archives.

```bash
echo "malicious content" > badfile
tar -czf bad.tar.gz badfile
```

Create `Dockerfile.security`:

```Dockerfile
FROM alpine:latest
ADD bad.tar.gz /malicious/
RUN find /malicious -type f
```

Build and run:

```bash
podman build -t security-demo -f Dockerfile.security .
podman run --rm security-demo
```

This illustrates that `ADD` will automatically extract the contents, even when they are potentially unsafe. Prefer `COPY` to avoid this behavior unless extraction is explicitly desired.

## Troubleshooting

* Use `sudo setenforce 0` if SELinux causes permission errors.
* Use `--no-cache` flag with `podman build` to force rebuilds.
* For URL issues in `ADD`, check connectivity and the file’s availability.
* For more control with remote files, prefer `RUN curl` or `wget` instead of `ADD`.

## Cleanup

To remove all test artifacts:

```bash
podman rmi copy-demo add-demo add-extract-demo add-url-demo cache-demo security-demo
rm -f testfile.txt archive.tar.gz badfile bad.tar.gz version.txt
```

## Summary

* Use `COPY` when you only need to copy local files—it's safe, simple, and predictable.
* Use `ADD` *only* when you need to extract archives or fetch remote files.
* Be aware of the security implications when using `ADD`.
* Both instructions impact Docker’s caching behavior in similar ways.
