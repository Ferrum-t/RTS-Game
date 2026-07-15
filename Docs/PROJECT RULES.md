# PROJECT RULES

Project: RTS Engine
Engine: Godot 4.7+
Language: GDScript 2.0

## Core Principles

- Production-quality architecture only.
- Composition over Inheritance.
- SOLID.
- Data-driven.
- Low coupling.
- High cohesion.
- State Machines (FSM).
- Managers coordinate systems.
- Components implement behavior.
- Base classes contain only common logic.

## Coding Rules

- One class = one responsibility.
- No duplicated logic.
- No temporary hacks unless explicitly marked TODO.
- No circular dependencies.
- Managers never contain gameplay logic.
- Components never communicate directly with UI.
- Systems communicate through Managers.

## File Rules

- Files under 500 lines.
- Prefer multiple small classes over one large class.
- One feature per commit.
- Every refactor must preserve architecture.

## AI Rules

Always return complete files.

Never return patches.

Never use placeholders.

Never omit code.

Files must be immediately replaceable.