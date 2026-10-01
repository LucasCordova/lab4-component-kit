# The Build Guide

One way to build the kit, milestone by milestone. Every milestone ends with
something you can run. Commit and push at each one.

Ground rules, same as always:

- **Follow it closely or deviate freely.** Boxes marked *Dials* hold values
  meant to be tuned. Boxes marked *Your call* mark places where the design is
  up to you. The README requirements are the contract.
- **Ask "which class moment is this?"** The parts are Tuesday's lecture
  (a part is a child node). The cuts are Thursday's paper activity (one job,
  one reason to change). The stats files are the four rivals and their
  `.tres` temperaments.

**The kit rule.** Everything you write in `components/` is shared by both
cabinets. A part that needs editing to work in the second cabinet has two
jobs. When that happens, split it.

**Where the starter stands.** Open these two files before you build anything,
because the lab is about what they are missing:

- `cabinet_a/bandit.gd` chases Blitz, and nothing else. It has no health and
  it cannot hurt anyone.
- `cabinet_b/crate.gd` falls, and nothing else.

---

## Milestone 0: Run both cabinets

1. Clone your repo and open `project.godot` in Godot.
2. Run the project. On the picker screen press **1**. Move Blitz with the
   arrow keys or WASD. Press **Space** to throw a berry. Walk near a bandit
   and it chases you. Berries pass through bandits and bandits pass through
   you.
3. Press **Escape**, then **2**. Slide the cannon with left and right, fire
   with **Space**. Crates fall through the orchard and off the screen.
4. Stop the project.

The input actions and the collision layer names are already set up. Look at
them once so nothing later is a mystery: **Project → Project Settings →
Input Map**, and **Project → Project Settings → General → Layer Names → 2D
Physics**.

| Layer box | Name | Who lives on it |
| --- | --- | --- |
| 1 | `world` | The arena walls |
| 2 | `player` | Blitz's body |
| 3 | `enemies` | Bandit bodies |
| 4 | `friendly_hurtbox` | Places where the player's side can be hit |
| 5 | `enemy_hurtbox` | Places where the enemy side can be hit |

---

## Milestone 1: HealthComponent

**The idea:** a part is a child node. This one has one job: track hit points.

**Create the kit folder.**

1. In the **FileSystem** dock (bottom left), right-click **`res://`** and
   choose **New Folder**. Name it **`components`**.
2. Right-click the new `components` folder and choose **New → Script**.
3. In the dialog set **Inherits** to **`Node`**, set the path to
   **`res://components/health_component.gd`**, and click **Create**.
4. Replace the whole file with:

```gdscript
class_name HealthComponent
extends Node
## One job: track hit points. It announces what happened and decides nothing else.

signal changed(current: int)
signal died

@export var max_health: int = 3

var current: int

func _ready() -> void:
	current = max_health

func take_hit(amount: int = 1) -> void:
	if current <= 0:
		return
	current = clampi(current - amount, 0, max_health)
	changed.emit(current)
	if current == 0:
		died.emit()
```

5. Save the script.

Read it once more. It has no sprite and no position. It never frees anything
and never asks who owns it. It counts, and it announces.

**Bolt it onto the bandit.**

1. In the FileSystem dock, double-click **`cabinet_a/bandit.tscn`** to open it.
2. In the **Scene** dock, click the **`Bandit`** root node.
3. Click the **+** button at the top of the Scene dock (Add Child Node).
4. In the search box type **`HealthComponent`**. Select it and click
   **Create**. (It is in the list because of the `class_name` line.)
5. With the new `HealthComponent` node selected, look at the **Inspector**.
   Set **Max Health** to **3**.
6. Save the scene.

**Bolt it onto Blitz.** Open **`cabinet_a/blitz.tscn`** and repeat the same
five steps on the **`Blitz`** root. Set **Max Health** to **5**. Save.

**Let the brains listen.** Open **`cabinet_a/bandit.gd`**. Add these lines
between the comment at the top and `func _physics_process`:

```gdscript
@onready var health: HealthComponent = $HealthComponent

func _ready() -> void:
	health.changed.connect(_on_health_changed)
	health.died.connect(_on_died)

func _on_health_changed(current: int) -> void:
	print(name, " health: ", current)

func _on_died() -> void:
	queue_free()
```

Open **`cabinet_a/blitz.gd`**. Add these lines right under the
`var facing` line:

```gdscript
@onready var health: HealthComponent = $HealthComponent

func _ready() -> void:
	health.changed.connect(_on_health_changed)

func _on_health_changed(current: int) -> void:
	print("Blitz health: ", current)
```

Save both scripts.

**Prove the part works.** Nobody calls `take_hit` yet, so running the game
looks unchanged. Test it with one temporary line. In `bandit.gd`, add this as
the last line of `_ready`:

```gdscript
	health.take_hit(3)
```

Run the project and press **1**. All three bandits vanish at once and the
Output panel shows each one counting down to 0. Signals up: the part
announced `died`, and the brain decided what that means. **Delete the
temporary line** and save.

> **Your call:** `changed` could also carry the maximum, or the amount lost.
> Add what your own part in M5 will want to hear.

**Commit:** `git add -A`, commit, push.

---

## Milestone 2: Hitbox and Hurtbox

**The idea:** damage travels from part to part. A **hitbox** deals damage. A
**hurtbox** is a place where its owner can be hit, and it forwards every hit
to a HealthComponent. No script ever reaches into another entity's health.

**Write the two parts.** Create each one the way you created the health
script (right-click `components`, **New → Script**), but set **Inherits** to
**`Area2D`** for both.

`res://components/hurtbox_component.gd`:

```gdscript
class_name HurtboxComponent
extends Area2D
## One job: be the place where its owner can be hit. It forwards every hit to a HealthComponent.

@export var health: HealthComponent

func take_hit(amount: int) -> void:
	if health != null:
		health.take_hit(amount)
```

`res://components/hitbox_component.gd`:

```gdscript
class_name HitboxComponent
extends Area2D
## One job: deal damage to any HurtboxComponent it touches.

signal landed

@export var damage: int = 1

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		area.take_hit(damage)
		landed.emit()
```

Save both.

**The layer plan.** Hurtboxes sit on a layer. Hitboxes sit on no layer and
mask the hurtbox layer they are allowed to damage.

| Part | Layer | Mask | In words |
| --- | --- | --- | --- |
| Blitz's hurtbox | `friendly_hurtbox` (box 4) | none | "Blitz can be hit here." |
| Bandit's hurtbox | `enemy_hurtbox` (box 5) | none | "The bandit can be hit here." |
| Bandit's hitbox | none | `friendly_hurtbox` (box 4) | "I hurt the player's side." |
| Berry's hitbox | none | `enemy_hurtbox` (box 5) | "I hurt the enemy side." |

**The bandit can be hit.** Open **`cabinet_a/bandit.tscn`**.

1. Click the **`Bandit`** root, click **+**, search **`HurtboxComponent`**,
   click **Create**.
2. With `HurtboxComponent` selected, click **+** again, search
   **`CollisionShape2D`**, click **Create**. In the Inspector choose
   **Shape → New RectangleShape2D**, click the new shape to expand it, and
   set **Size** to **30 x 30**.
3. Click **`HurtboxComponent`** again. In the Inspector find **Health**,
   click **Assign**, pick **`HealthComponent`**, click **OK**.
4. Still on `HurtboxComponent`, open **Collision**. Under **Layer** turn
   **off** box 1 and turn **on** box 5 (`enemy_hurtbox`). Under **Mask** turn
   **off** box 1 so no box is lit.

**The bandit can hurt.** Still in `bandit.tscn`:

1. Click the **`Bandit`** root, click **+**, search **`HitboxComponent`**,
   click **Create**.
2. With `HitboxComponent` selected, add a **`CollisionShape2D`** child with a
   **New RectangleShape2D** of **26 x 26**.
3. Click **`HitboxComponent`**. Under **Collision → Layer** turn **off** box
   1 so no box is lit. Under **Mask** turn **off** box 1 and turn **on** box
   4 (`friendly_hurtbox`). Leave **Damage** at **1**.
4. Save the scene.

**Blitz can be hit.** Open **`cabinet_a/blitz.tscn`**.

1. Click the **`Blitz`** root, add a **`HurtboxComponent`** child.
2. Give it a **`CollisionShape2D`** child with a **New RectangleShape2D** of
   **26 x 26**.
3. On `HurtboxComponent`: **Health → Assign → `HealthComponent`**.
   **Layer**: only box 4 (`friendly_hurtbox`). **Mask**: no boxes.
4. Save the scene.

**The berry can hurt.** Open **`shared/berry.tscn`**.

1. Click the **`Berry`** root, add a **`HitboxComponent`** child.
2. Give it a **`CollisionShape2D`** child with **Shape → New CircleShape2D**,
   **Radius 10**.
3. On `HitboxComponent`: **Layer**: no boxes. **Mask**: only box 5
   (`enemy_hurtbox`).
4. Save the scene.

A berry should disappear when it lands. Open **`shared/berry.gd`** and add
one line at the end of `_ready`:

```gdscript
	$HitboxComponent.landed.connect(queue_free)
```

**Game over is the game's job.** The bandit never decides what happens when
Blitz runs out of health. The cabinet does. Open **`cabinet_a/cabinet_a.gd`**
and replace the whole file with:

```gdscript
extends Node2D
## Cabinet A: Bandit Brawl. Escape walks back to the picker.
## Game over is the game's job: this script listens for Blitz's health running out.

func _ready() -> void:
	$Blitz/HealthComponent.died.connect(_on_blitz_died)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene_to_file("res://main.tscn")

func _on_blitz_died() -> void:
	print("Blitz is out of berries. Restarting.")
	get_tree().reload_current_scene.call_deferred()
```

Save everything and run. Three berries defeat a bandit. A bandit that reaches
Blitz costs him one health per touch (watch the Output panel), and five
touches restart the cabinet.

Compare this with the paper bandit from class. Line 15 of that script reached
into `player.hp` every physics frame. Here the bandit's script never mentions
Blitz's health at all.

> **Dials:** the hitbox and hurtbox sizes. A hurtbox slightly smaller than
> the sprite feels generous to the player. A hitbox slightly smaller than the
> sprite forgives near misses.
>
> **Your call:** the bandit hurts once per touch. A hitbox that hurts again
> every half second while it overlaps is a fine M5 part.

**Commit.**

---

## Milestone 3: The second cabinet

**The idea:** reuse. Cabinet B has no characters at all (the crates and the
orchard are plain `Node2D` scenes), and the kit works anyway. **You do not
open anything in `components/` during this milestone.**

**The crate can be broken, and it can hurt the orchard.** Open
**`cabinet_b/crate.tscn`**.

1. Click the **`Crate`** root, add a **`HealthComponent`** child. Set
   **Max Health** to **1**.
2. Click **`Crate`**, add a **`HurtboxComponent`** child. Give it a
   **`CollisionShape2D`** child with a **New RectangleShape2D** of
   **40 x 40**. On `HurtboxComponent`: **Health → Assign →
   `HealthComponent`**. **Layer**: only box 5 (`enemy_hurtbox`). **Mask**: no
   boxes.
3. Click **`Crate`**, add a **`HitboxComponent`** child. Give it a
   **`CollisionShape2D`** child with a **New RectangleShape2D** of
   **36 x 36**. On `HitboxComponent`: **Layer**: no boxes. **Mask**: only box
   4 (`friendly_hurtbox`).
4. Save the scene.

Open **`cabinet_b/crate.gd`** and add a `_ready` function above `_process`:

```gdscript
func _ready() -> void:
	$HealthComponent.died.connect(queue_free)
	$HitboxComponent.landed.connect(queue_free)
```

**The orchard can be hit.** Open **`cabinet_b/orchard.tscn`**.

1. Click the **`Orchard`** root, add a **`HealthComponent`** child. Set
   **Max Health** to **5**.
2. Click **`Orchard`**, add a **`HurtboxComponent`** child. Give it a
   **`CollisionShape2D`** child with a **New RectangleShape2D** of
   **1152 x 36**. Select that `CollisionShape2D` and in the Inspector open
   **Transform** and set **Position** to **(576, 630)** so it covers the
   green ground strip.
3. On `HurtboxComponent`: **Health → Assign → `HealthComponent`**.
   **Layer**: only box 4 (`friendly_hurtbox`). **Mask**: no boxes.
4. Save the scene.

**The cabinet listens.** Open **`cabinet_b/cabinet_b.gd`**. Add a `_ready`
function above `_process`:

```gdscript
func _ready() -> void:
	$Orchard/HealthComponent.changed.connect(_on_orchard_changed)
	$Orchard/HealthComponent.died.connect(_on_orchard_died)
```

And add these two functions at the bottom of the file:

```gdscript
func _on_orchard_changed(current: int) -> void:
	print("Orchard health: ", current)

func _on_orchard_died() -> void:
	print("The orchard is lost. Restarting.")
	get_tree().reload_current_scene.call_deferred()
```

Save and run cabinet B. One berry breaks a crate. A crate that reaches the
ground costs the orchard one health and breaks. Five crates restart the
cabinet.

The berry needed no changes at all. Its hitbox already masks
`enemy_hurtbox`, and the crate's hurtbox lives there.

**Check the kit rule:** run `git status`. Nothing under `components/` should
be listed as modified.

**Commit.**

---

## Milestone 4: Numbers out of the code

**The idea:** numbers live in data. `bandit.gd` still says `300.0` and
`120.0`, and `crate.gd` still says `60.0`. Those move into a Resource, and
each kind of entity becomes a `.tres` file.

**The tuning sheet class.**

1. In the FileSystem dock, right-click **`res://`**, **New Folder**, name it
   **`stats`**.
2. Right-click `stats`, **New → Script**. **Inherits**: **`Resource`**. Path:
   **`res://stats/entity_stats.gd`**. Click **Create**.
3. Replace the whole file with:

```gdscript
class_name EntityStats
extends Resource
## A tuning sheet. Each .tres file made from this class is one kind of entity.

@export var max_health: int = 3
@export var speed: float = 120.0
@export var sight_range: float = 300.0
@export var touch_damage: int = 1
@export var tint: Color = Color.WHITE
```

4. Save the script.

**Make the files.** For each row below: right-click the **`stats`** folder,
choose **New → Resource**, search **`EntityStats`**, click **Create**, and
save it under the given name. Then double-click the new file and set its
values in the Inspector. Save each one (the save icon at the top of the
Inspector, or save all).

| File | max_health | speed | sight_range | touch_damage | tint |
| --- | --- | --- | --- | --- | --- |
| `bandit.tres` | 3 | 120 | 300 | 1 | white |
| `scout.tres` | 1 | 210 | 420 | 1 | a light cyan |
| `brute.tres` | 6 | 70 | 260 | 2 | a light red |
| `crate.tres` | 1 | 60 | 0 | 1 | white |
| `tough_crate.tres` | 3 | 40 | 0 | 2 | a light purple |

**One new entrance on the health part.** The owner needs a way to hand the
part its maximum from a stats file. Open
**`components/health_component.gd`** and add this function above
`take_hit`:

```gdscript
## Lets the owner re-arm this part from a tuning sheet.
func setup(new_max: int) -> void:
	max_health = new_max
	current = new_max
```

The kit grew by one call down, and both cabinets get it for free.

**The bandit reads its sheet.** Open **`cabinet_a/bandit.gd`** and replace
the whole file with:

```gdscript
extends CharacterBody2D
## A Berry Bandit. The brain chases Blitz. Every number it uses lives in its stats file.

@export var stats: EntityStats

@onready var health: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $HitboxComponent

func _ready() -> void:
	if stats == null:
		stats = EntityStats.new()
	health.setup(stats.max_health)
	hitbox.damage = stats.touch_damage
	$Sprite2D.modulate = stats.tint
	health.changed.connect(_on_health_changed)
	health.died.connect(_on_died)

func _on_health_changed(current: int) -> void:
	print(name, " health: ", current)

func _on_died() -> void:
	queue_free()

func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var to_player: Vector2 = player.global_position - global_position
	if to_player.length() < stats.sight_range:
		velocity = to_player.normalized() * stats.speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
```

Now hand out the sheets:

1. Open **`cabinet_a/bandit.tscn`**, click the **`Bandit`** root, and drag
   **`stats/bandit.tres`** from the FileSystem dock onto the **Stats** slot
   in the Inspector. Save. This is the default for every bandit.
2. Open **`cabinet_a/cabinet_a.tscn`**. Click **`Bandit2`** and drag
   **`stats/brute.tres`** onto its **Stats** slot. Click **`Bandit3`** and
   drag **`stats/scout.tres`** onto its **Stats** slot. Save.

Run cabinet A. One script, three temperaments: a slow red brute that takes
six berries, a fast cyan scout that takes one, and a plain bandit.

**The crate reads its sheet.** Open **`cabinet_b/crate.gd`** and replace the
whole file with:

```gdscript
extends Node2D
## A falling crate. The brain only falls. Every number it uses lives in its stats file.

const OFFSCREEN_Y: float = 700.0

@export var stats: EntityStats

func _ready() -> void:
	if stats == null:
		stats = EntityStats.new()
	$HealthComponent.setup(stats.max_health)
	$HitboxComponent.damage = stats.touch_damage
	$Sprite2D.modulate = stats.tint
	$HealthComponent.died.connect(queue_free)
	$HitboxComponent.landed.connect(queue_free)

func _process(delta: float) -> void:
	position.y += stats.speed * delta
	if position.y > OFFSCREEN_Y:
		queue_free()
```

Open **`cabinet_b/crate.tscn`**, click the **`Crate`** root, drag
**`stats/crate.tres`** onto its **Stats** slot, and save.

**The spawner picks from a list of sheets.** Open
**`cabinet_b/cabinet_b.gd`**.

1. Add this line under the `@export var spawn_every` line:

```gdscript
@export var crate_types: Array[EntityStats] = []
```

2. In `_spawn_crate`, add these two lines right after the
   `var crate := CRATE.instantiate()` line:

```gdscript
	if not crate_types.is_empty():
		crate.stats = crate_types.pick_random()
```

3. Save the script. Open **`cabinet_b/cabinet_b.tscn`** and click the
   **`CabinetB`** root. In the Inspector, expand **Crate Types** and click
   **Add Element** three times. Drag **`stats/crate.tres`** onto the first
   two slots and **`stats/tough_crate.tres`** onto the third. Save.

Run cabinet B. Most crates are plain. About one in three is purple, slower,
takes three berries, and costs the orchard two health.

> **Dials:** every value in every `.tres` file, and the mix in **Crate
> Types**. Change a number, run, feel it, change it again. You are tuning
> the game with no code edit between tries.
>
> **Your call:** crates ignore `sight_range`. If a field that one kind of
> entity ignores bothers you (it should, a little), split the class into two
> Resource types.

**Commit.**

---

## Milestone 5: Your own part (required)

Write **one new component** in `components/` and use it on **two different
entities**. Name it in the README's **Your Submission** section. Before you
write it, run Thursday's three tests on it: can you name its job in three
words, who would ask for it to change, and could it lift out to another
entity untouched?

The menu (or invent your own of similar size):

- **Flash on hit.** Hears `changed` from a HealthComponent and tints a sprite
  for a moment. It needs two exports: the health part to listen to, and the
  sprite to tint.
- **Drop on death.** Hears `died` and spawns a scene at its owner's position
  some of the time. `assets/fig.png` is waiting for this one.
- **Knockback.** When a hurtbox is hit, push the owner away from the hit.
- **Health bar.** A small bar above the owner that hears `changed`.
- **Lifetime.** Frees its owner after a number of seconds. Berries could use
  one.
- **Repeating hitbox.** A hitbox that hurts again on a timer while it still
  overlaps a hurtbox.
- **Invulnerability window.** After a hit, the hurtbox ignores hits for a
  moment.

Two reminders while you build it. The part gets what it needs through
`@export` slots that you assign in the Inspector, and it never calls
`get_parent()`. If it has numbers, they are `@export` values or they live in
a stats file.

**Commit, push, and fill in Your Submission in the README.**

---

## Nothing happened?

| Symptom | Cause and cure |
| --- | --- |
| `HealthComponent` is missing from the Add Child Node list | The script is unsaved, or the `class_name` line is missing or misspelled. Save the script and look again. |
| Berries pass through bandits | Check the layer plan table. The berry's hitbox **Mask** needs box 5, and the bandit's hurtbox **Layer** needs box 5. Whose layer, whose mask? |
| Hits register but health never changes | The hurtbox's **Health** slot is empty. Select the `HurtboxComponent` and assign it. |
| Nothing is ever hit, and the layers are right | The hitbox or hurtbox has no `CollisionShape2D` child, or the shape slot is empty (look for the yellow warning triangle in the Scene dock). |
| Blitz loses health without being touched | Blitz's hurtbox is on box 5 instead of box 4, so his own berries hurt him. |
| The bandit hurts itself at the start | The bandit's hitbox masks box 5. It should mask box 4. |
| "Invalid access to property 'damage' on a null value" or similar | A `$HitboxComponent` or `$HealthComponent` path does not match the node name in the scene. Names are case sensitive. |
| Every bandit looks and acts the same after M4 | The **Stats** slot was set on `bandit.tscn` only. Set it per instance in `cabinet_a.tscn` (click `Bandit2`, then `Bandit3`). |
| A crate crashes with a null `stats` error | The `if stats == null` line is missing from `_ready`, or it runs after a line that reads `stats`. |
| Editor shows stale settings after a checkout | Project Settings do not reload from disk. Run **Project → Reload Current Project** without saving first. |

The checklist, week 6 edition: which scene ran, is the node in it, is the
script saved, whose layer, whose mask, **and is the slot assigned?**
