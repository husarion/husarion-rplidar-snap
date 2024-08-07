[private]
default:
    @just --list --unsorted

# some random build script
build target="humble":
    #!/bin/bash
    export SNAPCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=1

    if [ {{target}} == "humble" ]; then
        export ROS_DISTRO=humble
        export CORE_VERSION=core22
    elif [ {{target}} == "jazzy" ]; then
        export ROS_DISTRO=jazzy
        export CORE_VERSION=core24
    else
        echo "Unknown target: $target"
        exit 1
    fi

    sudo rm -rf snap/snapcraft.yaml
    ./render_template.py ./snapcraft_template.yaml.jinja2 snap/snapcraft.yaml
    chmod 444 snap/snapcraft.yaml
    snapcraft

install:
    #!/bin/bash
    unsquashfs husarion-rplidar*.snap
    sudo snap try squashfs-root/
    sudo snap connect husarion-rplidar:raw-usb
    sudo husarion-rplidar.stop

remove:
    #!/bin/bash
    sudo snap remove husarion-rplidar
    sudo rm -rf squashfs-root/

clean:
    #!/bin/bash
    export SNAPCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=1
    snapcraft clean   

iterate target="jazzy":
    #!/bin/bash
    start_time=$(date +%s)
    
    echo "Starting script..."

    sudo snap remove husarion-rplidar
    sudo rm -rf squashfs-root/
    sudo rm -rf husarion-rplidar*.snap
    export SNAPCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=1
    
    if [ {{target}} == "humble" ]; then
        export ROS_DISTRO=humble
    elif [ {{target}} == "jazzy" ]; then
        export ROS_DISTRO=jazzy
    else
        echo "Unknown target: {{target}}"
        exit 1
    fi

    snapcraft clean
    sudo rm -rf snap/snapcraft.yaml
    ./render_template.py ./snapcraft_template.yaml.jinja2 snap/snapcraft.yaml
    chmod 444 snap/snapcraft.yaml
    snapcraft

    unsquashfs husarion-rplidar*.snap
    sudo snap try squashfs-root/
    sudo snap connect husarion-rplidar:raw-usb
    sudo snap connect husarion-rplidar:hardware-observe # for find_usb_device
    sudo snap connect husarion-rplidar:shm-plug husarion-rplidar:shm-slot
    sudo husarion-rplidar.stop
    sudo snap set husarion-rplidar configuration=s2

    end_time=$(date +%s)
    duration=$(( end_time - start_time ))

    hours=$(( duration / 3600 ))
    minutes=$(( (duration % 3600) / 60 ))
    seconds=$(( duration % 60 ))

    printf "Script completed in %02d:%02d:%02d (hh:mm:ss)\n" $hours $minutes $seconds

swap-enable:
    #!/bin/bash
    sudo fallocate -l 3G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    sudo swapon --show

    # Make the swap file permanent:
    sudo bash -c "echo '/swapfile swap swap defaults 0 0' >> /etc/fstab"

    # Adjust swappiness:
    sudo sysctl vm.swappiness=10
    sudo bash -c "echo 'vm.swappiness=10' >> /etc/sysctl.conf"

swap-disable:
    #!/bin/bash
    sudo swapoff /swapfile
    sudo rm /swapfile
    sudo sed -i '/\/swapfile swap swap defaults 0 0/d' /etc/fstab  # Remove the swap file entry
    sudo sed -i '/vm.swappiness=10/d' /etc/sysctl.conf  # Remove or comment out the swappiness setting
    sudo sysctl -p  # Reload sysctl configuration

prepare-store-credentials:
    #!/bin/bash
    snapcraft export-login --snaps=husarion-rplidar \
      --acls package_access,package_push,package_update,package_release \
      exported.txt

publish:
    #!/bin/bash
    export SNAPCRAFT_STORE_CREDENTIALS=$(cat exported.txt)
    snapcraft login
    snapcraft upload --release edge husarion-rplidar*.snap