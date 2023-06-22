# Load libraries
library(conflicted)
library(dplyr)
library(jsonlite)
library(readr)
library(tidyverse)

# Set query URL
## Return: Ambient nature songs to create a sensory, reflective soundspace experience that adds insight into the natural world, human existence, and the intersection between the two. Maori natural world influences.
## Reference: iTune Genre CSV https://gist.github.com/jpmurray/975fda3ce15d48bbc877 
query <- "https://itunes.apple.com/search?term=ambient%2Bnature&explicit=No&entity=song&media=music&limit=200"

# Add a description of the desired mood or feeling
query <- paste0(query, "&attribute=moodTerm&term=Peaceful")
query <- paste0(query, "&attribute=moodTerm&term=Reflective")

# Specify cultural influence for the songs
query <- paste0(query, "&attribute=musicTerm&term=Māori")

# Specify natural influences for the songs
query <- paste0(query, "&attribute=musicTerm&term=Nature")

# Limit results to instrumental tracks only
query <- paste0(query, "&attribute=songTerm&term=Instrumental")

# Fetch initial playlist data from iTunes API
responses <- fromJSON(query)
initial_playlist <- responses[["results"]]

# View initial playlist
view(initial_playlist)

# Select first 20 songs from the initial playlist
my_playlist <- initial_playlist %>%
  slice(1:20)

# Extract artwork URLs
artwork_urls <- my_playlist %>%
  select(artworkUrl30) %>%
  pull(artworkUrl30) %>%
  unique()

# Rename columns and select specific variables
my_playlist <- initial_playlist %>%
  slice(1:20) %>%
  select(artistId:isStreamable) %>%
  rename(comments = additional_info, genre = primaryGenreName)

# Add track name length and lowercase track name variables
my_playlist <- my_playlist %>%
  mutate(track_name_length = nchar(trackName),
         track_name_lower = tolower(trackName))

# Filter songs with sentiment "joy" and title containing "Happy"
my_playlist <- my_playlist %>%
  filter(str_detect(sentiment_joy, "joy"), str_detect(trackName, "Happy"))

# Filter songs with title containing "sun"
sun_songs <- my_playlist %>%
  filter(str_detect(trackName, "sun"))

# Sort playlist by trackId
sort_trackId <- my_playlist %>%
  arrange(trackId)

# Save my_playlist as a local CSV file
write_csv(my_playlist, "./my_playlist.csv")

# Summarize playlist by genre
playlist_summary <- my_playlist %>%
  group_by(genre) %>%
  summarise(num_songs = n())

# View playlist summary
view(playlist_summary)