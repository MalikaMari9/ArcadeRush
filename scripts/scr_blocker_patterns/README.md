# Continuous Blocker Route System

ArcadeRush generates independent obstacle rows from world distance. The old
four-row authored pattern cycle has been replaced by a continuous route that
always reserves enough horizontal space for the widest player collision mask.

## Responsibilities

- `obj_controller/Create_0.gml` contains the speed, spacing, and encounter
  tuning values.
- `obj_controller/Step_0.gml` advances the distance accumulator and requests
  each new row.
- `scr_blocker_patterns.gml` measures collision geometry, selects a safe row,
  moves the reserved route, and creates the blocker instances.
- `par_scrolling_blocker` continues to own movement, player pushing, depth,
  invulnerability phasing, and cleanup.

## Lanes and masks

The playable corridor contains four lanes. Bits `1`, `2`, `4`, and `8`
represent the lanes from left to right.

| Mask | Occupied lanes |
| ---: | --- |
| `1`, `2`, `4`, `8` | One lane |
| `3`, `6`, `12` | One two-lane blocker |
| `9` | Both outer lanes |
| `7`, `11`, `13`, `14` | Three lanes, leaving one routed escape |

One-lane placements randomly choose `obj_blocker1` or `obj_blocker2`.
Two-lane placements use `obj_blocker3`.

## Physical route validation

The route does not assume that an apparently empty lane is passable. It uses
the actual sprite bounding boxes for:

- `spr_obstacle_1`, conservatively representing the widest one-lane blocker
- `spr_obstacle_3`, representing the two-lane blocker
- all three back-facing player protection states

`scr_blocker_lane_is_safe()` places the widest player mask at a lane centre,
adds five pixels of clearance on each side, and rejects any overlap with the
row's calculated blocker rectangles.

The controller remembers `blocker_safe_lane`. Each new mask must keep that
lane open. After the row is selected, the reservation has a 42% opportunity
to move one lane left or right, but only when both the old and new lanes are
physically open in the current row. This keeps consecutive rows connected.

## Difficulty

Difficulty rises with distance until `18000` world pixels. Early runs favour
one-blocker rows; later runs give more weight to two- and three-lane rows.
Repeating the exact previous mask receives only 18% of its normal weight.

While UFO Catcher or Key Pusher is active, the same generator continues but
rejects every candidate containing more than one blocker. This avoids both
complex overlap and the large empty zone produced by pausing the old system.

## Spacing and speed

The current controller values are:

| Setting | Value |
| --- | ---: |
| Starting world speed | `250 px/s` |
| World acceleration | `5 px/s²` |
| Maximum world speed | `350 px/s` |
| First-row distance | `250 px` |
| Row spacing | `625-700 px` |

The tallest blocker is 253 pixels and the largest player collision box is 248
pixels. A 625-pixel row interval leaves 124 pixels beyond their combined
height, preventing visually open but physically impossible vertical gaps.

The distance accumulator preserves fractional carry after spawning, so frame
rate changes do not alter the long-term obstacle density.

## Lock-on scheduling

UFO Catcher and Key Pusher preferentially alternate. The first encounter is
due after 3.5 seconds and later encounters are due 7-9 seconds after launch.
They never overlap one another. An active coin or duck can postpone a due
encounter for at most two seconds, and unsafe UFO attempts become Key Pusher
encounters instead.

Manual controls remain:

- `U`: UFO Catcher
- `K`: Key Pusher
- `C`: coin tower
- `H`: walking duck
- `M`: Ticket Magnet
- `B`: Double Ticket
- `G`: Shield

## Playtest checklist

- Cross between adjacent safe lanes over several consecutive rows.
- Watch blocker density at both 250 and 350 px/s.
- Confirm rows remain simple during UFO and Key Pusher attacks.
- Confirm UFO/Key alternation still feels varied when unsafe UFOs are replaced.
- Test the two-second coin/duck overlap rule for fairness.
