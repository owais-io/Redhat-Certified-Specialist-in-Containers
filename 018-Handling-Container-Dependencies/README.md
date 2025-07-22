# Handling Container Dependencies

## Objectives

- Use `depends_on` in Docker Compose to manage startup order
- Add and customize `healthcheck` for service readiness
- Implement retry logic in entrypoint scripts
- Validate service connectivity between dependent containers

## Prerequisites

To follow along with this lab:

- Podman or Docker installed (Podman preferred for OpenShift alignment)
- podman-compose or docker-compose installed
- Basic understanding of container concepts
- Familiarity with terminal and a text editor (like `vim`, `nano`, or VSCode)

## Setup

Create a working directory:

```bash
mkdir container-dependencies-lab && cd container-dependencies-lab
```

Verify tools:

```bash
podman --version
podman-compose --version
```

## Task 1: Using `depends_on` in Compose Files

### Step 1.1: Create Basic Compose File

Start by creating a `docker-compose.yml` with two services: a `db` (PostgreSQL) and a `web` (NGINX).

```yaml
version: '3.8'
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: example
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    depends_on:
      db:
        condition: service_healthy
```

### Step 1.2: Explanation

* `depends_on`: ensures the `web` service starts only after the `db` service is healthy.
* `healthcheck`: checks readiness of the PostgreSQL database.
* `condition: service_healthy`: makes the dependency wait until the healthcheck passes.

### Step 1.3: Launch Services

```bash
podman-compose up -d
```

You should observe that the `web` container starts only after `db` becomes healthy.

## Task 2: Writing Health Check Scripts

### Step 2.1: Create a Custom Healthcheck Script

```bash
cat <<EOF > healthcheck.sh
#!/bin/sh

if curl -s http://db:5432 | grep -q 'PostgreSQL'; then
  exit 0
else
  exit 1
fi
EOF

chmod +x healthcheck.sh
```

### Step 2.2: Use the Script in Compose

Extend the Compose file by adding a Python service:

```yaml
  app:
    image: python:3.9-alpine
    volumes:
      - ./healthcheck.sh:/healthcheck.sh
    healthcheck:
      test: ["CMD", "/healthcheck.sh"]
      interval: 10s
      timeout: 5s
      retries: 3
```

## Task 3: Retry Logic in Entrypoint

### Step 3.1: Create Entrypoint Script

```bash
cat <<EOF > entrypoint.sh
#!/bin/sh

max_retries=5
retry_delay=5

for i in \$(seq 1 \$max_retries); do
  if nc -z db 5432; then
    echo "Database is ready!"
    exec "\$@"
    break
  else
    echo "Waiting for database... Attempt \$i/\$max_retries"
    sleep \$retry_delay
  fi
done

echo "Failed to connect to database after \$max_retries attempts"
exit 1
EOF

chmod +x entrypoint.sh
```

### Step 3.2: Create Dockerfile

```Dockerfile
FROM python:3.9-alpine
WORKDIR /app
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
CMD ["python", "app.py"]
```

## Task 4: Test Application and Connectivity

### Step 4.1: Create Test App

```python
# app.py

import os
import psycopg2

def connect_db():
    try:
        conn = psycopg2.connect(
            host="db",
            database="postgres",
            user="postgres",
            password=os.getenv("POSTGRES_PASSWORD")
        )
        print("Successfully connected to database!")
        conn.close()
    except Exception as e:
        print(f"Connection failed: {e}")

if __name__ == "__main__":
    connect_db()
```

### Step 4.2: Update Compose

```yaml
  app:
    build: .
    depends_on:
      db:
        condition: service_healthy
    environment:
      POSTGRES_PASSWORD: example
```

### Step 4.3: Build and Run

```bash
podman-compose up --build
```

The `app` container should connect to the `db` once it's healthy.

## Troubleshooting

If services do not start correctly:

* View logs:

  ```bash
  podman-compose logs
  ```

* Check health status:

  ```bash
  podman inspect --format='{{.State.Health.Status}}' <container_name>
  ```

* Tune healthcheck timings (intervals and retries) if the service times out.

* Ensure container names and hostnames match in scripts and Compose config.

## Cleanup

To remove containers and free resources:

```bash
podman-compose down
podman system prune -f
```