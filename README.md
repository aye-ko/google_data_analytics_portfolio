# google_data_analytics_portfolio
**Goal: **

Maximize the number of annual memberships by converting casual riders into yearly members. 

**Audience:**

•	Manager responsible for the development of campaigns and initiatives to promote the bike-share program.
•	Analytics team (Me)
•	Executive Team – Detail-oriented executive who will decide whether to approve the recommended marketing program.


**Current State:**

Cyclistic currently relies on building general awareness and appealing to broad consumer segments. 
Has three tiers of passes: Single Ride, Full Day, and Annual Ride. 

Casual Riders: Anyone who purchases a single-ride pass or a full-day pass.

Annual Members: Purchase yearly memberships.

Finance Analysts say Annual Members are most profitable, and key to future growth. 

Manager notes that casual riders are already aware of the program and have chosen Cyclistic for their mobility needs.

The manager's goal is to design a marketing strategy that converts casual riders into annual members.  By identifying members who spend = or > annual membership prices and informing them of how much they would save.  Highlight the time saved due to traffic and how much time they would save, and cite health benefits. 

**Ask:**

How do annual members use bikes differently from casual riders?
Why would Casual riders buy a yearly membership?
How can Cyclistic use digital media to influence casual riders to become members?  


What is the problem to solve?  
Converting casual riders into Annual Members. 

Business Task: Show the difference in how annual members use the bikes compared to casual members.  
 
Consider the Key Stakeholders	Marketing Manager. 
Detail-oriented Executives.


**Prepare:**

Guiding Questions: 

Where is the data located?

https://www.kaggle.com/datasets/onyedikako/divvy-trips
**ORIGINAL DATASET:** https://divvy-tripdata.s3.amazonaws.com/index.html
(Houses all Quarterly Reports)

Does the data ROCCC?
ROCCC
Reliability- 
Since it is a company report.
Original-
This is company data—first party from the Cyclistic company archives. 
Comprehensive- 
It is not comprehensive due to privacy restrictions on customer data and credit card statements. 

Current – 
Data is not real-time.

Cited –

It is sourced from the company archives, so it is well-cited. 

Key Tasks: 
How do I download and store the data?
Determine the credibility of the data.

How do I identify if it's organized?
Sort and filter the data?	I will download the Data from the Divvy Website. 

Data is from a credible source.

I will use R to sort and filter the data.

Deliverable: 
A description of all data sources. 
The Data is from Divvy Quarter reports. 

Limitations of Data:
What are the limits of the analysis? The data does not include individual riders' usage.  Therefore, the data will focus on aggregate groups rather than individual patterns. 

**Process**

Tools: Use R Studio to clean, organize, and visualize the data. 
Ensure Data Integrity: Keep a backup of the original raw data
Work only on copies of the data
Steps to clean the data:

•	Remove null spaces
•	Check for spelling errors.
•	Trim extra spaces
•	Format the time to be in the HH:MM: SS
•	Create a new column called ride_length to track the average ride_length of each group by subtracting the started_at from the ended_at.
•	Ensure times are in minutes across the board
•	Filter columns with the same start and end station as round_trips and store them in a new column
•	Create a column called day_of_week and calculate the day of the week that each ride starts, 1= Sunday and 7= Saturday
•	Organize data into temporary tables
•	Create outlier_table for rides < 1 minute or > 60 minutes and > 120 minutes user probably forgot to return the bike. Compare which group falls mostly into these tables and hypothesize why.

Verify Data is Clean and Ready to Analyze:

•	Check for duplicate rows.
•	Check for null values
•	Check for the  appropriate length of values in each column
•	Check if start times and end times make sense (end times cannot be less than start times. 
•	Check for outliers like < 1 minute or > 120 minutes
•	Flag outliers for analysis, for instance, to determine who cancels more, who keeps the bike the longest, and add them to a new table
•	Run summary statistics like min, max, and  mean values
•	Check for ride times that are impossibly short or long

Document Cleaning Process:
Use R Markdown to document the whole process

Key Task:
Check the data for errors

**Analyze**

What will I calculate: 

Duration and Frequency:
•	How long does each group ride?
•	How often does each group ride?
•	Which group rides for the longest time?
•	When does each group ride the most, which time of day, and what day of the week?
•	Which group rides the most on holidays? 


Location Patterns:
•	Which station is most popular for each group?
•	Which group rides the farthest?
•	Which group ends at the same station the most (round_trips)
•	What percentage of rides are round-trip?
•	What percentage of rides are one-way? 
•	For one-way rides, average ride length per group. 

Outliers:
•	Which group falls the most into the outlier table?

Is the Data properly formatted?	
Suprises	
Trends	
Insights	

Key Task:
•	Aggregate data so it is valuable and accessible
•	Organize and format your data
•	Perform calculations
•	Identify trends and relationships

Deliverable:
A description of all data sources.
Data is from Divvy Quarter reports. 

Limitations of Data:
What are the limits of the analysis? 
The data does not include individual riders' usage.  Therefore, the data will focus on aggregate groups rather than individual patterns. 

