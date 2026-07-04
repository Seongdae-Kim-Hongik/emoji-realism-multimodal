# ============================================================================
# run_all.R — end-to-end R pipeline
#   Rscript run_all.R    (edit paths in R/00_config.R first)
# ============================================================================
source("R/00_config.R")
source("R/01_load_data.R")
source("R/02_primary_analyses.R")
source("R/03_robustness_sensitivity.R")
source("R/04_bayesian_crossmodal.R")

message("== Loading data (N = 20) ==")
df_sv       <- load_survey()
df_et_big   <- load_eyetracking("AOI_BIG")
df_et_small <- load_eyetracking("AOI_SAMLL")
df_fn       <- load_fnirs()

message("== Primary analyses (fNIRS / eye-tracking / PCE) ==")
primary <- run_primary(df_sv, df_et_big, df_fn)

message("== Robustness & sensitivity ==")
robustness_image_only(df_et_small)
sensitivity_order(df_et_big)

message("== Bayesian cross-modal (exploratory + confirmatory) ==")
bayes <- bayes_crossmodal()

message("== DONE. Tables written to results/ ==")
