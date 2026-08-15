# GROK WORKLOG — Nomad Wars

Документ для быстрого ориентира: что уже сделано с Grok, как устроена архитектура, куда идём.

Ветка: `nomads-wars-grok` (репозиторий `RTS-Game`)

---

## Кто ведёт проект

- **Тимур** — 3D-дизайнер, Godot + vibe-coding, Астана
- **Grok** — архитектура, код, пуш в GitHub
- Цель 3 месяца: навык геймдева + вектор к коммерции
- Визуал сейчас: stylized low-poly / примитивы; позже hand-paint модели

---

## Что уже работает (Фаза 0–1)

| Система | Статус |
|--------|--------|
| Выделение юнитов (клик + box) | OK |
| Движение + формации (квадрат) | OK |
| Ghost building + постройка Town Center | OK |
| Origin зданий/юнитов/земли | OK |
| Harvest дерева | OK |
| Return + deposit на склад | OK |
| ResourceManager + UI (Wood/Stone/Gold/Food) | OK |
| Train Worker (50 wood, 3 сек) | OK |
| BuildingManager / UnitManager Autoload | OK |
| **Combat (минимум)** | OK |

---

## Combat — как пользоваться

1. Обучи 2 Worker (или используй стартового + Train)
2. Выдели одного → **ПКМ по другому**
3. Юнит подходит и бьёт раз в ~1 сек на 10 урона
4. При HP ≤ 0 юнит умирает и удаляется

Лог:
```
Worker -> attack Worker2
Worker hits Worker2 for 10 dmg (HP 90/100)
...
Worker2 died
```

Архитектура боя:
- `CombatComponent` — подход, кулдаун, урон
- `BaseUnit.attack_target` + состояние `ATTACKING`
- `CommandManager.issue_attack`
- `InteractionManager` — ПКМ по `BaseUnit` = атака

Пока нет: команд, дружественный огонь-фильтр, HP-бар на экране, атака зданий.

---

## Архитектура (LEGO)

```
BaseUnit
  ├── MovementComponent
  ├── HarvestComponent
  ├── InventoryComponent
  └── CombatComponent

Managers (Autoload / сценовые)
  UnitManager, BuildingManager, ResourceManager
  ConstructionManager, CommandManager, InteractionManager

Data
  BuildingData, BuildCatalog
```

Новый тип юнита = сцена + нужные компоненты + цифры (export), без копипасты логики.

---

## Дорожная карта (кратко)

1. **Сейчас** — минимальный combat ✅
2. Дальше по приоритету:
   - HP-бар над юнитом (опционально)
   - Стоимость зданий (wood)
   - Камень / второй ресурс
   - 1 боевой юнит (Soldier) отдельный от Worker
   - Простой enemy dummy / AI-заготовка
3. Позже — 2 «пояса жизни», миграция, тиры, герои

Победа в будущем: уничтожение зданий (как WC3).

---

## Как тестировать после Pull

1. GitHub Desktop → Fetch → Pull (`nomads-wars-grok`)
2. Godot → Project → Reload Current Project
3. F5

---

## История сессий (сжато)

- Создана ветка / репозиторий для экспериментов с Grok
- Исправлены origin Town Center, Tree, Worker, Ground
- BuildingManager без class_name (autoload conflict)
- Deposit → ResourceManager + ResourceUI
- Train Worker
- CombatComponent + ПКМ-атака

---

*Файл обновлять при крупных фичах, чтобы не терять контекст между сессиями.*
