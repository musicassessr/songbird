
load_all()

future::plan(future::multisession)

psychTestR::I18N_STATE$set(dict = musicassessr::musicassessr_dict,
                           lang = "de")



create_questionnaire_app(type = "kids",
                         pre_post = "pre",
                         extra_materials = extra_materials_kids)

# create_questionnaire_app(type = "teachers", pre_post = "pre")

# create_questionnaire_app(type = "parents", pre_post = "pre", extra_materials = extra_materials_parents)
