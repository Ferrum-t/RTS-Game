# DEVLOG

## 2026-07-07

### Added

- BaseUnit architecture
- Worker unit
- UnitManager autoload
- SelectionManager
- Multi-unit selection
- SelectionBox signal system
- Rectangle selection using screen-space coordinates
- Group movement for selected units

### Result

Nomad Wars now supports selecting multiple units and issuing move commands to the whole group.

This is the first complete RTS gameplay loop implemented.

# Milestone 1 — RTS Core Completed

Date: 2026-07-07

## Completed

- RTS Camera
    - WASD movement
    - Edge scrolling
    - Zoom
    - Rotation

- Base Unit architecture

- UnitManager

- SelectionManager

- CommandManager

- Formation System

- Click Selection

- Box Selection

- Multi Unit Selection

- Move Commands

- Formation Movement

## Result

The project now contains a reusable RTS gameplay foundation suitable for future gameplay systems.

## 2026-07-14

### Refactor

- Introduced Component architecture.
- BaseUnit became a coordinator.
- Movement logic moved to MovementComponent.
- Added BuildingData resource.
- Added BuildCatalog resource.
- BuildPanel now generates UI dynamically.
- GhostBuilding collision system refactored.

### Result

Nomad Wars transitioned from prototype architecture to reusable RTS framework.