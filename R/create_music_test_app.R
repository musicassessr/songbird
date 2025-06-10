

#' Create music test app
#'
#' @param force_p_id_from_url
#' @param pre_post
#'
#' @returns
#' @export
#'
#' @examples
create_music_test_app <- function(force_p_id_from_url = FALSE,
                                  pre_post = c("pre", "post")) {

  pre_post <- match.arg(pre_post)

  tl <- extra_materials_kids()

  welcome_text <- 'Willkommen zu den Musiktests.'
  finish_text <- "Vielen Dank für deine Teilnahme! Du wirst jetzt zur App weitergeleitet."

  musicassessr::make_musicassessr_test(

    title = "SingPause",
    languages = "de",
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

        # Append entry completion
        append_completion(pre_post = "start_pre"),

        # Main timeline
        tl,

        # Append entry completion
        append_completion(pre_post)

      )
    },

    final_page = psychTestR::reactive_page(function(state, ...) {

      url_params <- psychTestR::get_url_params(state)

      if(length(url_params$dev_vs_prod) == 0L || url_params$dev_vs_prod == "dev") {
        url <- "https://singpause.dev.songbird.training"
      } else {
        url <- "https://singpause.songbird.training"
      }

      musicassessr::redirect_page(text = finish_text, url = url,ms = 2000)


    })

  )

}


append_completion <- function(pre_post) {

  psychTestR::code_block(function(state, ...) {

    singpause_user_id <- psychTestR::get_global("singpause_user_id", state)
    singpause_id <- psychTestR::get_global("singpause_username", state)

    url_params <- psychTestR::get_url_params(state)

    if(length(url_params$dev_vs_prod) == 0L || url_params$dev_vs_prod == "dev") {
      Sys.setenv("ENDPOINT_URL" = Sys.getenv("ENDPOINT_URL_DEV"))
    } else {
      url <- "https://singpause.songbird.training"
    }

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
}
