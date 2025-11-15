# 012 - Logger Level & Compiler Strip

## Goal  
Strip debug logs in production builds automatically.

## Why  
Debug logging hurts performance.

## Steps  
1. Add log levels to DebugUtils.
2. Add a build script:
   - remove `DebugUtils.debug()` calls for prod builds.

## Performance Notes  
- Zero debug overhead in prod.
- Lower log spam.

## DebugUtils  
- Only warn/error always visible.

## Tests  
- Dev build logs debug.
- Prod build strips debug.
