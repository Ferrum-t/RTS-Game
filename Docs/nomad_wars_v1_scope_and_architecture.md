# Nomad Wars — MVP v1.0 Scope и архитектурная дорожная карта

> Документ-якорь для проекта. Обновлять при значимых архитектурных решениях.
> Прикладывать целиком в начале новой сессии с любой моделью (Claude/ChatGPT/Grok).
> Секция CURRENT STATUS ниже меняется часто — обновлять перед каждой сессией.
> Остальные разделы (SCOPE/ARCHITECTURE) меняются редко.

---

## 0. CURRENT STATUS (обновлено 2026-08-25, ветка `nomads-wars-grok`)

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
| **Phase 5** | **Horses resource + Cavalry gate (Barracks)** | **ACCEPTED** |

### Подтверждено в репозитории и F5

- **Movement / Harvest / Combat / Siege / Order / Match / Mobile TC** — без регрессии.
- **Phase 5 (F5 2026-08-25):**
  - `BaseResource.Type.HORSES = 4`; HorseHerd ×2 на World; amount 200.
  - Harvest → bag `Horses:` → deposit `Stockpile Horses:` / `deposited … H:`.
  - Herd depletion → queue_free.
  - Barracks `try_train_cavalry` (100 wood + 1 horse, 6s); debug **C**.
  - Cavalry: HP 180, atk 25, select; siege damage 25; `can_gather=false`.
  - Gate: spend horses (50→49 style via train cost); second cavalry train OK.
  - Soldier train + Tree/Stone + MATCH: VICTORY без регрессии.
  - UI: нет кнопки Cavalry / нет label Horses (сознательно out of scope Phase 5).

### MatchManager Win/Lose

Только `team_id == 0` и `team_id == 1`. `team_id >= 2` игнорируется.

### Известный технический долг

- UI: нет Horses в HUD; нет кнопки Train Cavalry; кнопки Train Worker/Soldier перекрываются.
- Debug keys P/M/U/C — убрать или спрятать перед релизом.
- `spend()` позиционные args — при 6-м ресурсе → data-driven costs.
- `NavigationBakeService.AGENT_RADIUS = 1.1` — эмпирика.
- Production single-slot; `get_nearest_town_center` без team filter.
- TC mobile path без NavigationAgent.

### Следующий шаг по roadmap (§4)

1–5. Order … Mobile TC — **DONE**  
6. Cleanup / UI polish (Horses label, Cavalry button, layout) — кандидат  
7. Horses + Cavalry — **DONE (Phase 5)**  
8. **← СЛЕДУЮЩИЙ крупный блок:** Raid/Loot (числовой gold на hit)  
9. Мобильные башни  
10. Environment Zones  
11. Полировка расы / баланс / Steam-ready

> Урок процесса: код из чата ≠ факт репозитория, пока не подтверждён F5-логом.

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
- **Horses** как новый тип ресурса — упрощённая версия для v1.0:
  - дикие лошади = полу-статичный ресурсный узел (как Stone/Tree), НЕ убегающее
    животное с AI;
  - добыча даёт отдельный ресурс-счётчик "Horses", который **гейтит** доступность
    кавалерии/быстрых юнитов (нет лошадей → нет быстрой армии);
  - полноценная симуляция табунов, дикие лошади с поведением "убегать/бродить",
    приручение живых особей — **бэклог**.

> **Статус:** Phase 5 **DONE** (узел + stockpile + cavalry gate). UI label — долг.

### 1.3 Grab / Raid (Orc-style из Warcraft 3)
- Атака вражеского здания → шанс/гарантированный дроп золота при уроне.
- Атака вражеской конюшни/аналога → шанс получить ресурс "Horses" (числовой лут,
  НЕ анимированная угнанная живая лошадь, бегущая через карту).
- Полноценный Capture/Steal (визуальный угон живых юнитов-животных) — **бэклог**.

### 1.4 Мобильные поселения (главная фича v1.0)
- Town Center: DEPLOYED / PACKING / MOBILE / UNPACKING — **Phase 4 DONE**.
- Команды UI pack/move/unpack — ещё debug keys only.

### 1.5 Мобильные башни
- После Raid или параллельно с UI polish.

### 1.6 Меняющаяся среда (Environment Zones)
- Базовая версия в v1.0 после мобильных башен / Raid.

### 1.7 Боевые юниты
- Worker, Soldier, **Cavalry (Phase 5 DONE)**.

---

## 2. BACKLOG — что сознательно откладывается после v1.0

- Остальные 3 фракции.
- Полноценная система героев.
- Живые угоняемые/приручаемые животные с AI.
- Полный Capture/Steal pipeline.
- Полная климатическая система.
- Летающие юниты, магия как слой.
- Кампания, multiplayer.
- Полная data-driven генерализация ресурсов.

---

## 3. Архитектурные контракты

### 3.1 Order abstraction
> **DONE (M8.1).** RAID type — ещё нет.

### 3.2 DeploymentState
> **DONE (Phase 4).**

### 3.3 Стат-резолюшн base × tier × deployment
> **DONE (Phase 2 + 4).**

### 3.4 Entity-agnostic movement for buildings
> **DONE (Phase 3/4):** CharacterBody3D; TC mover in DeploymentComponent.

### 3.5 NavigationBakeService dynamic obstacles
> **DONE (Phase 4).**

### 3.6 Horses
> **DONE (Phase 5):** Type.HORSES, HorseHerd, stockpile, cavalry gate.

### 3.7 Damage → Loot
> **Следующий крупный блок** (Raid/Loot).

---

## 4. Порядок фаз

1. Order — **DONE**  
2. Стат-резолвер — **DONE**  
3. Спайк физики — **DONE**  
4. DeploymentComponent — **DONE**  
5. Мобильный TC — **DONE**  
6. Cleanup / UI (Horses HUD, Cavalry button, layout)  
7. Horses + Cavalry — **DONE (Phase 5)**  
8. **Raid/Loot** — **← следующий**  
9. Мобильные башни  
10. Environment Zones  
11. Полировка v1.0

---

## 5. Как использовать этот документ

- Единственный источник правды по scope.
- В начале сессии — этот файл + F5-факт.
- Обновлять §0 и §4 по мере продвижения.
