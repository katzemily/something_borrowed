# Member Joining Automation

# Need to shift from Airtable to Googlesheets because we're hitting our data limit
# Step 1: Create a google form


#### Set-up ----

library(tidyverse)
library(googlesheets4)
library(janitor)

gs4_auth(email = "sbweddingexchange@gmail.com")

spreadsheet_url <- "https://docs.google.com/spreadsheets/d/15pN4QckuX0a6aqLkqR502ycqGs4j6VhYhmKAAECwXww/"


#### Import data ----

# We first want to export all of our existing data out of Airtable

# Then we want to start importing our data from Googlesheets so we can have it all in one place

googleform_data <- read_sheet(ss = spreadsheet_url,
           sheet = "Form Responses 1")

googleform_data |> 
  clean_names() |> 
  rename(date_submitted = timestamp,
         state = which_state_do_you_live_in,
         city = which_city_town_do_you_live_in,
         )
