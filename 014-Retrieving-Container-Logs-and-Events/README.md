# Retrieving Container Logs and Events with Podman

## Objectives

- View and filter container logs using Podman
- Monitor and analyze container lifecycle events
- Configure alternative log drivers like `json-file` and `journald`
- Use logs and events for effective troubleshooting

## Prerequisites

Before you begin:

- Podman installed (version 3.0+ recommended)
- Basic Linux command-line knowledge
- A running container (we will create one during the lab)

To verify Podman installation:

```bash
podman --version
````

Pull a base image to work with:

```bash
podman pull docker.io/library/nginx:alpine
```

## Task 1: Viewing Container Logs

### 1.1 Basic Log Viewing

Run the container in detached mode:

```bash
podman run -d --name nginx-container docker.io/library/nginx:alpine
```

To view the logs of the running container:

```bash
podman logs nginx-container
```

This will show the standard NGINX startup logs.

### 1.2 Follow Logs in Real-Time

To stream logs live as they are written:

```bash
podman logs --follow nginx-container
```

Press `Ctrl+C` to stop following the logs.

### 1.3 Filter Logs by Time

To see logs from the last 5 minutes:

```bash
podman logs --since 5m nginx-container
```

To view logs from a specific time range:

```bash
podman logs --since 2023-01-01T00:00:00 --until 2023-01-01T12:00:00 nginx-container
```

## Task 2: Configuring Alternative Log Drivers

### 2.1 JSON File Logging

Run a container using the `json-file` log driver:

```bash
podman run -d --name json-logger --log-driver json-file docker.io/library/nginx:alpine
```

To verify the location of the log file:

```bash
podman inspect --format '{{.HostConfig.LogConfig.Path}}' json-logger
```

### 2.2 Journald Logging

Run the container with `journald` log driver:

```bash
podman run -d --name journald-logger --log-driver journald docker.io/library/nginx:alpine
```

To view the logs through the system journal:

```bash
journalctl CONTAINER_NAME=journald-logger
```

## Task 3: Monitoring Container Events

### 3.1 Basic Event Monitoring

Open a terminal and start monitoring events:

```bash
podman events --format "{{.Time}} {{.Type}} {{.Status}}"
```

Then in another terminal, create a new container:

```bash
podman run -d --name event-test docker.io/library/nginx:alpine
```

You will see creation and start events in the first terminal.

### 3.2 Filtering Events

To filter only start events:

```bash
podman events --filter event=start
```

To filter events for a specific container:

```bash
podman events --filter container=event-test
```

To filter by event type and time:

```bash
podman events --filter event=die --since 1h
```

## Task 4: Troubleshooting with Logs and Events

### 4.1 Analyze a Failing Container

Create a container that will fail to start:

```bash
podman run --name failing-container docker.io/library/alpine /bin/nonexistent-command
```

Check the error logs:

```bash
podman logs failing-container
```

Check the recent events for it:

```bash
podman events --filter container=failing-container --since 1m
```

### 4.2 Debug with Detailed Logs

Run a container with debug-level logging:

```bash
podman run -d --name debug-container --log-level=debug docker.io/library/nginx:alpine
```

View the debug-level logs:

```bash
podman logs debug-container
```

## Cleanup

To remove all the containers created in this lab:

```bash
podman rm -f nginx-container json-logger journald-logger event-test failing-container debug-container
```