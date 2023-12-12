# WestEd_R
A repository of R scripts and examples for educational researchers using R at WestEd.

## Author(s)
- Jennifer K. Houchins
- Kelly Collins
- Rosie Owen

## Last Update
- January 5, 2022: Added template for pulling data from Qualtrics to Data Wrangling.
- December 27, 2022
- December 8, 2022: Rosie added script that shows how to download SurveyMonkey data

## Navigation
The following gives a brief overview of the contents for each subdirectory.

### Data
The Data subdirectory contains data files in various formats of the mtcars generic dataset to be used in examples within the provided R scripts. No project specific data will ever reside within this repository for compliance with data security requirements.

#### Data Files

- mtcars.csv: mtcars data in .csv format
- mtcars.dta: mtcars data in .dta format (Stata's format)
- mtcars.sas7bdat: mtcars data in .sas7bdat format (SAS's format)
- mtcars.sav: mtcars data in .sav format (SPSS's format)
- mtcars.xlsx: mtcars data in .xlsx format (MS Excel format)

### Data Wrangling
The Data Wrangling subdirectory contains R scripts with examples for loading and cleaning raw data.

#### Data Wrangling Files

- importing-data.R: provide examples of how to import data from differenct filetypes/sources
- qualtrics-download.R: provides instructions for setting up a Qualtrics API and a template for downloading Qualtric data using the QualtRics package
- surveymonkey-download.R: provides an example of downloading SurveyMonkey data
