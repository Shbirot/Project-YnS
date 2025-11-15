# 001 - Cache Animation Lookup

## Goal
Avoid rebuilding animation names + checking sprite_frames every frame.

## Why
String building + has_animation() calls are expensive.

## Steps
1. Build direction->animation map in _ready().
2. Reuse cached animation strings.

## Performance
Removes 80–120 string ops per second per entity.

## Tests
- All animations transition correctly.
