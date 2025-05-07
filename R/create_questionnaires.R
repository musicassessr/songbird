


likert_fragen <- c("Stimme überhaupt nicht zu",
                   "Stimme eher nicht zu",
                   "Stimme eher zu",
                   "Stimme voll und ganz zu")

likert_fragen2 <- c("Stimmt gar nicht",
                    "Stimmt eher nicht",
                    "Stimmt eher",
                    "Stimmt genau")

likert_fragen3 <- c("Trifft überhaupt nicht zu", "Trifft kaum zu", "Trifft eher Nicht zu", "Teils-teils", "Trifft eher zu", "Trifft sehr zu", "Trifft voll zu")


btn_script_4FC <- shiny::tags$script(
  htmltools::HTML(
    '
  if(typeof buttonMappings === "undefined") {
  console.log("boom!");
    const buttonMappings = [
    { id: "Stimme überhaupt nicht zu", image: "img/rating_1.png" },
    { id: "Stimme eher nicht zu", image: "img/rating_2.png" },
    { id: "Stimme eher zu", image: "img/rating_3.png" },
    { id: "Stimme voll und ganz zu", image: "img/rating_4.png" }
  ];
    buttonMappings.forEach(({ id, image }) => {
    let button = document.getElementById(id);
    if (button) {
      let img = document.createElement("img");
      img.src = image;
      img.alt = button.innerText;
      img.style.cursor = "pointer";
      img.style.width = "50px"; // Set width
      img.style.height = "50px"; // Set height
      img.onclick = function () {
        trigger_button(id);
      };

      let parent = button.parentNode;
      parent.insertBefore(img, button);
      parent.removeChild(button);
    }
  });
  }
  '
  )
)

#' Create timeline
#'
#' @param type
#' @param pre_post
#'
#' @returns
#' @export
#'
#' @examples
create_timeline <- function(type = c("kids", "teachers", "parents"),
                            pre_post = c("pre", "post")) {
  if (type == "kids") {
    items <- readxl::read_excel( system.file('extdata/Instrumente_2025-02-22_Seb_final.xlsx', package = 'songbird') ,
                                sheet = "Items_Kinder",
                                skip = 1)  %>%
      dplyr::slice(1:2, 7:64) %>%
      tidyr::fill(Einsatz) %>%
      tidyr::fill(Konstrukt) %>%
      dplyr::filter(Konstrukt != "Aktuelle Musikalische Aktivitäten")
    # We use the psyquest implementation

  }

  if (type == "parents") {

    items <- readxl::read_excel( system.file('extdata/Instrumente_2025-02-22_Seb_final.xlsx', package = 'songbird'),
                                sheet = "Items_Eltern",
                                skip = 1)  %>%
      dplyr::slice(1:78) %>%
      tidyr::fill(Einsatz) %>%
      tidyr::fill(Domäne) %>%
      dplyr::filter(Domäne != "BIG 5 Persönlichkeit") # psyquest instead

  }


  if (type == "teachers") {

    items <- readxl::read_excel( system.file('extdata/Instrumente_2025-02-22_Seb_final.xlsx', package = 'songbird') ,
                                sheet = "Items_Singleiter",
                                skip = 1) %>%

      dplyr::slice(1:58) %>%
      tidyr::fill(Einsatz)

  }

  # Normalise columns across idiosyncracies
  if (type %in% c("kids", "parents")) {
    items <- items %>%
      dplyr::mutate(`Benennung Item` = NA)
  } else {
    items$`Priorisierung: EFT-C` <- NULL
  }

  # Filter based on test type
  if (pre_post == "pre") {
    items <- items %>%
      dplyr::filter(Einsatz != "nur Post-Test")
  }

  if (pre_post == "post") {
    items <- items %>%
      dplyr::filter(Einsatz != "nur Prä-Test")
  }

  # Construct timeline

  tl <- purrr::pmap_dfr(items, function(Domäne,
                                 Konstrukt,
                                 Quelle,
                                 Einsatz,
                                 Fragetext,
                                 Instruktion,
                                 Antwortformat,
                                 Antwortskala,
                                 Items,
                                 `Benennung Item`,
                                 NegativelyCoded) {
    if (is.na(Antwortskala)) {
      return(NULL)

    } else if (length(Antwortformat) > 0L &&
               !is.na.scalar(Antwortformat) && Antwortformat %in% c("Dropdown", "DropdownOther")) {
      choices <- stringr::str_split_1(Antwortskala, ";")

      p <- psychTestR::dropdown_page(
        label = gsub("[^[:alnum:]]", "", Konstrukt),
        prompt = Items,
        choices = choices,
        next_button_text = "Weiter",
        max_width_pixels = 600,
        alternative_choice = Antwortformat == "DropdownOther",
        alternative_text = "Sonstiges (bitte angeben)"
      )

    } else if (Antwortskala == "Mehrfachnennung") {

      choices <- stringr::str_split_1(Items, ";") %>%
        gsub("[^[:alpha:] ]", "", .)

      p <- psychTestR::checkbox_page(
        label = gsub("[^[:alnum:]]", "", Konstrukt),
        prompt = Instruktion,
        trigger_button_text = "Weiter",
        choices = choices
      )

    } else if (grepl("TextInput", Antwortskala)) {

      p <- psychTestR::text_input_page(
        label = gsub("[^[:alnum:]]", "", Konstrukt),
        prompt = shiny::tags$div(
          if (!is.na(Instruktion))
            shiny::tags$p(shiny::tags$strong(Instruktion)),
          shiny::tags$p(Items)
        ),
        one_line = FALSE,
        button_text = "Weiter"
      )

    } else if (grepl(";", Antwortskala)) {
      choices <- stringr::str_split_1(Antwortskala, ";") %>%
        gsub("[^[:alpha:] ]", "", .)

      p <- psychTestR::NAFC_page(
        label = gsub("[^[:alnum:]]", "", Konstrukt),
        prompt = shiny::tags$div(
          if (!is.na(Instruktion))
            shiny::tags$p(shiny::tags$strong(Instruktion)),
          shiny::tags$p(Items)
        ),
        choices = choices
      )

    } else if (Antwortskala %in%
               c(
                 "4stufige Likert-Skala",
                 '4stufige Likert-Skala von "stimme gar nicht zu" bis "stimme voll zu"'
               ))
    {
      p <- psychTestR::NAFC_page(
        label = gsub("[^[:alnum:]]", "", Konstrukt),
        arrange_vertically = FALSE,
        prompt = shiny::tags$div(
          if (!is.na(Instruktion))
            shiny::tags$p(shiny::tags$strong(Instruktion)),
          shiny::tags$p(Items),

          if (type == "kids")
            btn_script_4FC

        ),
        choices = likert_fragen
      )

    } else if (Antwortskala == "4stufig „stimmt gar nicht“ - „stimmt genau“") {
      p <- psychTestR::NAFC_page(
        label = gsub("[^[:alnum:]]", "", Konstrukt),
        prompt = shiny::tags$div(
          if (!is.na(Instruktion))
            shiny::tags$p(shiny::tags$strong(Instruktion)),
          shiny::tags$p(Items)
        ),
        choices = likert_fragen2
      )

    } else if (Antwortskala == "7stufige Likert-Skala") {
      p <- psychTestR::NAFC_page(
        label = gsub("[^[:alnum:]]", "", Konstrukt),
        prompt = shiny::tags$div(
          if (!is.na(Instruktion))
            shiny::tags$p(shiny::tags$strong(Instruktion)),
          shiny::tags$p(Items)
        ),
        choices = likert_fragen3
      )

    } else {
      return(NULL)
    }

    Konstrukt <- stringr::str_replace_all(Konstrukt, "ü", "u") %>%
      stringr::str_replace_all("ä", "a") %>%
      stringr::str_replace("Ü", "U") %>%
      stringr::str_replace("ö", "o")

    return(tibble::tibble(
      module = gsub("[^[:alpha:]]", "", Konstrukt),
      module_start = Fragetext,
      page = list(p)
    ))

  })

  tl <- tl %>%
    tidyr::fill(module) %>%
    dplyr::group_by(module) %>%
    dplyr::mutate(no_in_module = dplyr::row_number()) %>%
    dplyr::ungroup() %>%
    purrr::pmap_dfr(function(module,
                      module_start,
                      page,
                      no_in_module) {

      logging::loginfo('module %s', module)

      page@label <- paste0(module, "_", no_in_module)

      tibble::tibble(module = module,
                     page = list(page),
                     module_start = module_start)
    })



  modules <- tl$module %>% unique()

  lang <- if(type == "kids") "de" else "de_f"


  tl <- purrr::map(modules, function(module) {
    pages <- tl %>%
      dplyr::filter(module == !!module)

    module_start <- pages$module_start %>% unique()
    module_start <- module_start[!is.na(module_start)]

    logging::loginfo("module_start: %s", module_start)

    if (length(module_start) > 0L &&
        !is.na.scalar(module_start)) {
      module_start <- psychTestR::one_button_page(module_start, button_text = "Weiter")
    }

    pages_unlisted <- unlist(pages$page)

    if (length(module_start) > 0L &&
        !is.na.scalar(module_start)) {
      pages_unlisted <- psychTestR::join(module_start, pages_unlisted)
    }

    # pages_unlisted <- psychTestR::randomise_at_run_time(
    #   label = paste0(module, "_order"),
    #   logic = pages_unlisted)

    psychTestR::module(label = module, pages_unlisted)
  }) %>%
    unlist() %>%
    psychTestR::new_timeline(default_lang = lang )


}
