## husarion-rplidar-snap

Snap for SLAMTEC LIDARs customized for Husarion robots.

## Apps

| app | description |
| - | - |
| `husarion-rplidar.start` | Start the `husarion-rplidar.daemon` service |
| `husarion-rplidar.stop` | Stop the `husarion-rplidar.daemon` service |
| `husarion-rplidar` | Start the application in the foreground (run in the current terminal). Remember to stop the daemon first |

## Quick start

1. Connect the RPLIDAR to the USB port.
2. Install the snap:

   ```bash
   sudo snap install husarion-rplidar
   ```

3. Verify the `/scan` topic is available:

   ```bash
   ros2 topic list
   ```

   You should see `/scan` listed.

## Unplugging and Plugging the LIDAR

### Before Unplugging

Run the following command to stop the service:

```bash
husarion-rplidar.stop
```

### After Plugging Back In

Run the following command to start the service:

```bash
husarion-rplidar.start
```

### Restarting the Driver

If you need to restart the driver, run:

```bash
husarion-rplidar.stop
husarion-rplidar.start
```

## Setup RPLIDAR Params

### ROS 2 Parameters

All `husarion-rplidar` ROS 2 parameters are available under the `driver` key.

| Key | Default Value |
| driver.device-namespace | (unset) |
| driver.namespace | (unset) |
| driver.scan-mode | (unset) |
| driver.channel-type | serial |
| driver.frame-id | laser |
| driver.inverted | false |
| driver.angle-compensate | true |

to set the parameters, use the `snap set` command. For example:

```bash
snap set husarion-rplidar driver.namespace=myrobot
```

### Additional Parameters

| Key | Default Value |
| driver | {...} |
| ros-domain-id | 0 |
| ros-localhost-only | 0 |
| transport | udp |
| serial-port | auto |
| serial-baudrate | 256000 |

Available DDS configs for the `transport` parameter are `builtin`, `udp` and `shm`.

You can modify configurations for `udp` and `shm` under this path:

```bash
ls /var/snap/husarion-rplidar/common/
```

You should see:

```bash
shm.xml  udp.xml
```

You can also create your own DDS config files, eg.:

```bash
vim /var/snap/husarion-rplidar/common/my-custom-transport.xml
```

and use them with:

```bash
sudo snap set husarion-rplidar transport=my-custom-transport
```

By default, `serial-port` is set to `auto`, which tries to automatically determine the serial port where the LIDAR is connected. If you have multiple LIDARs, it's recommended to set the full path to the serial interface (or a symlink):

```bash
sudo snap set husarion-rplidar serial=/dev/ttyUSB0
```