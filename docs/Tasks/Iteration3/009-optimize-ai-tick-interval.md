# 009 - Optimize AI Tick Interval

## Goal
Reduce AI frequency for non-boss actors.

## Why
AI runs expensive vector math.

## Steps
1. Add tick_interval (e.g. 0.1s).
2. Update only when timer expires.

## Performance
Up to 60% CPU reduction in large waves.

## Tests
- AI still responsive.
