
turn_on_upload_to_s3_mode <- function(log = FALSE) {
  scr <- "upload_to_s3 = true;"
  if(log) {
    scr <- paste0(scr, " console.log('Turning S3 mode on');")
  }
  shiny::tags$script(scr)
}

SAA_plus <- function() {
  psychTestR::join(
    psychTestR::one_button_page(
      shiny::tags$div(
        turn_on_upload_to_s3_mode(TRUE),
        shiny::tags$p("Es geht los mit einem Gesangstest.")
      ),
      button_text = "Weiter"
    ),

    SAA::SAA(
      arrhythmic_item_bank = songbird::Berkowitz_subset %>% itembankr::set_item_bank_class(),
      rhythmic_item_bank = songbird::Berkowitz_subset %>% itembankr::set_item_bank_class(),
      skip_setup = "except_microphone",
      app_name = "singpause-pretest-questionnaire-kids",
      demographics = FALSE,
      gold_msi = FALSE,
      concise_wording = TRUE,
      long_tone_paradigm = "call_and_response",
      volume_meter_on_melody_trials = FALSE,
      volume_meter_on_melody_trials_type = 'playful',
      long_tone_length = 3L,
      num_examples = list(
        "long_tones" = 1L,
        "arrhythmic" = 1L,
        "rhythmic" = 0L
      ),
      num_items = list(
        "long_tones" = 4L,
        "arrhythmic" = 5L,
        "rhythmic" = 5L
      ),
      long_tone_call_and_response_end = "auto",
      default_range = list(bottom_range = 62, top_range = 74, clef = "treble"),
      get_answer_melodic = musicassessr::get_answer_add_trial_and_compute_trial_scores_s3,
      asynchronous_api_mode = TRUE,
      use_presigned_url = FALSE,
      user_id = 147L # PRETEST: melody_dev: 147L, melody_prod: 186L;;; POSTTEST: melody_dev: 148L, melody_prod: 187L
    )
  )
}

extra_materials_kids <- function(production = FALSE) {

    tl <- list(

      SAA_plus(),

      mdt::mdt(num_items = 15L),

      RAT::RAT(take_training = TRUE,
               num_items = 8L,
               feedback = NULL),

      psychTestR::one_button_page(body = "Jetzt kommt der letzte Test. Gleich hast Du es geschafft!",
                                  button_text = "Weiter"),

      psychTestR::NAFC_page(label = "do_jaj",
                            prompt = shiny::tags$div(
                              shiny::tags$p("Bist Du bereit, zum Abschluss noch einen kurzen, kniffligen Gedächtnistest mit Johann und Johanna zu absolvieren? Das wäre toll! Danach hast Du es geschafft!"),
                              shiny::tags$img(src = "https://www.gold.ac.uk/media/images-by-section/about-us/news/press-office/2022-news-stories/Jack-Jill-960.png")
                              ), choices = c("Ja, zum Gedächtnistest", "Nein, direkt weiter zur App")),


      psychTestR::conditional(function(state, ...) {
        answer <- psychTestR::answer(state)
        logging::loginfo("answer: %s", answer)
        answer == "Ja, zum Gedächtnistest"
      },  JAJ::JAJ(num_items = 5L, feedback = NULL) )


      #mpt::mpt(num_items = 15L)


    )

    # if(production) {
    #   tl <- psychTestR::randomise_at_run_time(
    #     label = "randomised_order",
    #     tl
    #   )
    # }

    return(tl)
}


extra_materials_parents <- function() {
  psychTestR::join(

    psychTestR::one_button_page(shiny::tags$div(
      shiny::tags$p(
        shiny::tags$strong(
          "Achtung: Bitte beantworten Sie die folgenden Fragen im Namen Ihres Kindes."
        )
      )
    ), button_text = "Weiter"),

    psyquest::TPI(languages = "de_f")

  )
}

