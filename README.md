# Emoji Realism — Multimodal (fNIRS · Eye-tracking · PCE) Analysis Code

Reproducible analysis code for:

> **A Conditional Dissociation in Emoji Communication: Neurophysiological and Behavioral Evidence**
> Jaechang Cha, Sanga Yeo, Chunghun Ha, Seongdae Kim.
> *International Journal of Human–Computer Interaction* (under revision, MS ID 265473093).

This repository contains the complete, self-contained analysis pipeline that
reproduces every statistic reported in the manuscript and its revision, using a
fully-crossed **5 (emotion) × 4 (emoji type)** within-subjects design (**N = 20**,
harmonized across all three modalities).

## What this code does

| Script | Produces |
|---|---|
| `R/00_config.R` | Central path / factor-level configuration (edit paths here) |
| `R/01_load_data.R` | Loads & harmonizes survey (PCE), eye-tracking, and fNIRS data |
| `R/02_primary_analyses.R` | 8-ROI fNIRS, 5-metric eye-tracking, 5-item PCE two-way LMMs; FDR; post-hoc |
| `R/03_robustness_sensitivity.R` | Image-only AOI robustness; trial-order covariate; early/late-trial exclusion |
| `R/04_bayesian_crossmodal.R` | Bayesian fNIRS×behaviour correlations — exploratory (pooled) **and** confirmatory (participant-aggregated) |
| `python/05_image_properties.py` | Low-level stimulus feature descriptives (luminance, RMS contrast, colorfulness, edge/complexity) + AOI-area ratio |
| `run_all.R` | Runs the full R pipeline end-to-end |

All console output and CSV tables are written to `results/`.

## Reproducing the analysis

```bash
# 1. R pipeline (fNIRS / eye-tracking / PCE / robustness / Bayesian)
Rscript run_all.R

# 2. Stimulus low-level feature descriptives
python3 python/05_image_properties.py
```

### Requirements
- **R ≥ 4.3** with `readxl`, `tidyverse`, `lme4`, `lmerTest`, `emmeans`, `BayesFactor`
- **Python ≥ 3.9** with `numpy`, `pandas`, `Pillow`

```r
install.packages(c("readxl","tidyverse","lme4","lmerTest","emmeans","BayesFactor"))
```

## Data availability

The raw data (fNIRS recordings, eye-tracking exports, questionnaire responses,
and facial-image stimuli) are **not redistributed here** because they contain
identifiable human-participant information and licensed photographic face stimuli,
under the governing IRB approval (Hongik University IRB 7002340-202412-HR-037).
The repository ships the full analysis code and a complete
[`data/DATA_DICTIONARY.md`](data/DATA_DICTIONARY.md) describing every input file and
variable, so the pipeline can be re-run by placing appropriately-formatted files at
the paths defined in `R/00_config.R`. De-identified data may be made available from
the corresponding author on reasonable request and with IRB approval.

## Analysis design notes (revision)

- **Sample:** N = 20, identical participants across fNIRS, eye-tracking, and survey
  (intention-to-treat; all completers retained).
- **Models:** two-way (Emotion × Emoji-type) linear mixed models with a
  by-participant random intercept, `DV ~ Emotion * Type + (1 | SubjectID)`.
- **Multiple comparisons:** Benjamini–Hochberg FDR within each measurement family
  (8 fNIRS ROIs; 5 eye-tracking metrics; 5 PCE items); Bonferroni / FDR for
  post-hoc contrasts; Bayesian cross-modal correlations reported separately
  (exploratory pooled and confirmatory participant-aggregated).
- **Robustness:** image-only AOI re-analysis, trial-order covariate, and
  early/late-trial exclusion are provided to probe stimulus-confound and
  order/fatigue explanations.

## License
Code released under the MIT License (see `LICENSE`).

## Citation
See `CITATION.cff`. Archived release: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21188828.svg)](https://doi.org/10.5281/zenodo.21188828)
