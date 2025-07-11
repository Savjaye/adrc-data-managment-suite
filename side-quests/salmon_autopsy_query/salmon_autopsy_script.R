library(dplyr)

setwd("./adrc_projects/data-management-suite/side-quests/salmon_autopsy_query")

tbl_subject <- read.csv("tables/tbl_subject.csv")
tbl_visits <- read.csv("tables/tbl_visits.csv") %>% group_by(subject_rec_id)%>% 
  summarize(
    max_visit = max(yrinstudy)
  )

tbl_query <- merge(tbl_subject, tbl_visits)
autopsy_data <- tbl_query[c("Regtryid","max_visit", "subject_demographic_procedure_consent_autopsy", 
                              "subject_demographic_procedure_agree_consent_autopsy_signed", "subject_demographic_consent_version","subject_demographic_consent_version_date","subject_demographic_consent_date", 
                              "DOD","CauseOfDeath","whereDied","AutopsyLetterDateSent", "SympathyLetterDateSent",
                              "subject_demographic_procedure_agree_body_donation", 
                              "subject_status", "subject_status_description", "subject_status_description_reason",
                              "ChangeofStatus", "DropMo", "DropDay", "DropYr", "DropCode", "ReasonDrop",
                              "patient_type_notes")]

init_file <- read.csv("tables/adrc_deaths_and_autopsies.csv")
out_file <- merge(init_file, autopsy_data, by.x = "REGTRYID", by.y="Regtryid", all.x = TRUE, all.y = FALSE)
write.csv(out_file, file = "tables/output/adrc_deaths_and_autopsies.csv", row.names = FALSE)

