# Member Joining Automation

# Need to shift from Airtable to Googlesheets because we're hitting our data limit
# Step 1: Create a google form


#### Set-up ----

library(tidyverse)
library(googlesheets4)
library(janitor)

gs4_auth(email = "sbweddingexchange@gmail.com")

google_forms_url <- "https://docs.google.com/spreadsheets/d/15pN4QckuX0a6aqLkqR502ycqGs4j6VhYhmKAAECwXww/"

airtable_data_url <- "https://docs.google.com/spreadsheets/d/1e6pj3pGx5QtBHz8Q9TvH5OmfAdJ-LPd8jGlv4WsUOUI/"


#### Import data ----

# We first want to export all of our existing data out of Airtable
airtable_member_raw <- read_sheet(airtable_data_url,
           sheet = "Members")

airtable_members <- airtable_member_raw |> 
  clean_names() 

member_subscriptions <- airtable_members |> 
  filter(subscribe == "checked") |> 
  select(email_address, full_name, state, city, comments, join_date)

# Then we want to start importing our data from Googlesheets so we can have it all in one place

googleform_data <- read_sheet(ss = google_forms_url,
           sheet = "Form Responses 1")

googleform_data |> 
  clean_names() |> 
  rename(date_submitted = timestamp,
         state = which_state_do_you_live_in,
         city = which_city_town_do_you_live_in,
         member_type = which_best_describes_your_situation,
         wedding_month = wedding_month_if_applicable,
         wedding_year = wedding_year_if_applicable,
         comments = feel_free_to_leave_any_comments_questions_feedback_or_ideas_here,
         subscribe = check_the_box_below_to_subscribe_to_our_email_list_for_occasional_updates)
