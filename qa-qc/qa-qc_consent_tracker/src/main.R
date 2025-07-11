library(dplyr)
library(fs)
library(stringr)
library(googlesheets4)

setwd("/Users/savannahhargrave/adrc/adrc-projects/data-managment-suite/qa-qc/qa-qc_consent_tracker")

source("src/outside_studies_qa.R")
source("src/write_google_sheet.R")

# google sheet config
sheet_link = "https://docs.google.com/spreadsheets/d/1nvsPfTlXQYRHlaNgfYuzMjBaS3WNzS4JRfYJ7qVz5Yw/edit?gid=772754732#gid=772754732"

# create logging mechanism 
log_file <- file.path("logs", paste0("qaqc_run_", Sys.Date(),".log"))
log_message <- function(msg){
  cat(paste("[",Sys.time(), "]", msg, "\n"), file = log_file, append = TRUE)
  message(msg)
}
# read in mapping
log_message("Loading in protocol/directory map")  
protocol_dir_map <- read.csv("config/protocol_consent_dir_mapping.csv")

# define google sheet vars


# loop through each of the protocols
for (protocol_id in protocol_dir_map$protocol_id){
  
  # call the appropriate processing function
  if (protocol_id == 55){
    print("processing longitudinal")
    tbl_protocol_report <- tibble()
  } else if (protocol_id == "autopsy"){
    print("processing autopsy")
    tbl_protocol_report <- tibble()
  } else {
    consent_dir <- protocol_dir_map[protocol_dir_map$protocol_id == protocol_id, ]$consent_dir
    sample_type <- protocol_dir_map[protocol_dir_map$protocol_id == protocol_id, ]$sample_type
    has_lab_log <- sample_type != ""
    print(protocol_id)
    print(has_lab_log)
    tbl_protocol_report <- outside_studies_qa(protocol_id, consent_dir, has_lab_log, sample_type)
  }
  
  # write the output to the appropriate tab in the google sheet 
  sheet_name = protocol_dir_map[protocol_dir_map$protocol_id == protocol_id, ]$sheet_name
  print(sheet_name)
  #write_google_sheet(sheet_link, sheet_name, tbl_protocol_report)
}
