# carla_autoware_bridge_docker

## Introduction
This is a Dockerfile to use [CARLA](https://github.com/carla-simulator/carla) and [Autoware.AI](https://gitlab.com/autowarefoundation/autoware.ai) on Docker container.

## Requirements
* NVIDIA graphics driver
* Docker
* nvidia-docker2

## Preparation
### Download CARLA Simulator
Please download the CARLA Simulator and addtional map file from <https://github.com/carla-simulator/carla/releases/tag/0.9.9.2>.  
And, please put CARLA Simulator in the same directory as the Dockerfile.  
This time, I used the following package.

- `CARLA_0.9.9.2.tar.gz`
- `AdditionalMaps_0.9.9.2.tar.gz`

### Build Docker image
```shell
$ docker build -t carla-autoware:0.9.9 .
```

### Create Docker container
```shell
$ ./launch_container.sh
```

## Usage
### CARLA Autoware bridge
#### Launch CARLA Simulator
Please launch CARLA Simulator by the following command.

```shell
$ cd CARLA_0.9.9
$ ./CarlaUE4.sh -windowed -ResX=160 -ResY=120
```

#### Launch CARLA Autoware bridge
```shell
$ roslaunch carla_autoware_bridge carla_autoware_bridge.launch town:=Town05
```

#### Launch Runtime Manager
```shell
$ roslaunch runtime_manager runtime_manager.launch
```

And, Please specify the following launch files in runtime_manager.

|Task|launch file|
|---|---|
|Map|`${HOME}/carla-autoware/autoware_launch/my_map.launch`|
|Sensing|`${HOME}/carla-autoware/autoware_launch/my_sensing.launch`|
|Localization|`${HOME}/carla-autoware/autoware_launch/my_localization.launch`|

#### Launch RViz
```shell
$ rviz
```