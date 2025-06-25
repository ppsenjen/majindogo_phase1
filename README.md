# Maji Ndogo Data Analysis - Phase 1
This document outlines the initial steps I took to explore and analyze the Maji Ndogo water services database. My primary goal was to familiarize myself with the extensive dataset of 60,000 records, understand its structure, identify key data points, and uncover any inconsistencies.

# Problem Statement
Maji Ndogo faced a significant water crisis. Despite having numerous water sources, a substantial portion of the population lacked reliable access to clean and safe water. This crisis impacted public health, economic productivity, and overall community well-being. My analysis aimed to leverage the collected water-related data to identify the root causes of these water access and quality issues, and to propose data-driven solutions to improve the water infrastructure and supply for the citizens of Maji Ndogo. I focused on understanding the types of water sources, the factors affecting their accessibility (like queue times), and the quality of the water, particularly identifying and correcting data integrity issues related to contamination.


# 1. Initial Database Exploration
I began by connecting to the md_water_services database. I then listed all available tables in the database to get an overview of its structure.

I found the following tables: data_dictionary, employee, global_water_access, location, visits, water_quality, water_source, and well_pollution.

# Exploring Key Tables
I explored some of the key tables to understand their content:

### location table: I queried the location table and observed that it detailed specific geographical data, including address, province_name, town_name, and location_type (Urban/Rural). Each location had a unique location_id.

### visits table: I examined the visits table and saw that it recorded individual visits. Each record included an assigned_employee_id, location_id, source_id, time_of_record, visit_count, and time_in_queue. This table was crucial for understanding surveyor activities and user wait times.

# 2. Water Source Analysis
I delved into understanding the different types of water sources recorded in the database.

# Types of Water Sources
I noted five main types of water sources:

- River: These were open sources where people directly collected drinking water, posing a high risk of contamination.

- Well: These sources accessed underground water, generally safer than rivers but with known issues due to past infrastructure problems.

- Shared Tap: These were public communal taps serving multiple households.

- Tap in Home: These were taps installed inside citizens' homes, typically serving a household of about six people.

- Broken Tap in Home: These were home taps where the supporting infrastructure was non-functional, meaning no water was accessible.

Learned that for tap_in_home and tap_in_home_broken records, data was aggregated. Instead of one record per household tap, data from many nearby homes was combined into a single entry. The number_of_people_served field reflected the total population served by that aggregated group of taps (e.g., a record serving 956 people represented approximately 160 homes, assuming 6 people per household). This aggregation was done to prevent system slowdowns from millions of individual records.

I retrieved the distinct types of water sources present in the water_source table.

# Unpacking Queue Times
I investigated the visits table to identify sources experiencing long queues, specifically looking for time_in_queue values of 500 minutes or more.

To determine which types of water sources experienced these long queues, I joined the water_source and visits tables on source_id. I found that shared taps were primarily the sources with extensive queue times.

# 3. Water Quality Assessment
The core purpose of the survey was to evaluate water source quality. I understood that field surveyors assigned a subjective quality score from 1 (terrible) to 10 (excellent, typically for clean home taps). Shared taps were generally not rated as highly, and queue times also influenced their scores.

Decided to test a hypothesis: surveyors only made multiple visits to shared taps, and good water sources like home taps should not have been revisited. Therefore, I expected to find no records of second visits to home taps with perfect quality scores.

I constructed a query to find records where subjective_quality_score was 10 for home taps (tap_in_home or tap_in_home_broken) that had a visit_count of 2 or more (indicating a second or subsequent visit).

Upon running this query, I observed no records were returned in my database environment. This suggested that, in my specific dataset, the hypothesis held true: perfect-scoring home taps were indeed not revisited. This contrasted with the initial problem description, which indicated such "erroneous" records existed in the original sample data (218 rows).

Also ran a query to confirm the visit_count for home taps with a perfect score. From the results of this query, I saw that all visit_count values for these home taps were 1, further confirming the absence of revisited perfect-score home taps in my dataset.

# 4. Investigating Pollution Issues and Data Integrity
I moved on to investigate the well_pollution table, which contained data on biological and chemical contaminants in wells. Each well was classified as 'Clean', 'Contaminated: Biological', or 'Contaminated: Chemical' in the results field. This classification was critical as contaminated wells were unsafe for drinking.

I started by looking at a sample of the well_pollution table.

# Data Integrity Check
Recognized the importance of data integrity, especially concerning water safety. I learned that biological contamination was measured in CFU/mL, with anything greater than 0.01 indicating contamination. I needed to identify any inconsistencies where results was marked 'Clean' but biological contamination was present.

I executed a query to find instances where results was 'Clean' but biological was greater than 0.01.

Comparing these results with the full table, I identified inconsistencies where data entry personnel seemed to have mistakenly used the description field to determine cleanliness. Specifically, if the description started with "Clean" (e.g., "Clean Bacteria: E. coli"), the results column was sometimes classified as 'Clean', even when biological contamination was above 0.01. This was incorrect, as "Clean" in the description should only appear if no biological or chemical contamination was present.

To find these specific "Clean" descriptions that were erroneous, I searched for descriptions starting with "Clean " (with a space) and where biological contamination was also present.

# Data Cleaning and Correction
I identified two main issues requiring data correction:

- Incorrect Descriptions:
The description field for some records mistakenly included "Clean" at the beginning. I needed to correct:

'Clean Bacteria: E. coli' to 'Bacteria: E. coli'.
'Clean Bacteria: Giardia Lamblia' to 'Bacteria: Giardia Lamblia'.

- Misclassified Results:
The results column contained wells incorrectly marked as 'Clean' despite having a biological contamination value greater than 0.01. I had to update these results to 'Contaminated: Biological'.

Before making changes, I created a copy of the well_pollution table as well_pollution_copy to ensure data safety during the update process.

Then, executed the UPDATE statements to fix the identified inconsistencies in the well_pollution_copy table.

After running these updates, I verified that the problematic records were no longer present in well_pollution_copy. I confirmed that this query returned no rows, indicating I had successfully corrected the identified errors in the copied table.

