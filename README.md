# humanoid_motion_interfaces

ROS 2 Humble 的 humanoid motion 公共接口包。该包只定义消息和动作，
不包含运动算法或执行逻辑。ROS 边界统一使用 rad、m 和 s。

## 消息

- `Status`：统一的结果状态码和诊断文本。
- `MotionOptions`：速度、加速度、jerk 比例及超时选项。所有字段为 `0` 时使用
  YAML 默认值；非零比例必须位于 `(0, 1]`；`timeout_sec=0` 使用默认 60 秒。

## 动作

- `MoveJ`：命名关节目标。
- `MoveL`：笛卡尔直线目标位姿。
- `MoveP`：笛卡尔目标位姿。

动作反馈中的 `progress` 由执行端限制在 `[0, 1]`。控制源身份和优先级由服务端
YAML 端点配置确定，不属于消息字段。

## 连续伺服 Topic

- `ServoJ`：以 `sensor_msgs/msg/JointState` 连续发送即时关节目标；使用
  `name` 和 `position`，关节角单位为 rad。
- `ServoP`：以 `geometry_msgs/msg/PoseStamped` 连续发送即时末端目标；
  `header.frame_id` 指定参考坐标系，位置单位为 m，姿态使用单位四元数。

ServoJ/ServoP 是 Topic，不是一次性 Service 或 Action。服务端默认以 100 Hz
执行控制循环，发布端也应以 100 Hz（10 ms 周期）持续刷新目标。订阅端使用
sensor-data QoS；发布端应使用兼容的 best-effort、volatile QoS。停止刷新后，
目标会在配置的 Servo lease 到期时失效（默认 100 ms）。具体 Topic 名称、关节组、
优先级、base frame 和 tip frame 由服务端 `channels.yaml` 配置。

该包不提供公开 FK/IK Service。末端命令所需的运动学求解属于服务端内部实现，
不会作为 `/kinematics/fk` 或 `/kinematics/ik` 暴露。

例如，默认配置可按 100 Hz 连续发送目标：

```bash
ros2 topic pub -r 100 --qos-reliability best_effort \
  --qos-durability volatile \
  /teleop/servo_j sensor_msgs/msg/JointState \
  "{name: [right_shoulder_pitch, right_elbow], position: [0.2, -0.5]}"

ros2 topic pub -r 100 --qos-reliability best_effort \
  --qos-durability volatile \
  /teleop/servo_p geometry_msgs/msg/PoseStamped \
  "{header: {frame_id: base_link}, pose: {position: {x: 0.4, y: 0.2, z: 0.8}, orientation: {w: 1.0}}}"
```

## 构建与测试

```bash
colcon --log-base log_interfaces build \
  --build-base build_interfaces \
  --install-base install_interfaces \
  --packages-select humanoid_motion_interfaces

colcon --log-base log_interfaces test \
  --build-base build_interfaces \
  --install-base install_interfaces \
  --packages-select humanoid_motion_interfaces

colcon test-result --test-result-base build_interfaces --verbose
```

测试会加载生成的 Python 接口，核对消息字段、动作结构、状态常量，并验证
动作目标中不存在 `source_id` 或 `priority`。
