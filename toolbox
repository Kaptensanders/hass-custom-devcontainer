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

function test_remote() {
docker run --rm -it \
    -p $HASS_PORT:8123 \
    -v $(pwd):/workspaces/devimage \
    -v $(pwd):/config/www/workspace \
    --name ${CONTAINER_NAME}_remote\
    kaptensanders/hass-custom-devcontainer
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
    recreate)
        build --no-cache
        create_container
        ;;
    login)
        docker start hass_dev_container >/dev/null 2>&1
        docker exec -it $CONTAINER_NAME /bin/bash
        ;;
    test)
        build
        create_container
        ;;
    test_remote)
        test_remote
        ;;
    *)
        echo "toolbox <build, rebuild, create_container, recreate, login, test, test_remote>"
        echo "  * build:"
        echo "      - delete container $CONTAINER_NAME"
        echo "      - delete image $CONTAINER_NAME"
        echo "      - build new image (cached if available)"
        echo "  * rebuild:"
        echo "      - same as 'build' but without cached build"
        echo "  * create_container:"
        echo "      - delete container $CONTAINER_NAME"
        echo "      - build and run new $CONTAINER_NAME"
        echo "  * login:"
        echo "      - start $CONTAINER_NAME and attach login shell"
        echo "  * login:"
        echo "      - start $CONTAINER_NAME and attach login shell"
        echo "  * testremote:"
        echo "      - run container pulled from dockerhub"
        ;;
esac