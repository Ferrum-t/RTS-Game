# AI CONTEXT — Nomad Wars

**Official title (EN):** Nomad Wars  
**Technical:** `NomadWars` · see `Docs/GAME_DESIGN.md` § Official identity

This project is NOT a simple RTS prototype.

Goal:

Build a reusable commercial-quality RTS Framework for **Nomad Wars** (mobile settlements, migration pressure, multi-base economy).

The architecture is more important than adding features quickly.

## Priorities

Architecture  
Performance  
Maintainability  
Scalability

## Current Style

Composition · Managers · Components · Finite State Machines · Data-driven systems · Low coupling · High cohesion

## Rules

Never simplify architecture for short-term gains.  
Never replace Components with inheritance.  
Every gameplay system should remain reusable.  
Assume the project will eventually contain hundreds of units and dozens of buildings.  
Always preserve clean architecture.
