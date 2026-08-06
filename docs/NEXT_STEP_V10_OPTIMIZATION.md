# Next step after v10_optimization

After the automated verifier passes:

1. Run a 15-minute profile session on a physical iPhone with 1, 5 and 15 products at 1×/2×/4×.
2. Confirm no lost or duplicated game time after foreground jank, lock/unlock and route transitions.
3. Cross zero cash, force-close immediately, relaunch and confirm the emergency snapshot.
4. Switch RU/EN on every main and nested screen. RU must contain no accidental English except approved abbreviations/glossary terms; EN must contain no Cyrillic.
5. Verify product creation, contracts, investors, credit, HR auto-hire, parallel assignments, improvements, infrastructure migration and rollback saves.
6. Run the same smoke flow on Android and confirm native diagnostics reports `kotlin_atomic_file`.
7. Review `git diff`, simulator/device logs and profile timeline before commit.

Do not mark the iteration verified from compilation alone.
