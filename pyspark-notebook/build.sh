#!/bin/bash
set -xe

NO_CACHE=""
export DOCKER_BUILDKIT=0

while (( $# )); do
    case $1 in
        --no-cache) NO_CACHE="--no-cache"
        ;;
        --buildkit) export DOCKER_BUILDKIT=1
        ;;
        --*) echo "Bad Option $1"
        ;;
        *) TYPE=$1
        ;;
        *) break
	;;
    esac
    shift
done


# Builds a pyspark docker image based on $PYTHON_CONTAINER
TARGET_TAG=$TYPE
PYTHON_CONTAINER="python:3.7-slim-stretch"

# Get the matching tag Dockerfile and other resources for Jupyter notebooks
STACKS_TAG="cd158647fb94f83a6e13cb0207c2ec1516453f89" #a83e18b"
STACKS_PROJECT="docker-stacks"
STACKS_URL="https://github.com/jupyter/$STACKS_PROJECT"

BASE_FOLDER="base-notebook"
MINIMAL_FOLDER="minimal-notebook"
SCIPY_FOLDER="scipy-notebook"
PYSPARK_FOLDER="pyspark-notebook"

BASE_CONTAINER="tmp_"$BASE_FOLDER":"$STACKS_TAG
MINIMAL_CONTAINER="tmp_"$MINIMAL_FOLDER":"$STACKS_TAG
SCIPY_CONTAINER="tmp_"$SCIPY_FOLDER":"$STACKS_TAG

rm -rf $STACKS_PROJECT
git clone -n $STACKS_URL.git $STACKS_PROJECT
cd $STACKS_PROJECT
git checkout $STACKS_TAG
cd $BASE_FOLDER

sed -i "s/ run-one//g" Dockerfile

# Build jupyter BASE image using python $PYTHON_CONTAINER image
docker build $NO_CACHE \
  -t $BASE_CONTAINER \
  --build-arg BASE_CONTAINER=$PYTHON_CONTAINER \
  .

# Build jupyter MINIMAL image using BASE image
cd ../$MINIMAL_FOLDER
docker build $NO_CACHE \
  -t $MINIMAL_CONTAINER \
  --build-arg BASE_CONTAINER=$BASE_CONTAINER \
  .

cd ../$SCIPY_FOLDER
docker build $NO_CACHE \
  -t $SCIPY_CONTAINER \
  --build-arg BASE_CONTAINER=$MINIMAL_CONTAINER \
  .

cd ../..
pwd
docker build \
  -t $TARGET_TAG $NO_CACHE\
  --build-arg BASE_CONTAINER=$SCIPY_CONTAINER \
  .

exit
