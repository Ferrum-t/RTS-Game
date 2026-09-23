# M19.2 — Remote / Quick Train — SCOPE LOCK

**Status:** LOCKED — code only after `M19.2 READY FOR IMPLEMENTATION`  
**Date:** 2026-09-23  
**Product:** Nomad Wars  
**Branch:** `nomads-wars-grok`  
**Prerequisite:** M19.1 Training Queue ACCEPTED  
**Related:** `TrainWorkerButton.gd`, `TrainSoldierButton.gd`, `CommandBar.gd`, `ui.tscn`

---

## Goal

Order Worker / Soldier from anywhere on the map without returning the camera to base. Reuse M19.1 queue; no new economy.

---

## LOCK decisions

| # | Decision |
|---|----------|
| **1 Visibility** | **B** — buttons visible only if player has ≥1 living TC (Worker btn) / ≥1 living Barracks (Soldier btn) |
| **2 Routing** | **B** — selected matching building if any → else first with free queue slot (pipeline < 5) → else first living |
| **3 Feedback** | **Yes minimal** — `disabled` + short text/tooltip hint: no building / no resources / queue full |

---

## IN

1. Quick Train **Worker** and **Soldier** accessible without requiring building selection.
2. Visibility rule B (presence of building type).
3. Target resolution B (selected → free slot → first alive).
4. Calls existing `try_train_worker` / `try_train_soldier` (M19.1 queue, spend on enqueue).
5. Minimal disabled + hint on buttons.

---

## OUT

- Hotkeys
- Food / population limits
- AI changes
- Cost / train_time changes
- Climate
- New buildings
- Full selection UI rewrite
- Collapsible production panel (option C deferred)

---

## Expected files

- `Scripts/UI/CommandBar.gd` and/or `Scenes/UI/ui.tscn` — always-available Quick Train group with visibility B
- `Scripts/UI/TrainWorkerButton.gd` — routing B + disabled hints
- `Scripts/UI/TrainSoldierButton.gd` — same

Do not change EconomicAIController, climate, or train costs/times.

---

## F5 acceptance

1. Camera at enemy base → Train Soldier → enqueues on a player Barracks (log/queue).
2. Same for Worker → player TC.
3. With Barracks selected → order goes to **that** Barracks.
4. Queue full (5) or no wood → button disabled / clear reject.
5. M19.1 selection panel + cancel still work.
6. 0 script errors; AI train unchanged.

---

## Gate

Say **`M19.2 READY FOR IMPLEMENTATION`** to authorize code.
