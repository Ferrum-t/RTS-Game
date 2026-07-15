# RTS ENGINE ARCHITECTURE

Current Architecture

Game
│
├── Managers
│
│   ├── UnitManager
│   ├── CommandManager
│   ├── InteractionManager
│   ├── ConstructionManager
│   ├── BuildingManager
│
├── Units
│
│   ├── BaseUnit
│   ├── Worker
│   ├── Player
│
├── Components
│
│   ├── MovementComponent
│   ├── HarvestComponent
│   ├── InventoryComponent
│   ├── CombatComponent (planned)
│   ├── BuildComponent (planned)
│
├── Buildings
│
│   ├── BaseBuilding
│   ├── TownCenter
│
├── Resources
│
│   ├── BaseResource
│   ├── Tree
│   ├── Stone (planned)
│
├── Jobs
│
│   ├── HarvestJob
│   ├── BuildJob
│
├── RTS
│
│   ├── SelectionManager
│   ├── SelectionBox
│   ├── Formation
│
└── UI