# CURRENT STATE

**Gameplay scope:** [`nomad_wars_v1_scope_and_architecture.md`](nomad_wars_v1_scope_and_architecture.md)  
**Vision:** [`12_PROGRESSION_AND_TIER_SYSTEM.md`](12_PROGRESSION_AND_TIER_SYSTEM.md)  
**Stage 1.5 design (parked):** [`DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`](DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md)  
**Tech debt:** [`TECH_DEBT.md`](TECH_DEBT.md)  
**Process:** [`ACCEPTANCE_AND_PROCESS.md`](ACCEPTANCE_AND_PROCESS.md)

**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-19

---

## Active sprint

| Field | Value |
|--------|--------|
| **Now** | **M17.0 — Variant C: Minimal AI 2nd TC expansion** (scope locked, not implemented) |
| **Not now** | Stage 1.5 climate B–G, Economy 1.5, combat polish (M17.1), AI pack/repair |

Player has a full T1 eco/build loop. AI still runs Stage-1 single-base economy. That asymmetry is the current product gap.

---

## Stage 1 — ACCEPTED (2026-09-01)

T1 economic AI opponent, shared production/combat, no AI migration, no T2. Evidence: multiple F5 full matches.

---

## Player systems M10–M16 — IN CODE (2026-09-16 … 09-19)

Formal F5 acceptance rows are not all logged in this file; **git on `nomads-wars-grok` is the fact source**.

| ID | Content |
|----|---------|
| **M10** | Worker construction: site + BUILD order + progress; gates on train/combat while under construction |
| **M10.1** | Build only with selected Worker; BuildPanel/CommandBar context |
| **M10.1b/c** | Bottom command bar; train prefers selected building; Esc/RMB ghost cancel; TC in Worker build bar |
| **M10.2** | Under-construction visual + progress bar; resume BUILD on incomplete; footprint stand range |
| **M11** | Spawn 4 player Workers at match start (rally cluster) |
| **M12** | Multi-worker REPAIR (Order.Type.REPAIR, REPAIRING state, diminishing returns) |
| **M12.1** | TeamRules DEAD ordinal aligned after REPAIRING insert |
| **M13** | IDLE-only retaliation when damaged by enemy unit |
| **M15** | Deposit only to **constructed** TC (skip UNDER_CONSTRUCTION) |
| **M16** | IDLE-only auto-acquire nearest enemy (radius 12); does not interrupt work orders |
| **Polish** | Watchtower Pack/Unpack in CommandBar; camera XZ clamp to map |

**Player capability summary:** multi-building economy (place TC/Barracks/Watchtower via workers), repair, nearest constructed deposit, idle acquire, mobile pack/unpack UI.

---

## AI (team 1) — still Stage-1 cell

| Behavior | Status |
|----------|--------|
| One TC via `_team_town_center()` (first alive) | Current |
| Train workers from that one TC only | Current |
| Instant Barracks (`place_building_for_team`, no ghost `can_build`) | Current (TD-01) |
| `desired_worker_count=4`, dual `stock_floor=100` | Current |
| Soldiers → `attack_threshold=3` → EnemyAIComponent once | Current |
| 2nd TC / multi-TC train | **M17.0 target** |

---

## Stage 1.5 climate — PARKED (not active sprint)

Design contract remains valid for later. Code progress beyond old status docs:

| Item | Repo fact |
|------|-----------|
| Slice A backend (fixed regions + seasonal state) | In code; F5 of 4×r14 prototype was accepted |
| Expanded geometry Variant B **8×r21** | **Ported** (`Port climate layout: Variant B 8×r21`) |
| Seasonal Front v0 | Commit present |
| Slice B visuals / C resource pressure / D horses / E neutrals / F hero / G matrix | **Not** current work |

Do **not** treat climate as the next implementation request unless explicitly re-opened after M17.

---

## Balance snapshot (Stage 1 baseline; update when values change)

### Map / bases

| Key | Value |
|-----|--------|
| Player TC | `(28.0, 0.0, -22.0)` |
| Enemy TC | `(-28.0, 0.0, 28.0)` |
| Nav `MAP_HALF` | **100** |
| AI Barracks default offset | `tc + (4, 0, 3)` |

### AI controller exports

| Export | Value |
|--------|--------|
| `desired_worker_count` | **4** |
| `attack_threshold` | **3** |
| `decision_interval` | **1.5 s** |
| `stock_floor` | **100** |

### Costs (unchanged baseline)

Worker 50W · Soldier 80W · Cavalry 100W+1H · Siege 150W+50S · Barracks 100W+50S · Watchtower 40W+20S

---

## Next action

1. **M17.0** — AI minimal 2nd TC + train workers from any alive same-team TC (`max_ai_tc=2`).
2. **M17.1** (optional) — combat polish if tunnel-to-TC still hurts after expand.
3. Stage 1.5 B+ only on explicit request.
4. Keep frozen: Combat / Deployment / Match / NavBake contracts unless a slice names them.
