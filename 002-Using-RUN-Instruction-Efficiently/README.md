# Lab 2: Using RUN Instruction Efficiently

## Objectives

By the end, you should be able to:

- Use the `RUN` instruction in shell and exec forms.
- Combine multiple operations in a single `RUN` command to minimize image layers.
- Inspect image history to understand layer usage and size impact.

## Prerequisites

To follow along, you should have:

- Podman or Docker installed on a Linux system (Ubuntu or CentOS is recommended).
- Basic understanding of image building with Docker or Podman.
- Internet access for downloading packages.

## Task 1: Understanding RUN Instruction Forms

### RUN in Shell Form

The shell form runs commands using a default shell (`/bin/sh -c`).

1. Create a file named `Dockerfile` with the following content:

   ```dockerfile
   FROM alpine:latest
   RUN apk add --no-cache curl
````

2. Now build the image:

   ```bash
   podman build -t run-lab-shell .
   ```

This will install `curl` in a new image layer.

---

### RUN in Exec Form

In the exec form, you write the command as a JSON array. This avoids shell interpretation issues.

Modify your `Dockerfile` like this:

```dockerfile
FROM alpine:latest
RUN ["/bin/sh", "-c", "apk add --no-cache curl"]
```

Then build it:

```bash
podman build -t run-lab-exec .
```

This also installs `curl`, but the difference lies in how the command is parsed and executed internally.

## Task 2: Combining Commands to Minimize Layers

Each `RUN` instruction creates a new image layer. To reduce image size and layer count, combine operations into a single `RUN`.

### Inefficient Dockerfile

```dockerfile
FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y nginx
RUN rm -rf /var/lib/apt/lists/*
```

This approach results in three separate layers.

### Optimized Dockerfile

```dockerfile
FROM ubuntu:latest
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*
```

This combines operations into a single layer, reducing size and build time.

To build the optimized image:

```bash
podman build -t optimized-nginx .
```

Check the image list:

```bash
podman images | grep -E 'optimized-nginx|run-lab-shell'
```

You should observe that the optimized image has fewer layers and a smaller size.

## Task 3: Verifying Layer Reduction

### Check Image Layers

Use the following command to view the image history:

```bash
podman history optimized-nginx
```

Only one `RUN` layer should appear for the combined operations.

### Compare Image Sizes

Run:

```bash
podman images
```

This lets you compare sizes of different builds to verify the impact of optimization.

## Troubleshooting

* **Permission Errors:** If you face permission-related issues during builds, try using the `--privileged` flag.
* **Stale Caches:** To force a clean build and ensure packages are up-to-date, use:

  ```bash
  podman build --no-cache -t optimized-nginx .
  ```
