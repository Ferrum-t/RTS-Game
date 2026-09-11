# Nomad Wars — MVP v1.0 Scope и архитектурная дорожная карта

> **Единственный живой документ** по scope / статусу / порядку фаз.
> World lore и design-vision не расширяют gameplay scope молча — при конфликте побеждает этот файл.
> Stage 1.5 design contract: `Docs/DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`.

---

## 0. CURRENT STATUS (2026-09-11, ветка `nomads-wars-grok`)

**Репо:** `Ferrum-t/RTS-Game` → `nomads-wars-grok`  
**Движок:** Godot 4.7 stable  
**Правило приёмки:** код из чата ≠ факт, пока нет F5-лога + чтения файла.

### Product Scope — Stage 1 accepted, Stage 1.5 design active

**Stage 1 — Simple Economic AI Opponent (T1, no AI migration) — ACCEPTED.**

Текущий следующий этап — **Stage 1.5 Gameplay Design / implementation planning**.

Stage 1.5 сейчас является design phase. Никакая новая механика не считается реализованной только потому, что она описана в design contract.

- Wave spawner (`EnemySpawner` / `EnemyAIComponent`) остаётся **Pressure Test Mode**, не финальным marketed gameplay loop.
- Не расширять T1/T2 scope по бумажному спору. T2 остаётся замороженным до доказанной необходимости после Stage 1.5.
- AI migration остаётся вне текущего implementation slice.

### Milestones

| ID | Содержание | Статус |
|----|------------|--------|
| M1–M9, Phase 2–8.2 | Core RTS + mobile TC/WT + raid | **ACCEPTED** |
| Stuck / Billboard / Formation / selection-aware | **ACCEPTED** |
| 10 | Environment Zones v1.0 | **ACCEPTED** |
| 11 | Enemy AI waves (Pressure Test Mode) | **ACCEPTED** |
| 12 | Polish (debug keys, names) | **ACCEPTED** |
| Stage 1 | Simple Economic AI Opponent, T1, no AI migration | **ACCEPTED** |
| Stage 1.5 | Climate / region / migration-pressure design | **ACTIVE DESIGN** |

### Canonical Stage 1.5 design contract

`Docs/DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`

Core decisions:

- map regions are geographically fixed;
- region boundaries do not overlap;
- each region has exactly three gameplay climate states: `COLD`, `FAVORABLE`, `DRY`;
- seasonal change modifies region state, not region geometry;
- `TRANSITION` is not a fourth gameplay state in the current model;
- `FAVORABLE` is the most advantageous ecological state for settlement/economic development;
- each major region is conceived as an ecological/economic package for an aul;
- horses are a first visible climate-response system;
- neutral camps are a separate PvE value stream;
- a minimal **player hero** is planned because artifact carry/drop/steal cannot be tested without one;
- one artifact type is sufficient for the first hero slice;
- Power Sites are reserved future infrastructure, not current implementation;
- AI hero, AI migration, full hero progression, magic/mana, Artifact tiers and T2 remain deferred.

### Current implementation order

1. **A — Climate backend:** fixed regions + seasonal state lookup.
2. **B — Environment visuals:** state presentation.
3. **C — Resource climate pressure:** soft effect on existing resource extraction.
4. **D — Horses:** climate-dependent availability using existing horse/cavalry pipeline.
5. **E — Neutral camps:** combat + basic loot.
6. **F — Minimal player hero + one artifact:** pickup → bonus → death drop → steal.
7. **G — Conflict matrix:** develop / migrate / defend / raid / contest / commit.

Every implementation slice requires its own narrow request and F5 acceptance according to `Docs/ACCEPTANCE_AND_PROCESS.md`.

---

## 1. V1.0 BASELINE

The accepted baseline remains the T1 RTS foundation. Stage 1.5 is a design/vertical-slice expansion under active review and does not silently rewrite the accepted Stage 1 contracts.

### Existing baseline

- Turan only
- Wood / Stone / Gold / Horses
- Worker / Soldier / Cavalry / SiegeUnit
- Raid foundation
- Mobile settlements and mobile towers
- Zones v1.0
- Economic AI opponent
- Match victory/defeat through existing Stage 1 rules

### Scope boundary

Stage 1.5 may introduce a minimal player hero if the implementation slice is explicitly tasked and accepted. It does **not** authorize a full hero progression system, AI hero, magic roster, or T2.

---

## 2. BACKLOG / DEFERRED

- AI migration
- AI hero
- Full economic AI sophistication / Economy 1.5 unless a concrete F5 proves need
- Full hero progression
- Artifact tiers
- Places of Power gameplay
- Mana / magic systems
- Other factions
- Multiplayer
- Campaign
- T2/T3 unless Stage 1.5 evidence changes scope

---

## 3. ARCHITECTURAL CONTRACTS

Existing accepted contracts remain frozen unless an implementation request explicitly targets them.

Order · DeploymentState · `base × tier × deployment` · Building mover · NavBake · Horses · Damage→Loot · Building visual · Tower auto-attack · Match win/lose · dual-mode selection · Stage 1 economic AI.

**Important:** the old Zones v1.0 moving-zone implementation is now a **migration target for Stage 1.5 A**, not a design direction. The new contract is fixed geographic regions with changing state.

---

## 4. PROCESS

1. Design decision is recorded before feature code.
2. One implementation slice at a time.
3. F5 after commit is required for “done”.
4. Do not combine climate, resource, horse, neutral, hero and AI systems into one implementation patch.
5. Repository facts must be verified directly; chat claims are not evidence.

See `Docs/ACCEPTANCE_AND_PROCESS.md` §1–§5.

---

## 5. DOCUMENTATION OWNERSHIP

- `CURRENT_STATE.md` — implemented/accepted state and balance facts.
- `STAGE_1_5_GAMEPLAY.md` — Stage 1.5 gameplay questions and causal design.
- `DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md` — canonical fixed-region climate/migration/neutral/hero design contract.
- `02_GEOGRAPHY_AND_CLIMATE.md` — worldbuilding; must not override the Stage 1.5 gameplay contract.
- `08_MIGRATION_AND_NOMADISM.md` — worldbuilding/design foundation; must not override the Stage 1.5 gameplay contract.
- `TODO.md` — short next-step checklist.
- `ACCEPTANCE_AND_PROCESS.md` — process rules.

When documents conflict on current gameplay implementation, this file and the Stage 1.5 design contract are authoritative for their respective scope.
