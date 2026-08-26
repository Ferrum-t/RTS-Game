# GROK WORKLOG — Nomad Wars

Ветка: `nomads-wars-grok` (репозиторий `RTS-Game`)

---

## 2026-08-26 — Phase 7 COMPLETE + Polish sprint start

### Phase 7 (Enemy AI)

- `EnemyAIComponent` + `EnemySpawner`
- Waves → player TC → Barracks → priority SiegeUnit
- Match DEFEAT / VICTORY intact
- F5: full enemy pressure, player can lose legitimately

### Hotfix deposit

- `BuildingManager.get_nearest_town_center(pos, team_filter)`
- Workers no longer deposit to enemy TC
- Log: `no own-team Town Center found, keeping inventory`

### Polish sprint (Navigation & Combat)

**Code**

1. **Attack hysteresis (unit)** — `CombatComponent`
   - Enter melee at `attack_range`
   - Exit only past `attack_range * 1.25`
   - On IN_RANGE: `movement.cancel()` freezes agent

2. **Attack hysteresis (building)** — `BaseUnit.update_attacking_building`
   - Enter at `building_attack_range`
   - Exit past `building_attack_range * building_exit_range_mult` (1.2)
   - `_siege_in_range` lock + cancel movement while striking

3. **Soft RVO** — `MovementComponent`
   - `avoidance_enabled = true`, radius 0.45, layers/mask 1
   - `set_velocity` + `velocity_computed` → `move_and_slide`
   - Light separation push kept as backup
   - Does not change Harvest / Order / Match contracts

**Docs updated:** TODO, CURRENT_STATE, ROADMAP, PROJECT_ROADMAP, this worklog.

### F5 checklist (polish)

1. Soldier siege player TC — no constant approach/attack jitter
2. Unit-vs-unit melee — less oscillation at range edge
3. Two workers pass near each other / enemy soldier — soft avoid
4. Harvest → deposit still works
5. Enemy waves still attack buildings

### Next

After F5 accept polish → Phase 8 defenses / mobile towers.

---

*Older sessions: M1–M6, Phase 4–6, UI, Raid/Siege — see git history.*
