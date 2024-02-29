# FILE DESCRIPTION ####
#
# Name: generatesightwordcodes.R
# Author: Jennifer K. Houchins
# Project: [Used for an RCT project]
# Purpose: Generate unique codes that elementary students
#          can use to identify themselves for pre/post surveys.
#
# Date Created: 2023-08-23
# Box Folder ID: 
# Box File ID: 
#
# Modifications - 
#   Date of Change: 2024-02-29
#   By: Jennifer Houchins
#   Notes: (1) Added more documentation in comments
#          (2) Removed here package which wasn't needed
# 
# Code Conventions: 
# 1. we never ever set working directory (because that's bad!)
# 2. we adhere to tidy data principles (for more info see https://r4ds.had.co.nz/tidy-data.html)
###########################################

# LOAD PACKAGES AND AUTHORIZE BOX ####      

# load libraries/packages
# pacman installs any libraries that aren't already installed before loading
# boxr interfaces with Box 
# tidyverse provides many good things (check out tidyverse.org)
# rvest package allows us to scrape data/text from a web address

if (!require("pacman")) install.packages("pacman")
pacman::p_load(pacman, boxr, tidyverse, rvest)

box_auth()

# LOAD DATA ####

# Get 3-letter sight words from https://byjus.com/english/3-letter-words/

html <- read_html("https://byjus.com/english/3-letter-words/")

words <- html |> 
  html_element("table") |> 
  html_table()

# setting this seed ensures that randomization happens the same way each time
# the result of the following code generates a table with three columns of random words
# each row of the table can be used as a unique "code" for students to enter enter
# qualtrics as an "ExternalDataReference"
set.seed(123)
codes <- words |> 
  expand(X1, X2, X3)

# GENERATE OUTPUTS ####
# Outputs could be reports, data visualizations, cleaned data, etc.
# write the codes table out to a csv file that can be used to assign to students
# participating in a study
write_csv(codes, here("listofcodes.csv"))
