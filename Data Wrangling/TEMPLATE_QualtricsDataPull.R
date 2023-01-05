## Qualtrics Data Pull R Script  ###############################################
## File Name: TEMPLATE_QualtricsDataPull.R
## Author: Kelly Collins
## Email: kcollin2@wested.org
## Date Created: 8/31/2021
## Box Folder ID: 
## Box File ID: 
##
## Modifications - 
##   Date of Change: 
##   By: 
##   Notes: (1) 
##          (2) 

################################################################################

# TOC
#  1. Install and Load Packages
#  1.1 Setting up your Qualtrics API [DELETE after 1st time]
#  2. MAIN USER EDITS 
#  3. Import survey data
#  4 Create a codebook: Part1
#  5. Create a codebook: Part2
#  6. Clean test surveys
#  7. Write to Box

# NOTICE: To use this script you must have already installed the boxr package  
#   and set up with your authentication Key. 
#   If you have not already done this: 
#     1. Download and install the 'boxr' package. 
#     2. Follow Authentication instructions at link below
#         - https://ijlyttle.github.io/boxr/articles/boxr.html

################################################################################

#******************************************************************************#
#### 1. Install and Load Packages ##############################################
#******************************************************************************#

# @function installPackage
#  The `installPackage` function takes a package name, checks if it is
#   installed, and installs it if it is not installed.
# @param {string} packagename
#   The `packagename` parameter must be a valid package name.
# @return {void}
installPackage <- function(packagename) {
  if( !(packagename %in% rownames(installed.packages())) ) {
    install.packages(packagename)
  }
}

installPackage("pacman")

#unload all previously loaded packages that may affect script
library(pacman)
pacman::p_unload(all)
#load required packages
library(pacman)
p_load(plyr)
p_load(utils)
p_load(boxr)
p_load(tidyverse)
p_load(psych)
p_load(qualtRics) # Uncomment if you have already set up your Qualtrics API
box_auth()

#******************************************************************************#
#### 1.1 Setting up your Qualtrics API [DELETE AFTER 1ST TIME] #################
#******************************************************************************#
#
# This Entire section refers to the first time use of the "qualtRics" package.
#   Documentation on the package and setting up your qualtrics api for the first 
#   time can be found at the following site: 
#    https://cran.r-project.org/web/packages/qualtRics/vignettes/qualtRics.html
#

## Install & load the 'qualtRics' package
p_load(qualtRics)

### Get your account specific QUALTRICS_API_KEY and QUALTRICS_BASE_URL
# For more instructions on how to find this: 
#   https://api.qualtrics.com/instructions/ZG9jOjg0MDczOA-api-reference


## Getting your Qualtrics Base URL
#
#   - Open your qualtrics account
#   - Click on 'account settings'
#   - Click on on 'Qualtrics IDs'
#   - Find the 'User' box
#   - identify your 'Datacenter ID'
#
# Your Base URL is {datacenterid}.qualtrics.com

QUALTRICS_BASE_URL <- "{REPLACE_ME}.qualtrics.com"

## Getting your API Key 
#
#   - Open your qualtrics account
#   - Click on 'account settings'
#   - Click on on 'Qualtrics IDs'
#   - Find the 'API' box
#   - identify your 'Token'
#
# Your API Key is your Token

QUALTRICS_API_KEY <- "{REPLACE_ME_WITH_TOKEN}"

# Store your Base URL and API Key in your .Renviron for repeated use
qualtrics_api_credentials(api_key = QUALTRICS_API_KEY,
                          base_url = QUALTRICS_BASE_URL,
                          install = TRUE,
                          overwrite = T)

# To begin using qualtRics without restarting R
readRenviron("~/.Renviron")

### NOW DELETE THIS SECTION !!!!!!!!!!!!!!!!!!!!!!!!

#******************************************************************************#
#### 2.MAIN USER EDITS #########################################################
#******************************************************************************#
#
# In this section a user can set all of the important import and export for 
#   the survey data they are looking to fetch, clean, and store
#
#   NOTE: If you do not need to use any special import parameters or cleaning 
#   parameters you should be able to just run this code after these varaiables
#   are properly Set
#

### SurveyID - the qualtrics survey ID for the survey you are trying to fetch.
#   To import data from a specific survey you will nee the surveyID. 
#
# Steps for finding the surveyID:
#
#   - Open your qualtrics account
#   - Click on 'account settings'
#   - Click on on 'Qualtrics IDs'
#   - Find the 'Surveys' box
#   - identify the survey you are looking for and it's surveyID
#
# Enter THE Survey ID in the quotes below
#   Ex:
#     SURVEY_ID <- "SV_8A1C7EDo81W4guy"

SURVEY_ID <- "REPLACE_ME"

### Box Folder ID - the box folder where you intend to store the survey data and
#     codebook that you revrieved from Qualtrics
#
#   If you go to the folder in Box you will notice the digits at the end of the 
#     url for the box folder. This is the Box folder ID.
#
#   Paste the Box folder ID where the # are located below (no quotes necessary)
#   Ex:
#     BOX_FOLDER_ID <- 145425326961

BOX_FOLDER_ID <- #NUBMERS_HERE#

### Survey File Name - the name of the output survey file that will be stored on 
#    box.
#    
#   Name your file something identifiable. Enter the name into the quotes below.
#     YOU MUST LEAVE THE `.csv`
#     Ex:
#       SURVEY_NAME <- "NSF_PirateMath_PreSurvey_2021Pilot.csv"
    
SURVEY_NAME <- "REPLACE_ME.csv"
    
### Codebook File Name - the name of the output codebook file that will be 
#    stored on box.
#    
#   Name your file something identifiable. Enter the name into the quotes below.
#     YOU MUST LEAVE THE `.csv`
#     Ex:
#       CODEBOOK_NAME <- "Codebook_PirateMath_PreSurvey_2021Pilot.csv"
    
CODEBOOK_NAME <- "REPLACE_ME.csv"

### IMPORTANT: READ THE CLEANING CRITERIA BEFORE RUNING CODE
#         
#   The cleaning section is meant to remove test survey responses done in 
#     preview mode or by wested staff (from either their wested or personal 
#     email).
#   Please make sure you read through the criteria and add or remove anything 
#     you need before running the code. 
    
#******************************************************************************#    
#### 3. Import survey data #####################################################
#******************************************************************************#   
    
    
### Useful fetch_survey arguments: (Optional Changes)
#
#   unasnwer_recode       - recode seen but unanswered questions with an 
#                           integer-like value, such as 999. Default to NULL.
#   unasnwer_recode_multi - recode seen but unanswered multi-select questions 
#                           with an integer-like value, such as 999. 
#                           Default to NULL.
#   include_questions     - Vector of strings (e.g. c('QID1', 'QID2', 'QID3'). 
#                           Export only specified questions. Defaults to NULL.
#   verbose               - Logical. If TRUE, verbose messages will be printed 
#                           to the R console. Defaults to TRUE.
#   label                 - Logical. TRUE to export survey responses as 
#                           Choice Text or FALSE to export survey responses as 
#                           values.
#   breakout_sets         - Logical. If TRUE, then the fetch_survey function 
#                           will split multiple choice question answers into 
#                           columns. If FALSE, each multiple choice question is 
#                           one column. Defaults to TRUE.
#   time_zone             - String. A local timezone to determine response date 
#                           values. Defaults to NULL which corresponds to 
#                           UTC time. 
#                           See "https://api-test.qualtrics.com/docs/
#                           publicapidocs/docs/Instructions/dates-and-times.md" 
#                           for more information on format.
#

df.survey <- fetch_survey(surveyID = SURVEY_ID,
                        label = F,
                        convert = F)

# Note: the class of the resulting data.frame is: 
#           "spec_tbl_df"     "tbl_df"      "tbl"         "data.frame" 



#******************************************************************************#
#### 4. Create A Codebook: Part1 - Variable names and questions ###############
#******************************************************************************#
#
# The goal of this section and the next is to be able to create a dataframe 
#   which has the following 5 columns:
#     - variable_name
#     - data_type
#     - main_question
#       - sub_question (for 'choose all' or matrix questions only)
#     - response_values

# the survey data frame attributes has all of the variables except 'Data Type'
survey.codebook <- attr(df.survey,"column_map")

# getting datatype
data_type <- df.survey %>% 
  summarise_all(class)

data_type <- data_type[1,]

data_type <- data_type %>% 
  gather(variable, class)

# Changing column names
names(survey.codebook)[names(survey.codebook) == "qname"] = "variable_name"
names(survey.codebook)[names(survey.codebook) == "main"] = "main_question"
names(survey.codebook)[names(survey.codebook) == "sub"] = "sub_question"

names(data_type)[names(data_type) == "variable"] = "variable_name"
names(data_type)[names(data_type) == "class"] = "data_type"

# isolating columns and adding data_type
survey.codebook <- survey.codebook[ ,c("variable_name",
                                         "main_question",
                                         "sub_question")]

survey.codebook <- full_join(survey.codebook,data_type)

# re-ordering columns
survey.codebook <- survey.codebook[ ,c("variable_name",
                                         "data_type",
                                         "main_question",
                                         "sub_question")]

#******************************************************************************#
#### 5. Create A Codebook: Part2 - Response Values #############################
#******************************************************************************#
#
# Here we want to identify and capture all the possible response values for a 
#   given question and what they mean.
#       specifically for Multiple Coice and Matrix Questions Only
#

### Metadata
#
# The first chunck of variables is always going to be survey meta_data. 
#   Values for the metadata is usually apparent in the variable name.
#   Because of this, it is often sufficient to repeate the variable name as the 
#   response value, or leave the response value blank, whichever you prefer. 
#
#
#
#
# Variables to grab from Metadata:
#     - Question Name
#     - Question Type
#     - Choice Value

Survey.Metadata <- metadata(surveyID = SURVEY_ID,
                 get = list(questions = T,
                            metadata = F,
                            responsecounts = F))

# @function grab_question.type
#   The `grab_question.type` takes the survey metadata which is provided as a,
#   list of lists, and compiles pertinent info into a data fram with the 
#   tagged survey question names and question types.
# @param {list} metadata.list
#   The `metadata.list` must be the metadata imported from Qualtrics using the 
#   function 'metadata;.
# @return {data frame}
grab_question.type <- function(metadata.list){
  
  variable_name <- c()
  question_type <- c()
  
  for(i in names(metadata.list$questions)){
  
    a <- metadata.list[["questions"]][[i]][["questionType"]][["type"]]
    question_type <- c(question_type,a)
    }
  
  for(i in names(metadata.list$questions)){
    
    a <- metadata.list[["questions"]][[i]][["questionName"]]
    variable_name <- c(variable_name,a)
    }
  
  output <- data.frame(variable_name,question_type)
  
return(output)  
}

# @function grab_question.choices
#   The `grab_question.choices` takes the survey metadata which is provided as a,
#   list of lists, and compiles pertinent info into a data fram with the 
#   tagged survey question names and the values of the response choices
# @param {list} metadata.list
#   The `metadata.list` must be the metadata imported from Qualtrics using the 
#   function 'metadata;.
# @return {data frame}
grab_question.choices <- function(metadata.list){
  
  variable_name <- c()
  
  for(i in names(metadata.list$questions)){
    
    a <- metadata.list[["questions"]][[i]][["questionName"]]
    variable_name <- c(variable_name,a)
    rm(a)
  }
  
  output <- data.frame(variable_name)
  
  choice.lengths <- c()
  
  for(i in names(metadata.list$questions)){
    
    a <- length(metadata.list[["questions"]][[i]][["choices"]])
    choice.lengths <- c(choice.lengths,a)
    rm(a)
    
  }
  
  max.choices <- max(choice.lengths)
  
  for(i in 1:max.choices){
    a <- paste0("choice_",i)
    
    output[[a]] = NA
    
    x <- as.character(i)
    
    for(n in names(metadata.list$questions)){
      
      var_name <- metadata.list[["questions"]][[n]][["questionName"]]
      
      if (length(metadata.list[["questions"]][[n]][["choices"]][[x]]) > 0){
       
        if(length(metadata.list[["questions"]][[n]][["choices"]][[x]][["recode"]]) > 0){
          
          b <- metadata.list[["questions"]][[n]][["choices"]][[x]][["recode"]]
          c <- metadata.list[["questions"]][[n]][["choices"]][[x]][["choiceText"]]
       
          value <- paste(b, c, sep = " = ") } else { 
            c <- metadata.list[["questions"]][[n]][["choices"]][[x]][["choiceText"]]
            value <- c
            }
       
       output[[a]][output[["variable_name"]] == var_name] = value
       
      }else{ output[[a]][output[["variable_name"]] == var_name] = NA}
      
    }
    }
  return(output)
}


# @function add_typesAndvalues
#   The `add_typesAndvalues` takes the survey metadata that was compiled using
#   `grab_question.type` & `grab_question.choices` and adds them to the codebook
#   that was sturted using the column_map attribute from the `qualtRics` package.
# @param {data fram} metadata.df 
#   The `metadata.df` should be the joined data frame outputs from 
#   `grab_question.type` & `grab_question.choices`
# @param {data fram} codebook.df 
#   The `codebook.df ` should be the df created by using the column_map attribute
#   of the survey imported using the `qualtRics` package.
# @return {data frame}
add_typesAndvalues <- function(metadata.df, codebook.df){
  
  final_codebook.df <- codebook.df
  final_codebook.df[["question_type"]] = NA
  
  # adding question_types to final_codebook.df
  for(i in metadata.df[["variable_name"]]){
    
    type <- as.character(metadata.df[["question_type"]][metadata.df[["variable_name"]] == i])
    check <- grep(i,final_codebook.df$variable_name, value = T)  
    
    final_codebook.df[["question_type"]][final_codebook.df[["variable_name"]] %in% check] = type
  }
  
  #Isolating just MC and Matrix Questions
  MC.MatrixQs <- metadata.df[metadata.df$question_type == "MC" |
                                 metadata.df$question_type == "Matrix", ]
  
  #Joining Choices into one "values" variable
  MC.MatrixQs <- MC.MatrixQs %>% unite(values, 
                                       3:ncol(MC.MatrixQs),
                                       sep = ", ", na.rm = T)
  
  #Creating "values" variable in final_codebook.df
  final_codebook.df$values <- NA
  
  # adding values to final_codebook.df
  for(i in MC.MatrixQs$variable_name){
    value <- as.character(MC.MatrixQs[["values"]][MC.MatrixQs[["variable_name"]] == i])
    check <- grep(i,final_codebook.df$variable_name, value = T)  
    
    final_codebook.df[["values"]][final_codebook.df[["variable_name"]] %in% check] = value
  }
  
  # Reordering columns
  final_codebook.df <- final_codebook.df[ ,c("variable_name",
                                             "data_type",
                                             "question_type",
                                             "main_question",
                                             "sub_question",
                                             "values")]
  return(final_codebook.df)
  
}

# Using the above functions to add values and question types to the codebook  
Question.Types <- grab_question.type(Survey.Metadata)
Question.Choices <- grab_question.choices(Survey.Metadata)

# Joining 'Question.Types' and 'Question.Choices' into one data frame.
Question.Info <- full_join(Question.Types,Question.Choices)

# Creating the final codebook that will be saved to Box
Final_Codebook <- add_typesAndvalues(Question.Info, survey.codebook)  

#******************************************************************************#
#### 6. Clean test responses ###################################################
#******************************************************************************#

# Removing all surveys completed as previews (not distributed)
Survey_Clean <- df.survey[!(df.survey$DistributionChannel == "preview"), ]

# Removing test surveys completed by wested staff
Survey_Clean <- Survey_Clean[grep("@wested.org",Survey_Clean$RecipientEmail,
                                  invert = T), ]

# Removing test surveys completed by wested staff from their personal emails
Survey_Clean <- Survey_Clean[grep("@gmail.com",Survey_Clean$RecipientEmail,
                                  invert = T), ]

#******************************************************************************#
#### 7. Write to Box ###########################################################
#******************************************************************************#

# Writing survey response data to box folder
box_write(Survey_Clean,SURVEY_NAME, dir_id = BOX_FOLDER_ID)

# Writing data codebook to box folder
box_write(Final_Codebook,CODEBOOK_NAME, dir_id = BOX_FOLDER_ID)