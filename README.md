# Please visit https://github.com/OpenVoiceOS/ovos-docker as Mycroft AI is now abandon-ware.

# Mycroft AI Voice Assistant running on Docker

[![Mycroft AI version](https://img.shields.io/badge/Mycroft%20AI-21.2.2-green.svg?style=flat&logoColor=FFFFFF&color=87567)](https://mycroft.ai)
[![Debian version](https://img.shields.io/badge/Debian-Bullseye-green.svg?style=flat&logoColor=FFFFFF&color=87567)](https://www.debian.org)
[![Docker pulls](https://img.shields.io/docker/pulls/smartgic/mycroft-base.svg?style=flat&logo=docker&logoColor=FFFFFF&color=87567)](https://hub.docker.com/r/smartgic/mycroft-base)
[![Discord](https://img.shields.io/discord/809074036733902888)](https://discord.gg/sHM3Duz5d3)

- [Mycroft AI Voice Assistant running on Docker](#mycroft-ai-voice-assistant-running-on-docker)
  * [What is Mycroft AI?](#what-is-mycroft-ai-)
  * [How does it work with Docker?](#how-does-it-work-with-docker-)
  * [Supported architectures and tags](#supported-architectures-and-tags)
  * [Requirements](#requirements)
  * [How to build these images](#how-to-build-these-images)
  * [How to use these images](#how-to-use-these-images)
    + [Mycroft GUI](#mycroft-gui)
    + [Raspberry Pi](#raspberry-pi)
    + [Precise-lite engine usage](#precise-lite-engine-usage)
      - [Download the models](#download-the-models)
      - [Configure Mycroft to use `precise-lite` engine](#configure-mycroft-to-use--precise-lite--engine)
    + [Pairing](#pairing)
    + [CLI access](#cli-access)
    + [Skills management](#skills-management)
  * [FAQ](#faq)
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
| `mycroft_gui`       | Mycroft AI graphical user interface    |

To allow data persistance, Docker volumes are required which will avoid to re-pair the device, re-install the skills, etc... everytime that the the container is re-created.

| Volume                  | Description                                         |
| ---                     | ---                                                 |
| `mycroft_skills`        | Mycroft AI skills source code                       |
| `mycroft_skills_repo`   | Mycroft AI skills repository cache                  |
| `mycroft_skills_venv`   | Mycroft AI virtualenv for skills requirements       |

## Supported architectures and tags

| Architecture | Information                                        |
| ---          | ---                                                |
| `amd64`      | Such as AMD and Intel processors                   |
| `arm/v6`     | Such as Raspberry Pi 1 *(soon due to Mimic issue)* |
| `arm/v7`     | Such as Raspberry Pi 2/3/4                         |
| `arm64`      | Such as Raspberry Pi 4 64-bit                      |

*Raspberry Pi(s) are automatically dectected to allow `/dev/gpiomem` device to be passed to the `mycroft_skills` container.*

*These are examples, many other boards use these CPU architectures.*

| Tag | Description                                                                         |
| --  | ---                                                                                 |
| `dev`/`latest`    | Nightly build based on the latest commits applied to the `dev` branch |
| `master`/`stable` | The latest stable version based on the `master` branch                |
| `2X.XX`           | Current and previous stable versions                                  |

## Requirements

Docker is of course required and `docker-compose` is a nice to have to simplify the whole process by using the `docker-compose.yml` files.

**PulseAudio is a requirement and has to be up and running on the host to expose a socket and allow the containers to use microphone and speakers.**

If you plan to run Mycroft AI on a Raspberry Pi, have a look to this Ansible playbooks: https://github.com/smartgic/ansible-playbooks-mycroft.git

This will help you to set the requirements such as firmware, overclocking, PulseAudio, filesystem, etc... *(except the Docker setup)*.

## How to build these images

The `base` image is the main image for the other images, for example the `audio` image requires the `base` image to be build.

```bash
$ git clone https://github.com/smartgic/docker-mycroft.git
$ cd docker-mycroft
$ docker build -t smartgic/mycroft-base:dev --build-arg BRANCH=dev --build-arg TAG=dev base/
```

Two arguments are available for the `base` image:
* `BRANCH`: Which branch to use from `mycroft-core` GitHub repository
* `TAG`: What tag this image will have *(default is `dev`)*.

Other than the `base` image, only the `TAG` argument is available.
```
$ docker build -t smartgic/mycroft-audio:dev --build-arg TAG=dev audio/
```

Eight *(8)* images needs to be build; `mycroft-base`, `mycroft-voice`, `mycroft-skills`, `mycroft-cli`, `mycroft-bus`, `mycroft-enclosure`, `mycroft-audio`, `mycroft_gui`.

## How to use these images

`docker-compose.yml` file provides an easy way to provision the Docker volumes and containers with the required configuration for each of them. `docker-compose` supports  environment file, check the `.env` *(`.env-raspberrypi` for Raspberry Pi)* files prior the execution to set your custom values.

```bash
$ git clone https://github.com/smartgic/docker-mycroft.git
$ mkdir mycroft-config mycroft-web-cache mycroft-precise-models mycroft-cache mycroft-mimic3-voices
$ chown 1000:1000 mycroft-config mycroft-web-cache mycroft-precise-models mycroft-cache mycroft-mimic3-voices
$ cd docker-mycroft
$ docker-compose --env-file .env up -d
```

Or use the `run.sh` which is a `docker-compose` wrapper with variables, execute the script with the `-h` argument to display the help message.

```bash
$ git clone https://github.com/smartgic/docker-mycroft.git
$ cd docker-mycroft
$ sudo run.sh -v dev
```

The `-u` option from `run.sh` will allows you to execute the script without privileges, the only requirement will be to add your user to the `docker` group then logout and login.

Without `docker-compose` the container creation could be tedious and repetitive, *(example of `mycroft_skills` container)*:

```bash
$ sudo docker run -d \
  -v ~/mycroft-config:/home/mycroft/.config/mycroft \
  -v ~/mycroft-web-cache:/home/mycroft/.cache/mycroft \
  -v ~/mycroft-cache:/tmp/mycroft \
  -v mycroft_skills:/opt/mycroft/skills \
  -v mycroft_skills_venv:/opt/mycroft-venv \
  -v mycroft_skills_repo:/opt/mycroft \
  -v ${XDG_RUNTIME_DIR}/pulse:${XDG_RUNTIME_DIR}/pulse \
  -v ~/.config/pulse/cookie:/home/mycroft/.config/pulse/cookie \
  -v /sys:/sys:ro \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/localtime:/etc/localtime:ro \
  --device /dev/snd \
  --group-add $(getent group audio | cut -d: -f3) \
  --env PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
  --env PULSE_COOKIE=/home/mycroft/.config/pulse/cookie \
  --network host \
  --ipc host \
  --name mycroft_skills \
  smartgic/mycroft-skills:dev
```

### Mycroft GUI

The container needs to be authenticated to access the X Server and run the GUI. One way to do it is to use `xauth` *(part of the `xauth` package on Debian/Ubuntu)* which will generate a X authentication token. This token will have to be mounted as a volume within the container to be then used via the `XAUTHORITY` environment variable.

```bash
$ touch ~/.docker.xauth
$ xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f ~/.docker.xauth nmerge -
```

The `mycroft_gui` container requires an access to a X server to display information. In order to leverage OpenGL and provide better performances, the container needs to have the `render` group added to it.

```bash
  --group-add $(getent group render | cut -d: -f3)
```

When using `docker-compose` on a Raspberry Pi, the `render` group ID is hardcoded into `.env-raspberrypi` environment file, if `107` is not the GID of `render` group on your system then the update the `.env-raspberrypi` file with the correct value.

### Raspberry Pi

To reduce IOPS contention we recommend to use a `tmpfs` for `mycroft-cache` directory, `tmpfs` will prevent write IO on the disk.

```bash
$ sudo mkdir -p /mnt/mycroft
$ echo "tmpfs /mnt/mycroft tmpfs nosuid,nodev,size=64M,mode=700,uid=1000,gid=1000 0 0" | sudo tee -a /etc/fstab
$ sudo mount -a
```

Make sure the user `UID` and `GID` match your user.

```bash
$ docker-compose --env-file .env-raspberrypi -f docker-compose.yml -f docker-compose.raspberrypi.yml up -d
```

Remember, the Raspberry Pi is "slow" board so the `docker-compose` deployment could take longer than expected.

As mentioned previously, without `docker-compose` the container creation could be tedious and repetitive, *(example of `mycroft_skills` container on a Raspberry Pi)*:

```bash
$ sudo docker run -d \
  -v ~/mycroft-config:/home/mycroft/.config/mycroft \
  -v ~/mycroft-web-cache:/home/mycroft/.cache/mycroft \
  -v /mnt/mycroft:/tmp/mycroft \
  -v mycroft_skills:/opt/mycroft/skills \
  -v mycroft_skills_venv:/opt/mycroft-venv \
  -v mycroft_skills_repo:/opt/mycroft \
  -v ${XDG_RUNTIME_DIR}/pulse:${XDG_RUNTIME_DIR}/pulse \
  -v ~/.config/pulse/cookie:/home/mycroft/.config/pulse/cookie \
  -v /sys:/sys:ro \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/localtime:/etc/localtime:ro \
  --device /dev/snd \
  --device /dev/gpiomem \
  --group-add $(getent group audio | cut -d: -f3) \
  --group-add $(getent group gpio | cut -d: -f3) \
  --env PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
  --env PULSE_COOKIE=/home/mycroft/.config/pulse/cookie \
  --network host \
  --ipc host \
  --name mycroft_skills \
  smartgic/mycroft-skills:dev
```

We build the Ansible `prepi` [role](https://github.com/smartgic/ansible-role-prepi) to optimize and prepare the Raspberry Pi to receive Mycroft AI *(but not only)*.

### Precise-lite engine usage

[OpenVoiceOS](https://community.mycroft.ai/t/openvoiceos-a-bare-minimal-production-type-of-os-based-on-buildroot/4708/312) released a lighter version of `precise` engine; `precise-lite`. The requirements have been embedded within the `mycroft_voice` container but few extra steps are required.

#### Download the models

```bash
$ cd ~/mycroft-precise-models
$ git clone https://github.com/OpenVoiceOS/precise-lite-models
```

#### Configure Mycroft to use `precise-lite` engine

Add these lines to `mycroft.conf` in `~/mycroft-config` directory.

```json
{
  "hotwords": {
    "hey mycroft": {
      "module": "ovos-precise-lite",
      "model": "~/models/precise-lite-models/wakewords/en/hey_mycroft.tflite",
      "sensitivity": 0.5,
      "trigger_level": 3
    }
  }
}
```

Once the configuration has been updated, `mycroft_voice` container needs to be restarted.

```bash
$ sudo docker restart mycroft_voice
```

*No support will be provided by [Smart'Gic](https://smartgic.io) about this engine.*

### Pairing

If your audio is configured correctly, you should hear your Mycroft instance giving you a pairing code that you should use at [https://home.mycroft.ai](https://home.mycroft.ai).

If you don't have audio set up, you can retrieve the pairing code from logs `mycroft_skills` container:

```bash
$ sudo docker logs -f mycroft_skills | grep -i "pairing code"
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

## FAQ

* [Impossible to update configuration because device isn't paired](https://github.com/smartgic/docker-mycroft/issues/5)
* [[Errno 13] Permission denied: '/home/mycroft/.config/mycroft/skills](https://github.com/smartgic/docker-mycroft/issues/13)
* [Mimic2 cache is local to the `mycroft_audio` container](https://github.com/smartgic/docker-mycroft/issues/24)

## Support

* [Discord channel](https://discord.gg/Vu7Wmd9j)
* [Mycroft AI documentation](https://mycroft-ai.gitbook.io/docs)
* [Mycroft AI community](https://community.mycroft.ai)
* [Contribute to Mycroft AI](https://mycroft.ai/contribute)
* [Report Mycroft AI core bugs](https://github.com/MycroftAI/mycroft-core/issues)
* [Report bugs related to these Docker images](https://github.com/smartgic/docker-mycroft/issues)
