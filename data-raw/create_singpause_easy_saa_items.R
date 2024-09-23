
library(DBI)
library(tidyverse)

Berkowitz_bottom_5 <- Berkowitz::ngram_item_bank %>%
  tibble::as_tibble() %>%
  filter(rhythmic_difficulty_percentile <= 5,
         arrhythmic_difficulty_percentile <= 5,
         N < 10)

hist(Berkowitz_bottom_5$N)

summary(Berkowitz_bottom_5$N)



db_con <- musicassessrdb::musicassessr_con()

dbWriteTable(db_con, name = 'item_bank_Berkowitz_bottom_5th_percentile', value = Berkowitz_bottom_5, row.names = FALSE, append = FALSE, overwrite = TRUE)


tt <- tbl(db_con, "item_bank_Berkowitz_bottom_5th_percentile") %>% collect()

DBI::dbDisconnect(db_con)

nrow(tt)


hist(tt$N)

summary(tt$N)

