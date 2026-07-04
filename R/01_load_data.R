# ============================================================================
# 01_load_data.R — load & harmonize the three modalities (N = 20)
# Returns: df_sv (PCE), df_et_big / df_et_small (eye-tracking), df_fn (fNIRS)
# ============================================================================

## ---- Survey / PCE (wide -> long -> one row per Subject×Type×Emotion) ----
load_survey <- function(path = PATHS$survey) {
  raw <- read_excel(path)
  q_cols <- colnames(raw)[grepl("_[1-4]$", colnames(raw))]
  raw %>%
    mutate(SubjectID = row_number()) %>%
    select(SubjectID, all_of(q_cols)) %>%
    pivot_longer(all_of(q_cols), names_to = "col_name", values_to = "Score") %>%
    mutate(
      Score  = as.numeric(Score),
      Type_kr = str_extract(col_name, "^[^_]+"),
      # match Korean emotion tokens embedded in the raw column names
      Emo_kr = case_when(str_detect(col_name,"분노")~"분노", str_detect(col_name,"슬픔")~"슬픔",
                         str_detect(col_name,"혐오")~"혐오", str_detect(col_name,"기쁨")~"기쁨",
                         str_detect(col_name,"공포")~"공포"),
      Q_num = as.numeric(str_extract(col_name, "\\d+$")),
      Type  = factor(TYPE_MAP[Type_kr], levels = TYPE_LEVELS),
      Emotion = factor(EMO_MAP[Emo_kr], levels = EMO_LEVELS),
      Q_label = paste0("Q", Q_num)) %>%
    filter(!is.na(Type), !is.na(Emotion)) %>%
    select(SubjectID, Type, Emotion, Q_label, Score) %>%
    pivot_wider(names_from = Q_label, values_from = Score, values_fn = mean) %>%
    mutate(Q_mean = (Q1+Q2+Q3+Q4)/4, SubjectID = factor(SubjectID))
}

## ---- Eye-tracking (Tobii AOI metrics export). aoi = "AOI_BIG" or "AOI_SAMLL" ----
load_eyetracking <- function(aoi, path = PATHS$eyetrack) {
  d <- read_tsv(path, show_col_types = FALSE) %>%
    rename(pid = Participant) %>%
    mutate(pid = tolower(trimws(pid)),
      Type = case_when(tolower(Type)=="realistic"~"Realistic", tolower(Type)=="graphic-con"~"GraphicCon",
                       tolower(Type)=="ani-con"~"AniCon", tolower(Type)=="real-con"~"RealCon"),
      Emotion = case_when(tolower(Emotion)=="joy"~"Joy", tolower(Emotion)=="anger"~"Anger",
                          tolower(Emotion)=="sadness"~"Sadness", tolower(Emotion)=="disgust"~"Disgust",
                          tolower(Emotion)=="fear"~"Fear")) %>%
    filter(AOI == aoi, !is.na(Type), !is.na(Emotion)) %>%
    mutate(Type = factor(Type, levels = TYPE_LEVELS), Emotion = factor(Emotion, levels = EMO_LEVELS))
  ids <- unique(d$pid)
  d$SubjectID <- factor(setNames(seq_along(ids), ids)[d$pid])
  for (m in ET_METRICS) d[[m]] <- as.numeric(d[[m]])
  d
}

## ---- fNIRS group HbO by Brodmann/ROI ----
load_fnirs <- function(path = PATHS$fnirs) {
  read_excel(path) %>%
    rename(SubjectID = `Subject Name`, Type = Group) %>%
    mutate(SubjectID = factor(tolower(trimws(SubjectID))),
      Emotion = factor(str_to_title(tolower(Emotion)), levels = EMO_LEVELS),
      Type = factor(recode(Type, AniCon="AniCon", GraphicCon="GraphicCon",
                           RealCon="RealCon", Realistic="Realistic"), levels = TYPE_LEVELS))
}
