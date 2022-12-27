# FILE DESCRIPTION ####
#
# Name: importing-data.R
# Author: Jennifer K. Houchins
# Project: WestEd R scripts
# Purpose: Provide examples of loading data in R from various sources:
#         * Excel
#         * csv
#         * Stata
#         * SPSS
#         * SAS

# LOAD PACKAGES AND AUTHORIZE BOX ####

# the pacman package manager will install any libraries that haven't been 
# installed prior to loading the library (very handy)

install.packages("pacman")
pacman::p_load(pacman, tidyverse, readxl, haven, googlesheets4)

# LOAD DATA FROM EXCEL ####

# this uses the readxl package associated with the tidyverse

mtcars_excel <- read_excel("Data/mtcars.xlsx")

# LOAD DATA FROM CSV ####

# this uses the readr package which comes with the tidyverse package by default

mtcars_csv <- read_csv("Data/mtcars.csv")

# LOAD DATA FROM STATA ####

# this example as well as the next two use the haven package associated with tidyverse

mtcars_stata <- read_dta("Data/mtcars.dta")

# LOAD DATA FROM SPSS ####

mtcars_spss <- read_sav("Data/mtcars.sav")

# LOAD DATA FROM SAS ####

mtcars_sas <- read_sas("Data/mtcars.sas7bdat")
