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
Usage: destroy.sh [options]
Use docker-compose to unprovision Mycroft AI Voice Assistant Docker stack
Options:
    -h      Show this help message
    -v      Remove the volumes used by Mycroft AI containers
    -i      Remove all images used by Mycroft AI containers
    -u      Execute this script as a simple user, make sure your user is part of the "docker" group
    '
    exit
}

# Check the arguments passed to the script.
while getopts viuh flag
do
    case "${flag}" in
        v) volumes=${OPTARG};;
        i) images=${OPTARG};;
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

# Remove mycroft-config, mycroft-web-cache and mycroft-precise-models directories
if [ -d ~/mycroft-config ] || [ -d ~/mycroft-web-cache ] || [ -d ~/mycroft-precise-models ]; then
    rm -f ~/mycroft-config/* ~/mycroft-web-cache/* ~/mycroft-precise-models*
    rmdir ~/mycroft-config ~/mycroft-web-cache ~/mycroft-precise-models
fi

DOCKER_COMPOSE_OPTIONS=""

if [ -z $volumes ]; then
    export DOCKER_COMPOSE_OPTIONS+="--volumes "
fi

if [ -z $images ]; then
    export DOCKER_COMPOSE_OPTIONS+="--rmi all "
fi

# Execute docker-compose using the docker-compose.yml file from the
# same directory.
VERSION="" docker-compose down $DOCKER_COMPOSE_OPTIONS
