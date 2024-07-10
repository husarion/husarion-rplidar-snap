# husarion-rplidar-snap

Snap package for RPLIDAR lidars with configurations for Husarion robots

## Apps

| app | description |
| - | - |
| `husarion-rplidar.start` | Start the `husarion-rplidar.daemon` service |
| `husarion-rplidar.stop` | Stop the `husarion-rplidar.daemon` service |
| `husarion-rplidar` | Start the application in the foreground (run in the current terminal). Remember to stop the daemon first |


## Using the snap

### Choosing a LIDAR model

```bash
sudo snap set husarion-rplidar configuration=s2
```

### Change `ROS_DOMAIN_ID`

```bash
sudo snap set husarion-rplidar ros.domain-id=12
```

### Change `NAMESPACE`

```bash
sudo snap set husarion-rplidar ros.namespace=abc
```

