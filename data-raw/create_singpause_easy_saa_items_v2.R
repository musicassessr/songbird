
library(DBI)
library(tidyverse)
library(musicassessr)

Berkowitz_subset <- Berkowitz::ngram_item_bank %>%
  tibble::as_tibble() %>%
  dplyr::filter(rhythmic_difficulty_percentile <= 2,
                arrhythmic_difficulty_percentile <= 2,
                N < 10) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(max_no_repeated_notes = max(rle(itembankr::str_mel_to_vector(abs_melody))$lengths) ) %>%
  dplyr::ungroup() %>%
  filter(max_no_repeated_notes <= 3,
         mean_duration > 0.4) %>%
  rowwise() %>%
  mutate(total_duration = sum(itembankr::str_mel_to_vector(durations), na.rm = TRUE),
         min_duration = min(itembankr::str_mel_to_vector(durations), na.rm = TRUE),
         max_duration = max(itembankr::str_mel_to_vector(durations), na.rm = TRUE)
         ) %>%
  ungroup() %>%
  filter(total_duration > 2,
         min_duration > 0.15,
         max_duration < 1.5)

# Filter for min and max duration as well (e.g.,  0.15 < x  < 1.5 seconds)



hist(Berkowitz_subset$max_no_repeated_notes)

hist(Berkowitz_subset$N)

summary(Berkowitz_subset$N)



db_con <- musicassessrdb::musicassessr_con()
#db_con <- musicassessrdb::musicassessr_con(db_name = "melody_prod")

dbWriteTable(db_con, name = 'item_bank_Berkowitz_songbird', value = Berkowitz_subset, row.names = FALSE, append = FALSE, overwrite = TRUE)


tt <- tbl(db_con, "item_bank_Berkowitz_songbird") %>% collect()

nrow(tt)

musicassessrdb::db_disconnect(db_con)


hist(tt$N)

summary(tt$N)

