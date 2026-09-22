# ME-0 — Migration Info / Climate Feedback — SCOPE LOCK

**Status:** LOCKED — implementation only after `ME-0 READY FOR IMPLEMENTATION`  
**Date:** 2026-09-22  
**Product:** Nomad Wars  
**Branch:** `nomads-wars-grok`  
**Prerequisite:** Climate v0.1 ACCEPTED  
**Related:** Migration Economics PRE-CODE AUDIT, `EnvironmentZoneService.gd`

---

## Goal

Make existing climate pressure **legible** so the player can consciously choose:

```text
STAY  |  PACK → MOVE → UNPACK  |  BUILD NEW TC
```

**No** mechanical advantage or cost is added. Information / feedback only.

---

## IN

| Item | Notes |
|------|--------|
| Player-facing signal on **R0** state change | Extend existing `_emit_home_region_signal` |
| Short indication of regional economic pressure | State name + harvest mult (existing `_MULT`) |
| Existing data only | `get_region_state`, `_MULT` — no new systems |
| Log path | Reuse `[CLIMATE]` prints; keep readable |
| Optional on-screen | Prefer Label3D on R0 disc/label if already present; **no** new Control UI tree |

### Example target log line

```text
[CLIMATE] R0 FAVORABLE → DRY  mult=0.5  (home pressure ↑ — harvest weaker, horses offline in region)
[CLIMATE] R0 DRY → FAVORABLE  mult=1.5  (home pressure ↓)
```

Exact wording may be shortened; must stay one concise line.

---

## OUT

- ME-1 resource Pack cost
- Climate-dependent Pack cost / horse migration cost
- Pack/Unpack FSM changes
- Forced / automatic Pack
- AI migration or scoring
- New economy systems
- 12-month calendar / migration screen
- Neutral Camps, Climate v0.2, unpack anti-deadlock, horse visual hide

---

## Implementation path (when READY)

**Primary file:** `Scripts/Systems/EnvironmentZoneService.gd`  
- Enrich `_emit_home_region_signal("R0")` with mult + short pressure hint  
- Do **not** touch `DeploymentComponent`, `ResourceManager`, AI, Pack buttons

**Secondary (optional, only if zero risk):** update R0 `Label3D` text to include mult when state changes (already refreshed in `_update_visual_colors`).

---

## F5 acceptance

1. R0 state change → clear `[CLIMATE]` line with mult / pressure sense
2. Player can still Pack / 2nd TC / Stay unchanged
3. No new costs, no auto-pack
4. Climate v0.1 horse gate still works
5. Zero script errors; M18.x intact

---

## Gate

Say **`ME-0 READY FOR IMPLEMENTATION`** to authorize code.
