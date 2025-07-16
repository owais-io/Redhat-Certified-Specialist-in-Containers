#!/bin/sh

# Process arguments
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



#----------------------------------------------------------

# #!/bin/sh

# # Environment detection
# if [ "$ENV_MODE" = "production" ]; then
#     echo "PRODUCTION MODE: Strict settings applied"
#     # Add production-specific logic here
# elif [ "$ENV_MODE" = "development" ]; then
#     echo "DEVELOPMENT MODE: Debug features enabled"
#     # Add development-specific logic here
# else
#     echo "No ENV_MODE specified, running in default mode"
# fi

# exec "$@"



#----------------------------------------------------------

# #!/bin/sh
# echo "Container starting with arguments: $@"
# echo "First argument: ${1:-none}"
# echo "Second argument: ${2:-none}"

# # Execute the command passed from CMD
# exec "$@"

# ---------------------------------------------------------

# #!/bin/sh

# echo "Container starting..."
# echo "Executing as user: $(whoami)"
# echo "Current directory: $(pwd)"
