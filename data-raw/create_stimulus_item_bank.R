

library(tidyverse)
library(itembankr)


sort_singpause_2024 <- function(df) {
  df %>%
    tibble::as_tibble() %>%
    # This is done manually now:
    #dplyr::mutate(song_name = stringr::str_replace_all(stringr::str_remove_all(midi_file, ".mid"), "_", " ")) %>%
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


create_item_bank(name = "singpause_2024",
                 input = "files",
                 output = 'item',
                 midi_file_dir = "~/songbird/inst/stimuli/midi")

# Move to current dir

file.rename(from = 'singpause_2024_file.rda', to = '~/songbird/data-raw/singpause_2024_file.rda')
file.rename(from = 'singpause_2024_item.rda', to = '~/songbird/data-raw/singpause_2024_item.rda')

load('data-raw/singpause_2024_item.rda')
singpause_item_item_bank <- item_bank


rm(item_bank)





# Phrases

create_item_bank(name = "singpause_2024_phrase",
                 input = "files_phrases",
                 output = 'item',
                 midi_file_dir = "~/songbird/inst/stimuli/midi phrases")

file.rename(from = 'singpause_2024_phrase_file.rda', to = '~/songbird/data-raw/singpause_2024_phrase_file.rda')
file.rename(from = 'singpause_2024_phrase_item.rda', to = '~/songbird/data-raw/singpause_2024_phrase_item.rda')


load('data-raw/singpause_2024_phrase_item.rda')
singpause_phrase_item_bank <- item_bank

rm(item_bank)




# Add difficulty values

singpause_item_item_bank <- singpause_item_item_bank %>%
  dplyr::as_tibble() %>%
  mutate(
    rhythmic_difficulty = singpause_item_item_bank %>%
      tibble::as_tibble() %>%
      dplyr::mutate(log_freq = 0) %>%
      Berkowitz::predict_rhythmic_difficulty()

  )

singpause_phrase_item_bank <- singpause_phrase_item_bank %>%
  dplyr::as_tibble() %>%
  mutate(
    rhythmic_difficulty = singpause_phrase_item_bank %>%
      tibble::as_tibble() %>%
      dplyr::mutate(log_freq = 0) %>%
      Berkowitz::predict_rhythmic_difficulty()

  )




# Add metadata

singpause_2024_metadata <- readxl::read_excel('~/songbird/inst/stimuli/singpause_metadata.xlsx') %>%
  # Normalise strings with umlauts
  mutate(midi_file = stringi::stri_trans_nfc(midi_file))

singpause_item_item_bank <- singpause_item_item_bank %>%
  mutate(midi_file = stringi::stri_trans_nfc(midi_file)) %>%
  dplyr::left_join(singpause_2024_metadata, by = "midi_file")

singpause_phrase_item_bank <- singpause_phrase_item_bank %>%
  mutate(midi_file = stringi::stri_trans_nfc(midi_file)) %>%
  dplyr::left_join(singpause_2024_metadata, by = "midi_file")




# Sort the item banks
singpause_item_item_bank <- singpause_item_item_bank %>%
  mutate(phrase_number = NA,
         phrase_name = NA)

singpause_phrase_item_bank <- singpause_phrase_item_bank %>%
  sort_singpause_2024() %>%
  mutate(item_id = str_remove(item_id, "_item_"))


# Add lyrics

singpause_item_item_bank <- singpause_item_item_bank %>%
  rowwise() %>%
  dplyr::mutate(lyrics = read_lyrics(paste0("~/songbird/inst/stimuli/lyrics/", lyrics_file))) %>%
  ungroup()


singpause_phrase_item_bank <- singpause_phrase_item_bank %>%
  rowwise() %>%
  dplyr::mutate(lyrics = read_lyrics(paste0("~/songbird/inst/stimuli/lyrics/", lyrics_file), remove_extra_chars = TRUE)) %>%
  ungroup()


singpause_phrase_item_bank <- singpause_phrase_item_bank %>%
  mutate(item_type = "phrase")


# Make sure item ids are formatted correctly for the phrase item bank (add an underscore)

singpause_phrase_item_bank <- singpause_phrase_item_bank %>%
  rowwise() %>%
  mutate(item_id = stringr::str_replace(item_id, "singpause_2024_phrase", "singpause_2024_phrase_")) %>%
  ungroup()






singpause_item_bank <- rbind(singpause_item_item_bank,
                             singpause_phrase_item_bank)

use_data(singpause_item_item_bank,
         singpause_phrase_item_bank,
         singpause_item_bank,
         overwrite = TRUE)


library(DBI)

db_con <- musicassessrdb::musicassessr_con()
dbWriteTable(db_con, name = 'item_bank_singpause_2024_item', value = singpause_item_item_bank, row.names = FALSE, append = FALSE, overwrite = TRUE)
dbWriteTable(db_con, name = 'item_bank_singpause_2024_phrase', value = singpause_phrase_item_bank, row.names = FALSE, append = FALSE, overwrite = TRUE)


DBI::dbDisconnect(db_con)


