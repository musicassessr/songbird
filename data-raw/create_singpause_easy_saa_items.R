
library(DBI)
library(tidyverse)

Berkowitz_bottom_10 <- Berkowitz::ngram_item_bank %>%
  tibble::as_tibble() %>%
  filter(rhythmic_difficulty_percentile < 10)


db_con <- musicassessrdb::musicassessr_con()
dbWriteTable(db_con, name = 'item_bank_Berkowitz_bottom_10th_percentile', value = Berkowitz_bottom_10, row.names = FALSE, append = FALSE, overwrite = TRUE)

DBI::dbDisconnect(db_con)
