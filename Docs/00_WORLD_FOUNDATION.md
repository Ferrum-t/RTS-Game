Важно разделить то, что мы **уже решили**, и то, что пока является **направлением для дальнейшей проработки**. В предыдущем обсуждении мы специально не хотели преждевременно фиксировать детали вроде окончательных названий рас, точной истории мира и полного списка зданий.

### Что мы хотели добавить по плану

После `00_WORLD_FOUNDATION.md` структура World Bible должна развиваться примерно так:

```text
Docs/
└── World/
    ├── 00_WORLD_FOUNDATION.md
    │
    ├── 01_WORLD_AND_PLANET.md
    ├── 02_GEOGRAPHY_AND_CLIMATE.md
    ├── 03_ENVIRONMENTAL_CYCLES.md
    ├── 04_HISTORY_AND_ORIGIN.md
    ├── 05_FACTIONS.md
    ├── 06_CULTURES_AND_WAY_OF_LIFE.md
    ├── 07_ECONOMY_AND_RESOURCES.md
    ├── 08_MIGRATION_AND_NOMADISM.md
    ├── 09_MILITARY_PHILOSOPHY.md
    ├── 10_MAGIC_AND_TECHNOLOGY.md
    └── 11_WORLD_CONFLICT.md
```

А в `GameDesign/` уже отдельно:

```text
GameDesign/
├── MOBILE_SETTLEMENTS.md
├── MIGRATION_SYSTEM.md
├── ENVIRONMENT_ZONES.md
├── HORSES_AND_ANIMAL_ECONOMY.md
├── RAID_AND_LOOT.md
├── HERO_SYSTEM.md
├── UNIT_CLASSES.md
├── BUILDING_SYSTEM.md
└── FACTION_DESIGN.md
```

Причём **не всё это нужно писать сейчас**. Правильный порядок я вижу таким:

**Шаг 1 — Foundation**
Зафиксировать фундаментальную философию мира.

**Шаг 2 — Planet / Geography / Climate**
Понять, почему вообще существует такая система миграции.

**Шаг 3 — Environmental Cycles**
Разработать движущиеся зоны среды — главную системную особенность игры.

**Шаг 4 — Cultures / Factions**
Только после среды определить, почему четыре народа приспособились к ней по-разному.

**Шаг 5 — Economy**
Horses, food, wood, stone, gold и т.д.

**Шаг 6 — Migration**
Как именно общество физически кочует.

**Шаг 7 — Military**
Почему армии, здания, герои и война выглядят именно так.

**Шаг 8 — Gameplay translation**
Перевести всё это в конкретные игровые системы.

---

# `00_WORLD_FOUNDATION.md`

Ниже — версия, которую я бы сейчас дал Клоду как **канонический foundation-документ**. Я намеренно не превращал гипотезы в установленный lore.

````markdown
# 00 — WORLD FOUNDATION

> **Project:** Nomad Wars  
> **Document:** World Foundation  
> **Status:** Foundation / Canonical Direction  
> **Purpose:** Define the fundamental worldbuilding principles, philosophy and causal foundations of Nomad Wars.
>
> This document is a worldbuilding source of truth.
> It defines principles and established concepts, not implementation details.
>
> If later documents contradict this document, the contradiction must be explicitly identified and resolved rather than silently overriding the foundation.

---

# 1. CORE CONCEPT

Nomad Wars is a fantasy real-time strategy game built around a world in which **environmental change is a fundamental force shaping civilizations, migration, economy and warfare**.

The world is not a static board on which civilizations happen to fight.

The world itself changes.

Environmental conditions move across the map, resources appear and disappear, favorable regions shift, and societies must adapt.

The central design principle is:

> **The player does not control the world.  
> The world forces the player to adapt.**

Or, more concisely:

> **The map changes the players.**

This principle is one of the primary identities of Nomad Wars.

---

# 2. THE CENTRAL PHILOSOPHY

Nomad Wars is not primarily about building the largest permanent settlement.

It is about maintaining a functioning society in a changing world.

A civilization must continuously answer:

- Where can we live?
- Where is water?
- Where are animals?
- Where are temporary resources available?
- How long will this region remain favorable?
- When should we move?
- What should we take with us?
- What should we leave behind?
- Where will another civilization move when its own environment deteriorates?
- When does migration become conflict?

The fundamental gameplay and worldbuilding chain is:

```text
PLANET
    ↓
CLIMATE
    ↓
WATER & RESOURCES
    ↓
ECOSYSTEMS
    ↓
HABITABLE REGIONS
    ↓
MIGRATION
    ↓
SETTLEMENT POSITION
    ↓
ECONOMY
    ↓
MILITARY
    ↓
CONFLICT
````

This causal relationship should remain one of the foundations of the project.

---

# 3. NOMADISM IS NOT AESTHETIC DECORATION

Nomadism in Nomad Wars should not exist merely because the game visually references Central Asian or Eurasian cultures.

The mobile way of life must have a **functional reason**.

Societies became mobile because their environment rewards mobility.

The world contains changing ecological conditions and uneven distribution of resources.

A region can be prosperous for a period of time and later become:

* too dry;
* too cold;
* depleted;
* dangerous;
* inaccessible;
* unsuitable for animals;
* unsuitable for agriculture;
* or otherwise unfavorable.

Therefore mobility becomes an adaptation strategy.

Nomadism is not simply a cultural preference.

It is a response to the structure of the world.

---

# 4. THE WORLD AS A MOVING SYSTEM

One of the defining features of Nomad Wars is the existence of large environmental zones.

These zones represent changing ecological conditions rather than simple decorative biomes.

A simplified early concept consists of several environmental states:

```text
GREEN
Favorable / productive

YELLOW
Transition

RED
Drought / heat / resource stress

BLUE
Cold / winter / severe conditions
```

The important property is not the exact number or color of the zones.

The important property is:

> **The zones move.**

A favorable region can migrate across the map.

Resources associated with favorable conditions can become unavailable.

Another region can become productive.

Civilizations therefore cannot rely indefinitely on one location.

The environment creates pressure for migration.

---

# 5. MIGRATION AS A SOCIAL SYSTEM

Migration is not intended to be equivalent to moving a military unit.

A settlement represents a society.

Therefore migration can involve:

* people;
* animals;
* buildings;
* supplies;
* military forces;
* leaders;
* production infrastructure;
* defensive infrastructure.

A settlement can therefore exist in different states.

Conceptually:

```text
DEPLOYED
    ↓
PACKING
    ↓
MOBILE
    ↓
UNPACKING
    ↓
DEPLOYED
```

The exact gameplay implementation is defined elsewhere.

The worldbuilding principle is:

> **A nomadic society carries part of its civilization with it.**

However, this does not mean every structure must be mobile.

Some things belong to the society.

Some things belong to the land.

This distinction is important.

---

# 6. MOBILE VS STATIONARY CIVILIZATION

Nomad Wars should avoid the simplistic rule:

> "Nomadic civilization = every building can move."

Instead, mobility should have meaning.

A useful conceptual distinction is:

### Mobile infrastructure

Things that primarily belong to the society itself.

Examples may include:

* the central settlement;
* animal infrastructure;
* portable military infrastructure;
* some workshops;
* mobile defensive structures.

### Stationary infrastructure

Things strongly connected to a specific location.

Examples may include:

* permanent sacred sites;
* large defensive structures;
* resource infrastructure;
* major stone structures;
* infrastructure requiring permanent foundations.

This distinction creates an important philosophical contrast:

> **Mobile structures represent the society.
> Stationary structures represent its relationship with a place.**

This principle can later influence faction design.

---

# 7. THE SETTLEMENT IS NOT JUST A BASE

In a conventional RTS, the base is primarily an economic and production structure.

In Nomad Wars, the settlement represents a **mobile community**.

The Town Center therefore has a special role.

For the first playable civilization, the central settlement is envisioned as a mobile khan-like headquarters / great tent or similar nomadic structure.

When deployed, it functions as the center of the settlement.

When necessary, it can be raised and transported.

The settlement may therefore transition between:

```text
SETTLEMENT
    ↓
PREPARATION
    ↓
MIGRATION
    ↓
NEW LOCATION
    ↓
REDEPLOYMENT
```

The act of migration should feel like a social decision rather than a normal building command.

---

# 8. PARTIAL MIGRATION

Migration does not necessarily mean moving everything.

A society may choose:

* to move the entire settlement;
* to move only the central settlement;
* to move selected mobile infrastructure;
* to leave defensive structures behind;
* to abandon infrastructure;
* to establish temporary forward positions.

This creates strategic decisions.

For example:

> The environment is deteriorating.

The player may choose:

```text
MOVE EVERYTHING
```

or:

```text
MOVE THE CORE
LEAVE DEFENSES
```

or:

```text
MOVE ANIMAL INFRASTRUCTURE
KEEP THE CURRENT POSITION
```

This concept is important because migration becomes a strategic trade-off rather than an automatic button.

---

# 9. ANIMALS AS A FUNDAMENTAL PART OF THE ECONOMY

Animals are not merely decorative resources.

For nomadic societies, animals can simultaneously represent:

* food;
* wealth;
* transportation;
* logistics;
* military potential;
* social status;
* economic resilience.

Horses are particularly important.

For the initial playable civilization, wild horses are intended to be obtainable during the early game.

The player therefore does not necessarily begin with unlimited access to cavalry.

The process can conceptually be:

```text
WILD HORSES
    ↓
CAPTURE
    ↓
HERD
    ↓
TRANSPORT / ECONOMY
    ↓
MILITARY POTENTIAL
```

The exact numerical relationship between horses and unit production belongs to the game-design documents.

The worldbuilding principle is:

> **A horse is simultaneously an economic asset, a means of movement and a potential military resource.**

Losing a herd should therefore be meaningful.

---

# 10. RAIDING AND RESOURCE TRANSFER

Conflict in Nomad Wars is not intended to be purely about destroying enemy armies.

A raid can target the enemy's economic ability to survive and migrate.

A major conceptual mechanic is:

> **Damage to an enemy's infrastructure can produce economic benefit for the attacker.**

This includes the possibility of looting resources from damaged or destroyed structures.

Animal infrastructure can create an additional layer.

For example, an enemy stable may contain horses.

Capturing or looting those animals can become strategically valuable.

This establishes a connection:

```text
MILITARY ATTACK
    ↓
INFRASTRUCTURE DAMAGE
    ↓
LOOT
    ↓
RESOURCE TRANSFER
    ↓
ECONOMIC ADVANTAGE
```

Therefore warfare can be motivated by survival and logistics rather than simple territorial conquest.

---

# 11. TERRITORY IS TEMPORARY

Territory in Nomad Wars should not necessarily be understood as permanent ownership of land.

A civilization may occupy a region because it is currently useful.

Later, the same region may become unsuitable.

Another civilization may be forced into it.

Therefore conflict can arise naturally from environmental pressure.

The core chain is:

```text
ENVIRONMENTAL CHANGE
        ↓
RESOURCE CHANGE
        ↓
MIGRATION PRESSURE
        ↓
POPULATION MOVEMENT
        ↓
OVERLAPPING MIGRATION ROUTES
        ↓
COMPETITION
        ↓
CONFLICT
```

This is preferable to relying entirely on artificial reasons such as:

> "Two factions are enemies because the lore says they hate each other."

Historical hatred may exist, but the underlying world should provide material reasons for conflict.

---

# 12. THE CENTRAL CONFLICT OF THE WORLD

The world historically maintained a relatively stable ecological and cultural balance.

Different societies developed different patterns of movement and adaptation.

Each civilization learned how to survive within its own environmental range.

The current world is different.

An external disruption begins to disturb the existing balance.

The exact nature of this disruption is **not yet canonically defined**.

Possible future directions include:

* an ancient force awakening;
* migration from distant lands;
* an external civilization arriving across the ocean;
* a major ecological disturbance;
* another large-scale unknown event.

These are currently possibilities, not established canon.

The important established principle is:

> **Something disrupts the old balance and causes populations to move into regions traditionally occupied by other societies.**

This creates the larger conflict of the setting.

---

# 13. THE WORLD IS LARGER THAN THE PLAYABLE REGION

The known world should feel larger than the initial playable map.

The initial setting is dominated by a huge continental landmass broadly inspired geographically by the Eurasian scale and diversity of landscapes.

It contains:

* grasslands;
* forest-steppe;
* forests;
* tundra;
* deserts;
* mountains;
* large lakes;
* rivers;
* inland seas;
* coastal regions.

There are also:

* island states;
* maritime civilizations;
* smaller settled kingdoms;
* distant territories.

A vast ocean remains poorly explored.

Legends suggest that other continents exist beyond it.

These distant regions provide space for future civilizations, factions and expansions.

They should not need to be fully defined during the initial development.

---

# 14. EXTREME ENVIRONMENTS

The world contains environments far beyond the ordinary habitable steppe.

One particularly extreme southern continent is envisioned as a harsh region combining:

* active volcanism;
* extreme cold;
* permanent ice;
* volcanic terrain;
* potentially lethal environmental conditions.

Parts of this continent may approach conditions conceptually comparable to:

* polar environments;
* extreme deserts;
* volcanic landscapes.

The exact physical plausibility, climate model and geography are future worldbuilding work.

The established concept is:

> **The world contains extreme environmental regions that represent the upper limits of survival.**

These regions can later support unique factions, creatures and gameplay systems.

---

# 15. THE FOUR INITIAL CULTURAL DIRECTIONS

The initial world concept contains four major civilization directions.

They are inspired by cultures that existed across the territory of modern Kazakhstan and the broader Eurasian steppe.

This is intended as an **homage and reinterpretation**, not a literal recreation of historical peoples.

The goal is to transform recognizable cultural ideas into fantasy civilizations.

The cultures should be recognizable through:

* worldview;
* architecture;
* materials;
* social organization;
* relationship with animals;
* warfare;
* mobility;
* visual language;
* mythology.

They should not rely only on superficial costumes or ornaments.

---

# 16. FIRST CULTURAL DIRECTION — ANDRONOVO-INSPIRED

The first civilization is inspired conceptually by the Andronovo cultural horizon.

This civilization is envisioned as an ancient northern / steppe society.

One early concept is that they migrate alongside enormous elephant- or mammoth-like animals.

These creatures are not necessarily literal mammoths.

Their final biology, name and role remain to be designed.

The society may use materials derived from these animals, such as:

* bone;
* tusk;
* hide;
* fur.

Their architecture can therefore emerge directly from their ecological relationship with these animals.

The important concept is:

> **The civilization's material culture is derived from its relationship with a migrating megafauna.**

This creates a culture that is visually and economically distinct without simply copying historical architecture.

---

# 17. SECOND CULTURAL DIRECTION — SAKA-INSPIRED

The second civilization is inspired by Saka cultures and the broader "animal style" tradition of the Eurasian steppe.

Possible visual characteristics include:

* gold;
* red;
* black;
* white;
* elongated architectural forms;
* animal motifs;
* highly decorated objects;
* mobile ceremonial structures.

The civilization may contain heroic figures inspired conceptually by imagery such as the Golden Man and Tomyris.

These characters should be reinterpretations rather than direct copies.

Possible fantasy archetypes include:

* fire-oriented heroes;
* warrior queens;
* powerful archers;
* animal-associated champions.

The final faction identity remains to be designed.

---

# 18. THIRD CULTURAL DIRECTION — HUNNIC-INSPIRED

The third civilization is conceptually inspired by Hunnic-era steppe societies.

It is envisioned as a harsher and more utilitarian culture.

Possible characteristics:

* simpler structures;
* rougher materials;
* massive forms;
* functional architecture;
* strong military orientation.

The visual language may eventually overlap with fantasy archetypes commonly associated with:

* orcs;
* dwarves;
* heavily built warrior societies.

However, these comparisons are references for fantasy readability, not the final identity.

The civilization should ultimately develop its own cultural language.

---

# 19. FOURTH CULTURAL DIRECTION — TURAN / TURKIC-INSPIRED

The fourth civilization represents a broader fantasy interpretation of later Turkic / Eurasian nomadic traditions.

Its current working name is **Turan**, but this name is not final.

This civilization is currently the **only planned playable civilization for the MVP**.

Its initial visual language is based around:

* mobile settlements;
* yurts / tents;
* steppe warfare;
* horses;
* wolves;
* portable infrastructure;
* nomadic military organization.

Possible technological characteristics include a more advanced mechanical tradition, potentially including:

* firearms;
* mechanisms;
* engineered weapons.

These elements are not yet final.

The most important identity of this civilization is:

> **Mobility is not a special ability.
> Mobility is the normal condition of society.**

---

# 20. FUTURE FACTIONS

The four initial civilizations are not intended to exhaust the world.

Future factions may include civilizations or beings associated with environments and regions such as:

* undead;
* demons;
* deep-sea / marine civilizations;
* extreme northern civilizations;
* polar fauna-based cultures;
* distant continents;
* unknown civilizations across the ocean.

These are future possibilities.

They should not constrain the initial MVP.

The world should remain open enough to introduce fundamentally different civilizations later.

---

# 21. FANTASY ELEMENTS

Nomad Wars is a fantasy world.

Therefore the setting may contain:

* magic;
* supernatural creatures;
* heroes;
* flying units;
* magical weapons;
* magical structures;
* mythical animals;
* unusual technologies.

Fantasy elements should nevertheless be integrated into the world's cultures and environmental logic.

The presence of fantasy does not mean that every civilization must have the same fantasy mechanics.

Different societies may interact with magic differently.

For example:

* one civilization may use spiritual traditions;
* another may use elemental magic;
* another may emphasize engineering;
* another may have a biological or animal-based relationship with supernatural forces.

---

# 22. MILITARY PHILOSOPHY

Military forces are an extension of the society.

The army is not completely separate from the civilization's economic and environmental systems.

A civilization's military potential depends on:

* resources;
* animals;
* mobility;
* infrastructure;
* environment;
* technology;
* heroes;
* logistics.

The initial unit taxonomy may include:

### Light

* low armor;
* high mobility;
* lower individual damage.

### Medium

* balanced armor;
* balanced mobility;
* balanced damage.

### Heavy

* high armor;
* high damage;
* low mobility.

Additional battlefield roles may include:

* melee;
* ranged;
* cavalry;
* siege;
* flying;
* magical;
* support;
* heroes.

The exact unit roster belongs to Game Design documentation.

---

# 23. HEROES

Heroes are a major part of the intended identity of the game.

They may be designed with RPG-like characteristics.

Possible hero roles include:

* melee;
* ranged;
* fast / mobile;
* tank;
* support;
* magical;
* specialized battlefield roles.

Heroes may eventually include:

* experience;
* levels;
* abilities;
* auras;
* inventories;
* artifacts.

Auras are particularly important because they can connect heroes to armies.

A hero should not necessarily be valuable only because of personal damage.

A hero may alter the effectiveness of nearby forces.

---

# 24. HERO INVENTORY

A future hero system may include an inventory containing multiple artifacts.

The inventory concept is inspired partly by RPG/MOBA-style item systems.

Artifacts may modify:

* attack;
* defense;
* mobility;
* abilities;
* survivability;
* magical capabilities;
* aura effects.

The exact number of inventory slots and item rules are not yet canonical.

---

# 25. MULTIPLE GAME MODES IN THE FUTURE

Nomad Wars is envisioned not only as one RTS campaign.

The core world and systems should eventually support:

* standard RTS matches;
* campaign missions;
* hero-focused maps;
* Dota-like asymmetric maps;
* tower defense;
* tower placement / defense scenarios;
* other experimental game modes.

The long-term idea is:

> **One world and one technological foundation can support multiple games and modes.**

The RTS is the initial foundation.

Future games or DLCs may reuse:

* units;
* heroes;
* factions;
* environments;
* buildings;
* maps;
* simulation systems;
* lore.

This is a long-term direction, not an MVP requirement.

---

# 26. THE ROLE OF ENVIRONMENT IN GAMEPLAY

Environmental change should affect strategic decisions.

Potential consequences include:

* resource availability;
* animal availability;
* movement;
* production;
* combat effectiveness;
* settlement efficiency;
* survival;
* migration pressure.

Different civilizations may respond differently to the same environmental condition.

This creates faction asymmetry based on adaptation rather than only numerical bonuses.

For example:

```text
SAME ENVIRONMENT
        ↓
DIFFERENT CULTURES
        ↓
DIFFERENT ADAPTATIONS
        ↓
DIFFERENT STRATEGIES
```

This is one of the intended foundations of faction design.

---

# 27. DAY / NIGHT

Time of day may also influence civilizations.

This is a secondary environmental cycle rather than the primary world system.

Possible examples include:

* nocturnal civilizations becoming stronger at night;
* flying units appearing only at certain times;
* reduced effectiveness for civilizations adapted to daylight;
* changes to scouting or visibility.

These ideas are currently conceptual.

The established principle is:

> **Time can become another environmental variable that changes strategic conditions.**

The system must not be allowed to obscure the primary environmental-migration loop.

---

# 28. THE CORE GAMEPLAY PHILOSOPHY

The intended strategic loop is:

```text
ENVIRONMENT
    ↓
RESOURCE AVAILABILITY
    ↓
MIGRATION PRESSURE
    ↓
SETTLEMENT POSITION
    ↓
ECONOMY
    ↓
ARMY
    ↓
CONFLICT
    ↓
RAID / CAPTURE / LOOT
    ↓
MIGRATION
```

The loop should remain circular.

There should be no assumption that the player simply:

```text
builds base
→ gathers resources
→ creates army
→ destroys enemy
```

Instead:

```text
the environment changes
→ the society adapts
→ resources shift
→ settlements move
→ civilizations collide
→ conflict changes resources
→ the environment changes again
```

---

# 29. WHAT MAKES NOMAD WARS DIFFERENT

The intended identity can be summarized through several principles.

### 1. A living map

The map is not static.

### 2. Environmental pressure

Nature changes strategic conditions.

### 3. Migration

Moving the settlement is a normal strategic action.

### 4. Mobile civilization

Part of the civilization itself can move.

### 5. Animals as economy

Animals can connect economy, logistics and military power.

### 6. Raiding

Military conflict can directly affect the enemy economy.

### 7. Cultural adaptation

Civilizations should feel different because they evolved different solutions to the world.

### 8. Heroes

Heroes connect RTS strategy with RPG-like progression.

### 9. Emergent conflict

Environmental pressure can naturally bring civilizations into conflict.

### 10. World expansion

The initial playable world is only part of a much larger setting.

---

# 30. WHAT THE GAME IS NOT

Nomad Wars should avoid becoming:

* a conventional RTS with decorative yurts;
* a reskinned Warcraft;
* a game where all buildings are arbitrarily mobile;
* a game where seasons are purely visual;
* a game where nomadism is only a movement bonus;
* a game where resources are static and migration is optional;
* a lore-heavy world disconnected from gameplay.

The strongest ideas should exist simultaneously in:

```text
LORE
    ↕
WORLD
    ↕
GAMEPLAY
    ↕
SYSTEMS
```

A good worldbuilding decision should have the potential to produce a gameplay consequence.

A good gameplay mechanic should make sense within the world.

---

# 31. DESIGN PRINCIPLE: WORLD → GAMEPLAY

Whenever a major gameplay mechanic is introduced, ask:

> **Why would this exist in the world?**

Whenever a major lore concept is introduced, ask:

> **Can this eventually influence gameplay?**

This prevents the separation between "lore" and "game".

For example:

### Horses

World:

> Horses are economically important animals.

Gameplay:

> Horses influence mobility and military production.

### Migration

World:

> Environmental pressure forces societies to move.

Gameplay:

> The player must relocate settlements.

### Mobile buildings

World:

> Some infrastructure belongs to a mobile society.

Gameplay:

> Selected structures can be packed and transported.

### Raiding

World:

> Conflict over resources affects survival.

Gameplay:

> Damaging enemy infrastructure can produce loot.

---

# 32. SCIENTIFIC / INTERNAL CONSISTENCY PRINCIPLE

Nomad Wars is fantasy, but its world should maintain internal consistency.

Fantasy elements are allowed.

Arbitrary contradictions are not.

When developing the world, distinguish between:

```text
ESTABLISHED CANON
    ↓
PLAUSIBLE DESIGN
    ↓
SPECULATIVE IDEA
```

Uncertain concepts must not silently become established facts.

This is especially important for:

* geography;
* climate;
* ecology;
* animal behavior;
* migration;
* resource systems;
* technology;
* historical inspirations.

---

# 33. CULTURAL APPROACH

The project draws inspiration from the cultures of Central Asia and the Eurasian steppe.

However:

> **Nomad Wars is not a historical reconstruction.**

Historical cultures are sources of inspiration.

The goal is to transform them into fantasy civilizations.

The inspiration should appear through:

* social structures;
* material culture;
* architecture;
* mobility;
* mythology;
* symbolism;
* relationship with animals;
* warfare;
* environmental adaptation.

The project should avoid simply copying historical costumes, weapons or buildings without transforming their underlying logic.

---

# 34. LONG-TERM WORLD STRUCTURE

The world should be developed hierarchically.

The intended order is:

```text
WORLD FOUNDATION
        ↓
PLANET
        ↓
GEOGRAPHY
        ↓
CLIMATE
        ↓
ECOSYSTEMS
        ↓
RESOURCES
        ↓
CULTURES
        ↓
SOCIETIES
        ↓
FACTIONS
        ↓
MILITARY
        ↓
GAMEPLAY
```

This order is not absolute.

However, whenever possible, downstream elements should have an identifiable cause in upstream world rules.

---

# 35. CURRENT CANONICAL MVP FOCUS

The MVP does not need the complete world.

The initial playable civilization is currently the **Turan / Turkic-inspired civilization**.

The MVP should primarily prove:

1. Mobile Town Center.
2. Mobile settlement logic.
3. Deployment states.
4. Partial migration.
5. Horses as an important economic resource.
6. Raiding / loot foundations.
7. Mobile defensive structures.
8. Environmental zones.
9. Environmental pressure on settlement location.
10. A functional RTS loop built around adaptation.

Other civilizations, continents, deep history, large-scale mythology and advanced hero systems may remain future development.

---

# 36. CURRENTLY UNRESOLVED QUESTIONS

The following subjects must remain explicitly open until they are designed:

* final name of the world;
* final name of the Turan civilization;
* final names of all four civilizations;
* exact origin of the world;
* exact historical timeline;
* exact cause of the environmental disruption;
* exact origin of magic;
* exact origin of supernatural creatures;
* exact biology of giant northern animals;
* exact geography;
* exact climate model;
* exact number and behavior of environmental zones;
* final resource taxonomy;
* final technology level;
* final hero roster;
* final antagonist factions;
* exact relationship between historical inspiration and fantasy mythology.

These should be resolved in dedicated documents rather than prematurely fixed here.

---

# 37. DEVELOPMENT PRINCIPLE

The project should grow from a small playable core into a larger world.

Do not attempt to build the entire world before the core gameplay is proven.

The intended progression is:

```text
FOUNDATION
    ↓
MVP WORLD RULES
    ↓
ONE PLAYABLE CIVILIZATION
    ↓
PLAYABLE ENVIRONMENTAL LOOP
    ↓
MIGRATION
    ↓
ECONOMY
    ↓
MILITARY
    ↓
SECOND CIVILIZATION
    ↓
FACTION ASYMMETRY
    ↓
CAMPAIGN / HERO SYSTEM
    ↓
EXPANSION OF THE WORLD
```

The world should support the game.

The game should reveal the world.

Neither should become an independent project disconnected from the other.

---

# 38. THE CORE STATEMENT

The entire concept of Nomad Wars can be reduced to the following principle:

> **Civilizations do not fight because they want territory.
> They fight because the changing world forces them into the same places.**

And the central player experience is:

> **You are not defending a static base.
> You are leading a society through a changing world.**

The environment moves.

Resources move.

People move.

Animals move.

Settlements move.

Borders move.

And eventually:

> **conflict moves with them.**

```

### Что делать после этого

Я бы сейчас **не давал Клоду сразу писать все остальные world-документы**. Этот файл должен стать верхним уровнем, а затем мы последовательно спустимся вниз.

Первым следующим документом я бы сделал:

**`01_WORLD_AND_PLANET.md`**

Туда уже вынести устройство самой планеты: континент, океан, полюса, широты, моря, реки, горы, пустыни, северные/центральные/южные зоны и тот самый экстремальный южный материк.

А затем:

**`02_GEOGRAPHY_AND_CLIMATE.md` → `03_ENVIRONMENTAL_CYCLES.md`**

Именно после этого имеет смысл окончательно проектировать четыре культуры. Иначе мы сначала придумаем народы, а потом будем искусственно объяснять, почему они именно такие. Здесь лучше сделать наоборот: **среда → адаптация → культура**.
```
