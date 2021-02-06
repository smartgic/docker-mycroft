# Mycroft AI Voice Assistant running on Docker

[![Mycroft AI version](https://img.shields.io/badge/Mycroft%20AI-20.08-green.svg?style=flat&logoColor=FFFFFF&color=87567)](https://mycroft.ai)
[![Debian version](https://img.shields.io/badge/Debian-Buster-green.svg?style=flat&logoColor=FFFFFF&color=87567)](https://www.debian.org)
[![Docker pulls](https://img.shields.io/docker/pulls/smartgic/mycroft-base.svg?style=flat&logo=docker&logoColor=FFFFFF&color=87567)](https://hub.docker.com/r/smartgic/mycroft-base)

- [Mycroft AI Voice Assistant running on Docker](#mycroft-ai-voice-assistant-running-on-docker)
  * [What is Mycroft AI?](#what-is-mycroft-ai-)
  * [How does it work with Docker?](#how-does-it-work-with-docker-)
  * [Supported architectures](#supported-architectures)
  * [Requirements](#requirements)
  * [How to use these images](#how-to-use-these-images)
    + [Pairing](#pairing)
    + [CLI access](#cli-access)
    + [Skills management](#skills-management)
  * [Support](#support)


## What is Mycroft AI?

[![Mycroft AI logo](https://mycroft.ai/wp-content/uploads/2017/06/Logo_2.gif)](https://mycroft.ai)

[Mycroft AI](https://www.mycroft.ai/) is the world’s leading open source voice assistant. It is private by default and completely customizable. Our software runs on many platforms—on desktop, our reference hardware, a Raspberry Pi, or your own custom hardware.

The Mycroft open source voice stack can be freely remixed, extended, and deployed anywhere. Mycroft may be used in anything from a science project to a global enterprise environment.


## How does it work with Docker?

Mycroft AI is a complex piece of software which has several core services. These core services have been split into Docker containers to provide isolation and a micro service approach.

| Container           | Description                            |
| ---                 | ---                                    |
| `mycroft_bus`       | Mycroft AI message bus                 |
| `mycroft_enclosure` | Mycroft AI enclosure management        |
| `mycroft_audio`     | Mycroft AI audio output                |
| `mycroft_voice`     | Mycroft AI wake word & voice detection |
| `mycroft_skills`    | Mycroft AI skills management           |
| `mycroft_cli`       | Mycroft AI command line                |

To allow data persistance, Docker volumes are required which will avoid to re-pair the device, re-install the skills, etc... everytime that the the container is re-created.

| Volume                  | Description                                   |
| ---                     | ---                                           |
| `mycroft_ipc`           | Mycroft AI inter-process communication        |
| `mycroft_skills`        | Mycroft AI skills source code                 |
| `mycroft_skills_config` | Mycroft AI skills configuration               |
| `mycroft_skills_repo`   | Mycroft AI skills repository cache            |
| `mycroft_skills_venv`   | Mycroft AI virtualenv for skills requirements |


## Supported architectures

| Architecture | Tags                            |
| ---          | ---                             |
| `x86_64`     | `x86_64-dev`, `x86_64-latest`   |
| `armv7l`     | `armv7l-dev`, `armv7l-latest`   |
| `aarch64`    | `aarch64-dev`, `aarch64-latest` |

`dev` is a nightly build based on the latest commits applied to the `dev` branch and `master` is the latest stable version.


## Requirements

Docker is of course required and `docker-compose` is a nice to have to simplify the whole process.

**PulseAudio is a requirement and has to be up and running on the host to expose a socket and allow the containers to use microphone and speakers.**


## How to use these images

`docker-compose.yml` file provides an easy way to provision the Docker volumes and containers with the required configuration for each of them. The `run.sh` script is a wrapper for `docker-compose` with variables encapsulation.

```bash
$ git clone https://github.com/smartgic/docker-mycroft.git
$ mkdir mycroft-config mycroft-web-cache
$ cd docker-mycroft
$ COMPOSE_HTTP_TIMEOUT=120 XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR ARCH=aarch64 VERSION=dev docker-compose up -d
```

Or using the `run.sh`, execute the script with the `-h` argument to display the help message.

```bash
$ git clone https://github.com/smartgic/docker-mycroft.git
$ cd docker-mycroft
$ sudo run.sh -a aarch64 -v dev
```

The `-u` option from `run.sh` will allows you to execute the script without privileges, the only requirement will be to add your user to the `docker` group then logout and login.

Without `docker-compose` the container creation could be tedious and repetitive, *(example of `mycroft_skills` container)*:

```bash
$ sudo docker run -d \
  -v ~/mycroft-config:/home/mycroft/.mycroft \
  -v ~/mycroft-web-cache:/var/tmp \
  -v mycroft_ipc:/tmp/mycroft/ipc \
  -v mycroft_skills_config:/home/mycroft/.config/mycroft \
  -v mycroft_skills:/opt/mycroft/skills \
  -v mycroft_skills_venv:/opt/mycroft-venv \
  -v mycroft_skills_repo:/opt/mycroft \
  -v ${XDG_RUNTIME_DIR}/pulse:${XDG_RUNTIME_DIR}/pulse \
  -v ~/.config/pulse/cookie:/home/mycroft/.config/pulse/cookie \
  -v /sys:/sys \
  --device /dev/snd \
  --device /dev/gpiomem \ # For Raspberry Pi GPIO
  --group-add $(getent group audio | cut -d: -f3) \
  --group-add $(getent group gpio | cut -d: -f3) \ # For Raspberry Pi GPIO
  --env PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
  --env PULSE_COOKIE=/home/mycroft/.config/pulse/cookie \
  --network host \
  --name mycroft_skills \
  smartgic/mycroft-skills:aarch64-dev
```

### Pairing

If your audio is configured correctly, you should hear your Mycroft instance giving you a pairing code that you should use at [https://home.mycroft.ai](https://home.mycroft.ai).

If you don't have audio set up, you can retrieve the pairing code from logs `mycroft_skills` container:

```bash
$ sudo docker logs -f mycroft_skills | grep -i "pairing code:"
```

Once the device has been paired the required skills will be installed, this process could run for few minutes depending the hardware.

### CLI access

Get access to the container CLI with:

```bash
$ sudo docker exec -ti mycroft_cli bash
```

From the container's command prompt, start the Mycroft client console with:

```bash
$ mycroft-cli-client
```

When the containers start, all the requirements and skills will be installed. This could takes some time depending the hardware and Mycroft will not be ready until this process has finished.


### Skills management

```bash
$ sudo docker exec -ti mycroft_cli bash
```

From the container's command prompt, use the `msm` command to install a skill from Git repository:

```bash
$ msm install https://github.com/smartgic/mycroft-wakeword-led-gpio-skill.git
```

## Support

* [Mycroft AI documentation](https://mycroft-ai.gitbook.io/docs)
* [Mycroft AI community](https://community.mycroft.ai)
* [Contribute to Mycroft AI](https://mycroft.ai/contribute)
* [Report Mycroft AI core bugs](https://github.com/MycroftAI/mycroft-core/issues)
* [Report bugs related to these Docker images](https://github.com/smartgic/docker-mycroft/issues)
