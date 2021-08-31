library(GGIR)
library(tidyverse)

#--- INPUTS ---

### Check these ###
diary_filename <- "HBA+LEISURE+Sleep+Diary_August_test.csv"
max_days <- 7
###################

# These shouldn't need editing if using the Docker container with recommended
# folder names.

diary_raw <- fs::path(paste0("/home/hba-actig/hba-sleepdiary/", diary_filename))
files_in <- fs::path("/home/hba-actig/hba-actigraph")
diary_clean <- fs::path("/home/hba-actig/hba-sleepdiary/diary_clean.csv")
data_out <- fs::path("/home/hba-actig/ggir-output")
setwd(files_in)

#--- FUNCTIONS ---

clean_diary <- function(f) {
  
  col_names <- names(readr::read_csv(f, n_max = 0))
  ids <- raw_files_pre %>% stringr::str_replace("RAW.csv", "")
  
  df <- read_csv(f, col_names = col_names, skip = 3) %>%
    mutate(secs = "00") %>%
    tidyr::unite("SleepOnsetDay1", c(TTS.1_1, TTS.1_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOnsetDay2", c(TTS.2_1, TTS.2_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOnsetDay3", c(TTS.3_1, TTS.3_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOnsetDay4", c(TTS.4_1, TTS.4_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOnsetDay5", c(TTS.5_1, TTS.5_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOnsetDay6", c(TTS.6_1, TTS.6_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOnsetDay7", c(TTS.7_1, TTS.7_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOffsetDay1", c(FWT.1_1, FWT.1_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOffsetDay2", c(FWT.2_1, FWT.2_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOffsetDay3", c(FWT.3_1, FWT.3_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOffsetDay4", c(FWT.4_1, FWT.4_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOffsetDay5", c(FWT.5_1, FWT.5_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOffsetDay6", c(FWT.6_1, FWT.6_2, secs), sep = ":", remove=FALSE) %>%
    tidyr::unite("SleepOffsetDay7", c(FWT.7_1, FWT.7_2, secs), sep = ":", remove=FALSE) %>%
    dplyr::select(QID1, contains("SleepO")) %>%
    dplyr::filter(QID1 %in% ids)
  readr::write_csv(df, diary_clean)
}

clean_filenames_pre <- function(f) {
  new_f <- paste0(stringr::str_replace(f, "RAW.csv", " RAW.csv"))
  fs::file_move(f, new_f)
}

clean_filenames_post <- function(f) {
  new_f <- paste0(stringr::str_replace(f, " RAW.csv", "RAW.csv"))
  fs::file_move(f, new_f)
}

runGGIR <- function() {
  g.shell.GGIR(
    mode = c(1,2,3,4,5),
    overwrite = FALSE,
    datadir = files_in,
    outputdir = data_out,
    do.report = c(2,4,5),
    idloc = 5,
    desiredtz = "Australian Eastern Standard Time",
    #=====================
    # Part 2
    #=====================
    strategy = 1,
    hrs.del.start = 0,
    hrs.del.end = 0,
    maxdur = 9,
    includedaycrit = 16,
    qwindow=c(0,24),
    mvpathreshold =c(100),
    bout.metric = 4,
    excludefirstlast = FALSE,
    includenightcrit = 16,
    #=====================
    # Part 3 + 4
    #=====================
    def.noc.sleep = 1,
    outliers.only = TRUE,
    criterror = 4,
    do.visual = TRUE,
    loglocation = "/home/hba-actig/hba-sleepdiary/diary_clean.csv",
    coln1 = 2,
    colid = 1,
    nnights = max_days,
    sleeplogidnum = FALSE,
    #=====================
    # Part 5
    #=====================
    threshold.lig = c(30),
    threshold.mod = c(100),
    threshold.vig = c(400),
    boutcriter = 0.8,
    boutcriter.in = 0.9,
    boutcriter.lig = 0.8,
    boutcriter.mvpa = 0.8,
    boutdur.in = c(1,10,30),
    boutdur.lig = c(1,10),
    boutdur.mvpa = c(1),
    includedaycrit.part5 = 2/3,
    #=====================
    # Visual report
    #=====================
    timewindow = c("WW"),
    visualreport=TRUE
  )
}

#--- RUN ---

raw_files_pre <- Sys.glob("HBA*.csv")
lapply(raw_files_pre, clean_filenames_pre)
clean_diary(diary_raw)
runGGIR()
raw_files_post <- Sys.glob("HBA* RAW.csv")
lapply(raw_files_post, clean_filenames_post)

message("--- FINISHED ---")