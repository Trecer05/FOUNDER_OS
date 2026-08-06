# FOUNDER.OS v10 — UAT rework

Base commit: `14d8d89ee30d3805acdd3acec7834c9fe5e11fee`.

## Implemented

1. Language limits now use a dedicated resolver and show product, framework, required-language, and final-limit reasons before confirmation.
2. Stack coherence is explained in product creation and the product workspace.
3. Product catalog cards use stable, higher-contrast category/stage accents and display the blueprint name instead of the broad enum category.
4. Project workspace supports direct candidate hiring with project-relevant sorting/filtering.
5. Development capacity is explained as effective team FTE and separated from infrastructure compute.
6. Product workspace is split into Overview, Development, Team, Marketing, Metrics, and Infrastructure; metrics support 7/30/90/all ranges.
7. Two Edge S1 servers are prepared at a new start and migrated v9 saves, while rented hosting remains the only active compute source until owned migration.
8. A fully remote company pays no office rent; server-room rent remains zero until owned infrastructure is active.
9. Crossing from non-negative to negative cash triggers an emergency snapshot save.
10. Investor requests enter a deterministic 1–14 day negotiation with visible status, progress, explicit offer, or explicit rejection.
11. Business credit is always discoverable in Finance; approval is based on products/contracts, burn, and security risk.
12. Product improvements queue working hours and have no direct purchase price; payroll and infrastructure continue during work.
13. Employees can participate in several products. Their product allocation is normalized across assignments; parallel work raises workload and can lower morale. Vacation and wellbeing bonus actions restore them.
14. Assigning an employee to another product adds an assignment instead of silently removing the previous one.
15. HR / People Partner unlocks automatic project team hiring. Automatic hires receive 25% higher salary and signing bonus.
16. Cash and time remain visible in the global bar. Time text has explicit normal color and no underline decoration.
17. Product-facing UI uses the blueprint name so a company website is not labelled SaaS.
18. Product compute demand is displayed with its user-growth formula and covered by a regression test.
19. Hosting prices are recalibrated against 2026 public cloud price bands. RUB/USD/EUR display uses fixed offline Bank of Russia rates effective 2026-08-06. Contract grace periods and partial late payouts are implemented. High-frequency UI areas use grouped screens, short transitions, and chart repaint isolation.

## Verification status

Implementation is packaged but is not considered verified until `tools/verify_ux_economy_v10.sh` passes locally and the physical-iPhone scenario is completed.

## Deliberate limits

- English support is partial in v10: display preferences, currency formatting, locale selection, and new preference copy are present, while the full historic Russian copy still needs extraction into a complete localization catalog.
- Pricing calibration in this iteration focuses on hosting/cloud economics. A future pass should benchmark every salary, office, hardware, agency, contract, and acquisition entry by region and difficulty preset.
- Swift/Kotlin native code was not introduced. Profiling points to screen structure and rebuild scope rather than a platform-channel bottleneck; native code would add risk without solving the current cause.
