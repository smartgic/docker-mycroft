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
    -v      Mycroft core version to use, default is "dev", "master" is avaiable too
    -x      Specify which XDG_RUNTIME_DIR to use, default is "/run/user/1000" but could be $XDG_RUNTIME_DIR if defined
    -u      Execute this script as a simple user, make sure your user is part of the "docker" group
    '
    exit
}

# Check the arguments passed to the script.
while getopts t:a:v:x:uh flag
do
    case "${flag}" in
        t) timeout=${OPTARG};;
        v) version=${OPTARG};;
        x) xdg=${OPTARG};;
        u) user="true";;
        h) help;;
    esac
done

# This script requires super user privileges, root or sudo are required
# to pursuit the execution of this script except if the user specified
# the -u option.
if [ -z $user ]; then
    if ((EUID != 0)); then
        echo 'root or sudo required for script $(basename $0)'
        exit 1
    fi
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
for COMMAND in "docker" "docker-compose"; do
    command_exists "${COMMAND}"
done

# Create Docker mount directories.
#   - mycroft-config: Mycroft configuration file such as mycroft.conf
#   - mycroft-web-cache: Configuration sent by Selene backend to the device
mkdir -p ~/mycroft-config ~/mycroft-web-cache
chown 1000:1000 ~/mycroft-config ~/mycroft-web-cache

# Variables used by docker-compose during creation process.
if [ -z $timeout ]; then
    export COMPOSE_HTTP_TIMEOUT=120
else
    export COMPOSE_HTTP_TIMEOUT=$timeout
fi

if [ -z $version ]; then
    export VERSION="dev"
else
    export VERSION="$version"
fi

if [ -z $xdg ]; then
    export XDG_RUNTIME_DIR=/run/user/1000
else
    export XDG_RUNTIME_DIR="$xdg"
fi

# Execute docker-compose using the docker-compose.yml file from the
# same directory.
docker-compose up -d