# Managing Environment Files and Secrets with Podman

## Lab Objectives

- Use `.env` files to manage container environment variables.
- Pass those variables to a container using Podman CLI.
- Create and use **Podman secrets** for secure handling of sensitive values.
- Integrate both `.env` and secrets into a `docker-compose.yml` file for use with **Podman Compose**.

## Prerequisites

- Podman installed (version 3.0+ recommended)
- Podman Compose installed (`pip install podman-compose`)
- Basic familiarity with Linux command line
- Text editor like `vim`, `nano`, or `VSCode`

## Setup

Create a working directory for this lab:

```bash
mkdir podman-secrets-lab && cd podman-secrets-lab
```

## Task 1: Working with Environment Files

### Subtask 1.1: Create `.env` File

Let’s define a simple set of environment variables in a file:

```bash
cat <<EOF > .env
APP_NAME=MySecureApp
DB_USER=admin
DB_PASS=SuperSecret123!
EOF
```

Verify the file content:

```bash
cat .env
```

You should see:

```
APP_NAME=MySecureApp
DB_USER=admin
DB_PASS=SuperSecret123!
```

### Subtask 1.2: Use `.env` File in a Container

Let’s run a temporary container and load environment variables from the `.env` file:

```bash
podman run --rm --env-file=.env alpine env | grep -E 'APP_NAME|DB_'
```

Expected output:

```
APP_NAME=MySecureApp
DB_USER=admin
DB_PASS=SuperSecret123!
```

> The `--env-file` flag allows you to load multiple environment variables from a file all at once.

## Task 2: Working with Podman Secrets

### Subtask 2.1: Create a Secret

First, create a file that holds the secret value:

```bash
echo "TopSecretPassword" > db_password.txt
podman secret create db_password_secret db_password.txt
```

Now list all available secrets:

```bash
podman secret ls
```

Example output:

```
ID              NAME                DRIVER    CREATED          UPDATED
xxxxxxxxxxxx    db_password_secret file      X seconds ago    X seconds ago
```

### Subtask 2.2: Use Secret Inside Container

You can mount and read the secret like this:

```bash
podman run --rm --secret=db_password_secret alpine cat /run/secrets/db_password_secret
```

Output:

```
TopSecretPassword
```

> If you face permission errors, try running the command as root or with the `--privileged` flag.

## Task 3: Using Podman Compose

### Subtask 3.1: Create a `docker-compose.yml` File

Here we combine `.env` file and secret together in a single service definition:

```bash
cat <<EOF > docker-compose.yml
version: '3.8'
services:
  webapp:
    image: alpine
    env_file: .env
    secrets:
      - db_password_secret
    command: sh -c "echo \$APP_NAME && cat /run/secrets/db_password_secret"
secrets:
  db_password_secret:
    external: true
EOF
```

### Subtask 3.2: Deploy Using Podman Compose

Run the compose setup:

```bash
podman-compose up
```

Expected output from the `webapp` container:

```
webapp_1  | MySecureApp
webapp_1  | TopSecretPassword
```

> Note: `external: true` means the secret must already exist and is managed outside of the Compose file.

## Cleanup

When you're done, you can clean up everything:

```bash
podman secret rm db_password_secret
cd .. && rm -rf podman-secrets-lab
```