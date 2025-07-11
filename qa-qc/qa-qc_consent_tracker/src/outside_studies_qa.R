outside_studies_qa <- function(protocol_id,
                               consent_directory, lab_log=FALSE, lab_sample_type=NULL){
  
  # 1. read in tbl_subject_referred
  tbl_subject_referred <- read.csv("data/input/tbl_subject_referred.csv")
    # subset tbl_subject_referred to get entries associated with the current protocol_id 
  tbl_status <- tbl_subject_referred[tbl_subject_referred$protocol_id == protocol_id, c("subject_id", "protocol_id", "status", "status_date")]
  
  # 2. isolate the number of samples collected and merge
    # read in the appropriate lab log 
  if (lab_log){
    if (lab_sample_type == "skin"){
      tbl_lab <- read.csv("data/input/tbl_subject_lab_skin.csv")
    } else {
      tbl_lab <- read.csv("data/input/tbl_subject_lab_lp.csv")
    }
      # subset tbl_lab to get entries associated with the current protocol_id
    tbl_lab <- tbl_lab[tbl_lab$protocol_id == protocol_id, ]
      # count total entries for each person
    tbl_sample_count <- tbl_lab %>% group_by(subject_id) %>%
      summarize(
        !!paste0("number_of_", lab_sample_type, "_samples") := n(),
        )
    
    tbl_status <- merge(tbl_status, tbl_sample_count, all.x = TRUE)
    
  }
  # 3. read in the consents and make tbl_consents 
  tbl_consents <- tibble(consent_file_name = basename(dir_ls(consent_directory)))
  
  tbl_consents <- tbl_consents%>% mutate(
    subject_id = str_extract(consent_file_name, "^\\d{5}") %>% str_remove("^0+")
  )
  # 4. merge tables together 
  
  tbl_status_count_consents <- merge(tbl_status, tbl_consents, all.x = TRUE, all.y = TRUE)
  
  return(tbl_status_count_consents)
  
  
  
  
}
