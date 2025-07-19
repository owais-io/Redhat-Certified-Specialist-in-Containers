# Container Volumes and Bind Mounts with Podman

Here, we will walk through the following:

- How to create and use named volumes
- How to use bind mounts with proper SELinux context
- How to fix permission-related issues for container access
- How to test and verify data persistence across container runs

## Prerequisites

Before you begin, ensure the following:

- Podman is installed (version 3.0+ recommended)
- SELinux is **enabled**
- You have basic Linux terminal knowledge
- You have `sudo` access for certain operations

## Setup

Install Podman:
```bash
sudo dnf install podman
````

Verify installation:

```bash
podman --version
```

## Task 1: Creating and Using Named Volumes

### Step 1.1: Create a Named Volume

```bash
podman volume create mydata_volume
```

Check if the volume was created:

```bash
podman volume ls
```

Expected:

```
DRIVER      VOLUME NAME
local       mydata_volume
```

### Step 1.2: Use Volume in a Container

```bash
podman run -d --name volume_test -v mydata_volume:/data docker.io/library/alpine sleep infinity
```

Verify the mount:

```bash
podman exec volume_test ls /data
```

### Step 1.3: Test Persistence

```bash
podman exec volume_test sh -c "echo 'Persistent Data' > /data/testfile"
podman stop volume_test
podman rm volume_test
podman run --name new_test -v mydata_volume:/data docker.io/library/alpine cat /data/testfile
```

Expected:

```
Persistent Data
```

## Task 2: Bind Mounts with SELinux Context

### Step 2.1: Create a Host Directory

```bash
mkdir ~/container_data
echo "Host file content" > ~/container_data/hostfile.txt
```

### Step 2.2: Mount with `:Z` Option

```bash
podman run -it --rm -v ~/container_data:/container_data:Z docker.io/library/alpine cat /container_data/hostfile.txt
```

Expected:

```
Host file content
```

### Step 2.3: Verify SELinux Label

```bash
ls -Z ~/container_data/hostfile.txt
```

Expected:

```
unconfined_u:object_r:container_file_t:s0 /home/user/container_data/hostfile.txt
```

## Task 3: Adjusting Host Directory Permissions

### Step 3.1: Create a Restricted Directory

```bash
sudo mkdir /restricted_data
sudo chmod 700 /restricted_data
sudo chown root:root /restricted_data
```

### Step 3.2: Test Access Without Adjustment

```bash
podman run -it --rm -v /restricted_data:/data docker.io/library/alpine touch /data/testfile
```

Expected:

```
Permission denied
```

### Step 3.3: Fix Permissions and SELinux

```bash
sudo chmod 755 /restricted_data
sudo chcon -t container_file_t /restricted_data
podman run -it --rm -v /restricted_data:/data:Z docker.io/library/alpine touch /data/testfile
```

Verify:

```bash
ls -lZ /restricted_data
```

## Task 4: Comprehensive Persistence Test

### Step 4.1: Run Combined Container

```bash
podman run -d --name persist_test -v mydata_volume:/data -v ~/container_data:/container_data:Z docker.io/library/alpine sleep infinity
```

### Step 4.2: Write Test Data

```bash
podman exec persist_test sh -c "echo 'Named Volume Data' >> /data/named.txt"
podman exec persist_test sh -c "echo 'Bind Mount Data' >> /container_data/bind.txt"
```

### Step 4.3: Verify Data Persisted

```bash
podman stop persist_test
podman rm persist_test
podman run --rm -v mydata_volume:/data docker.io/library/alpine cat /data/named.txt
cat ~/container_data/bind.txt
```

Expected Output:

```
Named Volume Data
Bind Mount Data
```

## Troubleshooting Tips

* **Permission Denied?**

  * Check SELinux mode: `getenforce`
  * Always use `:Z` on bind mounts
  * Verify directory permissions: `ls -lZ`

* **Volume Data Not Persisting?**

  * Check with: `podman volume ls` and `podman inspect <container>`

* **SELinux Errors?**

  * Review logs: `sudo ausearch -m avc -ts recent`
  * For testing only: `sudo setenforce 0` (use with caution)

## Cleanup

```bash
podman volume rm mydata_volume
podman rm -f $(podman ps -aq)
rm -rf ~/container_data
sudo rm -rf /restricted_data
```