# Revision analysis — key numbers (single source of truth)

**Sample:** N = 20, identical participants across fNIRS / eye-tracking / survey (survey 400 condition-rows = 20×20; ET AOI_BIG 800 rows = 20×20×2 presentations; fNIRS 400 = 20×20). Manuscript's original figures reproduce on this N=20 set → "22" was a clerical error; true analyzed N = 20 (all completers retained, ITT).

## fNIRS (reproduces manuscript; keep reported values, only correct N)
- Significant Emotion main effect (pFDR<.05) in 5 ROIs: **Left DLPFC, Left FPC, Right FPC, Left OFC, Right OFC** (identical set to submission).
- Emoji type & interaction: all n.s. (pFDR type ≈ .967, interaction ≈ .982). Null, not invariance.
- Emotion marginal HbO (avg over sig ROIs): Anger 0.012 (highest) > Fear −0.020 > Sadness −0.061 > Joy −0.081 > Disgust −0.105 (lowest). Matches "anger/fear highest, disgust/joy lowest."
- η²p (Emotion) 0.05–0.08 across sig ROIs.

## Eye-tracking (AOI_BIG primary) — reproduces manuscript
- Pupil: emotion p=5e-64 (η²p .33), type p=5e-166 (η²p .64), interaction p=6e-40 (η²p .25).
- Type means pupil: Realistic 3.83 ≈ Real-con 3.84 > Ani-con 3.56 > Graphic-con 3.27.
- Time to first whole fixation by type: Realistic 502 / Real-con 478 / Ani-con 631 / **Graphic-con 1055 ms** (reversal preserved).
- Total fixation dur, #fixations, #saccades, TTFF: all type p<.001.

### Image-only AOI robustness (AOI_SMALL) — NEW, R2.2
- Image-only AOI = 87.4% of primary AOI area (label+margin ≈ 12.6%).
- Re-running all 5 ET metrics on image-only AOI: **type effects essentially unchanged** (pupil type η²p .644 vs .635; p=5.6e-170; every metric keeps same significance & direction). Findings not driven by the label region.

### Image low-level feature descriptives — NEW, R2.2 (n=3 images/type available: joy, anger, fear)
| Type | Luminance | RMS contrast | Colorfulness | Edge density |
|---|---|---|---|---|
| Realistic | 148±1 | 94±1 | 48±0 | 2.01±.09 |
| Real-con | 169±16 | 90±13 | 36±8 | 2.24±.60 |
| Ani-con | 227±3 | 51±2 | 41±4 | 0.99±.23 |
| Graphic-con | 240±3 | 40±6 | 68±9 | 0.76±.09 |
- One-way ANOVA across types: Luminance F(3,8)=80.8; Contrast F(3,8)=42.0; Colorfulness F(3,8)=14.4; Edge/complexity F(3,8)=15.1 — **all p<.05**. Emoji type is confounded with luminance/contrast/complexity; pupil & oculomotor differences cannot be cleanly attributed to "realism" per se.

### Sensitivity: trial-order & early/late (NEW, R2.3)
- Trial order derived from Start_of_interval rank within participant.
- After adding trial-order covariate: **all type main effects remain highly significant** (pupil p=1e-133; total-dur p=2e-22; #fix p=4e-37; #sacc p=7e-37; TTFF p=6e-9). Trial order itself significant for several metrics (fatigue/habituation present) but does not remove type effects.
- Early/late (first & last 5 trials) exclusion: because presentation order was FIXED & identical across participants, trimming removes whole conditions → type main effects still hold (pupil p=4e-133) but interaction becomes unreliable/uninterpretable (missing cells). Reported honestly as a limitation of the fixed-order design (supports reviewer's order-confound point).

## PCE / survey — reproduces manuscript EXACTLY
- Emotion (composite): Joy 5.68 ≈ Anger 5.44 ≈ Sadness 5.33 > Disgust 4.55 > Fear 3.77.
- Type (composite): Realistic 4.31 < Real-con 4.90 < Graphic-con 5.30 ≈ Ani-con 5.32. (ani-con–graphic-con p=.904; graphic-con–real-con p=.018; real-con–realistic p<.001.)
- Interaction sig all items (η²p .12–.19). **Fear: all type contrasts n.s. (p=.813)** → null within this stimulus set (NOT "irrelevant").

## Bayesian cross-modal — re-analyzed 3 ways (NEW, R2.3)
Effective-N inflation demonstrated & corrected:
| Approach | N/emotion | Sadness R-FPC×eye-openness | # BF10>3 | # BF10>10 |
|---|---|---|---|---|
| Submission (raw pooled, 2/condition) | ~128 | r=−.441, BF10=3.2×10⁵ | — | — |
| V1 exploratory (condition-mean pooled) | ~64–72 | r=−.424, BF10=234 | 47 | 20 |
| **V2 confirmatory (participant-aggregated)** | 18–20 | r=−.497, **BF10=10.9** | 9 | 1 |
- **Direction robust across all three** (all fNIRS–ET couplings negative; 8/9 of V2 BF10>3 negative). Magnitude of *evidence* shrinks sharply once pseudo-replication removed → original "extreme" BFs were inflated by non-independence.
- V2 top pairs: Sadness R-FPC×eye-openness BF10=10.9; Sadness L-FPC×eye-openness 6.4; Sadness R-FPC×total-fix 5.9; Anger R-FPC×pupil 4.7; Joy R-VLPFC×pupil 4.2; Disgust L-VLPFC×total-fix 4.0.
- Plan: report V2 as primary/confirmatory in main text (softened), keep V1 pooled in supplement labeled exploratory & non-independent.

## Multiple-comparison strategy (to state explicitly, R2.3)
Families & corrections: (1) 8 fNIRS ROI omnibus → BH-FDR; (2) 5 ET metric omnibus → BH-FDR; (3) 5 PCE omnibus → BH-FDR; (4) post-hoc within each sig omnibus → Bonferroni (fNIRS emotion) / BH-FDR (Type|Emotion); (5) Bayesian cross-modal → NOT NHST-corrected, reported as exploratory Bayes factors (and now confirmatory participant-aggregated version).
