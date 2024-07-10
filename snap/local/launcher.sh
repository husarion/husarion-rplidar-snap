#!/bin/bash -e

source $SNAP/usr/bin/utils.sh

# Iterate over the snap parameters and retrieve their value.
# If a value is set, it is forwarded to the launch file.
OPTIONS=(
 channel-type
 serial-port
 serial-baudrate
 frame-id
 inverted
 angle-compensate
 scan-mode
 device-namespace
)

# Check if SERIAL_PORT is set to auto or specified
SERIAL_PORT=$(find_ttyUSB driver.serial-port "10c4")
if [ $? -ne 0 ]; then
  log_and_echo "Failed to find the serial port."
  exit 1
else
  log_and_echo "Found serial port: $SERIAL_PORT"
fi

# Check if the specified serial port exists
if [ ! -e "$SERIAL_PORT" ]; then
  log_and_echo "Specified serial port $SERIAL_PORT does not exist."
  exit 1
else
  log_and_echo "Specified serial port exists: $SERIAL_PORT"
fi

LAUNCH_OPTIONS=""

for OPTION in "${OPTIONS[@]}"; do
  VALUE="$(snapctl get driver.${OPTION})"
  
  if [ "${OPTION}" == "serial-port" ]; then
    VALUE="$SERIAL_PORT"
  fi

  if [ -n "${VALUE}" ]; then
    OPTION_WITH_UNDERSCORE=$(echo ${OPTION} | tr - _)
    LAUNCH_OPTIONS+="${OPTION_WITH_UNDERSCORE}:=${VALUE} "
  fi
done

if [ "${LAUNCH_OPTIONS}" ]; then
  # watch the log with: "journalctl -t rosbot-xl"
  log "Running with options: ${LAUNCH_OPTIONS}"
fi

ros2 launch $SNAP/usr/bin/rplidar.launch.py ${LAUNCH_OPTIONS}
