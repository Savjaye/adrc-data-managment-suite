
tbl_subject <- read.csv("./data/input/tbl_subject.csv")
tbl_visits <- read.csv("./data/input/tbl_visits.csv") 
c1 <- read.csv("./data/input/uds_c1npsyb.csv")
roster <- read.csv("./data/input/uds_roster.csv")
a1 <-read.csv("./data/input/uds_a1subdemo.csv")

# 1. Get anyone who has had blood(NCRADDateCollected), psych data(VISITDATE), or a submissing to NACC (REGRTYID)
  # get the C1 data with IDs
tbl_c1_w_rid <- merge(c1, roster, by="RID") 
  # merge in the a1 for the coodrintor initials 
tbl_sdsc <- merge(tbl_c1_w_rid, a1, by=c("RID", "VISCODE"), all=TRUE) %>% mutate(VISCODE = substr(VISCODE, 2, nchar(VISCODE))) %>% select(REGTRYID, VISCODE, VISITDATE.x, INITIALS.y)
  # rename fields
colnames(tbl_sdsc)[colnames(tbl_sdsc) == "VISITDATE.x"] <- "PSYCH_VISIT_DATE"
colnames(tbl_sdsc)[colnames(tbl_sdsc) == "INITIALS.y"] <- "COORDINATOR_INITIALS"

  tbl_visits_w_regid <- merge(tbl_visits, tbl_subject, by = "subject_id")
  # add in the date of blood collections
tbl_year_one_visits <- merge(tbl_sdsc, tbl_visits_w_regid, by.x=c("REGTRYID", "VISCODE"), by.y=c("adrc_long_id", "yrinstudy"), all.x = TRUE, all.y = TRUE) %>%
      # select out needed cols
  select(REGTRYID, subject_id, COORDINATOR_INITIALS,VISCODE, PSYCH_VISIT_DATE,NCRADDateCollected) %>% 
      # format dates and filter to get y=1 data only
  mutate(PSYCH_VISIT_DATE = as.Date(as.character(PSYCH_VISIT_DATE), format = "%m/%d/%Y"),
         NCRADDateCollected = as.Date(as.character(NCRADDateCollected), format = "%b-%d-%y")) %>% filter(VISCODE == "1")


# 2. Read in all the consents from the consent directory
consent_directory <- "/Volumes/adrc_users/Regulatory/ADRC Longitudinal 170957 (EL)/Scanned-Signed Longitudinal Consents"
consent_ls <- tibble(consent_file_name = basename(dir_ls(consent_directory)))
consent_df <- consent_ls %>% mutate(
  REGTRYID = str_extract(consent_file_name, "^\\d{5}") %>% str_remove("^0")
)

tbl_year_one_visits_w_consents <- merge(tbl_year_one_visits, consent_df, by="REGTRYID", all.x = TRUE) %>% filter(PSYCH_VISIT_DATE >= as.Date("2023-06-01") | NCRADDateCollected >= as.Date("2023-06-01"))
write.csv(tbl_year_one_visits_w_consents, file = "./missingConsents/consents_folder.csv")
