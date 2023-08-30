# TLDR: Output file's name: result.csv (in the same folder)
# Rows are not exactly in the order of AI01-AI110!! 
# Look at the first column in result.csv 
# Missing Log Files: AI31 and AI45

# 1. This script process all Emotion Regulation log files from the scan sessions. 
# 2. For each participant, average ratings and response time for the reappraisal, 
# negative and neutral trials are calculated. (6 values in total)
# 3. Trials where the response is zero are ignored.
# 4. Results = 6 columns in a csv file and pasted into the behavioral file. 

# Pathway to be changed:
folder_path <- "/Users/helen/Desktop/EmotionRegulation"
input_type <- "\\.txt$"
csv_name <- "/result.csv"
output_pathway <- paste(folder_path, csv_name, sep = "")

library(tidyverse)
library(fs)

setwd(folder_path)

txt_files <- list.files(pattern = input_type)
view(txt_files)

# create output dataframe
final_result <- data.frame(
  types = c('Reappraisal Rating','Negative Rating',
            'Neutral Rating', 'Reappraisal ResTime',
            'Negative ResTime', 'Neutral ResTime')
)

# read and process AffInt Log files one by one
for (i in seq_along(txt_files)) {
  txt_data <- map_dfr(txt_files[[i]], read.table)
  
  # group data by conditions and calculate mean rating & response time
  result <- txt_data %>% 
    group_by(V2) %>% 
    summarise(mean(V5[V5 != 0]), mean(V6[V6 != 0]))
  rating_result <- result[["mean(V5[V5 != 0])"]]
  resTime_result <- result[["mean(V6[V6 != 0])"]]
  combine_result <- c(rating_result, resTime_result)
  
  segments <- strsplit(txt_files[[i]], "-")
  col_name <- segments[[1]][1]
  final_result[[col_name]] <- combine_result
}

# Write the result to a CSV file
transpose_final_result = t(final_result)
write.table(transpose_final_result, file = output_pathway, sep = ",", col.names = FALSE, row.names = TRUE)

