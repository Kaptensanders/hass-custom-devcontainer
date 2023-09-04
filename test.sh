#!/bin/bash

echo "Running test container..."

docker run --rm -it \
    -p 8123:8123 \
    -v $(pwd):/workspaces/test \
    -v $(pwd):/config/www/workspace \
    -e LOVELACE_PLUGINS="" \
    -e ENV_FILE="/workspaces/test/test.env" \
    Kaptensanders/hass-custom-devcontainer