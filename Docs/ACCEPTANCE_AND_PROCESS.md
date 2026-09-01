# Acceptance & Process Rules

**Branch:** `nomads-wars-grok`  
**Audience:** human + any AI chat (Grok, GPT, Gemini, Claude, …)  
**Purpose:** single place to cite when someone says “check like we always do” / “по правилам приёмки”.

This document captures the **recurring process discipline** used on Nomad Wars (often restated by Claude audits). It is **not** lore and **not** feature design. If process and feature conflict, **process wins for “done” claims**.

**Related:** `PROJECT_RULES.md` (code architecture) · `TECH_DEBT.md` (open gaps) · `CURRENT_STATE.md` (what works) · `TODO.md` (checklist) · `GROK_WORKLOG.md` (session trail)

---

## 1. Definition of Done

| Claim | Required evidence |
|--------|-------------------|
| “Fixed” / “Works” / “Closed” | **F5 (or full match) log** from **after** the commit, with explicit criteria checked |
| “Described” / “Documented” | Entry in `TECH_DEBT.md` / `CURRENT_STATE.md` / this file — **not** the same as Done |
| “Should work” / paraphrase of code | **Not** acceptance |

**Rule:** готово = F5-лог, не пересказ.

No log after a code commit → item stays **open** even if the patch looks correct.

---

## 2. Fix now vs document for later

| Kind | Action |
|------|--------|
| **P0 / isolated functional break** (wrong behavior every match, irreversible stick, crash) | Code fix, **narrow** scope, then F5 |
| **Architectural debt** (e.g. AI placement ≠ player `can_build`) | `TECH_DEBT.md` + optional TODO bullet; **no** drive-by rewrite |
| **Design Stage N+1** (Economy 1.5, zone harvest, new victory) | Docs + roadmap; **do not** pretend Stage 1 already has it |
| **Confirmed healthy** (nav rebake, door/rally on BaseBuilding) | Note in `CURRENT_STATE` / TECH_DEBT “confirmed”; no ticket spam |

**Rule:** one concern per change. Do not “while we’re here” wire zones into AI, rewrite goal stacks, and fix placement in the same step.

---

## 3. Narrow fix before big system

When a symptom is clear (example: irreversible `stone < 50 ? stone : wood`):

1. **First** — smallest change that removes the failure mode (dual floor / alternate).  
2. **F5** against written criteria.  
3. **Only then** — larger model (BUILDING_GOAL → REQUIREMENT → DEFICIT → assign) if still needed.

**Rule:** do not build Economy 1.5 (or any big framework) on top of an unfixed structural hole or an unproven hypothesis.

---

## 4. What an F5 / control match must contain

Before calling a change accepted, the requester or implementer lists **checkable** items, for example:

- Exact log lines that must appear **once** (e.g. one `attack threshold reached` / `attack issued` per army wave).
- Lines that must **not** spam every AI tick.
- Behavioral checks (units path smoothly; no re-issue stutter every ~1–2 s).
- Edge path (reinforcement joins attack; late trainee gets AI).
- Economy checks if relevant (resource A not abandoned forever; no permanent `not enough X` while stockpile Y is huge).

**Rule:** criteria are written **before** or **with** the fix request, not invented after a green-looking session.

---

## 5. Multi-chat / multi-model hygiene

Several models and chats touch this repo. To keep a shared truth:

1. **Canonical facts live in the repo**, not only in a handoff paragraph for another chat.  
   - Balance numbers (TC positions, map distance, resource amounts, speeds, AI thresholds) → `CURRENT_STATE.md` or a dedicated balance section/file.  
   - Debt → `TECH_DEBT.md` with code anchors.  
   - Process → **this file**.
2. Handoff reports for GPT/Gemini/Grok are fine; **copy durable numbers into docs in the same session** when they change.
3. When auditing, prefer quoting **file + symbol** (`EconomicAIController._pick_resource_for_worker`) over “the AI script”.
4. After map/balance moves, **re-verify** assumptions that depended on old geometry (e.g. AI `barracks_offset`) — “worked on old map” ≠ “works on new map”.

**Rule:** chat lore ≠ repo fact. If it’s needed next week, it must be in `Docs/`.

---

## 6. Documentation layout (who owns what)

| File | Owns |
|------|------|
| `ACCEPTANCE_AND_PROCESS.md` | How we accept work (this file) |
| `PROJECT_RULES.md` | Code architecture & AI coding output rules |
| `AI_CONTEXT.md` | Framework goals / no architecture shortcuts |
| `TECH_DEBT.md` | Open gaps, severity, fix sketches, audit index |
| `CURRENT_STATE.md` | What systems work; Stage status; balance snapshot |
| `TODO.md` | Short checklist + links to TECH_DEBT |
| `GROK_WORKLOG.md` | Chronological session notes (not source of truth for balance) |

Do **not** dump long debt essays into `TODO.md`. Do **not** put process rules only inside a single chat transcript.

---

## 7. Re-issue / order spam class of bugs

This project has already hit “re-issue the same order every tick/frame” bugs (movement pingpong, attack spam). Treat as a **known hazard class**:

- Decision layers that run on an interval must **not** blindly re-call `replace_order_*` / attach AI every pulse when state is unchanged.
- Prefer: one-shot flags, “only if missing component”, “only if order target changed”.
- F5 should look for **smooth progress** toward target, not only absence of error spam.

---

## 8. How to cite this document

In chat or PR descriptions:

```text
See Docs/ACCEPTANCE_AND_PROCESS.md §1 (Definition of Done)
See Docs/ACCEPTANCE_AND_PROCESS.md §3 (narrow fix before big system)
See Docs/ACCEPTANCE_AND_PROCESS.md §5 (repo fact vs chat lore)
```

For a new mechanic, a minimal request template:

```text
Change: <one sentence>
Files allowed: <list>
Out of scope: <list>
F5 criteria:
  1. ...
  2. ...
Debt if not fixing now: TD-XX or new entry in TECH_DEBT.md
```

---

## 9. Stage 1 example (illustrative, historical)

Applied successfully on this branch:

| Item | Process outcome |
|------|-----------------|
| Attack issue spam | Code fix → F5 showed one threshold/issued + reinforcements |
| Dual stock floor harvest | Narrow fix only → F5 wood recovery; not full Economy 1.5 |
| TD-01 placement pipeline | Documented, not rewritten |
| TD-03 post-TC residual AI | Accepted Stage 1 behavior, no code |
| Zones economic effect | Explicitly deferred |

Use as a pattern, not as a freeze on future design.

---

*Last updated: 2026-09-01 — extracted from recurring Claude/process audits so any chat can link one URL instead of re-deriving the rules.*
