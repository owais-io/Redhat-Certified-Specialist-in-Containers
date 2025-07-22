# Running Multi-Container Applications with Podman

## Prerequisites

Before starting, make sure you have the following:

- Podman (v3.0+)
- `podman-compose` installed (`pip install podman-compose`)
- Familiarity with YAML syntax
- Basic understanding of Docker/Podman concepts

Start the Podman service:

```bash
sudo systemctl start podman
```

Verify installations:

```bash
podman --version
podman-compose --version
```

## Step 1: Create Project Structure

Create a working directory for your multi-container application:

```bash
mkdir multi-container-lab && cd multi-container-lab
```

Then create a `docker-compose.yml` file with the following content:

```yaml
version: '3.8'

services:
  web:
    image: docker.io/python:3.9
    command: python -m http.server 8000
    ports:
      - "8000:8000"
    volumes:
      - ./app:/app
    depends_on:
      - redis
      - db
    networks:
      - app-network

  redis:
    image: docker.io/redis:alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - app-network

  db:
    image: docker.io/postgres:13-alpine
    environment:
      POSTGRES_PASSWORD: example
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  redis-data:
  postgres-data:

networks:
  app-network:
    driver: bridge
```

## Step 2: Deploy the Stack with `podman-compose`

Bring up the containers:

```bash
podman-compose up -d
```

Check running containers:

```bash
podman ps
```

Confirm the web service is active:

```bash
curl http://localhost:8000
```

You should receive a response from the Python HTTP server.

## Step 3: Add Secrets Management

Create a database password as a secret:

```bash
echo "supersecret" | podman secret create db_password -
```

Modify the `docker-compose.yml` to use the secret:

```yaml
services:
  db:
    image: docker.io/postgres:13-alpine
    secrets:
      - db_password
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password

secrets:
  db_password:
    external: true
```

Redeploy the application to apply changes:

```bash
podman-compose down
podman-compose up -d
```

**Note**: If you encounter permission issues, try:

```bash
sudo setsebool -P container_manage_cgroup true
```

## Step 4: Generate and Deploy with Kubernetes YAML

Generate a Kubernetes deployment YAML:

```bash
podman kube generate --service -f k8s-deployment.yaml web redis db
```

Inspect the contents of the generated `k8s-deployment.yaml` file.

To deploy:

```bash
podman play kube k8s-deployment.yaml
```

Verify the pod and containers:

```bash
podman pod ps
podman ps
```

## Cleanup

To stop and remove all resources:

```bash
podman-compose down
podman pod rm -a -f
podman rm -a -f
podman volume prune
podman secret rm db_password
```