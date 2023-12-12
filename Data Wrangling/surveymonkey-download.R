#### FILE DESCRIPTION ####
#
# Name: surveymonkey-download.R
# Author: Rosie Owen
# Project: WestEd R scripts
# Purpose: Provide template for downloading survey results from SurveymMonkey in R,
#          using the surveymonkey package from https://github.com/mattroumaya/




#### HOW TO USE THIS SCRIPT
# for info on how to use the surveymonkey R package, read the instructions
# copied below, or follow this link for R package credit and more details: 
# https://github.com/mattroumaya/surveymonkey 

# FIRST install the surveymonkey package for R if you don't already have it
# you need to install it from github, using devtools (also install that if 
# you don't already have it): 
# install.packages("devtools")
# devtools::install_github("mattroumaya/surveymonkey")

# NEXT Get your OAuth token
# You’ll need an OAuth token, and for that you’ll need to set up an app.
# Log in to SurveyMonkey in your browser, then navigate to 
# https://developer.surveymonkey.com/apps. Create an app. 
# It should be private, and you should enable the relevant scopes: 
# View Surveys, View Collectors, View Contacts, View Responses, View Response Details. 
# Now look at the settings page for your app and take note of the 
# “Access Token” field, which should contain a very long character string.

# NEXT Add your OAuth token to your .Rprofile
# Add the SurveyMonkey account’s OAuth token to your .Rprofile file. To open 
# and edit that file, run usethis::edit_r_profile(), then add a line like this:
# options(sm_oauth_token = "kmda332fkdlakfld8am7ml3dafka-dafknalkfmalkfad-THIS IS NOT THE REAL KEY THOUGH").
# Except use the OAuth token listed on your app’s settings page, obtained in 
# the previous step.

# NEXT Restart R for this change to take effect.

# FINALLY find the SURVEY ID from SurveyMonkey 



#### Load packages, set Box directory, save survey ID, create filename ####
# install.packages("pacman") # install pacman if you don't yet have it
pacman::p_load(boxr, tidyverse, stringi, stringr, surveymonkey)
box_auth()

# Box directory for saving SurveyMonkey data
rawData.box.dir <- 999999999999 

# Save survey ID 
surveyID <- 514949009

# create filename for survey data
todaysDate <- format(Sys.time(), "%m%d%Y")
rawData.filename <- paste0("rawdata", todaysDate, ".csv") 



#### Load survey data into R from SurveyMonkey ####
# fetch survey 
rawData <- surveyID %>%
  fetch_survey_obj %>%
  parse_survey %>% 
  strip_html

view(rawData)



#### Save data to Box as .csv ####
box_write(rawData, 
          rawData.box.dir, 
          write_fun = readr::write_csv,
          file_name = rawData.filename)