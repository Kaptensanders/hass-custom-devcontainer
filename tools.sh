#!/bin/bash

IMAGE_NAME=hass_dev_image
CONTAINER_NAME=hass_dev_container
HASS_PORT=8123

function build() {
    docker container rm $CONTAINER_NAME
    docker rmi $(docker images "$IMAGE_NAME" -a -q)
    docker build $1 --progress=plain --tag "$IMAGE_NAME" .
}

function create_container() {
    docker container rm $CONTAINER_NAME
    docker run -it \
        -p $HASS_PORT:8123 \
        -v $(pwd):/workspaces/devimage \
        -v $(pwd):/config/www/workspace \
        -e ENV_FILE="/workspaces/devimage/test.env" \
        --name "$CONTAINER_NAME" \
        "$IMAGE_NAME"
}

case $1 in
    build)
        build
        ;;
    rebuild)
        build --no-cache
        ;;
    create_container)
        create_container
        ;;
    login)
        docker start hass_dev_container >/dev/null 2>&1
        docker exec -it $CONTAINER_NAME /bin/bash
        ;;
    *)
        echo "tools.sh <build, rebuild, create_container>"
        ;;
esac