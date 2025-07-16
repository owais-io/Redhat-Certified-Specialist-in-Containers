# Parameterized ENTRYPOINT Scripts

## Prerequisites

Make sure you have the following installed:

- Podman (recommended) or Docker
- Basic Linux shell knowledge
- Familiarity with shell scripting
- A text editor (vim, nano, VS Code)

To check Podman installation:

```bash
podman --version
```

Create a working directory:

```bash
mkdir entrypoint-lab && cd entrypoint-lab
```

## Task 1: Create a Basic ENTRYPOINT Script

### 1.1 Write the Shell Script

Create a file named `entrypoint.sh`:

```bash
#!/bin/bash

echo "Container starting..."
echo "Executing as user: $(whoami)"
echo "Current directory: $(pwd)"
```

### 1.2 Make the Script Executable

```bash
chmod +x entrypoint.sh
```

### 1.3 Create the Dockerfile

```Dockerfile
FROM alpine:latest
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

### 1.4 Build and Run

```bash
podman build -t entrypoint-demo .
podman run entrypoint-demo
```

**Expected Output:**

```
Container starting...
Executing as user: root
Current directory: /
```

---

## Task 2: Implement Parameter Handling

### 2.1 Update `entrypoint.sh` to Handle Arguments

```bash
#!/bin/bash

echo "Container starting with arguments: $@"
echo "First argument: ${1:-none}"
echo "Second argument: ${2:-none}"

exec "$@"
```

### 2.2 Update the Dockerfile

```Dockerfile
FROM alpine:latest
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["echo", "Default command executed"]
```

### 2.3 Test Scenarios

**Run with default CMD:**

```bash
podman run entrypoint-demo
```

Output:

```
Container starting with arguments: echo Default command executed
First argument: echo
Second argument: Default command executed
Default command executed
```

**Override CMD at runtime:**

```bash
podman run entrypoint-demo ls -l /
```

---

## Task 3: Environment-Specific Logic

### 3.1 Modify `entrypoint.sh` to Detect Modes

```bash
#!/bin/bash

if [ "$ENV_MODE" = "production" ]; then
    echo "PRODUCTION MODE: Strict settings applied"
elif [ "$ENV_MODE" = "development" ]; then
    echo "DEVELOPMENT MODE: Debug features enabled"
else
    echo "No ENV_MODE specified, running in default mode"
fi

exec "$@"
```

### 3.2 Dockerfile Remains Same

```Dockerfile
FROM alpine:latest
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["echo", "Running container"]
```

### 3.3 Test with Environment Variables

**Development mode:**

```bash
podman run -e ENV_MODE=development entrypoint-demo
```

**Production mode:**

```bash
podman run -e ENV_MODE=production entrypoint-demo
```

**No ENV\_MODE:**

```bash
podman run entrypoint-demo
```

## Task 4: Advanced Parameter Handling

### 4.1 Update `entrypoint.sh` to Support Commands

```bash
#!/bin/bash

case "$1" in
    start)
        echo "Starting application with config: ${2:-default}"
        ;;
    stop)
        echo "Stopping application gracefully"
        ;;
    *)
        echo "Usage: $0 {start|stop} [config]"
        exit 1
esac
```

### 4.2 Test Various Commands

```bash
podman run entrypoint-demo start production
podman run entrypoint-demo stop
podman run entrypoint-demo invalid
```

---

## Troubleshooting Tips

* **Permission denied**:
  Use `chmod +x entrypoint.sh`

* **Environment variable not applied**:
  Ensure the syntax is `-e ENV_MODE=value`

* **"exec format error"**:

  * Make sure the first line of your script is `#!/bin/bash`
  * Convert line endings using `dos2unix entrypoint.sh` if you're editing on Windows