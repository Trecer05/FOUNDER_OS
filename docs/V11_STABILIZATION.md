# FOUNDER.OS v11 stabilization

Base: `af971bead2fa05e9459d92d0192c365d13c37fdb`.

## Physical-device defects addressed

- Office cards always show listed rent and separately explain remote-first zero actual charge.
- Narrow infrastructure rows and advertising dropdowns cannot overflow on iPhone width.
- New games start without purchased physical servers. The exact legacy v10 automatic `2 × Edge S1` pair is removed only while rented hosting is active; owned infrastructure is preserved.
- HR / People Partner is visible as its own hiring path. Project auto-hire remains reducer-gated until an HR employee exists.
- Hosting capacity uses `CU` and explains the approximate active-user capacity.
- Frontend, Backend, HR, Compute, CU, U, kW, Gbps, provider names and promo codes remain technical English where appropriate.
- RU localization translates authored UI phrases only and never invents pseudo-Cyrillic words.
- Profit cards toggle between month and day.
- Finance breakdown uses clear Russian categories instead of `Payroll`.

## Compatibility

Snapshot schema is 11. Native snapshot filenames and channel names remain stable so v10 native saves can be decoded and migrated. GameEngine/RNG remain deterministic Dart. No dependency, Bundle ID, signing, deployment target or build configuration changes are introduced.

## Verification

Run `bash tools/verify_v11_stabilization.sh`. Automated verification is not a replacement for a second physical-iPhone UAT of the exact reported screens.
