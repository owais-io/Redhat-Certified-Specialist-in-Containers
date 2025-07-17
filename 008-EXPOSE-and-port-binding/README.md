# EXPOSE and Port Binding in Containers

## Prerequisites

Before beginning, ensure the following:

- Podman is installed (version 3.0 or above is recommended)
- You are familiar with basic Linux terminal commands
- A text editor like `vim`, `nano`, or `gedit` is available
- `curl` or `telnet` is installed for testing
- You have network connectivity

To verify Podman installation:

```bash
podman --version
```

Expected output should confirm version 3.x.x or above.

## Lab Setup

Create a working directory for this lab:

```bash
mkdir portbinding-lab && cd portbinding-lab
```

## Task 1: Using `EXPOSE` in a Containerfile

### 1.1 Create a Simple Python Web App

We'll start by writing a minimal Flask app:

```bash
cat > app.py <<EOF
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from the exposed container port!\\n"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF
```

Create a `requirements.txt` to define Flask as a dependency:

```bash
echo "flask" > requirements.txt
```

### 1.2 Write the Containerfile with EXPOSE

```bash
cat > Containerfile <<EOF
FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
EXPOSE 8080
CMD ["python", "app.py"]
EOF
```

> Note: The `EXPOSE` instruction is purely documentation. It does **not** publish the port to the host.

## Task 2: Run Container with Port Mappings

### 2.1 Build the Image

```bash
podman build -t exposed-app .
```

### 2.2 Run and Map Ports

```bash
podman run -d -p 8080:8080 --name webapp exposed-app
```

Check if the container is running and port is mapped:

```bash
podman ps
```

If port `8080` is already in use, try:

```bash
podman run -d -p 8081:8080 --name webapp exposed-app
```

## Task 3: Test Connectivity from Host

### 3.1 Verify Port Mapping

Check if the host is listening on the port:

```bash
ss -tulnp | grep 8080
```

Then test the app:

```bash
curl http://localhost:8080
```

Expected output:

```
Hello from the exposed container port!
```

### 3.2 Run with a Different Host Port

Stop the container:

```bash
podman stop webapp
```

Now try binding it to a different port:

```bash
podman run -d -p 9090:8080 --name webapp2 exposed-app
curl http://localhost:9090
```

## Task 4: Troubleshoot Port Conflicts

### 4.1 Simulate Conflict

Try running on a busy port:

```bash
podman run -d -p 8080:8080 --name webapp3 exposed-app
```

You should get an error saying the port is already in use.

### 4.2 Fix the Conflict

To find which process is using the port:

```bash
sudo lsof -i :8080
```

You can:

* Stop the conflicting process
* Use a different host port
* Or let Podman assign a random available port:

```bash
podman run -d -P --name webapp4 exposed-app
podman port webapp4
```

## Final Verification and Cleanup

List all containers (active and inactive):

```bash
podman ps -a
```

To stop and remove all containers created during the lab:

```bash
podman stop -a && podman rm -a
```