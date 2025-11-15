# 014 - Optimize Camera Lerp

## Goal
Reduce camera vector ops.

## Why
Camera updates every frame.

## Steps
1. Skip lerp when hero velocity small.
2. Precompute target positions.

## Performance
Minor but global cost reduction.

## Tests
- Camera remains smooth.
