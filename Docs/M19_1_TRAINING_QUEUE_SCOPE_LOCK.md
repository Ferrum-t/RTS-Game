# M19.1 — Training Queue + Progress UI — SCOPE LOCK

**Status:** LOCKED — code only after `M19.1 READY FOR IMPLEMENTATION`  
**Date:** 2026-09-23  
**Product:** Nomad Wars  
**Branch:** `nomads-wars-grok`  
**Related:** `TownCenter.gd`, `Barracks.gd`, selection UI

---

## Goal

Classic RTS training queue: enqueue multiple units, see progress of the current one, cancel with full refund. Player comfort only — no economy/AI redesign.

---

## LOCK decisions

| # | Decision |
|---|----------|
| Max queue | **5** |
| UI location | **Selection only** (selected TC or Barracks) |
| Enqueue while training | **Yes** |
| Cancel | **Cancel last** + **Cancel all** |
| Spend | At **enqueue** |
| Refund | **Full** on cancel (queued or current) |
| Units in scope | TC → **Worker** only; Barracks → **Soldier** only |
| AI | **Unchanged** (still single-slot `try_train_*` path ok if queue is transparent or AI only starts when idle) |
| Cost / train_time | **No change** (Soldier 6.5s, Worker 3.0s, costs as now) |

---

## IN

1. Queue data on TownCenter / Barracks (max 5).
2. `try_train_worker` / `try_train_soldier`: if training, enqueue instead of reject (when under max + can afford).
3. On finish: spawn → auto-start next from queue.
4. Progress: expose remaining / total for UI ProgressBar.
5. UI when building selected (player team): queue slots + current progress bar.
6. Cancel last / Cancel all → full refund via ResourceManager.

---

## OUT

- Food / population limits
- Remote train without selecting building
- AI training queue redesign
- Cavalry / Siege in queue (this slice)
- Cost or train_time balance changes
- Climate, migration, Watchtower, new buildings

---

## Expected files

- `Scripts/Buildings/TownCenter.gd`
- `Scripts/Buildings/Barracks.gd`
- New or existing selection panel script under `Scripts/UI/` (e.g. `TrainingQueuePanel.gd`)
- Possibly `Scenes/UI/ui.tscn` hook for panel

Do **not** modify EconomicAIController unless required only to keep existing AI calls working without behavior change.

---

## F5 acceptance

1. Select TC → queue 3+ Workers → progress bar moves → chain of spawns.
2. Select Barracks → queue 3+ Soldiers → same.
3. Enqueue while one is already training succeeds (until max 5).
4. Cancel last refunds one unit cost; Cancel all refunds remaining queue + current.
5. AI still trains Workers/Soldiers (no regression).
6. 0 script errors; climate / combat / economy costs unchanged.

---

## Gate

Say **`M19.1 READY FOR IMPLEMENTATION`** to authorize code.
