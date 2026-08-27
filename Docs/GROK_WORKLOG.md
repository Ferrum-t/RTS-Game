# GROK WORKLOG — Nomad Wars

Ветка: `nomads-wars-grok` (репозиторий `RTS-Game`)

---

## 2026-08-27 — Phase 8.0 Watchtower wired (waiting F5)

Polish sprint (hysteresis + RVO) **ACCEPTED** по F5 игрока. RVO wall-nudge у стен зданий — tech debt, не блокер.

### Phase 8.0 code

- `BuildingCombatComponent` — scan `UnitManager.units` каждые 0.4s, без Area3D / PhysicsQuery
- `Watchtower` extends `BaseBuilding` (HP 350, range 14, dmg 12, RANGED)
- Damage: frozen `BaseUnit.damage(amount)` — не `take_damage`
- Catalog: `WatchtowerData` Wood 40 / Stone 20 → BuildPanel button
- `ResourceManager.cost_watchtower()` и `BuildingManager.watchtowers_list` уже были — не трогали
- MatchManager спаунит player Watchtower на марше врага (TC + `(0,0,6)`)
- Win/Lose формула не менялась (все buildings). DEFEAT теперь требует снести TC **и** башню

### F5

См. `Docs/PHASE_8_0_INTEGRATION.md`. Ждём `[TOWER] acquired` / `hits`.

### Next

F5 accept 8.0 → Phase 8.1 MobileTower (`DeploymentComponent`).

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
