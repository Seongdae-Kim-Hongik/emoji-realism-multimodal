# ============================================================================
# 02_primary_analyses.R — fNIRS (8 ROI), eye-tracking (5 metrics), PCE (5 items)
#   two-way Emotion×Type LMMs, FDR across each family, post-hoc contrasts
# ============================================================================

# two-way LMM omnibus + partial eta^2
lmm_omnibus <- function(data, dv) {
  d <- data; d$DV <- as.numeric(d[[dv]]); d <- d[is.finite(d$DV), ]
  m <- suppressMessages(lmer(DV ~ Emotion*Type + (1|SubjectID), data = d))
  a <- as.data.frame(anova(m)); a$term <- rownames(a)
  a$petasq <- (a$`F value`*a$NumDF)/(a$`F value`*a$NumDF + a$DenDF)
  list(model = m, anova = a)
}
.p  <- function(a, t) a$`Pr(>F)`[a$term == t]
.pe <- function(a, t) round(a$petasq[a$term == t], 3)

run_primary <- function(df_sv, df_et_big, df_fn) {
  # ---- fNIRS ----
  fn_tab <- map_dfr(ROI_VARS, function(r) {
    a <- lmm_omnibus(df_fn, r)$anova
    tibble(ROI=r, F_emo=a$`F value`[a$term=="Emotion"], p_emo=.p(a,"Emotion"), peta_emo=.pe(a,"Emotion"),
           p_type=.p(a,"Type"), p_int=.p(a,"Emotion:Type"))
  }) %>% mutate(pFDR_emo=p.adjust(p_emo,"BH"), pFDR_type=p.adjust(p_type,"BH"), pFDR_int=p.adjust(p_int,"BH"))
  write.csv(fn_tab, file.path(OUTDIR,"fnirs_omnibus.csv"), row.names=FALSE)
  sig_roi <- fn_tab$ROI[fn_tab$pFDR_emo < .05]
  fn_ph <- map_dfr(sig_roi, function(r)
    as.data.frame(pairs(emmeans(lmm_omnibus(df_fn,r)$model, ~Emotion), adjust="bonferroni")) %>% mutate(ROI=r))
  write.csv(fn_ph, file.path(OUTDIR,"fnirs_emotion_posthoc.csv"), row.names=FALSE)

  # ---- Eye-tracking (primary AOI) ----
  et_tab <- map_dfr(seq_along(ET_METRICS), function(i) {
    a <- lmm_omnibus(df_et_big, ET_METRICS[i])$anova
    tibble(Metric=ET_LABELS[i], p_emo=.p(a,"Emotion"), peta_emo=.pe(a,"Emotion"),
           p_type=.p(a,"Type"), peta_type=.pe(a,"Type"), p_int=.p(a,"Emotion:Type"), peta_int=.pe(a,"Emotion:Type"))
  }) %>% mutate(pFDR_emo=p.adjust(p_emo,"BH"), pFDR_type=p.adjust(p_type,"BH"), pFDR_int=p.adjust(p_int,"BH"))
  write.csv(et_tab, file.path(OUTDIR,"et_omnibus_primary.csv"), row.names=FALSE)
  # pupil Type|Emotion pairwise (FDR)
  mp <- lmm_omnibus(df_et_big,"Average_pupil_diameter")$model
  write.csv(as.data.frame(pairs(emmeans(mp,~Type|Emotion), adjust="fdr")),
            file.path(OUTDIR,"et_pupil_type_by_emotion.csv"), row.names=FALSE)

  # ---- PCE ----
  pce_tab <- map_dfr(PCE_METRICS, function(q) {
    a <- lmm_omnibus(df_sv,q)$anova
    tibble(Metric=q, p_emo=.p(a,"Emotion"), p_type=.p(a,"Type"), p_int=.p(a,"Emotion:Type"), peta_int=.pe(a,"Emotion:Type"))
  }) %>% mutate(pFDR_emo=p.adjust(p_emo,"BH"), pFDR_type=p.adjust(p_type,"BH"), pFDR_int=p.adjust(p_int,"BH"))
  write.csv(pce_tab, file.path(OUTDIR,"pce_omnibus.csv"), row.names=FALSE)
  mc <- lmm_omnibus(df_sv,"Q_mean")$model
  write.csv(as.data.frame(pairs(emmeans(mc,~Type), adjust="fdr")), file.path(OUTDIR,"pce_type_posthoc.csv"), row.names=FALSE)
  write.csv(as.data.frame(pairs(emmeans(mc,~Type|Emotion), adjust="fdr")), file.path(OUTDIR,"pce_type_by_emotion.csv"), row.names=FALSE)

  message("Primary analyses done. Significant-emotion fNIRS ROIs: ", paste(sig_roi, collapse=", "))
  list(fnirs=fn_tab, fnirs_posthoc=fn_ph, eyetracking=et_tab, pce=pce_tab)
}
