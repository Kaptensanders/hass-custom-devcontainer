#!/bin/bash

docker run -it \
    -p 8123:8123 \
    -v $(pwd):/workspaces/devimage \
    -v $(pwd):/config/www/workspace \
    --name test_hass_container \
    kaptensanders/hass-custom-devcontainer