# FOUNDER.OS v10_optimization

Base commit: `4abab48d469cb7199cc21f827504b4d9cba7656b`.

## Goal

Reduce CPU work, UI rebuild scope, snapshot-write pressure and platform I/O latency without removing systems, changing balance, changing seeded RNG, or duplicating simulation rules between platforms.

## Native boundary

Swift and Kotlin implement one optional MethodChannel contract:

- atomic snapshot load/save/clear;
- monotonic-clock diagnostics;
- native backend diagnostics.

`GameEngine`, RNG, economy, contracts, investors, products and migrations remain deterministic Dart. Tests and unsupported platforms automatically use the Dart/SharedPreferences fallback.

## Dart hot-path changes

- Drift-aware active-session ticker batches missed whole seconds instead of stacking timer callbacks.
- Save requests are latest-only and coalesced; large snapshot encoding moves to a background isolate, while an emergency negative-balance save remains immediate.
- Product projections use a bounded deterministic LRU cache.
- Immutable `GameState` uses GC-safe `Expando` indexes for repeated ID/group lookups.
- Product simulation calculates working hours once per batch.
- Dashboard and product workspace rebuild only the state-dependent fragments; retained hidden tabs detach from tick listeners without losing state.
- Global status controls no longer use a full-screen backdrop blur.
- Chart painters compare values instead of list identity.

## Localization

- All presentation `Text`/`RichText` paths are routed through `AppText`.
- Russian mode normalizes accidental implementation English while preserving product/company proper names, approved abbreviations and glossary terminology.
- English mode translates known interface copy and guarantees that fallback copy contains no Cyrillic.
- Input hints, tooltips, navigation labels and semantics labels are localized.
- The audit prevents new direct `Text` calls from bypassing the localization layer.

## Compatibility

- Snapshot schema remains v10; no RNG migration is introduced.
- Existing v8-v10 SharedPreferences saves are migrated into native atomic storage when available.
- Bundle ID, signing, deployment targets and Gradle configuration are unchanged.
- No third-party dependency is added.

## Verification

Run:

```bash
bash tools/verify_v10_optimization.sh
```

The gate runs localization/native audits, formatter, analyzer, focused tests, all tests, iOS simulator build and Android debug build. Physical iPhone and Android smoke tests remain mandatory before marking the iteration verified.
