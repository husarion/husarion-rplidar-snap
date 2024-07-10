build:
    #!/bin/bash
    # ARCH=$(arch)

    # if [ "$ARCH" = "x86_64" ]; then \
    #     SNAP_ARCH="amd64"; \
    # elif [ "$ARCH" = "aarch64" ]; then \
    #     SNAP_ARCH="arm64"; \
    # else \
    #     SNAP_ARCH="$ARCH"; \
    # fi

    # lxd init --minimal
    # export SNAPCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=1
    # snapcraft --build-for=${SNAP_ARCH}
    export SNAPCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=1
    snapcraft

clean:
    #!/bin/bash
    export SNAPCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=1
    snapcraft clean 

_install-rsync:
    #!/bin/bash
    if ! command -v rsync &> /dev/null; then \
        if [ "$EUID" -ne 0 ]; then \
            echo "Please run as root to install dependencies"; \
            exit 1; \
        fi

        sudo apt update && sudo apt install -y rsync
    fi

dev-shell:
    snap run --shell husarion-rplidar

logs:
    sudo snap logs husarion-rplidar -n 20

# copy repo content to remote host with 'rsync' and watch for changes
sync hostname password="husarion": _install-rsync
    #!/bin/bash
    sshpass -p "husarion" rsync -vRr --delete ./ husarion@{{hostname}}:/home/husarion/${PWD##*/}
    while inotifywait -r -e modify,create,delete,move ./ ; do
        sshpass -p "{{password}}" rsync -vRr --delete ./ husarion@{{hostname}}:/home/husarion/${PWD##*/}
    done

install-snapcraft:
    sudo snap install lxd
    sudo usermod -aG lxd husarion
    newgrp lxd

    sudo lxd init --minimal
   
    sudo snap install snapcraft --classic
    # fixing issues with networking (https://documentation.ubuntu.com/lxd/en/latest/howto/network_bridge_firewalld/?_ga=2.178752743.25601779.1705486119-1059592906.1705486119#prevent-connectivity-issues-with-lxd-and-docker)
    sudo bash -c 'echo "net.ipv4.conf.all.forwarding=1" > /etc/sysctl.d/99-forwarding.conf'
    sudo systemctl stop docker.service
    sudo systemctl stop docker.socket
    sudo systemctl restart systemd-sysctl
    # now you may need to reboot (after reboot docker will not work until you run `sudo systemctl start docker.service`)

    # Enable the hotplug feature and restart the `snapd` daemon (for serial interface):
    sudo snap set core experimental.hotplug=true
    sudo systemctl restart snapd

    # Make sure $USER is in lxd group (you need to logout and login again after this command)
    sudo usermod -aG lxd username

push-snapcraft-store:
    #!/bin/bash
    export SNAPCRAFT_STORE_CREDENTIALS=$(cat ./.snapcraft_store_credentials.txt)
    # Loop through each file matching the pattern 'husarion-rplidar*.snap'
    for file in husarion-rplidar*.snap; do
        # Check if the file exists to avoid errors
        if [[ -f "$file" ]]; then \
            echo "Uploading $file..."; \
            snapcraft upload --release=edge "$file"; \
        fi
    done

rpi4-requirments-intstall:
    sudo snap install pi --channel=22/stable # provides bt-serial interface

docker-disable:
    #!/bin/bash
    sudo systemctl stop docker.service
    sudo systemctl stop docker.socket
    sudo systemctl restart systemd-sysctl

docker-enable:
    #!/bin/bash
    sudo systemctl start docker.service
    sudo systemctl start docker.socket
    sudo systemctl restart systemd-sysctl

signal-test:
    #!/bin/bash

iterate:
    #!/bin/bash -e
    start_time=$(date +%s)
    
    echo "Starting script..."

    sudo snap remove husarion-rplidar
    sudo rm -rf squashfs-root/
    sudo rm -rf *.snap
    export SNAPCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=1
    snapcraft clean
    snapcraft
    
    end_time=$(date +%s)
    duration=$(( end_time - start_time ))

    hours=$(( duration / 3600 ))
    minutes=$(( (duration % 3600) / 60 ))
    seconds=$(( duration % 60 ))

    printf "Build completed in %02d:%02d:%02d (hh:mm:ss)\n" $hours $minutes $seconds

    sudo unsquashfs husarion-rplidar*.snap
    sudo snap try squashfs-root/
    sudo snap connect husarion-rplidar:raw-usb
    sudo snap connect husarion-rplidar:shm-plug husarion-rplidar:shm-slot

    end_time=$(date +%s)
    duration=$(( end_time - start_time ))

    hours=$(( duration / 3600 ))
    minutes=$(( (duration % 3600) / 60 ))
    seconds=$(( duration % 60 ))

    printf "Script completed in %02d:%02d:%02d (hh:mm:ss)\n" $hours $minutes $seconds


remove:
    #!/bin/bash
    sudo snap remove husarion-rplidar
    sudo rm -rf squashfs-root/

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