
#  devtools::install_github('musicassessr/songbird', ref = 'devel')

# create_questionnaire_app(type = "kids", pre_post = "pre")
# create_questionnaire_app(type = "parents", pre_post = "pre")
# create_questionnaire_app(type = "teachers", pre_post = "pre")




#' Create questionnaire app
#'
#' @param force_p_id_from_url
#' @param type
#' @param pre_post
#' @param img_dir
#'
#' @returns
#' @export
#'
#' @examples
create_questionnaire_app <- function(force_p_id_from_url = FALSE,
                                     type = c("kids", "parents", "teachers"),
                                     pre_post = c("pre", "post"),
                                     img_dir = system.file("data-raw/questionnaires/www/img", package = "songbird")) {

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

  if(pre_post == "pre") {

    if(type == "kids") {
      tl <- kids_tl_pretest
    }
    if(type == "parents") {
      tl <- parents_tl_pretest
    }
    if(type == "teachers") {
      tl <- teachers_tl_pretest
    }

  } else {
    # post test TLs...
  }

  psychTestR::make_test(
    opt = psychTestR::test_options(
      title = "SingPause",
      admin_password = "ilikecheesepie432",
      researcher_email = "sebsilas@gmail.com",
      logo = "https://musicassessr.com/assets/songbird_logo.png",
      logo_height = "70px",
      logo_width = "190px",
      logo_position = "left",
      allow_any_p_id_url = TRUE,
      force_p_id_from_url = force_p_id_from_url,
      enable_admin_panel = FALSE,
      display = psychTestR::display_options(css = c("https://musicassessr.com/assets/css/style_songbird.css",
                                                    system.file('www/css/musicassessr.css', package = 'musicassessr') ) )
    ),

    elts = psychTestR::join(

                            # Grab URL parameters

                            psychTestR::reactive_page(function(state, ...) {

                              url_params <- psychTestR::get_url_params(state)
                              psychTestR::set_global("singpause_user_id", url_params$user_id, state)
                              psychTestR::set_global("singpause_username", url_params$username, state)

                              psychTestR::one_button_page('Liebe Schülerin, lieber Schüler, im Folgendem werden wir Dir einige kurze Frage stellen. Beantworte sie einfach ganz spontan und so wie Du Dich gerade fühlst. Es gibt kein Richtig oder Falsch. Klicke bitte auf "Weiter" um zu beginnen.', button_text = "Weiter")

                            }),

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

                            }),

                            psychTestR::reactive_page(function(state, ...) {

                              url_params <- psychTestR::get_url_params(state)

                              if(length(url_params$dev_vs_prod) == 0L || url_params$dev_vs_prod == "dev") {
                                url <- "https://singpause.dev.songbird.training"
                              } else {
                                url <- "https://singpause.songbird.training"
                              }

                              musicassessr::redirect_page(text = "Vielen Dank für deine Teilnahme! Du wirst jetzt zur App weitergeleitet.",
                                                          url = url,
                                                          ms = 2000)

                            })


                            )

  )
}
