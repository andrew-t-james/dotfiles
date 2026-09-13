#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


ROLES = {"implementation-coordinator", "advisor"}
LIFECYCLE_TOOLS = {
    "close_agent",
    "followup_task",
    "interrupt_agent",
    "send_input",
    "send_message",
    "wait",
}
ACTIVE_TOOLS = {"followup_task", "send_input"}
SKILL_IDENTITY = re.compile(
    r"^Crew skill: (?P<path>/.*)#sha256:(?P<sha256>[0-9a-f]{64})$",
    re.MULTILINE,
)


class ReceiptError(Exception):
    pass


def load_events(path: Path) -> list[dict]:
    try:
        lines = path.read_text().splitlines()
    except OSError as error:
        raise ReceiptError(f"cannot read receipt: {error}") from error
    if not any(line.strip() for line in lines):
        raise ReceiptError("receipt is empty")

    events = []
    for line_number, line in enumerate(lines, start=1):
        if not line.strip():
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError as error:
            raise ReceiptError(
                f"line {line_number} contains invalid JSON: {error.msg}"
            ) from error
        if not isinstance(event, dict):
            raise ReceiptError(f"event {len(events) + 1} is not an object")
        event_type = event.get("type")
        if not isinstance(event_type, str) or not event_type:
            raise ReceiptError(f"event {len(events) + 1} has no string type")
        if event_type in {"item.started", "item.completed"}:
            item = event.get("item")
            if not isinstance(item, dict):
                raise ReceiptError(f"event {len(events) + 1} item is not an object")
            if item.get("type") == "agent_message" and not isinstance(
                item.get("text"), str
            ):
                raise ReceiptError(
                    f"event {len(events) + 1} agent message has no string text"
                )
            if item.get("type") == "collab_tool_call":
                for field in ("id", "tool", "sender_thread_id"):
                    if not isinstance(item.get(field), str) or not item[field]:
                        raise ReceiptError(
                            f"event {len(events) + 1} collaboration item has no string {field}"
                        )
                receivers = item.get("receiver_thread_ids", [])
                if not isinstance(receivers, list) or not all(
                    isinstance(receiver, str) and receiver for receiver in receivers
                ):
                    raise ReceiptError(
                        f"event {len(events) + 1} has invalid receiver_thread_ids"
                    )
                if "agents_states" in item:
                    states = item["agents_states"]
                    if not isinstance(states, dict) or not all(
                        isinstance(agent_id, str)
                        and agent_id
                        and isinstance(state, dict)
                        for agent_id, state in states.items()
                    ):
                        raise ReceiptError(
                            f"event {len(events) + 1} has invalid agents_states"
                        )
        events.append(event)
    return events


def role_from_prompt(prompt: object) -> str | None:
    if not isinstance(prompt, str):
        return None
    lines = prompt.splitlines()
    markers = [line for line in lines if line.startswith("Crew role: ")]
    if len(markers) != 1 or not lines or markers[0] != lines[0]:
        return None
    role = markers[0].removeprefix("Crew role: ")
    return role if role in ROLES else None


def validate(events: list[dict], expected_skill_sha256: str) -> dict:
    errors = []
    thread_starts = [
        (index, event)
        for index, event in enumerate(events)
        if event.get("type") == "thread.started"
    ]
    if len(thread_starts) != 1:
        errors.append(
            f"expected exactly one thread.started event, found {len(thread_starts)}"
        )
    root_thread_id = None
    if len(thread_starts) == 1:
        thread_index, thread_event = thread_starts[0]
        root_thread_id = thread_event.get("thread_id")
        if thread_index != 0:
            errors.append("thread.started is not the first event")
        if not isinstance(root_thread_id, str) or not root_thread_id:
            errors.append("thread.started has no string thread_id")
            root_thread_id = None

    turn_starts = [
        index
        for index, event in enumerate(events)
        if event.get("type") == "turn.started"
    ]
    turn_completions = [
        index
        for index, event in enumerate(events)
        if event.get("type") == "turn.completed"
    ]
    if len(turn_starts) != 1:
        errors.append(
            f"expected exactly one turn.started event, found {len(turn_starts)}"
        )
    elif turn_starts[0] != 1:
        errors.append("turn.started does not immediately follow thread.started")
    if len(turn_completions) != 1:
        errors.append(
            f"expected exactly one turn.completed event, found {len(turn_completions)}"
        )
    if len(turn_completions) == 1 and turn_completions[0] != len(events) - 1:
        errors.append("turn.completed is not the final event")

    root_collaboration = []
    if root_thread_id:
        root_collaboration = [
            (index, event["item"])
            for index, event in enumerate(events)
            if event.get("type") in {"item.started", "item.completed"}
            and event["item"].get("type") == "collab_tool_call"
            and event["item"].get("sender_thread_id") == root_thread_id
        ]

    calls_by_id: dict[str, list[tuple[int, str, dict]]] = {}
    for index, item in root_collaboration:
        calls_by_id.setdefault(item["id"], []).append(
            (index, events[index]["type"], item)
        )

    valid_calls = []
    for item_id, occurrences in calls_by_id.items():
        started = [entry for entry in occurrences if entry[1] == "item.started"]
        completed = [entry for entry in occurrences if entry[1] == "item.completed"]
        if len(started) != 1 or len(completed) != 1 or started[0][0] >= completed[0][0]:
            errors.append(f"collaboration item {item_id} has an invalid lifecycle pair")
            continue
        start_index, _, start_item = started[0]
        complete_index, _, complete_item = completed[0]
        for field in ("tool", "sender_thread_id", "prompt"):
            if start_item.get(field) != complete_item.get(field):
                errors.append(
                    f"collaboration item {item_id} changes {field} during its lifecycle"
                )
        completed_receivers = complete_item.get("receiver_thread_ids", [])
        if (
            start_item.get("tool") != "spawn_agent"
            and completed_receivers
            and start_item.get("receiver_thread_ids", []) != completed_receivers
        ):
            errors.append(
                f"collaboration item {item_id} changes targets during its lifecycle"
            )
        valid_calls.append((start_index, complete_index, start_item, complete_item))
    skill_identities = []
    root_messages = []
    for index, event in enumerate(events):
        if (
            event.get("type") == "item.completed"
            and event["item"].get("type") == "agent_message"
        ):
            root_messages.append(index)
            for match in SKILL_IDENTITY.finditer(event["item"].get("text", "")):
                skill_identities.append(
                    (index, match.group("path"), match.group("sha256"))
                )
    skill_path = None
    skill_sha256 = None
    if len(skill_identities) != 1:
        errors.append(
            f"expected exactly one Crew skill identity, found {len(skill_identities)}"
        )
    else:
        skill_index, skill_path, skill_sha256 = skill_identities[0]
        if skill_sha256 != expected_skill_sha256:
            errors.append(
                f"Crew skill identity hash {skill_sha256} does not match expected {expected_skill_sha256}"
            )
        if valid_calls and skill_index > valid_calls[0][0]:
            errors.append("Crew skill identity follows the first collaboration action")

    first_collaboration_action = None
    first_action_is_coordinator_spawn = False
    if valid_calls:
        _, _, first_start, _ = valid_calls[0]
        first_role = role_from_prompt(first_start.get("prompt"))
        first_collaboration_action = (
            f"{first_role or 'unclassified'} {first_start['tool']}"
        )
        first_action_is_coordinator_spawn = (
            first_start["tool"] == "spawn_agent"
            and first_role == "implementation-coordinator"
        )

    coordinator_ids = []
    advisor_ids = []
    agent_states: dict[str, str] = {}
    failed_coordinator_spawns = 0
    last_child_action = -1
    for _, complete_index, start_item, complete_item in valid_calls:
        tool = start_item["tool"]
        if tool == "spawn_agent":
            role = role_from_prompt(start_item.get("prompt"))
            receivers = complete_item.get("receiver_thread_ids", [])
            succeeded = complete_item.get("status") == "completed" and bool(receivers)
            if role is None:
                if succeeded:
                    errors.append(
                        "successful root spawn has an invalid Crew role marker"
                    )
                continue
            if not succeeded:
                if (
                    role == "implementation-coordinator"
                    and complete_item.get("status") == "failed"
                ):
                    failed_coordinator_spawns += 1
                continue
            if len(receivers) != 1:
                errors.append(f"{role} spawn returned {len(receivers)} agent IDs")
                continue
            agent_id = receivers[0]
            if agent_id in agent_states:
                errors.append(f"agent ID {agent_id} was spawned more than once")
                continue
            agent_states[agent_id] = "active"
            last_child_action = complete_index
            if role == "implementation-coordinator":
                coordinator_ids.append(agent_id)
            else:
                advisor_ids.append(agent_id)
            continue
        if tool not in LIFECYCLE_TOOLS:
            continue
        receivers = start_item.get("receiver_thread_ids", [])
        if not receivers:
            errors.append(f"{tool} has no target")
            continue
        unknown_ids = sorted(set(receivers) - set(agent_states))
        if unknown_ids:
            errors.append(f"{tool} targets unknown agent(s): {', '.join(unknown_ids)}")
            continue
        last_child_action = complete_index
        for agent_id in receivers:
            if tool in ACTIVE_TOOLS:
                agent_states[agent_id] = "active"
                continue
            if tool == "interrupt_agent":
                agent_states[agent_id] = "interrupted"
                continue
            if tool == "send_message":
                continue
            status = (
                complete_item.get("agents_states", {}).get(agent_id, {}).get("status")
            )
            if status in {"completed", "done"}:
                agent_states[agent_id] = "completed"
            elif status in {"blocked", "errored", "failed", "interrupted"}:
                agent_states[agent_id] = status
            elif status in {"active", "pending", "running", "working"}:
                agent_states[agent_id] = "active"

    if len(coordinator_ids) != 1:
        errors.append(
            f"expected exactly one successful coordinator spawn, found {len(coordinator_ids)}"
        )
    if not first_action_is_coordinator_spawn:
        errors.append("first root collaboration action was not a coordinator spawn")
    if failed_coordinator_spawns > 1:
        errors.append(
            f"expected at most one failed coordinator spawn, found {failed_coordinator_spawns}"
        )

    coordinator_id = coordinator_ids[0] if len(coordinator_ids) == 1 else None
    coordinator_state = agent_states.get(coordinator_id, "not-started")
    advisor_states = {agent_id: agent_states[agent_id] for agent_id in advisor_ids}
    if coordinator_id and coordinator_state != "completed":
        errors.append(f"coordinator's final state is {coordinator_state}")
    for advisor_id, state in advisor_states.items():
        if state != "completed":
            errors.append(f"advisor {advisor_id} final state is {state}")

    final_message_after_coordination = bool(
        root_messages and root_messages[-1] > last_child_action
    )
    if not final_message_after_coordination:
        errors.append("no final message followed coordinator completion")
    return {
        "ok": not errors,
        "root_thread_id": root_thread_id,
        "skill_path": skill_path,
        "skill_sha256": skill_sha256,
        "coordinator_id": coordinator_id,
        "advisor_ids": advisor_ids,
        "advisor_states": advisor_states,
        "failed_coordinator_spawns": failed_coordinator_spawns,
        "first_collaboration_action": first_collaboration_action,
        "coordinator_state": coordinator_state,
        "turn_completed": len(turn_completions) == 1,
        "final_message_after_coordination": final_message_after_coordination,
        "errors": errors,
    }


def failure_report(error: ReceiptError) -> dict:
    return {
        "ok": False,
        "root_thread_id": None,
        "skill_path": None,
        "skill_sha256": None,
        "coordinator_id": None,
        "advisor_ids": [],
        "advisor_states": {},
        "failed_coordinator_spawns": 0,
        "first_collaboration_action": None,
        "coordinator_state": "unknown",
        "turn_completed": False,
        "final_message_after_coordination": False,
        "errors": [str(error)],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate a Codex Crew JSONL receipt.")
    parser.add_argument("--skill-sha256", required=True)
    parser.add_argument("receipt", type=Path)
    args = parser.parse_args()
    try:
        if not re.fullmatch(r"[0-9a-f]{64}", args.skill_sha256):
            raise ReceiptError("--skill-sha256 must be 64 lowercase hex characters")
        report = validate(load_events(args.receipt), args.skill_sha256)
    except ReceiptError as error:
        report = failure_report(error)
    print(json.dumps(report, indent=2))
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
