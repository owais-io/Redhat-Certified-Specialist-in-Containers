# Backup and Restore Images and Containers with Podman

By the end, you will be able to:

- Backup and restore container **images** using tarball files  
- Save the **state** of a running container into a new image  
- Understand the **limitations** of `save`, `load`, and `commit` operations  

## Prerequisites

- A Linux system with Podman installed (RHEL 8+, CentOS 8+, Fedora recommended)  
- Podman version **3.x.x** or higher  
- At least **1 GB** of free disk space  
- Internet access (for pulling images)  
- Basic familiarity with containers and Podman commands  

Check your Podman version:
```bash
podman --version
````

## Lab Setup

First, let’s pull a simple image to work with:

```bash
podman pull docker.io/library/alpine:latest
```

List available images:

```bash
podman images
```

Take note of the image reference or image ID of Alpine.

## Task 1: Save an Image to Tarball

To create a portable backup of the Alpine image:

```bash
podman save -o alpine_backup.tar docker.io/library/alpine:latest
```

Now confirm the backup file was created:

```bash
ls -lh alpine_backup.tar
file alpine_backup.tar
```

You should see a `.tar` file around **8 MB** in size.

## Task 2: Load an Image from Tarball

Let’s simulate restoring this image.

First, remove the original image:

```bash
podman rmi docker.io/library/alpine:latest
```

Then, load the image back:

```bash
podman load -i alpine_backup.tar
```

Verify:

```bash
podman images
```

Your Alpine image should appear again, with the same tag and layers as before.

## Task 3: Commit a Container to New Image

Run a container and make some changes inside it:

```bash
podman run -it --name myalpine docker.io/library/alpine:latest /bin/sh
```

Inside the container:

```sh
touch /testfile
echo "Lab 12" > /testfile
exit
```

Now commit the container:

```bash
podman commit myalpine my_custom_alpine:v1
```

Verify the new image:

```bash
podman images
podman run --rm my_custom_alpine:v1 cat /testfile
```

Output should be:

```
Lab 12
```

## Task 4: Understanding Limitations

### Tarball Portability

* Images are architecture-specific
  For example, saving an image on **x86\_64** will not work on **ARM** systems.

### Commit Limitations

* `podman commit` does **not** preserve:

  * Running processes
  * Attached volumes
  * Network configurations

Check more limitations:

```bash
podman commit --help | grep -A5 "Limitations"
```

### Disk Space

* Saving and committing images uses additional disk space
  Check your container storage usage:

```bash
podman system df
```

## Summary

In this repo, you have:

* Used `podman save` and `podman load` for image-level backups and restoration
* Created a new image from a running container using `podman commit`
* Understood when to use these tools, and their limitations

## Cleanup (Optional)

To remove everything created in this lab:

```bash
podman rm -a
podman rmi -a
rm alpine_backup.tar
```

## 🧠 Knowledge Check

| Question                                                         | Answer                                                                                                                          |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| What's the difference between `podman save` and `podman export`? | `save` works with **images** (preserves layers and metadata), `export` works with **containers** (exports the filesystem only). |
| How would you verify the integrity of a saved tarball?           | Use a checksum: `sha256sum alpine_backup.tar`                                                                                   |
| When would you choose `commit` over building with a Dockerfile?  | When you need to preserve the **runtime state** or when no Dockerfile is available.                                             |
