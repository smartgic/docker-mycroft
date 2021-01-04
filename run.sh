#!/bin/bash
#
# Copyright 2021 Gaëtan Trellu (goldyfruit) <gaetan.trellu@smartgic.io>.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Function to display a help message.
help() {
    echo '
Usage: run.sh [options]
Use docker-compose to provision Mycroft AI Voice Assistant Docker stack
Options:
    -h      Show this help message
    -t      Configures the time a request to the Docker daemon is allowed to hang, default to 120
    -a      CPU architecture, default from "arch" command
    -v      Mycroft core version to use, default is "dev", "master" is avaiable too
    -x      Specify which XDG_RUNTIME_DIR to use, default is "$XDG_RUNTIME_DIR"
    '
    exit
}

# Check the arguments passed to the script.
while getopts t:a:v:x:h flag
do
    case "${flag}" in
        t) timeout=${OPTARG};;
        a) arch=${OPTARG};;
        v) version=${OPTARG};;
        x) xdg=${OPTARG};;
        h) help;;
    esac
done

# This script requires super user privileges, root or sudo are required
# to pursuit the execution of this script.
if ((EUID != 0)); then
    echo "root or sudo required for script ( $(basename $0) )"
    exit 1
fi

# Function that checks if a binary command is available, if not
# then the script exit.
command_exists() {
    command -v "$1" >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "$1 but it's not installed, abort..."
        exit 1
    fi
}

# Few commands are required to continue such as docker and docker-compose
# The check if perform whith the command_exists function from above.
for COMMAND in "docker" "docker-compose" "arch"; do
    command_exists "${COMMAND}"
done

# Create Docker mount directories.
#   - mycroft-config: Mycroft configuration file such as mycroft.conf
#   - mycroft-web-cache: Configuration sent by Selene backend to the device
mkdir -p ~/mycroft-config ~/mycroft-web-cache

# Variables used by docker-compose during creation process.
if [ -z $timeout ]; then
    export COMPOSE_HTTP_TIMEOUT=120
else
    export COMPOSE_HTTP_TIMEOUT=$timeout
fi

if [ -z $arch ]; then
    export ARCH="amd64"
else
    export ARCH="$arch"
fi

if [ -z $version ]; then
    export VERSION="dev"
else
    export VERSION="$version"
fi

if [ -z $xdg ]; then
    export XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR
else
    export XDG_RUNTIME_DIR="$xdg"
fi

# Execute docker-compose using the docker-compose.yml file from the
# same directory.
docker-compose up -d