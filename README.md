# Lab 4: Component Kit

Your fourth lab, built solo, and the first one where the deliverable is a
**kit** instead of a single game. You build a small set of reusable parts
(health, hitbox, hurtbox, and one of your own invention), then prove they are
reusable by bolting the same files onto two different tiny games. The lab
calls those games **cabinets**.

Cabinet A is **Bandit Brawl**: Blitz throws marionberries at the Berry Bandits
you carved on paper in class. Cabinet B is **Crate Crash**: a berry cannon
defends the fig orchard from falling crates. The two cabinets share almost no
gameplay code, and that is the point. The parts in `components/` do the same
job in both.

This is the component pattern and data-driven design from Week 6, and it is
the architecture your team project should grow inside.

## Getting started

1. Accept the assignment link (posted on Canvas), then clone **your** repo:

   ```bash
   git clone <your-repo-url>
   ```

2. Open `project.godot` in Godot (standard build). Run the project. A picker
   screen appears. Press **1** for Cabinet A, **Escape** to come back, then
   **2** for Cabinet B. In both cabinets things move and nothing can be hurt
   yet. That is correct. Damage is your job.
3. Open **`GUIDE.md`** (in this repo) and build milestone by milestone.

## What is already here

- `main.tscn`, the cabinet picker, set as the main scene
- `cabinet_a/`: Blitz (moves and throws berries), three bandits (they chase
  Blitz when he gets close), and the arena
- `cabinet_b/`: the cannon (slides and fires), falling crates, and the orchard
- `shared/`: the berry both cabinets throw, and the arena walls
- `assets/`: all the sprites, including `fig.png` for anyone who wants drops
- Input actions (`move_left`, `move_right`, `move_up`, `move_down`, `throw`,
  `pick_a`, `pick_b`, `back`) and named collision layers, already set up in
  `project.godot`
- This README and `GUIDE.md`

There is no `components/` folder and no `stats/` folder. You create both.

## Requirements

Your submitted project must have, at minimum:

1. A **`components/` folder** holding one copy of every part. Both cabinets
   use those same files.
2. **Health, hitbox, and hurtbox parts** that carry all damage in both
   cabinets. Defeat happens because a part signaled `died`.
3. Parts that follow the **rules of parts**: one job each (you can name it in
   three words), each part owns its data, signals go up and calls go down,
   and no part reaches into its owner (no `get_parent()`, no absolute node
   paths inside `components/`).
4. A **stats Resource** with at least three `.tres` files in use, so tuning
   an entity never means editing a script.
5. **One part of your own**, used by two different entities (see the "Your
   own part" menu at the end of `GUIDE.md`). Name it in **Your Submission**.
6. Class code style: typed variables, `@export` for tunables, named collision
   layers, motion on the correct clock.

The guide shows one way to build the kit. Deviate freely as long as the
requirements are met.

## How to submit

**Pushing to `main` is the submission.** Commit and push at every milestone:

```bash
git add -A
git commit -m "M2: hitbox and hurtbox"
git push
```

Push early, push often. A half-finished kit that is pushed beats a finished
kit that is still on your laptop.

## Useful keys

Run Project: **F5** (**Cmd+B** on Mac) · Run Current Scene: **F6** (**Cmd+R**) · Stop: **F8** (**Cmd+.**)

---

## Your Submission

*Fill this section in before the deadline. It is part of the grade.*

**Screenshot of each cabinet:**

> [Replace this line with two screenshots. Commit the images to the repo and
> embed them: `![cabinet a](shot-a.png)`]

**My parts list:**

> [One line per part in `components/`: its name, its job in three words or
> fewer, and which entities carry it.]

**My wiring sketch:**

> [For one entity (the bandit is a good choice), list who calls down into
> which part and which signals come back up. A text list is fine. A photo of
> a paper sketch is fine too.]

**My tuning sheet:**

> [Which numbers live in your stats Resource, and which `.tres` files exist?
> Name one value you changed while playing and what it did to the feel.]

**My own part (M5):**

> [What is it, what is its one job, and which two entities use it?]

**One thing that surprised me:**

> [A bug, a behavior, a Godot thing. What did you not expect?]
