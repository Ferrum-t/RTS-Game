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
| **Phase 2** | **Stat resolver: `get_current_stat` + tier_modifiers on BaseBuilding** | **ACCEPTED** |

### Подтверждено в репозитории и F5

- **Movement / Harvest / Combat / Siege / Order / Match** — как в предыдущем статусе (M1–M9).
- **Phase 2 (tier-часть резолвера):**
  - `Scripts/Systems/DeploymentState.gd` — только `enum State` (DEPLOYED/PACKING/MOBILE/UNPACKING).
  - `BaseBuilding.get_current_stat(stat_name, base_value)` = base × tier_modifiers[tier-1] × deployment_overrides[state].
  - `_ready()`: `max_health = int(get_current_stat(...))` затем `health = max_health` (резолв **только при спавне**).
  - Дефолты `tier_modifiers`: `[{}, {"max_health": 1.5}, {"max_health": 2.0}]` → tier1=500, tier2=750, tier3=1000 при base 500.
  - F5: построенный TC tier=1 → `HP …/500`; тот же тип с tier=2 до `_ready` → `HP …/750`. Словари не шарятся между инстансами.
  - `deployment_overrides` / смена `deployment_state` в рантайме **не** пересчитывают статы — это требование фазы 4.

### «Set tier» в Output — НЕ наш код

В репозитории **нет** `print("Set tier")` и нет кастомного setter для `tier`.  
Строка `Set tier` / `Set team_id` появляется, когда в **Remote Inspector** во время F5 меняют `@export`-свойство — это лог редактора Godot, не игровой print.  
Смена `tier` на уже живом здании **не** вызывает повторный `get_current_stat` (ожидаемо до фазы 4).

### MatchManager Win/Lose (факт кода)

Считает **только** `team_id == 0` (player) и `team_id == 1` (enemy):

- **VICTORY:** когда-то был ≥1 building team 1 **и** сейчас `enemy_alive == 0`.
- **DEFEAT:** когда-то был ≥1 building team 0 **и** сейчас `player_alive == 0`.

Любой другой `team_id` (2, 3, …) **игнорируется** в подсчёте. Поэтому:

- смена **последнего** enemy TC с `1` → `2` → сразу **VICTORY** (team 1 «исчез» без destroy);
- тестовое здание с `team_id = 3` не влияет на Win/Lose, пока живы team 0 и team 1.

Для тестов фазы 3: держать player=0, enemy=1; не менять team_id enemy TC в Inspector.

### Известный технический долг

- `NavigationBakeService.AGENT_RADIUS = 1.1` — эмпирика.
- `MovementComponent.set_target()` пишет `owner.move_target`.
- `CombatComponent` → `owner.velocity` в chase (entity-agnostic movement — фазы 3–4).
- Production single-slot.
- `get_nearest_town_center` без фильтра по `team_id`.
- **MatchManager жёстко team 0/1** — runtime смена team_id в Inspector ломает тесты (зафиксировано F5).
- Enemy TC от MatchManager получает автоимя `@StaticBody3D@N` (не задан `.name`).
- Phase 2: runtime смена tier/deployment **не** резолвит статы заново (нужно в фазе 4).

### Следующий шаг по roadmap (§4)

1. Order — **DONE**  
2. Стат-резолвер (tier) — **DONE**  
3. **← СЛЕДУЮЩИЙ:** спайк физики DEPLOYED ↔ MOBILE  
4. DeploymentComponent + NavBake register/unregister (+ runtime re-resolve stats)  
5. Мобильный Town Center  

> Урок процесса: код из чата ≠ факт репозитория, пока не подтверждён чтением файлов после коммита и F5.

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

### 1.3 Grab / Raid (Orc-style из Warcraft 3)
- Атака вражеского здания → шанс/гарантированный дроп золота при уроне.
- Атака вражеской конюшни/аналога → шанс получить ресурс "Horses" (числовой лут,
  НЕ анимированная угнанная живая лошадь, бегущая через карту).
- Полноценный Capture/Steal (визуальный угон живых юнитов-животных) — **бэклог**.

### 1.4 Мобильные поселения (главная фича v1.0)
- Town Center (аналог Ancient/Tree of Life у NE): два состояния —
  DEPLOYED / MOBILE (плюс переходные PACKING/UNPACKING).
- DEPLOYED: полная экономика, производство, высокая защита/урон (для башен).
- MOBILE: может двигаться, часть функций отключена, стата ниже.
- Команды: "Поднять кочевье" (только TC), "Поднять весь аул" (все мобильные
  здания разом), "Развернуть лагерь" (обратно).
- Частичный переезд (не всё поселение, только выбранные здания) — входит в v1.0
  как минимум на уровне возможности выбрать здания вручную.
- Тиры построек (T1/T2/T3) влияют не только на визуал, но и на характеристики,
  **включая скорость упаковки/разворачивания**.

### 1.5 Мобильные башни
- Могут перемещаться; DEPLOYED = высокий урон/защита/дальность, MOBILE = ниже
  все боевые характеристики, но может двигаться и вести огонь на ходу
  (со штрафом).
- Варианты (обычная/лёгкая/тяжёлая/магическая) — можно ограничить v1.0 одним-двумя
  вариантами, остальное в бэклог.

### 1.6 Меняющаяся среда (Environment Zones)
- Базовая версия: зоны на карте, которые смещаются со временем и влияют минимум
  на доступность/скорость добычи ресурсов (без сложных модификаторов на бой/
  здоровье/видимость — это можно добавить позже через тот же Modifier-механизм).
- Именно она создаёт игровое давление, ради которого нужна механика кочевья —
  без неё "поднять лагерь" не имеет geplay-смысла. Поэтому базовая версия входит
  в v1.0, а не в бэклог.

### 1.7 Боевые юниты
- Базовый набор ролей (melee/ranged/siege) для одной расы, включая кавалерию,
  зависящую от ресурса Horses.
- Тяжёлые/лёгкие/средние — через данные (armor/speed/damage), не через
  подклассы.

---

## 2. BACKLOG — что сознательно откладывается после v1.0

- Остальные 3 фракции.
- Полноценная система героев (XP, abilities, аура, инвентарь, артефакты).
- Живые угоняемые/приручаемые животные с AI (флиться, табуны, дикое поведение).
- Полный Capture/Steal pipeline (визуальный угон юнитов/животных).
- Полная климатическая система (сезоны, модификаторы на бой/здоровье/
  производство/видимость).
- Летающие юниты, магия как отдельный полноценный слой.
- Осадные машины как отдельный класс юнитов (если не входят в v1.0 минимально).
- Кампания, hero maps, tower defense, arena, MOBA-режимы.
- Мультиплеер/netcode.
- Полная data-driven генерализация ресурсной системы под произвольные будущие
  типы (сейчас реализовать ровно под wood/stone/gold/horses).

---

## 3. Архитектурные контракты, которые нужно заложить СЕЙЧАС

Эти пункты нужны именно потому, что без них v1.0-фичи (не бэклог!) лягут как хаки.

### 3.1 Order abstraction
Raid — это по сути ATTACK-приказ с побочным loot-эффектом. Минимальный контракт:
- `Order` как data-объект (type, target, params).
- `Unit.current_order` + `execute_order()`.
- Очередь длины 1 на первом этапе.

> **Статус:** минимальный контракт Order data-object + `replace_order` реализован (M8.1).
> Полный `execute_order()` / очередь / RAID type — ещё нет.

### 3.2 DeploymentState — общий компонент, не bespoke-FSM на здание
```
enum DeploymentState { DEPLOYED, PACKING, MOBILE, UNPACKING }
```
- Отдельный `DeploymentComponent` (фаза 4).
- Сигнал `state_changed(old, new)`.

> **Статус:** enum вынесен в `DeploymentState.gd` (Phase 2). Компонент и переходы — фаза 4.

### 3.3 Стат-резолюшн: base × tier × deployment
Единая функция `get_current_stat` резолвит: base × tier_modifier × deployment_override.

> **Статус Phase 2:** реализовано **на BaseBuilding** (не через BuildingData — подключение Data отложено).
> Tier-часть проверена F5. Deployment overrides + **runtime re-resolve** при смене state — фаза 4.

### 3.4 Movement/Combat компоненты должны быть entity-agnostic
Открытый вопрос: StaticBody3D (DEPLOYED) ↔ CharacterBody3D (MOBILE) — **фаза 3 спайк**.

### 3.5 NavigationBakeService: динамическая регистрация препятствий
register/unregister при DEPLOYED ↔ MOBILE — фаза 4. Ребейк во время движения юнита уже проверен (M6.x).

### 3.6 Horses как отдельный тип ресурса/сущности
Узел добычи + гейт кавалерии — после Mobile TC (фаза 7).

### 3.7 Damage → Loot как отдельный хук
Не на Destroy, а на hit — фаза 8.

---

## 4. Обновлённый порядок фаз (с учётом v1.0-скоупа)

> Примечание (2026-08-25): diagnostic cleanup и Phase 2 (tier resolver) выполнены.

1. **Order abstraction** — **DONE (M8.1)**.
2. **Стат-резолвер base×tier×deployment** — **DONE (Phase 2, tier-часть)**.  
   Runtime re-resolve при deployment — вместе с фазой 4.
3. **Спайк: физика DEPLOYED↔MOBILE в Godot** (см. 3.4) — **← СЛЕДУЮЩИЙ**.
4. **DeploymentComponent + NavigationBakeService register/unregister** (+ re-resolve stats).
5. **Мобильный Town Center**.
6. **Cleanup** — диагносты уже убраны; dead code по мере появления.
7. **Horses как ресурс + гейт кавалерии**.
8. **Raid/Loot (числовой вариант)**.
9. **Мобильные башни**.
10. **Базовая версия Environment Zones**.
11. Полировка одной расы, баланс, UI/UX — до релизного состояния v1.0.

---

## 5. Как использовать этот документ

- Хранить как единственный источник правды по scope и архитектурным решениям.
- В начале новой сессии с любой моделью — прикладывать этот файл + короткий снапшот статуса.
- Не смешивать с оперативными логами/дебагом.
- Обновлять §0 и §4 по мере продвижения.
