

#' Audio melodic production block
#'
#' @param audio_df
#' @param max_goes
#' @param user_id
#' @param paradigm_type
#'
#' @return
#' @export
#'
#' @examples
audio_file_melodic_production_block <- function(audio_df,
                                                max_goes = 3L,
                                                user_id = 1L,
                                                paradigm_type = c("call_and_response", "simultaneous_recall")) {

  paradigm_type <- match.arg(paradigm_type)

  total_no_melodies <- nrow(audio_df)

  audio_df <- audio_df %>%
    dplyr::mutate(melody_no = dplyr::row_number() ) %>%
    purrr::pmap(iterate_row, total_no_melodies = total_no_melodies, max_goes = max_goes, user_id = user_id, paradigm_type = paradigm_type) %>%
    unlist()

}



# Function to convert row to dataframe
iterate_row <- function(..., total_no_melodies, max_goes = 3L, user_id = 1L, paradigm_type = c("call_and_response", "simultaneous_recall")) {


  paradigm_type <- match.arg(paradigm_type)

  # Convert the row to a DF
  tb_row <- tibble::as_tibble(list(...))

  audio_file <- tb_row$audio_file

  audio_file_path <- paste0('assets/audio/', audio_file)

  audio_file_melodic_production_page(tb_row,
                                     audio_file_path,
                                     audio_file,
                                     total_no_melodies,
                                     max_goes,
                                     attempts_left = 2L,
                                     melody_no = tb_row$melody_no,
                                     user_id = user_id,
                                     paradigm_type = paradigm_type)

}



#' Audio file melodic production page
#'
#' @param tb_row
#' @param audio_file_path
#' @param audio_file
#' @param total_no_melodies
#' @param max_goes
#' @param attempts_left
#' @param melody_no
#' @param page_title
#' @param page_text
#' @param user_id
#' @param paradigm_type
#'
#' @return
#' @export
#'
#' @examples
audio_file_melodic_production_page <- function(tb_row,
                                              audio_file_path,
                                              audio_file,
                                              total_no_melodies,
                                              max_goes = 3L,
                                              attempts_left,
                                              melody_no,
                                              page_title = if(paradigm_type == "simultaneous_recall") "Sing along with the melody" else "Sing back the melody",
                                              page_text = shiny::tags$div(
                                                shiny::tags$img(id = "singImage", src = "https://musicassessr.com/assets/img/singing.png", height = 100, width = 100)
                                              ),
                                              user_id = 1L,
                                              paradigm_type = c("call_and_response", "simultaneous_recall")) {


  paradigm_type <- match.arg(paradigm_type)


  psychTestR::join(

    psychTestR::code_block(function(state, ...) {

      # Repeat melody logic stuff
      psychTestR::set_global("user_satisfied", "Try Again", state)
      psychTestR::set_global("number_attempts", 1, state)
      psychTestR::set_global("max_goes", max_goes, state)
      psychTestR::set_global("attempts_left", max_goes, state)

    }),

    # Keep in loop until the participant confirms they are happy with their entry
    psychTestR::while_loop(test = function(state, ...) {
      number_attempts <- psychTestR::get_global("number_attempts", state)
      user_answer <- psychTestR::get_global("user_satisfied", state)
      user_wants_to_play_again <- user_answer == "Try Again"
    },
    logic = list(

      psychTestR::reactive_page(function(state, ...) {

        db_vars <- if(psychTestR::get_global("asynchronous_api_mode", state)) {

          list(
            midi_vs_audio = "audio",
            stimuli = tb_row$abs_melody,
            stimuli_durations = tb_row$durations,
            trial_time_started = Sys.time(),
            instrument = psychTestR::get_global("inst", state),
            attempt = 1L,
            item_id = tb_row$item_id,
            display_modality = "audio",
            phase = "test",
            rhythmic = TRUE,
            session_id = musicassessr::get_promise_value(psychTestR::get_global("session_id", state)),
            test_id = 1L, # SAA
            review_items_id = NULL,
            new_items_id = NULL,
            user_id = user_id,
            feedback = TRUE,
            feedback_type = "opti3"
          )
        } else NULL

        # Grab various variables
        number_attempts <- psychTestR::get_global("number_attempts", state)
        max_goes <- psychTestR::get_global("max_goes", state)
        attempts_left <- psychTestR::get_global("attempts_left", state) - 1L

        musicassessr::present_stimuli(
          stimuli = audio_file_path,
          stimuli_type = "audio",
          display_modality = "auditory",
          page_title = page_title,
          page_text = shiny::tags$div(
            musicassessr::set_melodic_stimuli(itembankr::str_mel_to_vector(tb_row$abs_melody),
                                              itembankr::str_mel_to_vector(tb_row$durations)),
            page_text
            ),
          page_type = "record_audio_page",
          get_answer = musicassessr::get_answer_add_trial_and_compute_trial_scores_s3,
          hideOnPlay = TRUE,
          page_label = audio_file,
          answer_meta_data = tb_row,
          db_vars = db_vars,
          audio_playback_as_single_play_button = TRUE,
          happy_with_response = TRUE,
          attempts_left = attempts_left,
          max_goes = max_goes,
          total_no_melodies = total_no_melodies,
          show_progress = FALSE,
          melody_no = melody_no,
          lyrics = tb_row$lyrics,
          trigger_start_of_stimulus_fun = musicassessr::paradigm(paradigm_type = paradigm_type, stimuli_type = "audio", feedback = TRUE, asynchronous_api_mode = TRUE)$trigger_start_of_stimulus_fun,
          trigger_end_of_stimulus_fun = musicassessr::paradigm(paradigm_type = paradigm_type, stimuli_type = "audio", feedback = TRUE, asynchronous_api_mode = TRUE)$trigger_end_of_stimulus_fun
        )

      }),

      musicassessr::update_play_melody_loop_and_save(max_goes)
    )
    )
  )
}


