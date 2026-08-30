# 12 — PROGRESSION AND TIER SYSTEM

## Status

**Document type:** Design Vision / Progression Design  
**Status:** DESIGN VISION — **NOT MVP**, except items explicitly marked otherwise  
**Scope:** How base development (tiers) interacts with nomad mobility, magic sites, air units, and long-term AI symmetry  
**Current MVP faction:** Turan  
**Canon level:** Structure and roles are intentional; **exact costs/HP/DPS are NOT locked** — calibrate via F5 like wave interval.

> **Gameplay scope authority remains** `nomad_wars_v1_scope_and_architecture.md`.  
> This file records vision so it is not lost and does **not** expand v1.0 implementation obligations.

---

## 1. Design intent

Classic RTS (e.g. Alliance in WC3) uses tier progression mainly for **stronger walls and heavier units**.

Nomad Wars tier progression must also upgrade **the quality of migration**:

- faster pack / unpack;
- faster caravan movement;
- reduced transit vulnerability;
- (later) resistance to seasonal / zone penalties while migrating.

**Places of Power** create map pressure: magic production is tied to controllable nodes, so seasons and migration force relocation — same identity as mobile settlements.

---

## 2. Tier structure (Turan names)

Names align with lore (`05_FACTIONS.md` / steppe-Turkic theme).

| Tier | Name | Economy unlock (structure) | Nomad identity |
|------|------|----------------------------|----------------|
| **T1** | **Аул (Aul)** | Basic gather (wood / food / gold as present in code); basic military | Slow pack/unpack; slow caravan; vulnerable to seasons |
| **T2** | **Орда (Horde)** | Horses as resource; cavalry; improved logistics | Pack/unpack faster; caravan faster; partial season resist |
| **T3** | **Каганат (Kaganate)** | Magic roster, siege depth, air | Near-instant deploy; armored caravan; strong season resist while moving |

**MVP v1.0:** only **T1** content that already exists in code (TC, Worker, Barracks line, Watchtower, Soldier/Cavalry/Siege, Zones v1.0 harvest).  
**T2 / T3:** after Environment Zones v1.1 and a completed T1 balance cycle — not parallel to unfinished Balance Pass.

---

## 3. Tier → mobility (mechanical contract)

Uses existing architecture: `BaseBuilding.get_current_stat()` = `base × tier_modifiers × deployment_overrides`  
(`DESIGN_DEPLOYMENT_EFFICIENCY.md` §2). Filling the table is **not** a new subsystem.

**Provisional multipliers** (experiment targets — not code-locked):

| Parameter | T1 Aul | T2 Horde | T3 Kaganate |
|-----------|--------|----------|-------------|
| pack/unpack time (× base) | 1.0 | 0.7 | 0.4 |
| mobile move_speed (× base) | 1.0 | 1.3 | 1.6 |
| vulnerability_multiplier (transit) | current (TC 1.5 / tower 1.3) | −20% of current | −40% of current |
| tower range / dmg (DEPLOYED) | base | +15% | +30% |
| resistance to seasonal zone penalty | none | partial | immunity while migrating (MOBILE/PACKING/UNPACKING) |

Principles (from `DESIGN_DEPLOYMENT_EFFICIENCY.md` §5):

1. Mobility has opportunity cost.  
2. Must not be pure punishment.  
3. Tier reduces **mobility penalties**, not only raw power.  
4. Player must **feel** the effect (UI / clear feedback).

Concrete % validated only after T1 balance is stable.

---

## 4. Structural unlocks (roles — not costs)

Do **not** copy WC3 gold/lumber numbers. Current economy uses different orders of magnitude (TC ~500 HP, Soldier ~150 HP, wood/stone/horses). Exact costs come from F5, same method as wave interval.

### 4.1 Buildings (role unlock by tier)

| Building | Tier | Role |
|----------|------|------|
| Town Center (main tent) | T1+ | Workers, drop-off, tier upgrade hub |
| Barracks (warrior camp) | T1 | Melee / basic infantry |
| Watchtower | T1+ | Mobile defense; scales with tier table §3 |
| Stables / paddocks | T2 | Horse economy + cavalry gate |
| Spirit Sanctuary (Святилище духов) | T2/T3 | Magic unit production — **only near a Place of Power** |
| Wind Spire (Гнездо Ветров) | T2/T3 | Air production |
| Siege workshop (or Barracks T3 branch) | T3 | Heavy siege |

### 4.2 Units (roles)

| Unit | Tier | Role |
|------|------|------|
| Worker (shepherd) | T1 | Gather, build, pack |
| Light infantry | T1 | Fast melee |
| Archer | T1 | Ranged |
| Steppe rider | T2 | Cavalry + charge identity |
| Shaman of Winds | T2/T3 | Support heal / move-speed aura |
| Storm caster | T2/T3 | Temporary local zone / slow |
| Falcon scout | T2 | Cheap air vision, no (or minimal) attack |
| Eagle riders | T3 | Flying melee |
| Wind serpent | T3 | Air siege vs static bases |
| Siege ballista (or equivalent) | T3 | Building damage; optional fire-on-move with speed penalty |

Existing code units (Worker, Soldier, Cavalry, SiegeUnit) map to **T1 / early T2 roles** until renamed or split.

---

## 5. Places of Power (Места Силы)

- Map nodes (e.g. Балбалы / spirit nodes): **not destroyable**; **controllable**.
- **Spirit Sanctuary** may be built or **unpacked only inside** the node radius.
- If climate / zones make the node unfavorable, the player must **migrate** to another node to keep training mages.
- Ties migration pressure to magic access (same story as `04_HISTORY_AND_ORIGIN.md` / migration competition).

**Implementation:** not v1.0. After Zones v1.1 design is real enough to place nodes.

---

## 6. Magic and air (vision only)

- Magic is **spatially gated** (Places of Power), not a free global tech tree only.
- Air identity for Turan: falconry / wind — scout → heavy flyers → air siege.
- Full magic combat rules, mana economy, and flying navigation: **post–v1.0**.

See also `10_MAGIC_AND_TECHNOLOGY.md` for lore tone; **this file** owns progression unlock structure.

---

## 7. Symmetric enemy AI (principle, not milestone)

Long-term product goal: multiplayer-shaped skirmish. Enemy should use the **same** ResourceManager / BuildingManager / Order pipeline as the player — not permanent special-case spawn rules.

**Now:** `EnemySpawner` + `EnemyAIComponent` remain the v1.0 pressure tool (wave tests / match loop).

**Rule:** do not add hard-coded "enemy-only" shortcuts that block a future full-economy AI. Prefer shared systems.

Full economic opponent AI is a **major** post-v1.0 effort (studio-scale), not a balance-pass item.

---

## 8. Heroes

- **Not v1.0** (`LORE_MVP_SCOPE_OVERRIDE.md`).
- Architecture already composition-ready (`BaseUnit` + components). No premature Effect/Modifier system required before a real hero design is in front of us.
- Future: HeroComponent (XP/levels), AbilityComponent, optional Inventory / Aura — layered on existing Order/Combat pipelines.

---

## 9. Isolated cheap polish (may be v1.0 if scheduled)

### Building Health Bar

When a building is damaged, show a billboard HP bar (same pattern as unit `HealthBar3D`: visible only if `ratio < 1` and HP > 0). Applies to **all** buildings (TC, Watchtower, Barracks, …), not only mobile pack bars.

- Does not change damage formula, deployment, or economy numbers.
- Safe parallel milestone when Balance Pass is paused or between wave tests.

---

## 10. What v1.0 does / does not include

| Include in v1.0 | Explicitly not v1.0 |
|-----------------|---------------------|
| T1 playable Turan core already in code | T2/T3 upgrade chain |
| Mobile settlement + dual-mode caravan control | Places of Power + Spirit Sanctuary |
| Zones v1.0 harvest blobs | Seasonal zone resistance by tier |
| Wave / pressure tuning (Balance Pass) | Full economic enemy AI |
| Optional: Building Health Bar | Air units, magic roster, heroes |

---

## 11. Suggested order after current pause

1. Finish **Balance Pass** isolation (wave tempo midpoint + AFK criterion) — one variable at a time.  
2. Optional parallel: **Building Health Bar**.  
3. Zones v1.1 (seasonal pressure) — so migration has external reason.  
4. Then design-spec → implement **T2** mobility row only (fill `tier_modifiers` / deployment tables).  
5. Later: Places of Power, magic/air, symmetric AI, heroes.

---

## 12. Related documents

* `nomad_wars_v1_scope_and_architecture.md` — gameplay scope authority  
* `LORE_MVP_SCOPE_OVERRIDE.md` — lore must not expand MVP  
* `DESIGN_DEPLOYMENT_EFFICIENCY.md` — deployment × tier contract  
* `MOBILE_SETTLEMENTS.md` — philosophy of mobility cost  
* `08_MIGRATION_AND_NOMADISM.md` — migration lore  
* `10_MAGIC_AND_TECHNOLOGY.md` — magic/tech fiction  
* `NOMAD_WORLD_BACKLOG.md` — other future logistics ideas  

---

## 13. Final principle

For nomads, **tier is not only bigger armies**.  
Tier is **how well the aul can move, arrive, and adapt** when the world forces the next camp.
