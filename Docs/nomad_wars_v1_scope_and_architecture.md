# Nomad Wars — MVP v1.0 Scope и архитектурная дорожная карта

> **Official title (EN):** **Nomad Wars** · technical `NomadWars` · identity: `Docs/GAME_DESIGN.md`  
> **Единственный живой документ** по scope / статусу / порядку фаз.  
> World lore и design-vision не расширяют gameplay scope молча — при конфликте побеждает этот файл + `CURRENT_STATE.md`.  
> Stage 1.5 design (parked): `Docs/DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`.

---

## 0. CURRENT STATUS (2026-09-21, ветка `nomads-wars-grok`)

**Product:** Nomad Wars (not “Nomads Wars”)  
**Репо:** `Ferrum-t/RTS-Game` → branch `nomads-wars-grok` *(legacy slug)*  
**Движок:** Godot 4.7 stable  
**Правило приёмки:** код из чата ≠ факт, пока нет F5-лога + чтения файла.

### Product focus

| Layer | Status |
|-------|--------|
| **Stage 1** T1 economic AI | **ACCEPTED** |
| **Player M10–M16** construction / repair / multi-TC deposit / idle acquire | **ACCEPTED** |
| **M17.0–M17.2** AI 2nd TC + expansion eco + dual Barracks | **ACCEPTED** |
| **Stage 1.5 climate** | Design + backend geometry **parked** — not active sprint |
| **M17.3** AI Watchtower | PRE-CODE AUDIT done — needs LOCK |

### Active slice

See `Docs/CURRENT_STATE.md`. No open implementation slice until explicit READY.

### Milestones (high level)

| ID | Content | Status |
|----|---------|--------|
| M1–M9, Phase 2–8.2 | Core RTS + mobile + raid | **ACCEPTED** |
| Formation / selection-aware / stuck / billboard | **ACCEPTED** |
| Stage 1 Economic AI | **ACCEPTED** |
| Stage 1.5 design + Slice A + 8×r21 port | **PARKED** |
| M10–M16 Player eco/build/combat QoL | **ACCEPTED** |
| M17.0 AI 2nd TC | **ACCEPTED** |
| M17.1 Expansion Economy | **ACCEPTED** |
| M17.2 Multi-Base Military L1 | **ACCEPTED** |
| M17.3 AI Watchtower | audit only |

### Stage 1.5 (parked detail)

Canonical design: `DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md`.  
Code: fixed regions, seasonal state, Variant B geometry port, Seasonal Front v0.  
**Do not** implement B–G unless an explicit request re-opens Stage 1.5 after multi-base loop is settled.

---

## 1. V1.0 BASELINE

Accepted baseline remains T1 RTS foundation + player construction loop + AI multi-base production (M17.0–17.2).

- Turan only · Wood / Stone / Gold / Horses
- Worker / Soldier / Cavalry / SiegeUnit
- Raid foundation · Mobile settlements / towers
- Economic AI opponent (2 TC, 2 Barracks, once-policies)
- Match victory/defeat through existing Stage 1 rules

Stage 1.5 may later add climate pressure / hero slice on explicit task. It does **not** authorize T2, AI migration, or full hero progression by documentation alone.

---

## 2. BACKLOG / DEFERRED

- AI migration / pack / repair
- AI hero / full hero / artifact tiers / magic
- Economy 1.5 unless F5 proves need
- Other factions / multiplayer / campaign
- T2/T3 unless evidence changes scope

---

## 3. ARCHITECTURAL CONTRACTS

Frozen unless a slice names them:

Order · DeploymentState · `base × tier × deployment` · Building mover · NavBake · Horses · Damage→Loot · Building visual · Tower auto-attack · Match win/lose · dual-mode selection · Stage 1 economic AI execution path.

Construction progress / REPAIR / IDLE acquire are player-side additions on top of these contracts.

---

## 4. PROCESS

1. Design decision recorded before feature code.
2. One implementation slice at a time.
3. F5 after commit required for “done”.
4. Do not combine climate + eco + combat + hero in one patch.
5. Repository facts > chat claims.

See `Docs/ACCEPTANCE_AND_PROCESS.md`.

---

## 5. DOCUMENTATION OWNERSHIP

| File | Role |
|------|------|
| **This file §0** | Canonical phase order / active sprint |
| `CURRENT_STATE.md` | Implemented table + balance + next action |
| `GAME_DESIGN.md` | **Official product title** + high-level design |
| `TODO.md` | Short checklist |
| `GROK_WORKLOG.md` | Session history |
| `TECH_DEBT.md` | Durable gaps |
| `DESIGN_CLIMATE_*` | Parked Stage 1.5 contract |
| Lore `00`–`12` | Worldbuilding; must not override gameplay status |

When documents conflict on **what to build next**, this §0 and `CURRENT_STATE.md` win.
