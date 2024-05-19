#!/usr/bin/env python3

import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, GroupAction, PushRosNamespace, SetRemap
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node

def generate_launch_description():
    channel_type = LaunchConfiguration('channel_type', default='serial')
    serial_port = LaunchConfiguration('serial_port', default='/dev/ttyUSB0')
    serial_baudrate = LaunchConfiguration('serial_baudrate', default='256000')  # for A3 is 256000
    frame_id = LaunchConfiguration('frame_id', default='laser')
    inverted = LaunchConfiguration('inverted', default='false')
    angle_compensate = LaunchConfiguration('angle_compensate', default='true')
    scan_mode = LaunchConfiguration('scan_mode', default='Sensitivity')
    robot_namespace = LaunchConfiguration('robot_namespace', default='')
    device_namespace = LaunchConfiguration('device_namespace', default='')

    # Conditional frame_id setup based on device_namespace
    def get_frame_id(context):
        device_ns = LaunchConfiguration('device_namespace').perform(context)
        return f"{device_ns}_link" if device_ns else "laser"

    frame_id_substitution = OpaqueFunction(function=get_frame_id)

    return LaunchDescription([

        DeclareLaunchArgument(
            'channel_type',
            default_value=channel_type,
            description='Specifying channel type of lidar'),

        DeclareLaunchArgument(
            'serial_port',
            default_value=serial_port,
            description='Specifying usb port to connected lidar'),

        DeclareLaunchArgument(
            'serial_baudrate',
            default_value=serial_baudrate,
            description='Specifying usb port baudrate to connected lidar'),
        
        DeclareLaunchArgument(
            'frame_id',
            default_value=frame_id,
            description='Specifying frame_id of lidar'),

        DeclareLaunchArgument(
            'inverted',
            default_value=inverted,
            description='Specifying whether or not to invert scan data'),

        DeclareLaunchArgument(
            'angle_compensate',
            default_value=angle_compensate,
            description='Specifying whether or not to enable angle_compensate of scan data'),

        DeclareLaunchArgument(
            'scan_mode',
            default_value=scan_mode,
            description='Specifying scan mode of lidar'),

        DeclareLaunchArgument(
            'robot_namespace',
            default_value='',
            description='Namespace which will appear in front of all topics (including /tf and /tf_static).',
        ),

        DeclareLaunchArgument(
            'device_namespace',
            default_value='',
            description='Sensor namespace that will appear before all non absolute topics and TF frames, used for distinguishing multiple cameras on the same robot.',
        ),

        GroupAction(
            actions=[
                PushRosNamespace(robot_namespace),
                PushRosNamespace(device_namespace),
                SetRemap(src='/tf', dst=[LaunchConfiguration('robot_namespace'), '/tf']),
                SetRemap(src='/tf_static', dst=[LaunchConfiguration('robot_namespace'), '/tf_static']),
                Node(
                    package='rplidar_ros',
                    executable='rplidar_node',
                    name='rplidar_node',
                    parameters=[{
                        'channel_type': channel_type,
                        'serial_port': serial_port,
                        'serial_baudrate': serial_baudrate,
                        'frame_id': frame_id_substitution,
                        'inverted': inverted,
                        'angle_compensate': angle_compensate,
                        'scan_mode': scan_mode
                    }],
                    output='screen'
                )
            ]
        )
    ])
