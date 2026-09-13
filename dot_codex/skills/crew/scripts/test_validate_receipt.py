from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).with_name("validate_receipt.py")
SKILL_SHA256 = "a" * 64


def run_path(
    path: Path,
    skill_sha256: str = SKILL_SHA256,
) -> tuple[subprocess.CompletedProcess[str], dict]:
    result = subprocess.run(
        [
            sys.executable,
            str(SCRIPT),
            "--skill-sha256",
            skill_sha256,
            str(path),
        ],
        capture_output=True,
        text=True,
    )
    return result, json.loads(result.stdout)


def run_receipt(events: list[object]) -> tuple[subprocess.CompletedProcess[str], dict]:
    with tempfile.TemporaryDirectory() as directory:
        receipt = Path(directory) / "run.jsonl"
        receipt.write_text("".join(json.dumps(event) + "\n" for event in events))
        return run_path(receipt)


def message(item_id: str, text: str) -> dict:
    return {
        "type": "item.completed",
        "item": {"id": item_id, "type": "agent_message", "text": text},
    }


def tool_pair(
    item_id: str,
    tool: str,
    *,
    prompt: str | None = None,
    receivers: list[str] | None = None,
    status: str = "completed",
    states: dict | None = None,
) -> list[dict]:
    common = {
        "id": item_id,
        "type": "collab_tool_call",
        "tool": tool,
        "sender_thread_id": "root",
        "receiver_thread_ids": receivers or [],
        "prompt": prompt,
    }
    return [
        {"type": "item.started", "item": {**common, "status": "in_progress"}},
        {
            "type": "item.completed",
            "item": {
                **common,
                "status": status,
                "agents_states": states or {},
            },
        },
    ]


def coordinator_spawn(item_id: str = "spawn", child: str = "coord") -> list[dict]:
    return tool_pair(
        item_id,
        "spawn_agent",
        prompt="Crew role: implementation-coordinator\n\nComplete the bounded work.",
        receivers=[child],
    )


def advisor_spawn(item_id: str = "advisor", child: str = "advisor-1") -> list[dict]:
    return tool_pair(
        item_id,
        "spawn_agent",
        prompt="Crew role: advisor\n\nAnswer one read-only question.",
        receivers=[child],
    )


def completed_wait(item_id: str = "wait", child: str = "coord") -> list[dict]:
    return tool_pair(
        item_id,
        "wait",
        receivers=[child],
        states={child: {"status": "completed"}},
    )


def valid_events() -> list[dict]:
    return [
        {"type": "thread.started", "thread_id": "root"},
        {"type": "turn.started"},
        message(
            "plan",
            "Preparing the review.\n"
            "Crew skill: /tmp/project/.agents/skills/crew/SKILL.md#sha256:"
            + SKILL_SHA256,
        ),
        *coordinator_spawn(),
        *completed_wait(),
        *tool_pair(
            "close",
            "close_agent",
            receivers=["coord"],
            states={"coord": {"status": "completed"}},
        ),
        message("final", "Verified final answer."),
        {"type": "turn.completed", "usage": {"input_tokens": 100, "output_tokens": 20}},
    ]


class ValidateReceiptTests(unittest.TestCase):
    def test_accepts_complete_coordinator_lifecycle(self) -> None:
        result, report = run_receipt(valid_events())

        self.assertEqual(result.returncode, 0)
        self.assertTrue(report["ok"])
        self.assertEqual(report["coordinator_id"], "coord")
        self.assertEqual(report["coordinator_state"], "completed")
        self.assertEqual(report["skill_sha256"], SKILL_SHA256)
        self.assertEqual(report["errors"], [])

    def test_accepts_one_failed_coordinator_spawn_before_success(self) -> None:
        failed = tool_pair(
            "failed",
            "spawn_agent",
            prompt="Crew role: implementation-coordinator\n\nComplete the bounded work.",
            status="failed",
        )
        events = valid_events()
        events[3:3] = failed
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 0)
        self.assertEqual(report["failed_coordinator_spawns"], 1)

    def test_accepts_advisor_after_coordinator(self) -> None:
        events = valid_events()
        events[5:5] = advisor_spawn() + completed_wait("advisor-wait", "advisor-1")
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 0)
        self.assertEqual(report["advisor_ids"], ["advisor-1"])
        self.assertEqual(report["advisor_states"], {"advisor-1": "completed"})

    def test_rejects_active_advisor_at_final(self) -> None:
        events = valid_events()
        events[5:5] = advisor_spawn()
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertIn("advisor advisor-1 final state is active", report["errors"])

    def test_rejects_wait_without_coordinator(self) -> None:
        events = valid_events()
        events[3:9] = tool_pair("wait", "wait")
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertIn(
            "expected exactly one successful coordinator spawn, found 0",
            report["errors"],
        )
        self.assertIn(
            "first root collaboration action was not a coordinator spawn",
            report["errors"],
        )
        self.assertIn("wait has no target", report["errors"])

    def test_rejects_two_coordinators(self) -> None:
        events = valid_events()
        events[5:5] = coordinator_spawn("second", "coord-2")
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertIn(
            "expected exactly one successful coordinator spawn, found 2",
            report["errors"],
        )

    def test_rejects_role_marker_not_first_or_repeated(self) -> None:
        for prompt in (
            "Intro\nCrew role: implementation-coordinator",
            "Crew role: implementation-coordinator\nCrew role: advisor",
        ):
            with self.subTest(prompt=prompt):
                events = valid_events()
                events[3:5] = tool_pair(
                    "spawn", "spawn_agent", prompt=prompt, receivers=["coord"]
                )
                result, report = run_receipt(events)

                self.assertEqual(result.returncode, 1)
                self.assertIn(
                    "successful root spawn has an invalid Crew role marker",
                    report["errors"],
                )

    def test_rejects_unclassified_root_spawn(self) -> None:
        events = valid_events()
        events[5:5] = tool_pair(
            "unknown",
            "spawn_agent",
            prompt="Inspect the repository.",
            receivers=["unknown"],
        )
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertIn(
            "successful root spawn has an invalid Crew role marker", report["errors"]
        )

    def test_rejects_advisor_before_coordinator(self) -> None:
        events = valid_events()
        events[3:3] = advisor_spawn()
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertIn(
            "first root collaboration action was not a coordinator spawn",
            report["errors"],
        )

    def test_rejects_targetless_and_unknown_target_actions(self) -> None:
        for action in (
            tool_pair("extra", "wait"),
            tool_pair("extra", "wait", receivers=["stranger"]),
        ):
            with self.subTest(action=action):
                events = valid_events()
                events[5:5] = action
                result, report = run_receipt(events)

                self.assertEqual(result.returncode, 1)
                self.assertTrue(any("target" in error for error in report["errors"]))

    def test_rejects_followup_after_coordinator_completion(self) -> None:
        events = valid_events()
        events[-2:-2] = tool_pair("followup", "followup_task", receivers=["coord"])
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertEqual(report["coordinator_state"], "active")
        self.assertIn("coordinator's final state is active", report["errors"])

    def test_rejects_action_targeting_future_coordinator(self) -> None:
        failed = tool_pair(
            "failed",
            "spawn_agent",
            prompt="Crew role: implementation-coordinator\n\nComplete the bounded work.",
            status="failed",
        )
        events = valid_events()
        events[3:3] = failed + completed_wait("premature")
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertIn("wait targets unknown agent(s): coord", report["errors"])

    def test_rejects_missing_or_duplicate_tool_pair(self) -> None:
        missing = valid_events()
        missing.pop(4)
        duplicate = valid_events()
        duplicate.insert(5, duplicate[4])
        for events in (missing, duplicate):
            with self.subTest(events=events):
                result, report = run_receipt(events)

                self.assertEqual(result.returncode, 1)
                self.assertTrue(any("lifecycle" in error for error in report["errors"]))

    def test_rejects_changed_nonempty_target_during_pair(self) -> None:
        events = valid_events()
        events[6]["item"]["receiver_thread_ids"] = ["advisor-1"]
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertIn(
            "collaboration item wait changes targets during its lifecycle",
            report["errors"],
        )

    def test_rejects_missing_or_concatenated_thread(self) -> None:
        missing = valid_events()[1:]
        concatenated = valid_events() + valid_events()
        for events in (missing, concatenated):
            with self.subTest(events=events):
                result, report = run_receipt(events)

                self.assertEqual(result.returncode, 1)
                self.assertTrue(
                    any("thread.started" in error for error in report["errors"])
                )

    def test_rejects_turn_completion_before_final_message(self) -> None:
        events = valid_events()
        events[-2], events[-1] = events[-1], events[-2]
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertIn("turn.completed is not the final event", report["errors"])

    def test_rejects_turn_start_after_work(self) -> None:
        events = valid_events()
        events[1], events[2] = events[2], events[1]
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertIn(
            "turn.started does not immediately follow thread.started", report["errors"]
        )

    def test_reports_malformed_item_without_traceback(self) -> None:
        events = [
            {"type": "thread.started", "thread_id": "root"},
            {"type": "turn.started"},
            {"type": "item.started", "item": None},
        ]
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertIn("event 3 item is not an object", report["errors"])
        self.assertNotIn("Traceback", result.stderr)

    def test_reports_null_agent_states_without_traceback(self) -> None:
        events = valid_events()
        events[6]["item"]["agents_states"] = None
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertIn("event 7 has invalid agents_states", report["errors"])
        self.assertNotIn("Traceback", result.stderr)

    def test_reports_null_agent_message_without_traceback(self) -> None:
        events = valid_events()
        events[2]["item"]["text"] = None
        result, report = run_receipt(events)

        self.assertEqual(result.returncode, 1)
        self.assertIn("event 3 agent message has no string text", report["errors"])
        self.assertNotIn("Traceback", result.stderr)

    def test_reports_missing_file_as_json(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            result, report = run_path(Path(directory) / "missing.jsonl")

        self.assertEqual(result.returncode, 1)
        self.assertFalse(report["ok"])
        self.assertTrue(report["errors"][0].startswith("cannot read receipt:"))

    def test_rejects_missing_or_wrong_skill_identity(self) -> None:
        missing = valid_events()
        missing[2] = message("plan", "Preparing the review.")
        wrong = valid_events()
        wrong[2] = message(
            "plan",
            "Crew skill: /tmp/project/.agents/skills/crew/SKILL.md#sha256:" + "b" * 64,
        )
        for events in (missing, wrong):
            with self.subTest(events=events):
                result, report = run_receipt(events)

                self.assertEqual(result.returncode, 1)
                self.assertTrue(
                    any("skill identity" in error for error in report["errors"])
                )


if __name__ == "__main__":
    unittest.main()
