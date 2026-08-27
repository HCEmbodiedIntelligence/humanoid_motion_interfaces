#!/usr/bin/env bash

set -euo pipefail

python3 - <<'PY'
from humanoid_motion_interfaces.action import MoveJ, MoveL, MoveP
from humanoid_motion_interfaces.msg import MotionOptions, Status


def fields(message_type):
    return tuple(message_type.get_fields_and_field_types())


assert fields(Status) == ('code', 'message')
assert {
    'OK': Status.OK,
    'INVALID_REQUEST': Status.INVALID_REQUEST,
    'LOWER_PRIORITY': Status.LOWER_PRIORITY,
    'PREEMPTED': Status.PREEMPTED,
    'CANCELED': Status.CANCELED,
    'IK_FAILED': Status.IK_FAILED,
    'LIMIT_VIOLATION': Status.LIMIT_VIOLATION,
    'STATE_STALE': Status.STATE_STALE,
    'DRIVER_FAULT': Status.DRIVER_FAULT,
    'TIMEOUT': Status.TIMEOUT,
    'NOT_CONFIGURED': Status.NOT_CONFIGURED,
    'SDK_ERROR': Status.SDK_ERROR,
    'INTERNAL_ERROR': Status.INTERNAL_ERROR,
} == {
    'OK': 0,
    'INVALID_REQUEST': 1,
    'LOWER_PRIORITY': 2,
    'PREEMPTED': 3,
    'CANCELED': 4,
    'IK_FAILED': 5,
    'LIMIT_VIOLATION': 6,
    'STATE_STALE': 7,
    'DRIVER_FAULT': 8,
    'TIMEOUT': 9,
    'NOT_CONFIGURED': 10,
    'SDK_ERROR': 11,
    'INTERNAL_ERROR': 255,
}

assert fields(MotionOptions) == (
    'velocity_scale',
    'acceleration_scale',
    'jerk_scale',
    'timeout_sec',
)

assert fields(MoveJ.Goal) == ('group_name', 'target', 'options')
assert fields(MoveJ.Result) == ('status', 'final_joint_state')
assert fields(MoveJ.Feedback) == ('progress', 'actual_joint_state')

cartesian_goal_fields = ('group_name', 'tip_frame', 'target_pose', 'options')
cartesian_result_fields = ('status', 'final_joint_state', 'final_pose')
cartesian_feedback_fields = ('progress', 'actual_joint_state', 'actual_pose')
for action_type in (MoveL, MoveP):
    assert fields(action_type.Goal) == cartesian_goal_fields
    assert fields(action_type.Result) == cartesian_result_fields
    assert fields(action_type.Feedback) == cartesian_feedback_fields

for goal_type in (MoveJ.Goal, MoveL.Goal, MoveP.Goal):
    goal_fields = fields(goal_type)
    assert 'source_id' not in goal_fields
    assert 'priority' not in goal_fields
PY
