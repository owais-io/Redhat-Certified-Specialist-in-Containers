# Inspecting Containers and Images with Podman

## Objectives

By the end, you will be able to:

- Use `podman inspect` to extract detailed information about containers and images.
- View and filter environment variables passed to a container.
- Review volume mount points and exposed network ports.
- Interpret container exit codes and state for troubleshooting.

## Prerequisites

To follow along, you will need:

- A Linux system with **Podman** installed (RHEL/CentOS/Fedora preferred)
- Basic knowledge of Linux terminal usage
- A running container to inspect (we’ll create one during the lab)

Install Podman if not already available:

```bash
sudo dnf install -y podman
```

Verify installation:

```bash
podman --version
```

Pull a lightweight image:

```bash
podman pull docker.io/library/nginx:alpine
```

## Lab Instructions

### Task 1: Inspecting Container and Image Metadata

#### 1.1 Basic Inspection

Start a container:

```bash
podman run -d --name my_nginx -p 8080:80 nginx:alpine
```

Inspect the container:

```bash
podman inspect my_nginx
```

Inspect the image:

```bash
podman inspect nginx:alpine
```

> Note: Container inspection shows the **runtime** state. Image inspection reveals the **static** configuration.

#### 1.2 Filter Specific Fields

Get only the container’s IP address:

```bash
podman inspect my_nginx --format '{{.NetworkSettings.IPAddress}}'
```

Get the container’s creation time:

```bash
podman inspect my_nginx --format '{{.Created}}'
```

### Task 2: Extracting Environment Variables

#### 2.1 View All Environment Variables

Start a container with custom environment variables:

```bash
podman run -d --name env_test -e APP_COLOR=blue -e APP_MODE=prod nginx:alpine
```

Inspect all environment variables:

```bash
podman inspect env_test --format '{{.Config.Env}}'
```

#### 2.2 Filter Specific Variable

Extract only the `APP_COLOR` value:

```bash
podman inspect env_test --format '{{range .Config.Env}}{{if eq (index (split . "=") 0) "APP_COLOR"}}{{.}}{{end}}{{end}}'
```

### Task 3: Reviewing Volume Mounts and Ports

#### 3.1 Inspect Volume Mounts

Create a container with a volume mount:

```bash
podman run -d --name vol_test -v /tmp:/container_tmp nginx:alpine
```

Inspect mounts:

```bash
podman inspect vol_test --format '{{.Mounts}}'
```

#### 3.2 Inspect Port Bindings

Check port bindings:

```bash
podman inspect my_nginx --format '{{.NetworkSettings.Ports}}'
```

Check the specific host port:

```bash
podman inspect my_nginx --format '{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}'
```

### Task 4: Analyzing Container Status and Exit Codes

#### 4.1 Inspect Exit Code of a Failed Container

Create a container that exits with a failure:

```bash
podman run --name fail_test alpine sh -c "exit 3"
```

Check its exit code:

```bash
podman inspect fail_test --format '{{.State.ExitCode}}'
```

> Tip: Non-zero exit codes often mean the container ran into a problem. Logs may help.

#### 4.2 Get Complete State Info

For a detailed state overview:

```bash
podman inspect my_nginx --format '{{json .State}}' | jq
```

> Note: `jq` is used to pretty-print JSON. You can install it with:
>
> ```bash
> sudo dnf install jq
> ```

## Cleanup

Once you're done, clean up all containers and the image:

```bash
podman stop my_nginx env_test vol_test
podman rm my_nginx env_test vol_test fail_test
podman rmi nginx:alpine
```