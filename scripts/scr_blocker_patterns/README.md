# Procedural Blocker Pattern System

This document explains how ArcadeRush generates scrolling obstacle formations.
The system only controls these obstacle objects:

- `obj_blocker1`
- `obj_blocker2`
- `obj_blocker3`

UFO Catcher, Key Master, Scalpers, player damage, and obstacle movement remain
separate systems.

## Architecture

The generator is split between two areas:

- `obj_controller` decides when to spawn a row and which pattern to use.
- `scr_blocker_patterns` defines the patterns and converts row masks into
  obstacle instances.

The pattern system creates obstacles but does not move them. After creation,
the obstacles inherit scrolling, pushing, depth sorting, and cleanup behavior
from `par_scrolling_blocker`.

## Pattern format

Every pattern is a struct containing a name, difficulty tier, and four rows:

```gml
{
    name: "Classic sweep",
    tier: 0,
    rows: [1, 2, 4, 8]
}
```

- `name` identifies the formation.
- `tier` controls when the formation is likely to appear.
- `rows` contains four masks that spawn one after another.

The script currently contains 52 patterns and 208 authored rows.

## Lane masks

The four lanes are represented as bits from left to right:

| Mask | Binary | Occupied area |
| ---: | :---: | --- |
| `0` | `0000` | Empty breather row |
| `1` | `0001` | Lane 1 |
| `2` | `0010` | Lane 2 |
| `4` | `0100` | Lane 3 |
| `8` | `1000` | Lane 4 |
| `3` | `0011` | Lanes 1-2 |
| `6` | `0110` | Lanes 2-3 |
| `12` | `1100` | Lanes 3-4 |
| `9` | `1001` | Lanes 1 and 4 |

For example, `[1, 2, 4, 8]` produces a left-to-right sweep. The first row
uses lane 1, the second uses lane 2, and so on.

## Lane measurements

The measured playable area uses these controller values:

```gml
blocker_lane_left = 124;
blocker_lane_width = 208;
blocker_lane_count = 4;
```

This creates the following positions:

| Placement | Center X |
| --- | ---: |
| Lane 1 | `228` |
| Lane 2 | `436` |
| Lane 3 | `644` |
| Lane 4 | `852` |
| Lanes 1-2 | `332` |
| Lanes 2-3 | `540` |
| Lanes 3-4 | `748` |

The separate `blocker_spawn_left` and `blocker_spawn_right` controller values
are retained for the UFO and player recovery systems. Pattern placement uses
the measured lane values above.

## Mapping masks to obstacle objects

### One-lane rows

Masks `1`, `2`, `4`, and `8` randomly choose either:

- `obj_blocker1`
- `obj_blocker2`

Both objects occupy one lane.

### Two-lane rows

Masks `3`, `6`, and `12` create `obj_blocker3`, which occupies two adjacent
lanes:

- Mask `3`: lanes 1-2
- Mask `6`: lanes 2-3
- Mask `12`: lanes 3-4

### Outer-pair rows

Mask `9` creates two one-lane obstacles, one in lane 1 and one in lane 4. Each
side independently chooses blocker 1 or blocker 2. The two middle lanes remain
open.

### Unknown masks

If an unsupported mask is added accidentally, the spawner degrades it to one
one-lane obstacle instead of creating an unsafe wall.

## Controller initialization

The controller Create event initializes the generator:

```gml
blocker_generation_enabled = true;
blocker_spawn_timer = 0.85;
blocker_spawn_buffer = 64;
blocker_row_spacing_min = 410;
blocker_row_spacing_max = 520;
blocker_patterns = scr_blocker_pattern_data();
```

- `blocker_generation_enabled` is the master switch.
- `blocker_spawn_timer` delays the first row.
- `blocker_spawn_buffer` starts obstacles completely above the room.
- Row spacing moves from approximately 520 pixels early in the game to 410
  pixels at maximum difficulty.
- `blocker_patterns` stores the full pattern array.

The controller also tracks the current formation:

```gml
blocker_pattern_row = 0;
blocker_current_pattern_id = -1;
blocker_recent_pattern_ids = [];
blocker_mirror_current_pattern = false;
blocker_reverse_current_pattern = false;
```

## Difficulty progression

Difficulty is based on total world distance:

```gml
var blocker_difficulty = clamp(distance_travelled / 14000, 0, 1);
```

- At distance `0`, difficulty is `0`.
- At distance `7000`, difficulty is `0.5`.
- At distance `14000` or higher, difficulty is `1`.

The value affects pattern tiers, mutation chance, breather chance, and row
spacing.

### Tier probabilities

| Stage | Easy | Medium | Hard |
| --- | ---: | ---: | ---: |
| Early | 68% | 29% | 3% |
| Middle | 38% | 52% | 10% |
| Late | 20% | 55% | 25% |

Easy patterns never disappear completely. This allows occasional recovery
even late in a run.

## Recent-pattern history

When selecting a formation, the generator excludes the five most recently
completed pattern IDs. After a four-row pattern finishes, its ID is appended to
`blocker_recent_pattern_ids`. If the array grows past five entries, the oldest
entry is removed.

This reduces obvious repetition without forcing a predictable order.

## Reversing and mirroring

Each newly selected pattern independently receives:

- A 50% chance to reverse its row order.
- A 50% chance to mirror its lanes horizontally.

Reversing `[1, 2, 4, 8]` produces `[8, 4, 2, 1]` by reading row index
`3 - blocker_pattern_row`.

Mirroring changes masks as follows:

```text
1  <-> 8
2  <-> 4
3  <-> 12
6  stays 6
9  stays 9
0  stays 0
```

Reversing changes the time order. Mirroring changes the horizontal layout.
Both can be active on the same formation.

## Row mutation

Single-lane rows occasionally change to another random single lane:

```gml
blocker_row_mask = choose(1, 2, 4, 8);
```

The chance increases from 14% early in the game to 28% at maximum difficulty.
Two-lane and outer-pair rows do not mutate, preserving their authored routes.

## Breather rows

### Random breathers

A row can be replaced with mask `0`, which spawns nothing. The chance decreases
from 12% early in the game to 4.5% at maximum difficulty.

### Hazard breathers

When `obj_ufo_catcher` or `obj_key_pusher` exists, the next obstacle row is
automatically changed to mask `0`. The pattern still advances normally.

This keeps lock-on telegraphs readable and prevents the player from being
forced through a complex blocker row during a lock-on attack.

## Spawn position calculation

The X coordinate is calculated from lane start and lane span:

```gml
spawn_x = blocker_lane_left
    + (lane_start + lane_span * 0.5)
        * blocker_lane_width;
```

For a one-lane obstacle in lane 3:

```text
124 + (2 + 0.5) * 208 = 644
```

For a two-lane obstacle covering lanes 2-3:

```text
124 + (1 + 1) * 208 = 540
```

The obstacle sprites use centered origins, so the calculated center can be
assigned directly to the instance X position.

The Y coordinate accounts for the centered sprite origin:

```gml
blocker_bottom_from_origin = blocker_height
    - sprite_get_yoffset(blocker_sprite);

spawn_y = -blocker_bottom_from_origin
    - blocker_spawn_buffer;
```

This positions the complete sprite above the room with an additional 64-pixel
buffer. Instances are created on the `Obstacles` layer.

## Advancing a formation

After spawning or skipping a row:

```gml
blocker_pattern_row += 1;
```

When the counter reaches four:

1. The completed pattern ID is added to recent history.
2. History is trimmed to five entries.
3. `blocker_pattern_row` returns to zero.
4. The current pattern ID is cleared.
5. A new pattern is selected when the next row timer expires.

## Distance-based row timing

The next physical row spacing is interpolated between 520 and 410 pixels:

```gml
var blocker_spacing = lerp(
    blocker_row_spacing_max,
    blocker_row_spacing_min,
    blocker_difficulty
);
```

A random variation of plus or minus 8% prevents perfectly mechanical timing.
The spacing is converted to seconds using world speed:

```gml
blocker_spawn_timer = blocker_spacing / world_scroll_speed;
```

Examples before the random variation:

```text
520 px / 120 px per second = 4.33 seconds
410 px / 300 px per second = 1.37 seconds
```

The time between rows becomes shorter as scrolling accelerates, while the
physical distance remains controlled. A minimum timer of 0.65 seconds protects
against unsafe future speed values.

## Complete generation flow

```text
Controller starts
    |
    v
Load 52 patterns
    |
    v
Wait for the row timer
    |
    v
Calculate difficulty from distance
    |
    v
If row 0, select a pattern and choose mirror/reverse
    |
    v
Read the current row mask
    |
    v
Possibly mutate the row
    |
    v
Possibly replace it with a breather
    |
    v
Possibly mirror the mask
    |
    v
Convert the mask into obstacle instances
    |
    v
Advance the row counter
    |
    v
After four rows, remember the completed pattern
    |
    v
Calculate the next timer from distance / world speed
    |
    v
Repeat
```

## Main tuning values

The most useful values to adjust during playtesting are in the controller
Create event:

| Variable | Current value | Effect |
| --- | ---: | --- |
| `blocker_spawn_timer` | `0.85` | Delay before the first row |
| `blocker_spawn_buffer` | `64` | Extra offscreen spawn distance |
| `blocker_row_spacing_min` | `410` | Late-game row spacing |
| `blocker_row_spacing_max` | `520` | Early-game row spacing |
| `blocker_hazard_breathers` | `true` | Empty rows during UFO/Key attacks |

Additional tuning values are in the controller Step event:

| Expression | Current range | Effect |
| --- | ---: | --- |
| `distance_travelled / 14000` | `0-1` | Difficulty-ramp length |
| Mutation chance | `14%-28%` | Single-row variation |
| Breather chance | `12%-4.5%` | Natural empty rows |
| Spacing variation | `92%-108%` | Timing irregularity |
| Minimum timer | `0.65 s` | Maximum row frequency |

## Systems that should remain separate

Do not move the following behavior into the pattern script:

- Obstacle downward movement
- Player pushing
- I-frame obstacle phasing
- Scalper capture handling
- Obstacle depth sorting
- Offscreen obstacle cleanup
- UFO or Key Master attack state machines
- Player protection and lives

The pattern generator is intentionally limited to choosing and placing
obstacles. Keeping these responsibilities separate makes future balancing and
debugging safer.
