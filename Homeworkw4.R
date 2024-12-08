
library(usethis) 
#you can use this to create a github token. 

#loading the required packages 
library(here)
library(readr)
library(sf)
library(dplyr) #helpful for the "%>%" function (pretty sure it's in tidyverse)
library(tmap)
library(tidyverse)


#reading the gender inequality data
gender_inequal <- read_csv(here("Genderin.csv"))

# Read the GeoJSON file
World_count <- st_read("World_Countries.geojson")

World_count1 <- st_read(here("World_Countries.geojson"))
                        
# Print the contents
print(World_count)


# View the first few rows
head(gender_inequal)

install.packages("countrycode") #to match the country codes
library(countrycode)

data <- gender_inequal %>%
  mutate(iso2_code = countrycode(countryIsoCode, "iso3c", "iso2c")) #changing the codes so that they fit together 

#merging to create a map
inequalmap <- merge(World_count, data, by.x="ISO", 
                    by.y="iso2_code", na.rm = TRUE) #na.rm removes na values, idk if it actually works we'll see.. "cries"




# Reshape the data to wide format - we use this so we can get the differences in two different columns
data_wide <- inequalmap %>%
  pivot_wider(names_from = year, values_from = value, names_prefix = "gii_")


# Creating a new column for the difference in GII between 2019 and 2010
data <- data_wide %>%
  drop_na(gii_2019, gii_2010) %>% #removing the na values (FINALLY!!!)
  mutate(gii_difference = gii_2019 - gii_2010)

# ------  NOW WE BE MAKING MAPS ---------

# Create the map for difference
  tmap_mode("plot")
  tm_shape(data) +
    tm_fill("gii_difference", 
            palette = "RdYlGn", 
            title = "Global Inequality",
            style = "jenks",
            midpoint = NA) + 
                tm_borders() 

  #2010  
tmap_mode("plot")
  tm_shape(data) +
    tm_fill("gii_2010", 
            palette = "-RdBu", 
            title = "Gender Inequality 2010",
            style = "jenks",
            midpoint = NA) + 
    tm_borders()  

#2019
  tmap_mode("plot")
  tm_shape(data) +
    tm_basemap(server = "OpenStreetMap") +  # Add OpenStreetMap as the basemap
    tm_fill("gii_2019", 
            palette = "PuBuGn", 
            title = "Global Inequality",
            style = "jenks",
            midpoint = NA) + 
    tm_borders() 
 
# I am not sure if this will be reproducible but you can try :)

  
  