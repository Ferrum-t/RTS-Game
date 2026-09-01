# CURRENT STATE

**Gameplay scope:** [`nomad_wars_v1_scope_and_architecture.md`](nomad_wars_v1_scope_and_architecture.md)  
**Vision:** [`12_PROGRESSION_AND_TIER_SYSTEM.md`](12_PROGRESSION_AND_TIER_SYSTEM.md)  
**Lore override:** [`LORE_MVP_SCOPE_OVERRIDE.md`](LORE_MVP_SCOPE_OVERRIDE.md)  
**Tech debt:** [`TECH_DEBT.md`](TECH_DEBT.md)  
**Process:** [`ACCEPTANCE_AND_PROCESS.md`](ACCEPTANCE_AND_PROCESS.md)  
**Stage 1.5 design (next):** [`STAGE_1_5_GAMEPLAY.md`](STAGE_1_5_GAMEPLAY.md)

**Branch:** `nomads-wars-grok`

---

## Stage 1 — FORMAL SIGN-OFF

| Field | Value |
|--------|--------|
| **Status** | **ACCEPTED** |
| **Date** | 2026-09-01 |
| **Evidence** | Multiple F5 full matches (VICTORY / DEFEAT); post-commit logs for attack-once and dual-floor |
| **Scope** | T1 economic AI opponent, shared production/combat, no AI migration, no T2 |

### Accepted under Stage 1

- Core RTS loop (select, harvest, build, train, fight)
- Per-team stockpiles
- AI: workers → Barracks → soldiers → attack threshold → combat → match end
- Attack issue **once** + reinforcements (no per-tick spam)
- Harvest **dual stock-floor** (`stock_floor=100`) — irreversible wood/stone stick fixed
- Door / rally / flag / building select ring
- Building HP / visual states / loot on destroy
- Mobile buildings (pack/move/unpack)
- Navigation ~200×200 (`MAP_HALF=100`), footprint rebake
- Zones: motion + visuals + `get_multiplier_at` (**no** harvest/AI wiring)

### Explicitly out of Stage 1 (not failures)

| Item | Note |
|------|------|
| AI Economy 1.5 (goal→deficit→assign) | **Deferred** — §3 amendment; dual-floor sufficient for T1 |
| T2 / T3 / Heroes / Places of Power | Not started |
| AI migration | Not Stage 1 |
| Zone → harvest / AI | Stage B later |
| TD-01 shared `can_place` | Later |
| TD-03 residual AI after TC death | OK while win = destroy TC |
| TD-04 TeamRules `DEAD := 6` | Later |

**Do not start Economy 1.5 or T2** unless a new F5 or Stage 1.5 design proves a concrete need.

---

## Balance snapshot (canonical — repo fact, not chat-only)

Values from F5 / code exports on `nomads-wars-grok` as of 2026-09-01. Update this table in the **same session** when balance changes (`ACCEPTANCE_AND_PROCESS.md` §5).

### Map / bases

| Key | Value |
|-----|--------|
| Player TC | `(28.0, 0.0, -22.0)` |
| Enemy TC | `(-28.0, 0.0, 28.0)` |
| TC distance | **~75.1** |
| Nav `MAP_HALF` | **100** (playable ~200×200) |
| AI Barracks default offset | `tc + (4, 0, 3)` → e.g. `(-24, 0, 31)` |

### Resource nodes (starting amounts)

| Node type | Amount |
|-----------|--------|
| Tree / EnemyTree | **2500** |
| Stone / EnemyStone | **2500** |
| HorseHerd / EnemyHorseHerd | **1000** |

### AI controller (`EconomicAIController`)

| Export | Value |
|--------|--------|
| `desired_worker_count` | **4** |
| `attack_threshold` | **3** |
| `decision_interval` | **1.5** s |
| `stock_floor` | **100** (wood & stone dual check + alternate) |
| `barracks_offset` | `(4, 0, 3)` |

### Unit move speeds (after WC-feel tuning)

| Unit | `move_speed` |
|------|----------------|
| Base / Worker default | **2.4** |
| Soldier | **2.7** |
| Cavalry | **3.9** |
| SiegeUnit | **1.8** |

### Training / building costs (UI + data / logs)

| Item | Cost |
|------|------|
| Worker | 50 Wood (~3 s) |
| Soldier | 80 Wood |
| Cavalry | 100 Wood + 1 Horse |
| Siege | 150 Wood + 50 Stone |
| Barracks | 100 Wood + 50 Stone |
| Watchtower | 40 Wood + 20 Stone |

### Rally defaults (`BaseBuilding`)

| Key | Value |
|-----|--------|
| `spawn_offset` (door) | ~(3.5, 0, 0) |
| `default_rally_offset` | **(12, 0, 0)** |
| Rally grid | 4 cols × spacing **2.5** |

---

## Next action

1. ~~Formal Stage 1 sign-off~~ **done**  
2. ~~Balance snapshot in repo~~ **done**  
3. **Stage 1.5 Gameplay Design** — `STAGE_1_5_GAMEPLAY.md` (design only)  
4. Economy 1.5 / T2 / TD-* only if Stage 1.5 design or a new F5 demands them  
