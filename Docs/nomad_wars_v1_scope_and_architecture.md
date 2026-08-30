# Nomad Wars — MVP v1.0 Scope и архитектурная дорожная карта

> **Единственный живой документ** по scope / статусу / порядку фаз.
> Не заводить параллельные ROADMAP / ARCHITECTURE / PHASE_8_x_INTEGRATION.
> World lore (`Docs/0x_*.md`) не расширяет gameplay scope молча — при конфликте побеждает этот файл.
> Прикладывать целиком в начале новой сессии.
> §0 менять перед каждой сессией. §1–3 — редко.

---

## 0. CURRENT STATUS (2026-08-30, ветка `nomads-wars-grok`)

**Репо:** `Ferrum-t/RTS-Game` → `nomads-wars-grok`  
**Движок:** Godot 4.7 stable  
**Правило приёмки:** код из чата ≠ факт, пока нет F5-лога + чтения файла.

### Милестоуны

| ID | Содержание | Статус |
|----|------------|--------|
| M1–M6.9 | NavAgent + bake, Harvest-through-Movement, Siege | **ACCEPTED** |
| M7 | Stone harvest | **ACCEPTED** |
| M8.1 / M8.2 | Order + ownership audit | **ACCEPTED** |
| M9 | Match loop Win/Lose | **ACCEPTED** |
| Phase 2–5 | Stats, mobile TC, Horses/Cavalry, Pack UI | **ACCEPTED** |
| Phase 6 Core | DamageType + loot + SiegeUnit | **ACCEPTED** |
| Phase 6.2 | Building visual INTACT→DESTROYED | **ACCEPTED** |
| Phase 7 | EnemyAI + waves | **ACCEPTED** |
| Polish | Attack hysteresis + RVO | **ACCEPTED** |
| Phase 8.0 | Watchtower auto-attack (`BuildingCombatComponent`) | **ACCEPTED** |
| Phase 8.1 | MobileTower pack/move/unpack | **ACCEPTED** |
| Phase 8.2 | DeploymentConfig, transit vuln, unpack AABB, UI | **ACCEPTED** |
| Stuck | STUCK stays MOBILE, no auto-unpack | **ACCEPTED** |
| Billboard | Pack/unpack bar faces camera (QuadMesh + cam basis) | **ACCEPTED** |
| Formation-offsets | Grid dests for multi-MOBILE RMB | **ACCEPTED** |
| **10** | **Environment Zones** (blobs FAVORABLE/DRY/COLD, harvest mult, visual priority) | **ACCEPTED** |
| **11** | **Enemy AI** (threat retarget units, wave scaling, EnemySoldier_N / EnemyTownCenter names) | **ACCEPTED** |
| **12** | **Polish v1.0** (debug hotkeys gated, readable building names) | **ACCEPTED** |
| **+** | **Selection-aware building control** (select TC/WT → Pack/Unpack/RMB only selected; empty = entire caravan) | **ACCEPTED** |

### Сейчас

**Фазы 10–12 + selection-aware control закрыты.**

**Balance Pass (изолированный темп спавна) — в процессе, пауза для design-sync:**

| Интервал | Результат F5 |
|----------|----------------|
| 15s | TC ~волна 9; всё ещё «не успеваю» |
| 30s | VICTORY на волне 5 с армией; промежутки субъективно длинные; AFK-хвост не сдан |
| 45s | VICTORY рано; worker-rush слишком безопасен |
| 20s | **ещё не прогнан** |

`MatchManager` задаёт `spawn_interval` / `first_spawn_delay` / `max_units_alive` при `EnemySpawner.new()` — дублирует defaults скрипта (tech debt: один источник конфига). Сейчас оба файла держат **30**.

**Design vision записан (не implementation):**
- `Docs/12_PROGRESSION_AND_TIER_SYSTEM.md` — тиры Аул/Орда/Каганат → мобильность; Места Силы; авиарий/магия как структура ролей; симметричный AI как принцип; Building Health Bar как дешёвый изолированный polish.
- `DESIGN_DEPLOYMENT_EFFICIENCY.md` §8 — provisional таблица tier×mobility (T2/T3 **не** кодить до закрытия T1 balance + Zones v1.1).

**Caravan / building control (dual-mode):** без изменений (selected vs entire caravan).

**Environment Zones v1.0:** без изменений (blobs + harvest only).

**MOBILE combat:** attack off; vuln ×1.5 / ×1.3 — сознательный выбор до отдельного баланс-милестоуна.

### Открытые решения / tech debt (не кодить без отдельного промта)

| ID | Вопрос | Статус |
|----|--------|--------|
| MOBILE combat | Attack off; vuln ×1.5 / ×1.3 | Сознательный чойс |
| Raise TC-only | Separate command | Backlog |
| C | Unpack vs resources/terrain | Средний |
| D | Enemy AI vs MOBILE | Частично |
| Heroes | Full system | **После v1.0** |
| Collision | Unit pass-through MOBILE | Tech debt |
| Zones v1.1 | Сезонное давление | После balance |
| Balance | Wave tempo midpoint (20s?) + AFK | **Paused mid-pass** |
| Spawner config | MatchManager overrides EnemySpawner defaults | Tech debt — single source later |
| T2/T3 / Places of Power / air / magic | Vision in `12_PROGRESSION…` | **NOT v1.0** |
| Building HP bar | Billboard on damage only | Cheap parallel candidate |
| Full economic enemy AI | Same pipeline as player | Post-v1.0 principle only |

### Следующий шаг (кандидаты)

1. **Дожать Balance Pass** — interval **20** + честный AFK-хвост после волны 5 (одна переменная).
2. **Building Health Bar** — изолированный polish (паттерн unit HealthBar3D).
3. **Zones v1.1** — сезонное давление.
4. Только потом — T2 mobility row из `12_PROGRESSION…` / §8 deployment efficiency.

Порядок выбирает игрок/сессия; без отдельного промта с scope — не начинать.

---

## 1. V1.0 SCOPE

Цель v1.0: одна раса (Turan), играбельное ядро, ранний Steam. Глубина одной механики, не ширина контента.

### 1.1 Раса
Одна фракция (Turan) до релизного качества. Остальные 3 — бэклог. World docs могут описывать все четыре; код — только Turan.

### 1.2 Экономика
Wood, stone, gold, **Horses (Phase 5 DONE)**.

### 1.3 Grab / Raid
Phase 6 Core **DONE**. Capture/Steal юнитов / полноценный animal raid — бэклог.

### 1.4 Мобильные поселения
Town Center DEPLOYED/PACKING/MOBILE/UNPACKING — **DONE**. UI Pack/Unpack — **DONE**.  
Raise Entire Settlement (весь MOBILE караван) — **DONE** (Formation-offsets).  
Selection-aware control (selected buildings only) — **DONE**.  
Raise Settlement (только TC) как отдельная команда — **backlog** (после Zones v1.1).

### 1.5 Мобильные башни
Watchtower + MobileTower cycle — **DONE (8.0–8.2)**.

### 1.6 Environment Zones
**v1.0 минимальная (blobs + harvest mult) — DONE.**  
Zones v1.1 (сезонное давление) — кандидат после баланс-пасса.

### 1.7 Боевые юниты
Worker, Soldier, Cavalry, SiegeUnit. **Без героев в v1.0.**  
**Без T2/T3 upgrade chain, Places of Power, air roster, magic production в v1.0** (vision: `12_PROGRESSION_AND_TIER_SYSTEM.md`).

### 1.8 Герои
**Не v1.0.** Lore может описывать архетипы; реализация — backlog §2.

### 1.9 Progression tiers
**v1.0 = T1 only** (current content). T2 Орда / T3 Каганат — post balance + Zones v1.1; see `12_PROGRESSION_AND_TIER_SYSTEM.md`.

---

## 2. BACKLOG после v1.0

- Остальные 3 фракции.
- **Полноценная система героев** (XP, абилки, ауры, инвентарь).
- Capture/Steal, animal raid beyond horse node.
- Raise Settlement (TC only) as separate command.
- Zones v1.1 — сезонное / фронтальное давление.
- **T2/T3 tier upgrades** (mobility table + structural unlocks).
- Places of Power + Spirit Sanctuary; magic units; air (falcon / eagle / serpent).
- Full economic enemy AI (shared Order/Resource pipeline).
- Лёт, кампания, multiplayer.
- Лошади как лимит миграции, settlement mass — `NOMAD_WORLD_BACKLOG.md`.
- Fire DoT (не часть visual Burning).
- `03_ECOSYSTEMS_AND_RESOURCES.md` (world doc still planned).

---

## 3. Архитектурные контракты (заморожены)

### 3.1 Order — DONE (M8.1)
### 3.2 DeploymentState — DONE (Phase 4)
### 3.3 Stats `base × tier × deployment` — DONE. Efficiency / tier tables not filled for T2+.
### 3.4 Building mover ≠ unit MovementComponent — DONE
### 3.5 NavigationBakeService — DONE (footprint off on MOBILE, on on UNPACKING)
### 3.6 Horses — DONE (Phase 5)
### 3.7 Damage → Loot — DONE

```
modified_building_damage = max(1, round(base_damage × damage_multiplier))
```

| Type | vs Building |
|------|-------------|
| MELEE | 0.25× |
| RANGED | 0.10× |
| SIEGE | 2.0× |

Siphon: `taken = mini(want, available)`.

### 3.8 Building visual state — DONE (Phase 6.2)
### 3.9 Building auto-attack — DONE (8.0)
### 3.10 Match Win/Lose — все buildings team 0 vs 1
### 3.11 Три уровня мобильности (не смешивать)
1. Философия — `MOBILE_SETTLEMENTS.md` / world docs
2. Механический контракт — `DESIGN_DEPLOYMENT_EFFICIENCY.md`
3. Баланс-цифры — только после прототипов
4. Progression vision — `12_PROGRESSION_AND_TIER_SYSTEM.md`

### 3.12 Scope vs lore
Worldbuilding files are canon for fiction. **Gameplay scope and phase order = this file only.** Lore must not silently add MVP requirements (heroes, T2/T3, magic, air).

### 3.13 Environment Zones v1.0 — DONE
- Только harvest multiplier.
- Приоритет типов в точке: COLD > DRY > FAVORABLE.
- Визуал должен совпадать с доминирующим типом (не аддитивное смешение).

### 3.14 Building selection dual-mode — DONE
- Empty building selection → Pack/Unpack/RMB = entire team-0 MOBILE caravan.
- Non-empty selected mobile buildings → only those.
- Units selection clears buildings and vice versa (как в текущей реализации).

---

## 4. Порядок фаз

1–8. Foundation … Raid/Loot — **DONE**  
8b. Building visual states — **DONE**  
9. Мобильные башни 8.0–8.2 — **DONE**  
9b. Formation-offsets — **ACCEPTED**  
**10. Environment Zones v1.0** — **ACCEPTED**  
10b. (optional) Raise Settlement TC-only vs Entire as separate commands — backlog  
**11. Enemy AI усиление** — **ACCEPTED**  
**12. Полировка v1.0** (debug keys, имена) — **ACCEPTED**  
**+ Selection-aware building control** — **ACCEPTED**  

**Кандидаты после 12:** дожать balance (20s + AFK) · Building HP bar · Zones v1.1 · T2 mobility (vision only until then)

---

## 5. Как работать с этим документом и с Grok

- Единственный источник правды по **gameplay scope** — **этот файл**.
- World lore: `00_WORLD_FOUNDATION.md` … `11_WORLD_CONFLICT.md`.
- Progression vision: `12_PROGRESSION_AND_TIER_SYSTEM.md`.
- Операционно: `TODO.md`, `GROK_WORKLOG.md`, `CURRENT_STATE.md`.
- Дизайн механик: `MOBILE_SETTLEMENTS.md`, `DESIGN_DEPLOYMENT_EFFICIENCY.md`.
- Будущее вне фаз: `NOMAD_WORLD_BACKLOG.md`.

### Правило сессии (Grok / Claude)

1. Grok действует **по конкретному промту**: scope, файлы, запреты.
2. «Готово» = **реальный F5-лог** или (для docs) **чтение файла после commit**.
3. Замороженные контракты (§3) не рефакторить «заодно».
4. Не создавать второй roadmap. Lore / vision doc не расширяет MVP-список.
