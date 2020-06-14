FROM autoware/autoware:1.14.0-melodic-cuda
ARG CARLA_VERSION=0.9.9

USER root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo \
        less \
        emacs \
        tmux \
        bash-completion \
        command-not-found \
        software-properties-common \
        xsel \
        xdg-user-dirs \
        python-pip \
        python-protobuf \
        python-pexpect \
        pcl-tools \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# addtional ROS package
RUN apt-get update && apt-get install -y --no-install-recommends \
        ros-melodic-derived-object-msgs \
        ros-melodic-ackermann-msgs \
        ros-melodic-ainstein-radar-msgs \
        ros-melodic-compressed-image-transport \
        ros-melodic-rqt* \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install \
        simple-pid \
        numpy \
        pygame \
        networkx

ENV USERNAME autoware
USER $USERNAME
WORKDIR /home/$USERNAME
COPY CARLA_${CARLA_VERSION}.2.tar.gz /home/$USERNAME/
RUN mkdir CARLA_${CARLA_VERSION} && \
    tar xfvz CARLA_${CARLA_VERSION}.2.tar.gz -C CARLA_${CARLA_VERSION} && \
    rm /home/$USERNAME/CARLA_${CARLA_VERSION}.2.tar.gz
COPY AdditionalMaps_${CARLA_VERSION}.2.tar.gz /home/$USERNAME/
RUN tar xfvz AdditionalMaps_${CARLA_VERSION}.2.tar.gz -C /home/$USERNAME/CARLA_${CARLA_VERSION}/ && \
    rm /home/$USERNAME/AdditionalMaps_${CARLA_VERSION}.2.tar.gz

RUN echo "export PYTHONPATH=$PYTHONPATH:~/CARLA_${CARLA_VERSION}/PythonAPI/carla/dist/carla-${CARLA_VERSION}-py2.7-linux-x86_64.egg:~/CARLA_${CARLA_VERSION}/PythonAPI/carla" >> ~/.bashrc

SHELL ["/bin/bash", "-c"]
RUN mkdir -p ~/catkin_ws/src && \
    source /opt/ros/melodic/setup.bash && \
    catkin_init_workspace ~/catkin_ws/src && \
    cd ~/catkin_ws/src && \
    git clone --recursive https://github.com/carla-simulator/ros-bridge.git && \
    sed -i -e 's/fixed_delta_seconds: 0.05/fixed_delta_seconds: 0.10/' ros-bridge/carla_ros_bridge/config/settings.yaml && \
    cd ~/catkin_ws && \
    catkin_make -DCMAKE_BUILD_TYPE=Release && \
    source ~/catkin_ws/devel/setup.bash

RUN cd /home/$USERNAME && \
    git clone https://github.com/carla-simulator/scenario_runner.git -b v${CARLA_VERSION} && \
    sed -i '/carla/d' scenario_runner/requirements.txt && \
    sudo pip install -r scenario_runner/requirements.txt

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && \
    sudo apt-get install git-lfs && \
    git lfs install && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

RUN cd /home/$USERNAME && \
    git clone https://github.com/carla-simulator/carla-autoware.git && \
    git-lfs clone https://bitbucket.org/carla-simulator/autoware-contents.git

RUN echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc && \
    echo "source ~/Autoware/install/local_setup.bash" >> ~/.bashrc && \
    echo "export SCENARIO_RUNNER_PATH=/home/$USERNAME/scenario_runner" >> ~/.bashrc && \
    echo "export CARLA_MAPS_PATH=/home/$USERNAME/autoware-contents/maps" >> ~/.bashrc

ENTRYPOINT []
CMD ["/bin/bash"]
