# 12 — PROGRESSION AND TIER SYSTEM

## Status

**Document type:** Design Vision / Progression Design  
**Status:** DESIGN VISION — **does not expand v1.0 by itself**  
**Scope:** Tiers (Аул / Орда / Каганат), Places of Power, air/magic roles, and the **architectural principle** of a symmetric economic opponent  
**Current MVP faction:** Turan  
**Canon level:** Structure and roles are intentional; **exact costs/HP/DPS are NOT locked**.

> **Gameplay scope authority:** `nomad_wars_v1_scope_and_architecture.md` only.  
> Path on disk: `Docs/12_PROGRESSION_AND_TIER_SYSTEM.md` (no `Docs/World/` subfolder in this repo).

**Product decision (2026-08-31):**  
Whether v1.0 stays **T1-only** or grows to **T1+T2** is **deferred** until **Stage 1** (Simple Economic AI Opponent, T1 only) is playtested. Do not implement T2/T3/Places/air/magic because this document exists.

---

## 0. Why this document exists (identity problem)

Wave-based `EnemySpawner` as the main pressure source reads as **Tower Defense**, even when Order/Resource/Combat pipelines are shared. That is a product-identity problem, not a cosmetic one.

Correct direction: replace (or demote) pure wave pressure with an opponent that **gathers, builds, trains, and attacks** through the same systems as the player.

**Wrong direction:** doing that *and* T2+T3 *and* Places of Power *and* air *and* magic *and* zone redesign *at once*. One variable at a time.

---

## 1. Design intent — tiers and nomad identity

Classic RTS tier (e.g. WC3 Alliance) mainly unlocks **stronger walls and heavier units**.

Nomad Wars tier must also upgrade **migration quality**:

- faster pack / unpack;
- faster caravan movement;
- reduced transit vulnerability;
- (later) resistance to seasonal / zone penalties while migrating.

**Places of Power** gate magic production to map nodes so climate and migration matter — same identity as mobile settlements.

---

## 2. Tier structure (Turan names)

| Tier | Name | Economy unlock (structure) | Nomad identity |
|------|------|----------------------------|----------------|
| **T1** | **Аул (Aul)** | Basic gather; basic military | Slow pack/unpack; slow caravan; vulnerable to seasons |
| **T2** | **Орда (Horde)** | Horses; cavalry; logistics | Faster pack/move; partial season resist |
| **T3** | **Каганат (Kaganate)** | Magic, deep siege, air | Near-instant deploy; armored caravan; strong season resist while moving |

**Until Stage 1 result:** treat shipping content as **T1 only** (what already exists in code).  
**T2 / T3:** only after an explicit scope decision post–Stage 1 (and preferably after Zones readability / v1.1 pressure is honest).

Do **not** import WC3 gold/lumber tables; calibrate numbers via F5 on the current economy (TC ~500 HP, Soldier ~150 HP, wood/stone/horses).

---

## 3. Tier → mobility (mechanical contract)

Hook already exists: `BaseBuilding.get_current_stat()` = `base × tier_modifiers × deployment_overrides`  
(`DESIGN_DEPLOYMENT_EFFICIENCY.md`). Not a new subsystem.

**Provisional multipliers** (experiment targets — not code-locked):

| Parameter | T1 Aul | T2 Horde | T3 Kaganate |
|-----------|--------|----------|-------------|
| pack/unpack time (× base) | 1.0 | 0.7 | 0.4 |
| mobile move_speed (× base) | 1.0 | 1.3 | 1.6 |
| vulnerability_multiplier (transit) | current (TC 1.5 / tower 1.3) | −20% | −40% |
| tower range / dmg (DEPLOYED) | base | +15% | +30% |
| resistance to seasonal zone penalty | none | partial | immunity while migrating |

Principles: mobility has cost; not pure punishment; tier reduces **penalties**, not only raw power; player must **feel** it.

---

## 4. Structural unlocks (roles — not costs)

### 4.1 Buildings

| Building | Tier | Role |
|----------|------|------|
| Town Center | T1+ | Workers, drop-off, future tier hub |
| Barracks | T1 | Infantry |
| Watchtower | T1+ | Mobile defense |
| Stables | T2 | Horse economy + cavalry gate |
| Spirit Sanctuary | T2/T3 | Magic units — **only near Place of Power** |
| Wind Spire | T2/T3 | Air production |
| Siege workshop | T3 | Heavy siege |

### 4.2 Units

| Unit | Tier | Role |
|------|------|------|
| Worker | T1 | Gather, build, pack |
| Light infantry / Soldier | T1 | Melee |
| Archer | T1 | Ranged |
| Steppe rider / Cavalry | T2 | Cavalry |
| Shaman of Winds | T2/T3 | Support |
| Storm caster | T2/T3 | Zone / control |
| Falcon scout | T2 | Air vision |
| Eagle riders | T3 | Flying melee |
| Wind serpent | T3 | Air siege |
| Siege unit | T3 | Building damage |

Existing code units map to **T1 / early T2 roles** until renamed.

---

## 5. Places of Power (Места Силы)

- Controllable, non-destroyable map nodes.
- Spirit Sanctuary build/unpack only inside node radius.
- Unfavorable climate → player must migrate to keep magic production.

**Not Stage 1. Not automatic v1.0.** After zone pressure is readable.

---

## 6. Magic and air (vision only)

Spatially gated magic; Turan air = falconry / wind (scout → heavy → air siege).  
Full rules post–Stage 1 decision and post–v1.0 core loop.

---

## 7. Symmetric economic AI — principle + Stage 1 experiment

### 7.1 Long-term principle

Multiplayer-shaped skirmish: enemy uses the **same** ResourceManager / BuildingManager / Order / Production / Combat / Movement pipeline as the player. Avoid permanent enemy-only shortcuts that block that future.

### 7.2 Stage 1 — Simple Economic AI Opponent (T1 only) — **next code experiment**

**Goal:** test the thesis *"replacing waves with a real economy opponent makes this feel like RTS, not TD."*

**In scope:**

- Opponent uses **player systems** (not `EnemySpawner` as the primary pressure).
- Threshold-based rules only (not "smart" AI):
  - Keep N workers on wood/stone
  - Build Barracks when resources allow
  - Train Soldier while Barracks free
  - Attack player TC when army size ≥ K
- **No AI migration** in Stage 1 (no PACKING→MOBILE→UNPACKING for the enemy). AI base stays put. Migration AI is a **later** milestone (needs zone evaluation + same uncertainty as the player).

**Out of scope for Stage 1:**

- Tier system / T2 / T3
- Places of Power, air, magic
- Building Health Bar (optional parallel polish only)
- Environment Zones redesign
- Further wave-interval tuning as the *main* balance work

**F5 criterion:**

> Match feels like *"me vs opponent economy"*, not *"me vs wave timer"*.  
> Opponent visibly builds and grows an army; units are not only spawned ready-made on a clock.

**After Stage 1:**

- If T1 + economic opponent already feels like the intended RTS → keep **v1.0 = T1-only** and push toward release discipline.
- If still thin → then **T2 earlier** becomes an evidence-based decision, not a paper argument.

### 7.3 Wave spawner role

`EnemySpawner` / `EnemyAIComponent` → **Pressure Test Mode** (debug / fallback / optional mode), **not** the final marketed gameplay loop.

Stop further wave-number calibration as the primary product goal until Stage 1 has a result.

### 7.4 Known risks (do not ignore)

1. **AI migration ≠ attack** — do not list migrate next to gather/attack as same difficulty; Stage 1 excludes it.  
2. **Perf** — two full economies may hit nav/unit counts sooner (`TODO`: Staggered Nav Updates).  
3. **Zone readability** — if blobs are not understood, migration pressure fails from the *environment* side of the same loop; treat zone clarity as same-class identity issue, parallel priority after Stage 1 starts.  
4. **Art production** — real schedule bottleneck may be concept→rig→anim per unit, not code; production test on one worker remains a parallel product risk check.

---

## 8. Heroes

**Not v1.0** (`LORE_MVP_SCOPE_OVERRIDE.md`). Composition-ready later; no premature Effect system required now.

---

## 9. Isolated cheap polish

**Building Health Bar** — billboard on damage only (unit `HealthBar3D` pattern). All buildings. Does not change combat formulas. Optional parallel when not blocking Stage 1.

---

## 10. Suggested order (Claude consensus 2026-08-31)

1. **Stage 1:** Simple Economic AI Opponent, T1 only, no AI migration.  
2. Optional parallel: Building Health Bar; art production spike on one worker.  
3. Zone readability / Zones v1.1 (seasonal front) — same identity family as "why migrate".  
4. **Then** decide v1.0 = T1-only vs T1+T2 from play evidence.  
5. Only then: T2 mobility row, Places of Power, air/magic, AI migration, heroes.

---

## 11. Related documents

* `nomad_wars_v1_scope_and_architecture.md` — scope authority (§0 Product Scope Under Review)  
* `LORE_MVP_SCOPE_OVERRIDE.md` — heroes / lore must not expand MVP  
* `DESIGN_DEPLOYMENT_EFFICIENCY.md` — deployment × tier contract  
* `MOBILE_SETTLEMENTS.md` — mobility philosophy  
* `08_MIGRATION_AND_NOMADISM.md` / `10_MAGIC_AND_TECHNOLOGY.md`  
* `NOMAD_WORLD_BACKLOG.md`

---

## 12. Final principles

1. For nomads, **tier is how well the aul moves and adapts**, not only army size.  
2. **One experiment at a time** — Stage 1 AI before rewriting v1.0 to T1+T2.  
3. Waves are a **test tool**; the product identity is **RTS vs economy**, under migration pressure from a readable world.
