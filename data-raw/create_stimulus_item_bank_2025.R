

library(tidyverse)
library(itembankr)


sort_singpause_2025 <- function(df) {
  df %>%
    tibble::as_tibble() %>%
    # This is done manually now:
    group_by(song_name) %>%
    mutate(phrase_number = dplyr::row_number(),
           phrase_name = paste0("Phrase ", phrase_number, ", ", song_name) ) %>%
    ungroup()
}


read_lyrics <- function(f, remove_extra_chars = FALSE) {

  logging::loginfo("Reading lyrics file: %s", f)

  lines <- readLines(f, warn = FALSE)

  # Combine the lines into a single character string
  text <- paste(lines, collapse = "\n")

  if(remove_extra_chars) {
    text <- str_remove(text, " ->.*")
  }

  return(text)
}


# Phrases

# debug(itembankr::midi_file_to_notes_and_durations)

# debug(tuneR::readMidi)

# t <- itembankr::midi_file_to_notes_and_durations("~/songbird/inst/stimuli_2025/midi_phrases/04_Drahtesel_3.mid")

# midi_files <- list.files(path = "~/songbird/inst/stimuli_2025/midi_phrases/", pattern = "\\.midi$|\\.mid$",  full.names = TRUE, ignore.case = TRUE)


create_item_bank(name = "singpause_2025_phrase",
                 input = "files_phrases",
                 output = 'item',
                 remove_redundancy = FALSE,
                 remove_melodies_with_only_repeated_notes = FALSE,
                 midi_file_dir = "~/songbird/inst/stimuli_2025/midi_phrases")

create_item_bank(name = "singpause_2025_item",
                 input = "files_phrases",
                 output = 'item',
                 remove_redundancy = FALSE,
                 remove_melodies_with_only_repeated_notes = FALSE,
                 midi_file_dir = "~/songbird/inst/stimuli_2025/midi")


file.rename(from = 'singpause_2025_phrase_file.rda', to = '~/songbird/data-raw/singpause_2025_phrase_file.rda')
file.rename(from = 'singpause_2025_phrase_item.rda', to = '~/songbird/data-raw/singpause_2025_phrase_item.rda')

file.rename(from = 'singpause_2025_item_file.rda', to = '~/songbird/data-raw/singpause_2025_item_file.rda')
file.rename(from = 'singpause_2025_item_item.rda', to = '~/songbird/data-raw/singpause_2025_item_item.rda')


load('data-raw/singpause_2025_phrase_item.rda')
singpause_phrase_item_bank <- item_bank

rm(item_bank)


load('data-raw/singpause_2025_item_item.rda')
singpause_item_item_bank <- item_bank

rm(item_bank)



singpause_phrase_item_bank <- singpause_phrase_item_bank %>%
  dplyr::as_tibble() %>%
  mutate(
    rhythmic_difficulty = singpause_phrase_item_bank %>%
      tibble::as_tibble() %>%
      dplyr::mutate(log_freq = 0) %>%
      Berkowitz::predict_rhythmic_difficulty()

  )


singpause_item_item_bank <- singpause_item_item_bank %>%
  dplyr::as_tibble() %>%
  mutate(
    rhythmic_difficulty = singpause_item_item_bank %>%
      tibble::as_tibble() %>%
      dplyr::mutate(log_freq = 0) %>%
      Berkowitz::predict_rhythmic_difficulty()

  )




# Add metadata

singpause_2025_metadata <- readxl::read_excel('~/songbird/inst/stimuli_2025/singpause_metadata_2025.xlsx') %>%
  # Normalise strings with umlauts
  mutate(midi_file = stringi::stri_trans_general(midi_file, "Latin-ASCII"),
         lyrics_file = stringi::stri_trans_general(lyrics_file, "Latin-ASCII"),
         audio_file = stringi::stri_trans_general(audio_file, "Latin-ASCII")
         ) %>%
  filter(!is.na(song_name))

singpause_phrase_item_bank <- singpause_phrase_item_bank %>%
  mutate(midi_file = stringi::stri_trans_nfc(midi_file)) %>%
  dplyr::left_join(singpause_2025_metadata, by = "midi_file")


singpause_item_item_bank <- singpause_item_item_bank %>%
  mutate(midi_file = stringi::stri_trans_nfc(midi_file)) %>%
  dplyr::left_join(singpause_2025_metadata, by = "midi_file")




# Sort the item banks
singpause_phrase_item_bank <- singpause_phrase_item_bank %>%
  sort_singpause_2025() %>%
  mutate(item_id = str_remove(item_id, "_item_"))



# Add lyrics

singpause_phrase_item_bank <- singpause_phrase_item_bank %>%
  rowwise() %>%
  dplyr::mutate(lyrics = read_lyrics(paste0("~/songbird/inst/stimuli_2025/lyrics_phrases/", lyrics_file), remove_extra_chars = TRUE)) %>%
  ungroup()


singpause_phrase_item_bank <- singpause_phrase_item_bank %>%
  mutate(item_type = "phrase")


# Make sure item ids are formatted correctly for the phrase item bank (add an underscore)

singpause_phrase_item_bank_2025 <- singpause_phrase_item_bank %>%
  rowwise() %>%
  mutate(item_id = stringr::str_replace(item_id, "singpause_2025_phrase", "singpause_2025_phrase_")) %>%
  ungroup()

rm(singpause_phrase_item_bank)


# Get names right
singpause_item_item_bank_2025 <- singpause_item_item_bank %>%
  mutate(item_id = str_replace(item_id, "item_item", "item"))





use_data(singpause_phrase_item_bank_2025,
         singpause_item_item_bank_2025,
         overwrite = TRUE)


library(DBI)

# Create a (dummy) item item bank


# Dev


db_con <- musicassessrdb::musicassessr_con(db_name = "melody_dev")

dbWriteTable(db_con, name = 'item_bank_singpause_2025_phrase', value = singpause_phrase_item_bank_2025, row.names = FALSE, append = FALSE, overwrite = TRUE)
dbWriteTable(db_con, name = 'item_bank_singpause_2025_item', value = singpause_item_item_bank_2025, row.names = FALSE, append = FALSE, overwrite = TRUE)


musicassessrdb::db_disconnect(db_con)


# Prod


db_con <- musicassessrdb::musicassessr_con(db_name = "melody_prod")

dbWriteTable(db_con, name = 'item_bank_singpause_2025_phrase', value = singpause_phrase_item_bank_2025, row.names = FALSE, append = FALSE, overwrite = TRUE)
dbWriteTable(db_con, name = 'item_bank_singpause_2025_item', value = singpause_item_item_bank_2025, row.names = FALSE, append = FALSE, overwrite = TRUE)


musicassessrdb::db_disconnect(db_con)

# gamifyr::scp_up('~/songbird/inst/stimuli_2025/image')

