# Nomad Wars Roadmap

## RTS Framework

### Camera
- [x] RTS Camera / Edge Scroll / Zoom / Rotation

### Units
- [x] BaseUnit + Order abstraction
- [x] Worker / Soldier / Cavalry / SiegeUnit
- [x] MovementComponent (NavAgent + soft RVO)
- [x] HarvestComponent / CombatComponent / InventoryComponent
- [x] EnemyAIComponent (Phase 7)

### Managers
- [x] UnitManager / BuildingManager / ResourceManager
- [x] Selection / Command / Interaction / Construction
- [x] MatchManager
- [x] EnemySpawner
- [x] NavigationBakeService

### Buildings
- [x] TownCenter (mobile) / Barracks
- [x] DeploymentComponent
- [x] Building visual states (INTACT→DESTROYED)
- [x] LootableComponent / damage modifiers
- [ ] Phase 8 — towers / defenses

### Gameplay
- [x] Selection / Move / Harvest / Attack / Siege
- [x] Resources (Wood, Stone, Horses + dictionary costs)
- [x] Phase 7 AI waves + core loop
- [ ] **Polish: attack hysteresis + RVO** (active)
- [ ] Environment belts / migration

### Polish
- [x] Resource HUD + train / pack UI
- [ ] Audio / VFX
