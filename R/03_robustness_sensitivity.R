# ============================================================================
# 03_robustness_sensitivity.R  (reviewer-requested checks)
#   (a) image-only AOI robustness   (b) trial-order covariate
#   (c) early/late-trial exclusion  — note: presentation order was fixed
# ============================================================================

# (a) Re-run the 5 ET omnibus tests on the image-only AOI
robustness_image_only <- function(df_et_small) {
  t <- map_dfr(seq_along(ET_METRICS), function(i) {
    a <- lmm_omnibus(df_et_small, ET_METRICS[i])$anova
    tibble(Metric=ET_LABELS[i], p_type=.p(a,"Type"), peta_type=.pe(a,"Type"),
           p_int=.p(a,"Emotion:Type"), peta_int=.pe(a,"Emotion:Type"))
  }) %>% mutate(pFDR_type=p.adjust(p_type,"BH"), pFDR_int=p.adjust(p_int,"BH"))
  write.csv(t, file.path(OUTDIR,"et_omnibus_imageonly_AOI.csv"), row.names=FALSE)
  t
}

# (b)+(c) trial-order covariate & early/late exclusion (trial order from Start_of_interval)
sensitivity_order <- function(df_et_big) {
  etb <- df_et_big %>% group_by(SubjectID) %>%
    mutate(trial_order = rank(Start_of_interval, ties.method="first"),
           trial_z = as.numeric(scale(trial_order))) %>% ungroup()
  t <- map_dfr(seq_along(ET_METRICS), function(i) {
    dv <- ET_METRICS[i]; d <- etb; d$DV <- as.numeric(d[[dv]]); d <- d[is.finite(d$DV), ]
    base <- suppressMessages(lmer(DV ~ Emotion*Type + (1|SubjectID), data=d))
    ord  <- suppressMessages(lmer(DV ~ Emotion*Type + trial_z + (1|SubjectID), data=d))
    mid  <- d %>% group_by(SubjectID) %>%
      filter(trial_order > 5, trial_order <= max(trial_order)-5) %>% ungroup()
    mm   <- suppressMessages(lmer(DV ~ Emotion*Type + (1|SubjectID), data=mid))
    tibble(Metric=ET_LABELS[i],
           p_type_base = anova(base)["Type","Pr(>F)"],
           p_type_orderadj = anova(ord)["Type","Pr(>F)"],
           p_trialorder = anova(ord)["trial_z","Pr(>F)"],
           p_type_trimmed = anova(mm)["Type","Pr(>F)"])
  })
  write.csv(t, file.path(OUTDIR,"et_sensitivity_order.csv"), row.names=FALSE)
  t
}
