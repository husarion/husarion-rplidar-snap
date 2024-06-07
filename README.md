# husarion-rplidar-snap

Snap for Orbbec Astra customized for Husarion robots

## Apps

| app | description |
| - | - |
| `husarion-rplidar.start` | Start the `husarion-rplidar.daemon` service |
| `husarion-rplidar.stop` | Stop the `husarion-rplidar.daemon` service |
| `husarion-rplidar` | Start the application in the foreground (run in the current terminal). Remember to stop the daemon first |

## Setup RPLIDAR Params

All `husarion-rplidar` ROS 2 params are available over a separate key:

| Key | Default Value |
| driver.device-namespace | (unset) |
| driver.namespace | (unset) |
| driver.scan-mode | (unset) |
| driver.channel-type | serial |
| driver.frame-id | laser |
| driver.inverted | false |
| driver.angle-compensate | true |

To set the parameters, use the snap set command, e.g.,

```bash
snap set husarion-rplidar driver.namespace=myrobot
```

Additionally there are the following params available:

| Key | Default Value |
| driver | {...} |
| ros-domain-id | 0 |
| ros-localhost-only | 0 |
| transport | udp |
| serial-port | auto |
| serial-baudrate | 256000 |

Available DDS configs for `transport` params are `builtin`, `udp` and `shm`.

Configurations for `udp` and `shm` you can modify under this path.

```bash
$ ls /var/snap/husarion-rplidar/common/
shm.xml  udp.xml
```

You can also create your own DDS config files place them in this folder and use them with:

```bash
sudo snap set husarion-rplidar transport=my-custom-transport
```

By default `serial-port` is set to `auto`, so it tries to automatically determine the serial port under which the LIDAR is connected. If you have multiple LIDARs rather set a full path to the serial interface (or a symlink):

```bash
sudo snap set husarion-rplidar serial=/dev/ttyUSB0
```