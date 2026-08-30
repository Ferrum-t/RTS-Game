# Nomad Wars — MVP v1.0 Scope и архитектурная дорожная карта

> **Единственный живой документ** по scope / статусу / порядку фаз.
> World lore и design-vision (`12_PROGRESSION…`) не расширяют gameplay scope молча — при конфликте побеждает этот файл.
> §0 менять перед каждой сессией.

---

## 0. CURRENT STATUS (2026-08-31, ветка `nomads-wars-grok`)

**Репо:** `Ferrum-t/RTS-Game` → `nomads-wars-grok`  
**Движок:** Godot 4.7 stable  
**Правило приёмки:** код из чата ≠ факт, пока нет F5-лога + чтения файла.

### Product Scope — Under Active Review (2026-08-31)

Решается: **v1.0 = T1-only** (commercial-ready vertical slice) **vs T1+T2**.

**Решение ОТКЛАДЫВАЕТСЯ** до результата **Stage 1** (Simple Economic AI Opponent, T1 only, **без migration у AI**) — см. `Docs/12_PROGRESSION_AND_TIER_SYSTEM.md` §7.

- **Wave spawner** (`EnemySpawner` / `EnemyAIComponent`) = **Pressure Test Mode**, не финальный marketed gameplay loop.
- **Не крутить дальше цифры волн** как главный баланс-пасс, пока Stage 1 не даст F5-результат.
- **Не расширять v1.0 до T2/Places/air/magic** по бумажному спору — только после плейтеста Stage 1.

### Милестоуны (код)

| ID | Содержание | Статус |
|----|------------|--------|
| M1–M9, Phase 2–8.2 | Core RTS + mobile TC/WT + raid | **ACCEPTED** |
| Stuck / Billboard / Formation / selection-aware | **ACCEPTED** |
| **10** Environment Zones v1.0 | **ACCEPTED** |
| **11** Enemy AI waves (Pressure Test Mode) | **ACCEPTED** (role demoted to test tool) |
| **12** Polish (debug keys, names) | **ACCEPTED** |
| Balance Pass (wave interval 15/30/45) | **PAUSED** — data kept; not primary goal |
| **Stage 1** Simple Economic AI Opponent (T1, no AI migrate) | **NEXT** |

### Сейчас

**Design vision synced:** `12_PROGRESSION_AND_TIER_SYSTEM.md` (tiers, Places of Power, air/magic roles, Stage 1 AI experiment, risks).

**Caravan dual-mode / Zones v1.0 / MOBILE combat off + vuln** — без изменений.

**Spawner numbers (both files):** interval/delay **30**, max_alive **6** (Pressure Test Mode defaults).

### Открытые / tech debt (не кодить без промта)

| ID | Тема | Статус |
|----|------|--------|
| Stage 1 AI | Economic opponent T1, shared systems, no migrate | **Next experiment** |
| Wave tempo | 20s candidate | Frozen until Stage 1 |
| Zone readability / v1.1 | Seasonal front | Parallel identity priority after Stage 1 starts |
| Building HP bar | Billboard on damage | Optional parallel polish |
| T2/T3 / Places / air / magic | Vision only | **Not v1.0 until post–Stage 1 decision** |
| AI migration | PACK cycle for enemy | **After Stage 1** |
| Heroes | Full system | After v1.0 |
| Spawner config dual source | MatchManager overrides | Tech debt |
| Staggered Nav | 50+ units | Risk rises with dual economy |

### Следующий шаг

1. **Stage 1 — Simple Economic AI Opponent** (отдельный промт: scope, запреты, F5).  
2. Optional: Building Health Bar.  
3. Zone readability / Zones v1.1.  
4. Затем — решение T1-only vs T1+T2.

---

## 1. V1.0 SCOPE (baseline until Stage 1 decides otherwise)

Цель: одна раса (Turan), играбельное ядро. **По умолчанию T1 content already in code.** T1+T2 only if Stage 1 playtest demands it and scope §0 is updated.

### 1.1–1.6
Turan only · Wood/Stone/Gold/Horses · Raid foundation DONE · Mobile settlements + dual-mode DONE · Mobile towers DONE · Zones v1.0 DONE · Zones v1.1 candidate.

### 1.7 Units
Worker, Soldier, Cavalry, SiegeUnit. **No heroes. No air/magic roster in baseline v1.0.**

### 1.8 Heroes
**Not v1.0.**

### 1.9 Progression
**Baseline = T1 only.** T2/T3 vision in `12_PROGRESSION…`. Implementation only after Stage 1 decision + explicit scope update.

### 1.10 Opponent pressure
**Target loop:** economic opponent (Stage 1+).  
**Current tool:** wave Pressure Test Mode.

---

## 2. BACKLOG после baseline v1.0

- T2/T3, Places of Power, air, magic (if not pulled into v1.0 post–Stage 1)
- AI migration
- Full economic AI sophistication
- Heroes, other factions, multiplayer, campaign
- See `12_PROGRESSION…` and `NOMAD_WORLD_BACKLOG.md`

---

## 3. Архитектурные контракты (заморожены)

Order · DeploymentState · `base × tier × deployment` · Building mover · NavBake · Horses · Damage→Loot · Building visual · Tower auto-attack · Match win/lose · dual-mode selection · Zones v1.0 harvest-only — as previously frozen.

**3.15 Economic AI (Stage 1+)**  
Prefer shared Resource/Building/Order pipelines. Stage 1 = threshold rules, no AI pack/migrate.

---

## 4. Порядок фаз

…10–12 ACCEPTED · Balance wave pass PAUSED · **Stage 1 Economic AI = NEXT** · then zone readability / v1.1 · then T1 vs T1+T2 decision.

---

## 5. Работа с документами и Grok

1. Конкретный промт: scope, файлы, запреты.  
2. «Готово» = F5-лог или чтение файла после commit.  
3. Контракты §3 не рефакторить «заодно».  
4. Vision/lore не расширяет MVP без правки **этого** файла §0/§1.
