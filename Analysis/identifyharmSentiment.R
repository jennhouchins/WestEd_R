# FILE DESCRIPTION ####
#
# Name: identifyharmSentiment.R
# Author: Jennifer K. Houchins
# Project: Some Study
# Purpose: Analyze student written response data
#          for evidence of intent to self-harm or harm others.
#
# Date Created: 02/13/2024
# Date Modified: 04/03/2024 (add checks for evidence of abuse)
#
# Note: This analysis was written to work with a particular data file.
#       Some variable names may need updating for differently formatted data.
###########################################

# PROJECT SET UP ####
# install/load packages and authorize box
if (!require("pacman")) install.packages("pacman")
pacman::p_load(pacman, boxr, tidyverse, janitor, tidytext, 
               textdata, ggplot2, stringr)

# authenticate boxr
# (for boxr documentation, see https://r-box.github.io/boxr/articles/boxr.html)
box_auth()

# LOAD DATA ####
BOX_FOLDER_ID <- "" # box folder id for writing analysis results
STUDENT_DATA_ID_ORIG <- "" # box file id of supplied, clean/de-identified data file 

student_responses <- box_read_csv(STUDENT_DATA_ID_ORIG,
                                  fileEncoding = "latin1") |> # file has latin1 encoding, this option isn't needed for files with UTF-8 encoding
  clean_names() |> 
  select(alternative_id, essay, languages) |> 
  mutate(essay = iconv(essay, from= "latin1", to="UTF-8", sub='')) #convert essays to UTF-8 encoding for nlp, unnecessary is already UTF-8

# the tidytext and sentiment packages can only process english, so we must filter
# out responses written in other languages
student_responses_en <- student_responses |> 
  filter(languages == "English")

cleaned_responses <- student_responses_en_all |> 
  mutate(essay = tolower(essay))


# tokenize text of responses, in this case tokens are words 
response_tokens <- cleaned_responses |> 
  unnest_tokens(word, essay) |> 
  anti_join(stop_words) |> 
  distinct()

# ANALYSIS ####

# we'll be using the tidytext package to perform sentiment analysis using
# available lexicons (AFINN, bing, and nrc)
# for more info, see https://www.tidytextmining.com/sentiment

nrc <- get_sentiments("nrc") # gets sentiments like positive/negative and anger, joy, trust for words

# join response tokens with the nrc lexicon to determine the sentiments of each word 
# in a student essay response
sentiment_in_responses <- inner_join(response_tokens, nrc, by = "word", relationship = "many-to-many")

# count the number of times each sentiment occurs in a response and output 
# a dataframe with those counts
summary_nrc <- sentiment_in_responses  |> 
  dplyr::count(alternative_id, sentiment, sort = TRUE)  |> 
  spread(sentiment, n, fill=0)  |> 
  mutate(lexicon = "nrc")  |> 
  relocate(lexicon)  |>  
  select(alternative_id,positive, negative, anger, anticipation, disgust, fear, joy, 
         sadness, surprise, trust) 

# combine with full essay response
summary_nrc_full <- inner_join(summary_nrc, cleaned_responses, by = "alternative_id")

# responses that include higher negativity than positivity warrant some closer
# investigation (results in 93 essays to inspect or further filter) (LEVEL 2)
responses_to_investigate_negative <- summary_nrc_full |> 
  filter(anger > 0,
         anticipation > 0,
         sadness > 0,
         fear > 0, 
         disgust > 0) |> 
  filter(negative > positive) |> 
  select(alternative_id, essay) |> 
  distinct()

# List of words to search for in essays that may indicate some sort of harm
harm_words_to_search <- c("pain", "suffering", "end", "escape", "darkness", 
                          "alone", "helpless", "hopeless", "overwhelmed", 
                          "suicide", "harm", "cut", "cutting", "bleed", "void", "numb", 
                          "worthless", "guilt", "despair", "broken", "goodbye",
                          "burn", "kill", "killing", "hurt", "hurting", "relief", "pills",  
                          "die", "stab", "stabbing", "lowest")

harm_words <- tibble(word = harm_words_to_search)

# List of words to search for in essays that may indicate some sort of abuse
# words listed cover emotional/psychological, physical, sexual, financial, verbal, 
# neglect, and general abuse 
abuse_words_to_search <- c("manipulated", "controlled", "gaslighted", "gaslighting",
                           "belittled", "humiliated", "isolated", "intimidated",
                           "threatened", "coerced", "insulted", "criticized",
                           "devalued", "disrespected", "undermined", "invalidated", "hitting",
                           "hit", "slapped", "punched", "kicked", "beaten", "beating","beat",
                           "bruised", "burned", "choked","bitten","bite", "shoved", "restrained",
                           "injured", "assaulted", "battered", "violated", "raped", "coerced",
                           "molested", "forced", "touched", "exploited", "stolen", "biting",
                           "withheld", "deprived","yelled", "screamed", "sworn", "swore",
                           "abandoned", "neglected", "ignored", "starved", "afraid","trapped")

abuse_words <- tibble(word = abuse_words_to_search)
# get the harm words that appear in student essays
investigate_for_harm <- inner_join(response_tokens, harm_words, by = "word")

# get the abuse words that appear in student essays
investigate_for_abuse <- inner_join(response_tokens, abuse_words, by = "word")

# join with full essay responses for harm 
responses_to_investigate_harm <- inner_join(investigate_for_harm, cleaned_responses, 
                                            by = "alternative_id", relationship = "many-to-many") |> 
  select(alternative_id, word) |> 
  distinct()

# join with full essay responses for abuse
responses_to_investigate_abuse <- inner_join(investigate_for_abuse, cleaned_responses, 
                                             by = "alternative_id", relationship = "many-to-many") |> 
  select(alternative_id, word) |> 
  distinct()

# LEVEL 2 responses containing abuse words
evidence_of_abuse <- inner_join(investigate_for_abuse, cleaned_responses, 
                                by = "alternative_id", relationship = "many-to-many") |> 
  select(alternative_id, word, essay) |> 
  distinct()

# inner join of the overly negative responses with those that include harm words
# results are LEVEL 1 candidates for researcher inspection for final determination of risk
final_harm_candidates <- inner_join(responses_to_investigate_negative, 
                                    responses_to_investigate_harm, by = "alternative_id", 
                                    relationship = "many-to-many")

# inner join of the overly negative responses with those that include abuse words
# results are LEVEL 1 candidates for researcher inspection for final determination of risk
final_abuse_candidates <- inner_join(responses_to_investigate_negative, 
                                     responses_to_investigate_abuse, by = "alternative_id", 
                                     relationship = "many-to-many")


# GENERATE OUTPUTS ####
# we'll write out the essay responses selected for researcher inspection to Box
# appending report date to the file name to ensure we don't overwrite prior results
report_date <- format(Sys.time(), "%Y%m%d")
# box_write(final_harm_candidates,
#           dir_id = BOX_FOLDER_ID,
#           file_name = paste("essays_containing_harm_words_LEVEL1_",report_date,".csv"),
#           write_fun = readr::write_csv)
# 
# box_write(responses_to_investigate_negative,
#           dir_id = BOX_FOLDER_ID,
#           file_name = paste("essays_containing_negative_sentiments_LEVEL2_",report_date,".csv"),
#           write_fun = readr::write_csv)
# 
# box_write(final_abuse_candidates,
#           dir_id = BOX_FOLDER_ID,
#           file_name = paste("essays_containing_abuse_words_LEVEL1_",report_date,".csv"),
#           write_fun = readr::write_csv)
# 
# box_write(evidence_of_abuse,
#           dir_id = BOX_FOLDER_ID,
#           file_name = paste("essays_containing_abuse_words_LEVEL2_",report_date,".csv"),
#           write_fun = readr::write_csv)

# clean up the R environment so no data is left in the environment
# this ensures data compliance if any collaborator has not set RStudio
# settings such that the workspace is never saved to .RData (this should be set!)
rm(list = ls(all.names = TRUE))
