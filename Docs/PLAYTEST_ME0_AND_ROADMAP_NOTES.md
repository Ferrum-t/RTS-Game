# Playtest ME-0 + Roadmap Notes (Timur)

**Status:** Brainstorm / playtest evidence — **not** a design contract, **not** implementation authority  
**Date:** 2026-09-23  
**Product:** Nomad Wars  
**Branch:** `nomads-wars-grok`  
**Related:** `CURRENT_STATE.md`, `CLIMATE_UI_AND_PRESSURE_EXTENSIONS_IDEAS.md`, `IDEAS.md`, `NOMAD_WORLD_BACKLOG.md`, `ME0_MIGRATION_INFO_SCOPE_LOCK.md`

> Идеи и замечания после ME-0 playtest (2 матча).  
> При конфликте с `DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md` / `CURRENT_STATE.md` побеждает contract + CURRENT_STATE.  
> Implementation только после отдельного SCOPE LOCK + READY.

---

## 1. Где раньше фиксировали идеи

| Файл | Назначение |
|------|------------|
| `Docs/CLIMATE_UI_AND_PRESSURE_EXTENSIONS_IDEAS.md` | Climate UI, Level 2 зима/лето, 12 лун, Дерево Жизни, SFX |
| `Docs/IDEAS.md` | Короткие one-liners (world flavor) |
| `Docs/NOMAD_WORLD_BACKLOG.md` | Поздний backlog (mobility, fog, multiplayer extras) |
| `Docs/DESIGN_CLIMATE_AND_MIGRATION_PRESSURE.md` | **Канонический** climate design contract |
| `Docs/CURRENT_STATE.md` | Актуальный sprint / accepted slices |
| **Этот файл** | Playtest ME-0 + упорядоченные следующие milestone’ы + RTS UX идеи из сессии |

---

## 2. Climate Playtest Checklist — результат (матч 1–2 после ME-0)

Цель: понять, замечает ли игрок climate pressure и хочется ли кочевать.

| Вопрос | Ответ (Timur) |
|--------|----------------|
| Заметил смену климата домашней зоны **без** постоянного взгляда в консоль? | **Нет** |
| Когда R0 → DRY/COLD — почувствовал, что добыча хуже? | **Нет** |
| Появилось желание **pack TC**? | **Нет** |
| Появилось желание **2nd TC** в лучшей зоне? | **Нет** |
| Лошади suspend/resume — заметно и понятно? | **Нет** |
| В бою думал больше о климате или об армии AI? | **Армия AI** |
| Зоны | Менялись цветом **фоном**, ни на что не толкали |

### Вывод playtest

- ME-0 **технически** ok (log + mult + horses в консоли).
- **В игре** pressure не читается → нужен **Visual / HUD**, не сразу ME-1 pack cost.
- Combat dual-Barracks pressure >> climate; identity «карта меняет игрока» ещё не цепляет.

---

## 3. Зафиксированный порядок milestone’ов (после ME-0)

```text
ME-0 playtest                         ✓
        │
        ▼
CV-0.1  Climate Visual v0.1             ← NEXT (when LOCK)
        · HUD / banner home region state + mult
        · stronger zone readability (not console-only)
        · season_duration ↑ (180s too fast for feel)
        · NO ME-1 cost, NO Level 2, NO train queue
        │
        ▼
MAP-R   Resources in other regions (R2–R7)
        · Wood/Stone/Horses so migration has a destination
        · reduces «AI depletes → raids player trees → dies» dead-end eco
        │
        ▼
(optional parallel UX — separate LOCK each)
UX-T    Remote train / building action without camera home
UX-Q    Training queue + progress bar on panel
UX-F    Food display (usage numbers first; hard caps later)
        │
        ▼
CV-0.2 / Level 2 winter-summer        (soft → hard resource blocks)
12-month indicator (UI only)
ME-1    Soft pack cost (only if Visual still not enough incentive)
Yurts   Supply/food farms (юрта = farm-like supply building)
…       Neutral camps, hero, Power Sites (later)
```

**Явно не смешивать** climate visual + train queue + food/yurts в одном slice.

---

## 4. Детализация идей из сессии (для памяти)

### 4.1 Climate Visual v0.1 (приоритет)

- Player-facing сигнал смены R0 **без** обязательного взгляда в Output.
- Показать state + harvest mult (данные уже есть).
- Увеличить `season_duration_sec` (кандидат 300–480s; точное число — F5).
- Диски зон: уже меняют цвет; усилить читаемость, не заменять HUD.

### 4.2 Карта: ресурсы в других зонах

- Сейчас после depletion AI идёт воровать ресурсы игрока → воркеры мрут под башнями → аул без eco.
- Нужны resource nodes в дальних регионах, чтобы был смысл **перекочевать**, а не только raid home base.

### 4.3 RTS UX — удалённый train / здания

- В рейде на вражеский аул: выставить rally / train soldiers **без** возврата камеры к своему Barracks.
- Кнопка/иконка здания (Barracks и др.) на панели действий.

### 4.4 Очередь тренировки

- Несколько юнитов в очереди (как в классических RTS).
- На панели: сколько в очереди + progress текущего train.

### 4.5 Food / supply

- **Сначала:** отображение food — сколько «съедают» юниты (цифры на шкале).
- **Потом:** лимиты population; здание типа фермы / **жилая юрта** (визуал юрты, функция supply как farm).
- Больше юрт → выше cap (с потолком); уничтожение юрты снижает cap.

### 4.6 Level 2 зима/лето + 12 месяцев

- Уже в `CLIMATE_UI_AND_PRESSURE_EXTENSIONS_IDEAS.md`.
- Playtest подтвердил: сезон слишком быстрый; индикатор 12 месяцев — ясность, не forced move.
- Частичная блокировка ресурсов на жёстком уровне — после Visual + map resources.

### 4.7 ME-1 pack cost

- **Отложен** до проверки Visual. Cost без ощущаемого pressure = пустой штраф.

---

## 5. OUT до отдельных LOCK

- Implementation любого пункта выше без READY
- Смешение climate + UX + supply в одном PR
- Forced migration / auto-pack
- Hero / Power Sites / magic в ближайшем climate visual slice

---

*Записано 2026-09-23 по playtest Timur + разбору Grok. Источник истины sprint: `CURRENT_STATE.md`.*
