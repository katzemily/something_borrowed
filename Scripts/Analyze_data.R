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
airtable_member_raw <- read_sheet(airtable_data_url, sheet = "Members")

airtable_members <- airtable_member_raw |>
  clean_names()

airtable_member_subscriptions <- airtable_members |>
  filter(subscribe == "checked") |>
  mutate(wedding_month_date = as_date(wedding_date)) |>
  select(
    email_address,
    full_name,
    state,
    city,
    comments,
    join_date,
    wedding_month_date
  )


# Then we want to start importing our data from Googlesheets so we can have it all in one place

googleform_data_raw <- read_sheet(
  ss = google_forms_url,
  sheet = "Form Responses 1"
)

googleform_data <- googleform_data_raw |>
  clean_names() |>
  rename(
    datetime_submitted = timestamp,
    state = which_state_do_you_live_in,
    city = which_city_town_do_you_live_in,
    member_type = which_best_describes_your_situation,
    wedding_month = wedding_month_if_applicable,
    wedding_year = wedding_year_if_applicable,
    comments = feel_free_to_leave_any_comments_questions_feedback_or_ideas_here,
    subscribe = check_the_box_below_to_subscribe_to_our_email_list_for_occasional_updates
  ) |>
  mutate(
    join_date = as_date(datetime_submitted),
    city = as.character(city),
    wedding_year = as.character(wedding_year),
    comments = as.character(comments)
  ) |>
  mutate(
    wedding_year = case_when(wedding_year == "NULL" ~ NA, TRUE ~ wedding_year),
    comments = case_when(comments == "NULL" ~ NA, TRUE ~ comments)
  ) |>
  mutate(
    wedding_month_date = my(paste(wedding_month, wedding_year))
  )

googleform_member_subscriptions <- googleform_data |>
  filter(subscribe == "Subscribe") |>
  select(
    email_address,
    full_name,
    state,
    city,
    comments,
    join_date,
    wedding_month_date
  )

member_subscriptions <- airtable_member_subscriptions |>
  rbind(googleform_member_subscriptions)

# pattern <- "^(\\w+)\\s+(?:.*\\s+)?(\\w+)$"

# member_subscriptions |>
#     mutate(
#     first_name = str_match(full_name, pattern)[,2],
#     last_name = str_match(full_name, pattern)[,3]
#   ) |> view()

member_upload_list <- member_subscriptions |>
  mutate(
    # Extracts the very first word in the string
    first_name = str_extract(full_name, "^\\w+"),

    # Extracts the last word ONLY if preceded by a space
    last_name = str_extract(full_name, "(?<=\\s)\\w+$")
  ) |>
  mutate(
    mutate(
      across(c(first_name, last_name), str_to_title)
    )
  ) |>
  filter(!str_detect(full_name, "TEST") | is.na(full_name)) |>
  select(
    email_address,
    first_name,
    last_name,
    city,
    state,
    wedding_month_date
  ) |>
  distinct(email_address, .keep_all = TRUE)

# Just grab the latest of these
recent_member_upload_list <- member_upload_list |>
  tail(8)


email_addresses <- member_subscriptions |>
  mutate(email_address_lower = str_to_lower(email_address)) |>
  distinct(email_address_lower)

email_subscriber_url <- "https://docs.google.com/spreadsheets/d/1QQ9pDIcqxglvA3UkhvEmU-GG7_-4YxfLl0s8__DsmYs/"

write_sheet(
  ss = email_subscriber_url,
  email_addresses,
  sheet = "Emails"
)

write_sheet(
  ss = email_subscriber_url,
  member_upload_list,
  sheet = "mar_8_upload"
)

write_sheet(
  recent_member_upload_list,
  ss = email_subscriber_url,
  sheet = "april_6_upload"
)
