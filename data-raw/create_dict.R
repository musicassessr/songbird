

# Create a special "child-friendly German dictionary for SingPause (replacing some musicassessr translations)


library(tidyverse)
library(readxl)

setwd('~/songbird')


singpause_dict_df <- readxl::read_excel("data-raw/input/musicassessr_dict_sabeth_neue_version.xlsx",
                                           sheet = 4) %>%
  dplyr::select(-de) %>%
  dplyr::rename(de = de_children_appropriate)

insts_table2 <- musicassessr::insts_table2 %>% dplyr::select(key, en, de)
singpause_dict_df <- rbind(singpause_dict_df, insts_table2)

anyNA(singpause_dict_df)


# Join SAA dict

SAA_dict_df <- readxl::read_excel("~/SAA/data-raw/SAA.xlsx")

SAA_dict_df <- SAA_dict_df %>%
  mutate(de = case_when(is.na(de) ~ en, TRUE ~ de)) %>%
  dplyr::select(key, en, de)


singpause_dict_df <- singpause_dict_df %>%
  rbind(SAA_dict_df)


singpause_dict <- psychTestR::i18n_dict$new(singpause_dict_df)



# Internal
usethis::use_data(singpause_dict, overwrite = TRUE, internal = TRUE)


