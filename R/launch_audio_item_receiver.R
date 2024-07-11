

#' Launch audio item receiver
#'
#' @param max_goes
#' @param paradigm_type
#' @param app_name
#' @param app_url
#'
#' @return
#' @export
#'
#' @examples
launch_audio_item_receiver <- function(max_goes = 3L,
                                       paradigm_type = c("call_and_response",
                                                         "simultaneous_recall"),
                                       app_name,
                                       app_url = "https://dev.singpause.songbird.training/dashboard/") {

  paradigm_type <- match.arg(paradigm_type)

  timeline <- tl_audio_receiver(max_goes, paradigm_type)


  musicassessr::make_musicassessr_test(

    welcome_page = musicassessr::empty_code_block(),

    title = "SingPause",

    admin_password = Sys.getenv("ADMIN_PASSWORD"),

    elts = function() {
      timeline
    },

    opt = musicassessr::musicassessr_opt(setup_pages = TRUE,
                                         setup_options = musicassessr::setup_pages_options(skip_setup = 'except_microphone', playful_volume_meter_setup = TRUE),
                                         visual_notation = TRUE,
                                         instrument_id = 1L, # Voice
                                         app_name = app_name,
                                         asynchronous_api_mode = TRUE,
                                         redirect_on_failure_url = app_url,
                                         css = c("https://musicassessr.com/assets/css/style_songbird.css", system.file("www/css/musicassessr.css", package = 'musicassessr'))),

    final_page = musicassessr::redirect_page(text = psychTestR::i18n("redirect_message"),
                                             ms = 3000,
                                             url = app_url,
                                             final = TRUE),

    # psychTestR vars
    logo = "https://musicassessr.com/assets/songbird_logo.png",
    logo_width = "200px",
    logo_height = "76px",
    logo_position = 'left',
    logo_url = app_url,
    enable_admin_panel = FALSE,

    # The custom-translated SingPause dictionary
    dict = singpause_dict,

    languages = c('de', 'en')

  )
}


tl_audio_receiver <- function(max_goes, paradigm_type) {

  psychTestR::join(
    reactive_audio_file_melodic_production_page(max_goes, paradigm_type)
  )

}
