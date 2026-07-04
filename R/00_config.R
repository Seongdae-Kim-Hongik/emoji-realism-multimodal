# ============================================================================
# 00_config.R — central configuration (edit the paths to your local data)
# ============================================================================
# Input files (place your appropriately-formatted data at these paths; see
# data/DATA_DICTIONARY.md for the expected schema of each file).
PATHS <- list(
  survey = "data/survey_PCE.xlsx",                 # questionnaire (PCE), wide format
  eyetrack = "data/eyetracking_metrics.tsv",       # Tobii Pro Lab AOI metrics export (TSV)
  fnirs  = "data/fnirs_group_features_by_Brodmann.xlsx", # NIRSIT group HbO by ROI
  stimuli = "data/stimuli"                          # emoji/face stimulus PNGs
)
OUTDIR <- "results"; dir.create(OUTDIR, showWarnings = FALSE, recursive = TRUE)

# Factor levels (fixed across all scripts)
EMO_LEVELS  <- c("Joy", "Anger", "Sadness", "Disgust", "Fear")
TYPE_LEVELS <- c("Realistic", "GraphicCon", "AniCon", "RealCon")

# Korean -> English mappings used by the raw exports
TYPE_MAP <- c("애니콘"="AniCon", "그래픽콘"="GraphicCon", "실사콘"="RealCon", "실사"="Realistic")
EMO_MAP  <- c("분노"="Anger", "슬픔"="Sadness", "혐오"="Disgust", "기쁨"="Joy", "공포"="Fear")

ROI_VARS <- c("Left DLPFC","Right DLPFC","Left FPC","Right FPC",
              "Left VLPFC","Right VLPFC","Left OFC","Right OFC")
ET_METRICS <- c("Average_pupil_diameter","Total_duration_of_fixations","Number_of_fixations",
                "Number_of_saccades_in_AOI","Time_to_first_whole_fixation")
ET_LABELS  <- c("Avg pupil diameter (mm)","Total fixation duration (ms)","Number of fixations",
                "Number of saccades in AOI","Time to first whole fixation (ms)")
PCE_METRICS <- c("Q1","Q2","Q3","Q4","Q_mean")

set.seed(2024)
suppressPackageStartupMessages({
  library(readxl); library(tidyverse); library(lme4); library(lmerTest)
  library(emmeans); library(BayesFactor)
})
options(dplyr.summarise.inform = FALSE)
emmeans::emm_options(lmerTest.limit = 20000, pbkrtest.limit = 20000)
