#!/bin/bash
#
# Copyright 2022 Gaëtan Trellu (goldyfruit) <gaetan.trellu@smartgic.io>.
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
    -c      Specify the mycroft-config folder, default is ~/mycroft-config, assumes existing folder when manually provided
    -w      Specify the mycroft-web-cache folder, default is ~/mycroft-web-cache, assumes existing folder when manually provided
    -m      Specify the mycroft-precise-models folder, default is ~/mycroft-precise-models, assumes existing folder when manually provided
    -s      Specify the mycroft-cache folder, default is ~/mycroft-cache, assumes existing folder when manually provided
    -v      Specify the mycroft-mimic3-voices folder, default is ~/mycroft-mimic3-voices, assumes existing folder when manually provided
    -u      Execute this script as a simple user, make sure your user is part of the "docker" group
    '
    exit
}

# Check the arguments passed to the script.
while getopts t:a:v:x:c:w:uh flag
do
    case "${flag}" in
        t) timeout=${OPTARG};;
        v) version=${OPTARG};;
        x) xdg=${OPTARG};;
        c) configfolder=${OPTARG};;
        w) webcachefolder=${OPTARG};;
        m) modelsfolder=${OPTARG};;
        s) cachefolder=${OPTARG};;
        v) voicesfolder=${OPTARG};;
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

# Few commands are required to continue such as docker, docker-compose and xauth
# The check if perform whith the command_exists function from above.
for COMMAND in "docker" "docker-compose" "xauth"; do
    command_exists "${COMMAND}"
done

# Check if platform is Raspberry Pi, to apply it's own configuration later
# This is done since amd64 computers do not have the same hardware device
#  for GPIO pins like the Pi does.
case $(uname -m) in
    armv6l | armv7l | aarch64)
        raspberrypi="true";;
esac

# Create Docker mount directories.
#   - mycroft-config: Mycroft configuration file such as mycroft.conf
#   - mycroft-web-cache: Configuration sent by Selene backend to the device
#   - mycroft-precise-models: Custom models to use with precise or precise-lite
#   - mycroft-cache: Cache directory used by Mycroft components to share data
#   - mycroft-mimic3-voices: Voices downloaded by Mimic3
if [ -z $configfolder ]; then
    export CONFIG_FOLDER=~/mycroft-config
    mkdir -p ${CONFIG_FOLDER}
    chown 1000:1000 ${CONFIG_FOLDER}
else
    export CONFIG_FOLDER=$configfolder
fi
if [ -z $webcachefolder ]; then
    export WEBCACHE_FOLDER=~/mycroft-web-cache
    mkdir -p ${WEBCACHE_FOLDER}
    chown 1000:1000 ${WEBCACHE_FOLDER}
else
    export WEBCACHE_FOLDER=$webcachefolder
fi
if [ -z $modelsfolder ]; then
    export MODELS_FOLDER=~/mycroft-precise-models
    mkdir -p ${MODELS_FOLDER}
    chown 1000:1000 ${MODELS_FOLDER}
else
    export MODELS_FOLDER=$modelsfolder
fi
if [ -z $cachefolder ]; then
    export CACHE_FOLDER=~/mycroft-cache
    mkdir -p ${CACHE_FOLDER}
    chown 1000:1000 ${CACHE_FOLDER}
else
    export CACHE_FOLDER=$cachefolder
fi
if [ -z $voicesfolder ]; then
    export MIMIC3_VOICES_FOLDER=~/mycroft-mimic3-voices
    mkdir -p ${MIMIC3_VOICES_FOLDER}
    chown 1000:1000 ${MIMIC3_VOICES_FOLDER}
else
    export MIMIC3_VOICES_FOLDER=$cachefolder
fi

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

# Generate X authentication token for Docker
DOCKER_XAUTH=~/.docker.xauth
if [ ! -f $DOCKER_XAUTH ]; then
    touch $DOCKER_XAUTH
    xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $DOCKER_XAUTH nmerge -
    chown 1000:1000 $DOCKER_XAUTH
fi

# Execute docker-compose using the docker-compose.yml file from the
# same directory, adding the Raspberry Pi override if necessary.
if [ -z $raspberrypi ]; then
    docker-compose --env-file .env -f docker-compose.yml up -d
else
    docker-compose --env-file .env-raspberrypi -f docker-compose.yml -f docker-compose.raspberrypi.yml up -d
fi
