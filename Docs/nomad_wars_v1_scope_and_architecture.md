# Nomad Wars — MVP v1.0 Scope и архитектурная дорожная карта

> **Единственный живой документ** по scope / статусу / порядку фаз.
> Не заводить параллельные ROADMAP / ARCHITECTURE / PHASE_8_x_INTEGRATION.
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
| **Formation-offsets** | Grid dests for multi-MOBILE RMB | **WAITING F5** |

### Сейчас

**Formation-offsets** — критичный фикс death spiral (лог 27): TC + Watchtower ехали в одну точку, оба `unpack blocked — footprint overlaps`, оба вечно MOBILE, беззащитны, TC умер.

Код: `InteractionManager._try_move_mobile_buildings` — локальная сетка, **без** правки `Formation.gd`. Spacing = `2 * max(nav_half_extents.xz) + 0.4 + 1.5`.

**Caravan move (решено явно):** RMB по земле при пустом selection юнитов двигает **все** team-0 MOBILE здания. Selection-aware move зданий — после building selection, не сейчас.

### F5 formation-offsets

1. TC + Watchtower оба MOBILE.
2. RMB в одну точку (юниты не выделены).
3. Лог: разные `move via RMB to` + `spacing=`.
4. U на обоих → UNPACKING → DEPLOYED, **ноль** `footprint overlaps`.
5. Повтор с близкого старта — цели всё равно разные.

### Открытые решения (не кодить сейчас)

| ID | Вопрос | Статус |
|----|--------|--------|
| MOBILE combat | Атака в MOBILE выключена бинарно (не %). Входящий урон ×1.5 TC / ×1.3 tower. | **Сознательный чойс до баланса.** Не случайность. Лог 27 показал цену. |
| A | Selection-aware move зданий | Отложено: нет building selection. Сейчас = весь караван. |
| C | Unpack vs resources/terrain | Средний. Сейчас только building-vs-building. |
| D | Enemy AI vs MOBILE buildings | Отложено (баланс/AI). |

### Следующий шаг

1. F5 accept formation-offsets.
2. **Environment Zones** — внешнее давление, иначе мобильность геймплейно пуста.
3. Мелкий техдолг перед публичным билдом: спрятать P/M/U/C/R; имена enemy-buildings вместо `@CharacterBody3D@N`.

---

## 1. V1.0 SCOPE

Цель v1.0: одна раса, играбельное ядро, ранний Steam. Глубина одной механики, не ширина контента.

### 1.1 Раса
Одна фракция до релизного качества. Остальные 3 — бэклог.

### 1.2 Экономика
Wood, stone, gold, **Horses (Phase 5 DONE)**.

### 1.3 Grab / Raid
Phase 6 Core **DONE**. Capture/Steal юнитов — бэклог.

### 1.4 Мобильные поселения
Town Center DEPLOYED/PACKING/MOBILE/UNPACKING — **DONE**. UI Pack/Unpack — **DONE**.

### 1.5 Мобильные башни
Watchtower auto-attack + MobileTower cycle — **DONE (8.0–8.2)**. Efficiency tables — баланс, не сейчас.

### 1.6 Environment Zones
**Следующий контентный блок после F5 formation.** Без зон у игрока нет причины поднимать лагерь.

### 1.7 Боевые юниты
Worker, Soldier, Cavalry, SiegeUnit.

---

## 2. BACKLOG после v1.0

- Остальные 3 фракции, герои, Capture/Steal, лёт, магия, кампания, multiplayer.
- Лошади как лимит миграции, settlement mass, сигналы соседям — `NOMAD_WORLD_BACKLOG.md`.
- Fire DoT (не часть visual Burning).

---

## 3. Архитектурные контракты (заморожены)

### 3.1 Order — DONE (M8.1)
### 3.2 DeploymentState — DONE (Phase 4)
### 3.3 Stats `base × tier × deployment` — DONE (Phase 2+4). Efficiency tables не включены.
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
INTACT / DAMAGED / BURNING / DESTROYED от % HP. Burning ≠ fire DoT.

### 3.9 Building auto-attack — DONE (8.0)
`BuildingCombatComponent` сканирует `UnitManager.units` (0.4s). Нет Area3D. `BaseUnit.damage()`. Только при `DEPLOYED`.

### 3.10 Match Win/Lose
Все живые buildings team 0 vs 1. `team_id >= 2` игнор.

### 3.11 Три уровня мобильности (не смешивать)
1. Философия — `MOBILE_SETTLEMENTS.md`
2. Механический контракт — `DESIGN_DEPLOYMENT_EFFICIENCY.md`
3. Баланс-цифры — только после прототипов

---

## 4. Порядок фаз

1–8. Foundation … Raid/Loot — **DONE**  
8b. Building visual states — **DONE**  
9. Мобильные башни 8.0–8.2 — **DONE**  
9b. Formation-offsets — **WAITING F5**  
**10. Environment Zones ← следующий контент**  
11. Enemy AI усиление (экономика / реакция на MOBILE)  
12. Полировка v1.0 (спрятать debug keys, имена, баланс MOBILE combat)

---

## 5. Как работать с этим документом и с Grok

- Единственный источник правды по scope — **этот файл**.
- Операционно: `TODO.md` (чеклист), `GROK_WORKLOG.md` (история), `CURRENT_STATE.md` (короткий указатель сюда).
- Дизайн: `MOBILE_SETTLEMENTS.md`, `DESIGN_DEPLOYMENT_EFFICIENCY.md`, `00_WORLD_FOUNDATION.md`.
- Будущее вне фаз: `NOMAD_WORLD_BACKLOG.md`.

### Правило сессии (Grok / Claude)

1. Grok действует **по конкретному промту**: scope, файлы, запреты. Не «реализуй что посчитаешь нужным».
2. «Готово» подтверждается **реальным F5-логом**, не пересказом.
3. Замороженные контракты (§3) не рефакторить «заодно».
4. Не создавать второй roadmap. После приёмки фазы — строка в §0/§4, не новый `PHASE_X_INTEGRATION.md` навсегда.
