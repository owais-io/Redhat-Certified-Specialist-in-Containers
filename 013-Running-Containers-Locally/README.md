# Running Containers Locally with Podman

## Objectives

- Run containers in both foreground (interactive) and detached (background) modes  
- Map container ports to host ports for web access  
- Persist container data using named volumes  
- Override user permissions at container runtime  
- Inspect and manage running containers  

## Prerequisites

Before you begin, ensure the following:

- A Linux system with **Podman 3.0+** installed  
- Basic knowledge of Linux command line operations  
- Internet access to pull container images from remote registries  

### Installation (If not already installed)

For CentOS/RHEL/Fedora:
```bash
sudo dnf install -y podman
````

For Ubuntu/Debian:

```bash
sudo apt-get install -y podman
```

To verify Podman is installed:

```bash
podman --version
```

## Task 1: Running Containers in Foreground and Background

### Subtask 1.1: Run a Container in Foreground

Let’s start with a simple NGINX container:

```bash
podman run --name foreground-container docker.io/library/nginx
```

This will launch the container and attach your terminal to it.
You should see NGINX logs appearing in the terminal.
To stop the container, press `Ctrl + C`.

### Subtask 1.2: Run a Container in Detached Mode

```bash
podman run -d --name background-container docker.io/library/nginx
```

Here, `-d` flag runs the container in the background (detached mode).
You’ll get the container ID in response. To verify it's running:

```bash
podman ps
```

## Task 2: Port Mapping and Volume Binding

### Subtask 2.1: Port Mapping

Let’s map container port `80` to your local system’s port `8080`:

```bash
podman run -d --name webapp -p 8080:80 docker.io/library/nginx
```

Now, access the NGINX welcome page using:

```bash
curl http://localhost:8080
```

This confirms that port mapping works and the container is accessible via the host.

### Subtask 2.2: Create and Use Persistent Volume

To persist data across container restarts:

1. Create a volume:

   ```bash
   podman volume create mydata
   ```

2. Run a container with the volume mounted:

   ```bash
   podman run -d --name vol-container -v mydata:/data docker.io/library/alpine tail -f /dev/null
   ```

3. Verify the mount:

   ```bash
   podman exec vol-container ls /data
   ```

## Task 3: User Management and Runtime Overrides

### Subtask 3.1: Run as Specific User

Try running a container as user ID `1000`:

```bash
podman run --rm -it --user 1000 docker.io/library/alpine whoami
```

This may return:

```
whoami: unknown uid 1000
```

Try using a known user like `nobody`:

```bash
podman run --rm -it --user nobody docker.io/library/alpine whoami
```

Expected output:

```
nobody
```

### Subtask 3.2: Inspect Containers

Check the configuration of your running container:

```bash
podman inspect webapp
```

View logs:

```bash
podman logs webapp
```

Check live resource usage:

```bash
podman stats
```

## Task 4: Cleanup

Stop all running containers:

```bash
podman stop -a
```

Remove all containers:

```bash
podman rm -a
```

(Optional) Remove the volume:

```bash
podman volume rm mydata
```

## Troubleshooting Tips

* If you face permission issues, try using the `--privileged` flag.

* For port conflicts, check which service is already using a port:

  ```bash
  ss -tulnp
  ```

* If a container exits immediately, check its logs:

  ```bash
  podman logs <container-name>
  ```