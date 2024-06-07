#!/usr/bin/bash

log_and_echo() {
    local message="$1"
    # Log the message with logger
    logger -t "${SNAP_NAME}" "configure hook: $message"
    # Echo the message to standard error
    echo >&2 "$message"
}

log() {
    local message="$1"
    # Log the message with logger
    logger -t "${SNAP_NAME}" "configure hook: $message"
}

# Source the find_ttyUSB function
source $SNAP/usr/bin/find_ttyUSB.sh

# Get the serial-port value using snapctl
SERIAL_PORT=$(snapctl get serial-port)

# Check if SERIAL_PORT is set to auto
if [ "$SERIAL_PORT" == "auto" ]; then
  # Find the ttyUSB* device
  SERIAL_PORT=$(find_ttyUSB "10c4" "ea60")
  if [ $? -ne 0 ]; then
    log_and_echo "Failed to find the serial port."
    exit 1
  else
    log_and_echo "Found serial port: $SERIAL_PORT"
  fi
else
  # Check if the specified serial port exists
  if [ ! -e "$SERIAL_PORT" ]; then
    log_and_echo "Specified serial port $SERIAL_PORT does not exist."
    exit 1
  else
    log_and_echo "Specified serial port exists: $SERIAL_PORT"
  fi
fi

# Iterate over the snap parameters and retrieve their value.
# If a value is set, it is forwarded to the launch file.
LAUNCH_OPTIONS=""

OPTIONS="\
 channel-type \
 frame-id \
 inverted \
 angle-compensate \
 scan-mode \
 namespace \
 device-namespace \
"

for OPTION in ${OPTIONS}; do
  VALUE="$(snapctl get driver.${OPTION})"
  if [ -n "${VALUE}" ]; then
    LAUNCH_OPTIONS+="${OPTION}:=${VALUE} "
  fi
done

OPTIONS="\
 serial-baudrate \
"

for OPTION in ${OPTIONS}; do
  VALUE="$(snapctl get ${OPTION})"
  if [ -n "${VALUE}" ]; then
    LAUNCH_OPTIONS+="${OPTION}:=${VALUE} "
  fi
done

# Add the serial port to LAUNCH_OPTIONS
LAUNCH_OPTIONS+="serial-port:=${SERIAL_PORT} "

# Replace '-' with '_'
LAUNCH_OPTIONS=$(echo ${LAUNCH_OPTIONS} | tr - _)

if [ "${LAUNCH_OPTIONS}" ]; then
  # watch the log with: "journalctl -t rosbot-xl"
  log_and_echo "Running with options: ${LAUNCH_OPTIONS}"
fi

# Launch the ros2 launch file with the determined options
ros2 launch $SNAP/usr/bin/rplidar.launch.py ${LAUNCH_OPTIONS}
