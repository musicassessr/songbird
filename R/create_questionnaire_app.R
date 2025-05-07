
#  devtools::install_github('musicassessr/songbird', ref = 'devel')

# create_questionnaire_app(type = "kids", pre_post = "pre")
# create_questionnaire_app(type = "parents", pre_post = "pre")
# create_questionnaire_app(type = "teachers", pre_post = "pre")




#' Create questionnaire app
#'
#' @param tl
#' @param force_p_id_from_url
#' @param type
#' @param pre_post
#' @param img_dir
#' @param extra_materials
#'
#' @returns
#' @export
#'
#' @examples
create_questionnaire_app <- function(tl,
                                     force_p_id_from_url = FALSE,
                                     type = c("kids", "parents", "teachers"),
                                     pre_post = c("pre", "post"),
                                     img_dir = system.file("data-raw/questionnaires/www/img", package = "songbird"),
                                     extra_materials = NULL) {

  shiny::addResourcePath(
    prefix = "img", # custom prefix that will be used to reference your directory
    directoryPath = img_dir # path to resource in your package
  )

  type <- match.arg(type)
  pre_post <- match.arg(pre_post)

  stopifnot(
    type %in% c("kids", "parents", "teachers"),
    pre_post %in% c("pre", "post")
  )

  if(!is.null(extra_materials)) {
    tl <- psychTestR::join(
      extra_materials,
      tl
    )
  }

  if(type == "kids") {
    lang <- "de"
    welcome_text <- 'Liebe Schülerin, lieber Schüler, im Folgendem werden wir Dir einige kurze Frage stellen. Beantworte sie einfach ganz spontan und so wie Du Dich gerade fühlst. Es gibt kein Richtig oder Falsch. Klicke bitte auf "Weiter", um zu beginnen.'
    finish_text <- "Vielen Dank für deine Teilnahme! Du wirst jetzt zur App weitergeleitet."
  } else if(type == "parents") {
    lang <- "de_f"
    welcome_text <- 'Liebe Eltern, im Folgendem werden wir Ihnen einige kurze Frage stellen. Beantworten Sie einfach diese ganz spontan und so wie Sie sich gerade fühlen. Es gibt kein Richtig oder Falsch. Klicken Sie bitte auf "Weiter", um zu beginnen.'
    finish_text <- "Vielen Dank für Ihre Teilnahme! Sie werden jetzt zur App weitergeleitet."
  } else if(type == "teachers") {
    lang <- "de_f"
    welcome_text <- 'Liebe Singleiter:in, im Folgendem werden wir Ihnen einige kurze Frage stellen. Beantworten Sie diese einfach ganz spontan und so wie Sie sich gerade fühlen. Es gibt kein Richtig oder Falsch. Klicken Sie bitte auf "Weiter", um zu beginnen.'
    finish_text <- "Vielen Dank für Ihre Teilnahme! Sie werden jetzt zur App weitergeleitet."
  }

  musicassessr::make_musicassessr_test(

    title = "SingPause",
    languages = lang,
    admin_password = "ilikecheesepie432",
    researcher_email = NULL, # We can't translate the text
    logo = "https://musicassessr.com/assets/songbird_logo.png",
    logo_height = "70px",
    logo_width = "190px",
    logo_position = "left",
    allow_any_p_id_url = TRUE,
    force_p_id_from_url = force_p_id_from_url,

    opt = musicassessr::musicassessr_opt(asynchronous_api_mode = TRUE,
                                         user_id = 147L, # PRETEST: melody_dev: 147L, melody_prod: 186L;;; POSTTEST: melody_dev: 148L, melody_prod: 187L
                                         setup_pages = FALSE,
                                         use_presigned_url = FALSE,
                                         async_success_msg = "Lasst uns beginnen."
                                         ),

    # Grab URL parameters
    welcome_page = psychTestR::reactive_page(function(state, ...) {

        url_params <- psychTestR::get_url_params(state)
        psychTestR::set_global("singpause_user_id", url_params$user_id, state)
        psychTestR::set_global("singpause_username", url_params$username, state)

        psychTestR::one_button_page(welcome_text, button_text = "Weiter")

      }),

    elts = function() {
      psychTestR::join(

      # Main timeline
      tl,

      # Append entry completion

      psychTestR::code_block(function(state, ...) {

        singpause_user_id <- psychTestR::get_global("singpause_user_id", state)
        singpause_id <- psychTestR::get_global("singpause_username", state)

        session_info <- psychTestR::get_session_info(state, complete = FALSE)
        psychTestR_session_id <- session_info$p_id

        logging::loginfo("singpause_user_id: %s", singpause_user_id)
        logging::loginfo("singpause_id: %s", singpause_id)
        logging::loginfo("psychTestR_session_id: %s", psychTestR_session_id)

        if(length(singpause_user_id) > 0L && length(singpause_id) > 0L && length(psychTestR_session_id) > 0L) {
          musicassessrdb::append_singpause_survey_completion_api(user_id = singpause_user_id,
                                                                 singpause_id = singpause_id, # Same as username in users
                                                                 psychTestR_id = psychTestR_session_id,
                                                                 type = paste0(pre_post, "test"))
        }

      })

      )
    },

    final_page = psychTestR::reactive_page(function(state, ...) {

      url_params <- psychTestR::get_url_params(state)

      if(length(url_params$dev_vs_prod) == 0L || url_params$dev_vs_prod == "dev") {
        url <- "https://singpause.dev.songbird.training"
      } else {
        url <- "https://singpause.songbird.training"
      }

      musicassessr::redirect_page(text = finish_text,
                                  url = url,ms = 2000)


    })

  )

}
