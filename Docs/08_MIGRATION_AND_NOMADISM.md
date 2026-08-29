````markdown
# 08_MIGRATION_AND_NOMADISM.md

# Nomad Wars — Migration and Nomadism

**Status:** World Foundation  
**Document:** 08_MIGRATION_AND_NOMADISM.md  
**Scope:** Worldbuilding / Game Design Foundation  
**Version:** 1.0  
**Depends on:**  
- `00_WORLD_FOUNDATION.md`
- `01_WORLD_AND_PLANET.md`
- `02_GEOGRAPHY_AND_CLIMATE.md`
- `04_HISTORY_AND_ORIGIN.md`
- `05_FACTIONS.md`
- `06_CULTURES_AND_WAY_OF_LIFE.md`
- `07_ECONOMY_AND_RESOURCES.md`

---

## 1. PURPOSE

Migration is one of the foundational principles of the Nomad Wars world.

Nomadism is not treated as a decorative cultural theme or merely as an aesthetic reference to historical Central Asian peoples.

It is a **survival and economic adaptation to a changing environment**.

The world itself creates pressure on societies to move.

The central design principle is:

> **The player does not simply change the map. The map changes the player.**

Environmental conditions alter the availability of resources, the suitability of territories and the movement of populations.

Migration therefore becomes part of the strategic identity of the game.

---

# 2. CORE PRINCIPLE

Nomads do not migrate because they dislike permanent settlements.

They migrate because remaining in one place for too long can become economically or physically unsustainable.

The world contains environmental cycles and regional differences that continuously alter the value of territories.

A territory that is highly productive during one period can become significantly less productive later.

This creates a strategic pressure:

```text
ENVIRONMENT
    ↓
RESOURCE AVAILABILITY
    ↓
TERRITORY VALUE
    ↓
MIGRATION PRESSURE
    ↓
SETTLEMENT MOVEMENT
    ↓
ECONOMIC REORGANIZATION
    ↓
CONTACT WITH OTHER SOCIETIES
    ↓
TRADE / COMPETITION / CONFLICT
````

Migration is therefore not an isolated mechanic.

It is part of the complete gameplay loop.

---

# 3. THE LIVING MAP

The strategic map is not completely static.

Environmental zones move or change over time.

The exact implementation of these zones is a gameplay system and should remain independent from the worldbuilding layer.

Conceptually, however, the world contains changing environmental conditions such as:

* favorable periods;
* transition periods;
* drought;
* severe cold;
* changing water availability;
* changing vegetation;
* seasonal animal movement;
* regional environmental hazards.

The zones should not necessarily behave like four perfectly regular geometric squares.

Their shape and movement can depend on:

* terrain;
* rivers;
* mountains;
* forests;
* deserts;
* latitude;
* climate;
* water availability;
* seasonal cycles.

The goal is to create the impression that the world is a **living environmental system**, rather than a board with permanently fixed resource locations.

---

# 4. MIGRATION IS NOT RANDOM MOVEMENT

Migration should never feel like:

> "The game told me to move my base."

The player should understand **why** movement is becoming necessary.

For example:

```text
Grassland productivity ↓
        ↓
Food production ↓
        ↓
Animals become harder to sustain
        ↓
Livestock pressure ↑
        ↓
Economic efficiency ↓
        ↓
Another region becomes more attractive
        ↓
Migration becomes strategically desirable
```

The player should be able to anticipate environmental change and make decisions before a crisis becomes unavoidable.

This creates an important distinction:

### Reactive migration

The player waits until the current territory becomes unusable.

### Strategic migration

The player observes the approaching environmental change and relocates before competitors.

The second should generally be more rewarding.

---

# 5. MIGRATION AS A STRATEGIC RESOURCE

Information about future environmental conditions can itself have strategic value.

A player who knows that a favorable region will soon move toward a particular area can prepare:

* settlement movement;
* military protection;
* scouting;
* resource gathering;
* animal relocation;
* construction;
* trade;
* diplomacy.

This creates the possibility of a strategic role for reconnaissance and information.

A powerful hero or scout does not necessarily have to be powerful because of raw damage.

Some characters may instead provide information about:

* approaching environmental changes;
* resource availability;
* animal migration;
* enemy movement;
* distant territories.

---

# 6. THE SETTLEMENT IS MOBILE

For the nomadic factions, the settlement is not necessarily permanently attached to one location.

The settlement can exist in two broad conditions:

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

The exact states and implementation belong to the game architecture and `MOBILE_SETTLEMENTS.md`.

Conceptually:

### DEPLOYED

The settlement is established.

Buildings have their normal functionality.

Typical advantages:

* higher defensive capability;
* better production;
* better resource processing;
* stronger building-specific abilities.

### MOBILE

The settlement has been packed for migration.

Typical disadvantages:

* slower movement;
* reduced or disabled functionality;
* reduced defensive capability;
* vulnerable transition period.

The purpose is not to make migration free.

Migration is a strategic decision involving risk.

---

# 7. NOT EVERY BUILDING MUST MOVE

Nomadism does not require every structure to be mobile.

Different structures can represent different degrees of permanence.

This distinction is important for both gameplay and worldbuilding.

## Mobile structures

These are structures whose functions can realistically be associated with a travelling society.

Examples:

* main settlement / Town Center;
* certain watchtowers;
* selected military structures;
* mobile workshops;
* selected animal-related infrastructure;
* faction-specific structures.

## Stationary structures

Some structures may require:

* heavy foundations;
* large amounts of material;
* permanent infrastructure;
* favorable terrain;
* access to a particular resource;
* long-term operation.

These structures can remain stationary.

Therefore:

> **A nomadic civilization is not a civilization where everything has wheels.**

It is a civilization where mobility is integrated into the organization of society.

---

# 8. THE MOBILE TOWN CENTER

The Town Center is the clearest representation of this philosophy.

For the relevant factions, it represents the central mobile settlement, such as a large khan's tent, royal camp, great yurt or other faction-specific equivalent.

When deployed, it functions as the political and economic center of the settlement.

When migration begins, it can be packed and moved.

The player can conceptually have two levels of migration:

### Raise Settlement

Move the central structure while leaving other structures behind.

### Raise Entire Settlement

Prepare the complete settlement for migration.

This creates an important strategic choice.

The player does not always have to abandon everything.

A player might:

* move the central settlement;
* leave infrastructure behind;
* establish a forward position;
* abandon obsolete structures;
* return later;
* construct a new settlement elsewhere.

The exact rules are a gameplay balancing decision.

---

# 9. MOBILE DEFENSE

Watchtowers can also participate in migration.

However, mobile and deployed forms should not be identical.

A deployed tower can have:

* higher attack efficiency;
* better range;
* greater defensive capability.

A mobile tower can have:

* reduced attack capability;
* reduced range or attack frequency;
* slower movement;
* limited functionality.

This creates a trade-off:

```text
MOBILE
+ Can relocate
+ Can accompany migration
+ Can establish new defensive positions

-
- Reduced combat effectiveness
- Vulnerable during movement
```

This also allows mobile towers to become strategically interesting beyond simple base defense.

They may accompany an advancing settlement or be positioned near contested territory.

---

# 10. MIGRATION AND CONFLICT

Migration naturally creates territorial conflicts.

If environmental pressure pushes several societies toward the same productive region, their paths may converge.

The resulting conflict does not require a scripted event.

It can emerge naturally:

```text
Climate changes
      ↓
Region A becomes less productive
      ↓
Faction A migrates
      ↓
Faction B is already occupying the destination
      ↓
Competition for resources
      ↓
Diplomacy / trade / intimidation / conflict
```

This is one of the central emergent-design goals of Nomad Wars.

A conflict can occur because **the environment brought the participants together**.

---

# 11. MIGRATION AND RESOURCES

Migration is directly connected to the resource system.

Temporary resources can change in availability according to environmental conditions.

Examples include:

* grass;
* water;
* food;
* animals;
* wood;
* seasonal resources.

Permanent or more stable resources may remain in particular locations:

* mineral deposits;
* valuable stone;
* gold;
* rare materials;
* strategic locations.

This produces different reasons for movement.

A faction may move because:

1. temporary resources disappeared;
2. animals migrated;
3. water became scarce;
4. climate became hostile;
5. another territory became significantly more productive;
6. an enemy occupied the current region;
7. a strategic resource requires relocation;
8. military pressure makes the current position unsafe.

---

# 12. ANIMALS AND MIGRATION

Animals occupy a special position in the Nomad Wars economy.

They can simultaneously represent:

* resources;
* food;
* livestock;
* transportation;
* military potential;
* economic capacity.

Horses are especially important.

At the beginning of the game, a nomadic faction may need to **capture wild horses** before it can fully develop its mounted military potential.

Therefore:

```text
WILD HORSES
    ↓
CAPTURE
    ↓
LIVESTOCK / HERD
    ↓
TRANSPORT CAPACITY
    ↓
MILITARY POTENTIAL
```

This makes animals fundamentally different from ordinary mineral resources.

Losing a herd can damage the player's strategic capabilities even if the player's conventional resource stockpile remains intact.

---

# 13. HORSES AS MILITARY CAPACITY

For the relevant factions, the number and condition of horses can influence the amount of mounted military force that can be maintained.

This should not necessarily be interpreted as:

> one horse = exactly one soldier.

Instead, horses represent an underlying logistical capacity.

They can affect:

* cavalry availability;
* transport;
* scouting;
* migration speed;
* logistics;
* possibly hero mobility.

The exact numerical relationship belongs to Game Design and balancing documents.

The worldbuilding principle is:

> **A nomadic army depends on the same animal economy that supports the civilian population.**

Therefore war and civilian survival are not completely separate systems.

---

# 14. MIGRATION AND RAIDING

Nomadic warfare is closely connected to mobility.

A mobile society can choose to attack without attempting to permanently occupy an enemy's territory.

This creates several possible strategic behaviors:

* raid;
* capture resources;
* steal animals;
* attack infrastructure;
* destroy enemy production;
* capture valuable structures;
* withdraw;
* relocate.

This is connected to the game's planned **raid / loot / plunder mechanics**.

---

# 15. PLUNDER AS AN ECONOMIC MECHANIC

All factions can potentially participate in plunder.

Plunder is not necessarily a faction-exclusive ability.

It can be part of the underlying economic rules of warfare.

For example:

* damaging enemy buildings can produce recoverable resources;
* destroying or capturing animal infrastructure can expose livestock;
* defeated settlements can become temporary sources of supplies.

The goal is to make warfare economically meaningful.

An attack is therefore not always:

> "Kill the enemy army."

It can instead be:

> "Take enough of their resources to sustain your own society."

This reinforces the connection between warfare and survival.

---

# 16. CAPTURING ANIMALS

Animal infrastructure can create additional strategic objectives.

For example, if an enemy stable or similar animal facility is destroyed or captured, its animals may become available for seizure.

A worker or suitable unit could potentially:

* capture;
* drive away;
* transport;
* return the animals to friendly territory.

This can make livestock strategically valuable targets.

It also creates a different kind of raid:

```text
Attack enemy settlement
        ↓
Destroy / capture stable
        ↓
Enemy livestock becomes vulnerable
        ↓
Capture animals
        ↓
Withdraw
```

The exact implementation and unlock timing remain Game Design decisions.

---

# 17. MIGRATION AS A RISK

Migration must have meaningful disadvantages.

Otherwise optimal play becomes:

> constantly move.

Potential costs include:

* temporary production loss;
* reduced defense;
* slower movement;
* inability to use some buildings while mobile;
* vulnerability during packing;
* transportation limitations;
* loss of abandoned structures;
* disrupted economy;
* separation of units;
* exposure to enemy attacks.

The player therefore constantly evaluates:

```text
STAY
vs.
MOVE
```

Neither option should always be correct.

---

# 18. MIGRATION TIMING

Timing should be one of the major strategic skills.

Moving too early can mean:

* abandoning productive territory;
* losing infrastructure;
* arriving before resources are available;
* exposing the settlement unnecessarily.

Moving too late can mean:

* depleted food;
* dying livestock;
* exhausted resources;
* blocked migration routes;
* enemy occupation of the next favorable region.

The ideal player gradually learns to anticipate the environment.

---

# 19. MIGRATION ROUTES

Movement across the map is affected by geography.

Migration routes can be influenced by:

* mountains;
* rivers;
* deserts;
* forests;
* lakes;
* hostile territories;
* resource locations;
* narrow passages;
* bridges;
* seasonal conditions.

Therefore the shortest geographical route is not necessarily the best migration route.

A longer route may provide:

* water;
* grazing;
* safety;
* resources;
* access to trade;
* fewer enemies.

This turns geography into strategic infrastructure.

---

# 20. SEASONAL AND ENVIRONMENTAL DIFFERENCES BETWEEN FACTIONS

Not all factions should respond to environmental change in the same way.

Their cultural and technological adaptations can produce different strategies.

For example:

### Northern / cold-adapted societies

Potential strengths:

* cold resistance;
* better winter mobility;
* access to northern resources;
* specialized animals;
* reduced penalties in cold environments.

Potential weaknesses:

* heat;
* drought;
* southern environments.

### Southern / arid-adapted societies

Potential strengths:

* drought tolerance;
* desert mobility;
* efficient water management;
* heat resistance.

Potential weaknesses:

* extreme cold;
* northern environments.

### Steppe-adapted societies

Potential strengths:

* balanced mobility;
* animal husbandry;
* efficient migration;
* strong cavalry/logistics.

These are conceptual directions rather than final faction balance values.

---

# 21. NOMADISM IS NOT THE ABSENCE OF CIVILIZATION

A major worldbuilding principle is that nomadic societies should not be portrayed as technologically or culturally primitive simply because they move.

They possess:

* political structures;
* traditions;
* military organization;
* crafts;
* trade;
* religion or spiritual systems;
* technologies;
* architecture;
* economic institutions;
* knowledge of geography and climate.

Their civilization is simply organized differently.

Mobility itself can be an advanced adaptation.

---

# 22. NOMADISM AND CULTURAL IDENTITY

The game draws inspiration from cultures that historically existed across the territory of modern Kazakhstan and the broader Eurasian steppe.

The goal is not direct historical recreation.

Cultural references should be transformed into a fantasy setting.

Influences may appear through:

* architecture;
* ornaments;
* clothing;
* weapons;
* animals;
* settlement organization;
* social structures;
* mythology;
* relationship with landscape;
* concepts of movement and territory.

The important principle is:

> **The reference should be felt through the way the society functions, not only through decorative motifs.**

---

# 23. FOUR FOUNDATIONAL NOMADIC TRADITIONS

The initial world contains four major cultural/factional traditions.

Their exact names and final identities are defined in `05_FACTIONS.md`.

Their relationship with migration should differ.

Conceptually:

### Ancient northern tradition

Associated with ancient steppe cultures and large migrating animals.

Their migration may be closely connected with:

* herds;
* cold environments;
* mammoth-like creatures;
* bone, ivory and fur resources.

### Saka-inspired tradition

More strongly associated with:

* animal-style artistic motifs;
* prestige;
* mobility;
* elite warriors;
* fire and spiritual symbolism;
* valuable materials.

### Hunnic-inspired tradition

More robust and militarized.

Potential emphasis:

* large mobile groups;
* practical structures;
* military mobility;
* mass cavalry;
* harsh environmental adaptation.

### Turan / later steppe tradition

The initial MVP faction.

Potential emphasis:

* classical nomadic settlement organization;
* yurts;
* mobile structures;
* mounted warfare;
* wolves and steppe symbolism;
* advanced mobile technologies;
* stronger integration of mobility into the settlement itself.

These are worldbuilding foundations, not final mechanical balance definitions.

---

# 24. MIGRATION AND THE PLAYER EXPERIENCE

The intended player experience is not constant anxiety.

The system should create a rhythm:

```text
SETTLE
   ↓
EXPLOIT
   ↓
OBSERVE
   ↓
PREPARE
   ↓
MIGRATE
   ↓
REBUILD
   ↓
EXPLOIT
   ↓
CONFLICT
   ↓
MIGRATE AGAIN
```

The player should gradually learn to recognize this rhythm.

The game should reward planning rather than simply reacting to emergencies.

---

# 25. MIGRATION AS THE CORE RTS DIFFERENTIATOR

Traditional RTS design often assumes:

```text
BASE
 ↓
RESOURCE
 ↓
BUILD
 ↓
ARMY
 ↓
ATTACK
```

Nomad Wars adds another fundamental dimension:

```text
BASE
 ↓
RESOURCE
 ↓
ENVIRONMENT CHANGES
 ↓
MIGRATION
 ↓
NEW TERRITORY
 ↓
NEW RESOURCES
 ↓
NEW CONTACTS
 ↓
CONFLICT
```

The map therefore participates in the strategy.

It is not merely a battlefield.

It is an active force.

---

# 26. THE CENTRAL PHILOSOPHY

The fundamental philosophy of migration in Nomad Wars can be summarized as:

> **You do not own the land permanently. You survive by understanding when to stay and when to move.**

And more broadly:

> **The strongest society is not necessarily the one that controls the largest territory, but the one that can adapt when the world changes.**

This principle should influence:

* economy;
* architecture;
* military;
* resource systems;
* faction design;
* technology;
* heroes;
* AI behavior;
* map generation;
* environmental systems.

---

# 27. GAMEPLAY CONSEQUENCES

The migration philosophy implies several systems that should eventually exist.

### Required / foundational

* changing environmental zones;
* resource availability affected by environment;
* mobile settlement for relevant factions;
* mobile Town Center;
* mobile or semi-mobile selected buildings;
* migration preparation;
* deployment after movement;
* animal economy;
* horse capture;
* resource depletion / relocation pressure.

### Planned / later

* animal migration;
* advanced scouting and environmental prediction;
* seasonal resource cycles;
* raiding;
* plunder;
* livestock capture;
* faction-specific migration adaptations;
* migration routes;
* environmental forecasting;
* advanced logistics.

---

# 28. MVP PRINCIPLE

The MVP must not attempt to simulate the entire complexity of nomadic civilization.

The minimum viable expression of the philosophy is:

```text
ONE FACTION
    +
CHANGING ENVIRONMENT
    +
RESOURCE PRESSURE
    +
MOBILE TOWN CENTER
    +
MOBILE SELECTED BUILDINGS
    +
ANIMAL / HORSE ECONOMY
    +
BASIC MIGRATION
```

The MVP should prove one fundamental hypothesis:

> **Is an RTS more interesting when the player cannot permanently rely on the same territory?**

If this works, additional layers can be added later.

---

# 29. DESIGN RULES

The following rules should remain stable unless deliberately revised.

### Rule 1

Migration must have a gameplay reason.

### Rule 2

Migration must have a cost or risk.

### Rule 3

The player should be able to anticipate environmental change.

### Rule 4

Not every building needs to be mobile.

### Rule 5

Mobile structures should behave differently while moving.

### Rule 6

Animals are part of the economy, not merely decorative resources.

### Rule 7

Horses can represent military and logistical capacity.

### Rule 8

Warfare can generate economic value through plunder and livestock capture.

### Rule 9

Geography should influence migration routes.

### Rule 10

Different cultures should adapt to migration differently.

### Rule 11

Nomadism should be represented through systems and behavior, not only visual motifs.

### Rule 12

Migration should create opportunities as well as problems.

---

# 30. OPEN DESIGN QUESTIONS

The following questions remain intentionally unresolved.

### Environmental system

* How predictable are environmental zones?
* Are cycles deterministic, semi-random or dynamic?
* How long does a favorable region remain productive?
* Can players manipulate local conditions?

### Migration

* What is the exact cost of raising a settlement?
* How long does packing take?
* Can enemies interrupt packing?
* Can individual buildings be abandoned?
* Can abandoned buildings later be reclaimed?

### Animals

* How are wild horses represented?
* Are horses consumed when creating cavalry?
* Can herds reproduce?
* Can enemies steal livestock?
* Can animals die from environmental conditions?

### Warfare

* How exactly does plunder work?
* Which buildings contain valuable resources?
* Can livestock be captured without destroying its infrastructure?
* Can captured animals change the economic balance of a battle?

### Factions

* Which faction is best at migration?
* Which faction benefits from staying longer?
* Which faction has the strongest mobile infrastructure?
* Which factions are specialized for particular environments?

These questions should be resolved in dedicated Game Design documents rather than prematurely hard-coded into the world foundation.

---

# 31. RELATIONSHIP WITH OTHER DOCUMENTS

This document defines the **world and philosophical foundation** of migration.

It should not contain detailed implementation specifications.

Detailed mechanics belong in:

```text
GameDesign/
├── MOBILE_SETTLEMENTS.md
├── ECONOMY.md
├── RESOURCES.md
├── ANIMAL_ECONOMY.md
├── HORSE_SYSTEM.md
├── RAID_AND_PLUNDER.md
├── ENVIRONMENTAL_ZONES.md
└── SEASONS.md
```

The exact file structure can evolve with the project.

---

# 32. FINAL PRINCIPLE

Nomad Wars is not a game where nomads happen to have mobile buildings.

It is a game where **mobility is one of the consequences of how the world works**.

The environment changes.

Resources move.

Animals move.

People move.

Settlements move.

Trade routes change.

Enemies meet.

Conflicts emerge.

The strategic map therefore becomes part of the simulation rather than merely the space on which the simulation occurs.

The intended fundamental loop is:

```text
WORLD CHANGES
      ↓
RESOURCES CHANGE
      ↓
SOCIETY ADAPTS
      ↓
SETTLEMENT MOVES
      ↓
NEW TERRITORY
      ↓
NEW OPPORTUNITIES
      ↓
NEW CONFLICTS
      ↓
WORLD CHANGES AGAIN
```

**The world moves.
The people adapt.
The settlement follows.
The player decides when to move.**

```
```
