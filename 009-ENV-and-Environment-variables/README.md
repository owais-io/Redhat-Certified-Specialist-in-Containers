# Using ENV and Environment Variables with Podman

## Step 1: Verify Podman Installation

Check Podman version:

```bash
podman --version
````

Expected output:

```
podman version 3.4.0
```

## Step 2: Prepare the Working Directory

Create a dedicated directory for the lab:

```bash
mkdir env-lab && cd env-lab
```

## Step 3: Set Environment Variables in a Containerfile

### 3.1 Create a Basic Containerfile

Create and open a new `Containerfile`:

```bash
nano Containerfile
```

Add the following content:

```Dockerfile
FROM alpine:latest

ENV APP_NAME="MyApp" \
    APP_VERSION="1.0.0"

CMD echo "Running $APP_NAME version $APP_VERSION"
```

### 3.2 Build and Run the Container

```bash
podman build -t env-demo .
```

Now run it:

```bash
podman run env-demo
```

Expected output:

```
Running MyApp version 1.0.0
```

## Step 4: Override Environment Variables at Runtime

### 4.1 Override a Single Variable

```bash
podman run -e APP_NAME="NewApp" env-demo
```

Expected output:

```
Running NewApp version 1.0.0
```

### 4.2 Override Multiple Variables

```bash
podman run -e APP_NAME="ProductionApp" -e APP_VERSION="2.0.0" env-demo
```

Expected output:

```
Running ProductionApp version 2.0.0
```

## Step 5: Use Multi-line Environment Variables

### 5.1 Modify the Containerfile

Edit the existing `Containerfile`:

```Dockerfile
FROM alpine:latest

ENV APP_NAME="MyApp" \
    APP_VERSION="1.0.0" \
    APP_DESCRIPTION="This is a multi-line \
environment variable example"

CMD echo "$APP_DESCRIPTION"
```

### 5.2 Rebuild and Run

```bash
podman build -t multiline-env .
podman run multiline-env
```

Expected output:

```
This is a multi-line environment variable example
```

## Step 6: Document Environment Variables

### 6.1 Create a README.md File

```bash
nano README.md
```

Add the following content (already included here below):

```markdown
# Environment Variables

| Variable         | Description                 | Default Value               |
|------------------|-----------------------------|-----------------------------|
| APP_NAME         | Name of the application     | MyApp                       |
| APP_VERSION      | Application version         | 1.0.0                       |
| APP_DESCRIPTION  | Multi-line description      | See Containerfile for value |
```

### 6.2 Verify Consistency

Make sure your README content reflects what is defined inside the `Containerfile`.

## Troubleshooting Tips

* Always use `-e` before each environment variable when overriding values
* For multi-line variables, use a backslash (`\`) at the end of the first line
* To inspect running containers and see environment variables, use:

```bash
podman inspect <container-id>
```