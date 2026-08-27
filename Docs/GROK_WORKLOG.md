# GROK WORKLOG — Nomad Wars

Ветка: `nomads-wars-grok` (репозиторий `RTS-Game`)

**Scope / status:** только `Docs/nomad_wars_v1_scope_and_architecture.md`

---

## 2026-08-28 — Docs cleanup (Claude audit) + formation-offsets code present

### Claude audit accepted

- **Stuck Detection** — ACCEPTED (log 26): STUCK → stays MOBILE; manual U → UNPACKING → DEPLOYED; no false positives on open routes.
- **Billboard** pack/unpack bar — ACCEPTED (visual; no console proof required).
- **Log 27 death spiral** — confirmed: TC + Watchtower same dest → mutual `unpack blocked — footprint overlaps` → permanent MOBILE → defenseless → TC destroyed. Priority #1 = formation-offsets.

### Code (already on branch)

`InteractionManager._try_move_mobile_buildings`:
- Collects team-0 MOBILE TC + Watchtowers
- Local grid dests (`_building_formation_dests`); **does not** edit `Formation.gd`
- Spacing = `2 * max(nav_half_extents.xz) + UNPACK_MARGIN(0.4) + FORMATION_BUFFER(1.5)`
- Empty unit selection + RMB ground = whole caravan (selection-aware building move deferred — no building selection yet)

### Design fixed explicitly (scope §0)

- MOBILE combat: attack **off** binary; inbound vuln ×1.5 TC / ×1.3 tower — conscious choice until balance pass (not accident).
- Selection-aware building move — deferred until building selection exists.

### Docs hygiene (this pass)

- Single living roadmap: `nomad_wars_v1_scope_and_architecture.md`
- Pointers only: CURRENT_STATE, TODO, ROADMAP
- Deleted obsolete: ARCHITECTURE, PROJECT_ROADMAP, PHASE_8_*, SESSION

### F5 formation-offsets

See scope §0. Need different `move via RMB to` + `spacing=` and zero footprint overlaps on dual U.

### Next

F5 accept → Environment Zones.

---

## 2026-08-27 — Phase 8.0 Watchtower wired (later ACCEPTED)

Polish sprint (hysteresis + RVO) **ACCEPTED**. RVO wall-nudge у стен зданий — tech debt, не блокер.

### Phase 8.0–8.2

- `BuildingCombatComponent` — scan `UnitManager.units` каждые 0.4s, без Area3D / PhysicsQuery
- Watchtower / MobileTower / DeploymentConfig path completed through 8.2
- MatchManager spawns player Watchtower on enemy march path

---

## 2026-08-26 — Phase 7 COMPLETE + Polish sprint

### Phase 7 (Enemy AI)

- `EnemyAIComponent` + `EnemySpawner`
- Waves → player TC → Barracks → priority SiegeUnit
- Deposit own-team only hotfix

### Polish

1. Attack hysteresis (unit + building)
2. Soft RVO on MovementComponent

---

*Older sessions: M1–M6, Phase 4–6 — see git history.*
