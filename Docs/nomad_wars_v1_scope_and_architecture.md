# Nomad Wars — MVP v1.0 Scope и архитектурная дорожная карта

> **Единственный живой документ** по scope / статусу / порядку фаз.
> Не заводить параллельные ROADMAP / ARCHITECTURE / PHASE_8_x_INTEGRATION.
> World lore (`Docs/0x_*.md`) не расширяет gameplay scope молча — при конфликте побеждает этот файл.
> Прикладывать целиком в начале новой сессии.
> §0 менять перед каждой сессией. §1–3 — редко.

---

## 0. CURRENT STATUS (2026-08-28, ветка `nomads-wars-grok`)

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
| Billboard | Pack/unpack bar faces camera | **ACCEPTED** |
| Formation-offsets | Grid dests for multi-MOBILE RMB | **ACCEPTED** |

### Сейчас

**Doc sync (Claude audit 2026-08-28):**
- `01_WORLD_AND_PLANET.md` **есть** в репо (подтверждено чтением дерева).
- `05_FACTIONS.md` §37: убран «at least one hero» из MVP; герои = backlog.
- `05_FACTIONS.md` §10.2: зафиксировано, что в коде сейчас только Raise Entire Settlement (весь караван).
- `03_ECOSYSTEMS_AND_RESOURCES.md` — в related как *planned*, файла ещё нет.

**Caravan move:** RMB по земле при пустом selection юнитов = **все** team-0 MOBILE (Raise Entire Settlement). Raise Settlement (только TC) — после Environment Zones.

**MOBILE unit collision:** tech debt, не блокер.

### Открытые решения (не кодить сейчас)

| ID | Вопрос | Статус |
|----|--------|--------|
| MOBILE combat | Атака off бинарно; vuln ×1.5 TC / ×1.3 tower | Сознательный чойс до баланса |
| A | Selection-aware move зданий | Отложено |
| Raise TC-only | Raise Settlement vs Raise Entire Settlement | **Сейчас только Entire**; разделить команды после Env Zones |
| C | Unpack vs resources/terrain | Средний |
| D | Enemy AI vs MOBILE | Отложено |
| Heroes | Полная система героев | **После v1.0** — lore OK, код не начинать |
| Collision | Unit pass-through MOBILE | Tech debt |

### Следующий шаг

1. **Environment Zones** — внешнее давление на миграцию.
2. Мелкий техдолг: debug keys, имена enemy-buildings; (opt) collision / Raise TC-only.

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
Raise Settlement (только TC) — **после Environment Zones**.

### 1.5 Мобильные башни
Watchtower + MobileTower cycle — **DONE (8.0–8.2)**.

### 1.6 Environment Zones
**Следующий контентный блок.**

### 1.7 Боевые юниты
Worker, Soldier, Cavalry, SiegeUnit. **Без героев в v1.0.**

### 1.8 Герои
**Не v1.0.** Lore (§23–26 в `05_FACTIONS.md`) может описывать архетипы; реализация — backlog §2.

---

## 2. BACKLOG после v1.0

- Остальные 3 фракции.
- **Полноценная система героев** (XP, абилки, ауры, инвентарь).
- Capture/Steal, animal raid beyond horse node.
- Raise Settlement (TC only) как отдельная команда от Raise Entire Settlement.
- Лёт, магия, кампания, multiplayer.
- Лошади как лимит миграции, settlement mass, сигналы соседям — `NOMAD_WORLD_BACKLOG.md`.
- Fire DoT (не часть visual Burning).
- `03_ECOSYSTEMS_AND_RESOURCES.md` (world doc still planned).

---

## 3. Архитектурные контракты (заморожены)

### 3.1 Order — DONE (M8.1)
### 3.2 DeploymentState — DONE (Phase 4)
### 3.3 Stats `base × tier × deployment` — DONE. Efficiency tables не включены.
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

### 3.12 Scope vs lore
Worldbuilding files (`00`–`06`) are canon for fiction. **Gameplay scope and phase order = this file only.** Lore must not silently add MVP requirements (heroes, extra systems).

---

## 4. Порядок фаз

1–8. Foundation … Raid/Loot — **DONE**  
8b. Building visual states — **DONE**  
9. Мобильные башни 8.0–8.2 — **DONE**  
9b. Formation-offsets — **ACCEPTED**  
**10. Environment Zones ← следующий контент**  
10b. (optional) Raise Settlement TC-only vs Entire as separate commands  
11. Enemy AI усиление  
12. Полировка v1.0 (debug keys, имена, MOBILE combat balance, opt collision)

---

## 5. Как работать с этим документом и с Grok

- Единственный источник правды по **gameplay scope** — **этот файл**.
- World lore: `00_WORLD_FOUNDATION.md` … `06_CULTURES_AND_WAY_OF_LIFE.md` (и planned `03_…`).
- Операционно: `TODO.md`, `GROK_WORKLOG.md`, `CURRENT_STATE.md`.
- Дизайн механик: `MOBILE_SETTLEMENTS.md`, `DESIGN_DEPLOYMENT_EFFICIENCY.md`.
- Будущее вне фаз: `NOMAD_WORLD_BACKLOG.md`.

### Правило сессии (Grok / Claude)

1. Grok действует **по конкретному промту**: scope, файлы, запреты.
2. «Готово» = **реальный F5-лог** или (для docs) **чтение файла после commit**.
3. Замороженные контракты (§3) не рефакторить «заодно».
4. Не создавать второй roadmap. Lore doc не расширяет MVP-список.
