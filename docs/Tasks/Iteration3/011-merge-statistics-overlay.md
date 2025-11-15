# 011 - Merge Statistics Overlay

## Goal
Combine UI overlays into one node.

## Why
Multiple labels = more draw calls.

## Steps
1. Create PerformanceOverlay.gd.
2. Update text once per 0.25s instead of per-frame.

## Performance
Reduced UI cost.

## Tests
- Overlay shows correct stats.
