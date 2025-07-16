# CMD vs ENTRYPOINT Instructions in Containers

## Prerequisites

Before getting started, make sure you have the following:

- Docker or Podman installed  
  _Podman is preferred for OpenShift alignment_  
- Basic knowledge of the Linux command line  
- A text editor (such as `vim`, `nano`, or `vscode`)  
- Internet access to pull base images

## Setup

Begin by creating a working directory:

```bash
mkdir cmd-entrypoint-lab && cd cmd-entrypoint-lab
````

Check that Podman is properly installed:

```bash
podman --version
```

## Task 1: Understanding `CMD`

### Subtask 1.1: Basic CMD Usage

Create a `Containerfile.cmd`:

```Dockerfile
FROM alpine:latest
CMD ["echo", "Hello from CMD"]
```

Build and run the container:

```bash
podman build -t cmd-demo -f Containerfile.cmd
podman run cmd-demo
```

**Expected Output:**

```
Hello from CMD
```

### Subtask 1.2: Overriding CMD

```bash
podman run cmd-demo echo "Overridden command"
```

**Expected Output:**

```
Overridden command
```

**Key Concept:**
`CMD` sets default commands that are **easily overridden** during runtime.

## Task 2: Understanding `ENTRYPOINT`

### Subtask 2.1: Basic ENTRYPOINT Usage

Create a `Containerfile.entrypoint`:

```Dockerfile
FROM alpine:latest
ENTRYPOINT ["echo", "Hello from ENTRYPOINT"]
```

Build and run:

```bash
podman build -t entrypoint-demo -f Containerfile.entrypoint
podman run entrypoint-demo
```

**Expected Output:**

```
Hello from ENTRYPOINT
```

### Subtask 2.2: Appending Arguments

```bash
podman run entrypoint-demo "with appended text"
```

**Expected Output:**

```
Hello from ENTRYPOINT with appended text
```

**Key Concept:**
`ENTRYPOINT` turns your container into a fixed command, appending runtime arguments.

---

## Task 3: Combining `ENTRYPOINT` + `CMD`

### Subtask 3.1: Default Arguments with CMD

Create `Containerfile.combined`:

```Dockerfile
FROM alpine:latest
ENTRYPOINT ["echo"]
CMD ["Default message"]
```

Build and run:

```bash
podman build -t combined-demo -f Containerfile.combined
podman run combined-demo
```

**Expected Output:**

```
Default message
```

### Subtask 3.2: Overriding CMD at Runtime

```bash
podman run combined-demo "Custom message"
```

**Expected Output:**

```
Custom message
```

**Key Concept:**
When combined, `ENTRYPOINT` defines the command and `CMD` sets the default argument.

## Task 4: Advanced Usage Patterns

### Subtask 4.1: Using a Shell Script as ENTRYPOINT

Create `entrypoint.sh`:

```sh
#!/bin/sh
echo "Starting container with arguments: $@"
exec "$@"
```

Then, create `Containerfile.script`:

```Dockerfile
FROM alpine:latest
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["echo", "Default execution"]
```

Build and run:

```bash
podman build -t script-demo -f Containerfile.script
podman run script-demo
```

### Subtask 4.2: Full Command Override

```bash
podman run --entrypoint /bin/ls script-demo -l /
```

**Expected Output:**
A directory listing of the root `/` folder.

## Troubleshooting Tips

If something doesn’t work as expected, check:

* JSON array syntax for `CMD` and `ENTRYPOINT`
* File permissions (`chmod +x`) on shell scripts
* Shebang (`#!/bin/sh`) in scripts
* Line endings: use **LF**, not **CRLF**

## Final Verification

List all built images:

```bash
podman images
```

Final test run:

```bash
podman run --rm combined-demo "Lab completed successfully!"
```

## Cleanup

To remove all images built during this lab:

```bash
podman rmi cmd-demo entrypoint-demo combined-demo script-demo
```

## Summary

* `CMD` provides default commands that can be overridden.
* `ENTRYPOINT` locks in a command and treats arguments as runtime input.
* Using both gives you flexibility and structure.
* Runtime overrides behave differently based on how you use these instructions.