# PROJECT RULES

Project: RTS Engine / Nomad Wars  
Engine: Godot 4.7+  
Language: GDScript 2.0

**Process / acceptance (F5, debt vs fix, multi-chat hygiene):**  
→ **[`Docs/ACCEPTANCE_AND_PROCESS.md`](ACCEPTANCE_AND_PROCESS.md)**  
Cite that file when verifying mechanics or closing tasks. Architecture rules below stay here.

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

## AI Rules (code output)

Always return complete files.

Never return patches.

Never use placeholders.

Never omit code.

Files must be immediately replaceable.

## AI Rules (process)

- “Done” requires post-commit F5 evidence — see `ACCEPTANCE_AND_PROCESS.md` §1.
- Prefer narrow isolated fixes before large redesigns — §3.
- Durable facts (balance numbers, debt) go in `Docs/`, not only chat handoffs — §5.
