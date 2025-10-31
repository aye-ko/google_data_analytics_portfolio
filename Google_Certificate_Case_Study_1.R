# installing necessary packages
# tidyverse for cleaning

#r markdown for documentation
install.packages("rmarkdown", dependencies = TRUE)

library(tidyverse)
library(rmarkdown)
library(ggplot2)
#load data files

trips_2019_q1 <- read_csv("Divvy_Trips_2019_Q1.csv")
trips_2020_q1 <- read_csv("Divvy_Trips_2020_Q1.csv")

#view colnames to find out why one has 2019_Q1 has 12 rows and 2020_Q1 has 13 rows

colnames(trips_2019_q1)
colnames(trips_2020_q1)

#rename 2019 colums to match 2020 naming conventions

trips_2019_q1 <- trips_2019_q1 %>%
  rename(
    ride_id = trip_id,
    started_at = start_time,
    ended_at = end_time,
    start_station_name = from_station_name,
    end_station_name = to_station_name,
    start_station_id = from_station_id,
    end_station_id = to_station_id,
    member_casual = usertype,
  )%>%
  mutate(ride_id = as.character(ride_id),
         member_casual = case_when(
           member_casual == "Subscriber" ~ "member",
           member_casual == "Customer" ~ "casual",
           TRUE ~ member_casual
         ))# change the ride_id type to combine the 2020 dataset


all_trips <- bind_rows(trips_2019_q1, trips_2020_q1) #rebind the rows

colnames(all_trips) #check that it works

rm(trips_2019_q1, trips_2020_q1) #remove extra dataset to save ram

#check for duplicates and remove them 
number_of_rows_in_all_trips <- nrow(all_trips)
all_trips <- all_trips %>%
  distinct()

duplicates_removed <- number_of_rows_in_all_trips - nrow(all_trips) 
cat("Rows before duplicate check: ", number_of_rows_in_all_trips, "\n")
cat("Rows after duplicate check: ", nrow(all_trips), "\n")
cat("Number or rows removed: ", duplicates_removed, "\n")

#create new column for ride_length = ended_at - started_at
all_trips <- all_trips %>% 
  mutate(ride_length = as.numeric(difftime(ended_at, started_at, units = "mins")))%>%
  filter(ride_length > 0) %>% # remove negative values
  select(-birthyear, -rideable_type) #remove unneeded columns

original_rows_no_negatives <- nrow(all_trips)

#remove outliers and store in outlier table

outliers <- all_trips %>%
  filter(ride_length <1 | ride_length >60) %>%
  mutate(outlier_type = case_when(
    ride_length < 1 ~ "Too_Short_a_ride",
    ride_length > 120 ~ "Possibly_Forgotten",
    ride_length > 60 ~ "Possibly_Too_Long_a_ride"
  ))

#create all_trip_clean to reflect the clean data
all_trips_clean <- all_trips %>%
  filter(ride_length>= 1 & ride_length <= 60) %>% #create a cleaner table without outliers or entry errors
  mutate(
    round_trip = start_station_name == end_station_name |
      (!is.na(start_lat) & !is.na(end_lat) & #if, start_lat, end_lat exist check it
         start_lat == end_lat & start_lng == end_lng),
    day_of_week = wday(started_at)
  ) #if start_lng, end_lng exist check it

rm(all_trips)

# Store the counts
outlier_rows <- nrow(outliers)
clean_rows <- nrow(all_trips_clean)

# Show the math
cat("Original:", original_rows_no_negatives, "\n")
cat("Outliers:", outlier_rows, "\n")
cat("Clean:", clean_rows, "\n")
cat("Sum:", outlier_rows + clean_rows, "\n")

# Check if they add up
if (outlier_rows + clean_rows == original_rows_no_negatives) {
  cat("Data split correctly! All rows accounted for.\n")
} else {
  cat("ERROR: Rows don't add up! Check your filtering.\n")
}

# Analyze Data
# Duration and Frequency:
# How long does each group ride to determine who rides the longest?
ride_length_comparison <- all_trips_clean %>%
  group_by(member_casual) %>% 
  summarize(
    avg_ride_time = mean(ride_length),
    median_ride = median(ride_length),
    total_rides = n()
  )


member_ride_time <-ride_length_comparison %>%
  filter(member_casual == "member") %>%
  pull(avg_ride_time)

casual_ride_time <- ride_length_comparison %>%
  filter(member_casual == "casual") %>%
  pull(avg_ride_time)

member_ride_count <- ride_length_comparison %>%
  filter(member_casual == "member") %>%
  pull(total_rides)

casual_ride_count <- ride_length_comparison %>%
  filter(member_casual == "casual") %>%
  pull(total_rides)

greater_ride_time_group <- if (member_ride_time > casual_ride_time) {
  "member"
} else{
  "casual"
}

greater_ride_count_group <- if (member_ride_count > casual_ride_count) {
  "member"
} else{
  "casual"
}
ride_count_difference <- if (member_ride_count > casual_ride_count) {
  member_ride_count / casual_ride_count
} else{
  casual_ride_count / member_ride_count
}
#RESULTS

cat("Members ride on average", member_ride_time, "minutes", "\n")
cat("Casuals ride on average", casual_ride_time, "minutes", "\n")
cat("The group with longer rides is", greater_ride_time_group, "\n")
cat("The group with the most rides is ", greater_ride_count_group, "at",ride_count_difference ,"times more.", "\n")

# When does each group ride the most, which time of day, what day of the week?
day_names <- c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
day_of_week_patterns <- all_trips_clean %>%
  count(day_of_week, member_casual) %>%
  mutate(day_name = day_names[day_of_week])

member_ride_weekdays <- day_of_week_patterns %>%
  filter(member_casual == "member" & (day_of_week >=2 & day_of_week <= 6) )%>%
  pull(n) %>%
  mean()

member_ride_weekends <- day_of_week_patterns %>%
  filter(member_casual == "member" & (day_of_week == 1 | day_of_week == 7 ))%>%
  pull(n) %>%
  mean()

if (member_ride_weekdays > member_ride_weekends){
  member_ride_more <- cat("Members ride on the weekdays at an average of ", member_ride_weekdays, ",",(member_ride_weekdays / member_ride_weekends), " times more.", "\n")
}  else if(member_ride_weekdays == member_ride_weekends) {
  member_ride_more <-cat("Members ride the same on weekends as weekdays on average of ", member_ride_weekends, "\n")
} else {
  member_ride_more <-cat("Members ride more on weekends at an average of ", member_ride_weekends, ",", (member_ride_weekends / member_ride_weekdays), " times more.", "\n")
}

casual_ride_weekdays <- day_of_week_patterns %>%
  filter(member_casual == "casual" & (day_of_week >=2 & day_of_week <= 6))%>%
  pull(n) %>%
  mean()

casual_ride_weekends <- day_of_week_patterns %>%
  filter(member_casual == "casual" & (day_of_week == 1 | day_of_week == 7))%>%
  pull(n) %>%
  mean()

if (casual_ride_weekdays > casual_ride_weekends){
  casual_ride_more <- cat("Casuals ride on the weekdays at an average of ", casual_ride_weekdays, ",",(casual_ride_weekdays / casual_ride_weekends), " times more.", "\n")
}  else if(casual_ride_weekdays == casual_ride_weekends) {
  casual_ride_more <-cat("Casuals ride the same on weekends as weekdays on average of ", casual_ride_weekends, "\n")
} else {
  casual_ride_more <-cat("Casuals ride more on weekends at an average of ", casual_ride_weekends, ",", (casual_ride_weekends / casual_ride_weekdays), " times more.", "\n")
}


members_peak_day <-day_of_week_patterns %>%
  filter(member_casual == "member")%>%
  filter(n==max(n)) %>%
  pull(day_of_week) 
  
casual_peak_day <-day_of_week_patterns %>%
  filter(member_casual == "casual")%>%
  filter(n==max(n)) %>%
  pull(day_of_week) 


cat("Members ride the most on ", day_names[members_peak_day], "\n" , 
    "Casuals ride more on ", day_names[casual_peak_day], "\n")
  
  
# Location Patterns:
colnames(all_trips_clean)
#	Which station is most popular to each group?
popular_stations <- all_trips_clean %>%
  count(start_station_name, member_casual) %>%
  group_by(member_casual) %>%
  slice_max(n, n=10)

popular_member_station <- popular_stations %>%
  filter(member_casual == "member") %>%
  slice_max(n, n=10)


popular_casual_station <- popular_stations %>%
  filter(member_casual == "casual") %>%
  slice_max(n, n=10)

print("Members 10 most popular stations: ")
print(popular_member_station)
print("Casual 10 most popular stations: ")
print(popular_casual_station)
#	Which group rides the farthest?
#	Which group ends at the same station the most (round_trips)
round_trip_pattern <- all_trips_clean %>%
  group_by(member_casual) %>%
  count(round_trip) %>%
  mutate(
    total = sum(n),
    percentage = (n/total) * 100
  )

casual_round_trip <- round_trip_pattern %>%
  filter(member_casual == "casual" & round_trip == TRUE) %>%
  pull(percentage)

member_round_trip <- round_trip_pattern %>%
  filter(member_casual == "member" & round_trip == TRUE) %>%
  pull(percentage)

if (member_round_trip > casual_round_trip) {
  cat("Members take more round trips at ", (member_round_trip / casual_round_trip) ,"times more, with round trips being ", member_round_trip,"% of their total trips.", "\n" )
} else {
  cat("Casuals take more round trips at ", (casual_round_trip / member_round_trip), "times more, with round trips being ", casual_round_trip,"% of their total trips.", "\n" )
}


# CONCLUSION

# This analysis revealed three key behavioral differences between casual riders and annual members:
#
# 1. DURATION VS FREQUENCY: 
#    - Casual riders take longer trips (22.6 min avg) but members ride 12x more frequently
#    - This suggests different use cases: casuals for leisure, members for transportation

# 2. TIMING PATTERNS:
#    - Members peak on weekdays (127k rides on Tuesday), casuals peak on weekends (15k on Sunday)
#    - Members ride 2x more on weekdays vs weekends, casuals ride 2x more on weekends vs weekdays
#    - This confirms: members = commuters, casuals = recreational riders
#
# 3. ROUND TRIP BEHAVIOR:
#    - Casuals take round trips 8.8x more often (12.1% vs 1.4%)
#    - Supports the leisure vs commute hypothesis - casuals explore and return, members go point-to-point

# BUSINESS RECOMMENDATION:
# Marketing campaigns to convert casuals to annual members face a fundamental challenge: the two groups
# use bikes for entirely different purposes. Strategies should either:
#   A) Emphasize value propositions for occasional leisure use (weekend passes, seasonal pricing)
#   B) Encourage behavioral change by showing how bikes can replace short commutes
#   C) Create tiered membership options that better match casual usage patterns


# VISUALIZATIONS

# Visualization 1: Average Ride Duration by Group
ggplot(ride_length_comparison, aes(x = member_casual, y = avg_ride_time, fill = member_casual)) +
  geom_col() +
  labs(
    title = "Average Ride Duration: Casual vs Member",
    x = "Rider Type",
    y = "Average Duration (minutes)",
    fill = "Rider Type"
  ) +
  theme_minimal() +
  scale_fill_manual(values = c("casual" = "#FF6B6B", "member" = "#4ECDC4"))


# Visualization 2: Rides by Day of Week

ggplot(day_of_week_patterns, aes(x = day_name, y = n, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Ride Patterns Throughout the Week",
    x = "Day of Week",
    y = "Number of Rides",
    fill = "Rider Type"
  ) +
  theme_minimal() +
  scale_fill_manual(values = c("casual" = "#FF6B6B", "member" = "#4ECDC4")) +
  scale_x_discrete(limits = day_names)+
  scale_y_continuous(labels = scales::label_number( scale = 1/1000, suffix = "K"))

# Visualization 3: Round Trip Percentage Comparison

round_trip_viz <- round_trip_pattern %>%
  filter(round_trip == TRUE)

ggplot(round_trip_viz, aes(x = member_casual, y = percentage, fill = member_casual)) +
  geom_col() +
  labs(
    title = "Percentage of Trips That Are Round Trips",
    x = "Rider Type",
    y = "Percentage of Total Rides",
    fill = "Rider Type"
  ) +
  theme_minimal() +
  scale_fill_manual(values = c("casual" = "#FF6B6B", "member" = "#4ECDC4")) +
  geom_text(aes(label = paste0(round(percentage, 1), "%")), vjust = -0.5)

#Visualization 4: Total Rides Comparison

ggplot(ride_length_comparison, aes(x= member_casual , y = total_rides , fill = member_casual)) +
  geom_col() +
  labs(
    title = "Total Number of Rides: Casual vs Member",
    x = "Rider Type",
    y = "Total Rides",
    fill = "Rider Type"
  ) +
  theme_minimal() +
  scale_fill_manual(values = c("casual" = "#FF6B6B", "member" = "#4ECDC4")) +
  scale_y_continuous(labels = scales::label_number(scale = 1/1000, suffix = "K")) +
  geom_text(aes(label = scales::comma(total_rides)), vjust = -0.5)