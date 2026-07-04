# ============================================================================
# 04_bayesian_crossmodal.R — Bayesian fNIRS × behaviour correlations
#   V1 EXPLORATORY : pooled within emotion across emoji types (non-independent)
#   V2 CONFIRMATORY: participant-aggregated condition means (independent)
# Merges the three modalities by the anonymized participant ID column.
# ============================================================================

bayes_crossmodal <- function(path_survey = PATHS$survey,
                             path_et = PATHS$eyetrack, path_fnirs = PATHS$fnirs) {
  roi <- ROI_VARS
  et_vars <- c("Average_pupil_diameter","Total_duration_of_fixations","Number_of_fixations",
               "Average_eye_openness","Average_duration_of_fixations")
  sv_vars <- c("Q1","Q2","Q3","Q4","Q_mean"); outc <- c(sv_vars, et_vars)

  df_fnirs <- read_excel(path_fnirs) %>%
    rename(ID=`Subject Name`, Type=Group) %>%
    mutate(Emotion=tolower(Emotion), ID=tolower(trimws(ID)),
      Type=recode(Type, AniCon="ani-con", GraphicCon="graphic-con",
                  RealCon="real-con", Realistic="realistic")) %>%
    select(ID, Type, Emotion, all_of(roi))

  raw <- read_excel(path_survey)
  q_cols <- colnames(raw)[grepl("_[1-4]$", colnames(raw))]
  # merge via anonymized ID column present in the survey export
  stopifnot("ID" %in% colnames(raw))
  tmap <- c("애니콘"="ani-con","그래픽콘"="graphic-con","실사콘"="real-con","실사"="realistic")
  emap <- c("분노"="anger","슬픔"="sadness","혐오"="disgust","기쁨"="joy","공포"="fear")
  df_sv <- raw %>% mutate(ID=tolower(trimws(ID))) %>% select(ID, all_of(q_cols)) %>%
    pivot_longer(all_of(q_cols), names_to="cn", values_to="Score") %>%
    mutate(Score=as.numeric(Score), Type_kr=str_extract(cn,"^[^_]+"),
      Emo_kr=case_when(str_detect(cn,"분노")~"분노",str_detect(cn,"슬픔")~"슬픔",str_detect(cn,"혐오")~"혐오",
                       str_detect(cn,"기쁨")~"기쁨",str_detect(cn,"공포")~"공포"),
      Qn=as.numeric(str_extract(cn,"\\d+$")), Type=tmap[Type_kr], Emotion=emap[Emo_kr], Ql=paste0("Q",Qn)) %>%
    filter(!is.na(Type),!is.na(Emotion),!is.na(Qn)) %>% select(ID,Type,Emotion,Ql,Score) %>%
    pivot_wider(names_from=Ql, values_from=Score, values_fn=mean) %>% mutate(Q_mean=(Q1+Q2+Q3+Q4)/4)

  df_et <- read_tsv(path_et, show_col_types=FALSE) %>% rename(ID=Participant) %>%
    mutate(ID=tolower(trimws(ID)), Type=tolower(trimws(Type)), Emotion=tolower(trimws(Emotion))) %>%
    filter(AOI=="AOI_BIG", Type %in% c("ani-con","graphic-con","real-con","realistic"),
           Emotion %in% c("anger","sadness","disgust","joy","fear")) %>%
    group_by(ID,Type,Emotion) %>%
    summarise(across(all_of(et_vars), ~mean(as.numeric(.), na.rm=TRUE)), .groups="drop")

  merged <- df_fnirs %>% inner_join(df_sv, by=c("ID","Type","Emotion")) %>%
    inner_join(df_et, by=c("ID","Type","Emotion"))

  bf1 <- function(x,y,min_n=8){ ok<-is.finite(x)&is.finite(y); if(sum(ok)<min_n) return(NULL)
    bf<-suppressMessages(correlationBF(x[ok],y[ok])); post<-suppressMessages(posterior(bf,iterations=4000))
    tibble(N=sum(ok), r=median(post[,"rho"]), BF10=as.numeric(extractBF(bf)$bf)) }
  runver <- function(data, tag){ res<-list()
    for(emo in unique(data$Emotion)){ sub<-data[data$Emotion==emo,]
      for(r in roi) for(o in outc){ b<-bf1(as.numeric(sub[[r]]),as.numeric(sub[[o]]))
        if(!is.null(b)){ b$Emotion<-emo;b$ROI<-r;b$Outcome<-o;b$OutcomeType<-ifelse(o%in%sv_vars,"Survey","ET");res[[length(res)+1]]<-b}}}
    bind_rows(res) %>% arrange(desc(BF10)) %>% mutate(version=tag) }

  V1 <- runver(merged, "V1_exploratory_pooled")
  agg <- merged %>% group_by(ID,Emotion) %>%
    summarise(across(all_of(c(roi,outc)), ~mean(.,na.rm=TRUE)), .groups="drop")
  V2 <- runver(agg, "V2_confirmatory_participant_aggregated")
  write.csv(V1, file.path(OUTDIR,"bayes_V1_exploratory.csv"), row.names=FALSE)
  write.csv(V2, file.path(OUTDIR,"bayes_V2_confirmatory.csv"), row.names=FALSE)
  message(sprintf("Bayesian done. V1 BF10>3: %d ; V2 BF10>3: %d (of %d tests each)",
                  sum(V1$BF10>3), sum(V2$BF10>3), nrow(V1)))
  list(V1=V1, V2=V2)
}
