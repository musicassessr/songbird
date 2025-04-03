
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
        shiny::tags$p("Jetzt wirst du zu einem Gesangstest übergehen.")
      ),
      button_text = "Weiter"
    ),

    SAA::SAA(
      skip_setup = "except_microphone",
      app_name = "singpause-pretest-questionnaire-kids",
      # num_items = list(e
      #   "long_tones" = 6L,
      #   "arrhythmic" = 8L,
      #   "rhythmic" = 8L
      # ),
      default_range = list(bottom_range = 47, top_range = 72, clef = "treble"),
      get_answer_melodic = musicassessr::get_answer_add_trial_and_compute_trial_scores_s3,
      num_items = list(
        "long_tones" = 2L,
        "arrhythmic" = 2L,
        "rhythmic" = 2L
      ),
      asynchronous_api_mode = TRUE,
      user_id = 147L # PRETEST: melody_dev: 147L, melody_prod: 186L;;; POSTTEST: melody_dev: 148L, melody_prod: 187L
    )
  )
}

extra_materials_kids <- function() {
  psychTestR::randomise_at_run_time(
  label = "randomised_order",
  list(

    psyquest::CCM(),

    SAA_plus(),

    mdt::mdt(num_items = 2L),

    mpt::mpt(num_items = 2L),

    RAT::RAT(num_items = 2L),

    JAJ::JAJ(num_items = 2L)

  )
  )
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

    psyquest::TPI()

  )
}

