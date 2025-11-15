# 012 - Optimize Pool Release Logic

## Goal
Move heavy reset logic out of pool.release().

## Why
Pool release is hot path.

## Steps
1. Minimal reset in release.
2. Full reset done when acquired next time.

## Performance
Smoother spikes.

## Tests
- Pooled objects behave correctly.
