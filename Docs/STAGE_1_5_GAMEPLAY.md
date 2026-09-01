# Stage 1.5 — Gameplay Design

**Status:** Design open — **no implementation task yet**  
**Depends on:** Stage 1 **ACCEPTED** (`CURRENT_STATE.md`)  
**Process:** `ACCEPTANCE_AND_PROCESS.md` (design before code; §3 — do not invent AI systems without proven need)

**Not this document:** Economy 1.5 implementation, T2 content, zone→harvest wiring, AI migration code.

---

## Why Stage 1.5 exists

Stage 1 delivers a complete T1 fight:

```
ENVIRONMENT → RESOURCES → WORKERS → ECONOMY → MILITARY → ATTACK → RAID → VICTORY/DEFEAT
```

After ~5–10 minutes the risk is a **flat loop**:

```
gather → Barracks → army → attack TC → win/lose → (same again next match)
```

Stage 1.5 answers:

> **Why should the player keep playing after the basic T1 economy has stabilized?**

For **Nomad Wars** the intended identity is not “RTS with nomad skins”, but:

```
map changes → resources change → society must move → army is part of a mobile system
```

---

## Causal chain to design (fill in before any feature code)

For every proposed mid-game beat, answer:

```
What changed on the map / economy?
      ↓
Why is the player forced to react?
      ↓
What choices exist? (develop / migrate / defend / raid / all-in)
      ↓
What is the risk of each choice?
      ↓
What is the payoff?
      ↓
How does that create conflict with the opponent?
```

Do **not** start from “add migration” or “add T2” in isolation. Start from the chain above.

---

## Open design questions

### Environment & resources

- What is the **player-facing** role of moving ecological zones (beyond visual)?
- When do resources become **scarce or wrong-typed** near the home base?
- Is depletion a soft timer toward migration, or a hard local collapse?

### Mobility & settlement

- Why can’t the player just sit on one TC forever?
- What does “migrate” mean in one sentence for the player?
- How do pack/unpack buildings participate in that pressure (already exist in Stage 1)?

### Conflict beyond “kill TC”

- Reasons to attack that are **not** only enemy Town Center?
- Contested space, herds, favorable zones, raid loot, denying a migration path?
- Mid-game decision matrix: develop vs migrate vs defend vs raid vs commit army?

### Progression

- Where does **T2** appear as a *response* to Stage 1.5 pressure (not as a content dump)?
- New win/lose conditions later — only after the loop needs them (see TD-03 coupling).

### AI (only if design requires it)

- Does Stage 1.5 need the AI to understand goal → cost → deficit → workers?
- If **yes** → then open **Economy 1.5 design** with a written requirement from this doc.
- If **no** → keep dual-floor Stage 1 AI; do not complicate the decision layer.

---

## Out of scope until design answers exist

| Topic | Rule |
|--------|------|
| Economy 1.5 code | Frozen unless a question above forces it |
| T2 buildings/units | Frozen |
| Zone harvest multipliers | Stage B; link to a filled “why react” answer |
| AI migration | After migration is a player-facing necessity |
| New unit roster | After conflict reasons are clear |

---

## Working note

Stage 1 foundation is solid enough to **design** mid-game without rewriting the economic AI. Prefer one coherent loop story over parallel feature spikes.

*Created 2026-09-01 after Stage 1 formal sign-off.*
