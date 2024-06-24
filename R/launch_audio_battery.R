


launch_audio_battery <- function(max_goes = 3L,
                                 user_id = 1L,
                                 paradigm_type = c("call_and_response", "simultaneous_recall")) {

  paradigm_type <- match.arg(paradigm_type)

  common_names <- intersect(names(singpause_item_item_bank), names(singpause_phrase_item_bank))

  audio_df <- rbind(
    dplyr::select(tibble::as_tibble(singpause_phrase_item_bank), dplyr::all_of(common_names)),
    dplyr::select(tibble::as_tibble(singpause_item_item_bank), dplyr::all_of(common_names))
  ) %>%
    dplyr::slice(20:42)


  timeline <- tl(audio_df, max_goes, user_id, paradigm_type)


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
                                         user_id = user_id,
                                         username = "BOOM SET THIS UP",
                                         css = c("https://musicassessr.com/assets/css/style_songbird.css",
                                                 system.file("www/css/musicassessr.css", package = 'musicassessr')
                                                 )),


    final_page = musicassessr::redirect_page(text = "Well done! You will now be redirected back to your dashboard.",
                                             ms = 3000,
                                             url = "https://singpause.songbird.training/dashboard/",
                                             final = TRUE),

    # psychTestR vars
    logo = "https://musicassessr.com/assets/songbird_logo.png",
    logo_width = "200px",
    logo_height = "76px",
    logo_position = 'left',
    logo_url = "https://dev.singpause.songbird.training/dashboard/",
    enable_admin_panel = FALSE,

    # The custom-translated SingPause dictionary
    dict = singpause_dict,

    languages = c('de', 'en')
  )

}


tl <- function(audio_df, max_goes, user_id, paradigm_type) {

  psychTestR::join(

    audio_file_melodic_production_block(audio_df, max_goes, user_id, paradigm_type)
  )

}

