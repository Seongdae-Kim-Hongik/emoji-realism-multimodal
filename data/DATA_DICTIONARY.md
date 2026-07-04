# Data dictionary

Raw data are **not redistributed** (identifiable human-participant data and
licensed photographic stimuli, under Hongik University IRB 7002340-202412-HR-037).
This file documents the schema each script expects so the pipeline can be re-run
by placing appropriately-formatted files at the paths in `R/00_config.R`.

Design: fully-crossed **5 emotion × 4 emoji-type** within-subjects, **N = 20**
participants (identical across all three modalities).
- Emotions: Joy, Anger, Sadness, Disgust, Fear.
- Emoji types: Realistic (photographic face), Real-con (high-realism illustrated
  character), Ani-con (animated cartoon character), Graphic-con (yellow graphic emoji).

## 1. `survey_PCE.xlsx` — questionnaire (Perceived Communication Effectiveness)
One row per participant (wide). Contains an anonymized `ID` column (e.g. `b_sjy2`)
used to merge with the other modalities, plus 80 response columns named
`<type_kr>_<emotion_kr><code>_<q>` where `<q>` ∈ {1,2,3,4}:
- q1 communication clarity, q2 comprehension speed, q3 efficiency, q4 emotional expressiveness.
- Rated 1–7. `<type_kr>` ∈ {실사, 그래픽콘, 애니콘, 실사콘}; `<emotion_kr>` ∈ {기쁨, 분노, 슬픔, 혐오, 공포}.

## 2. `eyetracking_metrics.tsv` — Tobii Pro Lab AOI-metrics export (tab-separated)
One row per Participant × Media × AOI. Key columns used:
- `Participant` (anonymized ID), `Emotion`, `Type`, `AOI`
  (`AOI_BIG` = image+label primary AOI; `AOI_SAMLL` = image-only AOI), `AOI_size`,
  `Start_of_interval` (used to derive trial order).
- Metrics: `Average_pupil_diameter`, `Total_duration_of_fixations`,
  `Number_of_fixations`, `Number_of_saccades_in_AOI`, `Time_to_first_whole_fixation`,
  `Average_eye_openness`, `Average_duration_of_fixations`.

## 3. `fnirs_group_features_by_Brodmann.xlsx` — NIRSIT group HbO by ROI
One row per Subject × Emotion × Type (`Group`). ROI HbO-change columns (mm·mM,
19-s stimulus window vs preceding rest, GLM, outlier-removed):
`Left DLPFC, Right DLPFC, Left FPC, Right FPC, Left VLPFC, Right VLPFC, Left OFC, Right OFC`.
Merge keys: `Subject Name` (ID), `Emotion`, `Group` (emoji type).

## 4. `stimuli/` — stimulus PNGs
20 images (5 emotions × 4 types). Filenames encode `<type_kr>_<emotion_kr>`.
Used only by `python/05_image_properties.py` for low-level feature descriptives.
