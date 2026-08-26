# Nomad Wars — MVP v1.0 Scope и архитектурная дорожная карта

> Документ-якорь для проекта. Обновлять при значимых архитектурных решениях.
> Прикладывать целиком в начале новой сессии с любой моделью (Claude/ChatGPT/Grok).
> Секция CURRENT STATUS ниже меняется часто — обновлять перед каждой сессией.
> Остальные разделы (SCOPE/ARCHITECTURE) меняются редко.

---

## 0. CURRENT STATUS (обновлено 2026-08-26, ветка `nomads-wars-grok`)

**Ветка:** `Ferrum-t/RTS-Game` → `nomads-wars-grok`  
**Движок:** Godot 4.7 stable

### Милестоуны (приняты после F5)

| ID | Содержание | Статус |
|----|------------|--------|
| M1–M6.9 | Movement (NavAgent + bake), Harvest-through-Movement, Siege path | **ACCEPTED** |
| M7 | Stone harvest + stockpile parity с Wood | **ACCEPTED** |
| M8.1 | Order data-object + `replace_order(Order)` dispatcher | **ACCEPTED** |
| M8.2 | Audit ownership target-полей (без Increment 2) | **ACCEPTED** |
| M8.x | Cleanup diagnostic logs | **ACCEPTED** |
| M9 | Playable Match Loop (start setup, Win/Lose, command gate) | **ACCEPTED** |
| Phase 2 | Stat resolver: `get_current_stat` + tier_modifiers on BaseBuilding | **ACCEPTED** |
| Phase 3 | SPIKE: CharacterBody3D mobile building (physics + nav + move) | **ACCEPTED** |
| Phase 4 | DeploymentComponent + Mobile TC (pack/move/unpack + NavBake) | **ACCEPTED** |
| Phase 5 | Horses resource + Cavalry gate (Barracks) | **ACCEPTED** |
| UI-пакет | Horses HUD, Train Cavalry, Pack/Unpack buttons | **ACCEPTED** |
| **Phase 6 Core** | **Building damage modifiers + LootableComponent + SiegeUnit** | **ACCEPTED** |

### Подтверждено в репозитории и F5 (Phase 6)

- **DamageType:** MELEE / RANGED / SIEGE.
- **BuildingDamageRules** (`Scripts/Systems/BuildingDamageRules.gd`):
  - MELEE vs building = **0.25×**
  - RANGED vs building = **0.10×**
  - SIEGE vs building = **2.0×**
  - Формула (проверена логом + кодом):
    ```
    modified_building_damage = max(1, round(base_damage × damage_multiplier))
    ```
    - **округление: `round()`, НЕ `floor()`**
    - при `base_damage > 0` минимум урона по зданию = **1**
  - Примеры: Worker 10→3, Soldier 20→5, Cavalry 25→6, Siege 30→60.
- **LootableComponent** (`Scripts/Components/LootableComponent.gd`):
  - `loot_ratio` (TC default 0.5); pool = modified_damage × loot_ratio
  - пропорциональное распределение по остатку stock
  - **инвариант:** `taken = mini(amount, avail)` — нельзя высосать больше, чем есть
  - enemy: virtual stock; player team 0: global ResourceManager
- **SiegeUnit:** HP 200, base_damage 30, SIEGE, move_speed 3.0; Barracks train (150W+50S, key R)
- RAID verbose logs gated; summary on destroy
- MATCH: VICTORY после destroy enemy buildings

### MatchManager Win/Lose

Только `team_id == 0` и `team_id == 1`. `team_id >= 2` игнорируется (тестовые объекты).

### Известный технический долг

- Enemy buildings в логе как `@CharacterBody3D@N` (косметика spawn naming).
- Debug keys P/M/U/C/R — убрать или спрятать перед релизом.
- TC mobile path без NavigationAgent (застревание в деревьях при MOBILE).
- `NavigationBakeService.AGENT_RADIUS = 1.1` — эмпирика.
- Production single-slot; unit-unit separation при mass attack.
- Полная data-driven генерализация ресурсов — при 6-м типе.

### Следующий шаг по roadmap (§4)

1–7. Foundation … Horses — **DONE**  
8. Raid/Loot Core — **DONE (Phase 6)**  
**8b. ← СЛЕДУЮЩИЙ:** Phase 6.2 Building visual states (Intact / Damaged / Burning / Destroyed)  
9. Мобильные башни  
10. Environment Zones  
11. Enemy AI (простой RTS) — после 6.2  
12. Полировка расы / баланс / Steam-ready

> Урок процесса: код из чата ≠ факт репозитория, пока не подтверждён F5-логом + чтением файла.

---

## 1. V1.0 SCOPE — что входит в первый релиз

Цель v1.0: одна полностью проработанная раса, играбельное ядро, готовое к раннему
доступу / демо в Steam. Приоритет — глубина одной механики, а не широта контента.

### 1.1 Раса
- Одна фракция (выбрать одну из четырёх задуманных), доведённая до релизного
  качества: юниты, здания, арт, звук.
- Остальные 3 фракции — **бэклог**.

### 1.2 Экономика
- Базовые ресурсы: wood, stone, gold (уже есть).
- **Horses** — Phase 5 **DONE** (узел + stockpile + cavalry gate + UI label).

### 1.3 Grab / Raid (Orc-style из Warcraft 3)
- **Phase 6 Core DONE:** урон по зданиям с типом (MELEE/RANGED/SIEGE) +
  мгновенный siphon ресурсов пропорционально modified damage.
- Полноценный Capture/Steal (визуальный угон живых юнитов) — **бэклог**.

### 1.4 Мобильные поселения (главная фича v1.0)
- Town Center: DEPLOYED / PACKING / MOBILE / UNPACKING — **Phase 4 DONE**.
- UI Pack/Unpack — **DONE**.

### 1.5 Мобильные башни
- После Phase 6.2 / параллельно с polish.

### 1.6 Меняющаяся среда (Environment Zones)
- Базовая версия в v1.0 после мобильных башен.

### 1.7 Боевые юниты
- Worker, Soldier, Cavalry, **SiegeUnit (Phase 6)**.

---

## 2. BACKLOG — что сознательно откладывается после v1.0

- Остальные 3 фракции.
- Полноценная система героев.
- Живые угоняемые/приручаемые животные с AI.
- Полный Capture/Steal pipeline.
- Полная климатическая система / «живые агенты» мира.
- Летающие юниты, магия как слой.
- Кампания, multiplayer.
- Fire DoT / распространение огня (не часть Phase 6.2 visual Burning).

---

## 3. Архитектурные контракты

### 3.1 Order abstraction
> **DONE (M8.1).**

### 3.2 DeploymentState
> **DONE (Phase 4).**

### 3.3 Стат-резолюшн base × tier × deployment
> **DONE (Phase 2 + 4).**

### 3.4 Entity-agnostic movement for buildings
> **DONE (Phase 3/4).**

### 3.5 NavigationBakeService dynamic obstacles
> **DONE (Phase 4).**

### 3.6 Horses
> **DONE (Phase 5).**

### 3.7 Damage → Loot (Phase 6 Core)
> **DONE.** Инварианты:
>
> ```
> modified_building_damage = max(1, round(base_damage × damage_multiplier))
> ```
>
> | Type  | vs Building |
> |-------|-------------|
> | MELEE | 0.25×       |
> | RANGED| 0.10×       |
> | SIEGE | 2.0×        |
>
> - Округление: **`round()`** (не floor).
> - Минимум 1 при base_damage > 0.
> - Siphon: `taken = mini(want, available)` — нельзя извлечь больше stock.
> - Файлы: `BuildingDamageRules.gd`, `LootableComponent.gd`, `BaseBuilding.damage()`.

### 3.8 Building visual state (Phase 6.2)
> **Следующий блок** — design-spec ниже / отдельно. Только визуал от % HP.
> Burning ≠ fire DoT.

---

## 4. Порядок фаз

1. Order — **DONE**  
2. Стат-резолвер — **DONE**  
3. Спайк физики — **DONE**  
4. DeploymentComponent — **DONE**  
5. Мобильный TC — **DONE**  
6. Cleanup / UI — **DONE**  
7. Horses + Cavalry — **DONE**  
8. Raid/Loot Core — **DONE (Phase 6)**  
**8b. Building visual states — Phase 6.2 ← следующий**  
9. Мобильные башни  
10. Environment Zones  
11. Enemy AI (простой RTS)  
12. Полировка v1.0

---

## 5. Как использовать этот документ

- Единственный источник правды по scope.
- В начале сессии — этот файл + F5-факт.
- Обновлять §0 и §4 по мере продвижения.
- Формулы урона/лута — только из §3.7 (проверено кодом 2026-08-26).
